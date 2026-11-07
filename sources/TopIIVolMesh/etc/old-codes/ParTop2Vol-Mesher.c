/*****************************************************************************

             This file is a part of top-ii-vol meshing tools.

     -------------------------------------------------------------------

     Author(s): Mohd Afeef Badri
     Email    : mohd-afeef.badri@hotmail.com
     Date     : 2019‑10‑09

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


float **alloc2d(int, int);

int fetchLocalRows(int mpirank, int mpisize, int multipyFactor, int pntM);
int fetchStartRows(int mpirank, int mpisize, int multipyFactor, int pntM);

void initializeThreeIntegers(int *int1, int *int2, int *int3, int val1, int val2, int val3);
void fetchIstartIend(int mpirank, int mpisize, int *istart, int *iend);

int main(int argc, char *argv[])
{

//====================================================================================//
//---- Global Variables -----
//====================================================================================//

    int NPnt  ;             // # of points in the mesh
    int NTri  ;             // # of triangles on the mesh surfaces
    int NTet  ;             // # of tetrahedra in the mesh
    int label ;             // label # of the mesh surfaces


    int  IJK        ;       // variable used during tera or triangle generation
    int  Ip1JK      ;       // variable used during tera or triangle generation
    int  IJp1K      ;       // variable used during tera or triangle generation
    int  IJKp1      ;       // variable used during tera or triangle generation
    int  Ip1JKp1    ;       // variable used during tera or triangle generation
    int  IJp1Kp1    ;       // variable used during tera or triangle generation
    int  Ip1Jp1K    ;       // variable used during tera or triangle generation
    int  Ip1Jp1Kp1  ;       // variable used during tera or triangle generation
    int  dummycount ;       // variable used during tera or triangle generation


    int startrow ;          // used by MPI ranks to mark their starting row
    int locnrows ;          // used by MPI ranks to know the # of rows held
    int locNPnt  ;          // used by MPI ranks to know the # of points held
    int nrows    ;          // used by MPI ranks to know the total # of rows


    int xLocalStart ;       // used by MPI ranks to mark the x starting row
    int xLocalEnd   ;       // used by MPI ranks to mark the x ending row
    int yLocalStart ;       // used by MPI ranks to mark the y starting row
    int yLocalEnd   ;       // used by MPI ranks to mark the y ending row
    int zLocalStart ;       // used by MPI ranks to mark the z starting row
    int zLocalEnd   ;       // used by MPI ranks to mark the z ending row


    int globalsizes[2] ;    // used by MPI ranks to mark global size of array
    int localsizes [2] ;    // used by MPI ranks to mark local  size of array
    int starts[2]      ;    // used by MPI ranks to mark starting position of array


    float **data ;          // array to hold the input data from point cloud xyz


    float xx    ;           // variable hold x point value
    float yy    ;           // variable hold y point value
    float zz    ;           // variable hold z point value
    float delz  ;           // variable get delta z according to B/C (Laplacian)
    float zznew ;           // variable hold z point value


    const int charspernum = 14           ;

    char *const fmt1      = "%-13d "     ;
    char *const endfmt1   = "%-13d\n"    ;
    char *const fmt       = "%-13.6f   " ;
    char *const endfmt    = "%-13d\n"    ;
    char *const fmtint    = "%-11d "     ;
    char *const endfmtint = "%-7d\n"     ;

    FILE *infile;

    int ParallelPart = 0;

//====================================================================================//
//---- MPI variables -----
//====================================================================================//

    int ierr    ;                  // MPI Variable to capture error
    int mpirank ;                  // MPI Variable to give MPI rank
    int mpisize ;                  // MPI Variable to give MPI size

    MPI_Offset   offset        ;
    MPI_File     file          ;
    MPI_File     filein        ;
    MPI_File     fileinparted  ;
    MPI_Status   status        ;
    MPI_Datatype num_as_string ;
    MPI_Datatype num_as_string0;
    MPI_Request  request       ;

    ierr = MPI_Init(&argc, &argv)                  ;
    ierr|= MPI_Comm_size(MPI_COMM_WORLD, &mpisize) ;
    ierr|= MPI_Comm_rank(MPI_COMM_WORLD, &mpirank) ;

    MPI_Type_contiguous(charspernum, MPI_CHAR, &num_as_string) ;
    MPI_Type_commit(&num_as_string)                            ;

//====================================================================================//
//---- Commandline logo output -----
//====================================================================================//

    if(mpirank == 0)
        {
            #include "./../lib/LogoTopiiVolC.h"
        }

//====================================================================================//
//---- variable to calculate time -----
//====================================================================================//

    double t1 = MPI_Wtime();

//====================================================================================//
//---- Global Parameters -----
//====================================================================================//

    double zmax = -1920.0 ;

    int pntx = 32  ;
    int pnty = 29  ;
    int pntz = 100 ;

    char inpurfile[80] = "./../../data/DEM_160m.xyz" ;
    char outpufile[80] = "Tetra-ParTop2Vol.mesh"     ;

//====================================================================================//
//---- Comandline Parameters -----
//====================================================================================//

    for(int i=0; i<argc-1; i++)
        {

            char argvdummy = *argv[i] ;

            if (!strcmp(argv[i], "--xpoints"))
                pntx = atoi(argv[i+1]);

            if (!strcmp(argv[i], "--ypoints"))
                pnty = atoi(argv[i+1]);

            if (!strcmp(argv[i], "--zpoints"))
                pntz = atoi(argv[i+1]);

            if (!strcmp(argv[i], "--in"))
                strcpy(inpurfile, argv[i+1]);

            if (!strcmp(argv[i], "--out"))
                strcpy(outpufile, argv[i+1]);

            if (!strcmp(argv[i], "--depth"))
                zmax= atol(argv[i+1]);

        }

//====================================================================================//
//---- pntz-1  pnty-1 pntx-1 -----
//====================================================================================//

    int pntxM1    = pntx-1      ;
    int pntyM1    = pnty-1      ;
    int pntzM1    = pntz-1      ;
    int pntxXpnty = pntx * pnty ;
    int pntxXpntz = pntz * pntx ;

//====================================================================================//
//---- partition input point cloud -----
//====================================================================================//

    if(ParallelPart == 0)
            if(mpirank == 0)
                {  
                     #include "./../lib/TopiiVolPartitionPointCloudAlgo.h"
                }     

//====================================================================================//
//---- parallel  partitioning experimetal -----
//====================================================================================//

if(ParallelPart == 1)
  {

    const int charspernum0 = 41 ;
    
    MPI_Type_contiguous(charspernum0, MPI_CHAR, &num_as_string0); 
    MPI_Type_commit(&num_as_string0);

//-----------------------------------------------------------------------------------//
//---- Allocate MPI data -----
//-----------------------------------------------------------------------------------//

    locnrows = fetchLocalRows( mpirank, mpisize, 1, pntxXpnty );
    startrow = fetchStartRows( mpirank, mpisize, 1, pntxXpnty );

    nrows = pntxXpnty;

    globalsizes[0] = nrows;
    globalsizes[1] = 1;

    localsizes [0] = locnrows;
    localsizes [1] = 1;

    starts[0]  = startrow;
    starts[1]  = 0;

    MPI_Datatype localarray0	;
    MPI_Type_create_subarray(2, globalsizes, localsizes,starts, MPI_ORDER_C, 
                             num_as_string0, &localarray0);
    MPI_Type_commit(&localarray0);

//-----------------------------------------------------------------------------------//
//---- Open MPI files -----
//-----------------------------------------------------------------------------------//

    char strname[80]="";
    strcat (strname, inpurfile);

    MPI_File_open( MPI_COMM_WORLD, strname, 
                   MPI_MODE_RDONLY,
                   MPI_INFO_NULL, &filein);

    char filenamepath[256];
    snprintf (filenamepath, sizeof(filenamepath), "pc_part_%d.xyz",  mpirank);

    MPI_File_open( MPI_COMM_SELF, filenamepath, 
                   MPI_MODE_CREATE | MPI_MODE_RDWR,
                   MPI_INFO_NULL, &fileinparted );

//-----------------------------------------------------------------------------------//
//---- Set file view -----
//-----------------------------------------------------------------------------------//

    offset = 0;
    MPI_File_set_view( filein, offset,  MPI_CHAR, localarray0, 
                           "native", MPI_INFO_NULL );

//-----------------------------------------------------------------------------------//
//---- Data reading and writing -----
//-----------------------------------------------------------------------------------//

    char *data_as_txt0 = malloc(locnrows*1*charspernum0*sizeof(char));

    if(mpirank==0)
        printf("\n Reading the point cloud mesh");

    MPI_File_iread( filein, data_as_txt0, locnrows*1, num_as_string0,  &request ); 
    MPI_Wait( &request, &status );

    if(mpirank==0)
        printf(" ---- Done\n Writing partitioned point cloud mesh");

    MPI_File_iwrite( fileinparted, data_as_txt0, locnrows*1, num_as_string0, &request );
    MPI_Wait( &request, &status );

    if(mpirank==0)
        printf(" ---- Done");

//-----------------------------------------------------------------------------------//
//---- Freeup memory -----
//-----------------------------------------------------------------------------------//

    free(data_as_txt0);
    MPI_Type_free(&localarray0);
    MPI_File_close(&filein);
    MPI_File_close(&fileinparted);
    MPI_Type_free(&num_as_string0);

   }

//====================================================================================//
//---- Time taken for point cloud partitioning -----
//====================================================================================//

    if(mpirank==0)
        {
            printf( "\n\n *============================================================*\n");
            printf( "  point cloud patitioning took : %f s\n",  MPI_Wtime()-t1);
            printf( " *============================================================*\n");
        }

//====================================================================================//
//---- Name of partioned mesh cloud -----
//====================================================================================//

    char partCloudName[80] = "pc_part";

    MPI_Barrier(MPI_COMM_WORLD);

//====================================================================================//
//---- Calculating mesh attributes -----
//====================================================================================//

    NPnt = pntx * pnty * pntz                                  ;
    NTri = 4 * (pntzM1*pntxM1 + pntyM1*pntzM1 + pntxM1*pntyM1) ;
    NTet = pntxM1 * pntyM1 * pntzM1 * 6                        ;

//====================================================================================//
//---- local point calculation : balanced (if) & unbalanced (else) -----
//====================================================================================//

    if((pntxXpnty%mpisize) == 0)
        locNPnt = pntxXpnty/mpisize ;
    else if(mpirank < (pntxXpnty%mpisize))
        locNPnt = pntxXpnty/mpisize +1;
    else
        locNPnt = pntxXpnty/mpisize ;

//====================================================================================//
//---- local: rows and startrow # calculation -----
//====================================================================================//

    locnrows = fetchLocalRows( mpirank, mpisize, pntz, pntxXpnty);
    startrow = fetchStartRows(mpirank, mpisize, pntz, pntxXpnty);

//====================================================================================//
//---- Data allocation -----
//====================================================================================//

    data = alloc2d(locnrows, 3);

//====================================================================================//
//---- Gathering point data from partitioned files -----
//====================================================================================//

    if(mpirank==0)
        printf("\n Reading the partitioned point cloud mesh");

    char filepath[256];
    snprintf (filepath, sizeof(filepath), "%s_%d.xyz", partCloudName, mpirank);
    infile = fopen(filepath,"r");

    for (int i=0; i<locNPnt; i++)
        {
            for (int k=0; k<pntz; k++)
                {
                    if(k==0)
                        {
                            fscanf(infile,"%f",&data[i*pntz][0]) ;
                            fscanf(infile,"%f",&data[i*pntz][1]) ;
                            fscanf(infile,"%f",&data[i*pntz][2]) ;
                            delz= (zmax-data[i*pntz][2])/pntzM1  ;
                            zznew=data[i*pntz][2]                ;
                        }
                    else
                        {
                            data[i*pntz+k][0]=data[i*pntz][0] ;
                            data[i*pntz+k][1]=data[i*pntz][1] ;
                            zznew  = zznew + delz             ;
                            data[i*pntz+k][2]=zznew           ;
                        }
                }
        }

    fclose(infile);

    if(mpirank==0)
        printf(" ---- Done");

//====================================================================================//
//---- convert our data into txt -----
//====================================================================================//

    if(mpirank==0)
        printf("\n Point cloud data to parallel data conversion");

    char *data_as_txt = malloc(locnrows*4*charspernum*sizeof(char));
    int totcar = 4*charspernum*sizeof(char);

    label=0;

    for (int i=0; i<locnrows; i++)
        {
            for (int j=0; j<3; j++)
                {
                    sprintf(&data_as_txt[i*totcar+j*charspernum], fmt, data[i][j]);
                }
            sprintf(&data_as_txt[i*totcar+3*charspernum], endfmt, label);
        }

    if( (pntxXpnty%mpisize) == 0 )
        free(data);                      //CAUSING ERROR IN SOME MPI RANKS CHECK ?????

    if(mpirank==0)
        printf(" ---- Done\n\n");

    MPI_Barrier(MPI_COMM_WORLD);

//====================================================================================//
//---- create a type describing our piece of the array (Points) -----
//====================================================================================//

    nrows = NPnt;

    globalsizes[0] = nrows;
    globalsizes[1] = 4;

    localsizes [0] = locnrows;
    localsizes [1] = 4;

    starts[0]  = startrow;
    starts[1]  = 0;

    MPI_Datatype localarray;
    MPI_Type_create_subarray(2, globalsizes, localsizes, starts, MPI_ORDER_C, 
                             num_as_string, &localarray);
    MPI_Type_commit(&localarray);

//====================================================================================//
//---- open the file, and set the view -----
//====================================================================================//

    char str[80]="";
    strcat (str, outpufile);

    MPI_File_open(MPI_COMM_WORLD, str,
                  MPI_MODE_CREATE|MPI_MODE_WRONLY,
                  MPI_INFO_NULL, &file);

//====================================================================================//
//---- Header writing -----
//====================================================================================//

    if(mpirank==0)
        printf("\n Writing mesh points ");

    offset = 0;
    MPI_File_set_view(file, offset,  MPI_CHAR, localarray,
                      "native", MPI_INFO_NULL);
    if(mpirank==0)
        {
            char testchar[58];
            snprintf(testchar, sizeof(testchar),
                     "MeshVersionFormatted 1\n\nDimension 3\n\nVertices\n%-10d\n", NPnt);
            MPI_File_write(file, testchar, sizeof(testchar), MPI_CHAR, &status);
        }

//====================================================================================//
//---- Point data writing -----
//====================================================================================//

    offset += 57;

    MPI_File_set_view(file, offset,  MPI_CHAR, localarray,"native", MPI_INFO_NULL);
    MPI_File_write_all(file, data_as_txt, locnrows*4, num_as_string, &status);

    offset += totcar*NPnt;

    free(data_as_txt);
    MPI_Type_free(&localarray);

    MPI_Barrier(MPI_COMM_WORLD);

    if(mpirank==0)
        printf(" ---- Done\n ->  %d points written ",NPnt);

//====================================================================================//
//---- Tetdata header writing -----
//====================================================================================//

    if(mpirank==0)
        printf("\n Writing mesh volumes ");

    if(mpirank==0)
        {
            char testchar1[24];
            snprintf (testchar1, sizeof(testchar1), "\nTetrahedra\n%-10d\n", NTet);
            MPI_File_write(file, testchar1, sizeof(testchar1), MPI_CHAR, &status);
        }

    offset += 23;

//====================================================================================//
//---- local : rows, startrow #, istart #, and iend # calculations ----
//====================================================================================//

    initializeThreeIntegers(&xLocalStart, &yLocalStart, &zLocalStart, 0, 0, 0);
    initializeThreeIntegers(&xLocalEnd, &yLocalEnd, &zLocalEnd, pntxM1, pntyM1, pntzM1);

//----- get localrow and startrow for highest number ---------//
    int max     ;
    int highest ;

//Case 1: Xpoints are highest
    max     = pntxM1 ;
    highest = 1      ;

//Case 2: Ypoints are highest
    if(pntyM1 > max)
        {
            max     = pntyM1 ;
            highest = 2      ;
        }

//Case 3: Ypoints are highest
    if(pntzM1 > max)
        {
            max     = pntzM1 ;
            highest = 3      ;
        }

    switch(highest)
        {
        case 1:
            locnrows = fetchLocalRows( mpirank, mpisize, pntzM1 * pntyM1 * 6, pntxM1);
            startrow = fetchStartRows( mpirank, mpisize, pntzM1 * pntyM1 * 6, pntxM1);
            fetchIstartIend(mpirank, mpisize, &xLocalStart, &xLocalEnd);
            break;

        case 2:
            locnrows = fetchLocalRows( mpirank, mpisize, pntxM1 * pntzM1 * 6, pntyM1);
            startrow = fetchStartRows( mpirank, mpisize, pntxM1 * pntzM1 * 6, pntyM1);
            fetchIstartIend(mpirank, mpisize, &yLocalStart, &yLocalEnd);
            break;

        case 3:
            locnrows = fetchLocalRows( mpirank, mpisize, pntxM1 * pntyM1 * 6, pntzM1);
            startrow = fetchStartRows( mpirank, mpisize, pntxM1 * pntyM1 * 6, pntzM1);
            fetchIstartIend(mpirank, mpisize, &zLocalStart, &zLocalEnd);
            break;
        }

//====================================================================================//
//---- Data allocation -----
//====================================================================================//

    char *data_as_txt1 = malloc(locnrows*4*charspernum*sizeof(char));

//====================================================================================//
//---- Gathering tetrahedra data -----
//====================================================================================//

    dummycount = 0 ;
    label      = 0 ;

    for(int j=yLocalStart; j<yLocalEnd;  j++)
        {
            for(int i=xLocalStart; i<xLocalEnd;  i++)
                {
                    for(int k=zLocalStart; k<zLocalEnd;  k++)
                        {

                            IJK       =  i*pntz  + j*pntxXpntz + k +1 ;
                            Ip1JK     =  IJK     + pntxXpntz          ;
                            IJp1K     =  IJK     + pntz               ;
                            Ip1Jp1K   =  IJK     + pntxXpntz   + pntz ;
                            IJKp1     =  IJK     + 1                  ;
                            Ip1JKp1   =  Ip1JK   + 1                  ;
                            IJp1Kp1   =  IJp1K   + 1                  ;
                            Ip1Jp1Kp1 =  Ip1Jp1K + 1                  ;

                            sprintf(&data_as_txt1[dummycount*totcar+0*12], fmtint, IJK);
                            sprintf(&data_as_txt1[dummycount*totcar+1*12], fmtint, IJKp1);
                            sprintf(&data_as_txt1[dummycount*totcar+2*12], fmtint, IJp1K);
                            sprintf(&data_as_txt1[dummycount*totcar+3*12], fmtint, Ip1Jp1K);
                            sprintf(&data_as_txt1[dummycount*totcar+4*12], endfmtint, label);

                            dummycount++;

                            sprintf(&data_as_txt1[dummycount*totcar+0*12], fmtint, IJKp1);
                            sprintf(&data_as_txt1[dummycount*totcar+1*12], fmtint, IJK);
                            sprintf(&data_as_txt1[dummycount*totcar+2*12], fmtint, Ip1JK);
                            sprintf(&data_as_txt1[dummycount*totcar+3*12], fmtint, Ip1Jp1K);
                            sprintf(&data_as_txt1[dummycount*totcar+4*12], endfmtint, label);

                            dummycount++;

                            sprintf(&data_as_txt1[dummycount*totcar+0*12], fmtint, Ip1JKp1);
                            sprintf(&data_as_txt1[dummycount*totcar+1*12], fmtint, IJKp1);
                            sprintf(&data_as_txt1[dummycount*totcar+2*12], fmtint, Ip1JK);
                            sprintf(&data_as_txt1[dummycount*totcar+3*12], fmtint, Ip1Jp1K);
                            sprintf(&data_as_txt1[dummycount*totcar+4*12], endfmtint, label);

                            dummycount++;

                            sprintf(&data_as_txt1[dummycount*totcar+0*12], fmtint, IJKp1);
                            sprintf(&data_as_txt1[dummycount*totcar+1*12], fmtint, Ip1JKp1);
                            sprintf(&data_as_txt1[dummycount*totcar+2*12], fmtint, Ip1Jp1Kp1);
                            sprintf(&data_as_txt1[dummycount*totcar+3*12], fmtint, Ip1Jp1K);
                            sprintf(&data_as_txt1[dummycount*totcar+4*12], endfmtint, label);

                            dummycount++;

                            sprintf(&data_as_txt1[dummycount*totcar+0*12], fmtint, IJp1Kp1);
                            sprintf(&data_as_txt1[dummycount*totcar+1*12], fmtint, IJKp1);
                            sprintf(&data_as_txt1[dummycount*totcar+2*12], fmtint, Ip1Jp1Kp1);
                            sprintf(&data_as_txt1[dummycount*totcar+3*12], fmtint, Ip1Jp1K);
                            sprintf(&data_as_txt1[dummycount*totcar+4*12], endfmtint, label);

                            dummycount++;

                            sprintf(&data_as_txt1[dummycount*totcar+0*12], fmtint, IJKp1);
                            sprintf(&data_as_txt1[dummycount*totcar+1*12], fmtint, IJp1Kp1);
                            sprintf(&data_as_txt1[dummycount*totcar+2*12], fmtint, IJp1K);
                            sprintf(&data_as_txt1[dummycount*totcar+3*12], fmtint, Ip1Jp1K);
                            sprintf(&data_as_txt1[dummycount*totcar+4*12], endfmtint, label);

                            dummycount++;

                        }
                }
        }

//====================================================================================//
//---- create a type describing our piece of the array (Tetrahedra) -----
//====================================================================================//

    nrows = NTet;

    globalsizes[0] = nrows;
    globalsizes[1] = 4;

    localsizes [0] = locnrows;
    localsizes [1] = 4;

    starts[0]  = startrow;
    starts[1]  = 0;

    MPI_Datatype localarray1  ;
    MPI_Type_create_subarray(2, globalsizes, localsizes, starts, MPI_ORDER_C, 
                             num_as_string, &localarray1);
    MPI_Type_commit(&localarray1);

//====================================================================================//
//---- Tetdata writing -----
//====================================================================================//

    MPI_File_set_view(file, offset,  MPI_CHAR, localarray1,"native", MPI_INFO_NULL);

    MPI_File_write_all(file, data_as_txt1, locnrows*4, num_as_string, &status);

    offset += totcar*NTet;

    if(mpirank==0)
        printf(" ---- Done\n ->  %d tetrahedra written ",NTet);

    free(data_as_txt1);
    MPI_Type_free(&localarray1);

    MPI_Barrier(MPI_COMM_WORLD);

//====================================================================================//
//---- Triangle writing -----
//====================================================================================//

    if(mpirank==0)
        printf("\n Writing mesh surfaces ");

    MPI_File_set_view(file, offset,  MPI_CHAR, localarray,
                      "native", MPI_INFO_NULL);

    if(mpirank==0)
        {
            char testchar2[23];
            snprintf (testchar2, sizeof(testchar2), "\nTriangles\n%-10d\n", NTri);
            MPI_File_write(file, testchar2, sizeof(testchar2), MPI_CHAR, &status);
        }

    offset += 22;

//====================================================================================//
//---- local row calculation NTri/mpisize : balanced (if)  unbalanced (else) ----
//====================================================================================//

    int highestx, highesty, highestz;


//----------------------------------//
//  Xmin & Xmax  planes
//----------------------------------//

//Case 1: Ypoints are highest
    max      = pntyM1 ;
    highestx = 1      ;

//Case 2: Zpoints are highest
    if(pntzM1 > max)
        {
            max      = pntzM1 ;
            highestx = 2      ;
        }

    switch(highestx)
        {
        case 1:
            locnrows = fetchLocalRows( mpirank, mpisize, pntzM1 * 4, pntyM1);
            startrow = fetchStartRows( mpirank, mpisize, pntzM1 * 4, pntyM1);
            break;

        case 2:
            locnrows = fetchLocalRows( mpirank, mpisize, pntyM1 * 4, pntzM1);
            startrow = fetchStartRows( mpirank, mpisize, pntyM1 * 4, pntzM1);
            break;
        }

//----------------------------------//
//  Zmin & Zmax plane
//----------------------------------//

//Case 1: Xpoints are highest
    max      = pntxM1 ;
    highestz = 1      ;

//Case 2: Ypoints are highest
    if(pntyM1 > max)
        {
            max      = pntyM1 ;
            highestz = 2      ;
        }

    switch(highestz)
        {
        case 1:
            locnrows += fetchLocalRows( mpirank, mpisize, pntyM1 * 4, pntxM1);
            startrow += fetchStartRows( mpirank, mpisize, pntyM1 * 4, pntxM1);
            break;

        case 2:
            locnrows += fetchLocalRows( mpirank, mpisize, pntxM1 * 4, pntyM1);
            startrow += fetchStartRows( mpirank, mpisize, pntxM1 * 4, pntyM1);
            break;
        }

//----------------------------------//
//  Ymin & Ymax plane
//----------------------------------//

//Case 1: Xpoints are highest
    max      = pntxM1 ;
    highesty = 1      ;

//Case 2: Zpoints are highest
    if(pntzM1 > max)
        {
            max      = pntzM1 ;
            highesty = 2      ;
        }

//highesty = 2;

    switch(highesty)
        {
        case 1:
            locnrows += fetchLocalRows( mpirank, mpisize, pntzM1 * 4, pntxM1);
            startrow += fetchStartRows( mpirank, mpisize, pntzM1 * 4, pntxM1);
            break;

        case 2:
            locnrows += fetchLocalRows( mpirank, mpisize, pntxM1 * 4, pntzM1);
            startrow += fetchStartRows( mpirank, mpisize, pntxM1 * 4, pntzM1);
            break;
        }

//====================================================================================//
//---- Data allocation -----
//====================================================================================//

    char *data_as_txt2 = malloc(locnrows*4*charspernum*sizeof(char));

//====================================================================================//
//---- generating triangles for X planes -----
//====================================================================================//

    initializeThreeIntegers(&xLocalStart, &yLocalStart, &zLocalStart, 0, 0, 0);
    initializeThreeIntegers(&xLocalEnd, &yLocalEnd, &zLocalEnd, pntxM1, pntyM1, pntzM1);

    switch(highestx)
        {
        case 1:
            fetchIstartIend(mpirank, mpisize, &yLocalStart, &yLocalEnd);
            break;

        case 2:
            fetchIstartIend(mpirank, mpisize, &zLocalStart, &zLocalEnd);
            break;
        }


    dummycount=0;

//----X-MIN-PLANE---//
    label=11;

    for(int i=yLocalStart; i<yLocalEnd;  i++)
        {
            for(int j=zLocalStart; j<zLocalEnd;  j++)
                {

                    IJK        =  i*pntxXpntz + j+1 ;
                    IJKp1      =  IJK + 1           ;
                    Ip1JK      =  IJK + pntxXpntz   ;
                    Ip1JKp1    =  Ip1JK + 1         ;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, IJKp1);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, IJK);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, Ip1JK);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, Ip1JKp1);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, IJKp1);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, Ip1JK);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;
                }
        }

//----X-MAX-PLANE----//
    label=33;

    for(int i=yLocalStart; i<yLocalEnd;  i++)
        {
            for(int j=zLocalStart; j<zLocalEnd;  j++)
                {

                    IJK        =  i*pntxXpntz + j+1 + pntxM1*pntz  ;
                    IJKp1    =  IJK + 1          ;
                    Ip1JK    =  IJK + pntxXpntz     ;
                    Ip1JKp1   =  Ip1JK + 1        ;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, IJK);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, IJKp1);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, Ip1JK);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, IJKp1);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, Ip1JKp1);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, Ip1JK);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;

                }
        }

//====================================================================================//
//---- generating triangles for Z planes -----
//====================================================================================//

    initializeThreeIntegers(&xLocalStart, &yLocalStart, &zLocalStart, 0, 0, 0);
    initializeThreeIntegers(&xLocalEnd, &yLocalEnd, &zLocalEnd, pntxM1, pntyM1, pntzM1);

    switch(highestz)
        {
        case 1:
            fetchIstartIend(mpirank, mpisize, &xLocalStart, &xLocalEnd);
            break;

        case 2:
            fetchIstartIend(mpirank, mpisize, &yLocalStart, &yLocalEnd);
            break;
        }

//----Z-MIN-PLANE----//
    label = 22;

    for(int i=yLocalStart; i<yLocalEnd;  i++)
        {
            for(int j=xLocalStart; j<xLocalEnd;  j++)
                {

                    IJK     =  i*pntxXpntz + j*pntz + 1 ;
                    Ip1JK   =  IJK + pntxXpntz          ;
                    IJp1K   =  IJK + pntz               ;
                    Ip1Jp1K =  Ip1JK + pntz             ;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, IJK);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, IJp1K);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, Ip1Jp1K);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, Ip1JK);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, IJK);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, Ip1Jp1K);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;
                }
        }


//----Z-MAX-PLANE----//
    label=44;

    for(int i=yLocalStart; i<yLocalEnd;  i++)
        {
            for(int j=xLocalStart; j<xLocalEnd;  j++)
                {

                    IJK        =  i*pntxXpntz + j*pntz + 1 + pntzM1  ;
                    Ip1JK      =  IJK + pntxXpntz     ;
                    IJp1K      =  IJK + pntz          ;
                    Ip1Jp1K    =  Ip1JK + pntz        ;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, IJp1K);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, IJK);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, Ip1Jp1K);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, IJK);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, Ip1JK);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, Ip1Jp1K);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;
                }
        }

//====================================================================================//
//---- generating triangles for Y planes -----
//====================================================================================//

    initializeThreeIntegers(&xLocalStart, &yLocalStart, &zLocalStart, 0, 0, 0);
    initializeThreeIntegers(&xLocalEnd, &yLocalEnd, &zLocalEnd, pntxM1, pntyM1, pntzM1);

    switch(highesty)
        {
        case 1:
            fetchIstartIend(mpirank, mpisize, &xLocalStart, &xLocalEnd);
            break;

        case 2:
            fetchIstartIend(mpirank, mpisize, &zLocalStart, &zLocalEnd);
            break;
        }

//----Y-MAX-PLANE----//
    label=55;

    for(int i=xLocalStart; i<xLocalEnd;  i++)
        {
            for(int j=zLocalStart; j<zLocalEnd;  j++)
                {

                    IJK        =  i*pntz + j+1 + (pntxXpntz*pntyM1)  ;
                    IJKp1      =  IJK + 1          ;
                    IJp1K      =  IJK + pntz      ;
                    IJp1Kp1    =  IJp1K + 1        ;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, IJKp1);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, IJK);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, IJp1K);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, IJp1Kp1);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, IJKp1);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, IJp1K);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;

                }
        }

//----Y-MIN-PLANE----//
    label=66;

    for(int i=xLocalStart; i<xLocalEnd;  i++)
        {
            for(int j=zLocalStart; j<zLocalEnd;  j++)
                {

                    IJK        =  i*pntz + j+1;
                    IJKp1    =  IJK + 1    ;
                    IJp1K    =  IJK + pntz  ;
                    IJp1Kp1   =  IJp1K + 1  ;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, IJK);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, IJKp1);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, IJp1K);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;

                    sprintf(&data_as_txt2[dummycount*totcar+0*charspernum], fmt1, IJKp1);
                    sprintf(&data_as_txt2[dummycount*totcar+1*charspernum], fmt1, IJp1Kp1);
                    sprintf(&data_as_txt2[dummycount*totcar+2*charspernum], fmt1, IJp1K);
                    sprintf(&data_as_txt2[dummycount*totcar+3*charspernum], endfmt1, label);

                    dummycount++;

                }
        }

//====================================================================================//
//---- create a type describing our piece of the array (Triangle) -----
//====================================================================================//

    nrows = NTri;

    globalsizes[0] = nrows;
    globalsizes[1] = 4;

    localsizes [0] = locnrows;
    localsizes [1] = 4;

    starts[0]  = startrow;
    starts[1]  = 0;

    MPI_Datatype localarray2  ;
    MPI_Type_create_subarray(2, globalsizes, localsizes, starts, MPI_ORDER_C, 
                             num_as_string, &localarray2);
    MPI_Type_commit(&localarray2);


//====================================================================================//
//---- Triangle writing -----
//====================================================================================//

    MPI_File_set_view(file, offset,  MPI_CHAR, localarray2,"native", MPI_INFO_NULL);

    MPI_File_write_all(file, data_as_txt2, locnrows*4, num_as_string, &status);

    offset += totcar*NTet;

    free(data_as_txt2);
    MPI_Type_free(&localarray2);

    if(mpirank==0)
        printf(" ---- Done\n ->  %d triangles written ",NTri);

    MPI_Barrier(MPI_COMM_WORLD);

//====================================================================================//
//---- Footer writing -----
//====================================================================================//

    MPI_File_set_view(file, offset,  MPI_CHAR, localarray,"native", MPI_INFO_NULL);

    if(mpirank==0)
        {
            char testchar3[5];
            snprintf (testchar3, sizeof(testchar3), "\nEnd");
            MPI_File_write(file, testchar3, sizeof(testchar3)-1, MPI_CHAR, &status);
        }

//====================================================================================//
//---- Free memory -----
//====================================================================================//

    if(mpirank==0)
        {
            printf( "\n\n *============================================================*\n");
            printf( "  The program finshed in : %f s\n",  MPI_Wtime()-t1);
            printf( " *============================================================*\n");
        }
    fflush(stdout);

    MPI_File_close(&file);
    MPI_Type_free(&num_as_string);

    MPI_Finalize();

    return 0;

}
//----------------------------- END OF PROGRAM ---------------------------------------//




//====================================================================================//
//---- function to allocate array -----
//====================================================================================//


float **alloc2d(int n, int m)
{

    float *data   = malloc(n*m*sizeof(float));
    float **array = malloc(n*sizeof(float *));

    for (int i=0; i<n; i++)
        array[i] = &(data[i*m]);

    return array;

}

//====================================================================================//
//---- function to set istart and iend -----
//====================================================================================//

void fetchIstartIend(int mpirank, int mpisize, int *istart, int *iend)
{

    int pntM1=*iend;

    if( (pntM1%mpisize) == 0 )                   // balanced (if)
        {
            *istart = mpirank * pntM1/mpisize ;
            *iend   = *istart + pntM1/mpisize ;
        }
    else                                        // un balanced (else)
        {
            if( mpirank < (pntM1%mpisize) )
                {
                    *istart = mpirank * (pntM1/mpisize + 1) ;
                    *iend   = *istart + (pntM1/mpisize + 1) ;
                }
            else
                {
                    *istart = mpirank * (pntM1/mpisize) +  (pntM1%mpisize) ;
                    *iend   = *istart + (pntM1/mpisize) ;
                }
        }
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

//====================================================================================//
//---- function to set initialize three ints -----
//====================================================================================/

void initializeThreeIntegers(int *int1, int *int2, int *int3, int val1, int val2, int val3)
{

    *int1=val1;
    *int2=val2;
    *int3=val3;

}
