#include "ICOCO.hxx"
#include <stdlib.h>

using namespace std;
int main(int argc, char ** argv)
{
    if (getenv("SALOME_trace") == NULL )
	setenv("SALOME_trace","local",0);
    ICOCO myCalc;
    // test myCalc component ...
}
