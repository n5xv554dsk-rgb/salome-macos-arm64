      subroutine sfcot1 ( nbcoqu, nbcoar,
     >                    coonoe,
     >                    somare, filare, np2are,
     >                    cfaare, famare,
     >                    facare, posifa,
     >                    hettri, aretri, filtri,
     >                    hetqua, arequa, filqua,
     >                    cfaqua, famqua,
     >                    tritet, cotrte, aretet,
     >                    hettet, filtet,
     >                    quahex, coquhe, arehex,
     >                    hethex, filhex,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
     >                    nbarfr, arefro,
     >                    nbqufr, quafro,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
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
c   Suivi de Frontiere - COnTroles - phase 1
c   -        -           -- -              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbcoqu .   s .   1    . nombre de corrections pour les quadrangles .
c . nbcoar .   s .   1    . nombre de corrections pour les aretes      .
c . coonoe . es  . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
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
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . tritet . e   .nbtecf*4. numeros des triangles des tetraedres       .
c . cotrte . e   .nbtecf*4. codes des triangles des tetraedres         .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . nbarfr . e   .   1    . nombre d'aretes concernees                 .
c . arefro . es  . nbarfr . liste des aretes concernees                .
c . nbqufr . e   .   1    . nombre de quadrangles concernes            .
c . quafro . es  . nbqufr . liste des quadrangles concernes            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'SFCOT1' )
c
#include "nblang.h"
#include "tbdim0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbcoar, nbcoqu
      integer somare(2,nbarto), filare(nbarto), np2are(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer cfaare(nctfar,nbfare), famare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3), filtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
      integer filtet(nbteto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto)
      integer filhex(nbheto)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer volqua(2,nbquto), pypequ(2,*)
      integer nbarfr, arefro(nbarfr)
      integer nbqufr, quafro(nbqufr)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer larete, lequad, laface
      integer nuarfr, nuqufr
      integer nbexam, examno(2), examar(2)
      integer nufade, nufafi, decafv
      integer nbvoto
      integer nbtetr, nbhexa, nbpyra, nbpent
      integer lisvoi(tbdim)
      integer bilan, nbbato
      integer libasc(tbdim), nbbasc
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,7) = '(/,''. Examen du '',a,i10)'
      texte(1,8) =
     >'(''==> Nombre de corrections de noeuds lies a des '',a,'':'',
     >i10)'
      texte(1,9) = '(''==> Tout va bien.'')'
      texte(1,10) = '(''Nombre de '',a,''concernes :'',i10)'
      texte(1,11) = '(''Nombre de '',a,'' a basculer :'',i10)'
      texte(1,12) = '(''... Reprise du '',a,i10)'
c
      texte(2,7) = '(/,''. Examination of '',a,'' # '',i10)'
      texte(2,8) =
     >'(''==> Number of corrections of nodes connected to '',a,'':'',
     >i10)'
      texte(2,9) = '(''==> Everything is OK.'')'
      texte(2,10) = '(''Number of involved '',a,'':'',i10)'
      texte(2,11) = '(''Number of '',a,'' to swap :'',i10)'
      texte(2,12) = '(''... Correction of '',a,i10)'
c
#include "impr03.h"
c
      codret = 0
c
      nbcoar = 0
      nbcoqu = 0
      nbbato = 0
c
      nbvoto = nbteto + nbheto + nbpyto + nbpeto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typsfr', typsfr
#endif
c
c====
c 2. Boucle sur les quadrangles qui viennent d'etre decoupes et
c    qui font partie d'une frontiere reconnue
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. boucle quadrangles ; codret', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) mess14(langue,3,4), nbqufr
#endif
c
      nbtetr = 0
c
      do 21 , nuqufr = 1 , nbqufr
c
c 2.1. ==> Elimination des situations ou il est inutile
c          de controler car le quadrangle a deja ete ramene
c
        lequad = quafro(nuqufr)
c
        if ( lequad.le.0 ) then
          goto 21
        endif
c
c 2.2. ==> Reperage des situations a examiner :
c          . le noeud central du quadrangle decoupe
c          . les noeuds P2 courbes : a faire
c          ce noeud central est la seconde extremite de la 2eme ou 3eme
c          arete de l'un quelconque des quadrangles fils (cf. cmrdqu)
c
        if ( codret.eq.0 ) then
c
        if ( typsfr.le.2 ) then
          nbexam = 1
          larete = arequa(filqua(lequad),2)
          examno(1) = somare(2,larete)
        else
          codret = 22
        endif
c
        endif
c
c 2.3. ==> Examen
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) mess14(langue,1,4), lequad
#endif
c
        do 23 , iaux = 1 , nbexam
c
          bilan = 0
c
c 2.3.1. ==> Controle des volumes s'appuyant sur ce quadrangle
c
          if ( nbvoto.ne.0 ) then
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVGVQ', nompro
#endif
            call utvgvq ( lequad,
     >                    volqua, pypequ,
     >                    nbhexa, nbpyra, nbpent,
     >                    lisvoi,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
            decafv = 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCOVO', nompro
#endif
            call sfcovo ( bilan,
     >                    nbtetr, nbhexa, nbpyra, nbpent,
     >                    decafv, lisvoi,
     >                    coonoe,
     >                    somare,
     >                    aretri,
     >                    arequa,
     >                    tritet, cotrte, aretet,
     >                    hettet, filtet,
     >                    quahex, coquhe, arehex,
     >                    hethex, filhex,
     >                    ulsort, langue, codret)
c
            endif
c
            if ( codret.eq.0 ) then
c
            if ( bilan.ne.0 ) then
              goto 232
            endif
c
            endif
c
          endif
c
c 2.3.2. ==> Corrections eventuelles
c
  232     continue
c
          if ( codret.eq.0 ) then
c
          if ( bilan.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) mess14(langue,1,-1), examno(iaux)
#endif
c
            nbcoqu = nbcoqu + 1
            quafro(nuqufr) = -lequad
            jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCORN_quadrangle', nompro
#endif
            call utcorn ( examno(iaux), lequad, jaux,
     >                    coonoe,
     >                    somare, filare,
     >                    cfaare, famare,
     >                    arequa, filqua,
     >                    cfaqua, famqua,
     >                    ulsort, langue, codret)
c
          endif
c
          endif
c
   23   continue
c
        endif
c
   21 continue
c
c====
c 3. Boucle sur les aretes qui viennent d'etre decoupees et
c    qui font partie d'une frontiere reconnue
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. boucle aretes ; codret', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) mess14(langue,3,1), nbarfr
#endif
c
      do 31 , nuarfr = 1 , nbarfr
c
c 3.1. ==> Elimination des situations ou il est inutile
c          de controler car l'arete a deja ete ramenee
c
        if ( codret.eq.0 ) then
c
        larete = arefro(nuarfr)
c
        if ( larete.le.0 ) then
          goto 31
        endif
c
        endif
c
c 3.2. ==> Reperage des situations a examiner :
c          . le noeud milieu de l'arete decoupee ou
cgnc          . les noeuds P2 courbes
c
        if ( codret.eq.0 ) then
c
cgn        if ( typsfr.le.2 ) then
          nbexam = 1
          examar(1) = larete
          examno(1) = somare(2,filare(examar(1)))
cgn        else
cgn          nbexam = 2
cgn          examar(1) = filare(larete)
cgn          examno(1) = np2are(examar(1))
cgn          examar(2) = examar(1) + 1
cgn          examno(2) = np2are(examar(2))
cgn        endif
c
        endif
c
c 3.3. ==> Examen
c
        if ( codret.eq.0 ) then
c
        do 33 , iaux = 1 , nbexam
c
c 3.3.1. ==> Faces s'appuyant sur l'arete : s'il n'y en a pas, on
c            passe a la suite
c
          nufade = posifa(examar(iaux)-1) + 1
          nufafi = posifa(examar(iaux))
c
          if ( nufafi.lt.nufade ) then
            goto 33
          endif
c
          bilan = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) mess14(langue,1,1), examar(iaux)
#endif
c
c 3.3.2. ==> Controle des volumes s'appuyant sur cette arete
c
          if ( nbvoto.ne.0 ) then
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVGVA', nompro
#endif
            call utvgv1 ( nufade, nufafi,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
     >                    nbtetr, nbhexa, nbpyra, nbpent,
     >                    lisvoi, facare,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
            decafv = 2 * ( nufafi - nufade + 1 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCOVO', nompro
#endif
            call sfcovo ( bilan,
     >                    nbtetr, nbhexa, nbpyra, nbpent,
     >                    decafv, lisvoi,
     >                    coonoe,
     >                    somare,
     >                    aretri,
     >                    arequa,
     >                    tritet, cotrte, aretet,
     >                    hettet, filtet,
     >                    quahex, coquhe, arehex,
     >                    hethex, filhex,
     >                    ulsort, langue, codret)
c
            endif
c
            if ( codret.eq.0 ) then
c
            if ( bilan.ne.0 ) then
              goto 334
            endif
c
            endif
c
          endif
c
c 3.3.3. ==> Controle des surfaces vraiment 2D s'appuyant sur l'arete
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCOFA', nompro
#endif
c
          call sfcofa ( bilan, nbbasc, libasc,
     >                  examno(iaux), examar(iaux),
     >                  nufade, nufafi, nbvoto,
     >                  coonoe,
     >                  somare, filare, np2are,
     >                  facare,
     >                  hettri, aretri,
     >                  voltri,
     >                  hetqua, arequa, filqua,
     >                  volqua,
     >                  ulsort, langue, codret)
c
          endif
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,texte(langue,11)) mess14(langue,3,1), nbbasc
          endif
#endif
c
c 3.3.4. ==> Corrections eventuelles
c
  334     continue
c
c 3.3.4.1. ==> Retour au milieu
c
          if ( codret.eq.0 ) then
c
          if ( bilan.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) mess14(langue,1,-1), examno(iaux)
#endif
c
            nbcoar = nbcoar + 1
            arefro(nuarfr) = -larete
            jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCORN_arete', nompro
#endif
            call utcorn ( examno(iaux), jaux, larete,
     >                    coonoe,
     >                    somare, filare,
     >                    cfaare, famare,
     >                    arequa, filqua,
     >                    cfaqua, famqua,
     >                    ulsort, langue, codret)
c
          endif
c
          endif
c
c 3.3.4.2. ==> On fait les basculements d'aretes necessaires
c
          if ( codret.eq.0 ) then
c
          nbbato = nbbato + nbbasc
c
          do 3342 , jaux = 1 , nbbasc
c
            laface = libasc(jaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFBATR', nompro
#endif
            call sfbatr ( examno(iaux), examar(iaux), laface,
     >                    somare,
     >                    facare, posifa,
     >                    hettri, aretri, filtri,
     >                    ulsort, langue, codret)
c
 3342     continue
c
          endif
c
   33   continue
c
        endif
c
   31 continue
c
c====
c 4. La fin
c====
c
#ifdef _DEBUG_HOMARD_
      if ( (nbcoqu+nbcoar).eq.0 ) then
        write (ulsort,texte(langue,9))
      else
        if ( nbcoqu.gt.0 ) then
          write (ulsort,texte(langue,8)) mess14(langue,3,4), nbcoqu
        endif
        if ( nbcoar.gt.0 ) then
          write (ulsort,texte(langue,8)) mess14(langue,3,1), nbcoar
        endif
      endif
#endif
c
      if ( nbbato.gt.0 ) then
        write (ulsort,texte(langue,11)) mess14(langue,3,1), nbbato
      endif
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
