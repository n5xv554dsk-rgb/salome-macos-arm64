      subroutine eslmmf ( idfmed, nomamd,
     >                    typenh, typent, typgeo,
     >                    nmadeb, nbmato, nbelem, numfam,
     >                    typcon,
     >                    fammai,
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
c                - Familles
c                  -
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
c .        .     .        . 1 : descendante (eddesc)                   .
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
      parameter ( nompro = 'ESLMMF' )
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
      integer nmadeb, nbmato, nbelem, numfam
      integer typcon
      integer fammai(nbelem)
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
      integer iaux
      integer numdt, numit
      integer datype, chgt, tsf
      integer lgtfam
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typcon', typcon
      write (ulsort,90002) 'typenh', typenh
      write (ulsort,90002) 'typent', typent
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'nmadeb', nmadeb
      write (ulsort,90002) 'nbmato', nbmato
      write (ulsort,90002) 'nbelem', nbelem
      write (ulsort,90002) 'numfam', numfam
#endif
c
      numdt = ednodt
      numit = ednoit
      chgt = 0
      tsf = 0
c
c====
c 2. Longueur du tableau des familles
c====
c
      if ( codret.eq.0 ) then
c
      datype = edda04
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'numdt', numdt
      write (ulsort,90002) 'numit', numit
      write (ulsort,90002) 'typent', typent
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'datype', datype
      write (ulsort,90002) 'typcon', typcon
      write (ulsort,90002) 'chgt', chgt
      write (ulsort,90002) 'tsf', tsf
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHNME', nompro
#endif
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              typent, typgeo, datype, typcon, chgt, tsf,
     >              lgtfam, codret )
      if ( codret.ne.0 ) then
        saux06 = 'mmhnme'
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'lgtfam', lgtfam
#endif
c
      endif
c
c====
c 3. Remplissage du tableau
c====
c 3.1. ==> 0 par defaut
c
      if ( lgtfam.eq.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,63))
#endif
c
        if ( nmadeb.ge.0 ) then
          do 311 , iaux = 1, nbmato
            fammai(nmadeb-1+iaux) = 0
  311     continue
        else
          do 312 , iaux = 1, nbmato
            fammai(iaux) = 0
  312     continue
        endif
c
        endif
c
c 3.2. ==> lecture
c
      else
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHFNR', nompro
#endif
        call mmhfnr ( idfmed, nomamd, numdt, numit,
     >                typent, typgeo,
     >                tbiaux, codret )
        if ( codret.ne.0 ) then
          saux06 = 'mmhfnr'
        endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( numfam.gt.0 ) then
c
          if ( nmadeb.ge.0 ) then
            do 321 , iaux = 1, nbmato
             fammai(nmadeb-1+iaux) = tbiaux(iaux)
  321       continue
          else
            do 322 , iaux = 1, nbmato
             fammai(iaux) = tbiaux(iaux)
  322       continue
          endif
c
        else
c
          if ( nmadeb.ge.0 ) then
            do 323 , iaux = 1, nbmato
              fammai(nmadeb-1+iaux) = -tbiaux(iaux) + numfam
  323       continue
          else
            do 324 , iaux = 1, nbmato
              fammai(iaux) = -tbiaux(iaux) + numfam
  324       continue
          endif
c
        endif
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
