/*****************************************************************************

             This file is a part of top-ii-vol meshing tools.

     -------------------------------------------------------------------

     Author(s): Mohd Afeef Badri
     Email    : mohd-afeef.badri@hotmail.com
     Date     : 2019‑03‑29

     -------------------------------------------------------------------

     top-ii-vol  provides  sequential  and  parallel tools for  creating
     volumic tetrahedral meshes from a topology defined by a point cloud.
     top-ii-vol  is  distributed in the hope that it will be useful, but
     WITHOUT  ANY  WARRANTY; or  without  even  the  implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

*******************************************************************************/

//-----------------------------------------------------------------------------------//
//---- Global Variables -----
//-----------------------------------------------------------------------------------//

double xx	  ;
double yy	  ;
double zz	  ;
double delz	  ;
double zznew      ;

int zglobal = pntz;
int localZmove    ;
int layerZ        ;

int IJK	          ;
int Ip1JK	  ;
int IJp1K	  ;
int IJKp1	  ;
int Ip1JKp1	  ;
int IJp1Kp1	  ;
int Ip1Jp1K	  ;
int Ip1Jp1Kp1     ;

//-----------------------------------------------------------------------------------//
//---- Setting triangle label colors -----
//-----------------------------------------------------------------------------------//

int lab_x_min = 1 ;
int lab_y_min = 2 ;
int lab_z_min = 6 ;
int lab_x_max = 4 ;
int lab_y_max = 5 ;
int lab_z_max = 3 ;

lab_y_min = 99099;
lab_y_max = 99099;
        
for(int i=0; i <NpZ; i++)
{
    for(int j=0; j <NpX; j++)
    {
        if(mpirank==i*NpX*NpY+j)
            lab_y_min = 2;
        if(mpirank==( (mpisize-1)-i*NpX*NpY  -j ))
            lab_y_max = 5;        
    }
}
 
lab_x_min = 99099;
lab_x_max = 99099;
        
for(int i=0; i <NpZ; i++)
{
    for(int j=0; j <NpY; j++)
    {
        if(mpirank==i*NpX*NpY + j*NpX )
            lab_x_min = 1;
        if(mpirank==( (mpisize-1)  -i*NpX*NpY  -j*NpX ))
            lab_x_max = 4;        
    }
}
                
lab_z_min = 99099;
lab_z_max = 99099;
        
for(int j=0; j <NpX*NpY; j++)
{
    if(mpirank==j)
        lab_z_max = 3;
    if(mpirank==( (mpisize-1)  -j))
        lab_z_min = 6;
}         
       
//-----------------------------------------------------------------------------------//
//---- Calculating Parameters -----
//-----------------------------------------------------------------------------------//

FILE* rf;
FILE* w2f ;

w2f = std::fopen((*outputfile+"_"+std::to_string(mpirank)+".mesh").c_str(), "w");

rf = std::fopen((*inputfile+"_"+std::to_string(mpirank)+".info").c_str(), "r");
    
fscanf(rf,"%d",&pnty);
fscanf(rf,"%d",&pntx);
fscanf(rf,"%d",&pntz);
fscanf(rf,"%d",&localZmove);
fscanf(rf,"%d",&layerZ);
std::fclose(rf);

rf = std::fopen((*inputfile+"_"+std::to_string(mpirank)+".xyz").c_str(), "r");

// --------------------------------------- BUG --------------------------------------//
//                                                                                   //
//if(mpirank==(mpisize-1))pnty=pnty-1; // Last mpirank does not have comman partion  //
//                                                                                   //
// --------------------------------------- BUG --------------------------------------//

//-----------------------------------------------------------------------------------//
//---- Calculating Parameters -----
//-----------------------------------------------------------------------------------//

int PxM1 = pntx-1                                       ;
int PyM1 = pnty-1                                       ;
int PzM1 = pntz-1                                       ;
int PxPz = pntx*pntz					;
int PxPy = pntx*pnty					;

int NPnt = pntx * pnty * pntz				;
int NTri = 4*( PzM1*PxM1 + PyM1*PzM1 + PxM1*PyM1 )      ;
int NTet = PxM1 * PyM1 * PzM1 * 6			;


/*
//=============================================================================
// ------------- Commandline  output ------------------
//=============================================================================



    MPI_Barrier(MPI_COMM_WORLD);

    cout << "                                                               \n"
         << "           MPI Processs # "<<mpirank <<"                       \n"
         << "                                                               \n"
         << "  # points in the .xyz ------------- "<< PxPy << "             \n"
         << "  # points in X -------------------- "<< pntx << "             \n"
         << "  # points in Y -------------------- "<< pnty << "             \n"
         << "                                                               \n"
         << " *============================================================*\n";
*/

//-----------------------------------------------------------------------------------//
//---- Header for mesh -----
//-----------------------------------------------------------------------------------//

std::fprintf(w2f, "MeshVersionFormatted 1\n\nDimension 3\n\n");              

//-----------------------------------------------------------------------------------//
//---- Generating points -----
//-----------------------------------------------------------------------------------//

t_phase = MPI_Wtime();

cout   << "Generating points ........";
std::fprintf(w2f, "Vertices\n%d\n",NPnt);       
for(int i=0; i<PxPy; i++)
    {
        fscanf(rf,"%lf",&xx);
        fscanf(rf,"%lf",&yy);
        fscanf(rf,"%lf",&zz);  
              
        std::fprintf(w2f, "%lf\t%lf\t%lf 0\n"
                        ,  xx , yy ,zz
                    );

        zznew=zz;
        delz= (zmax-zz)/(((zglobal-1)-(localZmove-1*layerZ)));          
        for(int j=0; j<PzM1; j++)
            {
                zznew  = zznew + delz;
                std::fprintf(w2f, "%lf\t%lf\t%lf 0\n"
                                ,  xx , yy ,zznew
                             );                 
            }
    }

std::fprintf(w2f, "\n");
cout   << " finished for MPI rank : " << mpirank << "\n";

t_phase = MPI_Wtime() - t_phase;
t1 +=  t_phase;
*time_log = string( *time_log+"\tPoint generation         : "
                        +std::to_string(t_phase)+" s\n"           );

//-----------------------------------------------------------------------------------//
//---- Generating Tetrahedra -----
//-----------------------------------------------------------------------------------//

t_phase = MPI_Wtime();

cout   << "Generating Tetrahedra ...."			       ;
std::fprintf(w2f, "Tetrahedra\n%d\n",NTet);       

for(int j=0; j<PyM1;  j++)
    {
        for(int i=0; i<PxM1;  i++)
            {
                for(int k=1; k<=PzM1; k++)
                    {

                        IJK	        =	i*pntz  + j*PxPz + k  ;
                        Ip1JK	    =	IJK 	+ PxPz		  ;
                        IJp1K	    =	IJK 	+ pntz		  ;
                        Ip1Jp1K     =	IJK 	+ PxPz + pntz ;
                        IJKp1       =	IJK 	+ 1			  ;
                        Ip1JKp1     =	Ip1JK 	+ 1			  ;
                        IJp1Kp1     =	IJp1K   + 1			  ;
                        Ip1Jp1Kp1   =	Ip1Jp1K + 1			  ;


                        std::fprintf(w2f, "%d\t%d\t%d\t%d 0\n"
                                          "%d\t%d\t%d\t%d 0\n"
                                          "%d\t%d\t%d\t%d 0\n"
                                          "%d\t%d\t%d\t%d 0\n"
                                          "%d\t%d\t%d\t%d 0\n"
                                          "%d\t%d\t%d\t%d 0\n"
                                        , IJK, IJKp1, IJp1K, Ip1Jp1K
                                        , IJKp1, IJK, Ip1JK, Ip1Jp1K
                                        , Ip1JKp1, IJKp1, Ip1JK, Ip1Jp1K
                                        , IJKp1, Ip1JKp1, Ip1Jp1Kp1, Ip1Jp1K
                                        , IJp1Kp1, IJKp1, Ip1Jp1Kp1, Ip1Jp1K
                                        , IJKp1, IJp1Kp1, IJp1K, Ip1Jp1K
                                     );                              
                    }
            }
    }

std::fprintf(w2f, "\n");
cout   << " finished for MPI rank : " << mpirank << "\n";


t_phase = MPI_Wtime() - t_phase;
t1 +=  t_phase;
*time_log = string( *time_log+"\tTetrahedra generation    : "
                        +std::to_string(t_phase)+" s\n"           );

//-----------------------------------------------------------------------------------//
//---- Generating Triangles -----
//-----------------------------------------------------------------------------------//

t_phase = MPI_Wtime();

cout   << "Generating Triangles ....."			       ;
std::fprintf(w2f, "Triangles\n%d\n",NTri);       

//----X-MIN-PLANE---//

for(int i=0; i<PyM1;  i++)
    {
        for(int j=0; j<PzM1;  j++)
            {

                IJK	  =	i*PxPz + j + 1	;
                IJKp1	  =	IJK + 1         ;
                Ip1JK	  =	IJK + PxPz      ;
                Ip1JKp1   =	Ip1JK + 1       ;

                std::fprintf(w2f, "%d\t%d\t%d\t%d\n"
                                  "%d\t%d\t%d\t%d\n"
                                , IJKp1, IJK, Ip1JK, lab_x_min
                                , Ip1JKp1, IJKp1, Ip1JK, lab_x_min
                            );
            }
    }


//----Y-MIN-PLANE----//

for(int i=0; i<PxM1;  i++)
    {
        for(int j=0; j<PzM1;  j++)
            {

                IJK	      =	i*pntz + j + 1	;
                IJKp1	  =	IJK + 1		    ;
                IJp1K	  =	IJK + pntz	    ;
                IJp1Kp1   =	IJp1K + 1	    ;


                std::fprintf(w2f, "%d\t%d\t%d\t%d\n"
                                  "%d\t%d\t%d\t%d\n"
                                , IJK, IJKp1, IJp1K, lab_y_min
                                , IJKp1, IJp1Kp1, IJp1K, lab_y_min
                            );
            }
    }


//----Z-MAX-PLANE----//

for(int i=0; i<PyM1;  i++)
    {
        for(int j=0; j<PxM1;  j++)
            {

                IJK	      =	i*PxPz + j*pntz +1	    ;
                Ip1JK	  =	IJK + PxPz         		;
                IJp1K	  =	IJK + pntz		    	;
                Ip1Jp1K   =	Ip1JK + pntz			;

                std::fprintf(w2f, "%d\t%d\t%d\t%d\n"
                                  "%d\t%d\t%d\t%d\n"
                                , IJK, IJp1K, Ip1Jp1K, lab_z_max
                                , Ip1JK, IJK ,Ip1Jp1K, lab_z_max
                            );
            }
    }

//----X-MAX-PLANE----//

for(int i=0; i<PyM1;  i++)
    {
        for(int j=0; j<PzM1;  j++)
            {

                IJK	      =	i*PxPz + j+1 + PxM1*(pntz)	;
                IJKp1	  =	IJK + 1					        ;
                Ip1JK	  =	IJK + PxPz			            ;
                Ip1JKp1   =	Ip1JK + 1				        ;


                std::fprintf(w2f, "%d\t%d\t%d\t%d\n"
                                  "%d\t%d\t%d\t%d\n"
                                 , IJK, IJKp1, Ip1JK, lab_x_max
                                 , IJKp1, Ip1JKp1, Ip1JK, lab_x_max
                              );
            }
    }


//----Y-MAX-PLANE----//

for(int i=0; i<PxM1;  i++)
    {
        for(int j=0; j<PzM1;  j++)
            {

                IJK	      =	i*pntz + j+1 + PxPz*PyM1	;
                IJKp1	  =	IJK + 1					    ;
                IJp1K	  =	IJK + pntz				    ;
                IJp1Kp1   =	IJp1K + 1				    ;

                std::fprintf(w2f, "%d\t%d\t%d\t%d\n"
                                  "%d\t%d\t%d\t%d\n"
                                , IJKp1,IJK,IJp1K, lab_y_max
                                , IJp1Kp1,IJKp1,IJp1K, lab_y_max
                             );
            }
    }

//----Z-MIN-PLANE----//

for(int i=0; i<PyM1;  i++)
    {
        for(int j=0; j<PxM1;  j++)
            {

                IJK	      =	i*PxPz + j*pntz + 1 + PzM1	;
                Ip1JK	  =	IJK + PxPz			        ;
                IJp1K	  =	IJK + pntz				    ;
                Ip1Jp1K   =	Ip1JK + pntz				;

                std::fprintf(w2f, "%d\t%d\t%d\t%d\n"
                                  "%d\t%d\t%d\t%d\n"
                                , IJp1K, IJK, Ip1Jp1K, lab_z_min
                                , IJK, Ip1JK, Ip1Jp1K, lab_z_min
                             );
            }
    }

cout   << " finished for MPI rank : " << mpirank << "\n";

t_phase = MPI_Wtime() - t_phase;
t1 +=  t_phase;
*time_log = string( *time_log+"\tTriangles generation     : "
                        +std::to_string(t_phase)+" s\n"           );
/**/
//-----------------------------------------------------------------------------------//
//---- Finishing footer -----
//-----------------------------------------------------------------------------------//
       
std::fprintf(w2f, "\nEnd\n");
std::fclose(w2f);      
