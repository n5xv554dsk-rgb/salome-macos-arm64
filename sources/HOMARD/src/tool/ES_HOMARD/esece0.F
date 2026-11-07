      subroutine esece0 ( idfmed, nomamd,
     >                    typenh, typgeo, typent,
     >                    nbenti, nbencf, nbenca, nbrfma,
     >                    somare,
     >                    codeen, infosu, codear,
     >                     numdt,  numit, instan,
     >                    ltbiau, tbiaux,
     >                    ulsort, langue, codret)
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
c  Entree-Sortie : ECriture d'une Entite - 0
c  -      -        --             -        -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . typenh . e   .   1    . code des entites                           .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . typgeo . e   .   1    . type geometrique au sens MED               .
c . typent . e   .   1    . type d'entite au sens MED                  .
c . nbenti . e   .   1    . nombre d'entites                           .
c . nbencf . e   .   1    . nombre d'entites decrites par faces        .
c . nbenca . e   .   1    . nombre d'entites decrites par aretes       .
c . nbrfma . e   .   1    . nbre noeuds par maille si connec. par noeud.
c .        .     .        . nbre faces par maille si connectivite desce.
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . codeen . e   .nbencf**. connectivite descendante des mailles       .
c . infosu . e   .nbencf**. code des faces dans les mailles 3D         .
c . codear . e   .nbenca**. connectivite des mailles par aretes        .
c . numdt  . e   .   1    . numero du pas de temps                     .
c . numit  . e   .   1    . numero d'iteration                         .
c . instan . e   .   1    . pas de temps                               .
c . ltbiau . e   .    1   . longueur allouee a tbiaux                  .
c . tbiaux .     .    *   . tableau tampon entier                      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'ESECE0' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer typenh, typgeo, typent
      integer nbenti, nbencf, nbenca, nbrfma
      integer somare(2,*)
      integer codeen(nbencf,*), infosu(nbencf,*), codear(nbenca,*)
      integer numdt, numit
      integer ltbiau, tbiaux(*)
c
      character*64 nomamd
c
      double precision instan
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
      integer listma(1)
      integer dim1
      integer typcon
c
      integer nbmess
      parameter ( nbmess = 150 )
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
      texte(1,4) = '(''... Ecriture des '',i10,1x,a)'
c
      texte(2,4) = '(''... Writings of '',i10,1x,a)'
c
#include "esimpr.h"
c
      texte(1,81) = '(''Longueur allouee pour tbiaux    : '',i10)'
      texte(1,82) = '(''Longueur necessaire pour tbiaux : '',i10)'
c
      texte(2,81) = '(''Allocated length for tbiaux    : '',i10)'
      texte(2,82) = '(''Used length for tbiaux : '',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbenti, mess14(langue,3,typenh)
      write (ulsort,90002) 'nbencf', nbencf
      write (ulsort,90002) 'nbenca', nbenca
#endif
c
c====
c 2. Preparation des donnees
c====
c 2.1. ==> Verification
c
      if ( codret.eq.0 ) then
c
      if ( nbenti*nbrfma.gt.ltbiau ) then
        write (ulsort,texte(langue,81)) ltbiau
        write (ulsort,texte(langue,82)) nbenti*nbrfma
        codret = 7
      endif
c
      endif
c
c 2.2. ==> Creation du tableau
c
      if ( codret.eq.0 ) then
c
      dim1 = nbenti
c
c 2.2.2. ==> Mailles-points
c
      if ( typenh.eq.0 ) then
c
        listma(1) = 0
        typcon = ednoda
c
c 2.2.1. ==> Segments
c
      elseif ( typenh.eq.1 ) then
c
        dim1 = 2
        listma(1) = -nbrfma
        typcon = eddesc
c
c 2.2.4. ==> Autres : on cree directement le tableau a ecrire
c
      else
c
        listma(1) = 0
        typcon = eddesc
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'ESECE2', nompro
#endif
        call esece2 ( typenh, nbencf, nbenca, nbrfma,
     >                somare, codeen, infosu, codear,
     >                tbiaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 3. Ecriture veritable
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMMC', nompro
#endif
      call esemmc ( idfmed, nomamd,
     >              typenh, typent, typgeo,
     >              nbenti, nbrfma, nbenti,
     >              typcon,   dim1,
     >              codeen, infosu, listma,
     >               numdt,  numit, instan,
     >              tbiaux,
     >              ulsort, langue, codret )
c
      endif
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
