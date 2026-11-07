      subroutine pcs2h3 ( nbfop2, profho, vap2ho,
     >                    somare, np2are,
     >                    listso, listno,
     >                    nbarhi, areint,
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
c    interpolation p2/iso-p2 sur les noeuds - decoupage Hexaedres - 3
c                   -                                   -           -
c    Du centre aux sommets (selon 2 ou 3 aretes)
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
c . listso . e   .    8   . Liste des sommets ordonnes de l'hexaedre   .
c . listno . e   .   12   . Liste des noeuds ordonnees de l'hexaedre   .
c . nbarhi . e   .   1    . nombre d'aretes internes                   .
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
#include "fracti.h"
#include "fractj.h"
c
      character*6 nompro
      parameter ( nompro = 'PCS2H3' )
c
#include "nblang.h"
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
      integer listso(8), listno(12)
      integer nbarhi, areint(nbarhi)
c
      double precision vap2ho(nbfop2,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
cgn      integer jaux
      integer nusomm, larete
      integer listns(20)
      integer sm, nuv
      integer iaux1, iaux2, iaux3, iaux4, iaux5, iaux6
c
      integer nbmess
      parameter ( nbmess = 100 )
      character*80 texte(nblang,nbmess)
c
c ______________________________________________________________________
c
#include "impr01.h"
c
#include "impr03.h"
c
cgn        write (ulsort,texte(langue,1)) 'Entree', nompro
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'listso', listso
      write (ulsort,90002) 'listno  1-8', (listno(iaux),iaux=1,8)
      write (ulsort,90002) 'listno 9-12', (listno(iaux),iaux=9,12)
#endif
c
c    On passe en revue tous les sommets
c    Ils sont parcourus dans l'ordre de leur numerotation de reference
c
      do 10 , nusomm = 1 , 8
cgn      write(6,*) 'Dans pcs2h3, nusomm =',nusomm
c
c====
c 1. Le sommet dont on part et ses plus proches voisins
c====
c
      iaux1 = nusomm
      if ( nusomm.eq.1 ) then
        iaux2 = 2
        iaux3 = 4
        iaux4 = 6
      elseif ( nusomm.eq.2 ) then
        iaux2 = 1
        iaux3 = 3
        iaux4 = 5
      elseif ( nusomm.eq.3 ) then
        iaux2 = 2
        iaux3 = 4
        iaux4 = 8
      elseif ( nusomm.eq.4 ) then
        iaux2 = 1
        iaux3 = 3
        iaux4 = 7
      elseif ( nusomm.eq.5 ) then
        iaux2 = 2
        iaux3 = 6
        iaux4 = 8
      elseif ( nusomm.eq.6 ) then
        iaux2 = 1
        iaux3 = 5
        iaux4 = 7
      elseif ( nusomm.eq.7 ) then
        iaux2 = 4
        iaux3 = 6
        iaux4 = 8
      else
        iaux2 = 3
        iaux3 = 5
        iaux4 = 7
      endif
c
      listns(1) = listso(iaux1)
      listns(2) = listso(iaux2)
      listns(3) = listso(iaux3)
      listns(4) = listso(iaux4)
c
c====
c 2. Le sommet oppose et ses plus proches voisins
c====
c
      iaux1 = 9-nusomm
      if ( nusomm.eq.1 ) then
        iaux2 = 3
        iaux3 = 5
        iaux4 = 7
      elseif ( nusomm.eq.2 ) then
        iaux2 = 4
        iaux3 = 6
        iaux4 = 8
      elseif ( nusomm.eq.3 ) then
        iaux2 = 1
        iaux3 = 5
        iaux4 = 7
      elseif ( nusomm.eq.4 ) then
        iaux2 = 2
        iaux3 = 6
        iaux4 = 8
      elseif ( nusomm.eq.5 ) then
        iaux2 = 1
        iaux3 = 3
        iaux4 = 7
      elseif ( nusomm.eq.6 ) then
        iaux2 = 2
        iaux3 = 4
        iaux4 = 8
      elseif ( nusomm.eq.7 ) then
        iaux2 = 1
        iaux3 = 3
        iaux4 = 5
      else
        iaux2 = 2
        iaux3 = 4
        iaux4 = 6
      endif
c
      listns(8) = listso(iaux1)
      listns(5) = listso(iaux2)
      listns(6) = listso(iaux3)
      listns(7) = listso(iaux4)
c
c====
c 3. Les noeuds milieux les plus proches
c====
c
      if ( nusomm.eq.1 ) then
        iaux1 = 1
        iaux2 = 2
        iaux3 = 5
      elseif ( nusomm.eq.2 ) then
        iaux1 = 1
        iaux2 = 3
        iaux3 = 6
      elseif ( nusomm.eq.3 ) then
        iaux1 = 3
        iaux2 = 4
        iaux3 = 8
      elseif ( nusomm.eq.4 ) then
        iaux1 = 2
        iaux2 = 4
        iaux3 = 7
      elseif ( nusomm.eq.5 ) then
        iaux1 = 6
        iaux2 = 9
        iaux3 = 11
      elseif ( nusomm.eq.6 ) then
        iaux1 = 5
        iaux2 = 9
        iaux3 = 10
      elseif ( nusomm.eq.7 ) then
        iaux1 = 7
        iaux2 = 10
        iaux3 = 12
      else
        iaux1 = 8
        iaux2 = 11
        iaux3 = 12
      endif
c
      listns( 9) = listno(iaux1)
      listns(10) = listno(iaux2)
      listns(11) = listno(iaux3)
c
c====
c 4. Les noeuds milieux intermediaires
c====
c
      if ( nusomm.eq.1 .or. nusomm.eq.8 ) then
        iaux1 = 3
        iaux2 = 6
        iaux3 = 9
        iaux4 = 10
        iaux5 = 7
        iaux6 = 4
      elseif ( nusomm.eq.2 .or. nusomm.eq.7 ) then
        iaux1 = 2
        iaux2 = 4
        iaux3 = 8
        iaux4 = 11
        iaux5 = 9
        iaux6 = 5
      elseif ( nusomm.eq.3 .or. nusomm.eq.6) then
        iaux1 = 1
        iaux2 = 2
        iaux3 = 7
        iaux4 = 12
        iaux5 = 11
        iaux6 = 6
      else
        iaux1 = 1
        iaux2 = 3
        iaux3 = 8
        iaux4 = 12
        iaux5 = 10
        iaux6 = 5
      endif
c
      listns(12) = listno(iaux1)
      listns(13) = listno(iaux2)
      listns(14) = listno(iaux3)
      listns(15) = listno(iaux4)
      listns(16) = listno(iaux5)
      listns(17) = listno(iaux6)
c
c====
c 5. Les noeuds milieux les plus eloignes
c====
c
      if ( nusomm.eq.1 ) then
        iaux1 = 8
        iaux2 = 11
        iaux3 = 12
      elseif ( nusomm.eq.2 ) then
        iaux1 = 7
        iaux2 = 10
        iaux3 = 12
      elseif ( nusomm.eq.3 ) then
        iaux1 = 5
        iaux2 = 9
        iaux3 = 10
      elseif ( nusomm.eq.4 ) then
        iaux1 = 6
        iaux2 = 9
        iaux3 = 11
      elseif ( nusomm.eq.5 ) then
        iaux1 = 2
        iaux2 = 4
        iaux3 = 7
      elseif ( nusomm.eq.6 ) then
        iaux1 = 3
        iaux2 = 4
        iaux3 = 8
      elseif ( nusomm.eq.7 ) then
        iaux1 = 1
        iaux2 = 3
        iaux3 = 6
      else
        iaux1 = 1
        iaux2 = 2
        iaux3 = 5
      endif
c
      listns(18) = listno(iaux1)
      listns(19) = listno(iaux2)
      listns(20) = listno(iaux3)
c
c====
c 6. L'arete concernee : celle des aretes internes qui demarrent
c    sur le sommet en cours
c====
c
      do 62 , iaux = 1 , nbarhi
        larete = areint(iaux)
        if ( somare(1,larete).eq.listns(1) ) then
          sm = np2are(larete)
          goto 620
        endif
  62  continue
      write(ulsort,*) nompro//' - aucune arete interne ne correspond ?'
      codret = 62
c
  620 continue
c
c====
c 7. Interpolation
c====
c
      if ( codret.eq.0 ) then
c
      profho(sm) = 1
c
      do 71, nuv = 1 , nbfop2
cgn          do 711 , jaux =1 ,20
cgn        write(*,90014) listns(jaux), vap2ho(nuv,listns(jaux))
cgn  711 continue
c
        vap2ho(nuv,sm) = - v7s128 * ( vap2ho(nuv,listns(1))
     >                              + vap2ho(nuv,listns(2))
     >                              + vap2ho(nuv,listns(3))
     >                              + vap2ho(nuv,listns(4)) )
     >                   - qzs128 * ( vap2ho(nuv,listns(5))
     >                              + vap2ho(nuv,listns(6))
     >                              + vap2ho(nuv,listns(7)) )
     >                   - ses128 *   vap2ho(nuv,listns(8))
     >                   + v7st64 * ( vap2ho(nuv,listns(9))
     >                              + vap2ho(nuv,listns(10))
     >                              + vap2ho(nuv,listns(11)) )
     >                   + nfst64 * ( vap2ho(nuv,listns(12))
     >                              + vap2ho(nuv,listns(13))
     >                              + vap2ho(nuv,listns(14))
     >                              + vap2ho(nuv,listns(15))
     >                              + vap2ho(nuv,listns(16))
     >                              + vap2ho(nuv,listns(17)) )
     >                   + trst64 * ( vap2ho(nuv,listns(18))
     >                              + vap2ho(nuv,listns(19))
     >                              + vap2ho(nuv,listns(20)) )
c
cgn        write(*,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
   71 continue
c
      endif
c
   10 continue
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
