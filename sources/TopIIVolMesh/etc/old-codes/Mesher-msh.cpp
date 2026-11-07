#include <iostream>
#include <fstream>
#include <iomanip>
using namespace std;


int main()
{

//--------------------------------------//
//---- Global Variables -----
//--------------------------------------//

int counter1	;

double xx	;
double yy	;
double zz	;
double delz	;
double zznew	;


//--------------------------------------//
//---- Global Parameters -----
//--------------------------------------//
double 	zmax=-1920.0000		;

int 	pntx=10			,
	pnty=10			,
	pntz=10			;


//--------------------------------------//
//---- Calculating Parameters -----
//--------------------------------------//
int TotNodes = pntx * pnty * pntz		;
int TotTrigl = ((pntz-1) * (pntx-1) * 4)  + ((pnty-1) * (pntz-1) * 4) + ((pntx-1) * (pnty-1) * 4);
int TotTetra = (pntx-1) * (pnty-1) * (pntz-1) * 6;
int TotElemt = TotTetra + TotTrigl;



//--------------------------------------//
//---- I/O Files -----
//--------------------------------------//
ifstream in;
in.open("CoarseMesh-Skip500.xyz");
//in.open("./../data/CoarseMeshoo.xyz");

ofstream wrgmsh;
wrgmsh.open("output-mesh.msh");


//--------------------------------------//
//---- Header for msh2 -----
//--------------------------------------//
wrgmsh<< "$MeshFormat" 		<< endl;
wrgmsh<< "2.2 0 8" 		<< endl;
wrgmsh<< "$EndMeshFormat" 	<< endl;
wrgmsh<< "$Nodes" 		<< endl;
wrgmsh<< TotNodes 		<< endl;

counter1=1;

cout << "Generating points....";

for(int i=0; i<pntx*pnty; i++){
	in>>std::fixed>> xx  >> yy >> zz;
	wrgmsh<< std::fixed << counter1 << "  " << xx << "  " << yy << "  "<<zz << endl;
	counter1++;
	zznew=zz; delz= (zmax-zz)/(pntz-1);
	for(int j=0; j<pntz-1; j++){
		zznew  = zznew + delz;
			wrgmsh<< std::fixed << counter1 << "  " << xx << "  " << yy << "  "<<zznew << endl;
			counter1++;

	}
}

wrgmsh<< "$EndNodes" 		<< endl;

cout << "Done  "<< endl;

cout << "Generating Tetrahedra....";

wrgmsh<< "$Elements" 		<< endl;
wrgmsh<< TotElemt        	<< endl;


counter1=1;

int IJK,Ip1JK,IJp1K,Ip1Jp1K,IJKp1,Ip1JKp1,IJp1Kp1,Ip1Jp1Kp1;


//---------------------------------X-MIN-PLANE----------------------------------//
for(int i=0; i<pnty-1;  i++){
for(int j=0; j<pntz-1;  j++){

IJK	=	i*(pntz*pntx) + j+1	;
IJKp1	=	IJK + 1			;
Ip1JK	=	IJK + (pntz*pntx)	;
Ip1JKp1	=	Ip1JK + 1		;

wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "1" <<" " << "11" << " " << IJKp1  << " " <<  IJK << " " << Ip1JK <<endl;
counter1++;
wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "1" <<" " << "11" <<  " " << Ip1JKp1 << " " << IJKp1 << " " << Ip1JK <<endl;
counter1++;

}
}
//------------------------------------------------------------------------------------//

//---------------------------------Y-MIN-PLANE----------------------------------//
for(int i=0; i<pntx-1;  i++){
for(int j=0; j<pntz-1;  j++){

IJK	=	i*pntz + j+1	;
IJKp1	=	IJK + 1		;
IJp1K	=	IJK + pntz	;
IJp1Kp1	=	IJp1K + 1	;

wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "2" <<" " << "22" << " " << "0" << " "<< " " << IJK << " " << IJKp1 << " " << IJp1K <<endl;
counter1++;
wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "2" <<" " << "22" << " " << "0" << " "<< " " << IJKp1 << " " << IJp1Kp1 << " " << IJp1K <<endl;
counter1++;

}}
//------------------------------------------------------------------------------------//


//---------------------------------Z-MIN-PLANE----------------------------------//
for(int i=0; i<pnty-1;  i++){
for(int j=0; j<pntx-1;  j++){

IJK	=	i*(pntz*pntx) + j*(pntz)+1	;
Ip1JK	=	IJK + (pntz*pntx)		;
IJp1K	=	IJK + pntz			;
Ip1Jp1K	=	Ip1JK + pntz		;

wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "1" <<" " << "33" << " "  << IJK  << " " <<  IJp1K  << " " <<   Ip1Jp1K   <<endl;
counter1++;
wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "1" <<" " << "33" << " "  << Ip1JK << " " << IJK << " " << Ip1Jp1K <<endl;
counter1++;
}
}
//------------------------------------------------------------------------------------//


//---------------------------------X-MAX-PLANE----------------------------------//
for(int i=0; i<pnty-1;  i++){
for(int j=0; j<pntz-1;  j++){

IJK	=	i*(pntz*pntx) + j+1 + (pntx-1)*(pntz)	;
IJKp1	=	IJK + 1			;
Ip1JK	=	IJK + (pntz*pntx)	;
Ip1JKp1	=	Ip1JK + 1		;

wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "1" <<" " << "44" << " " <<  IJK  << " " << IJKp1  << " " << Ip1JK <<endl;
counter1++;
wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "1" <<" " << "44" <<  " " <<  IJKp1 << " " << Ip1JKp1 << " " << Ip1JK <<endl;
counter1++;

}
}
//------------------------------------------------------------------------------------//

//---------------------------------Y-MAX-PLANE----------------------------------//
for(int i=0; i<pntx-1;  i++){
for(int j=0; j<pntz-1;  j++){

IJK	=	i*pntz + j+1 + (pntx*pntz*(pnty-1))	;
IJKp1	=	IJK + 1		;
IJp1K	=	IJK + pntz	;
IJp1Kp1	=	IJp1K + 1	;

wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "2" <<" " << "55" << " " << "0" << " "<< " " <<  IJKp1 << " " << IJK << " " << IJp1K <<endl;
counter1++;
wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "2" <<" " << "55" << " " << "0" << " "<< " " << IJp1Kp1  << " " <<IJKp1  << " " << IJp1K <<endl;
counter1++;

}}
//------------------------------------------------------------------------------------//


//---------------------------------Z-MAX-PLANE----------------------------------//
for(int i=0; i<pnty-1;  i++){
for(int j=0; j<pntx-1;  j++){

IJK	=	i*(pntz*pntx) + j*(pntz)+1 + (pntz-1)	;
Ip1JK	=	IJK + (pntz*pntx)		;
IJp1K	=	IJK + pntz			;
Ip1Jp1K	=	Ip1JK + pntz		;

wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "1" <<" " << "66" << " "  << IJp1K    << " " << IJK << " " <<   Ip1Jp1K   <<endl;
counter1++;
wrgmsh<< std::fixed << counter1 << " " << "2" << " " << "1" <<" " << "66" << " "  <<  IJK << " " <<Ip1JK << " " << Ip1Jp1K <<endl;
counter1++;
}
}
//------------------------------------------------------------------------------------//


for(int j=0; j<pnty-1;  j++){
for(int i=0; i<pntx-1;  i++){
for(int k=1; k<=pntz-1; k++){

IJK	=	i*pntz + j*pntx*pntz + k;


Ip1JK	=	IJK 	+ (pntx*pntz)		;
IJp1K	=	IJK 	+ (pntz)		;
Ip1Jp1K	=	IJK 	+ (pntx*pntz) + pntz	;

IJKp1     =	IJK 	+ 1	;
Ip1JKp1   =	Ip1JK 	+ 1	;
IJp1Kp1   =	IJp1K   + 1	;
Ip1Jp1Kp1 =	Ip1Jp1K + 1	;


wrgmsh<< std::fixed << counter1 << " " << "4" << " " << "2" <<" " << "0" << " " << "0" << " " << IJK << " " << IJKp1 << " " << IJp1K << " " << Ip1Jp1K <<endl;
counter1++;

wrgmsh<< std::fixed << counter1 << " " << "4" << " " << "2" <<" " << "0" << " " << "0" << " " << IJKp1 << " " << IJK << " " << Ip1JK << " " << Ip1Jp1K <<endl;
counter1++;


wrgmsh<< std::fixed << counter1 << " " << "4" << " " << "2" <<" " << "0" << " " << "0" << " " << Ip1JKp1 << " " << IJKp1 << " " << Ip1JK << " " << Ip1Jp1K <<endl;
counter1++;

wrgmsh<< std::fixed << counter1 << " " << "4" << " " << "2" <<" " << "0" << " " << "0" << " " << IJKp1 << " " << Ip1JKp1 << " " << Ip1Jp1Kp1 << " " << Ip1Jp1K <<endl;
counter1++;

wrgmsh<< std::fixed << counter1 << " " << "4" << " " << "2" <<" " << "0" << " " << "0" << " " << IJp1Kp1 << " " << IJKp1 << " " << Ip1Jp1Kp1 << " " << Ip1Jp1K <<endl;
counter1++;

wrgmsh<< std::fixed << counter1 << " " << "4" << " " << "2" <<" " << "0" << " " << "0" << " " << IJKp1 << " " << IJp1Kp1 << " " << IJp1K << " " << Ip1Jp1K <<endl;
counter1++;

}
}
}


wrgmsh<< "EndElements" 		<< endl;
cout << "Done  "<< endl;



cout << "Program ended successfully"<< endl;

return 0;
}
