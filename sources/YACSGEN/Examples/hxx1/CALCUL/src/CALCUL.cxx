#include "CALCUL.hxx"

int CALCUL::add(int i1, int i2)
{
    return i1+i2;
}

int CALCUL::mul(int i1, int i2)
{
    return i1*i2;
}

double CALCUL::addi(double i1, double i2)
{
    return i1+i2;
}

double CALCUL::multi(double i1, double i2)
{
    return i1*i2;
}

double CALCUL::sqr(double i1)
{
    return i1*i1;
}

double CALCUL::sqr2(double i1,double& result)
{
    result=i1*i1;
    return result;
}

void CALCUL::return_3_int(int n, int& f1, int& f2,  int& f3)
{
    f1=n+1;
    f2=n+2;
    f3=n+3;
}

unsigned CALCUL::fact(unsigned n)
{
    int factorielle=1;
    for (unsigned i=n; i!=1; --i)
	factorielle*=i;
    return factorielle;
}

bool CALCUL::And(bool i1, bool i2)
{
    return i1&&i2;
}

bool CALCUL::Or(bool i1, bool i2)
{
    return i1||i2;
}
