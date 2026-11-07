#include <iostream>
#include <fstream>
#include <iomanip>
using namespace std;


int main(){

    int Scatter = 1 ;

    double x ;
    double y ;
    double z ;

    int pntx = 2500 ;
    int pnty = 2251 ;

    int skipx = 150;
    int skipy = 150;

    string inpurfile="./../data/DEM_2m_new.xyz";
    string outpufile="out-coarse.xyz";


    cout << " *============================================================*\n" 
         << "         ___                                            ___    \n" 
         << "        /  /               ___________                 /  /    \n" 
         << "     __/  /_ ___    ___   /__  __  __/__    __ ____   /  /     \n" 
         << "    /_   __// _  \\ / _  \\   / / / /   \\ \\  / // _  \\ /  / \n" 
         << "     /  /_ / /_/ // /_/ /__/ /_/ /__   \\ \\/ // /_/ //  /__   \n" 
         << "     \\___/ \\____// ____//__________/    \\__/ \\____/ \\____/\n" 
         << "                / /                                            \n" 
         << "               /_/                                             \n"
         << " *============================================================*\n"; 

    cout << " 							    \n" 
         << " *  This program  will coarsen your .xyz by skipping * \n" 
         << " *  the  specified  number of x and y points to skip.* \n" 
         << " 							    \n";

    cout << " *===================================================* \n" 
         << " *                  User Input                       * \n"  
         << " *===================================================* \n" 
         << "  							    \n"; 
    cout << "   Enter total  points in  x  [int]   "; cin >> pntx;
    cout << "   Enter points to skip in x  [int]   "; cin >> skipx;
    cout << "   Enter total  points in  y  [int]   "; cin >> pnty;
    cout << "   Enter points to skip in y  [int]   "; cin >> skipy;
    cout << "   Enter the input .xyz file  [char]  "; cin >> inpurfile;
    cout << "   Enter the output file name [char]  "; cin >> outpufile;
    cout << " 							    \n";

 
    ifstream in;
        in.open(inpurfile);

    ofstream wr;

//-----------------------------------------------------------------------------------//
//---- Skipmeshing -----
//-----------------------------------------------------------------------------------//

    if(Scatter!=1){

        cout << "\n\n";
    	cout << " *===================================================* \n" 
             << " *                  Work in progress                 * \n"  
             << " *===================================================* \n"
             << " 							\n"
             << "   Top2Vol began coarsing "+inpurfile+"                \n";
        cout << "   ...";   

        wr.open(outpufile);
        for(int j=0; j<pnty; j++){
        for(int i=0; i<pntx; i++){
	    in>>std::fixed>> x  >> y >> z;

	    if(int(j%skipy)==0 && int(i%skipx)==0 )
	        wr<< std::fixed << x << "  " << y << "  "<<z << endl;
        }
        }
        wr.close();

        cout << "Finshed !!!                                               \n" 
             << "   Top2Vol is now writing an info file                    \n";
        cout << "   ...";    

        wr.open("info-"+outpufile+".txt");

        wr   << " *===================================================* \n" 
             << " *                  INFORMATION                      * \n"  
             << " *===================================================* \n"        
             << "\n   Total # Points :: "<< int((pnty/skipy+1)*(pntx/skipx+1))
             << "\n   Total # xPoints:: "<< int(pntx/skipx+1)
             << "\n   Total # yPoints:: "<< int(pnty/skipy+1)
             << "\n\n ==================================================== \n"  
             << 
         endl;
        wr.close();


        cout << "Finshed !!!                                               \n";
    }

//-----------------------------------------------------------------------------------//
//---- Skip mesh with partitioning -----
//-----------------------------------------------------------------------------------//

   if(Scatter==1){

        int Nscat;
        int countme=0, countme2=0;

        cout << "\n\n";

        cout << " *===================================================* \n" 
             << " *           !!!! IMPORTANT !!!!                     * \n"  
             << " *===================================================* \n" 
             << "\n   To get perfect scaling we recommend  choosing      "
             << "\n   the striping parameter (number of partitions)      "
             << "\n   so that it divides << "<< int((pnty/skipy+1)*(pntx/skipx+1))
             << " >>   and << "<< int(pnty/skipy)
             << " >>" 
             << "\n\n ==================================================== \n"  
             << 
         endl;


        cout << "\n\n";
        cout << "Enter the striping parameter [int] :: ";cin  >> Nscat ;	
        cout << "\n\n";
 
        cout << " *===================================================* \n" 
             << " *                  IMPORTANT                        * \n"  
             << " *===================================================* \n"        
             << " *   Note that when using the parallel Top2Vol-mesher* \n" 
             << " *   please use << "<< Nscat <<" >> MPI processing units for     * \n"
             << " *   optimal performance of the mesher in parallel   * \n"
             << " *===================================================* \n"  
             << 
         endl;

	int k=0;

        wr.open(outpufile+"-info.txt");

        wr   << " *===================================================* \n" 
             << " *                  INFORMATION                      * \n"  
             << " *===================================================* \n"        
             << "\n   Total # strips :: "<< Nscat  
             << "\n   Total # Points :: "<< int((pnty/skipy+1)*(pntx/skipx+1))
             << "\n   Total # xPoints:: "<< int(pntx/skipx+1)
             << "\n   Total # yPoints:: "<< int(pnty/skipy+1)
             << "\n\n ==================================================== \n"  
             << 
         endl;
        wr.close();


        wr.open(outpufile+"_"+std::to_string(k)+".xyz");

        for(int j=0; j<pnty; j++){
        for(int i=0; i<pntx; i++){

	    in>>std::fixed>> x  >> y >> z;

	    if(int(j%skipy)==0 && int(i%skipx)==0 ){
                if(countme==int(int(pntx/skipx+1)*int(pnty/skipy+1))/Nscat){
		countme=0; k++;
    		wr.close();
                wr.open(outpufile+"_"+std::to_string(k)+".xyz");
		}
	        wr<< std::fixed << x << "  " << y << "  "<<z << endl;
	        countme++;
            }
        }
        }

    }

    	cout << "\n\n";

    	cout << " *===================================================* \n" 
             << " *                  Information                      * \n"  
             << " *===================================================* \n"        
             << "\n   Total # Points :: "<< int((pnty/skipy+1)*(pntx/skipx+1))
             << "\n   Total # xPoints:: "<< int(pntx/skipx+1)
             << "\n   Total # yPoints:: "<< int(pnty/skipy+1)
             << "\n\n ==================================================== \n"
             << 
    	endl;

return 0;
}

