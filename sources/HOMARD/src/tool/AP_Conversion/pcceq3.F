      subroutine pcceq3 ( cfanoe, famnoe, nnosho, nnosca,
     >                    cfampo, fammpo, nmpsho, nmpsca,
     >                    cfaare, famare, narsho, narsca,
     >                    cfatri, famtri, ntrsho, ntrsca,
     >                    cfaqua, famqua, nqusho, nqusca,
     >                    typele,
     >                    noehom, mpohom, arehom, trihom, quahom,
     >                    eqpntr,
     >                    eqnoeu, eqmapo, eqaret, eqtria, eqquad,
     >                    nbeqnn, nbeqmn, nbeqan, nbeqtn, nbeqqn,
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
c    aPres adaptation - Conversion - Creation des EQuivalences - phase 3
c     -                 -            -            --                   -
c ______________________________________________________________________
c
c    remarque : on trie les mailles en ne prenant que celles qui
c               sont vraiment des elements : cela se reconnait en
c               utilisant les codes lies au type des elements.
c
c    remarque : il vaut mieux que la boucle sur les entites soit a
c               l'interieur car elle sera toujours plus longue que
c               celle sur les equivalences, d'ou une meilleure
c               vectorisation
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . cfanoe . e   . nctfno*. codes des familles des noeuds              .
c .        .     . nbnoto .   1 : famille MED                          .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famnoe . e   . nbnoto . famille des aretes                         .
c . nnosho . e   . rsnoto . numero des noeuds dans HOMARD              .
c . nnosca . e   . rsnoto . numero des noeuds dans le code de calcul   .
c . cfampo . e   . nctfmp*. codes des familles des mailles-points      .
c .        .     . nbfmpo .   1 : famille MED                          .
c .        .     .        .   2 : type de maille-point                 .
c .        .     .        .   3 : famille des sommets                  .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . fammpo . e   . nbmpto . famille des mailles-points                 .
c . nmpsho . e   . rsmpac . numero des mailles-points dans HOMARD      .
c . nmpsca . e   . rsmpto . numero des mailles-points du calcul        .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famare . e   . nbarto . famille des aretes                         .
c . narsho . e   . rsarac . numero des aretes dans HOMARD              .
c . narsca . e   . rsarto . numero des aretes du calcul                .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famtri . e   . nbtrto . famille des triangles                      .
c . ntrsho . e   . rstrac . numero des triangles dans HOMARD           .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua .     . nbquto . famille des quadrangles                    .
c . nqusho . e   . rsquac . numero des quadrangles dans HOMARD         .
c . nqusca . e   . rsquto . numero des quadrangles du calcul           .
c . typele . e   . nbelem . type des elements                          .
c . noehom . e   . nbnoto . liste etendue des homologues par noeuds    .
c . mpohom . e   . nbmpto . liste etendue des homologues par ma.pts    .
c . arehom . e   . nbarto . liste etendue des homologues par aretes    .
c . trihom . e   . nbtrto . ensemble des triangles homologues          .
c . quahom . e   . nbquto . ensemble des quadrangles homologues        .
c . eqpntr .  s  .5*nbequi. 5i-4 : nombre de paires de noeuds pour     .
c .        .     .        .        l'equivalence i                     .
c .        .     .        . 5i-3 : idem pour les mailles-points        .
c .        .     .        . 5i-2 : idem pour les aretes                .
c .        .     .        . 5i-1 : idem pour les triangles             .
c .        .     .        . 5i   : idem pour les quadrangles           .
c . eqnoeu .  s  .2*nbeqno. liste des paires de noeuds equivalents avec.
c .        .     .        . la convention : eqnoeu(i)<-->eqnoeu(i+1)   .
c . eqmapo .  s  .2*nbeqmp. idem pour les mailles-points               .
c . eqaret .  s  .2*nbeqar. idem pour les aretes                       .
c . eqtria .  s  .2*nbeqtr. idem pour les triangles                    .
c . eqquad .  s  .2*nbeqqu. idem pour les quadrangles                  .
c . nbeqno .  s  .    1   . nombre total de noeuds dans les equivalen. .
c . nbeqmp .  s  .    1   . nombre total de mailles-points dans les eq..
c . nbeqar .  s  .    1   . nombre total d'aretes dans les eq.         .
c . nbeqtr .  s  .    1   . nombre total de triangles dans les eq.     .
c . nbeqqu .  s  .    1   . nombre total de quadrangles dans les eq.   .
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
      parameter ( nompro = 'PCCEQ3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nbfami.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombsr.h"
#include "nbutil.h"
#include "dicfen.h"
#include "refert.h"
c
c 0.3. ==> arguments
c
      integer nqusca(rsquto), nqusho(rsquac)
      integer ntrsca(rstrto), ntrsho(rstrac)
      integer nmpsca(rsmpto), nmpsho(rsmpac)
      integer narsca(rsarto), narsho(rsarac)
      integer nnosca(rsnoto), nnosho(rsnoac)
      integer typele(nbelem)
c
      integer cfanoe(nctfno,nbfnoe), famnoe(nbnoto)
      integer cfampo(nctfmp,nbfmpo), fammpo(nbmpto)
      integer cfaare(nctfar,nbfare), famare(nbarto)
      integer cfatri(nctftr,nbftri), famtri(nbtrto)
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
      integer noehom(nbnoto), mpohom(nbmpto)
      integer arehom(nbarto), trihom(nbtrto)
      integer quahom(nbquto)
c
      integer eqpntr(5*nbequi)
      integer eqnoeu(2*nbeqno), eqmapo(2*nbeqmp)
      integer eqaret(2*nbeqar), eqtria(2*nbeqtr)
      integer eqquad(2*nbeqqu)
      integer nbeqnn, nbeqmn, nbeqan, nbeqtn, nbeqqn
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, ideb, ifin
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      codret = 0
c
c====
c 2. a priori, aucune entite n'appartient a une equivalence
c====
c
      ideb = 1
      ifin = 5*nbequi
      do 21 , iaux = ideb , ifin
        eqpntr(iaux) = 0
   21 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'nbnoto = ', nbnoto
      write (ulsort,*) 'nbmapo = ', nbmapo
      write (ulsort,*) 'nbsegm = ', nbsegm
      write (ulsort,*) 'nbtria = ', nbtria
      write (ulsort,*) 'nbquad = ', nbquad
#endif
c
c====
c 3. Les noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Les noeuds ; codret = ', codret
#endif
c
      if ( nbeqno.ne.0 ) then
c
        iaux = -1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ4_no', nompro
#endif
        call pcceq4 ( iaux,
     >                nbnoto, nctfno, nbfnoe, ncffno, ncefno,
     >                nbeqno, jaux, jaux, jaux, rsnoto,
     >                noehom, cfanoe, famnoe, nnosho, nnosca,
     >                typele,
     >                eqpntr, eqnoeu, nbeqnn,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 4. Les mailles-points
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Les mailles-points ; codret = ', codret
#endif
c
      if ( nbeqmp.ne.0 ) then
c
        iaux = 0
        jaux = nbtetr + nbtria + nbquad + nbsegm
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ4_mp', nompro
#endif
        call pcceq4 ( iaux,
     >                nbmpto, nctfmp, nbfmpo, ncffmp, ncefmp,
     >                nbeqmp, jaux, tyhmpo, tyhmpo, nbelem,
     >                mpohom, cfampo, fammpo, nmpsho, nmpsca,
     >                typele,
     >                eqpntr, eqmapo, nbeqmn,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 5. Les aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Les aretes ; codret = ', codret
#endif
c
      if ( nbeqar.ne.0 ) then
c
        iaux = 1
        jaux = nbtetr + nbtria
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ4_ar', nompro
#endif
        call pcceq4 ( iaux,
     >                nbarto, nctfar, nbfare, ncffar, ncefar,
     >                nbeqar, jaux, tyhse1, tyhse2, nbelem,
     >                arehom, cfaare, famare, narsho, narsca,
     >                typele,
     >                eqpntr, eqaret, nbeqan,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 6. Les triangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. Les triangles ; codret = ', codret
#endif
c
      if ( nbeqtr.ne.0 ) then
c
        iaux = 2
        jaux = nbtetr
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ4_tr', nompro
#endif
        call pcceq4 ( iaux,
     >                nbtrto, nctftr, nbftri, ncfftr, nceftr,
     >                nbeqtr, jaux, tyhtr1, tyhtr2, nbelem,
     >                trihom, cfatri, famtri, ntrsho, ntrsca,
     >                typele,
     >                eqpntr, eqtria, nbeqtn,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 7. Les quadrangles : tri selon les equivalences
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '7. Les quadrangles ; codret = ', codret
#endif
c
      if ( nbeqqu.ne.0 ) then
c
        iaux = 4
        jaux = nbtetr + nbtria + nbsegm + nbmpto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ4_qu', nompro
#endif
        call pcceq4 ( iaux,
     >                nbquto, nctfqu, nbfqua, ncffqu, ncefqu,
     >                nbeqqu, jaux, tyhqu1, tyhqu2, nbelem,
     >                quahom, cfaqua, famqua, nqusho, nqusca,
     >                typele,
     >                eqpntr, eqquad, nbeqqn,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 8. la fin
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
