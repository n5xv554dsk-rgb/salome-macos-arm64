      subroutine decpt0 ( decare, decfac,
     >                    hettri, hetqua,
     >                    tritet, hettet,
     >                    quahex, hethex,
     >                    facpyr, hetpyr,
     >                    facpen, hetpen,
     >                    narde2, narra2,
     >                    ntrde4, ntrra4,
     >                    nqude4, nqura4,
     >                    ntede8, ntera8,
     >                    nhede8, nhera8,
     >                    npyder, npyraf,
     >                    npeder, nperaf,
     >                    ulsort, langue, codret )
c
c ______________________________________________________________________
c
c                             H O M A R D
c
c Outil de Maillage Adaptatif par Raffinement et Deraffinement d'EDF R&D
c
c Version originale enregistree le 18 juin 1996 sous le numero 96036
c aupres des huissiers de justice Simart et Lavoir a Clamart
c Version 11.2 enregistree le 13 fevrier 2015 sous le numero 2015/014
c aupres des huissiers de justice
c Lavoir, Silinski & Cherqui-Abrahmi a Clamart
c
c    HOMARD est une marque deposee d'Electricite de France
c
c Copyright EDF 1996
c Copyright EDF 1998
c Copyright EDF 2002
c Copyright EDF 2020
c ______________________________________________________________________
c
c traitement des DEcisions - ComPTage - phase 0
c                --          -  --            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . decare . e   .0:nbarto. decisions des aretes                       .
c . decfac . e   . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . narde2 .  s  . 1      . nb d'aretes avec decision de deraffinement .
c . narra2 .  s  . 1      . nb d'aretes avec decision de raffinement   .
c . ntrde4 .  s  . 1      . nb de triangles avec decision de deraffinem.
c . ntrra4 .  s  . 1      . nb de triangles avec decision de raffinemen.
c . ntede8 .  s  . 1      . nb de tetraedres avec decision de deraffine.
c . ntera8 .  s  . 1      . nb de tetraedres avec decision de raffinem .
c . nhede8 .  s  . 1      . nb d'hexaedres avec decision de deraffine  .
c . nhera8 .  s  . 1      . nb de hexaedres avec decision de raffinem  .
c . npyder .  s  . 1      . nb de pyramides avec decision de deraffine .
c . npyraf .  s  . 1      . nb de pyramides avec decision de raffinem  .
c . npeder .  s  . 1      . nb de pentaedres avec decision de deraffine.
c . nperaf .  s  . 1      . nb de pentaedres avec decision de raffinem .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c 0.1. ==> generalites
c
      implicit none
      save
c
      character*6 nompro
      parameter ( nompro = 'DECPT0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer hettri(nbtrto)
      integer hetqua(nbquto)
      integer hettet(nbteto), tritet(nbtecf,4)
      integer hethex(nbheto), quahex(nbhecf,6)
      integer hetpyr(nbpyto), facpyr(nbpycf,5)
      integer hetpen(nbpeto), facpen(nbpecf,5)
      integer narde2, narra2
      integer ntrde4, ntrra4
      integer nqude4, nqura4
      integer ntede8, ntera8
      integer nhede8, nhera8
      integer npyder, npyraf
      integer npeder, nperaf
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer larete, letria, lequad, letetr, lehexa, lapyra, lepent
      integer dt, etat
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      codret = 0
c
#include "impr03.h"
c
c====
c 2. decompte des entites a decouper et a supprimer et impressions
c====
c
c 2.1. ==> rien a priori
c
      ntera8 = 0
      nhera8 = 0
      nqura4 = 0
      ntrra4 = 0
      narra2 = 0
      ntede8 = 0
      nhede8 = 0
      nqude4 = 0
      ntrde4 = 0
      narde2 = 0
      npyraf = 0
      npyder = 0
      nperaf = 0
      npeder = 0
c
c 2.2. ==> les indications portent sur les tetraedres
c
      if ( nbteto.ne.0 ) then
c
        do 22 , letetr = 1, nbteto
c
          dt = decfac(tritet(letetr,1)) + decfac(tritet(letetr,2))
     >       + decfac(tritet(letetr,3)) + decfac(tritet(letetr,4))
c
          etat = mod ( hettet(letetr) , 100 )
c
          if ( etat.eq.0 ) then
c
            dt = dt + mod( hettri(tritet(letetr,1)) , 10 )
     >              + mod( hettri(tritet(letetr,2)) , 10 )
     >              + mod( hettri(tritet(letetr,3)) , 10 )
     >              + mod( hettri(tritet(letetr,4)) , 10 )
c
          endif
c
          if ( dt.eq.16 ) then
            ntera8 = ntera8 + 1
          elseif ( (dt.eq.-3) .or. (dt.eq.-4) ) then
            ntede8 = ntede8 + 1
cgn          if ( letetr.eq.58 ) then
cgn      write (ulsort,90015) 'tetr', letetr, ' faces, etat/dt',
cgn     > tritet(letetr,1),tritet(letetr,2),
cgn     > tritet(letetr,3),tritet(letetr,4),etat, dt
cgn      write (ulsort,90015) 'tetr', letetr, ' deci f',
cgn     > decfac(tritet(letetr,1)),decfac(tritet(letetr,2)),
cgn     > decfac(tritet(letetr,3)),decfac(tritet(letetr,4))
cgn          endif
          endif
c
   22   continue
c
      endif
c
c 2.3. ==> les indications portent sur les pyramides
c
      if ( nbpyto.ne.0 ) then
c
        do 23 , lapyra = 1, nbpyto
c
          dt = decfac(facpyr(lapyra,1)) + decfac(facpyr(lapyra,2))
     >       + decfac(facpyr(lapyra,3)) + decfac(facpyr(lapyra,4))
     >       + decfac(-facpyr(lapyra,5))
cgn      write(ulsort,90002) lapyra,dt
cgn      if ( dt.ne.0 ) then
cgn      print *,'   ',facpyr(lapyra,1),decfac(facpyr(lapyra,1))
cgn      print *,'   ',facpyr(lapyra,2),decfac(facpyr(lapyra,2))
cgn      print *,'   ',facpyr(lapyra,3),decfac(facpyr(lapyra,3))
cgn      print *,'   ',facpyr(lapyra,4),decfac(facpyr(lapyra,4))
cgn      print *,'   ',facpyr(lapyra,5),decfac(-facpyr(lapyra,5))
cgn      endif
c
          etat = mod ( hetpyr(lapyra) , 100 )
c
          if ( etat.eq.0 ) then
c
            dt = dt + mod( hettri(facpyr(lapyra,1)) , 10 )
     >              + mod( hettri(facpyr(lapyra,2)) , 10 )
     >              + mod( hettri(facpyr(lapyra,3)) , 10 )
     >              + mod( hettri(facpyr(lapyra,4)) , 10 )
     >              + mod( hetqua(facpyr(lapyra,5)) , 100 )
c
          endif
c
          if ( dt.eq.20 ) then
            npyraf = npyraf + 1
          elseif ( (dt.eq.-3) .or. (dt.eq.-4) ) then
            npyder = npyder + 1
          endif
c
   23   continue
c
      endif
c
c 2.4. ==> les indications portent sur les hexaedres
c
      if ( nbheto.ne.0 ) then
c
        do 24 , lehexa = 1, nbheto
cgn      if ( (lehexa.eq.57693) .or. (lehexa.eq.60646) ) then
cgn        write(ulsort,90112)'hethex', lehexa, hethex(lehexa)
cgn      do 241 , iaux=1,6
cgn        write(ulsort,90112)' decfac', quahex(lehexa,iaux),
cgn     >               decfac(-quahex(lehexa,iaux))
cgn  241 continue
cgn      endif
c
          dt = decfac(-quahex(lehexa,1)) + decfac(-quahex(lehexa,2))
     >       + decfac(-quahex(lehexa,3)) + decfac(-quahex(lehexa,4))
     >       + decfac(-quahex(lehexa,5)) + decfac(-quahex(lehexa,6))
c
          etat = mod (hethex(lehexa),1000)
c
          if ( etat.eq.0 ) then
c
            dt = dt + mod( hetqua(quahex(lehexa,1)) , 100 )
     >              + mod( hetqua(quahex(lehexa,2)) , 100 )
     >              + mod( hetqua(quahex(lehexa,3)) , 100 )
     >              + mod( hetqua(quahex(lehexa,4)) , 100 )
     >              + mod( hetqua(quahex(lehexa,5)) , 100 )
     >              + mod( hetqua(quahex(lehexa,6)) , 100 )
c
          endif
c
          if ( dt.eq.24 ) then
cgn        write(ulsort,90112)'raff. hethex', lehexa, hethex(lehexa)
            nhera8 = nhera8 + 1
          elseif ( (dt.eq.-4) .or. (dt.eq.-5) .or. (dt.eq.-6) ) then
cgn        write(ulsort,90112)'reac. hethex', lehexa, hethex(lehexa)
            nhede8 = nhede8 + 1
          endif
c
 24     continue
c
      endif
c
c 2.5. ==> les indications portent sur les pentaedres
c
      if ( nbpeto.ne.0 ) then
c
        do 25 , lepent = 1, nbpeto
c
          dt = decfac(facpen(lepent,1)) + decfac(facpen(lepent,2))
     >       + decfac(-facpen(lepent,3)) + decfac(-facpen(lepent,4))
     >       + decfac(-facpen(lepent,5))
cgn      write(ulsort,90002) lepent,dt
      if ( dt.ne.0 ) then
cgn      print *,'   ',facpen(lepent,1),decfac(facpen(lepent,1))
cgn      print *,'   ',facpen(lepent,2),decfac(facpen(lepent,2))
cgn      print *,'   ',facpen(lepent,3),decfac(-facpen(lepent,3))
cgn      print *,'   ',facpen(lepent,4),decfac(-facpen(lepent,4))
cgn      print *,'   ',facpen(lepent,5),decfac(-facpen(lepent,5))
      endif
c
          etat = mod ( hetpen(lepent) , 100 )
c
          if ( etat.eq.0 ) then
c
            dt = dt + mod( hettri(facpen(lepent,1)) , 10 )
     >              + mod( hettri(facpen(lepent,2)) , 10 )
     >              + mod( hetqua(facpen(lepent,3)) , 100 )
     >              + mod( hetqua(facpen(lepent,4)) , 100 )
     >              + mod( hetqua(facpen(lepent,5)) , 100 )
c
          endif
cgn      write(ulsort,90002)'==> dt final = ',dt
c
          if ( dt.eq.20 ) then
            nperaf = nperaf + 1
          elseif ( dt.eq.-5 ) then
            npeder = npeder + 1
          endif
c
   25   continue
c
      endif
c
c 2.6. ==> bilan sur les triangles
c
      do 26 , letria = 1, nbtrto
        if ( decfac(letria).eq.4 ) then
          ntrra4 = ntrra4 + 1
        elseif ( decfac(letria).eq.-1 ) then
          ntrde4 = ntrde4 + 1
        endif
 26   continue
c
c 2.7. ==> bilan sur les quadrangles
c
      do 27 , lequad = 1, nbquto
        if ( decfac(-lequad).eq.4 ) then
          nqura4 = nqura4 + 1
        elseif ( decfac(-lequad).eq.-1 ) then
          nqude4 = nqude4 + 1
        endif
 27   continue
c
c 2.8. ==> bilan sur les aretes
c
      do 28 , larete = 1, nbarto
        if ( decare(larete).eq.2 ) then
          narra2 = narra2 + 1
        elseif ( decare(larete).eq.-1 ) then
          narde2 = narde2 + 1
        endif
 28   continue
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
