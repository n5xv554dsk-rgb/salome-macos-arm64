      subroutine utb3n3 ( lgboin, boinoe,
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
c    UTilitaire - Bilan - option 3 - phase N3
c    --           -              -         --
c ______________________________________________________________________
c
c Retourne la liste des boites d'un noeud - 3D
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgboin .  s  .   1    . longueur de boinoe                         .
c . boinoe .  s  .    *   . liste des boites du noeud en cours         .
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
      parameter ( nompro = 'UTB3N3' )
c
#ifdef _DEBUG_HOMARD_
      integer ulsort
      parameter ( ulsort = 6 )
      integer langue
      parameter ( langue = 1 )
#endif
c
      integer sdim
      parameter ( sdim = 3 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer lgboin, boinoe(*)
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
#include "impr03.h"
c
c====
c 2. Pour une dimension iaux donnee, on passe en revue tous les
c    intervalles.
c      . Quand on rencontre la premiere limite qui est superieure a
c        la coordonnee, on stocke le numero de l'intervalle
c        dans numint(1,iaux)
c      . Sachant que les limites sont legerement recouvrantes, on
c        regarde si la coordonnee n'est pas superieure au minima de
c        l'intervalle suivant. Si oui, on stocke le numero de
c        l'intervalle suivant dans numint(2,iaux). Sinon,
c        numint(2,iaux) vaut numint(1,iaux).
c
c      numint :       1         2         3         4
c                |         |         |         |         |
c                               x --> 2/0
c                                    x --> 2/3
c====
c
      nombbo = 1
      do 21 , iaux = 1 , sdim
c
        numint(1,iaux) = 0
c
        do 211 , jaux = 1 , nbinte(iaux)
cgn     write (ulsort,90014) jaux,boimax(iaux,jaux)
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
cgn          write (ulsort,91020) (numint(1,iaux),iaux=1,sdim)
cgn          write (ulsort,91020) (numint(2,iaux),iaux=1,sdim)
cgn          write (ulsort,90002) 'nombre de boites', nombbo
c
c 2.2. ==>  Increment des pointeurs
c
      jaux = nbboit(1)*nbboit(2)
c
c 2.2.1. ==>  La boite principale
c
      iaux = jaux*(numint(1,3)-1)
     >     + nbboit(1)*(numint(1,2)-1)
     >     + numint(1,1)
cgn             write (ulsort,90002) 'b',iaux
      lgboin = 1
      boinoe(lgboin) = iaux
c
c 2.2.2. ==>  Les boites secondaires
c
      if ( nombbo.gt.1 ) then
c
        lgboin = 1
        boinoe(lgboin) = iaux
c
c           recouvrement en x
        iaux = jaux*(numint(1,3)-1)
     >       + nbboit(1)*(numint(1,2)-1)
     >       + numint(2,1)
        if ( iaux.ne.boinoe(1) ) then
cgn          write (ulsort,90002) 'n1',lenoeu
cgn          write (ulsort,90002) 'b1',iaux
          lgboin = lgboin + 1
          boinoe(lgboin) = iaux
        endif
cgn              write (ulsort,91020) (boinoe(jaux),jaux = 1,lgboin)
c
c           recouvrement en y
        iaux = jaux*(numint(1,3)-1)
     >       + nbboit(1)*(numint(2,2)-1)
     >       + numint(1,1)
        do 221 , jaux = 1 , lgboin
          if ( iaux.eq.boinoe(jaux) ) then
            goto 2211
          endif
  221   continue
cgn            write (ulsort,90002) 'n2',lenoeu
cgn            write (ulsort,90002) 'b2',iaux
        lgboin = lgboin + 1
        boinoe(lgboin) = iaux
cgn              write (ulsort,91020) (boinoe(jaux),jaux = 1,lgboin)
 2211   continue
c
c           recouvrement en z
        iaux = jaux*(numint(2,3)-1)
     >       + nbboit(1)*(numint(1,2)-1)
     >       + numint(1,1)
        do 222 , jaux = 1 , lgboin
          if ( iaux.eq.boinoe(jaux) ) then
            goto 2221
          endif
  222   continue
cgn            write (ulsort,90002) 'n3',lenoeu
cgn            write (ulsort,90002) 'b3',iaux
        lgboin = lgboin + 1
        boinoe(lgboin) = iaux
 2221   continue
c
c           recouvrement en x et y
        iaux = jaux*(numint(1,3)-1)
     >       + nbboit(1)*(numint(2,2)-1)
     >       + numint(2,1)
        do 223 , jaux = 1 , lgboin
          if ( iaux.eq.boinoe(jaux) ) then
            goto 2231
          endif
  223   continue
cgn            write (ulsort,90002) 'n3',lenoeu
cgn            write (ulsort,90002) 'b3',iaux
        lgboin = lgboin + 1
        boinoe(lgboin) = iaux
 2231   continue
c
c           recouvrement en y et z
        iaux = jaux*(numint(2,3)-1)
     >       + nbboit(1)*(numint(2,2)-1)
     >       + numint(1,1)
        do 224 , jaux = 1 , lgboin
          if ( iaux.eq.boinoe(jaux) ) then
            goto 2241
          endif
  224   continue
cgn            write (ulsort,90002) 'n3',lenoeu
cgn            write (ulsort,90002) 'b3',iaux
        lgboin = lgboin + 1
        boinoe(lgboin) = iaux
 2241   continue
c
c           recouvrement en z et x
        iaux = jaux*(numint(2,3)-1)
     >       + nbboit(1)*(numint(1,2)-1)
     >       + numint(2,1)
        do 225 , jaux = 1 , lgboin
          if ( iaux.eq.boinoe(jaux) ) then
            goto 2251
          endif
  225   continue
cgn            write (ulsort,90002) 'n3',lenoeu
cgn            write (ulsort,90002) 'b3',iaux
        lgboin = lgboin + 1
        boinoe(lgboin) = iaux
 2251   continue
c
c           recouvrement en x, y et z
        iaux = jaux*(numint(2,3)-1)
     >       + nbboit(1)*(numint(2,2)-1)
     >       + numint(2,1)
        do 226 , jaux = 1 , lgboin
          if ( iaux.eq.boinoe(jaux) ) then
            goto 2261
          endif
  226   continue
cgn            write (ulsort,90002) 'n3',lenoeu
cgn            write (ulsort,90002) 'b3',iaux
 2261   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
       write (ulsort,90002) 'lgboin', lgboin
       write (ulsort,91010) (boinoe(jaux),jaux = 1 , lgboin)
#endif
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
