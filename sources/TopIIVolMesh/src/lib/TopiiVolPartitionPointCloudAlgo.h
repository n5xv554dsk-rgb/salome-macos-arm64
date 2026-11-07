/*****************************************************************************

             This file is a part of top-ii-vol meshing tools.

     -------------------------------------------------------------------

     Author(s): Mohd Afeef Badri
     Email    : mohd-afeef.badri@hotmail.com
     Date     : 2020‑04‑17

     -------------------------------------------------------------------

     top-ii-vol  provides  sequential  and  parallel tools for  creating
     volumic tetrahedral meshes from a topology defined by a point cloud.
     top-ii-vol  is  distributed in the hope that it will be useful, but
     WITHOUT  ANY  WARRANTY; or  without  even  the  implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

*******************************************************************************/

//====================================================================================//
//---- variables -----
//====================================================================================//

char pathString[256] ;
char wfilename[23]   ;

int countme  = 0     ;
int k = 0            ;

double x             ;
double y             ;
double z             ;

FILE *writeFile      ;
FILE *readFile       ;

//====================================================================================//
//---- header -----
//====================================================================================//

printf( " *============================================================*\n");
printf( "                  Partitioning point cloud                     \n");
printf( " *============================================================*\n\n");

//====================================================================================//
//---- variable to calculate time -----
//====================================================================================//

double tst = MPI_Wtime();

//====================================================================================//
//---- opening files -----
//====================================================================================//

snprintf (pathString, sizeof(pathString), "%s", inputfile->c_str());

readFile = fopen(pathString,"r");

printf( " reading point cloud from : %s \n\n",pathString);

snprintf (wfilename, sizeof(wfilename), "pc_part_%d.xyz", k);
writeFile = fopen(wfilename,"w");

printf( " writing partitioned point cloud # %d in file : %s \n",k,wfilename);

//====================================================================================//
//---- calculation for balanced or unbalanced partioning -----
//====================================================================================//

int   TNPts[mpisize];
for(int j = 0; j<mpisize; j++)
    TNPts[j]=pnty*pntx/mpisize;

for(int j = 0; j<(pnty*pntx%mpisize); j++)
    TNPts[j]=TNPts[j]+1;

//====================================================================================//
//---- loop for reading the point cloud and writing partitions -----
//====================================================================================//

for(int j = 0; j<pnty; j++)
    {
        for(int i = 0; i<pntx; i++)
            {

                fscanf(readFile,"%lf",&x) ;
                fscanf(readFile,"%lf",&y) ;
                fscanf(readFile,"%lf",&z) ;

                if(countme==TNPts[k])
                    {
                        countme=0;
                        k++;
                        fclose(writeFile);
                        snprintf (wfilename, sizeof(wfilename), "pc_part_%d.xyz", k);
                        writeFile = fopen(wfilename,"w");
                        printf( " writing partitioned point cloud # %d in file : %s \n",k,wfilename);
                    }

                fprintf(writeFile,"%lf %lf %lf\n",x,y,z) ;
                countme++;

            }
    }

printf("\n");

//====================================================================================//
//---- closing files -----
//====================================================================================//

fclose(readFile);
fclose(writeFile);

//====================================================================================//
//---- footer -----
//====================================================================================//

printf( " finished partitioning the point cloud in : %lf \n\n",  MPI_Wtime()-tst);
printf( " *============================================================*\n");
