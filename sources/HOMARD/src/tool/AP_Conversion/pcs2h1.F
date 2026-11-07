      subroutine pcs2h1 ( nbfop2, profho, vap2ho,
     >                    somare, np2are,
     >                    hetqua, arequa, filqua,
     >                    quahex,
     >                    lehexa, listso, listno,
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
c    interpolation p2 sur les noeuds - decoupage des Hexaedres - 1
c                   -                                -           -
c    Du noeud central au milieu des faces
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
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . lehexa . e   .    1   . hexaedre a traiter                         .
c . listso . e   .    8   . liste des sommets de l'hexaedre            .
c . listno . e   .   12   . liste des noeuds de l'hexaedre             .
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
#include "fractf.h"
#include "fractg.h"
#include "fracth.h"
c
      character*6 nompro
      parameter ( nompro = 'PCS2H1' )
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
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
      integer quahex(nbhecf,6)
      integer lehexa
      integer listso(8), listno(12)
      integer nbarhi, areint(nbarhi)
c
      double precision vap2ho(nbfop2,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nuface, laface, larete
      integer listns(20)
      integer sm, nuv
      integer iaux1, iaux2, iaux3, iaux4
c
      integer nbmess
      parameter ( nbmess = 100 )
      character*80 texte(nblang,nbmess)
c
#include "impr01.h"
c
#include "impr03.h"
c ______________________________________________________________________
c
cgn        write (ulsort,texte(langue,1)) 'Entree', nompro
#ifdef _DEBUG_HOMARD_
      if ( lehexa.eq.2) then
      write (ulsort,90002) 'listso', listso
      write (ulsort,90002) 'listno  1-8', (listno(iaux),iaux=1,8)
      write (ulsort,90002) 'listno 9-12', (listno(iaux),iaux=9,12)
      endif
#endif
c    On passe en revue toutes les faces coupees
c
      do 10 , nuface = 1 , 6
c
      laface = quahex(lehexa,nuface)
cgn      if ( lehexa.eq.2) then
cgn      write (ulsort,90002) 'nuface, laface, etat',
cgn     >                      nuface,laface,hetqua(laface)
cgn      endif
cgn      write (ulsort,*) 'Dans pcs2h1, nuface =',nuface
cgn      write (ulsort,*) 'Dans pcs2h1, laface =',laface
cgn      write (ulsort,*) 'Dans pcs2h1, etat =',hetqua(laface)
c
      if ( ( mod(hetqua(laface),100).eq.4 ) .or.
     >     ( mod(hetqua(laface),100).ge.41 .and.
     >       mod(hetqua(laface),100).le.44 ) .or.
     >     ( mod(hetqua(laface),100).eq.99 ) ) then
c
c====
c 1. Les sommets de la face
c====
c
      if ( nuface.eq.1 ) then
        iaux1 = 1
        iaux2 = 2
        iaux3 = 3
        iaux4 = 4
      elseif ( nuface.eq.2 ) then
        iaux1 = 1
        iaux2 = 2
        iaux3 = 5
        iaux4 = 6
      elseif ( nuface.eq.3 ) then
        iaux1 = 1
        iaux2 = 4
        iaux3 = 6
        iaux4 = 7
      elseif ( nuface.eq.4 ) then
        iaux1 = 2
        iaux2 = 3
        iaux3 = 5
        iaux4 = 8
      elseif ( nuface.eq.5 ) then
        iaux1 = 3
        iaux2 = 4
        iaux3 = 7
        iaux4 = 8
      elseif ( nuface.eq.6 ) then
        iaux1 = 5
        iaux2 = 6
        iaux3 = 7
        iaux4 = 8
      endif
c
      listns(1) = listso(iaux1)
      listns(2) = listso(iaux2)
      listns(3) = listso(iaux3)
      listns(4) = listso(iaux4)
c
c====
c 2. Les sommets de la face opposee
c====
c
      if ( nuface.eq.1 ) then
        iaux1 = 5
        iaux2 = 6
        iaux3 = 7
        iaux4 = 8
      elseif ( nuface.eq.2 ) then
        iaux1 = 3
        iaux2 = 4
        iaux3 = 7
        iaux4 = 8
      elseif ( nuface.eq.3 ) then
        iaux1 = 2
        iaux2 = 3
        iaux3 = 5
        iaux4 = 8
      elseif ( nuface.eq.4 ) then
        iaux1 = 1
        iaux2 = 4
        iaux3 = 6
        iaux4 = 7
      elseif ( nuface.eq.5 ) then
        iaux1 = 1
        iaux2 = 2
        iaux3 = 5
        iaux4 = 6
      elseif ( nuface.eq.6 ) then
        iaux1 = 1
        iaux2 = 2
        iaux3 = 3
        iaux4 = 4
      endif
c
      listns(5) = listso(iaux1)
      listns(6) = listso(iaux2)
      listns(7) = listso(iaux3)
      listns(8) = listso(iaux4)
c
c====
c 3. Les noeuds de la face
c====
c
      if ( nuface.eq.1 ) then
        iaux1 = 1
        iaux2 = 2
        iaux3 = 3
        iaux4 = 4
      elseif ( nuface.eq.2 ) then
        iaux1 = 1
        iaux2 = 5
        iaux3 = 6
        iaux4 = 9
      elseif ( nuface.eq.3 ) then
        iaux1 = 2
        iaux2 = 5
        iaux3 = 10
        iaux4 = 7
      elseif ( nuface.eq.4 ) then
        iaux1 = 3
        iaux2 = 8
        iaux3 = 11
        iaux4 = 6
      elseif ( nuface.eq.5 ) then
        iaux1 = 4
        iaux2 = 7
        iaux3 = 12
        iaux4 = 8
      elseif ( nuface.eq.6 ) then
        iaux1 = 9
        iaux2 = 10
        iaux3 = 11
        iaux4 = 12
      endif
c
      listns( 9) = listno(iaux1)
      listns(10) = listno(iaux2)
      listns(11) = listno(iaux3)
      listns(12) = listno(iaux4)
c
c====
c 4. Les noeuds milieux intermediaires
c====
c
      if ( nuface.eq.1 .or. nuface.eq.6 ) then
        iaux1 = 5
        iaux2 = 6
        iaux3 = 7
        iaux4 = 8
      elseif ( nuface.eq.2 .or. nuface.eq.5 ) then
        iaux1 = 2
        iaux2 = 3
        iaux3 = 11
        iaux4 = 10
      elseif ( nuface.eq.3 .or. nuface.eq.4 ) then
        iaux1 = 1
        iaux2 = 4
        iaux3 = 12
        iaux4 = 9
      endif
c
      listns(13) = listno(iaux1)
      listns(14) = listno(iaux2)
      listns(15) = listno(iaux3)
      listns(16) = listno(iaux4)
c
c====
c 5. Les noeuds de la face opposee
c====
c
      if ( nuface.eq.1 ) then
        iaux1 = 9
        iaux2 = 10
        iaux3 = 11
        iaux4 = 12
      elseif ( nuface.eq.2 ) then
        iaux1 = 4
        iaux2 = 7
        iaux3 = 12
        iaux4 = 8
      elseif ( nuface.eq.3 ) then
        iaux1 = 3
        iaux2 = 8
        iaux3 = 11
        iaux4 = 6
      elseif ( nuface.eq.4 ) then
        iaux1 = 2
        iaux2 = 5
        iaux3 = 10
        iaux4 = 7
      elseif ( nuface.eq.5 ) then
        iaux1 = 1
        iaux2 = 5
        iaux3 = 6
        iaux4 = 9
      elseif ( nuface.eq.6 ) then
        iaux1 = 1
        iaux2 = 2
        iaux3 = 3
        iaux4 = 4
      endif
c
      listns(17) = listno(iaux1)
      listns(18) = listno(iaux2)
      listns(19) = listno(iaux3)
      listns(20) = listno(iaux4)
c
c====
c 6. L'arete concernee et donc le noeud au milieu
c====
c 6.1. ==> Le noeud au milieu de la face
c
      call utnmqu ( laface, jaux,
     >              somare, arequa, filqua )
cgn      write (ulsort,90002) 'noeud au milieu de la face', jaux
c
c 6.2. ==> L'arete concernee : celle des aretes internes qui demarre
c          sur le milieu de la face
c
cgn      write (ulsort,90002) 'nbarhi', nbarhi
      do 62 , iaux = 1 , nbarhi
        larete = areint(iaux)
cgn      write (ulsort,90002) 'larete', larete,somare(1,larete),somare(2,larete)
        if ( somare(1,larete).eq.jaux ) then
          sm = np2are(larete)
          goto 620
        endif
   62 continue
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
     >                              + vap2ho(nuv,listns(2))
     >                              + vap2ho(nuv,listns(3))
     >                              + vap2ho(nuv,listns(4)) )
     >                   - cqstr2 * ( vap2ho(nuv,listns(5))
     >                              + vap2ho(nuv,listns(6))
     >                              + vap2ho(nuv,listns(7))
     >                              + vap2ho(nuv,listns(8)) )
     >                   + trshu  * ( vap2ho(nuv,listns(9))
     >                              + vap2ho(nuv,listns(10))
     >                              + vap2ho(nuv,listns(11))
     >                              + vap2ho(nuv,listns(12)) )
     >                   + trssz  * ( vap2ho(nuv,listns(13))
     >                              + vap2ho(nuv,listns(14))
     >                              + vap2ho(nuv,listns(15))
     >                              + vap2ho(nuv,listns(16)) )
     >                   + unshu  * ( vap2ho(nuv,listns(17))
     >                              + vap2ho(nuv,listns(18))
     >                              + vap2ho(nuv,listns(19))
     >                              + vap2ho(nuv,listns(20)) )
c
cgn        write (ulsort,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
   71 continue
c
      endif
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
