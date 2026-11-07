      subroutine eslmmc ( idfmed, nomamd,
     >                    typenh, typent, typgeo,
     >                    nmadeb, nbmato, dim1, dim2,
     >                    typcon,
     >                    conmai,
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
c                - Connectivites
c                  -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage de sortie                         .
c . nomamd . e   . char64 . nom du maillage MED                        .
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
c . nmadeb . e   .   1    . numero de la maille de debut               .
c .        .     .        .  >=0 : le tableau est pris tel quel        .
c .        .     .        .   <0 : les descriptions sont inversees     .
c . nbmato . e   .   1    . nombre de mailles a lire                   .
c . dim1   . e   .   1    . 1ere dimension de la connectivite          .
c . dim2   . e   .   1    . 2nde dimension de la connectivite          .
c . typcon . e   .   1    . type de connectivite                       .
c .        .     .        . 0 : par noeud (ednoda)                     .
c .        .     .        . 1 : descendante (eddesc)                   .
c . conmai .  s  .dim1dim2. connectivite des mailles                   .
c . tbiaux .     .    *   . tableau tampon                             .
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
      parameter ( nompro = 'ESLMMC' )
c
#include "nblang.h"
#include "consts.h"
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
      integer nmadeb, nbmato, dim1, dim2
      integer typcon
      integer conmai(dim1,dim2)
      integer tbiaux(*)
c
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux, kaux, laux
      integer nmafin
      integer numdt, numit
c
      character*6 saux06
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
      texte(1,63) = '(''Toutes les familles sont nulles.'')'
c
      texte(2,4) = '(''... Readings of '',i10,1x,a)'
      texte(2,63) = '(''All the families are 0.'')'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbmato, mess14(langue,3,typenh)
#endif
c
      codret = 0
      nmafin = nmadeb + nbmato - 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typcon', typcon
      write (ulsort,90002) 'typenh', typenh
      write (ulsort,90002) 'typent', typent
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'nmadeb', nmadeb
      write (ulsort,90002) 'nbmato', nbmato
      write (ulsort,90002) 'nmafin', nmafin
      write (ulsort,90002) 'dim1  ', dim1
      write (ulsort,90002) 'dim2  ', dim2
#endif
c
      numdt = ednodt
      numit = ednoit
c
c====
c 2. Lecture de la connectivite des mailles
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHCYR', nompro
#endif
      call mmhcyr ( idfmed, nomamd, numdt, numit,
     >              typent, typgeo,
     >              typcon, edfuin,
     >              tbiaux, codret )
      if ( codret.ne.0 ) then
        saux06 = 'mmhcyr'
      endif
c
      endif
c
c====
c 3. Creation de la connectivite par noeud
c====
c
      kaux = 0
c
      if ( typcon.eq.ednoda ) then
c
        if ( codret.eq.0 ) then
c
        if ( nmadeb.ge.0 ) then
c
          do 31 , iaux = nmadeb , nmafin
            do 311, jaux = 1, dim2
              kaux = kaux + 1
              conmai(iaux,jaux) = tbiaux(kaux)
  311       continue
   31     continue
c
        else
cgn      print *,'passage 32 avec dim2 =', dim2
c
          do 32 , iaux = 1, nbmato
cgn          print *,conmai(1,iaux), conmai(2,iaux)
            do 321, jaux = 1, dim2
              kaux = kaux + 1
              conmai(jaux,iaux) = tbiaux(kaux)
  321       continue
   32     continue
c
        endif
c
        endif
c
c====
c 4. Creation de la connectivite descendante, sauf pour les volumes
c====
c
      else
c
        if ( codret.eq.0 ) then
c
c 4.1. ==> Pour les faces
c
        if ( typenh.eq.2 .or. typenh.eq.4 ) then
c
cgn      print *,'passage 231 avec nmadeb , nmafin =', nmadeb , nmafin
          do 41 , iaux = nmadeb , nmafin
cgn            print *,(conmai(iaux,jaux),jaux = 1, dim2)
            do 411, jaux = 1, dim2
              kaux = kaux + 1
              conmai(iaux,jaux) = abs(tbiaux(kaux))
  411       continue
   41     continue
c
c 4.2. ==> Pour les segments
c
        elseif ( typenh.eq.1 ) then
c
c  Le noeud milieu sera gere par les informations supplementaires
c
          laux = dim2 - 2
c
cgn      print *,'passage 42 avec dim2, nbmato =', dim2, nbmato
          do 42 , iaux = 1, nbmato
            do 421, jaux = 1, 2
              kaux = kaux + 1
              conmai(jaux,iaux) = tbiaux(kaux)
  421       continue
            kaux = kaux + laux
cgn          print *,conmai(1,iaux), conmai(2,iaux)
   42     continue
c
        endif
c
        endif
c
      endif
c
c====
c 5. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4)) nbmato, mess14(langue,3,typenh)
      write (ulsort,texte(langue,78)) saux06, codret
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
