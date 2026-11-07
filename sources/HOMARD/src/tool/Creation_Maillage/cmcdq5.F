      subroutine cmcdq5 ( lequad,
     >                    indnoe, indare, indqua,
     >                    coonoe, hetnoe, arenoe, famnoe,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hetqua, arequa,
     >                    filqua, perqua, famqua,
     >                    nivqua, ninqua,
     >                    cfaqua,
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
c    Creation du Maillage - Conformite - Decoupage des Quadrangles
c    -           -          -            -             -
c                           en 3 quadrangles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   .   1    . quadrangle a decouper                      .
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indqua . es  . 1      . indice du dernier quadrangle cree          .
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . famnoe .     . nouvno . famille des noeuds                         .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare . es  . nouvar . caracteristiques des aretes                .
c . hetqua . es  . nouvqu . historique de l'etat des quadrangles       .
c . arequa . es  .nouvqu*3. numeros des 4 aretes des quadrangles       .
c . filqua . es  . nouvqu . premier fils des quadrangles               .
c . perqua . es  . nouvqu . pere des quadrangles                       .
c . famqua . es  . nouvqu . famille des quadrangles                    .
c . nivqua . es  . nouvqu . niveau des quadrangles                     .
c . ninqua . es  . nouvqu . noeud interne au quadrangle                .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'CMCDQ5' )
c
#include "nblang.h"
#include "cofatq.h"
#include "fractc.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
#include "nouvnb.h"
#include "dicfen.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nouvno,sdim)
c
      integer lequad
      integer indnoe, indare, indqua
      integer hetnoe(nouvno), arenoe(nouvno), famnoe(nouvno)
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hetqua(nouvqu), arequa(nouvqu,4)
      integer filqua(nouvqu), perqua(nouvqu), famqua(nouvqu)
      integer nivqua(nouvqu)
      integer ninqua(nouvqu)
      integer cfaqua(nctfqu,nbfqua)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer numdec
      integer a1, a2, a3, a4
      integer ai, aj, ak, al
      integer aifj, aifl, ni
      integer ajfi, ajfk, nj
      integer n0
      integer saiaj, sajak, sakal, salai
      integer nf1, nf2, nf3
      integer anin0, anjn0, ankln0
      integer iaux, jaux
c
      logical noinma
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
c
      texte(1,4) ='(''Les decisions de decoupage des aretes du'')'
      texte(1,5) ='(''quadrangle numero'',i10,'' sont incoherentes :'')'
      texte(1,6) ='(''Arete'',i2,'' :'',i10,'' et historique :'',i10)'
      texte(1,7) = '(''.. Noeud milieu'',i10,'', coor :'',3g15.7)'
c
      texte(2,4) ='(''Decisions for the edges of the'')'
      texte(2,5) ='(''quadrangle #'',i10,''do not match :'')'
      texte(2,6) ='(''Edge #'',i2,'' :'',i10,'' state :'',i10)'
      texte(2,7) = '(''.. Central node'',i10,'', coor :'',3g15.7)'
c
#include "impr03.h"
c
      codret = 0
c
      if ( mod(mailet,3).eq.0 ) then
        noinma = .true.
      else
        noinma = .false.
      endif
c
c====
c 2. decoupage en 3 quadrangles des quadrangles de decision 5
c====
c   Quadrangle pere :
c     ak = numero de la k-eme arete du quadrangle pere
c     sajak = numero du noeud commun aux aretes aj et ak
c
c       sa4a1                       a4                        sa3a4
c           ._________________________________________________.
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c        a1 .                                                 . a3
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           ._________________________________________________.
c       sa1a2                       a2                        sa2a3
c
c   Remarque : on appelle ici le sens standard celui correspondant
c              a l'enchainement (a1,a2,a3,a4)
c
c
c Quadrangles fils apres decoupages des aretes ai et aj
c
c       saiaj         aifj       ai/ni       aifl         salai
c           ._____________________________________________.
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           .                      .anin0                 .
c      ajfi .         nq1          .                      .
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           .        anjn0         .                      .
c     aj/nj .----------------------.n0         nq3        . al
c           .                        .                    .
c           .                          .                  .
c           .                            .                .
c           .                              .              .
c      ajfk .           nq2                  .            .
c           .                           ankln0 .          .
c           .                                    .        .
c           .                                      .      .
c           .                                        .    .
c           ._____________________________________________.
c       sajak                     ak                      sakal
c
c
c 2.1. ==> determination des numeros d'aretes et de leurs numeros locaux
c
      a1 = arequa(lequad,1)
      a2 = arequa(lequad,2)
      a3 = arequa(lequad,3)
      a4 = arequa(lequad,4)
cgn      if ( lequad.eq.281 ) then
cgn      write(ulsort,90002) 'aretes', a1, a2, a3, a4
cgn      endif
c
c 2.2. ==> determination des aretes et des sommets, relativement
c          au decoupage de l'arete
c
      call utcoq5 ( hetare, somare, filare, a1, a2, a3, a4,
     >              numdec, ai, aj, ak, al,
     >              aifj, aifl, ni,
     >              ajfi, ajfk, nj,
     >              saiaj, sajak, sakal, salai,
     >              ulsort, langue, codret )
cgn      if ( lequad.eq.281 ) then
cgn      write(ulsort,90002) 'numdec', numdec
cgn      write(ulsort,90002) 'ai, aj, ak, al', ai, aj, ak, al
cgn      write(ulsort,90002) 'aifj, aifl, ni', aifj, aifl, ni
cgn      write(ulsort,90002) 'ajfi, ajfk, nj', ajfi, ajfk, nj
cgn      write(ulsort,90002) 'saiaj, sajak, sakal, salai',
cgn     >                     saiaj, sajak, sakal, salai
cgn      endif
c
c 2.3. ==> decoupage du quadrangle en fonction des aretes coupees
c
      if ( codret.eq.0 ) then
c
c 2.3.1. ==> le sommet central
c          . on le cree au barycentre du quadrangle s'il n'existe pas
c          . on le recupere sinon
c
      if ( noinma ) then
c
        n0 = ninqua(lequad)
c
      else
c
        n0 = indnoe + 1
        arenoe(n0) = 0
        coonoe(n0,1) = ( coonoe(saiaj,1) +
     >                   coonoe(sajak,1) +
     >                   coonoe(sakal,1) +
     >                   coonoe(salai,1) ) * unsqu
        coonoe(n0,2) = ( coonoe(saiaj,2) +
     >                   coonoe(sajak,2) +
     >                   coonoe(sakal,2) +
     >                   coonoe(salai,2) ) * unsqu
        if ( sdim.eq.3 ) then
          coonoe(n0,3) = ( coonoe(saiaj,3) +
     >                     coonoe(sajak,3) +
     >                     coonoe(sakal,3) +
     >                     coonoe(salai,3) ) * unsqu
        endif
        famnoe(n0) = 1
        hetnoe(n0) = 51
        indnoe = n0
c
      endif
#ifdef _DEBUG_HOMARD_
      if ( sdim.eq.3 ) then
          write (ulsort,texte(langue,7)) n0,
     >                            coonoe(n0,1),coonoe(n0,2),coonoe(n0,3)
      else
          write (ulsort,texte(langue,7)) n0,
     >                            coonoe(n0,1),coonoe(n0,2)
      endif
#endif
c
c 2.3.2. ==> creation des trois aretes interieures
c
      anin0 = indare + 1
      somare(1,anin0) = ni
c
      anjn0 = indare + 2
      somare(1,anjn0) = nj
c
      ankln0 = indare + 3
      somare(1,ankln0) = sakal
c
      jaux = cfaqua(cofafa,famqua(lequad))
      do 232 , iaux = anin0 , ankln0
        somare(2,iaux) = n0
        famare(iaux) = jaux
        hetare(iaux) = 50
        filare(iaux) = 0
        merare(iaux) = 0
  232 continue
c
      indare = ankln0
c
c 2.3.3. ==> creation des trois quadrangles
c
      nf1 = indqua + 1
      arequa(nf1,1) = aifj
      arequa(nf1,2) = ajfi
      arequa(nf1,3) = anjn0
      arequa(nf1,4) = anin0
c
      nf2 = indqua + 2
      arequa(nf2,1) = ajfk
      arequa(nf2,2) = ak
      arequa(nf2,3) = ankln0
      arequa(nf2,4) = anjn0
c
      nf3 = indqua + 3
      arequa(nf3,1) = aifl
      arequa(nf3,2) = anin0
      arequa(nf3,3) = ankln0
      arequa(nf3,4) = al
c
      jaux = nivqua(lequad) + 1
      do 233 , iaux = nf1 , nf3
        famqua(iaux) = famqua(lequad)
        hetqua(iaux) = 5500
        filqua(iaux) = 0
        perqua(iaux) = lequad
        nivqua(iaux) = jaux
  233 continue
c
c 2.3.4. ==> modification des parametres du quadrangle
c
      hetqua(lequad) = hetqua(lequad) + 40 + numdec
      filqua(lequad) = nf1
c
      indqua = nf3
c
      else
c
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) lequad
      write (ulsort,texte(langue,6)) 1, a1, hetare(a1)
      write (ulsort,texte(langue,6)) 2, a2, hetare(a2)
      write (ulsort,texte(langue,6)) 3, a3, hetare(a3)
      write (ulsort,texte(langue,6)) 4, a4, hetare(a4)
c
      endif
c
c====
c 3. la fin
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
