      subroutine vcind3 ( nbtafo, nbvind, indica, nbpg,
     >                    ncmpin, nucomp,
     >                    adindi, ntrava,
     >                    ulsort, langue, codret)
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
c    aVant adaptation - Conversion d'INDicateur - phase 3
c     -                 -            ---                -
c    Pour un indicateur exprime aux points de Gauss, on met sur la
c    maille la valeur la plus grande en valeur absolue, en respectant
c    son signe.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbtafo . e   .   1    . nombre de tableaux dans la fonction        .
c . nbvind . e   .   1    . nombre d'entites maximum                   .
c . indica . e   . nbtafo . valeurs de l'indicateur                    .
c .        .     .*nbvind .                                            .
c . nbpg   . e   .   1    . nombre de points de Gauss                  .
c . ncmpin . e   .   1    . nombre de composantes retenues             .
c . nucomp . e   . ncmpin . numeros des composantes retenues           .
c . adindi .  s  .   1    . adresse du tableau d'indicateur filtre     .
c . ntrava .  s  . char*8 . nom de l'objet de l'indicateur filtre      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'VCIND3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmreel.h"
c
c 0.3. ==> arguments
c
      integer nbvind, nbtafo, nbpg
      integer ncmpin, nucomp(ncmpin)
      integer adindi
c
      double precision indica(nbtafo,nbpg,nbvind)
c
      character*8 ntrava
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer nrcomp
c
      double precision dauxmi, dauxma, daux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
cgn      write(ulsort,*) 'dans ',nompro
cgn      write(ulsort,*) indica
cgn      write(ulsort,*) 'nbtafo,nbpg,nbvind = ',nbtafo,nbpg,nbvind
cgn        do 111 , iaux = 1 , nbtafo
cgn        do 111 , jaux = 1 , nbpg
cgn        do 111 , kaux = 1 , nbvind
cgn        write(ulsort,*)'indica(',iaux,',',jaux,',',kaux,') = ',
cgn     >           indica(iaux,jaux,kaux)
cgn 111    continue
c
c====
c 2. Allocation du tableau filtre
c====
c
      iaux = nbtafo*nbvind
      call gmalot ( ntrava, 'reel    ', iaux, adindi, codret )
c
c====
c 3. Transfert
c    On ne transfere que la ou les composantes retenues
c====
c
      if ( codret.eq.0 ) then
c
      do 31 , laux = 1 , ncmpin
c
        nrcomp = nucomp(laux)
        kaux = adindi + nrcomp - 1
c
        do 311 , iaux = 1 , nbvind
c
c 3.1. ==> Recherche des mini et maxi
c
          dauxmi = indica(nrcomp,1,iaux)
          dauxma = dauxmi
cgn        if ( iaux.eq.5.or.iaux.eq.21) then
cgn        write(ulsort,*)iaux,dauxmi
cgn        endif
          do 3111 , jaux = 2 , nbpg
cgn          if ( iaux.eq.5.or.iaux.eq.21) then
cgn            write(ulsort,*)jaux, indica(nrcomp,jaux,iaux)
cgn          endif
            dauxmi = min (dauxmi , indica(nrcomp,jaux,iaux) )
            dauxma = max (dauxma , indica(nrcomp,jaux,iaux) )
 3111     continue
c
c
c 3.2. ==> Tri selon les signes
c
c          .....0.....mi.......ma......   ==> ma
          if ( dauxmi.ge.0.d0 ) then
            daux = dauxma
          else
c          .........mi.......ma....0...   ==> mi
            if ( dauxma.le.0.d0 ) then
              daux = dauxmi
            else
c          ...mi..........0...ma........   ==> mi
              if ( abs(dauxmi).gt.dauxma ) then
                daux = dauxmi
c          ...mi...0..........ma........   ==> ma
              else
                daux = dauxma
              endif
            endif
          endif
cgn      if ( iaux.le.5.or.iaux.ge.0) then
cgn      write(ulsort,*)'mini : ',dauxmi,', maxi : ',dauxma,'==> ',daux
cgn      endif
c
          rmem(kaux+nbtafo*(iaux-1)) = daux
c
  311   continue
c
   31 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprot (nompro,ntrava,1,30)
#endif
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
