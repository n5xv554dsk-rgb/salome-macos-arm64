      subroutine mmag30 ( nbduno, nbduar, nbdutr,
     >                    nbpejs,
     >                    nbpejt, nbtrjt, nbhejq, nbqujq,
     >                    nbte06, nbpe09, nbhe12,
     >                    nbvojm,
     >                    nbjoto, nbjois, nbjoit, nbjoiq,
     >                    nbjp06, nbjp09, nbjp12,
     >                    tbaux1, tbaux2,
     >                    tbau30, tbau40,
     >                    tbau41, tbau51, tbau52, tbau53,
     >                    coonoe, hetnoe, arenoe,
     >                    somare, hetare,
     >                    filare, merare,
     >                    aretri, hettri,
     >                    filtri, pertri, nivtri,
     >                    arequa, hetqua,
     >                    filqua, perqua, nivqua,
     >                    tritet, cotrte,
     >                    hettet, filtet, pertet,
     >                    facpen, cofape,
     >                    hetpen, filpen, perpen,
     >                    quahex, coquhe,
     >                    hethex, filhex, perhex,
     >                    famnoe, famare,
     >                    famtri, famqua,
     >                    famtet, fampen, famhex,
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
c    Modification de Maillage - AGRegat - phase 3.0
c    -               -          --              - -
c    Creation des pentaedres
c    Et donc des noeuds, aretes, triangles, quadrangles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbduno . e   .   1    . nombre de duplications de noeuds           .
c . nbduar . e   .   1    . nombre de duplications d'aretes            .
c . nbdutr . e   .   1    . nombre de duplications de triangles        .
c . nbpejs . e   .   1    . nombre de pentaedres de joints simples     .
c . nbpejt . e   .   1    . nombre de pentaedres de joints triples     .
c . nbtrjt . e   .   1    . nombre de triangles de joints triples      .
c . nbhejq . e   .   1    . nombre d'hexaedres de joints quadruples    .
c . nbqujq . e   .   1    . nombre de quad. crees pour j. quadruples   .
c . nbte06 . e   .   1    . nombre de tetr. des j. ponctuels d'ordre 6 .
c . nbpe09 .  s  .   1    . nombre de pent. des j. ponctuels d'ordre 9 .
c . nbhe12 .  s  .   1    . nombre de hexa. des j. ponctuels d'ordre 12.
c . nbvojm . e   .   1    . nombre de volumes de joints multiples      .
c . nbjoto . e   .   1    . nombre total de joints                     .
c . nbjois . e   .   1    . nombre de joints simples                   .
c . nbjoit . e   .   1    . nombre de joints triples                   .
c . nbjoiq . e   .   1    . nombre de joints quadruples                .
c . nbjp06 . e   .   1    . nombre de joints ponctuels ordre 6         .
c . nbjp09 . e   .   1    . nombre de joints ponctuels ordre 9         .
c . nbjp12 . e   .   1    . nombre de joints ponctuels ordre 12        .
c . tbaux1 . e   .4*nbpejs. Pour le i-eme pentaedre de joint simple :  .
c .        .     .        . (1,i) : numero du triangle a dupliquer     .
c .        .     .        . (2,i) : numero du joint simple cree        .
c .        .     .        . (3,i) : tetraedre du cote min(fammed)      .
c .        .     .        . (4,i) : tetraedre du cote max(fammed)      .
c . tbaux2 . e   .4*nbjoto. Pour le i-eme joint :                      .
c .        .     .        . Numeros des familles MED des volumes       .
c .        .     .        . jouxtant le pentaedre/hexaedre, classes du .
c .        .     .        . plus petit (1,i) au plus grand             .
c .        .     .        . 0, si pas de volume voisin                 .
c . tbau30 . e   .8*nbduno. Pour la i-eme duplication de noeud :       .
c .        .     .        . (1,i) : noeud a dupliquer                  .
c .        .     .        . (2,i) : arete construite sur le noeud      .
c .        .     .        . (3,i) : noeud cree cote min(fammed)        .
c .        .     .        . (4,i) : noeud cree cote max(fammed)        .
c .        .     .        . (5,i) : numero du joint simple cree        .
c .        .     .        . (6,i) : arete entrant dans le cote 1       .
c .        .     .        . (7,i) : arete entrant dans le cote 2       .
c .        .     .        . (8,i) : ordre de multiplicite              .
c . tbau40 . e   .6*nbduar. Pour la i-eme duplication d'arete :        .
c .        .     .        . (1,i) : arete a dupliquer                  .
c .        .     .        . (2,i) : arete creee cote min(fammed)       .
c .        .     .        . (3,i) : arete creee cote max(fammed)       .
c .        .     .        . (4,i) : numero du joint simple cree        .
c .        .     .        . (5,i) : ordre de multiplicite              .
c .        .     .        . (6,i) : arete d'orientation de joint       .
c . tbau41 . e   .4*nbvojm. Les pentaedres de joint triple, puis les   .
c .        .     .        . hexaedres de joint quadruple :             .
c .        .     .        . (1,i) : arete multiple                     .
c .        .     .        . (2,i) : numero du joint                    .
c .        .     .        . Pour le i-eme pentaedre de joint triple :  .
c .        .     .        . (3,i) : triangle cree cote 1er sommet      .
c .        .     .        . (4,i) : triangle cree cote 2nd sommet      .
c .        .     .        . Pour le i-eme hexaedre de joint quadruple :.
c .        .     .        . (3,i) : quadrangle cree cote 1er sommet    .
c .        .     .        . (4,i) : quadrangle cree cote 2nd sommet    .
c . tbau51 . e   .9*nbte06. Les tetraedres ponctuels entre les joints  .
c .        .     .        . triples :                                  .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : triangle cote du 1er joint triple  .
c .        .     .        . (3,i) : triangle cote du 2eme joint triple .
c .        .     .        . (4,i) : triangle cote du 3eme joint triple .
c .        .     .        . (5,i) : triangle cote du 4eme joint triple .
c .        .     .        . (1+k) : pour le k-eme triangle, 1 s'il     .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . tbau52 . e   .  11*   . Les pentaedres ponctuels entre les joints  .
c .        .     . nbpe09 . triples et quadruples :                    .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : triangle cote du 1er joint triple  .
c .        .     .        . (3,i) : triangle cote du 2eme joint triple .
c .        .     .        . (4,i) : quadrangle cote du 1er joint quad. .
c .        .     .        . (5,i) : quadrangle cote du 2eme joint quad..
c .        .     .        . (6,i) : quadrangle cote du 3eme joint quad..
c .        .     .        . (1+k) : pour la k-eme face, 1 si elle      .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . tbau53 . e   .  13*   . Les hexaedres ponctuels entre les joints   .
c .        .     . nbhe12 . quadruples (ordre 12) :                    .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : quadrangle cote du 1er joint quad. .
c .        .     .        . (3,i) : quadrangle cote du 2eme joint quad..
c .        .     .        . (4,i) : quadrangle cote du 3eme joint quad..
c .        .     .        . (5,i) : quadrangle cote du 4eme joint quad..
c .        .     .        . (6,i) : quadrangle cote du 5eme joint quad..
c .        .     .        . (7,i) : quadrangle cote du 6eme joint quad..
c .        .     .        . (1+k) : pour le k-eme quadrangle, 1 s'il   .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . coonoe . es  .nbnoto*3. coordonnees des noeuds                     .
c . hetnoe . es  . nbnoto . historique de l'etat des noeuds            .
c . arenoe . es  . nbnoto . arete liee a un nouveau noeud              .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . hetare . es  . nbarto . historique de l'etat des aretes            .
c . filare . es  . nbarto . premiere fille des aretes                  .
c . merare . es  . nbarto . mere des aretes                            .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . es  . nbtrto . historique de l'etat des triangles         .
c . filtri . es  . nbtrto . premier fils des triangles                 .
c . pertri . es  . nbtrto . pere des triangles                         .
c . nivtri . es  . nbtrto . niveau des triangles                       .
c . arequa . es  .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . es  . nbquto . historique de l'etat des quadrangles       .
c . filqua . es  . nbquto . premier fils des quadrangles               .
c . perqua . es  . nbquto . pere des quadrangles                       .
c . nivqua . es  . nbquto . niveau des quadrangles                     .
c . tritet . es  .nbtecf*4. numeros des triangles des tetraedres       .
c . cotrte . es  .nbtecf*4. codes des triangles des tetraedres         .
c . hettet . es  . nbteto . historique de l'etat des tetraedres        .
c . filtet . es  . nbteto . premier fils des tetraedres                .
c . pertet . es  . nbteto . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nbteto . famille des tetraedres                     .
c . facpen . es  .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . es  .nbpecf*5. code des 5 faces des pentaedres            .
c . hetpen . es  . nbpeto . historique de l'etat des pentaedres        .
c . filpen . es  . nbpeto . premier fils des pentaedres                .
c . perpen . es  . nbpeto . pere des pentaedres                        .
c . quahex . es  .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . es  .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . hethex . es  . nbheto . historique de l'etat des hexaedres         .
c . filhex . es  . nbheto . premier fils des hexaedres                 .
c . perhex . es  . nbheto . pere des hexaedres                         .
c . famnoe . es  . nbnoto . famille des noeuds                         .
c . famare . es  . nbarto . famille des aretes                         .
c . famtri . es  . nbtrto . famille des triangles                      .
c . famqua . es  . nbquto . famille des quadrangles                    .
c . fampen . es  . nbpeto . famille des pentaedres                     .
c . famhex . es  . nbheto . famille des hexaedres                      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      parameter ( nompro = 'MMAG30' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpe.h"
#include "nombhe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbduno, nbduar, nbdutr
      integer nbpejs
      integer nbpejt, nbtrjt, nbhejq, nbqujq
      integer nbte06, nbpe09, nbhe12
      integer nbvojm
      integer nbjoto, nbjois, nbjoit, nbjoiq
      integer nbjp06, nbjp09, nbjp12
      integer tbaux1(4,nbpejs), tbaux2(4,nbjoto)
      integer tbau30(8,nbduno), tbau40(6,nbduar)
      integer tbau41(4,nbvojm)
      integer tbau51(9,nbte06), tbau52(11,nbpe09), tbau53(13,nbhe12)
      integer hetnoe(nbnoto), arenoe(nbnoto)
      integer somare(2,nbarto), hetare(nbarto)
      integer filare(nbarto), merare(nbarto)
      integer aretri(nbtrto,3), hettri(nbtrto)
      integer filtri(nbtrto), pertri(nbtrto), nivtri(nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto)
      integer filqua(nbquto), perqua(nbquto), nivqua(nbquto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer hettet(nbteto), filtet(nbteto), pertet(nbteto)
      integer facpen(nbpecf,5), cofape(nbpecf,5)
      integer hetpen(nbpeto), filpen(nbpeto), perpen(nbpeto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
      integer hethex(nbheto), filhex(nbheto), perhex(nbheto)
      integer famnoe(nbnoto), famare(nbarto)
      integer famtri(nbtrto), famqua(nbquto)
      integer famtet(nbteto), fampen(nbpeto), famhex(nbheto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer indtri, indtet, indpen, indhex
c
      integer nbmess
      parameter ( nbmess = 30 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "mmag01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), nbduno
      write (ulsort,texte(langue,7)) mess14(langue,3,1), nbduno
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbduar
      write (ulsort,texte(langue,8)) mess14(langue,3,2), nbdutr
      write (ulsort,texte(langue,7)) mess14(langue,3,3), nbte06
      write (ulsort,texte(langue,7)) mess14(langue,3,4), nbduar+nbqujq
      write (ulsort,texte(langue,7)) mess14(langue,3,7),
     >       nbpejs+nbpejt+nbpe09
      write (ulsort,texte(langue,7)) mess14(langue,3,6), nbhejq+nbhe12
#endif
c
      codret = 0
c
c====
c 2. Creation des mailles pour les joints simples
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Mailles joints S ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
      call gtdems (65)
c
      indtri = nbtrto - 2*nbdutr - nbtrjt
      indpen = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG31', nompro
#endif
      call mmag31 ( indtri, indpen,
     >              nbduno, nbduar, nbpejs,
     >              tbaux1, tbau30, tbau40,
     >              coonoe, hetnoe, arenoe,
     >              somare, hetare,
     >              filare, merare,
     >              aretri, hettri,
     >              filtri, pertri, nivtri,
     >              arequa, hetqua,
     >              filqua, perqua, nivqua,
     >              tritet, cotrte,
     >              facpen, cofape,
     >              hetpen, filpen, perpen,
     >              famnoe, famare, famtri,
     >              famqua, fampen,
     >              ulsort, langue, codret )
      call gtfims (65)
c
      endif
c
c====
c 3. Creation des mailles pour les joints triples
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Mailles joints T ; codret = ', codret
#endif
c
      if ( nbjoit.gt.0 ) then
c
        if ( codret.eq.0 ) then
      call gtdems (66)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG32', nompro
#endif
        call mmag32 ( indpen,
     >                nbduno, nbduar,
     >                nbpejt, nbvojm, nbjoto,
     >                tbaux2, tbau30, tbau40,
     >                tbau41,
     >                nbte06, tbau51,
     >                nbpe09, tbau52,
     >                coonoe, somare,
     >                aretri, hettri,
     >                filtri, pertri, nivtri,
     >                arequa,
     >                facpen, cofape,
     >                hetpen, filpen, perpen,
     >                famtri, fampen,
     >                ulsort, langue, codret )
      call gtfims (66)
c
        endif
c
      endif
c
c====
c 4. Creation des mailles pour les joints quadruples
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Mailles joints Q ; codret = ', codret
#endif
c
      indhex = 0
c
      if ( nbjoiq.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
      call gtdems (67)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG33', nompro
#endif
        call mmag33 ( indhex,
     >                nbduno, nbduar,
     >                nbpejt, nbhejq, nbvojm, nbjoto,
     >                nbjois, nbjoit,
     >                tbaux2, tbau30, tbau40,
     >                tbau41,
     >                nbhe12, tbau53,
     >                nbpe09, tbau52,
     >                coonoe, somare,
     >                arequa, hetqua,
     >                filqua, perqua, nivqua,
     >                quahex, coquhe,
     >                hethex, filhex, perhex,
     >                famqua, famhex,
     >                ulsort, langue, codret )
c
      call gtfims (67)
c
        endif
c
      endif
c
c====
c 5. Creation des mailles pour les joints ponctuels
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Mailles joints P ; codret = ', codret
#endif
      if ( codret.eq.0 ) then
c
      call gtdems (68)
c
c 5.1. ==> Les tetraedres pour les joints d'ordre 6
c
      if ( nbjp06.gt.0 ) then
c
        indtet = nbteto - nbte06
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG34', nompro
#endif
        call mmag34 ( indtet,
     >                nbte06,
     >                tbau51,
     >                aretri,
     >                tritet, cotrte,
     >                hettet, filtet, pertet,
     >                famtet,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 5.2. ==> Les pentaedres pour les joints d'ordre 9
c
      if ( nbjp09.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = nbjois + nbjoit + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG35', nompro
#endif
        call mmag35 ( indpen, iaux,
     >                nbpe09,
     >                tbau52,
     >                aretri, arequa,
     >                facpen, cofape,
     >                hetpen, filpen, perpen,
     >                fampen,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 5.3. ==> Les hexaedres pour les joints d'ordre 12
c
      if ( nbjp12.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = nbjoiq + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG36', nompro
#endif
        call mmag36 ( indhex, iaux,
     >                nbhe12,
     >                tbau53,
     >                arequa,
     >                quahex, coquhe,
     >                hethex, filhex, perhex,
     >                famhex,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      call gtfims (68)
c
      endif
c
c====
c 6. la fin
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
