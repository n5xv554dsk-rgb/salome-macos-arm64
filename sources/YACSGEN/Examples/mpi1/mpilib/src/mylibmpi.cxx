#include "mylibmpi.h"
#include "mpi.h" 

int Mylibmpi::mympi_funct(int v)
{
    int  namelen, numprocs, myid ; 
    char processor_name[MPI_MAX_PROCESSOR_NAME] ;
    int local_result;
    int result, err_code;

    /** combien y-a-t-il de processeurs ? **/ 
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs); 
    /** numero du processus courant **/ 
    MPI_Comm_rank(MPI_COMM_WORLD,&myid); 
    /** num du processeur courant **/ 
    MPI_Get_processor_name(processor_name,&namelen);
    
    local_result = myid + v;
    err_code = MPI_Reduce(&local_result, &result, 1, MPI_INT, MPI_SUM,
                          MASTER, MPI_COMM_WORLD);
    if(MPI_SUCCESS != err_code)
      printf("%d: failure on mpc_reduce\n", myid);
    
    return result;
//    if(MASTER == myid)
//printf("id %d: result=%d\n", myid, result);

}