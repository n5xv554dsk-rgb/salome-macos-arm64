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

using namespace std;


int main(int argc, char *argv[])
{

//-----------------------------------------------------------------------------------//
// ---- Logo -----
//-----------------------------------------------------------------------------------//

    #include "./../lib/LogoTopiiVolCpp.hpp"

//-----------------------------------------------------------------------------------//
//---- Global Variables -----
//-----------------------------------------------------------------------------------//

    double x 		;
    double y 		;
    double z 		;

    int pointsYAfterSkip;
    int pointsXAfterSkip;

//-----------------------------------------------------------------------------------//
//---- Input Parameters -----
//-----------------------------------------------------------------------------------//

    int pntx = 2500     ;
    int pnty = 2251     ;

    int skipx = 150     ;
    int skipy = 150     ;

    string inputfile  = "./../data/DEM_2m_new.xyz" ;
    string outputfile = "out-coarse.xyz"           ;

//-----------------------------------------------------------------------------------//
//---- Commandline Parameters -----
//-----------------------------------------------------------------------------------//

    for(int i=0; i<argc-1; i++)
        {

            string argvdummy  = argv[i]   ;
            string argvdummy1 = argv[i+1] ;

            if( argvdummy == "--xpoints")
                pntx = stoi(argvdummy1);

            if( argvdummy == "--ypoints")
                pnty = stoi(argvdummy1);

            if( argvdummy == "--xskip")
                skipx = stoi(argvdummy1);

            if( argvdummy == "--yskip")
                skipy = stoi(argvdummy1);

            if( argvdummy == "--in")
                inputfile = argvdummy1;

            if( argvdummy == "--out")
                outputfile = argvdummy1;

        }


//-----------------------------------------------------------------------------------//
//---- Message on commandline -----
//-----------------------------------------------------------------------------------//

    cout << "\n"
         << " *===================================================*\n"
         << " *                  User inputs                      *\n"
         << " *===================================================*\n\n"
         << "   X points are        ------ " << pntx      << "\n"
         << "   Y points are        ------ " << pnty      << "\n"
         << "   X skip points are   ------ " << skipx     << "\n"
         << "   Y skip points are   ------ " << skipy     << "\n"
         << "   Input file          ------ " << inputfile << "\n"
         << "   Output file         ------ " << outputfile<< "\n";

//-----------------------------------------------------------------------------------//
//---- I/O Files -----
//---------------------------------
// w2f  : write to file
// rf   : read from file
//-----------------------------------------------------------------------------------//    
    
    FILE* rf;
    rf = std::fopen((inputfile).c_str(), "r");
    
    FILE* w2f;
    w2f = std::fopen((outputfile).c_str(), "w");

//-----------------------------------------------------------------------------------//
//---- For timing the program -----
//-----------------------------------------------------------------------------------//

    clock_t get_time = clock();

//-----------------------------------------------------------------------------------//
//---- Total points after skip-----
//-----------------------------------------------------------------------------------//

    if (pnty%skipy==0)
        pointsYAfterSkip=pnty/skipy;
    if (pnty%skipy!=0)
        pointsYAfterSkip=pnty/skipy+1;

    if (pntx%skipx==0)
        pointsXAfterSkip=pntx/skipx;
    if (pntx%skipx!=0)
        pointsXAfterSkip=pntx/skipx+1;

//-----------------------------------------------------------------------------------//
//---- mesh coarsening ----
//-----------------------------------------------------------------------------------//

    cout << "\n"
         << " *===================================================*\n"
         << " *                  Work in progress                 *\n"
         << " *===================================================*\n\n"
         << "   topIIvol began coarsening "+inputfile+"\n"
         << "   ..."; 

    for(int j=0; j<pnty; j++)
        {
            for(int i=0; i<pntx; i++)
                {                    
                    fscanf(rf,"%lf",&x) ;
                    fscanf(rf,"%lf",&y) ;
                    fscanf(rf,"%lf",&z) ;
                    
                    if(int(j%skipy) == 0 && int(i%skipx) == 0)
                        std::fprintf(w2f, "%lf %lf %lf\n", x,y,z);
                }
        }

    std::fclose(w2f);
    std::fclose(rf);

    cout << "Finished !!!\n"
         << "   topIIvol is now writing an info file\n"
         << "   ...";

    w2f = std::fopen((outputfile+".info").c_str(), "w");

    std::fprintf(w2f, " *===================================================*\n"
                      " *      Information on processed point cloud         *\n"
                      " *===================================================*\n"
                      "   Total # points :: %d\n"
                      "   Total # xPoints:: %d\n"
                      "   Total # yPoints:: %d\n"
                      " *===================================================*\n"
                      , pointsYAfterSkip*pointsXAfterSkip  
                      , pointsXAfterSkip 
                      , pointsYAfterSkip                    
                );

    std::fclose(w2f);

    cout << "Finished !!!\n";

//-----------------------------------------------------------------------------------//
//---- Message on commandline -----
//-----------------------------------------------------------------------------------//

    cout << "\n"
         << " *===================================================*\n"
         << " *      Information on processed point cloud         *\n"
         << " *===================================================*\n"
         << "\n   Total # points :: "<< pointsXAfterSkip*pointsYAfterSkip
         << "\n   Total # xPoints:: "<< pointsXAfterSkip
         << "\n   Total # yPoints:: "<< pointsYAfterSkip
         << "\n\n ====================================================\n\n";

//-----------------------------------------------------------------------------------//
//---- For timing the program -----
//-----------------------------------------------------------------------------------//

    get_time = clock() - get_time;

    cout << " *============================================================*\n"
         << "  The program finished in : " << (float)get_time/CLOCKS_PER_SEC 
         << " s\n"
         << " *============================================================*\n\n";

    return 0;
}

