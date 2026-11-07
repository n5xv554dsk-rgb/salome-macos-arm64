      subroutine eslmmb ( idfmed, nomamd,
     >                    typenh, typent, typgeo,
     >                    nmadeb, nbmato, nbrfma, nbelem, numfam,
     >                    typcon, dim1,
     >                    conmai, fammai,
     >                    tbiaux,
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
c  Entree-Sortie - Lecture d'un Maillage au format MED
c  -      -        -            -                  -
c                - phase B
c                        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage de sortie                         .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . nmadeb . e   .   1    . numero de la maille de debut               .
c .        .     .        .  >=0 : le tableau est pris tel quel        .
c .        .     .        .   <0 : les descriptions sont inversees     .
c . nbmato . e   .   1    . nombre de mailles a lire                   .
c . nbrfma . e   .   1    . nbre noeuds par maille si connec. par noeud.
c .        .     .        . nbre faces par maille si connectivite desce.
c . nbelem . e   .   1    . nombre d'elements, tous types confondus    .
c . numfam . e   .   1    . decalage dans la numerotation des familles .
c .        .     .        .   1 : le tableau est pris tel quel         .
c .        .     .        .  <=0 : le tableau passe negatif et est     .
c .        .     .        .        decale de numfam                    .
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : segments                             .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . typent . e   .   1    . type des entites au sens MED               .
c . typgeo . e   .   1    . type geometrique au sens MED               .
c . typcon . e   .   1    . type de connectivite                       .
c .        .     .        . 0 : par noeud (ednoda)                     .
c .        .     .        . 1 : descendente (eddesc)                   .
c . dim1   . e   .   1    . 1ere dimension de la connectivite          .
c . conmai .  s  .nbelem**. connectivite des mailles                   .
c . fammai .  s  . nbelem . famille med des mailles                    .
c . tbiaux .     . nbelem . tableau tampon                             .
c .        .     . *nbmane.                                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'ESLMMB' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer typenh, typent, typgeo
      integer nmadeb, nbmato, nbrfma, nbelem, numfam
      integer typcon, dim1
      integer conmai(dim1,*), fammai(nbelem)
      integer tbiaux(*)
c
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> les messages
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
#include "esimpr.h"
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbmato, mess14(langue,3,typenh)
#endif
c
      codret = 0
c
c====
c 2. Lecture de la famille d'appartenance
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMF', nompro
#endif
      call eslmmf ( idfmed, nomamd,
     >              typenh, typent, typgeo,
     >              nmadeb, nbmato, nbelem, numfam,
     >              typcon,
     >              fammai,
     >              tbiaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. Lecture de la connectivite des mailles
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMC', nompro
#endif
      call eslmmc ( idfmed, nomamd,
     >              typenh, typent, typgeo,
     >              nmadeb, nbmato, dim1, nbrfma,
     >              typcon,
     >              conmai,
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
      write (ulsort,texte(langue,4)) nbmato, mess14(langue,3,typenh)
      write (ulsort,texte(langue,78)) nompro, codret
      write (ulsort,texte(langue,79))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
