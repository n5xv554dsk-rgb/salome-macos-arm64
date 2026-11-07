/*****************************************************************************

             This file is a part of top-ii-vol meshing tools.

     -------------------------------------------------------------------

     Author(s): Mohd Afeef Badri
     Email    : mohd-afeef.badri@hotmail.com
     Date     : 2019‑12‑09

     -------------------------------------------------------------------

     top-ii-vol  provides  sequential  and  parallel tools for  creating
     volumic tetrahedral meshes from a topology defined by a point cloud.
     top-ii-vol  is  distributed in the hope that it will be useful, but
     WITHOUT  ANY  WARRANTY; or  without  even  the  implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

*******************************************************************************/


#include <iostream>
#include <fstream>
#include <iomanip>

#ifdef MEDCOUPLING
#include "MEDLoader.hxx"
#include "MEDFileData.hxx"

/*
#include "MEDLoaderBase.hxx"
#include "MEDCouplingUMesh.hxx"
#include "MEDCouplingFieldDouble.hxx"
#include "MEDCouplingFieldFloat.hxx"
#include "MEDCouplingMemArray.hxx"
*/

using namespace MEDCoupling;
#endif               

using namespace std;


int main(int argc, char *argv[])
{

//-----------------------------------------------------------------------------------//
//---- Logo -----
//-----------------------------------------------------------------------------------//

    #include "./../lib/LogoTopiiVolCpp.hpp"

//-----------------------------------------------------------------------------------//
//---- Global Variables -----
//-----------------------------------------------------------------------------------//

    double xx	  ;
    double yy	  ;
    double zz	  ;
    double zmax   ;
    double delz	  ;
    double zznew  ;

    int pntx      ;
    int pnty      ;
    int	pntz      ;

    int IJK	  ;
    int Ip1JK	  ;
    int IJp1K	  ;
    int IJKp1	  ;
    int Ip1JKp1	  ;
    int IJp1Kp1	  ;
    int Ip1Jp1K	  ;
    int Ip1Jp1Kp1 ;

    string * inputfile  = new string();
    string * outputfile = new string();

//-----------------------------------------------------------------------------------//
//---- Input Parameters -----
//-----------------------------------------------------------------------------------//

    pntx = 11;
    pnty = 10;
    pntz = 10;

    zmax = -1920.0;

    *inputfile  = "out-coarse.xyz";
    *outputfile = "test.mesh";

    string meshtype  = "mesh";

//-----------------------------------------------------------------------------------//
//---- Commandline Parameters -----
//-----------------------------------------------------------------------------------//

    for(int i=0; i<argc-1; i++)
        {

            string argvdummy  = argv[i];
            string argvdummy1 = argv[i+1];

            if( argvdummy == "--xpoints")
                pntx= stoi(argvdummy1);

            if( argvdummy == "--ypoints")
                pnty= stoi(argvdummy1);

            if( argvdummy == "--zpoints")
                pntz= stoi(argvdummy1);

            if( argvdummy == "--in")
                *inputfile = argvdummy1;

            if( argvdummy == "--out")
                *outputfile = argvdummy1;

            if( argvdummy == "--mesh")
                meshtype = argvdummy1;

            if( argvdummy == "--depth")
                zmax= stod(argvdummy1);
        }

//-----------------------------------------------------------------------------------//
//---- I/O Files -----
//---------------------------------
// w2f  : write to file
// rf   : read from file
//-----------------------------------------------------------------------------------//

    FILE* rf;
    rf = std::fopen((*inputfile).c_str(), "r");    
    
    FILE* w2f = std::fopen((*outputfile).c_str(), "w");

//-----------------------------------------------------------------------------------//
//---- Message on commandline -----
//-----------------------------------------------------------------------------------//

    cout << " *===================================================*\n"
         << " *                  User input                       *\n"
         << " *===================================================*\n\n"
         << "   # X points  :: " << pntx        << "\n"
         << "   # Y points  :: " << pnty        << "\n"
         << "   # Z points  :: " << pntz        << "\n"
         << "   Z depth     :: " << zmax        << "\n"
         << "   Input file  :: " << *inputfile  << "\n"
         << "   Output file :: " << *outputfile << "\n\n"
         << " *===================================================*\n"
         << " *                  Work in progress                 *\n"
         << " *===================================================*\n\n";

//-----------------------------------------------------------------------------------//
//---- For timing the program -----
//-----------------------------------------------------------------------------------//

    clock_t get_time = clock();

//-----------------------------------------------------------------------------------//
//---- Calculating Parameters -----
//-----------------------------------------------------------------------------------//

    int PxM1 = pntx - 1;
    int PyM1 = pnty - 1;
    int PzM1 = pntz - 1;
    int Pxz  = pntx*pntz;
    int NPnt = pntx * pnty * pntz;
    int NTri = 4*(PzM1*PxM1 + PyM1*PzM1 + PxM1*PyM1);
    int NTet = PxM1 * PyM1 * PzM1 * 6;

//-----------------------------------------------------------------------------------//
//---- Debug Parameters -----
//-----------------------------------------------------------------------------------//

    int filePoints = 0;

//-----------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------//
//---- Writing mesh in Medit's .mesh format -----
//-----------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------//

    if(meshtype == "mesh")
        {
            cout << "   Meshing the topology in Medit's *.mesh format"	<< "\n";

//-----------------------------------------------------------------------------------//
//---- Header for mesh -----
//-----------------------------------------------------------------------------------//

            std::fprintf(w2f, "MeshVersionFormatted 1\n\nDimension 3\n\n");

//-----------------------------------------------------------------------------------//
//---- Generating points -----
//-----------------------------------------------------------------------------------//

            cout   << "   Generating points....";
            std::fprintf(w2f, "Vertices\n%d\n",NPnt);

            for(int i=0; i<pntx*pnty; i++)
                {

                    filePoints += fscanf(rf,"%lf",&xx);
                    filePoints += fscanf(rf,"%lf",&yy);
                    filePoints += fscanf(rf,"%lf",&zz);

                    std::fprintf(w2f, "%lf %lf %lf 0\n"
                                    , xx,yy,zz
                                );

                    zznew=zz;
                    delz= (zmax-zz)/PzM1;
                    for(int j=0; j<PzM1; j++)
                        {
                            zznew  = zznew + delz;
                            std::fprintf(w2f, "%lf %lf %lf 0\n"
                                            ,  xx,yy,zznew
                                        );
                        }
                }

            if(filePoints != pntx*pnty*3 )
            	{
            		cout<<"ERROR! Something is not right \n" 
            		    << filePoints*3 << " Vertices read \n"
            		    << pntx*pnty    << " Vertices expected \n";

            		exit(111);
            	}
            filePoints = 0;

            std::fclose(rf);
            std::fprintf(w2f, "\n");
            cout   << "   Done\n   #  " << NPnt << " points written\n";

//-----------------------------------------------------------------------------------//
//---- Generating Tetrahedra -----
// 6 Tetrahedra are written together for one Hex
//-----------------------------------------------------------------------------------//


            cout   << "   Generating Tetrahedra....";
            std::fprintf(w2f, "Tetrahedra\n%d\n",NTet);
            for(int j=0; j<PyM1;  j++)
                {
                    for(int i=0; i<PxM1;  i++)
                        {
                            for(int k=1; k<=PzM1; k++)
                                {

                                    IJK	      =	i*pntz  + j*Pxz + k	;
                                    Ip1JK     =	IJK 	+ Pxz		;
                                    IJp1K     =	IJK 	+ pntz		;
                                    Ip1Jp1K   =	IJK 	+ Pxz + pntz	;
                                    IJKp1     =	IJK 	+ 1		;
                                    Ip1JKp1   =	Ip1JK 	+ 1		;
                                    IJp1Kp1   =	IJp1K   + 1		;
                                    Ip1Jp1Kp1 =	Ip1Jp1K + 1		;
                                    
                                   std::fprintf(w2f, "%d %d %d %d 0\n"
                                                     "%d %d %d %d 0\n"
                                                     "%d %d %d %d 0\n"
                                                     "%d %d %d %d 0\n"
                                                     "%d %d %d %d 0\n"
                                                     "%d %d %d %d 0\n"
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
            cout   << "   Done\n   #  " << NTet << " tetrahedra written\n";

//-----------------------------------------------------------------------------------//
//---- Generating Triangles -----
// 2 Triangles a are written together for one Quadrangle
//-----------------------------------------------------------------------------------//

            cout   << "   Generating Triangles...."			       ;
            std::fprintf(w2f, "Triangles\n%d\n",NTri);
//---------------------------- X-MIN-PLANE -------------------------------//
            for(int i=0; i<PyM1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    =	i*Pxz + j + 1	;
                            IJKp1   =	IJK + 1		;
                            Ip1JK   =	IJK + Pxz	;
                            Ip1JKp1 =	Ip1JK + 1	;
                            
                            std::fprintf(w2f, "%d %d %d 1\n"
                                             "%d %d %d 1\n"
                                            , IJKp1, IJK, Ip1JK
                                            , Ip1JKp1, IJKp1, Ip1JK
                                        );
                        }
                }

//---------------------------- Y-MIN-PLANE -------------------------------//
            for(int i=0; i<PxM1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    =	i*pntz + j + 1	;
                            IJKp1   =	IJK + 1		;
                            IJp1K   =	IJK + pntz	;
                            IJp1Kp1 =	IJp1K + 1	;

                            std::fprintf(w2f, "%d %d %d 2\n"
                                              "%d %d %d 2\n"
                                            , IJK, IJKp1, IJp1K
                                            , IJKp1, IJp1Kp1, IJp1K
                                        );
                        }
                }

//---------------------------- Z-MIN-PLANE -------------------------------//
            for(int i=0; i<PyM1;  i++)
                {
                    for(int j=0; j<PxM1;  j++)
                        {

                            IJK	    =	i*Pxz + j*pntz + 1	;
                            Ip1JK   =	IJK + Pxz		;
                            IJp1K   =	IJK + pntz		;
                            Ip1Jp1K =	Ip1JK + pntz		;

                            std::fprintf(w2f, "%d %d %d 3\n"
                                              "%d %d %d 3\n"
                                            , IJK, IJp1K, Ip1Jp1K
                                            , Ip1JK, IJK ,Ip1Jp1K
                                        );
                        }
                }

//---------------------------- X-MAX-PLANE ----------------------------//
            for(int i=0; i<PyM1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    =	i*Pxz + j + 1 + PxM1*pntz	;
                            IJKp1   =	IJK + 1				;
                            Ip1JK   =	IJK + Pxz			;
                            Ip1JKp1 =	Ip1JK + 1			;

                            std::fprintf(w2f, "%d %d %d 4\n"
                                              "%d %d %d 4\n"
                                            , IJK, IJKp1, Ip1JK
                                            , IJKp1, Ip1JKp1, Ip1JK
                                        );
                        }
                }

//---------------------------- Y-MAX-PLANE ----------------------------//
            for(int i=0; i<PxM1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    =	i*pntz + j + 1 + Pxz*PyM1		;
                            IJKp1   =	IJK + 1					;
                            IJp1K   =	IJK + pntz				;
                            IJp1Kp1 =	IJp1K + 1				;

                            std::fprintf(w2f, "%d %d %d 5\n"
                                              "%d %d %d 5\n"
                                            , IJKp1,IJK,IJp1K
                                            , IJp1Kp1,IJKp1,IJp1K
                                        );
                        }
                }

//---------------------------- Z-MAX-PLANE ----------------------------//
            for(int i=0; i<PyM1;  i++)
                {
                    for(int j=0; j<PxM1;  j++)
                        {

                            IJK	    =	i*Pxz + j*pntz + 1 + PzM1	;
                            Ip1JK   =	IJK + Pxz			;
                            IJp1K   =	IJK + pntz			;
                            Ip1Jp1K =	Ip1JK + pntz			;

                            std::fprintf(w2f, "%d %d %d 6\n"
                                              "%d %d %d 6\n"
                                            , IJp1K, IJK, Ip1Jp1K
                                            , IJK, Ip1JK, Ip1Jp1K
                                        );
                        }
                }

            cout << "   Done\n   #  "<<NTri<<" triangles written\n";

//-----------------------------------------------------------------------------------//
//---- Finishing footer -----
//-----------------------------------------------------------------------------------//
          std::fprintf(w2f, "\nEnd\n");
        }

//-----------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------//
//---- Writing mesh in Gmsh's .msh format 4.1 / 2.2 -----
//-----------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------//

        else if (meshtype == "msh4")
        {
            cout << "   Meshing the topology in Gmsh's *.msh 4.1 format\n";

//--------------------------------------//
//---- Header for msh4.1 -----
//--------------------------------------//

            std::fprintf(w2f, "$MeshFormat\n4.1 0 8\n$EndMeshFormat\n");

            // Physical Names section
            std::fprintf(w2f, "$PhysicalNames\n");
            std::fprintf(w2f, "7\n");              // number of physical groups
            std::fprintf(w2f, "2 1 \"left\"\n");   // X-min surface (physical tag 1)
            std::fprintf(w2f, "2 2 \"front\"\n");  // Y-min surface (physical tag 2)
            std::fprintf(w2f, "2 3 \"bottom\"\n"); // Z-min surface (physical tag 3)
            std::fprintf(w2f, "2 4 \"right\"\n");  // X-max surface (physical tag 4)
            std::fprintf(w2f, "2 5 \"back\"\n");   // Y-max surface (physical tag 5)
            std::fprintf(w2f, "2 6 \"top\"\n");    // Z-max surface (physical tag 6)
            std::fprintf(w2f, "3 7 \"volume\"\n"); // Volume (physical tag 7)
            std::fprintf(w2f, "$EndPhysicalNames\n");

            // Entities section (required in MSH 4.1)
            std::fprintf(w2f, "$Entities\n");
            // Format: numPointEntities numCurveEntities numSurfaceEntities numVolumeEntities
            std::fprintf(w2f, "0 0 6 1\n");

            // Define 6 surfaces (boundary faces)
            // Format: surfaceTag minX minY minZ maxX maxY maxZ numBoundingCurves
            std::fprintf(w2f, "1 -1e99 -1e99 -1e99 1e99 1e99 1e99 1 1 0\n"); // X-min surface
            std::fprintf(w2f, "2 -1e99 -1e99 -1e99 1e99 1e99 1e99 1 2 0\n"); // Y-min surface
            std::fprintf(w2f, "3 -1e99 -1e99 -1e99 1e99 1e99 1e99 1 3 0\n"); // Z-min surface
            std::fprintf(w2f, "4 -1e99 -1e99 -1e99 1e99 1e99 1e99 1 4 0\n"); // X-max surface
            std::fprintf(w2f, "5 -1e99 -1e99 -1e99 1e99 1e99 1e99 1 5 0\n"); // Y-max surface
            std::fprintf(w2f, "6 -1e99 -1e99 -1e99 1e99 1e99 1e99 1 6 0\n"); // Z-max surface

            // Define 1 volume
            // Format: volumeTag minX minY minZ maxX maxY maxZ numBoundingSurfaces surfaceTag1 surfaceTag2 ...
            std::fprintf(w2f, "1 -1e99 -1e99 -1e99 1e99 1e99 1e99 1 7 0\n");

            std::fprintf(w2f, "$EndEntities\n");

            // Nodes section
            std::fprintf(w2f, "$Nodes\n");
            std::fprintf(w2f, "1 %d 1 %d\n", NPnt, NPnt); // numEntityBlocks numNodes minNodeTag maxNodeTag
            std::fprintf(w2f, "3 1 0 %d\n", NPnt);        // entityDim entityTag parametric numNodesInBlock

            // Node tags
            for (int i = 1; i <= NPnt; i++)
            {
                std::fprintf(w2f, "%d\n", i);
            }

            int counter1 = 1;

            cout << "   Generating points....";

            for (int i = 0; i < pntx * pnty; i++)
            {
                filePoints += fscanf(rf, "%lf", &xx);
                filePoints += fscanf(rf, "%lf", &yy);
                filePoints += fscanf(rf, "%lf", &zz);

                std::fprintf(w2f, "%lf %lf %lf\n", xx, yy, zz);

                counter1++;
                zznew = zz;
                delz = (zmax - zz) / PzM1;
                for (int j = 0; j < PzM1; j++)
                {
                    zznew = zznew + delz;
                    std::fprintf(w2f, "%lf %lf %lf\n", xx, yy, zznew);
                    counter1++;
                }
            }

            if (filePoints != pntx * pnty * 3)
            {
                cout << "ERROR! Something is not right \n"
                     << filePoints * 3 << " Vertices read \n"
                     << pntx * pnty << " Vertices expected \n";
                exit(111);
            }
            filePoints = 0;

            std::fclose(rf);
            std::fprintf(w2f, "$EndNodes\n");
            cout << "   Done\n";

//-----------------------------------------------------------------------------------//
//---- Generating Elements (Triangles and Tetrahedra) -----
//-----------------------------------------------------------------------------------//

            cout << "   Generating Elements....";
            std::fprintf(w2f, "$Elements\n");

            // Calculate number of element blocks (6 surface blocks + 1 volume block)
            int numElementBlocks = 7;
            std::fprintf(w2f, "%d %d 1 %d\n", numElementBlocks, NTet + NTri, NTet + NTri);

            counter1 = 1;

            //---------------------------------X-MIN-PLANE (Surface 1 - "left")----------------------------------//
            int numTriXMin = 2 * PyM1 * PzM1;
            std::fprintf(w2f, "2 1 2 %d\n", numTriXMin); // entityDim entityTag elementType numElementsInBlock

            for (int i = 0; i < PyM1; i++)
            {
                for (int j = 0; j < PzM1; j++)
                {
                    IJK = i * Pxz + j + 1;
                    IJKp1 = IJK + 1;
                    Ip1JK = IJK + Pxz;
                    Ip1JKp1 = Ip1JK + 1;

                    std::fprintf(w2f, "%d %d %d %d\n", counter1, IJKp1, IJK, Ip1JK);
                    std::fprintf(w2f, "%d %d %d %d\n", counter1 + 1, Ip1JKp1, IJKp1, Ip1JK);
                    counter1 += 2;
                }
            }

            //---------------------------------Y-MIN-PLANE (Surface 2 - "front")----------------------------------//
            int numTriYMin = 2 * PxM1 * PzM1;
            std::fprintf(w2f, "2 2 2 %d\n", numTriYMin);

            for (int i = 0; i < PxM1; i++)
            {
                for (int j = 0; j < PzM1; j++)
                {
                    IJK = i * pntz + j + 1;
                    IJKp1 = IJK + 1;
                    IJp1K = IJK + pntz;
                    IJp1Kp1 = IJp1K + 1;

                    std::fprintf(w2f, "%d %d %d %d\n", counter1, IJK, IJKp1, IJp1K);
                    std::fprintf(w2f, "%d %d %d %d\n", counter1 + 1, IJKp1, IJp1Kp1, IJp1K);
                    counter1 += 2;
                }
            }

            //---------------------------------Z-MIN-PLANE (Surface 3 - "bottom")----------------------------------//
            int numTriZMin = 2 * PyM1 * PxM1;
            std::fprintf(w2f, "2 3 2 %d\n", numTriZMin);

            for (int i = 0; i < PyM1; i++)
            {
                for (int j = 0; j < PxM1; j++)
                {
                    IJK = i * Pxz + j * pntz + 1;
                    Ip1JK = IJK + Pxz;
                    IJp1K = IJK + pntz;
                    Ip1Jp1K = Ip1JK + pntz;

                    std::fprintf(w2f, "%d %d %d %d\n", counter1, IJK, IJp1K, Ip1Jp1K);
                    std::fprintf(w2f, "%d %d %d %d\n", counter1 + 1, Ip1JK, IJK, Ip1Jp1K);
                    counter1 += 2;
                }
            }

            //---------------------------------X-MAX-PLANE (Surface 4 - "right")----------------------------------//
            int numTriXMax = 2 * (pnty - 1) * PzM1;
            std::fprintf(w2f, "2 4 2 %d\n", numTriXMax);

            for (int i = 0; i < pnty - 1; i++)
            {
                for (int j = 0; j < PzM1; j++)
                {
                    IJK = i * Pxz + j + 1 + PxM1 * pntz;
                    IJKp1 = IJK + 1;
                    Ip1JK = IJK + Pxz;
                    Ip1JKp1 = Ip1JK + 1;

                    std::fprintf(w2f, "%d %d %d %d\n", counter1, IJK, IJKp1, Ip1JK);
                    std::fprintf(w2f, "%d %d %d %d\n", counter1 + 1, IJKp1, Ip1JKp1, Ip1JK);
                    counter1 += 2;
                }
            }

            //---------------------------------Y-MAX-PLANE (Surface 5 - "back")----------------------------------//
            int numTriYMax = 2 * PxM1 * PzM1;
            std::fprintf(w2f, "2 5 2 %d\n", numTriYMax);

            for (int i = 0; i < PxM1; i++)
            {
                for (int j = 0; j < PzM1; j++)
                {
                    IJK = i * pntz + j + 1 + Pxz * PyM1;
                    IJKp1 = IJK + 1;
                    IJp1K = IJK + pntz;
                    IJp1Kp1 = IJp1K + 1;

                    std::fprintf(w2f, "%d %d %d %d\n", counter1, IJKp1, IJK, IJp1K);
                    std::fprintf(w2f, "%d %d %d %d\n", counter1 + 1, IJp1Kp1, IJKp1, IJp1K);
                    counter1 += 2;
                }
            }

            //---------------------------------Z-MAX-PLANE (Surface 6 - "top")----------------------------------//
            int numTriZMax = 2 * PyM1 * PxM1;
            std::fprintf(w2f, "2 6 2 %d\n", numTriZMax);

            for (int i = 0; i < PyM1; i++)
            {
                for (int j = 0; j < PxM1; j++)
                {
                    IJK = i * Pxz + j * pntz + 1 + PzM1;
                    Ip1JK = IJK + Pxz;
                    IJp1K = IJK + pntz;
                    Ip1Jp1K = Ip1JK + pntz;

                    std::fprintf(w2f, "%d %d %d %d\n", counter1, IJp1K, IJK, Ip1Jp1K);
                    std::fprintf(w2f, "%d %d %d %d\n", counter1 + 1, IJK, Ip1JK, Ip1Jp1K);
                    counter1 += 2;
                }
            }

//-----------------------------------------------------------------------------------//
//---- Generating Tetrahedra (Volume 1 - "volume") -----
//-----------------------------------------------------------------------------------//

            cout << "Done  \n"
                 << "   Generating Tetrahedrals....";

            // Volume elements
            std::fprintf(w2f, "3 1 4 %d\n", NTet); // entityDim entityTag elementType(4=tetrahedra) numElementsInBlock

            for (int j = 0; j < PyM1; j++)
            {
                for (int i = 0; i < PxM1; i++)
                {
                    for (int k = 1; k <= PzM1; k++)
                    {
                        IJK = i * pntz + j * Pxz + k;
                        Ip1JK = IJK + Pxz;
                        IJp1K = IJK + pntz;
                        Ip1Jp1K = IJK + Pxz + pntz;
                        IJKp1 = IJK + 1;
                        Ip1JKp1 = Ip1JK + 1;
                        IJp1Kp1 = IJp1K + 1;
                        Ip1Jp1Kp1 = Ip1Jp1K + 1;

                        std::fprintf(w2f, "%d %d %d %d %d\n", counter1, IJK, IJKp1, IJp1K, Ip1Jp1K);
                        std::fprintf(w2f, "%d %d %d %d %d\n", counter1 + 1, IJKp1, IJK, Ip1JK, Ip1Jp1K);
                        std::fprintf(w2f, "%d %d %d %d %d\n", counter1 + 2, Ip1JKp1, IJKp1, Ip1JK, Ip1Jp1K);
                        std::fprintf(w2f, "%d %d %d %d %d\n", counter1 + 3, IJKp1, Ip1JKp1, Ip1Jp1Kp1, Ip1Jp1K);
                        std::fprintf(w2f, "%d %d %d %d %d\n", counter1 + 4, IJp1Kp1, IJKp1, Ip1Jp1Kp1, Ip1Jp1K);
                        std::fprintf(w2f, "%d %d %d %d %d\n", counter1 + 5, IJKp1, IJp1Kp1, IJp1K, Ip1Jp1K);

                        counter1 += 6;
                    }
                }
            }

            std::fprintf(w2f, "$EndElements\n");
            cout << "Done\n";
        }

    else if (meshtype == "msh")
        {
            cout << "   Meshing the topology in Gmsh's *.msh 2.2 format\n";

//--------------------------------------//
//---- Header for msh2 -----
//--------------------------------------//

            std::fprintf(w2f, "$MeshFormat\n2.2 0 8\n$EndMeshFormat\n$Nodes\n%d\n",NPnt);

            int counter1 = 1;

            cout << "   Generating points....";

            for(int i=0; i<pntx*pnty; i++)
                {

                    filePoints += fscanf(rf,"%lf",&xx);
                    filePoints += fscanf(rf,"%lf",&yy);
                    filePoints += fscanf(rf,"%lf",&zz); 

                    std::fprintf(w2f, "%d %lf %lf %lf\n"
                                    ,  counter1,xx,yy,zz
                                );

                    counter1++ ;
                    zznew = zz ;
                    delz= (zmax-zz)/PzM1;
                    for(int j=0; j<PzM1; j++)
                        {
                            zznew  = zznew + delz ;
                            std::fprintf(w2f, "%d %lf %lf %lf\n"
                                            ,  counter1,xx,yy,zznew
                                        );
                            counter1++;

                        }
                }

            if(filePoints != pntx*pnty*3 )
            	{
            		cout<<"ERROR! Something is not right \n"
            		    << filePoints*3 << " Vertices read \n"
            		    << pntx*pnty    << " Vertices expected \n";

            		exit(111);
            	}
            filePoints = 0;

            std::fclose(rf);
            std::fprintf(w2f, "$EndNodes\n");
            cout << "   Done\n";

//-----------------------------------------------------------------------------------//
//---- Generating Triangles -----
//-----------------------------------------------------------------------------------//

            cout << "   Generating Triangles...."  ;
            std::fprintf(w2f, "$Elements\n%d\n",NTet+NTri);
            
            counter1=1;

//---------------------------------X-MIN-PLANE----------------------------------//
            for(int i=0; i<PyM1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    = i*Pxz + j + 1;
                            IJKp1   = IJK + 1;
                            Ip1JK   = IJK + Pxz;
                            Ip1JKp1 = Ip1JK + 1;


                            std::fprintf(w2f, "%d 2 2 1 11 %d %d %d\n"
                                              "%d 2 2 1 11 %d %d %d\n"
                                            , counter1, IJKp1, IJK, Ip1JK
                                            , counter1+1, Ip1JKp1, IJKp1, Ip1JK
                                        );

                            counter1=counter1+2;

                        }
                }

//---------------------------------Y-MIN-PLANE----------------------------------//
            for(int i=0; i<PxM1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    = i*pntz + j + 1;
                            IJKp1   = IJK + 1;
                            IJp1K   = IJK + pntz;
                            IJp1Kp1 = IJp1K + 1;

                            std::fprintf(w2f, "%d 2 2 2 22 %d %d %d\n"
                                              "%d 2 2 2 22 %d %d %d\n"
                                            , counter1, IJK, IJKp1, IJp1K
                                            , counter1+1, IJKp1, IJp1Kp1, IJp1K
                                        );

                            counter1=counter1+2;

                        }
                }

//---------------------------------Z-MIN-PLANE----------------------------------//
            for(int i=0; i<PyM1;  i++)
                {
                    for(int j=0; j<PxM1;  j++)
                        {

                            IJK	    = i*Pxz + j*pntz + 1;
                            Ip1JK   = IJK + Pxz;
                            IJp1K   = IJK + pntz;
                            Ip1Jp1K = Ip1JK + pntz;

                            std::fprintf(w2f, "%d 2 2 3 33 %d %d %d\n"
                                              "%d 2 2 3 33 %d %d %d\n"
                                            , counter1, IJK, IJp1K, Ip1Jp1K
                                            , counter1+1, Ip1JK, IJK, Ip1Jp1K
                                        );

                            counter1=counter1+2;
                        }
                }

//---------------------------------X-MAX-PLANE----------------------------------//
            for(int i=0; i<pnty-1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    = i*Pxz + j + 1 + PxM1*pntz;
                            IJKp1   = IJK + 1;
                            Ip1JK   = IJK + Pxz;
                            Ip1JKp1 = Ip1JK + 1;

                            std::fprintf(w2f, "%d 2 2 4 44 %d %d %d\n"
                                              "%d 2 2 4 44 %d %d %d\n"
                                            , counter1, IJK, IJKp1, Ip1JK
                                            , counter1+1, IJKp1, Ip1JKp1, Ip1JK
                                        );
                            
                            counter1=counter1+2;

                        }
                }

//---------------------------------Y-MAX-PLANE----------------------------------//
            for(int i=0; i<PxM1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    = i*pntz + j + 1 +  Pxz*PyM1;
                            IJKp1   = IJK + 1;
                            IJp1K   = IJK + pntz;
                            IJp1Kp1 = IJp1K + 1;

                            std::fprintf(w2f, "%d 2 2 5 55 %d %d %d\n"
                                              "%d 2 2 5 55 %d %d %d\n"
                                            , counter1, IJKp1, IJK, IJp1K
                                            , counter1+1, IJp1Kp1, IJKp1, IJp1K
                                        );
                            
                            counter1=counter1+2;

                        }
                }

//---------------------------------Z-MAX-PLANE----------------------------------//
            for(int i=0; i<PyM1;  i++)
                {
                    for(int j=0; j<PxM1;  j++)
                        {

                            IJK     = i*Pxz + j*pntz + 1 + PzM1;
                            Ip1JK   = IJK + Pxz;
                            IJp1K   = IJK + pntz;
                            Ip1Jp1K = Ip1JK + pntz;

                            std::fprintf(w2f, "%d 2 2 6 66 %d %d %d\n"
                                              "%d 2 2 6 66 %d %d %d\n"
                                            , counter1, IJp1K, IJK, Ip1Jp1K
                                            , counter1+1, IJK, Ip1JK, Ip1Jp1K
                                        );

                            counter1 = counter1+2;
                        }
                }

//-----------------------------------------------------------------------------------//
//---- Generating Tetrahedra -----
//-----------------------------------------------------------------------------------//

            cout << "Done  \n"
                 << "   Generating Tetrahedrals....";

            for(int j=0; j<PyM1;  j++)
                {
                    for(int i=0; i<PxM1;  i++)
                        {
                            for(int k=1; k<=PzM1; k++)
                                {

                                    IJK	      =	i*pntz + j*Pxz + k;
                                    Ip1JK     =	IJK + Pxz;
                                    IJp1K     =	IJK + pntz;
                                    Ip1Jp1K   =	IJK + Pxz + pntz;
                                    IJKp1     =	IJK + 1;
                                    Ip1JKp1   =	Ip1JK + 1;
                                    IJp1Kp1   =	IJp1K + 1;
                                    Ip1Jp1Kp1 =	Ip1Jp1K + 1;


                           std::fprintf(w2f, "%d 4 2 7 77 %d %d %d %d\n"
                                             "%d 4 2 7 77 %d %d %d %d\n"
                                             "%d 4 2 7 77 %d %d %d %d\n"
                                             "%d 4 2 7 77 %d %d %d %d\n"
                                             "%d 4 2 7 77 %d %d %d %d\n"
                                             "%d 4 2 7 77 %d %d %d %d\n"
                                           , counter1  , IJK, IJKp1, IJp1K,Ip1Jp1K
                                           , counter1+1, IJKp1, IJK, Ip1JK, Ip1Jp1K
                                           , counter1+2, Ip1JKp1, IJKp1, Ip1JK, Ip1Jp1K
                                           , counter1+3, IJKp1, Ip1JKp1, Ip1Jp1Kp1, Ip1Jp1K
                                           , counter1+4, IJp1Kp1, IJKp1, Ip1Jp1Kp1, Ip1Jp1K
                                           , counter1+5, IJKp1, IJp1Kp1, IJp1K, Ip1Jp1K
                                        );


//<< counter1   << " 4 2 7 77 " << IJK     << " " << IJKp1   << " " << IJp1K     << " " << Ip1Jp1K <<"\n"
//<< counter1+1 << " 4 2 7 77 " << IJKp1   << " " << IJK     << " " << Ip1JK     << " " << Ip1Jp1K <<"\n"
//<< counter1+2 << " 4 2 7 77 " << Ip1JKp1 << " " << IJKp1   << " " << Ip1JK     << " " << Ip1Jp1K <<"\n"
//<< counter1+3 << " 4 2 7 77 " << IJKp1   << " " << Ip1JKp1 << " " << Ip1Jp1Kp1 << " " << Ip1Jp1K <<"\n"
//<< counter1+4 << " 4 2 7 77 " << IJp1Kp1 << " " << IJKp1   << " " << Ip1Jp1Kp1 << " " << Ip1Jp1K <<"\n"
//>< counter1+5 << " 4 2 7 77 " << IJKp1   << " " << IJp1Kp1 << " " << IJp1K     << " " << Ip1Jp1K <<"\n";
                                    counter1=counter1+6;

                                }
                        }
                }

            std::fprintf(w2f, "$EndElements\n");
            cout  << "Done\n";

        }

#ifdef MEDCOUPLING
//-----------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------//
//---- Writing mesh in .med format -----
//-----------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------//

    else if (meshtype == "med")
        {
            cout << "   Meshing the topology in SALOME's *.med format\n";     

            int counter1 = 0;

            int count = 0;
            cout << "   Generating points....";
            // double medNodeCoords[pntx*pnty*pntz*3];            //  Causes an error for large meshes be carefull
            double* medNodeCoords = new double[pntx*pnty*pntz*3];

            for(int i=0; i<pntx*pnty; i++)
                {

                    filePoints += fscanf(rf,"%lf",&xx);
                    filePoints += fscanf(rf,"%lf",&yy);
                    filePoints += fscanf(rf,"%lf",&zz); 

                    medNodeCoords[ counter1 * 3   ] = xx;
                    medNodeCoords[counter1 * 3 + 1] = yy;
                    medNodeCoords[counter1 * 3 + 2] = zz;

                    counter1++ ;
                    zznew = zz ;
                    delz = (zmax-zz)/PzM1;
                    for(int j=0; j<PzM1; j++)
                        {
                            zznew  = zznew + delz ;

                            medNodeCoords[counter1 * 3    ] = xx;
                            medNodeCoords[counter1 * 3 + 1] = yy;
                            medNodeCoords[counter1 * 3 + 2] = zznew;

                            counter1++;
                        }
                }


            if(filePoints != pntx*pnty*3)
            	{
            		cout<<"ERROR! Something is not right \n" 
            		    << filePoints*3 << " Vertices read \n"
            		    << pntx*pnty    << " Vertices expected \n";

            		exit(111);
            	}
            filePoints = 0;
            
            cout << "   Done\n";

            mcIdType *medCellConn = new mcIdType[NTet*4 + NTri*3];

//-----------------------------------------------------------------------------------//
//---- Generating Tetrahedra -----
//-----------------------------------------------------------------------------------//

            cout << "Done  \n"
                 << "   Generating Tetrahedrons....";

            count = 0;
            for(int j=0; j<PyM1;  j++)
                {
                    for(int i=0; i<PxM1;  i++)
                        {
                            for(int k=0; k<PzM1; k++)
                                {

                                    IJK	      =	i*pntz + j*Pxz + k;
                                    Ip1JK     =	IJK + Pxz;
                                    IJp1K     =	IJK + pntz;
                                    Ip1Jp1K   =	IJK + Pxz + pntz;
                                    IJKp1     =	IJK + 1;
                                    Ip1JKp1   =	Ip1JK + 1;
                                    IJp1Kp1   =	IJp1K + 1;
                                    Ip1Jp1Kp1 =	Ip1Jp1K + 1;

                                    medCellConn[count] = IJK     ; count++; medCellConn[count] =  IJKp1   ; count++; medCellConn[count] = IJp1K     ; count++; medCellConn[count] = Ip1Jp1K ; count++;
                                    medCellConn[count] = IJKp1   ; count++; medCellConn[count] =  IJK     ; count++; medCellConn[count] = Ip1JK     ; count++; medCellConn[count] = Ip1Jp1K ; count++;
                                    medCellConn[count] = Ip1JKp1 ; count++; medCellConn[count] =  IJKp1   ; count++; medCellConn[count] = Ip1JK     ; count++; medCellConn[count] = Ip1Jp1K ; count++;
                                    medCellConn[count] = IJKp1   ; count++; medCellConn[count] =  Ip1JKp1 ; count++; medCellConn[count] = Ip1Jp1Kp1 ; count++; medCellConn[count] = Ip1Jp1K ; count++;
                                    medCellConn[count] = IJp1Kp1 ; count++; medCellConn[count] =  IJKp1   ; count++; medCellConn[count] = Ip1Jp1Kp1 ; count++; medCellConn[count] = Ip1Jp1K ; count++;
                                    medCellConn[count] = IJKp1   ; count++; medCellConn[count] =  IJp1Kp1 ; count++; medCellConn[count] = IJp1K     ; count++; medCellConn[count] = Ip1Jp1K ; count++;


                                }
                        }
                }
            cout  << "Done\n";


//-----------------------------------------------------------------------------------//
//---- Generating Triangles -----
//-----------------------------------------------------------------------------------//

//---------------------------------X-MIN-PLANE----------------------------------//
            for(int i=0; i<PyM1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    = i*Pxz + j ;
                            IJKp1   = IJK ;
                            Ip1JK   = IJK + Pxz;
                            Ip1JKp1 = Ip1JK ;

                            medCellConn[count] = IJKp1   ; count++; medCellConn[count] =  IJK   ; count++; medCellConn[count] = Ip1JK ; count++;
                            medCellConn[count] = Ip1JKp1 ; count++; medCellConn[count] =  IJKp1 ; count++; medCellConn[count] = Ip1JK ; count++;

                        }
                }

//---------------------------------Y-MIN-PLANE----------------------------------//
            for(int i=0; i<PxM1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    = i*pntz + j ;
                            IJKp1   = IJK ;
                            IJp1K   = IJK + pntz;
                            IJp1Kp1 = IJp1K ;

                            medCellConn[count] = IJK   ; count++; medCellConn[count] =  IJKp1   ; count++; medCellConn[count] = IJp1K ; count++;
                            medCellConn[count] = IJKp1 ; count++; medCellConn[count] =  IJp1Kp1 ; count++; medCellConn[count] = IJp1K ; count++;

                        }
                }

//---------------------------------Z-MIN-PLANE----------------------------------//
            for(int i=0; i<PyM1;  i++)
                {
                    for(int j=0; j<PxM1;  j++)
                        {

                            IJK	    = i*Pxz + j*pntz ;
                            Ip1JK   = IJK + Pxz;
                            IJp1K   = IJK + pntz;
                            Ip1Jp1K = Ip1JK + pntz;

                            medCellConn[count] = IJK   ; count++; medCellConn[count] =  IJp1K   ; count++; medCellConn[count] = Ip1Jp1K ; count++;
                            medCellConn[count] = Ip1JK ; count++; medCellConn[count] =  IJK     ; count++; medCellConn[count] = Ip1Jp1K ; count++;

                        }
                }

//---------------------------------X-MAX-PLANE----------------------------------//
            for(int i=0; i<pnty-1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    = i*Pxz + j + PxM1*pntz;
                            IJKp1   = IJK ;
                            Ip1JK   = IJK + Pxz;
                            Ip1JKp1 = Ip1JK;

                            medCellConn[count] = IJK   ; count++; medCellConn[count] =  IJKp1   ; count++; medCellConn[count] = Ip1JK ; count++;
                            medCellConn[count] = IJKp1 ; count++; medCellConn[count] =  Ip1JKp1 ; count++; medCellConn[count] = Ip1JK ; count++;

                        }
                }

//---------------------------------Y-MAX-PLANE----------------------------------//
            for(int i=0; i<PxM1;  i++)
                {
                    for(int j=0; j<PzM1;  j++)
                        {

                            IJK	    = i*pntz + j  +  Pxz*PyM1;
                            IJKp1   = IJK ;
                            IJp1K   = IJK + pntz;
                            IJp1Kp1 = IJp1K ;

                            medCellConn[count] = IJKp1   ; count++; medCellConn[count] =  IJK   ; count++; medCellConn[count] = IJp1K ; count++;
                            medCellConn[count] = IJp1Kp1 ; count++; medCellConn[count] =  IJKp1 ; count++; medCellConn[count] = IJp1K ; count++;

                        }
                }

//---------------------------------Z-MAX-PLANE----------------------------------//
            for(int i=0; i<PyM1;  i++)
                {
                    for(int j=0; j<PxM1;  j++)
                        {

                            IJK     = i*Pxz + j*pntz + PzM1;
                            Ip1JK   = IJK + Pxz;
                            IJp1K   = IJK + pntz;
                            Ip1Jp1K = Ip1JK + pntz;

                            medCellConn[count] = IJp1K ; count++; medCellConn[count] =  IJK   ; count++; medCellConn[count] = Ip1Jp1K ; count++;
                            medCellConn[count] = IJK   ; count++; medCellConn[count] =  Ip1JK ; count++; medCellConn[count] = Ip1Jp1K ; count++;

                        }
                }
/**/
//-----------------------------------------------------------------------------------//

            MEDCouplingUMesh * medMesh3d = MEDCouplingUMesh::New();

            medMesh3d -> setMeshDimension(3);
            medMesh3d -> allocateCells(NTet);
            medMesh3d -> setName("TetrahedralMesh");

            MEDCouplingUMesh * medMesh2d = MEDCouplingUMesh::New();
            medMesh2d -> setMeshDimension(2);
            medMesh2d -> allocateCells(NTri);
            medMesh2d -> setName("TetrahedralMesh");
            

            cout  << "   Writing Nodes....";
            DataArrayDouble * myCoords = DataArrayDouble::New();
            myCoords -> alloc(pntx*pnty*pntz, 3);
            myCoords -> setInfoOnComponent(0, "x");
            myCoords -> setInfoOnComponent(1, "y");
            myCoords -> setInfoOnComponent(2, "z");
            std::copy(medNodeCoords, medNodeCoords + pntx*pnty*pntz*3, myCoords -> getPointer());
            medMesh3d -> setCoords(myCoords);
            medMesh2d -> setCoords(myCoords);            
            cout  << "Done\n";



            cout  << "   Writing Tetrahedrons....";
            count = 0;
            for (int i = 0; i < NTet; i++) {
              medMesh3d -> insertNextCell(INTERP_KERNEL::NORM_TETRA4, 4, medCellConn + count);
              count += 4;
            }
            medMesh3d -> finishInsertingCells();
            cout  << "Done\n";




            cout  << "   Writing Trinangles....";
            for (int i = 0; i < NTri; i++) {
              medMesh2d -> insertNextCell(INTERP_KERNEL::NORM_TRI3, 3, medCellConn + count);
              count += 3;
            }
            medMesh2d -> finishInsertingCells();




            cout  << "   Writing Mesh....";            
            std::vector<const MEDCouplingUMesh *> finalMesh;
            finalMesh.push_back(medMesh3d);
            finalMesh.push_back(medMesh2d);

            WriteUMeshes(*outputfile,finalMesh,true);
            cout  << "Done\n";

            medMesh2d -> decrRef();
            medMesh3d -> decrRef();
            myCoords  -> decrRef();
            delete[]     medNodeCoords;
            delete[]     medCellConn;
        }
#endif               
    else
        {
            cout << " *=============================================================*\n"
                 << " * ERROR: --mesh input is wrong only msh, msh4, or mesh is accepted   *\n"
                 << " *=============================================================*\n\n";
        }
delete inputfile;
delete outputfile;
//-----------------------------------------------------------------------------------//
//---- For timing the program -----
//-----------------------------------------------------------------------------------//

    get_time = clock() - get_time;

    cout << " *============================================================*\n"
         << "  The program finished in : " << (float)get_time/CLOCKS_PER_SEC 
         << " s\n"
         << " *============================================================*\n";

    return 0;
}
