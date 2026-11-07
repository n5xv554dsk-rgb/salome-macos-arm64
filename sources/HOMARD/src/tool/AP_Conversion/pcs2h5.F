      subroutine pcs2h5 ( nbfop2, profho, vap2ho,
     >                    somare, np2are,
     >                    hetqua,
     >                    quahex,
     >                    lehexa, listso, listno,
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
c    interpolation p2 sur les noeuds - decoupage Hexaedres - 5
c                   -                            -           -
c    D'un milieu de face a un sommet (par face)
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
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . lehexa . e   .    1   . hexaedre a traiter                         .
c . listso . e   .    8   . liste des sommets de l'hexaedre            .
c . listno . e   .   12   . liste des noeuds de l'hexaedre             .
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
#include "fractf.h"
#include "fractg.h"
#include "fracth.h"
c
      character*6 nompro
      parameter ( nompro = 'PCS2H5' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombqu.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(*)
      integer somare(2,nbarto), np2are(nbarto)
      integer hetqua(nbquto)
      integer quahex(nbhecf,6)
      integer lehexa
      integer listso(8), listno(12)
      integer areint(4)
c
      double precision vap2ho(nbfop2,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nuface, etahex
      integer nusomm, laface, larete
      integer listns(20)
      integer sm, nuv
      integer iaux1, iaux2, iaux3, iaux4
c
      integer nbmess
      parameter ( nbmess = 100 )
      character*80 texte(nblang,nbmess)
c
#include "impr03.h"
c ______________________________________________________________________
c
#include "impr01.h"
c
cgn        write (ulsort,texte(langue,1)) 'Entree', nompro
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'listso', listso
      write (ulsort,90002) 'listno  1-8', (listno(iaux),iaux=1,8)
      write (ulsort,90002) 'listno 9-12', (listno(iaux),iaux=9,12)
#endif
c
c====
c 0. Reperage de la face coupees
c====
c
      do 11 , nuface = 1 , 6
c
        laface = quahex(lehexa,nuface)
        if ( mod(hetqua(laface),100).eq.4 ) then
          etahex = 40 + nuface
        endif
c
   11 continue
c
      if ( etahex.lt.41 .or. etahex.gt.46 ) then
        write(ulsort,*) 'Pb. Dans pcs2h5, etahex =',etahex
        codret = 11
      endif
c
c    On passe en revue tous les sommets
c    Ils sont parcourus dans l'ordre des aretes a1, a2, a3 et a4 de
c    la pyramide de base.
c
      do 10 , nusomm = 1 , 4
cgn      write(6,*) 'Dans pcs2h5, nusomm =',nusomm
c
c====
c 1. Les 2 sommets les plus proches et les 2 les plus eloignes
c    Remarques :
c    . L'un des sommets les plus proches est celui ou aboutit l'arete
c      du noeud milieu a interpoler (iaux1)
c    . L'autre sommet le plus proche est la 2nde extremite de l'arete
c      de l'hexaedre qui relie ce sommet a la face coupee (iaux2)
c    . Les sommets eloignes sont deduits par la regle :
c          somme des numeros locaux de deux sommets opposes = 9
c====
c
      if ( etahex.eq.41 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 6
          iaux2 = 1
        elseif ( nusomm.eq.2 ) then
          iaux1 = 5
          iaux2 = 2
        elseif ( nusomm.eq.3 ) then
          iaux1 = 8
          iaux2 = 3
        else
          iaux1 = 7
          iaux2 = 4
        endif
      elseif ( etahex.eq.42 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 3
          iaux2 = 2
        elseif ( nusomm.eq.2 ) then
          iaux1 = 4
          iaux2 = 1
        elseif ( nusomm.eq.3 ) then
          iaux1 = 7
          iaux2 = 6
        else
          iaux1 = 8
          iaux2 = 5
        endif
      elseif ( etahex.eq.43 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 2
          iaux2 = 1
        elseif ( nusomm.eq.2 ) then
          iaux1 = 3
          iaux2 = 4
        elseif ( nusomm.eq.3 ) then
          iaux1 = 8
          iaux2 = 7
        else
          iaux1 = 5
          iaux2 = 6
        endif
      elseif ( etahex.eq.44 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 1
          iaux2 = 2
        elseif ( nusomm.eq.2 ) then
          iaux1 = 6
          iaux2 = 5
        elseif ( nusomm.eq.3 ) then
          iaux1 = 7
          iaux2 = 8
        else
          iaux1 = 4
          iaux2 = 3
        endif
      elseif ( etahex.eq.45 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 1
          iaux2 = 4
        elseif ( nusomm.eq.2 ) then
          iaux1 = 2
          iaux2 = 3
        elseif ( nusomm.eq.3 ) then
          iaux1 = 5
          iaux2 = 8
        else
          iaux1 = 6
          iaux2 = 7
        endif
      else
        if ( nusomm.eq.1 ) then
          iaux1 = 2
          iaux2 = 5
        elseif ( nusomm.eq.2 ) then
          iaux1 = 1
          iaux2 = 6
        elseif ( nusomm.eq.3 ) then
          iaux1 = 4
          iaux2 = 7
        else
          iaux1 = 3
          iaux2 = 8
        endif
      endif
c
      listns(1) = listso(iaux1)
      listns(2) = listso(iaux2)
      listns(7) = listso(9-iaux1)
      listns(8) = listso(9-iaux2)
c
c====
c 2. Les sommets intermediaires
c    Il suffit d'en noter 2 sur la meme arete de l'hexaedre, les deux
c    autres sont deduits par la regle :
c          somme des numeros locaux de deux sommets opposes = 9
c====
c
      if ( etahex.eq.41 ) then
        if ( nusomm.eq.1 .or. nusomm.eq.3 ) then
          iaux1 = 2
          iaux2 = 5
        else
          iaux1 = 1
          iaux2 = 6
        endif
      elseif ( etahex.eq.42 ) then
        if ( nusomm.eq.1 .or. nusomm.eq.3 ) then
          iaux1 = 1
          iaux2 = 4
        else
          iaux1 = 2
          iaux2 = 3
        endif
      elseif ( etahex.eq.43 .or. etahex.eq.44 ) then
        if ( nusomm.eq.1 .or. nusomm.eq.3 ) then
          iaux1 = 3
          iaux2 = 4
        else
          iaux1 = 1
          iaux2 = 2
        endif
      elseif ( etahex.eq.45 ) then
        if ( nusomm.eq.1 .or. nusomm.eq.3 ) then
          iaux1 = 2
          iaux2 = 3
        else
          iaux1 = 1
          iaux2 = 4
        endif
      else
        if ( nusomm.eq.1 .or. nusomm.eq.3 ) then
          iaux1 = 1
          iaux2 = 6
        else
          iaux1 = 2
          iaux2 = 5
        endif
      endif
c
      listns(3) = listso(iaux1)
      listns(4) = listso(iaux2)
      listns(5) = listso(9-iaux1)
      listns(6) = listso(9-iaux2)
c
c====
c 3. Le noeud le plus proche, le plus eloigne et les 2 coplanaires
c    dans un plan parallelle a la face coupee
c    Remarques :
c    . Le noeud le plus proche est celui au milieu de l'arete
c      de l'hexaedre qui relie ce sommet a la face coupee (iaux1)
c    . Le noeud eloigne est deduit par la regle :
c          somme des numeros locaux de deux noeuds opposes = 13
c    . Le dernier noeud est deduit par la regle :
c          somme des numeros locaux de deux noeuds opposes = 13
c====
c
      if ( etahex.eq.41 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 5
          iaux2 = 6
        elseif ( nusomm.eq.2 ) then
          iaux1 = 6
          iaux2 = 5
        elseif ( nusomm.eq.3 ) then
          iaux1 = 8
          iaux2 = 6
        else
          iaux1 = 7
          iaux2 = 5
        endif
      elseif ( etahex.eq.42 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 3
          iaux2 = 2
        elseif ( nusomm.eq.2 ) then
          iaux1 = 2
          iaux2 = 3
        elseif ( nusomm.eq.3 ) then
          iaux1 = 10
          iaux2 = 2
        else
          iaux1 = 11
          iaux2 = 3
        endif
      elseif ( etahex.eq.43 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 1
          iaux2 = 4
        elseif ( nusomm.eq.2 ) then
          iaux1 = 4
          iaux2 = 1
        elseif ( nusomm.eq.3 ) then
          iaux1 = 12
          iaux2 = 4
        else
          iaux1 = 9
          iaux2 = 1
        endif
      elseif ( etahex.eq.44 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 1
          iaux2 = 4
        elseif ( nusomm.eq.2 ) then
          iaux1 = 9
          iaux2 = 1
        elseif ( nusomm.eq.3 ) then
          iaux1 = 12
          iaux2 = 4
        else
          iaux1 = 4
          iaux2 = 1
        endif
      elseif ( etahex.eq.45 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 2
          iaux2 = 3
        elseif ( nusomm.eq.2 ) then
          iaux1 = 3
          iaux2 = 2
        elseif ( nusomm.eq.3 ) then
          iaux1 = 11
          iaux2 = 3
        else
          iaux1 = 10
          iaux2 = 2
        endif
      else
        if ( nusomm.eq.1 ) then
          iaux1 = 6
          iaux2 = 5
        elseif ( nusomm.eq.2 ) then
          iaux1 = 5
          iaux2 = 6
        elseif ( nusomm.eq.3 ) then
          iaux1 = 7
          iaux2 = 5
        else
          iaux1 = 8
          iaux2 = 6
        endif
      endif
c
      listns( 9) = listno(iaux1)
      listns(20) = listno(13-iaux1)
      listns(18) = listno(iaux2)
      listns(19) = listno(13-iaux2)
c
c====
c 4. Les 4 noeuds intermediaires les plus proches
c    et les 4 noeuds intermediaires les plus eloignes
c====
c
      if ( etahex.eq.41 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 1
          iaux2 = 2
          iaux3 = 9
          iaux4 = 10
        elseif ( nusomm.eq.2 ) then
          iaux1 = 1
          iaux2 = 3
          iaux3 = 9
          iaux4 = 11
        elseif ( nusomm.eq.3 ) then
          iaux1 = 3
          iaux2 = 4
          iaux3 = 11
          iaux4 = 12
        else
          iaux1 = 2
          iaux2 = 4
          iaux3 = 10
          iaux4 = 12
        endif
      elseif ( etahex.eq.42 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 1
          iaux2 = 4
          iaux3 = 6
          iaux4 = 8
        elseif ( nusomm.eq.2 ) then
          iaux1 = 1
          iaux2 = 4
          iaux3 = 5
          iaux4 = 7
        elseif ( nusomm.eq.3 ) then
          iaux1 = 5
          iaux2 = 7
          iaux3 = 9
          iaux4 = 12
        else
          iaux1 = 6
          iaux2 = 8
          iaux3 = 9
          iaux4 = 12
        endif
      elseif ( etahex.eq.43 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 2
          iaux2 = 3
          iaux3 = 5
          iaux4 = 6
        elseif ( nusomm.eq.2 ) then
          iaux1 = 2
          iaux2 = 3
          iaux3 = 7
          iaux4 = 8
        elseif ( nusomm.eq.3 ) then
          iaux1 = 7
          iaux2 = 8
          iaux3 = 10
          iaux4 = 11
        else
          iaux1 = 5
          iaux2 = 6
          iaux3 = 10
          iaux4 = 11
        endif
      elseif ( etahex.eq.44 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 2
          iaux2 = 3
          iaux3 = 5
          iaux4 = 6
        elseif ( nusomm.eq.2 ) then
          iaux1 = 5
          iaux2 = 6
          iaux3 = 10
          iaux4 = 11
        elseif ( nusomm.eq.3 ) then
          iaux1 = 7
          iaux2 = 8
          iaux3 = 10
          iaux4 = 11
        else
          iaux1 = 2
          iaux2 = 3
          iaux3 = 7
          iaux4 = 8
        endif
      elseif ( etahex.eq.45 ) then
        if ( nusomm.eq.1 ) then
          iaux1 = 1
          iaux2 = 4
          iaux3 = 5
          iaux4 = 7
        elseif ( nusomm.eq.2 ) then
          iaux1 = 1
          iaux2 = 6
          iaux3 = 4
          iaux4 = 8
        elseif ( nusomm.eq.3 ) then
          iaux1 = 6
          iaux2 = 8
          iaux3 = 9
          iaux4 = 12
        else
          iaux1 = 5
          iaux2 = 7
          iaux3 = 9
          iaux4 = 12
        endif
      else
        if ( nusomm.eq.1 ) then
          iaux1 = 1
          iaux2 = 3
          iaux3 = 9
          iaux4 = 11
        elseif ( nusomm.eq.2 ) then
          iaux1 = 1
          iaux2 = 2
          iaux3 = 9
          iaux4 = 10
        elseif ( nusomm.eq.3 ) then
          iaux1 = 2
          iaux2 = 4
          iaux3 = 10
          iaux4 = 12
        else
          iaux1 = 3
          iaux2 = 4
          iaux3 = 11
          iaux4 = 12
        endif
      endif
c
      listns(10) = listno(iaux1)
      listns(11) = listno(iaux2)
      listns(12) = listno(iaux3)
      listns(13) = listno(iaux4)
c
      listns(14) = listno(13-iaux1)
      listns(15) = listno(13-iaux2)
      listns(16) = listno(13-iaux3)
      listns(17) = listno(13-iaux4)
c
c====
c 5. L'arete concernee : celle des aretes internes qui demarrent
c    ou finissent sur le sommet en cours
c====
c
cgn      write (ulsort,90002) 'listns(1)', listns(1)
      do 62 , iaux = 1 , 4
        larete = areint(iaux)
        if ( ( somare(1,larete).eq.listns(1) ) .or.
     >       ( somare(2,larete).eq.listns(1) ) ) then
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
cgn      write (ulsort,90002) 'sm', sm
      profho(sm) = 1
c
cgn        write (ulsort,90002) 'listns  1- 8',(listns(jaux),jaux=1,8)
cgn        write (ulsort,90002) 'listns  9-16',(listns(jaux),jaux=9,16)
cgn        write (ulsort,90002) 'listns 17-20',(listns(jaux),jaux=17,20)
c
      do 71, nuv = 1 , nbfop2
cgn          do 711 , jaux =1 ,20
cgn        write (ulsort,90014) listns(jaux), vap2ho(nuv,listns(jaux))
cgn  711 continue
c
          vap2ho(nuv,sm) = - nfstr2 * ( vap2ho(nuv,listns(1))
     >                                + vap2ho(nuv,listns(2)) )
     >                     - trssz  * ( vap2ho(nuv,listns(3))
     >                                + vap2ho(nuv,listns(4))
     >                                + vap2ho(nuv,listns(5))
     >                                + vap2ho(nuv,listns(6)) )
     >                     - trstr2 * ( vap2ho(nuv,listns(7))
     >                                + vap2ho(nuv,listns(8)) )
     >                     + nessz  *   vap2ho(nuv,listns(9))
     >                     + nfstr2 * ( vap2ho(nuv,listns(10))
     >                                + vap2ho(nuv,listns(11))
     >                                + vap2ho(nuv,listns(12))
     >                                + vap2ho(nuv,listns(13)) )
     >                     + trstr2 * ( vap2ho(nuv,listns(14))
     >                                + vap2ho(nuv,listns(15))
     >                                + vap2ho(nuv,listns(16))
     >                                + vap2ho(nuv,listns(17)) )
     >                     + trssz  * ( vap2ho(nuv,listns(18))
     >                                + vap2ho(nuv,listns(19)) )
     >                     + unssz  *   vap2ho(nuv,listns(20))
c
cgn        write (ulsort,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
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
