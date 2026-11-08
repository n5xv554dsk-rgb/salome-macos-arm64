// pdcore — explicit dynamic ordinary state-based peridynamics (3D), as a shared library
//
// Ported from ~/Desktop/pd/Ordinery-SB-3d/main_osb3d.cpp (same model, same time integration),
// generalized for SALOME meshes:
//   - every node has its own volume V_j (the cell volume from SMESH), not a constant dx*dy*dz
//   - neighbour search by a uniform cell list (no kd-tree dependency)
//   - boundary conditions per DOF: 0 = fixed displacement, 1 = body force (N/m^3) x f(t),
//     2 = prescribed velocity (u = value * t)
//   - f(t) = linear ramp to 1 over t_ramp (t_ramp = 0 -> step load, like main_osb3d)
//   - Python drives the time loop in chunks (pd_run) and reads the state back (pd_get_*)
//
// Model: 3D linear peridynamic solid (LPS, Silling et al. 2007)
//   e    = |xi + eta| - |xi|
//   m_i  = sum_j w |xi|^2 beta V_j
//   th_i = (3 / m_i) sum_j w |xi| e beta V_j
//   t_ij = (3K / m_i) th_i w |xi| + (15 mu / m_i) w (e - th_i |xi| / 3) = w (A_i th_i |xi| + B_i e)
//   F_i  = sum_j (t_ij + t_ji) M_ij beta V_j + b,  A_i = (3K - 5mu)/m_i, B_i = 15mu/m_i
// Bonds break when e / |xi| > s0.
//
// Plasticity (next stage) will add a plastic bond extension e_p per bond (BondEp) and replace
// e by (e - e_p) in the deviatoric part; the bond loop is kept in one place (pass 2) for that.

#define _USE_MATH_DEFINES
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <vector>
#ifdef _OPENMP
#include <omp.h>
#endif

namespace {

struct Rect
{
	double p0[3], p1[3], p2[3];
};

struct Model
{
	// Geometry
	int n = 0;
	std::vector<double> X;    // 3n
	std::vector<double> Vol;  // n
	double R = 0.0, dx = 0.0;
	int influence = 1;        // 1: w = R/|xi|, 0: w = 1

	// Material
	double E = 0.0, Nu = 0.25, Rho = 0.0, s0 = 1e30;

	std::vector<Rect> cracks;

	// Bonds (CSR)
	std::vector<int64_t> start;  // n+1
	std::vector<int> node;       // neighbour, -1 = broken
	std::vector<double> xi, wb, y;
	std::vector<double> bondCount;  // initial bonds incl. precrack-cut (damage, same as main_osb3d)
	std::vector<double> A, B, ThreeOverM, ATheta, Theta, Phi;
	bool built = false;

	// BC / IC
	std::vector<int> bct, ict;
	std::vector<double> bcv, icv;
	double tRamp = 0.0;

	// State
	std::vector<double> U, V, Acc, U1, V1, Acc1;
	double t = 0.0;
	int64_t step = 0;
};

double dot3(const double a[3], const double b[3]) { return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]; }

bool in_rectangle(const double x[3], const double p0[3], const double a[3], const double b[3])
{
	const double d[3] = { x[0] - p0[0], x[1] - p0[1], x[2] - p0[2] };
	const double u = dot3(d, a) / dot3(a, a);
	const double v = dot3(d, b) / dot3(b, b);
	return u >= 0.0 && u <= 1.0 && v >= 0.0 && v <= 1.0;
}

// Same test as main_osb3d.cpp: touching counts as cutting
bool segment_rectangle_intersect(const double p[3], const double q[3], const Rect &r)
{
	const double a[3] = { r.p1[0] - r.p0[0], r.p1[1] - r.p0[1], r.p1[2] - r.p0[2] };
	const double b[3] = { r.p2[0] - r.p0[0], r.p2[1] - r.p0[1], r.p2[2] - r.p0[2] };
	const double nrm[3] = { a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0] };
	const double dp[3] = { p[0] - r.p0[0], p[1] - r.p0[1], p[2] - r.p0[2] };
	const double dq[3] = { q[0] - r.p0[0], q[1] - r.p0[1], q[2] - r.p0[2] };
	const double sp = dot3(dp, nrm), sq = dot3(dq, nrm);
	if ((sp > 0.0 && sq > 0.0) || (sp < 0.0 && sq < 0.0)) return false;
	if (sp == 0.0 && sq == 0.0) return in_rectangle(p, r.p0, a, b) || in_rectangle(q, r.p0, a, b);
	const double s = sp / (sp - sq);
	const double x[3] = { p[0] + s * (q[0] - p[0]), p[1] + s * (q[1] - p[1]), p[2] + s * (q[2] - p[2]) };
	return in_rectangle(x, r.p0, a, b);
}

double beta(const Model &m, double x)
{
	if (x <= m.R - m.dx / 2.0) return 1.0;
	if (x <= m.R + m.dx / 2.0) return (m.R + m.dx / 2.0 - x) / m.dx;
	return 0.0;
}

double omega(const Model &m, double x) { return m.influence == 1 ? m.R / x : 1.0; }

}  // namespace

extern "C" {

void *pd_create(int n, const double *X, const double *vol, double R, double dx, int influence)
{
	Model *m = new Model;
	m->n = n;
	m->X.assign(X, X + 3 * (size_t)n);
	m->Vol.assign(vol, vol + n);
	m->R = R;
	m->dx = dx;
	m->influence = influence;
	m->bct.assign(3 * (size_t)n, 1);
	m->bcv.assign(3 * (size_t)n, 0.0);
	m->ict.assign(3 * (size_t)n, 1);
	m->icv.assign(3 * (size_t)n, 0.0);
	return m;
}

void pd_destroy(void *h) { delete static_cast<Model *>(h); }

int pd_num_threads()
{
#ifdef _OPENMP
	return omp_get_max_threads();
#else
	return 1;
#endif
}

void pd_set_material(void *h, double E, double nu, double rho, double s0)
{
	Model *m = static_cast<Model *>(h);
	m->E = E; m->Nu = nu; m->Rho = rho; m->s0 = s0;
}

// Rectangle P0 + u (P1 - P0) + v (P2 - P0), 0 <= u, v <= 1; bonds crossing it are cut at pd_build
void pd_add_precrack(void *h, const double *p0, const double *p1, const double *p2)
{
	Rect r;
	for (int k = 0; k < 3; k++) { r.p0[k] = p0[k]; r.p1[k] = p1[k]; r.p2[k] = p2[k]; }
	static_cast<Model *>(h)->cracks.push_back(r);
}

// Neighbour search, precracks, bond constants. Returns number of bonds (each pair counted twice).
int64_t pd_build(void *h)
{
	Model &m = *static_cast<Model *>(h);
	const int n = m.n;
	const double Rs = m.R * (1.0 + 1e-5);  // same tolerance as main_osb3d
	const double Rs2 = Rs * Rs;

	// Cell list with cell size Rs
	double lo[3] = { 1e300, 1e300, 1e300 }, hi[3] = { -1e300, -1e300, -1e300 };
	for (int i = 0; i < n; i++)
		for (int k = 0; k < 3; k++) { lo[k] = std::min(lo[k], m.X[3 * i + k]); hi[k] = std::max(hi[k], m.X[3 * i + k]); }
	int nc[3];
	for (int k = 0; k < 3; k++) nc[k] = std::max(1, (int)std::floor((hi[k] - lo[k]) / Rs) + 1);
	auto cell_of = [&](int i, int c[3]) {
		for (int k = 0; k < 3; k++) c[k] = std::min(nc[k] - 1, (int)std::floor((m.X[3 * i + k] - lo[k]) / Rs));
	};
	const size_t ncell = (size_t)nc[0] * nc[1] * nc[2];
	std::vector<int> cstart(ncell + 1, 0), cnodes(n);
	std::vector<size_t> cid(n);
	for (int i = 0; i < n; i++) { int c[3]; cell_of(i, c); cid[i] = ((size_t)c[2] * nc[1] + c[1]) * nc[0] + c[0]; cstart[cid[i] + 1]++; }
	for (size_t c = 0; c < ncell; c++) cstart[c + 1] += cstart[c];
	{
		std::vector<int> fill(cstart.begin(), cstart.end() - 1);
		for (int i = 0; i < n; i++) cnodes[fill[cid[i]]++] = i;
	}

	std::vector<std::vector<int>> nb(n);
	#pragma omp parallel for schedule(dynamic, 256)
	for (int i = 0; i < n; i++)
	{
		int c[3]; cell_of(i, c);
		const double *xi = &m.X[3 * i];
		for (int dz = -1; dz <= 1; dz++) for (int dy = -1; dy <= 1; dy++) for (int dxx = -1; dxx <= 1; dxx++)
		{
			const int cx = c[0] + dxx, cy = c[1] + dy, cz = c[2] + dz;
			if (cx < 0 || cy < 0 || cz < 0 || cx >= nc[0] || cy >= nc[1] || cz >= nc[2]) continue;
			const size_t cc = ((size_t)cz * nc[1] + cy) * nc[0] + cx;
			for (int q = cstart[cc]; q < cstart[cc + 1]; q++)
			{
				const int j = cnodes[q];
				if (j == i) continue;
				const double *xj = &m.X[3 * j];
				const double d0 = xj[0] - xi[0], d1 = xj[1] - xi[1], d2 = xj[2] - xi[2];
				if (d0 * d0 + d1 * d1 + d2 * d2 <= Rs2) nb[i].push_back(j);
			}
		}
		std::sort(nb[i].begin(), nb[i].end());  // deterministic order
	}

	m.start.assign(n + 1, 0);
	for (int i = 0; i < n; i++) m.start[i + 1] = m.start[i] + (int64_t)nb[i].size();
	const int64_t nbond = m.start[n];
	m.node.assign(nbond, -1);
	m.xi.assign(nbond, 0.0);
	m.wb.assign(nbond, 0.0);
	m.y.assign(nbond, 0.0);
	m.bondCount.assign(n, 0.0);

	#pragma omp parallel for schedule(dynamic, 256)
	for (int i = 0; i < n; i++)
	{
		const double *p = &m.X[3 * i];
		for (size_t k = 0; k < nb[i].size(); k++)
		{
			const int64_t b = m.start[i] + (int64_t)k;
			const int j = nb[i][k];
			const double *q = &m.X[3 * j];
			bool cut = false;
			for (const Rect &r : m.cracks) if (segment_rectangle_intersect(p, q, r)) { cut = true; break; }
			if (cut) continue;
			const double d0 = q[0] - p[0], d1 = q[1] - p[1], d2 = q[2] - p[2];
			const double L = std::sqrt(d0 * d0 + d1 * d1 + d2 * d2);
			m.node[b] = j;
			m.xi[b] = L;
			m.wb[b] = omega(m, L) * beta(m, L) * m.Vol[j];
		}
		m.bondCount[i] = (double)nb[i].size();
	}

	const double K = m.E / (3.0 * (1.0 - 2.0 * m.Nu));
	const double mu = m.E / (2.0 * (1.0 + m.Nu));
	m.A.assign(n, 0.0); m.B.assign(n, 0.0); m.ThreeOverM.assign(n, 0.0);
	m.ATheta.assign(n, 0.0); m.Theta.assign(n, 0.0); m.Phi.assign(n, 0.0);

	#pragma omp parallel for
	for (int i = 0; i < n; i++)
	{
		double mm = 0.0;
		int active = 0;
		for (int64_t b = m.start[i]; b < m.start[i + 1]; b++)
			if (m.node[b] != -1) { mm += m.wb[b] * m.xi[b] * m.xi[b]; active++; }
		if (mm > 0.0) { m.A[i] = (3.0 * K - 5.0 * mu) / mm; m.B[i] = 15.0 * mu / mm; m.ThreeOverM[i] = 3.0 / mm; }
		m.Phi[i] = m.bondCount[i] > 0 ? 1.0 - active / m.bondCount[i] : 0.0;
	}

	const size_t nd = 3 * (size_t)n;
	m.U.assign(nd, 0.0); m.V.assign(nd, 0.0); m.Acc.assign(nd, 0.0);
	m.U1.assign(nd, 0.0); m.V1.assign(nd, 0.0); m.Acc1.assign(nd, 0.0);
	m.t = 0.0; m.step = 0;
	m.built = true;
	return nbond;
}

// types/values: 3n each (DOF 3i+k)
void pd_set_bc(void *h, const int *types, const double *values)
{
	Model &m = *static_cast<Model *>(h);
	m.bct.assign(types, types + 3 * (size_t)m.n);
	m.bcv.assign(values, values + 3 * (size_t)m.n);
}

// ictype 0: velocity held at value for all time (main_osb3d convention); also sets the initial velocity
void pd_set_ic(void *h, const int *types, const double *values)
{
	Model &m = *static_cast<Model *>(h);
	m.ict.assign(types, types + 3 * (size_t)m.n);
	m.icv.assign(values, values + 3 * (size_t)m.n);
	for (size_t k = 0; k < m.V.size(); k++) m.V[k] = m.ict[k] == 0 ? m.icv[k] : 0.0;
}

void pd_set_load_ramp(void *h, double t_ramp) { static_cast<Model *>(h)->tRamp = t_ramp; }

// Advance nsteps of size dt (velocity Verlet, same as main_osb3d). Returns 0, or -1 if not built.
int pd_run(void *h, int nsteps, double dt)
{
	Model &m = *static_cast<Model *>(h);
	if (!m.built) return -1;

	const int n = m.n;
	const double half_dt = dt / 2.0;
	const double s0 = m.s0, rho = m.Rho, t_ramp = m.tRamp;
	const double t_start = m.t;

	const int64_t *bs = m.start.data();
	int *bn = m.node.data();
	const double *X = m.X.data(), *bxi = m.xi.data(), *bwb = m.wb.data();
	double *by = m.y.data();
	const double *Ai = m.A.data(), *Bi = m.B.data(), *tom = m.ThreeOverM.data(), *bc = m.bondCount.data();
	double *ath = m.ATheta.data(), *th = m.Theta.data(), *phi = m.Phi.data();
	const int *bct = m.bct.data(), *ict = m.ict.data();
	const double *bcv = m.bcv.data(), *icv = m.icv.data();
	double *U = m.U.data(), *V = m.V.data(), *Ac = m.Acc.data();
	double *U1 = m.U1.data(), *V1 = m.V1.data(), *Ac1 = m.Acc1.data();

	#pragma omp parallel
	for (int s = 1; s <= nsteps; s++)
	{
		const double t = t_start + s * dt;
		const double ft = t_ramp > 0.0 ? std::min(1.0, t / t_ramp) : 1.0;

		#pragma omp for schedule(static)
		for (int k = 0; k < 3 * n; k++)
		{
			if (bct[k] == 0) U1[k] = bcv[k];
			else if (bct[k] == 2) U1[k] = bcv[k] * t;
			else U1[k] = U[k] + dt * (V[k] + half_dt * Ac[k]);
		}

		// Pass 1: dilatation
		#pragma omp for schedule(static)
		for (int i = 0; i < n; i++)
		{
			const double ux = U1[3 * i], uy = U1[3 * i + 1], uz = U1[3 * i + 2];
			const double xx = X[3 * i], xy = X[3 * i + 1], xz = X[3 * i + 2];
			double sum = 0.0;
			for (int64_t b = bs[i]; b < bs[i + 1]; b++)
			{
				const int j = bn[b];
				if (j == -1) continue;
				const double ex = U1[3 * j] - ux + (X[3 * j] - xx);
				const double ey = U1[3 * j + 1] - uy + (X[3 * j + 1] - xy);
				const double ez = U1[3 * j + 2] - uz + (X[3 * j + 2] - xz);
				const double yy = std::sqrt(ex * ex + ey * ey + ez * ez);
				by[b] = yy;
				sum += bwb[b] * bxi[b] * (yy - bxi[b]);
			}
			th[i] = tom[i] * sum;
			ath[i] = Ai[i] * th[i];
		}

		// Pass 2: forces, bond breaking, velocity, damage
		#pragma omp for schedule(static)
		for (int i = 0; i < n; i++)
		{
			double F[3];
			for (int k = 0; k < 3; k++) F[k] = bct[3 * i + k] == 1 ? bcv[3 * i + k] * ft : 0.0;

			const double ux = U1[3 * i], uy = U1[3 * i + 1], uz = U1[3 * i + 2];
			const double xx = X[3 * i], xy = X[3 * i + 1], xz = X[3 * i + 2];
			const double athi = ath[i], bi = Bi[i];
			int active = 0;
			for (int64_t b = bs[i]; b < bs[i + 1]; b++)
			{
				const int j = bn[b];
				if (j == -1) continue;
				const double ex = U1[3 * j] - ux + (X[3 * j] - xx);
				const double ey = U1[3 * j + 1] - uy + (X[3 * j + 1] - xy);
				const double ez = U1[3 * j + 2] - uz + (X[3 * j + 2] - xz);
				const double L = bxi[b], yy = by[b], e = yy - L;
				const double tt = ((athi + ath[j]) * L + (bi + Bi[j]) * e) * bwb[b] / yy;
				F[0] += tt * ex; F[1] += tt * ey; F[2] += tt * ez;
				if (e / L > s0) bn[b] = -1;
				else active++;
			}
			for (int k = 0; k < 3; k++)
			{
				const int d = 3 * i + k;
				if (bct[d] == 0) { Ac1[d] = 0.0; V1[d] = 0.0; }
				else if (bct[d] == 2) { Ac1[d] = 0.0; V1[d] = bcv[d]; }
				else
				{
					Ac1[d] = F[k] / rho;
					V1[d] = ict[d] == 0 ? icv[d] : V[d] + half_dt * (Ac[d] + Ac1[d]);
				}
			}
			phi[i] = bc[i] > 0 ? 1.0 - active / bc[i] : 0.0;
		}

		#pragma omp single
		{
			std::swap(U, U1); std::swap(V, V1); std::swap(Ac, Ac1);
		}
	}

	// Pointers were swapped locally; make the vectors match
	if (nsteps % 2 == 1) { m.U.swap(m.U1); m.V.swap(m.V1); m.Acc.swap(m.Acc1); }
	m.t = t_start + nsteps * dt;
	m.step += nsteps;
	return 0;
}

static void copy_out(const std::vector<double> &v, double *out) { std::copy(v.begin(), v.end(), out); }

void pd_get_u(void *h, double *out) { copy_out(static_cast<Model *>(h)->U, out); }
void pd_get_v(void *h, double *out) { copy_out(static_cast<Model *>(h)->V, out); }
void pd_get_a(void *h, double *out) { copy_out(static_cast<Model *>(h)->Acc, out); }
void pd_get_phi(void *h, double *out) { copy_out(static_cast<Model *>(h)->Phi, out); }
void pd_get_theta(void *h, double *out) { copy_out(static_cast<Model *>(h)->Theta, out); }
double pd_time(void *h) { return static_cast<Model *>(h)->t; }
int64_t pd_step(void *h) { return static_cast<Model *>(h)->step; }

int pd_max_horizon(void *h)
{
	Model &m = *static_cast<Model *>(h);
	int64_t mx = 0;
	for (int i = 0; i < m.n; i++) mx = std::max(mx, m.start[i + 1] - m.start[i]);
	return (int)mx;
}

int64_t pd_broken_bonds(void *h)
{
	Model &m = *static_cast<Model *>(h);
	int64_t c = 0;
	for (int v : m.node) c += (v == -1);
	return c;
}

}  // extern "C"
