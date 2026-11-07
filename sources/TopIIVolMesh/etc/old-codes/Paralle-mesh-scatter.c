/*****************************************************************************
                                                                             
             This file is a part of top-ii-vol meshing tools.                         
                                                                             
     -------------------------------------------------------------------     
                                                                             
     Author(s): Mohd Afeef Badri                                             
     Email    : mohd-afeef.badri@hotmail.com                                                              
     Date     : 2019‑12‑21                                                  
                                                                           
     -------------------------------------------------------------------

     top-ii-vol  provides  sequential  and  parallel tools for  creating  
     volumic tetrahedral meshes from a topology defined by a point cloud.
     top-ii-vol  is  distributed in the hope that it will be useful, but 
     WITHOUT  ANY  WARRANTY; or  without  even  the  implied warranty of 
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

*******************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <mpi.h>


int fetchLocalRows(int mpirank, int mpisize, int multipyFactor, int pntM);
int fetchStartRows(int mpirank, int mpisize, int multipyFactor, int pntM);

int main(int argc, char **argv) {

//-----------------------------------------------------------------------------------//
//---- Global Variables -----
//-----------------------------------------------------------------------------------//

    char filepath[256];

    int ierr 	 ;
    int mpirank	 ;
    int mpisize  ;
    int NPnt     ;
    int startrow ;
    int endrow   ;
    int locnrows ;
    int nrows    ;

    const int charspernum = 41 ;

//-----------------------------------------------------------------------------------//
//---- MPI variables -----
//-----------------------------------------------------------------------------------//

    MPI_Offset 	 offset		;
    MPI_File   	 file		;
    MPI_File   	 file1		;
    MPI_Status 	 status		;
    MPI_Datatype num_as_string	;
    MPI_Request request;

    ierr = MPI_Init(&argc, &argv);
    ierr|= MPI_Comm_size(MPI_COMM_WORLD, &mpisize);
    ierr|= MPI_Comm_rank(MPI_COMM_WORLD, &mpirank);

    MPI_Type_contiguous(charspernum, MPI_CHAR, &num_as_string); 
    MPI_Type_commit(&num_as_string);

    double t1 = MPI_Wtime();

//-----------------------------------------------------------------------------------//
//---- Global Parameters -----
//-----------------------------------------------------------------------------------//

    int pntx=32;
    int pnty=29;

//-----------------------------------------------------------------------------------//
//---- Calculating Parameters -----
//-----------------------------------------------------------------------------------//

    NPnt = pntx * pnty						      ;

//=============================================================================
// ------------- Commandline logo output ------------------
//=============================================================================

    if(mpirank==0){
     #include "./../lib/LogoTopiiVolC.h"
    }

//-----------------------------------------------------------------------------------//
//---- Data allocation -----
//-----------------------------------------------------------------------------------//

    locnrows = fetchLocalRows( mpirank, mpisize, 1, NPnt );
    startrow = fetchStartRows( mpirank, mpisize, 1, NPnt );

    printf("mpirank %d localrow %d startrow %d\n",mpirank,locnrows,startrow);

//-----------------------------------------------------------------------------------//
//---- create a type describing our piece of the array (Points) -----
//-----------------------------------------------------------------------------------//

    nrows = NPnt		      ;
    int globalsizes[2] = {nrows   , 1};
    int localsizes [2] = {locnrows, 1};
    int starts[2]      = {startrow, 0};

    MPI_Datatype localarray	;
    MPI_Type_create_subarray(2, globalsizes, localsizes,starts, MPI_ORDER_C, 
                             num_as_string, &localarray);
    MPI_Type_commit(&localarray);

//-----------------------------------------------------------------------------------//
//---- open the file, and set the view -----
//-----------------------------------------------------------------------------------//

    MPI_File_open( MPI_COMM_WORLD, "./../../data/DEM_160m.xyz", 
                   MPI_MODE_RDONLY,
                   MPI_INFO_NULL, &file);


    snprintf (filepath, sizeof(filepath), "test-xxxwr_%d.xyz",  mpirank);

    MPI_File_open( MPI_COMM_SELF, filepath, 
                   MPI_MODE_CREATE | MPI_MODE_RDWR,
                   MPI_INFO_NULL, &file1 );

//-----------------------------------------------------------------------------------//
//---- Set file view -----
//-----------------------------------------------------------------------------------//

    offset = 0;

    MPI_File_set_view( file, offset,  MPI_CHAR, localarray, 
                           "native", MPI_INFO_NULL );

//-----------------------------------------------------------------------------------//
//---- Pointdata writing -----
//-----------------------------------------------------------------------------------//

    char *data_as_txt = malloc(locnrows*1*charspernum*sizeof(char));

    MPI_File_iread( file, data_as_txt, locnrows*1, num_as_string,  &request ); 
    MPI_Wait( &request, &status );

    MPI_File_iwrite( file1, data_as_txt, locnrows*1, num_as_string, &request );
    MPI_Wait( &request, &status );

//-----------------------------------------------------------------------------------//
//---- Freeup memory -----
//-----------------------------------------------------------------------------------//

    free(data_as_txt);
    MPI_Type_free(&localarray);
    MPI_File_close(&file);
    MPI_File_close(&file1);
    MPI_Type_free(&num_as_string);

    MPI_Finalize();
    return 0;
}

//====================================================================================//
//---- function to set localrow -----
//====================================================================================//

int fetchLocalRows(int mpirank, int mpisize, int multipyFactor, int pntM)
{

    int locnrows;
    int Remainder = pntM%mpisize ;
    int Quotient  = pntM/mpisize ;

    if( Remainder == 0 )
        locnrows = multipyFactor * Quotient ;
    else if( mpirank < Remainder )
        locnrows = multipyFactor * (Quotient+1);
    else
        locnrows = multipyFactor * Quotient;

    return locnrows;

}

//====================================================================================//
//---- function to set startrow -----
//====================================================================================/

int fetchStartRows(int mpirank, int mpisize, int multipyFactor, int pntM)
{

    int startrow;
    int Remainder = pntM%mpisize ;
    int Quotient  = pntM/mpisize ;

    if(Remainder == 0)
        startrow = mpirank * multipyFactor * Quotient;
    else if(mpirank < Remainder)
        startrow = mpirank * multipyFactor * (Quotient + 1)   ;
    else
        startrow = mpirank * multipyFactor * Quotient + Remainder * multipyFactor    ;

    return startrow;

}
