      subroutine utb3n5 ( lgboin, boinoe,
     >                    coonoe,
     >                    nbboit, nbinte,
     >                    boimin, boimax )
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
c    UTilitaire - Bilan - option 3 - phase N5
c    --           -              -         --
c ______________________________________________________________________
c
c Retourne la liste des boites d'un noeud - 1D
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgboin .  s  .   1    . longueur de boinoe                         .
c . boinoe .  s  .   8    . liste des boites du noeud en cours         .
c . coonoe . e   .  sdim  . coordonnees du noeud                       .
c . nbboit . e   .  sdim  . nombre de boites dans chaque dimension     .
c . nbinte . e   .  sdim  . nombre d'intervalles dans chaque dimension .
c . boimin .  a  .0:nbintx. limite minimale de chaque boite            .
c . boimax .  a  .0:nbintx. limite maximale de chaque boite            .
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
      parameter ( nompro = 'UTB3N5' )
c
#ifdef _DEBUG_HOMARD_
      integer ulsort
      parameter ( ulsort = 1 )
      integer langue
      parameter ( langue = 1 )
#endif
c
      integer sdim
      parameter ( sdim = 1 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer lgboin, boinoe(8)
      integer nbboit(sdim), nbinte(sdim)
c
      double precision coonoe(sdim)
      double precision boimin(3,0:*), boimax(3,0:*)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nombbo
      integer numint(2,3)
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
      do 11 , iaux = 1 , 8
        boinoe(iaux) = 0
   11 continue
c
c====
c 2. Pour une dimension iaux donnee, on passe en revue tous les
c    intervalles.
c    . Quand on rencontre la premiere limite qui est superieure a
c      la coordonnee, on stocke le numero de l'intervalle
c      dans numint(1,iaux)
c    . Sachant que les limites sont legerement recouvrantes, on
c      regarde si la coordonnee n'est pas superieure au minima de
c      l'intervalle suivant. Si oui, on stocke le numero de
c      l'intervalle suivant dans numint(2,iaux). Sinon,
c      numint(2,iaux) vaut numint(1,iaux).
c
c      numint :       1         2         3         4
c                |         |         |         |         |
c                               x --> 2/0
c                                    x --> 2/3
c====
cgn 3000 format(i10,3g12.5)
cgn 3001 format(10i4)
cgn 3002 format(a,' :',3i10)
c
cgn      write (ulsort,3002) 'sdim', sdim
      nombbo = 1
      do 21 , iaux = 1 , sdim
cgn        write (ulsort,3002) '. Dimension', iaux
cgn        write (ulsort,3002) '. nbinte(iaux)', nbinte(iaux)
c
        numint(1,iaux) = 0
c
        do 211 , jaux = 1 , nbinte(iaux)
cgn          write (ulsort,3000) jaux,boimax(iaux,jaux)
          if ( coonoe(iaux).le.boimax(iaux,jaux) ) then
            if ( numint(1,iaux).eq.0 ) then
              numint(1,iaux) = jaux
              numint(2,iaux) = jaux
              if ( coonoe(iaux).ge.boimin(iaux,jaux+1) ) then
                numint(2,iaux) = jaux + 1
                nombbo = nombbo*2
              endif
              goto 21
            endif
          endif
  211   continue
        numint(1,iaux) = nbboit(iaux)
        numint(2,iaux) = nbboit(iaux)
c
   21 continue
cgn      write (ulsort,3002) 'numint(1,*)',(numint(1,iaux),iaux=1,sdim)
cgn      write (ulsort,3002) 'numint(2,*)',(numint(2,iaux),iaux=1,sdim)
cgn      write (ulsort,3002) 'nombre de boites', nombbo
c
c 2.2. ==>  Increment des pointeurs
c 2.2.1. ==>  La boite principale
      iaux = nbboit(1)*(numint(1,2)-1)
     >     + numint(1,1)
cgn      write (ulsort,3002) 'boite principale',iaux
      lgboin = 1
      boinoe(lgboin) = iaux
c
c 2.2.2. ==>  Les boites secondaires
c
      if ( nombbo.gt.1 ) then
c
c       recouvrement en x
        iaux = nbboit(1)*(numint(1,2)-1)
     >       + numint(2,1)
        if ( iaux.ne.boinoe(1) ) then
cgn          write (ulsort,3002) 'b1',iaux
          lgboin = lgboin + 1
          boinoe(lgboin) = iaux
        endif
cgn          write (ulsort,3001) (boinoe(jaux),jaux = 1,lgboin)
c
      endif
c
c====
c 3. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
