      subroutine mmagr5 ( nbduno, nbduar, nbdutr, nbtrjt,
     >                    nbpejs, nbjoto,
     >                    tbaux1, tbaux2, tbau30, tbau40,
     >                    tbaux5, tbaux6,
     >                    somare,
     >                    aretri,
     >                    tritet, famtet, cfatet,
     >                    povoso, voisom,
     >                    posifa, facare,
     >                    voltri,
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
c    Modification de Maillage - AGRegat - phase 5
c    -               -          ---             -
c    Renumerotation des noeuds, aretes et triangles apres duplication
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbduno . e   .   1    . nombre de duplications de noeuds           .
c . nbduar . e   .   1    . nombre de duplications d'aretes            .
c . nbdutr . e   .   1    . nombre de duplications de triangles        .
c . nbtrjt . e   .   1    . nombre de triangles de joints triples      .
c . nbpejs . e   .   1    . nombre de pentaedres de joints simples     .
c . nbjoto . e   .   1    . nombre total de joints                     .
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
c . tbaux5 . e   . nbarto . numero MED du volume de l'arete            .
c . tbaux6 . e   . nbtrto . numero MED du volume du triangle           .
c . hetnoe . es  . nbnoto . historique de l'etat des noeuds            .
c . arenoe . es  . nbnoto . arete liee a un nouveau noeud              .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . voisom . e   . nvosom . aretes voisines de chaque noeud            .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . hetare . es  . nbarto . historique de l'etat des aretes            .
c . filare . es  . nbarto . premiere fille des aretes                  .
c . merare . es  . nbarto . mere des aretes                            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
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
c . facpen . es  .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . es  .nbpecf*5. code des 5 faces des pentaedres            .
c . famtet . e   . nbteto . famille des tetraedres                     .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . perpen . e   . nbpeto . pere des pentaedres                        .
c . famnoe . e   . nbnoto . famille des noeuds                         .
c . famare . e   . nbarto . famille des aretes                         .
c . famtri . e   . nbtrto . famille des triangles                      .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . fampen . e   . nbpeto . famille des pentaedres                     .
c . famtet . e   . nbteto . famille des tetraedres                     .
c . cfatet . e   . nctfte. codes des familles des tetraedres           .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
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
      parameter ( nompro = 'MMAGR5' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "coftex.h"
#include "nbfami.h"
#include "dicfen.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbduno, nbduar, nbdutr, nbtrjt
      integer nbpejs, nbjoto
      integer tbaux1(4,nbpejs), tbaux2(4,nbjoto)
      integer tbau30(8,nbduno), tbau40(6,nbduar)
      integer tbaux5(nbarto), tbaux6(nbtrto)
      integer povoso(0:nbnoto), voisom(*)
      integer somare(2,nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), voltri(2,nbtrto)
      integer famtet(nbteto), cfatet(nctfte,nbftet)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer jdeb, jfin
      integer tbaux(2)
      integer famhom, fammed(2)
      integer letetr, letria, larete, laret0
      integer lenoeu, lenoe0(2)
      integer nbtrol
      integer indtri
c
      integer nbmess
      parameter ( nbmess = 40 )
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
c
      texte(1,31) = '(5x,''==> substitution par le '',a,i8)'
c
      texte(2,31) = '(5x,''==> substitution by the '',a,i8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), nbduno
      write (ulsort,texte(langue,7)) mess14(langue,3,1), nbduno
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbduar
      write (ulsort,texte(langue,8)) mess14(langue,3,2), nbdutr
      write (ulsort,texte(langue,7)) mess14(langue,3,4), nbduar
#endif
c
      codret = 0
c
c 1.2. ==> vieux nombres
c
      nbtrol = nbtrto - 2*nbdutr - nbtrjt
c
cgn      write(ulsort,1001) 'tbaux2',4,nbjoto
cgn      do 1101 , kaux = 1,nbjoto
cgn       write(ulsort,1000) (tbaux2(jaux,kaux),jaux=1,4)
cgn 1101 continue
cgn 1000 format(10i9)
cgn 1001 format(a,4i6)
c
c====
c 2. Parcours des triangles dupliques
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,2)
#endif
c
      indtri = nbtrol
c
      do 2 , iaux = 1 , nbdutr
c
        letria = tbaux1(1,iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,2), letria
#endif
c
c 2.1. ==> On classe les deux tetraedres voisins. Par convention, le 1er
c          est celui de plus petit numero de famille MED (cf. mmagr0)
c          La face qui est dupliquee doit etre remplacee
c          Pour les autres faces, on doit changer les aretes communes
c          avec la face dupliquee.
c          Pour les aretes de ces faces, ne bordant pas la face
c          dupliquee, on doit changer les extremites.
c
        fammed(1) = cfatet(cofamd,famtet(voltri(1,letria)))
        fammed(2) = cfatet(cofamd,famtet(voltri(2,letria)))
        if ( fammed(1).lt.fammed(2) ) then
          tbaux(1) = 1
          tbaux(2) = 2
        else
          tbaux(1) = 2
          tbaux(2) = 1
        endif
c
c 2.2. ==> Substitution
c
        do 22 , jaux = 1 , 2
c
          letetr = voltri(tbaux(jaux),letria)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '. ', mess14(langue,1,3), letetr
#endif
c
          indtri = indtri + 1
c
          do 221 , kaux = 1 , 4
c
            if ( tritet(letetr,kaux).eq.letria ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,31)) mess14(langue,1,2), indtri
#endif
              tritet(letetr,kaux) = indtri
              goto 22
            endif
c
  221     continue
c
   22   continue
c
    2 continue
c
c====
c 3. Parcours des aretes dupliquees
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,1)
#endif
c
      do 3 , iaux = 1 , nbduar
c
c 3.1. ==> On repere les familles MED des deux volumes qui ont conduit
c          a la duplication de l'arete
c
        larete = tbau40(1,iaux)
        famhom = tbau40(4,iaux)
        fammed(1) = tbaux2(1,famhom)
        fammed(2) = tbaux2(2,famhom)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
      write (ulsort,texte(langue,18)) ' ', mess14(langue,1,7), famhom
      write (ulsort,*) ' ==> MED', fammed
#endif
c
c 3.2. ==> Parcours des faces s'enroulant autour de l'arete
c
        jdeb = posifa(larete-1) + 1
        jfin = posifa(larete)
        do 32 , jaux = jdeb , jfin
c
          letria = facare(jaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '..', mess14(langue,1,2), letria
#endif
c
          do 321 , kaux = 1 , 3
c
            if ( aretri(letria,kaux).eq.larete ) then
              if ( tbaux6(letria).eq.fammed(1) ) then
                laret0 = tbau40(2,iaux)
              elseif ( tbaux6(letria).eq.fammed(2) ) then
                laret0 = tbau40(3,iaux)
              else
                laret0 = aretri(letria,kaux)
              endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' ==> MED', tbaux6(letria)
      write (ulsort,texte(langue,31)) mess14(langue,1,1), laret0
#endif
              aretri(letria,kaux) = laret0
              goto 32
            endif
c
  321     continue
c
   32   continue
c
    3 continue
c
c====
c 4. Parcours des sommets dupliques
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,-1)
#endif
c
      do 4 , iaux = 1 , nbduno
c
c 3.1. ==> On repere les familles MED des deux volumes qui ont conduit
c          a la duplication du noeud
c
        lenoeu = tbau30(1,iaux)
        famhom = tbau30(5,iaux)
        fammed(1) = tbaux2(1,famhom)
        fammed(2) = tbaux2(2,famhom)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,texte(langue,4)) '.', mess14(langue,1,-1), lenoeu
      write (ulsort,texte(langue,18)) ' ', mess14(langue,1,7), famhom
      write (ulsort,*) ' ==> MED', fammed
#endif
c
c 3.2. ==> Parcours des aretes ayant ce noeud pour extremite
c
        jdeb = povoso(lenoeu-1) + 1
        jfin = povoso(lenoeu)
        do 42 , jaux = jdeb , jfin
c
          larete = voisom(jaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '..', mess14(langue,1,1), larete
#endif
c
          do 421 , kaux = 1 , 2
c
            lenoe0(kaux) = somare(kaux,larete)
            if ( somare(kaux,larete).eq.lenoeu ) then
              if ( tbaux5(larete).eq.fammed(1) ) then
                lenoe0(kaux) = tbau30(3,iaux)
              elseif ( tbaux5(larete).eq.fammed(2) ) then
                lenoe0(kaux) = tbau30(4,iaux)
              endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' ==> MED', tbaux5(larete)
      write (ulsort,texte(langue,31)) mess14(langue,1,-1), lenoe0(kaux)
#endif
            endif
c
  421     continue
c
          somare(1,larete) = min(lenoe0(1),lenoe0(2))
          somare(2,larete) = max(lenoe0(1),lenoe0(2))
c
   42   continue
c
    4 continue
c
c====
c 5. la fin
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
