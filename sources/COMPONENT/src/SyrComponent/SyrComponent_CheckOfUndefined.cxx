// Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
//
// Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
// CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
//
// See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
//

//  SuperVisionTest SyrComponent : example of component performing some mathinatical operations
//  File   : SyrComponent_CheckOfUndefined.cxx
//  Module : SuperVisionTest
//
#include <stdio.h>
#ifndef WIN32
#include <unistd.h>
#endif
#include <iostream>
#include <fstream>
#include <strstream>
#include <string>
#include <math.h>
#include <cstring>

using namespace std;

// ------------------------------------------------------------------
// NextPrime : Compute the first prime number greater or equal than an integer
// ------------------------------------------------------------------

#define VALUESNBR 4

long NextPrime (const long me ) 
{

 struct svalue {int signiaib ;
                int nbr ;} ;

 struct svalue values[VALUESNBR] ;
 long ia ;
 long maxia ;
 long ib[4] ;
 int n[4] ;
// int signiaib[4] = { -1 , +1 , +1 , -1 } ;
 int signiaib[4];
 signiaib[0] = -1;
 signiaib[1] = 1;
 signiaib[2] = 1;
 signiaib[3] = -1;
 long remain ;

 int nbvalues ;
 int loop ;
 int nindd ;
 long minn ;
 long maxvn ;
 long premret = 0 ;

   if (me < 0 || me >
#ifdef DECOSF1
                      127149130704178201
#else
                      2147483647
#endif
                               ){
//      Standard_RangeError::
//       Raise("Try to apply NextPrime method with negative, null or too large value.");
        return 0 ;
   }

   if ( me <= 7 ) {
     if ( me <= 1 )
       return 1 ;
     else if ( me <= 2 )
       return 2 ;
     else if ( me <= 3 )
       return 3 ;
     else if ( me <= 5 )
       return 5 ;
     else if ( me <= 7 )
       return 7 ;
   }

   minn = ( me - 1 ) / 6 ;              // n minimum
   while ( 6*minn+1 < me ) {
        minn += 1 ;
      }

   maxia = long( sqrt( (double)me ) / 6 + 1 ) ;

   maxvn = minn + VALUESNBR ;

   nbvalues = 0 ;
   for ( nindd = 0 ; nindd < VALUESNBR ; nindd++ ) {
      if ( 6*(nindd+minn)-1 < me ) {
        values[nindd].nbr = 1 ;
        values[nindd].signiaib = -1 ;
        nbvalues += 1 ;
      }
      else {
        values[nindd].nbr = 0 ;
        values[nindd].signiaib = 0 ;
      }
    }

   for ( ia = 1 ; ia <= maxia ; ia++ ) {
      if ( nbvalues == VALUESNBR*2 ) {
        break ;
      }
      remain = -VALUESNBR ;
      ib[0] = ( minn + ia - remain ) / (6*ia - 1) ;
      n[0] = int ( 6*ia*ib[0] - ia - ib[0] - minn ) ;
      ib[1] = ( minn - ia - remain ) / (6*ia - 1) ;
      n[1] = int ( 6*ia*ib[1] + ia - ib[1] - minn ) ;
      ib[2] = ( minn + ia - remain ) / (6*ia + 1) ;
      n[2] = int ( 6*ia*ib[2] - ia + ib[2] - minn ) ;
      ib[3] = ( minn - ia - remain ) / (6*ia + 1) ;
      n[3] = int ( 6*ia*ib[3] + ia + ib[3] - minn ) ;
      for ( loop = 0 ; loop < 4 ; loop++ ) {
         if ( n[loop] >= 0 && n[loop] < VALUESNBR ) {
           if ( ( values[n[loop]].nbr == 0 ) ||
                ( values[n[loop]].signiaib == signiaib[loop] ) ) {
             values[n[loop]].signiaib = -signiaib[loop] ;
             values[n[loop]].nbr += 1 ;
             if ( values[n[loop]].nbr <= 2 )
               nbvalues += 1 ;
	   }
	 }
       }
    }
   for ( nindd = 0 ; nindd < VALUESNBR ; nindd++ ) {
     if ( values[nindd].nbr == 0 ) {
       if ( me <= 6*(nindd+minn)-1 ) {
          premret = 6*(nindd+minn)-1 ;
          break ;
	}
       else if ( me <= 6*(nindd+minn)+1 ) {
         premret = 6*(nindd+minn)+1 ;
         break ;
       }
     }
     else if ( values[nindd].nbr == 1 ) {
        if ( values[nindd].signiaib > 0 ) {
          if ( me <= 6*(nindd+minn)-1 ) {
            premret = 6*(nindd+minn)-1 ;
            break ;
	  }
	}
        else {
          if ( me <= 6*(nindd+minn)+1 ) {
            premret = 6*(nindd+minn)+1 ;
            break ;
	  }
	}
      }
   }

   if ( premret != 0 ) {
     return premret ;
   }

 return NextPrime ( 6*(maxvn-1)+2) ;

}

static char * base( int b , long n ) {
  static char c[40] ;
  char ccc[2] ;
  int i = 39 ;
  c[39] = '\0' ;
  c[38] = '0' ;
  if ( n ) {
    while ( n ) {
      i-- ;
      sprintf( ccc ,"%d" , ( n % b ) ) ;
      c[i] = ccc[0] ;
      n = n / b ;
    }
  }
  else
    i = 38 ;
  return &c[i] ;
}

static char * B2( long n ) {
  return base( 2 , n ) ;
}

static char * B3( long n ) {
  return base( 3 , n ) ;
}

static char * B4( long n ) {
  return base( 4 , n ) ;
}

static char * B5( long n ) {
  return base( 5 , n ) ;
}

static char * B7( long n ) {
  return base( 7 , n ) ;
}

static char * B8( long n ) {
  return base( 8 , n ) ;
}

static long S( long f , long n ) {
  int i ;
  long res = 0 ;
  for ( i = 0 ; i <= n ; i++ ) {
    res += 1 << (f*i) ;
  }
  return res ;
}

static long S2( long n ) {
  return S( 2 , n ) ;
}

static long S6( long n ) {
  return S( 6 , n ) ;
}

static long rP( long odd ) {
  if ( (( odd - 1 ) % 6 ) == 0 )
    return 1 ;
  if ( (( odd - 3 ) % 6 ) == 0 )
    return 3 ;
  if ( (( odd - 5 ) % 6 ) == 0 )
    return 5 ;
  return 0 ;
}
static long nP( long odd ) {
  return ( odd / 6 ) ;
}

static long rQ( long N ) {
  if ( ( N & 7 ) == 5 ) {
    return 5 ;
  }
  return ( N & 3 ) ;
}
static long nQ( long N ) {
  if ( ( N & 3 ) == 3 ) {
    return ( N / 4 ) ;
  }
  else {
    return ( N / 8 ) ;
  }
}

static long rT( long N ) {
  return ( nP( N ) % 3 ) ;
}
static long nT( long N ) {
  return ( nP( N ) / 3 ) ;
}

static char * fact( int n ) {
  static char chn[132] ;
  if ( n == 0 ) {
    strcpy( chn , "0" ) ;
  }
  else if ( n == 1 ) {
    strcpy( chn , "1" ) ;
  }
  else {
    int pow2 = 0 ;
    int pow3 = 0 ;
    while ( (n & 1 ) == 0 ) {
      pow2 += 1 ;
      n = (n >> 1 ) ;
    }
    while ( ( n % 3 ) == 0 ) {
      pow3 += 1 ;
      n = n / 3 ;
    }
    int pos = 0 ;
    if ( pow2 ) {
      if ( pow2 == 1 ) {
        sprintf( &chn[pos] , "%d" , 2 ) ;
      }
      else {
        sprintf( &chn[pos] , "2**%d" , pow2 ) ;
      }
      pos = strlen( chn ) ;
    }
    if ( pow3 ) {
      if ( pow2 ) {
        strcat( chn , "*" ) ;
        pos = strlen( chn ) ;
      }
      if ( pow3 == 1 ) {
        sprintf( &chn[pos] , "%d" , 3 ) ;
      }
      else {
        sprintf( &chn[pos] , "3**%d" , pow3 ) ;
      }
      pos = strlen( chn ) ;
    }
    if ( n != 1 ) {
      if ( pow2 || pow3 ) {
        sprintf( &chn[pos] , "*%d" , n ) ;
      }
      else {
        sprintf( &chn[pos] , "%d" , n ) ;
      }
    }
  }
  return chn ;
}

static long Next( const long prev , long &pow2 ) {
  long next = ( 3*prev + 1 )/2 ;
  pow2 = 1 ;
  while ( ( next & 1 ) == 0 ) {
    next = ( next >> 1 ) ;
    pow2 += 1 ;
  }
  return next ;
}

int T1a( int n0 , int n1 ) {
  return (1<<(6*n1+2))*(3*n0+0) + (1<<(6*n1+1)) + S2(3*n1+0) ;
}
int T1b( int n0 , int n1 ) {
  return (1<<(6*n1+6))*(3*n0+1) + (1<<(6*n1+5)) + S2(3*n1+2) ;
}
int T1c( int n0 , int n1 ) {
  return (1<<(6*n1+4))*(3*n0+2) + (1<<(6*n1+3)) + S2(3*n1+1) ;
}
int T2a( int n0 , int n1 ) {
  return (1<<(6*n1+7))*(3*n0+0) + S2(3*n1+2) ;
}
int T2b( int n0 , int n1 ) {
  return (1<<(6*n1+3))*(3*n0+1) + S2(3*n1+0) ;
}
int T2c( int n0 , int n1 ) {
  return (1<<(6*n1+5))*(3*n0+2) + S2(3*n1+1) ;
}

int P1a1( int n0 , int n1 ) {
  return (1<<(6*n1+4))*(3*n0+0) + (1<<(6*n1+3)) + S2(3*n1+1) ;
}
int P1a2( int n0 , int n1 ) {
  return (1<<(6*n1+6))*(3*n0+0) + (1<<(6*n1+5)) + S2(3*n1+2) ;
}
int P1b1( int n0 , int n1 ) {
  return (1<<(6*n1+2))*(3*n0+1) + (1<<(6*n1+1)) + S2(3*n1+0) ;
}
int P1b2( int n0 , int n1 ) {
  return (1<<(6*n1+4))*(3*n0+1) + (1<<(6*n1+3)) + S2(3*n1+1) ;
}
int P1c1( int n0 , int n1 ) {
  return (1<<(6*n1+2))*(3*n0+2) + (1<<(6*n1+1)) + S2(3*n1+0) ;
}
int P1c2( int n0 , int n1 ) {
  return (1<<(6*n1+6))*(3*n0+2) + (1<<(6*n1+5)) + S2(3*n1+2) ;
}

int P2a1( int n0 , int n1 ) {
  return (1<<(6*n1+3))*(3*n0+0) + S2(3*n1+0) ;
}
int P2a2( int n0 , int n1 ) {
  return (1<<(6*n1+5))*(3*n0+0) + S2(3*n1+1) ;
}
int P2b1( int n0 , int n1 ) {
  return (1<<(6*n1+5))*(3*n0+1) + S2(3*n1+1) ;
}
int P2b2( int n0 , int n1 ) {
  return (1<<(6*n1+7))*(3*n0+1) + S2(3*n1+2) ;
}
int P2c1( int n0 , int n1 ) {
  return (1<<(6*n1+3))*(3*n0+2) + S2(3*n1+0) ;
}
int P2c2( int n0 , int n1 ) {
  return (1<<(6*n1+7))*(3*n0+2) + S2(3*n1+2) ;
}

typedef int (*fct)(int,int);

ostream * _Trace ;

void Compute( char * fctname , fct afct , int PT , int PP , int PPNext ) {
  int n0 ;
  int n1 ;
  long value = 0 ;
  long next = 0 ;
  for ( n1 = 0 ; n1 <= 3 ; n1++ ) {
    bool pn1 = true ;
    for ( n0 = 0 ; n0 <= 500 && value < 3000 ; n0++ ) {
      value = afct( n0 , n1 ) ;
      long pow2 ;
      next = Next( value , pow2 ) ;
      long kp2 ;
      if ( ( rP( value ) == 3 && rP( Next( next , kp2 ) ) == PPNext ) ||
             ( rT( value ) == PT && rP( value ) == PP &&
               rP( next ) == PPNext ) ) {
        if ( rQ( value ) == 3 ||
             ( rQ( value ) == 1 && ( nQ( value ) & 1 ) == 0 ) ) {
//          if ( pn1 ) {
//            *_Trace << "  n1 " << n1 ;
//            *_Trace << " n0 " << n0 << " " ;
//            pn1 = false ;
//          }
//          else {
            if ( value < 10 )
              *_Trace << "000" ;
            else if ( value < 100 )
              *_Trace << "00" ;
            else if ( value < 1000 )
              *_Trace << "0" ;
            *_Trace << value << " " ;
            long lownext = (next-1)/4 ;
            if ( 4*lownext+1 == next && ( lownext & 1 ) == 1 ) {
              *_Trace << "---" ;
	    }
            *_Trace << fctname << " n0 " << n0 << " " ;
//          }
          *_Trace << value << " = 6[3*" << nT( value ) << "+"
                  << rT( value ) << "]+" << rP( value ) << " --> "
                  << next << " (>>" << pow2 << ") = 6[3*"
                  << nT( next ) << "+" << rT( next )
                  << "] + " << rP( next ) << endl ;
	}
#if 0
        else {
          if ( pn1 ) {
            *_Trace << "  n1 " << n1 ;
            *_Trace << " n0 " << n0 << " " ;
            pn1 = false ;
          }
          else {
            *_Trace << "       n0 " << n0 << " " ;
          }
          *_Trace << "---" << value << " = 6[3*" << nT( value ) << "+"
                  << rT( value ) << "]+" << rP( value ) << " = 4*["
                  << "2*" << nQ( value )/2 << "+1]+1" ;
          if ( Next( (value-1)/4 , kp2 ) != next )
            *_Trace << " " << Next( (value-1)/4 , kp2 ) << " != " << next ;
          *_Trace << endl ;
	}
#endif
      }
    }
    value = 0 ;
  }
}

int SeqSyr( int n ) {
  long pow2 ;
  int nstep = 0 ;
  int EQ ;
  int r ;
  int q ;
  int Sr ;
  int Sq ;
  int nn = n ;
  *_Trace << "   " << n ;
  while ( n != 1 ) {
    n = Next( n , pow2 ) ;
    nstep += 1 ;
    int EQ ;
    r = rQ( n ) ;
    q = nQ( n ) ;
    if ( r == 3 ) {
      EQ = 4 ;
    }
    else {
      EQ = 8 ;
    }
    if ( ( nstep % 2 ) == 0 ) {
      *_Trace << endl << "   " ;
    }
    Sr = rP( n ) ;
    Sq = nP( n ) ;
    *_Trace << " -> " << n << " = " << EQ << "*" << q << "+" << r
            << " = 6*" << Sq << "+" << Sr ;
    if ( r == 5 ) {
      break ;
    }
  }
  *_Trace << endl ;
  if ( r == 5 && q > nn/8 ) {
    return n ;
  }
  return 0 ;
}

void little( int depth , int prt , int n , int r ) {

  int n0 ;
  int r0 ;
  int n1 ;
  int r1 ;
  int r2 ;
  depth += 1 ;

  if ( depth == prt )
    *_Trace << endl << depth << " little2 n = " << n << " r = " << r << endl ;

  n0 = n*2 ;
  r0 = r*2 - 1 ;
  if ( ( r0 % 3 ) == 0 ) {
    r1 = r0/3 ;
    if ( depth == prt ) {
      *_Trace << "n->3n " << n0 << "n + " << r1 << " = 4[ "
              << n0/4 << "n + " << r1/4 << " ]+3" << endl ;
      SeqSyr( r1 ) ;
    }
  }
  else if ( ( ( n0 + r0 ) % 3 ) == 0 ) {
    r1 = ( n0 + r0 ) / 3 ;
    if ( depth == prt ) {
      *_Trace << "n->3n+1 " << n0 << "n + " << r1 << " = 4[ "
              << n0/4 << "n + " << r1/4 << " ]+3" << endl ;
      SeqSyr( r1 ) ;
    }
  }
  else if ( ( ( 2*n0 + r0 ) % 3 ) == 0 ) {
    r1 = ( 2*n0 + r0 ) / 3 ;
    if ( depth == prt ) {
      *_Trace << "n->3n+2 " << n0 << "n + " << r1 << " = 4[ "
              << n0/4 << "n + " << r1/4 << " ]+3" << endl ;
      SeqSyr( r1 ) ;
    }
  }

  if ( depth == prt )
    *_Trace << endl << depth << " little4 n = " << n << " r = " << r << endl ;

  n1 = n0*2 ;
  r2 = r0*2 + 1 ;
  if ( ( r2 % 3 ) == 0 ) {
    r2 = r2/3 ;
    if ( depth == prt ) {
      *_Trace << "n->3n " << n1 << "n + " << r2 << " = 8[ "
              << n1/8 << "n + " << r2/8 << " ]+1" << endl ;
      SeqSyr( r2 ) ;
    }
  }
  else if ( ( ( n1 + r2 ) % 3 ) == 0 ) {
    r2 = ( n1 + r2 ) / 3 ;
    if ( depth == prt ) {
      *_Trace << "n->3n+1 " << n1 << "n + " << r2 << " = 8[ "
              << n1/8 << "n + " << r2/8 << " ]+1" << endl ;
      SeqSyr( r2 ) ;
    }
  }
  else if ( ( ( 2*n1 + r2 ) % 3 ) == 0 ) {
    r2 = ( 2*n1 + r2 ) / 3 ;
    if ( depth == prt ) {
      *_Trace << "n->3n+2 " << n1 << "n + " << r2 << " = 8[ "
              << n1/8 << "n + " << r2/8 << " ]+1" << endl ;
      SeqSyr( r2 ) ;
    }
  }

  if ( depth < prt ) {
    little( depth , prt , n0 , r1 ) ;
    little( depth , prt , n1 , r2 ) ;
  }

}

int main(int argc, char **argv) {

  int k ;
  int i ;
  int j ;
  int l ;
  int l1 ;
  int n = 0 ;
  int p ;
  int P ;
  int Prem = 37 ;

  _Trace = new ofstream( "/cas_01/jr/linux/SyrP.log" );

  for ( l = 0 ; l <= 17 ; l++ ) {
    for ( l1 = -1 ; l1 <= 1 ; l1 += 2 ) {
      P = 6*l + l1 ;
      if ( P > 0 && NextPrime( P-1 ) == P ) {
        for ( k = -1 ; k <= 1 ; k += 2 ) {
          for ( i = 1 ; i <= 30 ; i++ ) {
            for ( j = 1 ; j <= 30 ; j++ ) {
              n = int( pow( (double)2 , (double)i ) * pow( (double)3 , (double)j )*P ) + k ;
              if ( n < 0 || n > pow( (double)2 , (double)30 ) ) {
                break ;
              }
              if ( NextPrime( n-1 ) == n ) {
                *_Trace << n << " = 2**" << i << " * 3**" << j << " * " << P << " + "
                        << k << endl ;
              }
#if 0
              if ( NextPrime( n-1 ) != n && ( n % P ) == 0 ) {
                *_Trace << n << " = 2**" << i << " * 3**" << j << " * " << P << " + "
                        << k << " = " ;
                p = 5 ;
                while ( p*p <= n ) {
                  while ( ( n % p ) == 0 ) {
                    *_Trace << p << "*" ;
                    n = n / p ;
	          }
                  p = NextPrime( p + 1 ) ;
	        }
                *_Trace << n << endl ;
              }
#endif
            }
            *_Trace << endl ;
          }
	}
      }
      *_Trace << endl ;
    }
  }

#if 0
  _Trace = new ofstream( "/cas_01/jr/linux/Syr.log" );

  int n = 1 ;
  int prt ;

#if 0
  for ( prt = 1 ; prt <= 5 ; prt++ ) {
    *_Trace << endl << prt << ". 8n + 1 :" << endl ;
    little( 0 , prt , 8 , 1 ) ;
  }

  for ( prt = 1 ; prt <= 5 ; prt++ ) {
    *_Trace << endl << prt << ". 4n + 3 :" << endl ;
    little( 0 , prt , 4 , 3 ) ;
  }

  for ( prt = 1 ; prt <= 6 ; prt++ ) {
    *_Trace << endl << prt << ". 8n + 5 :" << endl ;
    little( 0 , prt , 8 , 5 ) ;
  }
#endif

  int i ;
  int max = 256 ;
  for ( i = 0 ; i <= max ; i++ ) {
    *_Trace << endl << endl << "8*" << i << "+5 = 4[2*" << i << "+1]+1 = " ;
    int ii = 2*i+1 ;
    while ( ((ii-1) & 7) == 4 ) {
      *_Trace << endl << "        8*" << ii/8 << "+5 = 4[2*" << ii/4
              << "+1]+1 = " ;
      ii = 2*(ii/4)+1 ;
    }
    *_Trace << "6*" << nP(8*i + 5) << "+" << rP(8*i + 5) << " :" << endl ;
    n = SeqSyr( 8*i + 5 ) ;
    n = n/8 ;
    while ( n && n > max ) {
      *_Trace << endl << "   ==> 8*" << n << "+5 = 4[2*" << n << "+1]+1 = " ;
      int ii = 2*n+1 ;
      while ( ((ii-1) & 7) == 4 ) {
        *_Trace << endl << "8*" << ii/8 << "+5 = 4[2*" << ii/4 << "+1]+1 = " ;
        ii = 2*(ii/4)+1 ;
      }
      *_Trace << "6*" << nP(8*n + 5) << "+" << rP(8*n + 5) << " :" << endl ;
      n = SeqSyr( 8*n + 5 ) ;
      n = n/8 ;
    }
  }

#if 0
  int x ;
  int rx ;
  int a ;
  int q ;
  int r ;
  int X ;
  int n ;
  int rn ;
  int xx ;
  int y ;
  int p ;
  int pow ;

  *_Trace << "2**[x(n+1)] = (2**x-1)*S[x](n)+1" << endl << endl ;

  *_Trace << "2**[(2x+1)(2n+rn+1)] = (2**(2x+1)-1)*S[2x+1](2n+rn)+1" << endl ;
  *_Trace << "                     = 2**(2x+1){(2**(2x+1)-1)*S[2x+1](2n+rn)-1}"
          << endl << endl ;
  *_Trace << "2**[2x(3n+rn+1)] = (2**2x-1)*S[2x](3n+rn)+1" << endl ;
  *_Trace << "                 = 2**2x{(2**2x-1)*S[2x](3n+rn-1)-1}"
          << endl << endl ;
  *_Trace << "2**(2x+1)-1 = 6S2(x-1)+1" << endl << endl ;

  *_Trace << "2**(2(3x+1))-1 = 3(6*2*7*S6(x-1)+1) *4 :" << endl ;
  *_Trace << "2**(2(3x+2))-1 = 3(6*2**3*7*S6(x-1)+5) *4 :" << endl ;
  *_Trace << "2**(2(3x+3))-1 = 3(6*2**5*7*S6(x-1)+21)" << endl ;
  *_Trace << "               = 3**2(2**6*7*S6(x-1)+7)" << endl ;
  *_Trace << "               = 3**2*7(2**6*S6(x-1)+1)" << endl ;
  *_Trace << "               = 3**2*7*S6(x)" << endl ;
  *_Trace << "2**(2(3x))-1 = 3**2*7*S6(x-1)" << endl ;
  *_Trace << "2**(2(3x+4))-1 = 3(6*2*7*S6(x)+1) *4 :" << endl ;
  *_Trace << "2**(2(3x+5))-1 = 3(6*2**3*7*S6(x)+5)" << endl << endl ;
  *_Trace << "2**(2(3x+rx))-1 = 3**2*2**(2rx)*7*S6(x-1)+2**(2rx)-1" << endl
          << endl ;

  *_Trace << "2**[(2x+1)(2n+rn+1)] = (6S2(x-1)+1)*S[2x+1](2n+rn)+1" << endl ;
  *_Trace << "2**[2(3x+rx)(3n+rn+1)] = {3**2*2**(2rx)*7*S6(x-1)+2**(2rx)-1}*"
          << endl << "                 S[2(3x+rx)](3n+rn)+1" << endl
          << endl ;

  *_Trace << "(6x+5)y+x = 2**3*7*S6(x-1)" << endl ;
  *_Trace << "x = 0 ; y = 0" << endl ;
  *_Trace << "x = 1 ; y = 5" << endl ;
  *_Trace << "x = 2 ; y = 214 = 2*107 = 2*O153" << endl ;
  *_Trace << "x = 3 ; y = 10131 = 3*3377 = 3*O6461" << endl ;
  *_Trace << "x = 4 ; y = 514244 = 4*128561 = 4*O373061" << endl ;
  *_Trace << "x = 5 ; y = ?" << endl ;
  *_Trace << "x = 6 ; y = 1489853154 = 6*248308859 = 6*O1663162173" << endl
          << endl ;

  for ( pow = 1 ; pow <= 31 ; pow++ ) {
    *_Trace << endl ;
    for ( x = 0 ; x <= 30 ; x++ ) {
      for ( n = 0 ; n <= 30 ; n++ ) {
        for ( rn = 0 ; rn <= 1 ; rn++ ) {
          if ( (2*x+1)*(2*n+rn+1) == pow && (2*x+1)*(2*n+rn+1) <= 31 ) {
            int val = (1 << (2*x+1)*(2*n+rn+1)) ;
            *_Trace << "2**(" << 2*x+1 << "*(" << 2*n+rn << "+1)) = " ;
            *_Trace << "2**[(2*" << x << "+1)(2*" << n << "+" << rn
                    << "+1)] = (6*" ;
            int SIG = S(2,x-1) ;
            int pow3 = 0 ;
            while ( SIG && (SIG % 3) == 0 ) {
              pow3 += 1 ;
              SIG = SIG/3 ;
	    }
            *_Trace << "3**" << pow3 << "*" << SIG
                    << "+1) * " << fact( S(2*x+1,2*n+rn) )
                    << " + 1 = " << endl
                    << "      (6*S2(" << x-1 << ")+1)*S" << 2*x+1 << "("
                    << 2*n+rn << ")+1 = "
                    << "(6*S2(" << x << "-1)+1)*S[2*" << x << "+1](2*"
                    << n << "+" << rn << ")+1 = " << val << endl ;
            if ( val != (6*S(2,x-1)+1)*S(2*x+1,2*n+rn)+1 ) {
              *_Trace << val << " != " << (6*S(2,x-1)+1)*S(2*x+1,2*n+rn)+1
                      << endl ;
	    }
	  }
        }
      }
    }
    for ( x = 0 ; x <= 30 ; x++ ) {
      for ( rx = 0 ; rx <= 2 ; rx++ ) {
        for ( n = 0 ; n <= 30 ; n++ ) {
          for ( rn = 0 ; rn <= 2 ; rn++ ) {
            if ( 3*x+rx != 0 && 2*(3*x+rx)*(3*n+rn+1) == pow
                 && 2*(3*x+rx)*(3*n+rn+1) <= 31 ) {
              *_Trace << "2**[" << 2*(3*x+rx) << "*(" << 3*n+rn << "+1)] = " ;
              *_Trace << "2**[2(3*" << x << "+" << rx << ")(3*" << n << "+"
                      << rn << "+1)] = [9*" << (1 << (2*rx)) << "*7*"
                      << S(6,x-1) << "+" ;
              int DRX = (1 << (2*rx))-1 ;
              int pow3 = 0 ;
              while ( DRX && (DRX % 3) == 0 ) {
                pow3 += 1 ;
                DRX = DRX/3 ;
	      }
              *_Trace << "3**" << pow3 << "*" << DRX << "] * " ;
              int SIG = S(2*(3*x+rx),3*n+rn) ;
              pow3 = 0 ;
              while ( SIG && (SIG % 3) == 0 ) {
                pow3 += 1 ;
                SIG = SIG/3 ;
	      }
              *_Trace << "3**" << pow3 << "*" << fact( SIG )
                      << " + 1 = " << endl
                      << "   [3**2*2**" << 2*rx << "*7*S6("
                      << x << "-1)+" << (1 << (2*rx))-1 << "] * S"
                      << 2*(3*x+rx) << "(" << 3*n+rn << ")+1 = " << endl
                      << "      {3**2*2**(2*" << rx << ")*7*S6("
                      << x << "-1)+2**(2*" << rx << ")-1} * S[2(3*"
                      << x << "+" << rx << ")](3*" << n << "+" << rn << ")+1"
                      << endl ;
              int val = (1 << (2*(3*x+rx)*(3*n+rn+1)) ) ;
              if ( val != (3*3*(1<<(2*rx))*7*S(6,x-1)+(1<<(2*rx))-1)*S(2*(3*x+rx),3*n+rn)+1 ) {
                *_Trace << val << " != " << (3*3*(1<<(2*rx))*7*S(6,x-1)+(1<<(2*rx))-1) * S(2*(3*x+rx),3*n+rn)+1 << endl ;
	      }
	    }
	  }
        }
      }
    }
  }
  return 0;


  *_Trace << endl ;
  for ( x = 1 ; x <= 30 ; x++ ) {
    for ( n = 0 ; n <= 30 ; n++ ) {
      if ( x*(n+1) <= 30 ) {
        X = ((1 << x ) - 1)*S(x,n) + 1 ;
        if ( (1 << (x*(n+1)) ) == X ) {
          *_Trace << "2**[" << x << "(" << n << "+1)] = 2**[[" ;
          int pow2 = 0 ;
          int pow3 = 0 ;
          int p ;
          p = x ;
          while ( p && (p & 1) == 0 ) {
            pow2 += 1 ;
            p = (p >> 1 ) ;
	  }
          while ( p && (p % 3) == 0 ) {
            pow3 += 1 ;
            p = p/3 ;
	  }
          if ( pow2 ) {
            *_Trace << "2" ;
            if ( pow2 != 1 ) {
              *_Trace << "**" << pow2 ;
	    }
            if ( pow3 || p != 1 ) {
              *_Trace << "*" ;
	    }
	  }
          if ( pow3 ) {
            *_Trace << "3" ;
            if ( pow3 != 1 ) {
              *_Trace << "**" << pow3 ;
	    }
            if ( p != 1 ) {
              *_Trace << "*" ;
	    }
	  }
          if ( !((pow2 || pow3) && p == 1) ) {
            *_Trace << p ;
	  }
          *_Trace << "][" ;
          p = n+1 ;
          pow2 = 0 ;
          pow3 = 0 ;
          while ( p && (p & 1) == 0 ) {
            pow2 += 1 ;
            p = (p >> 1 ) ;
	  }
          while ( p && (p % 3) == 0 ) {
            pow3 += 1 ;
            p = p/3 ;
	  }
          if ( pow2 ) {
            *_Trace << "2" ;
            if ( pow2 != 1 ) {
              *_Trace << "**" << pow2 ;
	    }
            if ( pow3 || p != 1 ) {
              *_Trace << "*" ;
	    }
	  }
          if ( pow3 ) {
            *_Trace << "3" ;
            if ( pow3 != 1 ) {
              *_Trace << "**" << pow3 ;
	    }
            if ( p != 1 ) {
              *_Trace << "*" ;
	    }
	  }
          if ( !((pow2 || pow3) && p == 1) ) {
            *_Trace << p ;
	  }
          *_Trace << "]]" ;
          int d = (1 << x) - 1 ;
          pow3 = 0 ;
          while ( (d % 3) == 0 ) {
            pow3 += 1 ;
            d = d / 3 ;
	  }
          *_Trace << " = (2**" << x << "-1)*S" ;
          if ( x & 1 ) {
            *_Trace << x << "[2*" << n/2 ;
            if ( n & 1 ) {
              *_Trace << "+1" ;
	    }
            *_Trace << "]+1 = " ;
	  }
          else {
            *_Trace << x << "[3*" << n/3 << "+" << (n % 3) << "]+1 = " ;
	  }
          *_Trace << "{" ;
          if ( pow3 ) {
            *_Trace << "3" ;
            if ( pow3 != 1 ) {
              *_Trace << "**" << pow3 ;
	    }
            *_Trace << "*" ;
	  }
          if ( d == 1 ) {
	  }
          else if ( d == 5 ) {
            *_Trace << "[5]" ;
	  }
          else {
            if ( nP(d) ) {
              *_Trace << "[6*" << nP(d) << "+" << rP(d) << "]" ;
	    }
            else {
              *_Trace << "[" << rP(d) << "]" ;
	    }
	  }
          *_Trace << "}*{" ;
          int Y = S(x,n) ;
          pow2 = 0 ;
          while ( (Y % 2) == 0 ) {
            pow2 += 1 ;
            Y = Y / 2 ;
	  }
          pow3 = 0 ;
          while ( (Y % 3) == 0 ) {
            pow3 += 1 ;
            Y = Y / 3 ;
	  }
          if ( pow2 ) {
            *_Trace << "2" ;
            if ( pow2 != 1 ) {
              *_Trace << "**" << pow2 ;
	    }
            *_Trace << "*" ;
	  }
          if ( pow3 ) {
            *_Trace << "3" ;
            if ( pow3 != 1 ) {
              *_Trace << "**" << pow3 ;
	    }
            *_Trace << "*" ;
	  }
          if ( nP(Y) && ( (nP(Y) & 1) == 0 || (nP(Y) % 3) == 0 ) ) {
            *_Trace << "[6*" ;
            int YY = nP(Y) ;
            pow2 = 0 ;
            while ( (YY % 2) == 0 ) {
              pow2 += 1 ;
              YY = YY / 2 ;
	    }
            pow3 = 0 ;
            while ( (YY % 3) == 0 ) {
              pow3 += 1 ;
              YY = YY / 3 ;
	    }
            if ( pow2 ) {
              *_Trace << "2" ;
              if ( pow2 != 1 ) {
                *_Trace << "**" << pow2 ;
	      }
              *_Trace << "*" ;
	    }
            if ( pow3 ) {
              *_Trace << "3" ;
              if ( pow3 != 1 ) {
                *_Trace << "**" << pow3 ;
	      }
              *_Trace << "*" ;
	    }
            *_Trace << YY << "+" << rP(Y) << "]}+1" << endl ;
	  }
          else {
            if ( nP(Y) ) {
              *_Trace << "[6*" << nP(Y) << "+" << rP(Y) << "]}+1" << endl ;
	    }
            else {
              *_Trace << "[" << rP(Y) << "]}+1" << endl ;
	    }
	  }
        }
        else {
          *_Trace << endl << (1 << (x*(n+1)) ) << " = 2**[" << x << "(" << n
                  << "+1)] != " << X << "(2**" << x
                  << "-1)*S" << x << "[" << n << "]+1" << endl ;
	}
      }
    }
  }
  return 0;

  *_Trace << "S[x]( n ) = Sigma((2**x)*i) i = 0 , n" << endl ;
  *_Trace << "S[x]( aq + r ) = X*S[a*x]( q - 1 ) + Sx( r )" << endl ;
  for ( x = 2 ; x <= 10 ; x++ ) {
    *_Trace << endl << endl ;
    for ( a = 2 ; a <= 12 ; a++ ) {
      *_Trace << endl ;
      for ( q = 1 ; q <= 12 ; q++ ) {
        for ( r = 0 ; r < a ; r++ ) {
          if ( a*q + r <= 24 ) {
            int i = S( x , a*q+r ) - S( x , r ) ;
            int X = i / S( a*x , q-1 ) ;
            int p2 = 0 ;
            if ( X*S( a*x , q-1 ) == i && (i % S( a*x , q-1 ) ) == 0 ) {
              while ( ( X & 1 ) == 0 ) {
                p2 += 1 ;
                X = ( X >> 1 ) ;
	      }
              int p3 = 0 ;
              while ( X > 0 && ( X % 3 ) == 0 ) {
                p3 += 1 ;
                X = ( X / 3 ) ;
	      }
              *_Trace << "S( " << x << " , " << a << "*" << q << " + " << r
                      << " ) = 2**" << p2 << "*3**" << p3 << "*"<< X
                      << "*S[" << a << "*" << x << "]( " << q << "-1 ) + S( "
                      << x << " , " << r << " )" << endl ;
	    }
	  }
	}
      }
    }
  }
  return 0;

  int PT ;
  int PP ;
  int PPNext ;
  for ( PP = 1 ; PP <= 5 ; PP+=4 ) {
    for ( PPNext = 1 ; PPNext <= 5 ; PPNext+=4 ) {
      for ( PT = 0 ; PT <= 2 ; PT++ ) {
        if ( PT == 0 && PP == 5 ) {
          *_Trace << endl << "T1a 2**(6n1+2)(3n0) + 2**(6n1+1) + S2(3n1+0) --> 6(3n0+0)+5"
                  << endl ;
          Compute( "T1a" , T1a , PT , PP , PPNext ) ;
        }
        if ( PT == 1 && PP == 1 ) {
          *_Trace << endl << "T2b 2**(6n1+3)(3n0+1) + S2(3n1+0) --> 6(3n0+1)+1"
                  << endl ;
          Compute( "T2b" , T2b , PT , PP , PPNext ) ;
        }
        if ( PT == 0 && PP == 1 ) {
          *_Trace << endl << "T2a 2**(6n1+7)(3n0) + S2(3n1+2) --> 6(3n0+0)+1"
                  << endl ;
          Compute( "T2a" , T2a , PT , PP , PPNext ) ;
        }
        if ( PT == 2 && PP == 5 ) {
          *_Trace << endl << "T1c 2**(6n1+4)(3n0+2) + 2**(6n1+3) + S2(3n1+1) --> 6(3n0+2)+5"
                  << endl ;
          Compute( "T1c" , T1c , PT , PP , PPNext ) ;
        }
        if ( PT == 2 && PP == 1 ) {
          *_Trace << endl << "T2c 2**(6n1+5)(3n0+2) + S2(3n1+1) --> 6(3n0+2)+1"
                  << endl ;
          Compute( "T2c" , T2c , PT , PP , PPNext ) ;
        }
        if ( PT == 1 && PP == 5 ) {
          *_Trace << endl << "T1b 2**(6n1+6)(3n0+1) + 2**(6n1+5) + S2(3n1+2) --> 6(3n0+1)+5"
                  << endl ;
          Compute( "T1b" , T1b , PT , PP , PPNext ) ;
        }

//      for ( PPNext = 1 ; PPNext <= 5 ; PPNext+=4 ) {
        *_Trace << endl << "P2a1 (1<<(6*n1+3))*(3*n0+0) + S2(3*n1+0) --> 6(3n0+0)+1"
                << endl ;
        Compute( "P2a1" , P2a1 , PT , PP , PPNext ) ;

        *_Trace << endl << "P2a2 (1<<(6*n1+5))*(3*n0+0) + S2(3*n1+1) --> 6(3n0+0)+1"
                << endl ;
        Compute( "P2a2" , P2a2 , PT , PP , PPNext ) ;

        *_Trace << endl << "P1b1 (1<<(6*n1+2))*(3*n0+1) + (1<<(6*n1+1)) + S2(3*n1+0) --> 6(3n0+1)+5"
                << endl ;
        Compute( "P1b1" , P1b1 , PT , PP , PPNext ) ;

        *_Trace << endl << "P1c1 (1<<(6*n1+2))*(3*n0+2) + (1<<(6*n1+1)) + S2(3*n1+0) --> 6(3n0+2)+5"
                << endl ;
        Compute( "P1c1" , P1c1 , PT , PP , PPNext ) ;

        *_Trace << endl << "P1a1 (1<<(6*n1+4))*(3*n0+0) + (1<<(6*n1+3)) + S2(3*n1+1) --> 6(3n0+0)+5"
                << endl ;
        Compute( "P1a1" , P1a1 , PT , PP , PPNext ) ;

        *_Trace << endl << "P2c1 (1<<(6*n1+3))*(3*n0+2) + S2(3*n1+0) --> 6(3n0+2)+1"
                << endl ;
        Compute( "P2c1" , P2c1 , PT , PP , PPNext ) ;

        *_Trace << endl << "P1b2 (1<<(6*n1+4))*(3*n0+1) + (1<<(6*n1+3)) + S2(3*n1+1) --> 6(3n0+1)+5"
                << endl ;
        Compute( "P1b2" , P1b2 , PT , PP , PPNext ) ;

        *_Trace << endl << "P2b1 (1<<(6*n1+5))*(3*n0+1) + S2(3*n1+1) --> 6(3n0+1)+1"
                << endl ;
        Compute( "P2b1" , P2b1 , PT , PP , PPNext ) ;

        *_Trace << endl << "P1a2 (1<<(6*n1+6))*(3*n0+0) + (1<<(6*n1+5)) + S2(3*n1+2) --> 6(3n0)+5"
                << endl ;
        Compute( "P1a2" , P1a2 , PT , PP , PPNext ) ;

        *_Trace << endl << "P2b2 (1<<(6*n1+7))*(3*n0+1) + S2(3*n1+2) --> 6(3n0+1)+1"
                << endl ;
        Compute( "P2b2" , P2b2 , PT , PP , PPNext ) ;

        *_Trace << endl << "P1c2 (1<<(6*n1+6))*(3*n0+2) + (1<<(6*n1+5)) + S2(3*n1+2) --> 6(3n0+2)+5"
                << endl ;
        Compute( "P1c2" , P1c2 , PT , PP , PPNext ) ;

        *_Trace << endl << "P2c2 (1<<(6*n1+7))*(3*n0+2) + S2(3*n1+2) --> 6(3n0+2)+1"
                << endl ;
        Compute( "P2c2" , P2c2 , PT , PP , PPNext ) ;
      }

    }
  }
#endif

#endif

  return 0;
}

