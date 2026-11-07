/*****************************************************************************

             This file is a part of top-ii-vol meshing tools.

     -------------------------------------------------------------------

     Author(s): Mohd Afeef Badri
     Email    : mohd-afeef.badri@hotmail.com
     Date     : 2019‑10‑29

     -------------------------------------------------------------------

     top-ii-vol  provides  sequential  and  parallel tools for  creating
     volumic tetrahedral meshes from a topology defined by apoint cloud.
     top-ii-vol  is  distributed in the hope that it will be useful, but
     WITHOUT  ANY  WARRANTY; or  without  even  the  implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

*******************************************************************************/


#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <iomanip>
#include <mpi.h>

using namespace std;

int main(int argc, char **argv)
{

//-----------------------------------------------------------------------------------//
//---- MPI variables -----
//-----------------------------------------------------------------------------------//

    int mpisize;
    int mpirank;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &mpisize);
    MPI_Comm_rank(MPI_COMM_WORLD, &mpirank);

//-----------------------------------------------------------------------------------//
//---- Logo -----
//-----------------------------------------------------------------------------------//

    if(mpirank==0)
      #include "./../lib/LogoTopiiVolCpp.hpp"

//-----------------------------------------------------------------------------------//
//---- I/O Files -----
//-----------------------------------------------------------------------------------//

    string *inputfile  = new string();
    string *outputfile = new string();

    *inputfile  = "./../../data/DEM_160m.xyz";
    *outputfile = "point-cloud-strip";

//-----------------------------------------------------------------------------------//
//---- Input Parameters -----
//-----------------------------------------------------------------------------------//

    string *time_log  = new string();
    *time_log  = "";

//-----------------------------------------------------------------------------------//
//---- Input Parameters -----
//-----------------------------------------------------------------------------------//


//-----------------------------------------//
//---- Points in z and zmax -----
//-----------------------------------------//

    double zmax = -1920.0  ;
    int    pntz = 9        ;

//-----------------------------------------//
//---- Points in x & y on the surface -----
//-----------------------------------------//

    // 10m  20m  40m  80m 160m
    int pntx = 32; // 500; 250; 125; 63; 32;
    int pnty = 29; // 451; 226; 113; 57; 29;

//-----------------------------------------//
//---- Partitions in x and y -----
//-----------------------------------------//

    int NpX = mpisize;
    int NpY = 1;
    int NpZ = 1;

    bool userpartitioning = false;       

//-----------------------------------------------------------------------------------//
//---- Comandline Parameters -----
//-----------------------------------------------------------------------------------//

    for(int i=0; i<argc-1; i++)
        {
            string argvdummy = argv[i];

            if(!strcmp(argv[i], "--xpoints"))
                pntx = atoi(argv[i+1]);

            if(!strcmp(argv[i], "--ypoints"))
                pnty = atoi(argv[i+1]);

            if(!strcmp(argv[i], "--zpoints"))
                pntz = atoi(argv[i+1]);

            if(!strcmp(argv[i], "--partition_x"))
            {   NpX = atoi(argv[i+1]); 
                userpartitioning = true;
            }

            if(!strcmp(argv[i], "--partition_y"))
            {   NpY = atoi(argv[i+1]);
                userpartitioning = true;
            }                

            if(!strcmp(argv[i], "--partition_z"))
            {   NpZ = atoi(argv[i+1]);
                userpartitioning = true;
            }                                                

            if(!strcmp(argv[i], "--depth"))
                zmax = atol(argv[i+1]);

            if(!strcmp(argv[i], "--in"))
                *inputfile = argv[i+1];
                
        }

//-----------------------------------------------------------------------------------//
//---- Automatic partitioning for no userpartioning -----
//-----------------------------------------------------------------------------------//

    if(!userpartitioning)
    {
      if(pnty>=pntx && pnty>=pntz)
      {
        NpX = 1; NpY = mpisize; NpZ = 1;           
      }
      else if(pntx>pnty && pntx>=pntz)
      {
        NpX = mpisize; NpY = 1; NpZ = 1;     
      }
      else if(pntz>pnty && pntz>pntx)
      {
        NpX = 1; NpY = 1; NpZ = mpisize;     
      }
    }   
    
//-----------------------------------------------------------------------------------//
//---- Time variable -----
//-----------------------------------------------------------------------------------//

    double t1 = 0     ,
           t_phase    ;    

//-----------------------------------------------------------------------------------//
//---- Main algo for partitioning -----
//-----------------------------------------------------------------------------------//

   t_phase = MPI_Wtime();
   {                                                   // Temporary solution
    #include "./../lib/TopiiVolParPartAlgo1D2D3D.hpp"  // Temporary solution
   }                                                   // Temporary solution
   
//    if(mpirank==0)                                          // Algorithm  fails  for 
//        {                                                   // more than 508 domains
//            #include "./../lib/TopiiVolPartAlgo1D2D3D.hpp"  // due to limitation  on
//        }                                                   // parallel file streams
    t_phase = MPI_Wtime() - t_phase;
    t1 =  t_phase;
    *time_log = string( *time_log+"\tPoint cloud partitioning : "
                        +std::to_string(t_phase)+" s\n"           );

//-----------------------------------------------------------------------------------//
//---- Comandline Parameters -----
//-----------------------------------------------------------------------------------//

    for(int i=0; i<argc-1; i++)
        {

            string argvdummy = argv[i];

            if(!strcmp(argv[i], "--out"))
                *outputfile  = argv[i+1];
        }

    MPI_Barrier(MPI_COMM_WORLD);

    *inputfile  = "point-cloud-strip";

//-----------------------------------------------------------------------------------//
//---- Main algo for meshing -----
//-----------------------------------------------------------------------------------//

    #include "./../lib/TopiiVolMeshAlgo1D2D3D.hpp"

//-----------------------------------------------------------------------------------//
//---- Time  -----
//-----------------------------------------------------------------------------------//
/**/
    MPI_Barrier(MPI_COMM_WORLD);
    if(mpirank==0)
        {
            cout << "                                                               \n"
                 << " *============================================================*\n"
                 <<  "  Time-log:\n"
                 << *time_log                                  
                 <<  "\tThe program finished in   : " << t1 << " s\n"
                 << " *============================================================*\n"
                 << "                                                               \n";
        }

    MPI_Finalize();

    return 0;
}
