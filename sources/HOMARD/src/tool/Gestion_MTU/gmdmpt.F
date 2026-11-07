      subroutine gmdmpt  ( choix, gmimp )
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
c     sous programme d'impression de toutes les tables servant
c     a la gestion des objets structures en memoire centrale
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   . ent    . type d'impression                          .
c .        .     .        . 1 : le dictionnaire des structures         .
c .        .     .        . 2 : les objets structures presents         .
c . gmimp  . e   .    1   . 0 => pas d'impression                      .
c .        .     .        . <=2 => impression simple                   .
c .        .     .        . >2 => impression etendue                   .
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
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtors.h"
#include "gmtoas.h"
#include "gmimpr.h"
c
c 0.3. ==> arguments
c
      integer choix
      integer gmimp
c
c 0.4. ==> variables locales
c
      character*8 nomf
      integer     i,j,ityp,ity,nba,iat,nbc,iad,k,l
c
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
c====
c 1. les structures declarees
c====
c
      if ( gmimp.gt.0 ) then
c
      if ( choix.eq.1 ) then
c
      write(ulsort,*) ' '
      write(ulsort,*) ' '
      write(ulsort,*) ' '
      write(ulsort,*) ' * Impression des tables des objets structures *'
      write(ulsort,*) ' ==============================================='
      write(ulsort,*) ' '
      write(ulsort,*) ' Etat des tables des structures declarees '
      write(ulsort,*) ' ---------------------------------------- '
      write(ulsort,*) ' '
c
    1 format(1x,i3,a,a8)
    2 format(4x,a,i8)
    3 format(4x,a,a8,' -> ',i8)
    4 format(4x,a,a8)
c
      write(ulsort,*) ' Nombre de types de structure = ',nbrtyp
      write(ulsort,*) ' '
      do 10 , i = 1,nbrtyp
         write(ulsort,*) ' '
         write(ulsort,1) i,' -> nom     du type   =  ',nomtyp(i)
         write(ulsort,*) ' '
         write(ulsort,2)   '    nombre  de attri  =  ',nbratt(i)
         write(ulsort,2)   '    nombre  de champ  =  ',nbcham(i)
         write(ulsort,2)   '    adresse de champ  =  ',adrdst(i)
         write(ulsort,*) ' '
        if ( gmimp.gt.2 ) then
        do 11 , j = adrdst(i),adrdst(i)+nbcham(i)-1
            write(ulsort,3) ' -> -> nom  de champ  =  ',nomcha(j)
            ityp = typcha(j)
            if ( ityp.gt.0) then
               nomf = nomtyp(ityp)
            else if (ityp.eq.-1) then
               nomf = nomtyb(1)
            else if (ityp.eq.-2) then
               nomf = nomtyb(2)
            else if (ityp.eq.-3) then
               nomf = nomtyb(3)
            endif
            write(ulsort,3) '       type de champ  =  ',nomf,ityp
            write(ulsort,*) ' '
   11    continue
         endif
         write(ulsort,*) ' '
   10 continue
      write(ulsort,*) ' -----------------------------------------------'
c
      endif
c
      endif
c
c====
c 2. les objets structures presents
c====
c
      if ( gmimp.gt.0 ) then
c
      if ( choix.eq.2 ) then
c
      write(ulsort,*) ' '
      write(ulsort,*) ' '
      write(ulsort,*) ' Etat des tables des objets structures - VTOC-MC'
      write(ulsort,*) ' -----------------------------------------------'
      write(ulsort,*) ' '
c
      write(ulsort,*) ' Nombre objets structures presents : ',iptobj-1
      write(ulsort,*) ' '
      do 20 , i = 1,iptobj-1
         write(ulsort,*) ' '
         write(ulsort,1) i,' -> nom objet  =  ',nomobj(i)
         write(ulsort,*) ' '
         ity = typobj(i)
         nba = nbratt(ity)
         iat = adrdsa(i)
         nbc = nbcham(ity)
         iad = adrdso(i)
         write(ulsort,3)   '    typ objet  =  ',nomtyp(ity),ity
         write(ulsort,*) ' '
         write(ulsort,2)   '    nbr-attri  =  ',nba
         if ( gmimp.gt.2 ) then
         write(ulsort,2)   '    adr attri  =  ',iat
         write(ulsort,*) ' '
         do 21 , j = 1,nba
            k = iat+j-1
            write(ulsort,2) ' -> -> numero-attr  =  ',j
            write(ulsort,2) '       valeur-attr  =  ',valatt(k)
            write(ulsort,*) '  '
   21    continue
         endif
         write(ulsort,2)   '    nbr-champ  =  ',nbc
         if ( gmimp.gt.2 ) then
         write(ulsort,2)   '    adr objet  =  ',iad
         write(ulsort,*) ' '
         do 22 , j = 1,nbc
            k = iad+j-1
            l = adrdst(ity)+j-1
            ityp = typcha(l)
            if ( ityp.gt.0) then
               nomf = nomtyp(ityp)
            else if (ityp.eq.-1) then
               nomf = nomtyb(1)
            else if (ityp.eq.-2) then
               nomf = nomtyb(2)
            else if (ityp.eq.-3) then
               nomf = nomtyb(3)
            endif
            write(ulsort,4) ' -> -> objet-champ  =  ',nomobc(k)
            write(ulsort,4) '       nom  -champ  =  ',nomcha(l)
            write(ulsort,3) '       type -champ  =  ',nomf,ityp
            write(ulsort,*) '  '
   22    continue
         endif
   20 continue
c
      write(ulsort,*) ' '
      write(ulsort,*) ' pointeur -> iptchp    =  ',iptchp
      write(ulsort,*) ' '
      write(ulsort,*) ' '
      write(ulsort,*) ' ==============================================='
c
      endif
c
      endif
c
      end
