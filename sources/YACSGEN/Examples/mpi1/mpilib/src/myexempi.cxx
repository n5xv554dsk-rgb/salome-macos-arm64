#include "mylibmpi.h"
#include <iostream>
#include <mpi.h>

int main(int argc, char* argv[]) 
{ 
    int  namelen, numprocs, myid ; 
    int result;
    Mylibmpi myinstance;

    /** initialisation de mpi **/ 
    MPI_Init(&argc,&argv); 
    /** combien y-a-t-il de processeurs ? **/ 
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs); 
    /** numero du processus courant **/ 
    MPI_Comm_rank(MPI_COMM_WORLD,&myid); 
    
    result = myinstance.mympi_funct(3);
    if(MASTER == myid)
      std::cout << "Resultat:" << result << std::endl;

    /** fin du pg **/ 
    MPI_Finalize(); 

    return 0; 
}