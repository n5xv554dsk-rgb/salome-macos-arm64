"""PARAVIS / ParaView renders of a pdsalome MED time series (cell fields Damage, Displacement, Velocity).

Usage from a script:   from pdsalome.viz import render; render(".../solution.med", out_dir)
Command line:          ./salome python pd_dynamic/render.py <results dir> [warp scale]
"""

import os

_SALOME_ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
MEDREADER = os.path.join(_SALOME_ROOT, "install/PARAVIS/lib/paraview/MEDReader.so")


def open_med(pvs, sol_med):
    """MEDReader with all fields of the time-step group that holds Damage (only one group may be active)."""
    if not getattr(open_med, "_loaded", False):
        pvs.LoadPlugin(MEDREADER, remote=False)
        open_med._loaded = True
    reader = pvs.MEDReader(FileNames=[sol_med])
    leaves = list(reader.GetProperty("FieldsTreeInfo")[::2])
    ts = next(l.split("/")[0] for l in leaves if "/Damage@@" in l)
    reader.FieldsStatus = [l for l in leaves if l.startswith(ts + "/") and "/ComSup" in l]
    reader.UpdatePipeline()
    return reader


def render(sol_med, out_dir, warp_scale=20.0, snapshots=(0.25, 0.5, 0.75, 1.0), log=print):
    import paraview.simple as pvs

    reader = open_med(pvs, sol_med)
    times = list(reader.TimestepValues)
    b = reader.GetDataInformation().GetBounds()
    cx, cy, cz = (b[0] + b[1]) / 2, (b[2] + b[3]) / 2, (b[4] + b[5]) / 2
    Lx, Ly = b[1] - b[0], b[3] - b[2]

    view = pvs.CreateRenderView()
    try:
        view.UseColorPaletteForBackground = 0
    except AttributeError:
        pass
    view.Background = [1, 1, 1]
    view.OrientationAxesVisibility = 0

    lut = pvs.GetColorTransferFunction("Damage")
    lut.ApplyPreset("Turbo", True)
    lut.RescaleTransferFunction(0.0, 1.0)
    sb = pvs.GetScalarBar(lut, view)
    sb.Title = "damage"
    sb.ComponentTitle = ""
    sb.TitleColor = sb.LabelColor = [0.1, 0.1, 0.1]
    sb.RangeLabelFormat = "%-#.1f"

    text = pvs.Text()
    td = pvs.Show(text, view)
    td.FontSize = 15
    td.Color = [0.1, 0.1, 0.1]
    td.WindowLocation = "Upper Center"
    images = []

    # 1. Deformed 3D plate at the last time, damage on the cells
    c2p = pvs.CellDatatoPointData(Input=reader)
    c2p.PassCellData = 1
    warp = pvs.WarpByVector(Input=c2p)
    warp.Vectors = ["POINTS", "Displacement"]
    warp.ScaleFactor = warp_scale
    view.ViewSize = [1600, 900]
    view.ViewTime = times[-1]
    d = pvs.Show(warp, view)
    pvs.ColorBy(d, ("CELLS", "Damage"))
    d.SetScalarBarVisibility(view, True)
    text.Text = f"damage on deformed plate (displacement x{warp_scale:g}), t = {times[-1] * 1e6:.1f} us"
    pvs.Render(view)  # first render resets the camera; set ours after it
    view.CameraParallelProjection = 0
    view.CameraFocalPoint = [cx, cy, cz]
    view.CameraPosition = [cx + 0.35 * Lx, cy - 1.1 * Ly, cz + 1.25 * Lx]
    view.CameraViewUp = [0, 1, 0]
    view.CameraViewAngle = 30
    pvs.Render(view)
    img = os.path.join(out_dir, "damage_3d_deformed.png")
    pvs.SaveScreenshot(img, view, ImageResolution=[1600, 900])
    images.append(img)
    pvs.Hide(warp, view)

    # 2. Mid-plane slice, top view, several times
    sl = pvs.Slice(Input=reader)
    sl.SliceType = "Plane"
    sl.SliceType.Origin = [cx, cy, cz + 1e-9]
    sl.SliceType.Normal = [0, 0, 1]
    d2 = pvs.Show(sl, view)
    pvs.ColorBy(d2, ("CELLS", "Damage"))
    d2.SetScalarBarVisibility(view, True)
    view.ViewSize = [1600, 760]
    view.CameraParallelProjection = 1
    view.CameraFocalPoint = [cx + 0.03 * Lx, cy, cz]
    view.CameraPosition = [cx + 0.03 * Lx, cy, cz + 1.0]
    view.CameraViewUp = [0, 1, 0]
    view.CameraParallelScale = 0.62 * Ly
    for frac in snapshots:
        tv = times[min(len(times) - 1, round(frac * (len(times) - 1)))]
        view.ViewTime = tv
        text.Text = f"mid-plane damage, t = {tv * 1e6:.1f} us"
        pvs.Render(view)
        img = os.path.join(out_dir, f"damage_midplane_t{tv * 1e6:04.1f}us.png")
        pvs.SaveScreenshot(img, view, ImageResolution=[1600, 760])
        images.append(img)

    for i in images:
        log(f"  {i}")
    pvs.Delete(view)
    return images
