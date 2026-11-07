      subroutine esemmc ( idfmed, nomamd,
     >                    typenh, typent, typgeo,
     >                    nbmato, nbrfma, nbelem,
     >                    typcon, dim1,
     >                    conmai, infosu, listma,
     >                     numdt,  numit, instan,
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
c  Entree-Sortie - Ecriture d'un Maillage au format MED
c  -      -        -            -                   -
c                - Connectivites
c                  -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage de sortie                         .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . nbmato . e   .   1    . nombre de mailles                          .
c . nbrfma . e   .   1    . nbre noeuds par maille si connec. par noeud.
c .        .     .        . nbre faces par maille si connectivite desce.
c . nbelem . e   .   1    . nombre d'elements, tous types confondus    .
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
c . dim1   . e   .   1    . 1ere dimension de la connectivite          .
c . conmai . e   .nbelem**. connectivite des mailles                   .
c . infosu . e   . nbelem . informations supplementaire sur les mailles.
c . fammai . e   . nbelem . famille med des mailles                    .
c . listma . e   .   1    . liste des mailles a ecrire                 .
c .        .     .        . si listma(1) vaut 0, on ecrit tout         .
c .        .     .        . si listma(1) vaut -1, on ecrit tout et les .
c .        .     .        . descriptions sont inversees                .
c .        .     .        . si listma(1) vaut -2, on ecrit les segments.
c .        .     .        . en degre 1 a partir de esece0              .
c .        .     .        . si listma(1) vaut -3, on ecrit les segments.
c .        .     .        . en degre 2 a partir de esece0              .
c . numdt  . e   .   1    . numero du pas de temps                     .
c . numit  . e   .   1    . numero d'iteration                         .
c . instan . e   .   1    . pas de temps                               .
c . tabaux .     . nbelem . tableau tampon                             .
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
      parameter ( nompro = 'ESEMMF' )
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
      integer nbmato, nbrfma, nbelem
      integer typcon, dim1
      integer conmai(dim1,*), infosu(nbelem)
      integer listma(nbmato), tabaux(*)
      integer numdt, numit
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
      integer iaux, jaux, kaux
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Ecriture des '',i10,1x,a)'
c
      texte(2,4) = '(''. Writings of '',i10,1x,a)'
c
#include "esimpr.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbmato, mess14(langue,3,typenh)
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'listma(1)', listma(1)
      write (ulsort,90002) 'typenh', typenh
      write (ulsort,90002) 'typent', typent
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'nbmato', nbmato
      write (ulsort,90002) 'nbrfma', nbrfma
      write (ulsort,90002) 'typcon', typcon
      write (ulsort,90002) 'dim1  ', dim1
      write (ulsort,90002) 'numdt', numdt
      write (ulsort,90002) 'numit', numit
#endif
c
      codret = 0
c
c====
c 2. Creation du tableau de travail
c====
c 2.1. ==> Creation de la connectivite par noeud
c
      if ( codret.eq.0 ) then
c
      kaux = 0
c
      if ( typcon.eq.ednoda ) then
c
        if ( listma(1).eq.0 ) then
c
cgn      print *,'passage 211'
          do 211 , iaux = 1, nbmato
            do 2111, jaux = 1, nbrfma
              kaux = kaux + 1
              tabaux(kaux) = conmai(iaux,jaux)
 2111       continue
  211     continue
c
        elseif ( listma(1).lt.0 ) then
cgn      print *,'passage 212 avec nbrfma =', nbrfma
c
          do 212 , iaux = 1, nbmato
cgn          print *,conmai(1,iaux), conmai(2,iaux)
            do 2121, jaux = 1, nbrfma
              kaux = kaux + 1
              tabaux(kaux) = conmai(jaux,iaux)
 2121       continue
  212     continue
c
        else
cgn      print *,'passage 213'
c
          do 213 , iaux = 1, nbmato
            do 2131, jaux = 1, nbrfma
              kaux = kaux + 1
              tabaux(kaux) = conmai(listma(iaux),jaux)
 2131       continue
  213     continue
c
        endif
c
c 2.2. ==> Creation de la connectivite descendante :
c          les mailles a partir de esece0
c
      else
c
c  . degre 1
c
        if ( listma(1).eq.-2 ) then
c
cgn      print *,'passage 222 avec nbrfma =', nbrfma
          do 222 , iaux = 1, nbmato
cgn          print *,conmai(1,iaux), conmai(2,iaux)
            do 2221, jaux = 1, 2
              kaux = kaux + 1
              tabaux(kaux) = conmai(jaux,iaux)
 2221       continue
  222     continue
c
        elseif ( listma(1).eq.-3 ) then
c
c  . degre 2 : on ajoute le noeud central
c
          do 223 , iaux = 1, nbmato
cgn          print *,conmai(1,iaux), conmai(2,iaux)
            do 2231, jaux = 1, 2
              kaux = kaux + 1
              tabaux(kaux) = conmai(jaux,iaux)
 2231       continue
            kaux = kaux + 1
            tabaux(kaux) = infosu(iaux)
  223     continue
c
        endif
c
      endif
c
      endif
c
c====
c 3. Ecriture de la connectivite
c====
c
      if ( codret.eq.0 ) then
c
cgn      print *,(tabaux(iaux),iaux=1,nbrfma*nbmato)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHCYW', nompro
#endif
      call mmhcyw ( idfmed, nomamd, numdt, numit, instan,
     >              typent, typgeo, typcon, edfuin,
     >              nbmato, tabaux, codret )
      if ( codret.ne.0 ) then
        saux06 = 'mmhcyw'
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
      write (ulsort,texte(langue,80))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
