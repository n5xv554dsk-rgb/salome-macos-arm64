#ifndef _CALCUL_HXX_
#define _CALCUL_HXX_


class CALCUL
{
// Méthodes publiques
public:
    int add(int i1, int i2);
    int mul(int i1, int i2);
    unsigned fact(unsigned n);
    double addi(double i1, double i2);
    double multi(double i1, double i2);
    double sqr(double i1);
    double sqr2(double i1,double& result);
    void return_3_int(int n, int& f1, int& f2,  int& f3);
    bool And(bool i1, bool i2);
    bool Or(bool i1, bool i2);
};

#endif
