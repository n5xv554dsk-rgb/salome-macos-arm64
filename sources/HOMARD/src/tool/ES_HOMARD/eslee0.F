      subroutine eslee0 ( idfmed, nomamd,
     >                    typenh, typgeo, typent,
     >                    nbencf, nbenca, nbrfma, nbrama,
     >                    codeen, coaren,
     >                    tabaux,
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
c  Entree-Sortie : LEcture d'une Entite - 0
c  -      -        --            -        -
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
c . nbencf . e   .   1    . nombre d'entites decrites par faces        .
c . nbenca . e   .   1    . nombre d'entites decrites par aretes       .
c . nbrfma . e   .   1    . nbre noeuds par maille si connec. par noeud.
c .        .     .        . nbre faces par maille si connectivite desce.
c . nbrama . e   .   1    . nbre aretes par maille si volume           .
c . codeen .  s  .nbencf**. connectivite descendante des mailles       .
c . coaren .  s  .nbenca**. connectivite des mailles par aretes        .
c . tabaux .     .    *   . tableau tampon                             .
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
      parameter ( nompro = 'ESLEE0' )
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
      integer nbencf, nbenca, nbrfma, nbrama
      integer codeen(*), coaren(*)
      integer tabaux(*)
c
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
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
      texte(1,4) = '(''... Lecture des '',i10,1x,a)'
c
      texte(2,4) = '(''... Readings of '',i10,1x,a)'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbencf, mess14(langue,3,typenh)
#endif
c
c====
c 2. Lecture des connectivites
c====
c
      if ( codret.eq.0 ) then
c
      if ( typenh.eq.1 ) then
        iaux = -nbrfma
        dim1 = 2
      else
        iaux = 1
        dim1 = nbencf
      endif
      if ( typenh.eq.0 ) then
        typcon = ednoda
      else
        typcon = eddesc
      endif
ccc      write (ulsort,90002) 'typent', typent
ccc      write (ulsort,90002) 'typgeo', typgeo
ccc      write (ulsort,90002) 'iaux  ', iaux
ccc      write (ulsort,90002) 'nbencf', nbencf
ccc      write (ulsort,90002) 'nbrfma, nbrama', nbrfma, nbrama
ccc      write (ulsort,90002) 'dim1  ', dim1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMC', nompro
#endif
        call eslmmc ( idfmed, nomamd,
     >                typenh, typent, typgeo,
     >                iaux, nbencf, dim1, nbrfma,
     >                typcon,
     >                codeen,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 3. Mise en place de la connectivite des volumes
c====
c
      if ( codret.eq.0 ) then
c
      if ( typenh.eq.3 .or. typenh.eq.5 .or.
     >     typenh.eq.6 .or. typenh.eq.7 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'ESLEE1', nompro
#endif
        call eslee1 ( typenh, nbencf, nbenca, nbrfma, nbrama,
     >                codeen, coaren, tabaux,
     >                ulsort, langue, codret )
c
      endif
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
