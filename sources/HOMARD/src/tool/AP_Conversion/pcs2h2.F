      subroutine pcs2h2 ( nbfop2, profho, vap2ho,
     >                    somare, np2are,
     >                    listso, listno,
     >                    tbarcp, nbarhi, areint,
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
c    interpolation p2 sur les noeuds - decoupage Hexaedres - 2
c                   -                            -           -
c    Du centre aux milieux d'aretes
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
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . listso . e   .    8   . liste des sommets de l'hexaedre            .
c . listno . e   .   12   . liste des noeuds de l'hexaedre             .
c . tbarcp . e   .  12    . 1/0 pour chaque arete coupee ou non        .
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
      parameter ( nompro = 'PCS2H2' )
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
      integer tbarcp(12), nbarhi, areint(nbarhi)
c
      double precision vap2ho(nbfop2,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
cgn      integer jaux
      integer larete
      integer listns(20)
      integer sm, nuv
      integer nuloar
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
      write (ulsort,90002) 'tbarcp  1-8', (tbarcp(iaux),iaux=1,8)
      write (ulsort,90002) 'tbarcp 9-12', (tbarcp(iaux),iaux=9,12)
#endif
c    On passe en revue toutes les aretes coupees
c
      do 10 , nuloar = 1 , 12
c
        if ( tbarcp(nuloar).eq.1 ) then
c
c====
c 1. Reperage des sommets et des noeuds
c====
c         le milieu de l'arete coupee
          listns( 9) = listno(nuloar)
c         le milieu de l'arete opposee
          listns(20) = listno(13-nuloar)
c
c 1.1. ==> Arete 1
c
          if ( nuloar.eq.1 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(1)
            listns( 2) = listso(2)
c           les autres sommets
            listns( 3) = listso(3)
            listns( 4) = listso(4)
            listns( 5) = listso(5)
            listns( 6) = listso(6)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(7)
            listns( 8) = listso(8)
c           les milieux des aretes proches
            listns(10) = listno( 2)
            listns(11) = listno( 3)
            listns(12) = listno( 5)
            listns(13) = listno( 6)
c           les milieux des aretes paralleles
            listns(14) = listno( 4)
            listns(15) = listno( 9)
c           les milieux des aretes moins proches
            listns(16) = listno( 7)
            listns(17) = listno( 8)
            listns(18) = listno(10)
            listns(19) = listno(11)
c
c 1.2. ==> Arete 2
c
          elseif ( nuloar.eq.2 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(1)
            listns( 2) = listso(4)
c           les autres sommets
            listns( 3) = listso(2)
            listns( 4) = listso(3)
            listns( 5) = listso(6)
            listns( 6) = listso(7)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(5)
            listns( 8) = listso(8)
c           les milieux des aretes proches
            listns(10) = listno( 1)
            listns(11) = listno( 4)
            listns(12) = listno( 5)
            listns(13) = listno( 7)
c           les milieux des aretes paralleles
            listns(14) = listno( 3)
            listns(15) = listno(10)
c           les milieux des aretes moins proches
            listns(16) = listno( 6)
            listns(17) = listno( 8)
            listns(18) = listno( 9)
            listns(19) = listno(12)
c
c 1.3. ==> Arete 3
c
          elseif ( nuloar.eq.3 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(2)
            listns( 2) = listso(3)
c           les autres sommets
            listns( 3) = listso(1)
            listns( 4) = listso(4)
            listns( 5) = listso(5)
            listns( 6) = listso(8)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(6)
            listns( 8) = listso(7)
c           les milieux des aretes proches
            listns(10) = listno( 1)
            listns(11) = listno( 4)
            listns(12) = listno( 6)
            listns(13) = listno( 8)
c           les milieux des aretes paralleles
            listns(14) = listno( 2)
            listns(15) = listno(11)
c           les milieux des aretes moins proches
            listns(16) = listno( 5)
            listns(17) = listno( 7)
            listns(18) = listno( 9)
            listns(19) = listno(12)
c
c 1.2. ==> Arete 4
c
          elseif ( nuloar.eq.4 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(3)
            listns( 2) = listso(4)
c           les autres sommets
            listns( 3) = listso(1)
            listns( 4) = listso(2)
            listns( 5) = listso(7)
            listns( 6) = listso(8)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(5)
            listns( 8) = listso(6)
c           les milieux des aretes proches
            listns(10) = listno( 2)
            listns(11) = listno( 3)
            listns(12) = listno( 7)
            listns(13) = listno( 8)
c           les milieux des aretes paralleles
            listns(14) = listno( 1)
            listns(15) = listno(12)
c           les milieux des aretes moins proches
            listns(16) = listno( 5)
            listns(17) = listno( 6)
            listns(18) = listno(10)
            listns(19) = listno(11)
c
c 1.5. ==> Arete 5
c
          elseif ( nuloar.eq.5 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(1)
            listns( 2) = listso(6)
c           les autres sommets
            listns( 3) = listso(2)
            listns( 4) = listso(4)
            listns( 5) = listso(5)
            listns( 6) = listso(7)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(3)
            listns( 8) = listso(8)
c           les milieux des aretes proches
            listns(10) = listno( 1)
            listns(11) = listno( 2)
            listns(12) = listno( 9)
            listns(13) = listno(10)
c           les milieux des aretes paralleles
            listns(14) = listno( 6)
            listns(15) = listno( 7)
c           les milieux des aretes moins proches
            listns(16) = listno( 3)
            listns(17) = listno( 4)
            listns(18) = listno(11)
            listns(19) = listno(12)
c
c 1.6. ==> Arete 6
c
          elseif ( nuloar.eq.6 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(2)
            listns( 2) = listso(5)
c           les autres sommets
            listns( 3) = listso(1)
            listns( 4) = listso(3)
            listns( 5) = listso(6)
            listns( 6) = listso(8)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(4)
            listns( 8) = listso(7)
c           les milieux des aretes proches
            listns(10) = listno( 1)
            listns(11) = listno( 3)
            listns(12) = listno( 9)
            listns(13) = listno(11)
c           les milieux des aretes paralleles
            listns(14) = listno( 5)
            listns(15) = listno( 8)
c           les milieux des aretes moins proches
            listns(16) = listno( 2)
            listns(17) = listno( 4)
            listns(18) = listno(10)
            listns(19) = listno(12)
c
c 1.7. ==> Arete 7
c
          elseif ( nuloar.eq.7 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(4)
            listns( 2) = listso(7)
c           les autres sommets
            listns( 3) = listso(1)
            listns( 4) = listso(3)
            listns( 5) = listso(6)
            listns( 6) = listso(8)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(2)
            listns( 8) = listso(5)
c           les milieux des aretes proches
            listns(10) = listno( 2)
            listns(11) = listno( 4)
            listns(12) = listno(10)
            listns(13) = listno(12)
c           les milieux des aretes paralleles
            listns(14) = listno( 5)
            listns(15) = listno( 8)
c           les milieux des aretes moins proches
            listns(16) = listno( 1)
            listns(17) = listno( 3)
            listns(18) = listno( 9)
            listns(19) = listno(11)
c
c 1.8. ==> Arete 8
c
          elseif ( nuloar.eq.8 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(3)
            listns( 2) = listso(8)
c           les autres sommets
            listns( 3) = listso(2)
            listns( 4) = listso(4)
            listns( 5) = listso(5)
            listns( 6) = listso(7)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(1)
            listns( 8) = listso(6)
c           les milieux des aretes proches
            listns(10) = listno( 3)
            listns(11) = listno( 4)
            listns(12) = listno(11)
            listns(13) = listno(12)
c           les milieux des aretes paralleles
            listns(14) = listno( 6)
            listns(15) = listno( 7)
c           les milieux des aretes moins proches
            listns(16) = listno( 1)
            listns(17) = listno( 2)
            listns(18) = listno( 9)
            listns(19) = listno(10)
c
c 1.9. ==> Arete 9
c
          elseif ( nuloar.eq.9 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(5)
            listns( 2) = listso(6)
c           les autres sommets
            listns( 3) = listso(1)
            listns( 4) = listso(2)
            listns( 5) = listso(7)
            listns( 6) = listso(8)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(3)
            listns( 8) = listso(4)
c           les milieux des aretes proches
            listns(10) = listno( 5)
            listns(11) = listno( 6)
            listns(12) = listno(10)
            listns(13) = listno(11)
c           les milieux des aretes paralleles
            listns(14) = listno( 1)
            listns(15) = listno(12)
c           les milieux des aretes moins proches
            listns(16) = listno( 2)
            listns(17) = listno( 3)
            listns(18) = listno( 7)
            listns(19) = listno( 8)
c
c 1.10. ==> Arete 10
c
          elseif ( nuloar.eq.10 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(6)
            listns( 2) = listso(7)
c           les autres sommets
            listns( 3) = listso(1)
            listns( 4) = listso(4)
            listns( 5) = listso(5)
            listns( 6) = listso(8)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(2)
            listns( 8) = listso(3)
c           les milieux des aretes proches
            listns(10) = listno( 5)
            listns(11) = listno( 7)
            listns(12) = listno( 9)
            listns(13) = listno(12)
c           les milieux des aretes paralleles
            listns(14) = listno( 2)
            listns(15) = listno(11)
c           les milieux des aretes moins proches
            listns(16) = listno( 1)
            listns(17) = listno( 4)
            listns(18) = listno( 6)
            listns(19) = listno( 8)
c
c 1.11. ==> Arete 11
c
          elseif ( nuloar.eq.11 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(5)
            listns( 2) = listso(8)
c           les autres sommets
            listns( 3) = listso(2)
            listns( 4) = listso(3)
            listns( 5) = listso(6)
            listns( 6) = listso(7)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(1)
            listns( 8) = listso(4)
c           les milieux des aretes proches
            listns(10) = listno( 6)
            listns(11) = listno( 8)
            listns(12) = listno( 9)
            listns(13) = listno(12)
c           les milieux des aretes paralleles
            listns(14) = listno( 3)
            listns(15) = listno(10)
c           les milieux des aretes moins proches
            listns(16) = listno( 1)
            listns(17) = listno( 4)
            listns(18) = listno( 5)
            listns(19) = listno( 7)
c
c 1.12. ==> Arete 12
c
          elseif ( nuloar.eq.12 ) then
c
c           les sommets de l'arete coupee
            listns( 1) = listso(7)
            listns( 2) = listso(8)
c           les autres sommets
            listns( 3) = listso(3)
            listns( 4) = listso(4)
            listns( 5) = listso(5)
            listns( 6) = listso(6)
c           les sommets de l'arete opposee a l'arete coupee
            listns( 7) = listso(1)
            listns( 8) = listso(2)
c           les milieux des aretes proches
            listns(10) = listno( 7)
            listns(11) = listno( 8)
            listns(12) = listno(10)
            listns(13) = listno(11)
c           les milieux des aretes paralleles
            listns(14) = listno( 4)
            listns(15) = listno( 9)
c           les milieux des aretes moins proches
            listns(16) = listno( 2)
            listns(17) = listno( 3)
            listns(18) = listno( 5)
            listns(19) = listno( 6)
c
          endif
c
c====
c 2. L'arete concernee : celle des aretes internes qui demarrent
c          sur le milieu de l'arete coupee
c====
c
          do 22 , iaux = 1 , nbarhi
            larete = areint(iaux)
            if ( somare(1,larete).eq.listns( 9) ) then
              sm = np2are(larete)
              goto 220
            endif
  22     continue
      write(ulsort,*) nompro//' - aucune arete interne ne correspond ?'
      codret = 22
c
  220     continue
c
c====
c 3. Calcul
c====
c
          if ( codret.eq.0 ) then
c
          profho(sm) = 1
c
          do 31, nuv = 1 , nbfop2
cgn          do 311 , jaux =1 ,20
cgn        write(*,90014) listns(jaux), vap2ho(nuv,listns(jaux))
cgn  311 continue
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
     >                     + trssz  * ( vap2ho(nuv,listns(14))
     >                                + vap2ho(nuv,listns(15)) )
     >                     + trstr2 * ( vap2ho(nuv,listns(16))
     >                                + vap2ho(nuv,listns(17))
     >                                + vap2ho(nuv,listns(18))
     >                                + vap2ho(nuv,listns(19)) )
     >                     + unssz  *   vap2ho(nuv,listns(20))
c
cgn        write(*,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
   31     continue
c
          endif
c
        endif
c
   10 continue
c
c====
c 4. La fin
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
