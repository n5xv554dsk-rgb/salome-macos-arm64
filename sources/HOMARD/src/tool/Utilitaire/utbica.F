      subroutine utbica ( commen,
     >                    ulsort, langue, codret )
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
c    UTilitaire - BIlan du maillage de CAlcul
c    --           --                   --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . commen . e   . ch80   . commentaire a ecrire en tete               .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTBICA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nbutil.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer ulsort, langue, codret
c
      character*(*) commen
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer tabaux(0:7)
c
      character*50 texte1
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
      texte(1,4) =
     > '(5x,''Le maillage de calcul comporte '',i10,'' mailles.'')'
      texte(1,5) = '(5x,''Ils sont repartis en :'')'
      texte(1,6) =
     > '(5x,''Le maillage de calcul est forme de'',i10,1x,a)'
c
      texte(2,4) =
     > '(5x,''The computationnal mesh contains '',i10,'' meshes.'')'
      texte(2,5) = '(5x,''They are spread over :'')'
      texte(2,6) =
     > '(5x,''The computationnal mesh is made of'',i10,1x,a)'
c
 1000 format (5x,'. ',a14,' :',i10)
c
      codret = 0
c
c====
c 2. ecriture
c====
c
c 2.1. ==> ecriture des generalites
c
      texte1 = '                                                  '
      iaux = min(50,len(commen))
      if ( iaux.gt.0 ) then
         texte1(1:iaux) = commen(1:iaux)
      endif
      write (ulsort,21000) texte1
21000 format(//,5x,a50,/)
c
c 2.2. ==> ecriture des caracteristiques du maillage de calcul
c
      tabaux(0) = nbmapo
      tabaux(1) = nbsegm
      tabaux(2) = nbtria
      tabaux(3) = nbtetr
      tabaux(4) = nbquad
      tabaux(5) = nbpyra
      tabaux(6) = nbhexa
      tabaux(7) = nbpent
c
      jaux = 0
      do 221 , iaux = 0 , 7
        if ( tabaux(iaux).gt.0 ) then
          jaux = jaux + 1
          kaux = iaux
        endif
  221 continue
c
      if ( jaux.gt.1 ) then
c
        write (ulsort,texte(langue,4)) nbelem
        write (ulsort,texte(langue,5))
        do 222 , iaux = 0 , 7
          if ( tabaux(iaux).gt.0 ) then
            write (ulsort,1000) mess14(langue,3,iaux), tabaux(iaux)
          endif
  222   continue
c
      else
c
        write (ulsort,texte(langue,6)) tabaux(kaux),
     >                                 mess14(langue,3,kaux)
c
      endif
c
      end
