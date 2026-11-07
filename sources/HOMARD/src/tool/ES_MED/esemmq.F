      subroutine esemmq ( idfmed, nomamd, nomequ,
     >                     numdt,  numit,
     >                    typgeo, typmai,
     >                    nbeqen, eqenti,
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
c  Entree-Sortie - Ecriture d'un Maillage au format MED - eQuivalences
c  -      -        -             -                  -      -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage de sortie                         .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . nomequ . e   . char64 . nom de l'equivalence                       .
c . numdt  . e   .   1    . numero du pas de temps                     .
c . numit  . e   .   1    . numero d'iteration                         .
c . nbeqen . e   .   1    . nombre de paires d'entites                 .
c . eqenti . e   .2*nbeqen. liste des paires d'entites equivalentes    .
c .        .     .        . avec la convention :                       .
c .        .     .        . eqenti(i)<-->eqenti(i+1)                   .
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
      parameter ( nompro = 'ESEMMQ' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "envex1.h"
#include "impr02.h"
#include "indefi.h"
c
#include "envca1.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer ulsort, langue, codret
c
      integer numdt, numit
      integer typgeo, typmai
      integer nbeqen
      integer eqenti(2,nbeqen)
c
      character*64 nomamd
      character*64 nomequ
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux, kaux
      integer nuenmx, nbcibl
      integer codre0
      integer codre1, codre2, codre3
      integer ptrav1, ptrav2, ptrav3
c
      character*8 ntrav1, ntrav2, ntrav3
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
#include "impr03.h"
c
#include "esimpr.h"
c
      codret = 0
c
c====
c 2. preliminaires
c====
c 2.1. ==> Numero maximal de l'entite source
c
      nuenmx = 0
      do 21 , iaux = 1 , nbeqen
cgn      write (ulsort,90112) 'eqenti',iaux,eqenti(1,iaux),eqenti(2,iaux)
        nuenmx = max (nuenmx, eqenti(1,iaux))
   21 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nuenmx', nuenmx
#endif
c
c 2.2. ==> tableaux de travail
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', nuenmx, ptrav1, codre1 )
      iaux = nuenmx + 1
      call gmalot ( ntrav2, 'entier  ',   iaux, ptrav2, codre2 )
      iaux = 2*nbeqen
      call gmalot ( ntrav3, 'entier  ',   iaux, ptrav3, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
      endif
c
c 2.3. ==> Nombre de cibles par source
c
      if ( codret.eq.0 ) then
c
      do 231 , iaux = 1 , nuenmx
        imem(ptrav1+iaux-1) = 0
  231 continue
c
      do 232 , iaux = 1 , nbeqen
        jaux = ptrav1+eqenti(1,iaux)-1
        imem(jaux) = imem(jaux) + 1
  232 continue
#ifdef _DEBUG_HOMARD_
      call gmprsx ('ntrav1 nombre de cibles', ntrav1)
#endif
c
      endif
c
c 2.4. ==> Pointeur
c
      if ( codret.eq.0 ) then
c
      do 241 , iaux = 1 , nuenmx+1
        imem(ptrav2+iaux-1) = 0
  241 continue
c
      do 242 , iaux = 1 , nuenmx
        nbcibl = imem(ptrav1+iaux-1)
cgn      write (ulsort,90112) 'cible',iaux,nbcibl
        jaux = ptrav2+iaux
        imem(jaux) = imem(jaux-1) + nbcibl
  242 continue
#ifdef _DEBUG_HOMARD_
      call gmprsx ('ntrav2 pointeur', ntrav2)
#endif
c
      endif
c
c 2.5. ==> Rangement
c
      if ( codret.eq.0 ) then
c
      do 252 , iaux = 1 , nbeqen
cgn      write (ulsort,90112) 'eqenti',iaux,eqenti(1,iaux),eqenti(2,iaux)
        jaux = ptrav2+eqenti(1,iaux)-1
        imem(jaux) = imem(jaux) + 1
cgn      write (ulsort,90002) 'imem(jaux)', imem(jaux)
        kaux = ptrav3 + 2*(imem(jaux)-1)
        imem(kaux  ) = eqenti(1,iaux)
        imem(kaux+1) = eqenti(2,iaux)
  252 continue
#ifdef _DEBUG_HOMARD_
      call gmprsx ('ntrav3', ntrav3)
#endif
c
      endif
c
c
c====
c 3. ecriture
c    la convention de stockage MED des listes d'equivalences est que
c    l'entite Liste(j) est associee a Liste(j+1)
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. ecriture ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MEQCOW', nompro
#endif
      call meqcow ( idfmed, nomamd, nomequ, numdt, numit,
     >              typgeo, typmai,
     >              nbeqen, imem(ptrav3), codret )
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,78)) 'meqcow', codret
      endif
c
      endif
c
c===
c 4. nettoyage
c===
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
      call gmlboj ( ntrav3, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
