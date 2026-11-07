      subroutine gmcata( nomtab, lgallo,
     >                   nballg, nomalg, lgallg )
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
c ......................................................................
c .           auteur : gn 03/05
c ......................................................................
c .
c .  - interet:
c .      recuperation des carateristiques d'un tableau
c .
c .  - realisation:
c .
c .  - arguments:
c . donnees nomtab  --> nom du tableau a etudier (8 caracteres au plus)
c .         nomalg <--> tableau de chaines de caracteres contenant
c .                     le nom associe a chaque tableau deja alloue
c .         lgallg <--> tableau entier contenant la longueur des
c .                     tableaux
c .resultat lgallo  <--  nombre de valeurs a l'allocation
c .
c ......................................................................
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
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmimpr.h"
c
c 0.3. ==> arguments
c
      character*8 nomtab
      character*8 nomalg(maxtab)
c
      integer lgallo
      integer nballg, lgallg(maxtab)
c
c 0.4. ==> variables locales
c
      character*8 nomvar
c
      integer iaux, jaux
      integer codret
      integer nrotab
      integer nbcain
c
      character*6 nompro
      parameter ( nompro = 'GMCATA' )
c
      character*1 carint(1)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c ----
c  1. preliminaires
c----
c
c 1.1. ==> nature du nom
c          aucun caractere n'est interdit, mais on met un blanc
c          dans le tableau pour ne plus avoir de messages ftnchek
c
      nbcain = 0
      carint(1) = ' '
      call gmntve ( nomtab, nomvar, nbcain, carint, codret )
c
      if ( codret.ne.0 ) then
        write(ulsort,30001) nompro
30001   format ( 2x,'Probleme dans ',a)
        call ugstop( nompro,ulsort,0,1,1)
      endif
c
c====
c 2. caracteristiques
c====
c
c 2.1. ==> Recherche dans les tables
c
      jaux = 0
      do 21 , iaux = 1 , nballg
         if ( nomalg(iaux).eq.nomvar ) then
           nrotab = iaux
           jaux = jaux + 1
         endif
   21 continue
c
      if (jaux.eq.0) then
        write(ulsort,30003) nompro, nomvar
30003   format ( 2x,'Probleme dans ',a,
     >         /,4x,'Le tableau (',a8,') n''a pas ete alloue',
     >         /,4x,'    ===>  arret dans le gestionnaire de memoire')
        call ugstop( nompro,ulsort,1,1,1)
      else if (jaux.gt.1) then
        write(ulsort,30013) nompro, nomvar
30013   format ( 2x,'Probleme  dans ',a,
     >         /,4x,'Le tableau (',a8,') a ete alloue plusieurs fois' ,
     >         /,4x,'    ===>  arret dans le gestionnaire de memoire')
        call ugstop( nompro,ulsort,1,1,1)
      endif
c
c 2.1. ==> Longueur d'allocation
c
      lgallo = lgallg(nrotab)
c
      end
