      subroutine pcs2h4 ( nbfop2, profho, vap2ho,
     >                    somare, np2are,
     >                    listso, listar,
     >                    areint,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c    interpolation p2 sur les noeuds - decoupage Hexaedres - 4
c                   -                            -           -
c    D'un milieu d'arete a un sommet (selon 1 arete)
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop2 . e   .    1   . nombre de fonctions P2                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vap2ho . es  . nbfop2*. variables p2 numerotation homard           .
c .        .     . nbnoto .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . listso . e   .   8    . numeros globaux des sommets                .
c . listar . e   .  12    . numeros globaux des aretes                 .
c . areint . e   .   *    . numeros globaux des aretes internes        .
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
      parameter ( nompro = 'PCS2H4' )
c
#include "nblang.h"
c
#include "fractf.h"
#include "fractg.h"
#include "fracth.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(*)
      integer somare(2,nbarto), np2are(nbarto)
      integer listso(8), listar(12)
      integer areint(*)
c
      double precision vap2ho(nbfop2,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer larete
      integer listns(20)
      integer sm(2), nuv
      integer iaux1(2), iaux2(2), iaux3(2), iaux4(2)
      integer jaux1(2), jaux2(2), jaux3(2), jaux4(2)
      integer kaux1(2), kaux2(2), kaux3(2), kaux4(2)
      integer laux1(2), laux2(2), laux3(2), laux4(2)
      integer maux1, maux2, maux3, maux4
      integer perm12(2)
c
      integer nbmess
      parameter ( nbmess = 100 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisation
c
      data perm12 / 2, 1 /
c
#include "impr03.h"
c ______________________________________________________________________
c
#include "impr01.h"
c
cgn        write (ulsort,texte(langue,1)) 'Entree', nompro
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'listar  1-8', (listar(iaux),iaux=1,8)
      write (ulsort,90002) 'listar 9-12', (listar(iaux),iaux=9,12)
      write (ulsort,90002) 'listso', listso
#endif
c
c     Deux aretes partent du milieu de l'arete coupee vers un des deux
c     sommets de l'arete opposee. On a donc deux interpolations a faire.
c     Ce sont les indices 1 et 2 des tableaux iauxi.
c
cgn        write (ulsort,*) 'la', nuarlo,'-eme arete est coupee'
c
c====
c 1. Les sommets de la face qui contient le sommet
c    iaux1 : le sommet de l'arete coupee
c    iaux2/3 : les deux autres sommets
c    iaux4 : le sommet oppose
c====
c
c     f1 : F3
      iaux1(1) = 1
      iaux2(1) = 4
      iaux3(1) = 6
      iaux4(1) = 7
c     f2 : F4
      iaux1(2) = 2
      iaux2(2) = 3
      iaux3(2) = 5
      iaux4(2) = 8
c
c====
c 2. Les noeuds de la face du cote du sommet oppose
c    kaux1/2 : les milieux des aretes vers l'arete coupee
c    kaux3/4 : les milieux des aretes vers le sommet oppose
c====
c
c     f1 : F3
      kaux1(1) = 2
      kaux2(1) = 5
      kaux3(1) = 7
      kaux4(1) = 10
c     f2 : F4
      kaux1(2) = 3
      kaux2(2) = 6
      kaux3(2) = 8
      kaux4(2) = 11
c
c====
c 3. Les noeuds et sommets de la face opposee :
c    . jauxi a le meme role que iauxi
c    . lauxi a le meme role que kauxi
c====
c
      do 31 , iaux = 1 , 2
c
        jaux1(iaux) = iaux1(perm12(iaux))
        jaux2(iaux) = iaux2(perm12(iaux))
        jaux3(iaux) = iaux3(perm12(iaux))
        jaux4(iaux) = iaux4(perm12(iaux))
c
        laux1(iaux) = kaux1(perm12(iaux))
        laux2(iaux) = kaux2(perm12(iaux))
        laux3(iaux) = kaux3(perm12(iaux))
        laux4(iaux) = kaux4(perm12(iaux))
c
   31 continue
c
c====
c 4. Les noeuds milieux intermediaires
c    maux1 : le milieu de l'arete coupee
c    maux2/3 : les milieux des aretes paralleles a l'arete coupee
c    maux4 : le milieu de l'arete oppose
c====
c
      maux1 = 1
      maux2 = 4
      maux3 = 9
      maux4 = 12
c
c====
c 5. L'arete concernee : celle des deux aretes internes qui demarrent
c    sur le sommet oppose
c====
c
      larete = areint(1)
      if ( somare(1,larete).eq.listso(iaux4(1)) ) then
        sm(1) = np2are(larete)
        sm(2) = np2are(areint(2))
      else
        sm(1) = np2are(areint(2))
        sm(2) = np2are(larete)
      endif
c
c====
c 7. Interpolation
c====
c
      if ( codret.eq.0 ) then
c
      do 70 , iaux = 1 , 2
c
        profho(sm(iaux)) = 1
cgn        write (ulsort,*) 'sm =',sm(iaux)
c
        listns( 1) = listso(iaux1(iaux))
        listns( 2) = listso(iaux2(iaux))
        listns( 3) = listso(iaux3(iaux))
        listns( 4) = listso(iaux4(iaux))
        listns( 5) = listso(jaux1(iaux))
        listns( 6) = listso(jaux2(iaux))
        listns( 7) = listso(jaux3(iaux))
        listns( 8) = listso(jaux4(iaux))
        listns( 9) = np2are(listar(kaux1(iaux)))
        listns(10) = np2are(listar(kaux2(iaux)))
        listns(11) = np2are(listar(kaux3(iaux)))
        listns(12) = np2are(listar(kaux4(iaux)))
        listns(13) = np2are(listar(laux1(iaux)))
        listns(14) = np2are(listar(laux2(iaux)))
        listns(15) = np2are(listar(laux3(iaux)))
        listns(16) = np2are(listar(laux4(iaux)))
        listns(17) = np2are(listar(maux1))
        listns(18) = np2are(listar(maux2))
        listns(19) = np2are(listar(maux3))
        listns(20) = np2are(listar(maux4))
cgn        write (ulsort,90002) 'listns  1- 8',(listns(jaux),jaux=1,8)
cgn        write (ulsort,90002) 'listns  9-16',(listns(jaux),jaux=9,16)
cgn        write (ulsort,90002) 'listns 17-20',(listns(jaux),jaux=17,20)
cgn        write (ulsort,*) listar(kaux1(iaux)),
cgn     >             listar(kaux2(iaux)),
cgn     >             listar(kaux3(iaux)),
cgn     >             listar(kaux4(iaux))
cgn        write (ulsort,*) listar(laux1(iaux)),
cgn     >             listar(laux2(iaux)),
cgn     >             listar(laux3(iaux)),
cgn     >             listar(laux4(iaux))
c
        do 71, nuv = 1 , nbfop2

c
cgn          do 711 , jaux =1 ,20
cgn        write (ulsort,90014) listns(jaux), vap2ho(nuv,listns(jaux))
cgn  711 continue
          vap2ho(nuv,sm(iaux)) =
     >              - nfstr2 * ( vap2ho(nuv,listns(1))
     >                         + vap2ho(nuv,listns(2))
     >                         + vap2ho(nuv,listns(3))
     >                         + vap2ho(nuv,listns(4)) )
     >              - cqstr2 * ( vap2ho(nuv,listns(5))
     >                         + vap2ho(nuv,listns(6))
     >                         + vap2ho(nuv,listns(7))
     >                         + vap2ho(nuv,listns(8)) )
     >              + trshu  * ( vap2ho(nuv,listns(9))
     >                         + vap2ho(nuv,listns(10))
     >                         + vap2ho(nuv,listns(11))
     >                         + vap2ho(nuv,listns(12)) )
     >              + unshu  * ( vap2ho(nuv,listns(13))
     >                         + vap2ho(nuv,listns(14))
     >                         + vap2ho(nuv,listns(15))
     >                         + vap2ho(nuv,listns(16)) )
     >              + trssz  * ( vap2ho(nuv,listns(17))
     >                         + vap2ho(nuv,listns(18))
     >                         + vap2ho(nuv,listns(19))
     >                         + vap2ho(nuv,listns(20)) )
c
cgn        write (ulsort,*) 'vap2ho(nuv,',sm(iaux),') =',vap2ho(nuv,sm(iaux))
   71 continue
c
   70 continue
c
      endif
c
c====
c 8. La fin
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
