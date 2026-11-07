      subroutine sfcotl ( coonoe,
     >                    somare, filare, np2are,
     >                    cfaare, famare,
     >                    facare, posifa,
     >                    hettri, aretri, filtri,
     >                    hetqua, arequa, filqua,
     >                    cfaqua, famqua,
     >                    tritet, cotrte, aretet, hettet,
     >                    filtet,
     >                    quahex, coquhe, arehex, hethex,
     >                    filhex,
     >                    facpyr, cofapy, arepyr, hetpyr,
     >                    facpen, cofape, arepen, hetpen,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
     >                    nbarfr, arefro,
     >                    nbqufr, quafro,
     >                    lgetco, taetco,
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
c   Suivi de Frontiere - COnTroLes
c   -        -           -- -  -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
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
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
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
c . arefro . e   . nbarfr . liste des aretes concernees                .
c . nbqufr . e   .   1    . nombre de quadrangles concernes            .
c . quafro . e   . nbqufr . liste des quadrangles concernes            .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
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
      parameter ( nompro = 'SFCOTL' )
c
#include "nblang.h"
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
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpyr(nbpyto)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer volqua(2,nbquto), pypequ(2,*)
      integer nbarfr, arefro(nbarfr)
      integer nbqufr, quafro(nbqufr)
c
      double precision coonoe(nbnoto,sdim)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nretap, nrsset
      integer iaux, jaux
c
      integer nbcoa1, nbcoq1, nuphas
      integer nbcoa2, nbcoq2
      integer nbarf0, nbquf0
c
      character*6 saux
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
      codret = 0
c
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,a6,'' CONTROLES'')'
      texte(1,5) = '(16(''=''),/)'
      texte(1,6) = '(/,''Phase de controle'',i10,/,27(''-''))'
      texte(1,7) = '(/,''. Examen du '',a,i10)'
      texte(1,8) =
     >'(''==> Nombre de corrections de noeuds lies a des '',a,'':'',
     >i10)'
      texte(1,9) = '(''==> Tout va bien.'')'
      texte(1,10) = '(''Nombre de '',a,''concernes :'',i10)'
      texte(1,11) = '(''Nombre de '',a,'' a basculer :'',i10)'
      texte(1,12) = '(''... Reprise du '',a,i10)'
c
      texte(2,4) = '(/,a6,'' CHECK'')'
      texte(2,5) = '(12(''=''),/)'
      texte(2,6) = '(/,''Checking phase #'',i10,/,26(''-''))'
      texte(2,7) = '(/,''. Examination of '',a,'' # '',i10)'
      texte(2,8) =
     >'(''==> Number of corrections of nodes connected to '',a,'':'',
     >i10)'
      texte(2,9) = '(''==> Everything is OK.'')'
      texte(2,10) = '(''Number of involved '',a,'':'',i10)'
      texte(2,11) = '(''Number of '',a,'' to swap :'',i10)'
      texte(2,12) = '(''... Correction of '',a,i10)'
c
cgn 1001 format(a,' :',i10,', ',3g13.5)
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. Prealables
c====
c
      nuphas = 0
      nbarf0 = nbarfr
      nbquf0 = nbqufr
cgn        if ( nbarfr.gt.0 ) return
c
   20 continue
c
c====
c 3. Controle des retournements pour les decoupages homogenes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Retournements ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nuphas = nuphas + 1
      write (ulsort,texte(langue,6)) nuphas
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCOT1', nompro
#endif
      call sfcot1 ( nbcoq1, nbcoa1,
     >              coonoe,
     >              somare, filare, np2are,
     >              cfaare, famare,
     >              facare, posifa,
     >              hettri, aretri, filtri,
     >              hetqua, arequa, filqua,
     >              cfaqua, famqua,
     >              tritet, cotrte, aretet,
     >              hettet, filtet,
     >              quahex, coquhe, arehex,
     >              hethex, filhex,
     >              voltri, pypetr,
     >              volqua, pypequ,
     >              nbarf0, arefro,
     >              nbquf0, quafro,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( (nbcoa1+nbcoq1).gt.0 ) then
c
        if ( nbcoq1.gt.0 ) then
          write (ulsort,texte(langue,8)) mess14(langue,3,4), nbcoq1
        endif
c
        if ( nbcoa1.gt.0 ) then
          write (ulsort,texte(langue,8)) mess14(langue,3,1), nbcoa1
        endif
c
      else
c
        write (ulsort,texte(langue,9))
c
      endif
c
      endif
c
c====
c 4. Controle des interpenetrations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Interpenetrations ; codret = ', codret
#endif
c
      nbcoa2 = 0
      nbcoq2 = 0
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      nuphas = nuphas + 1
      write (ulsort,texte(langue,6)) nuphas
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCOT2', nompro
#endif
      call sfcot2 ( nbcoq2, nbcoa2,
     >              coonoe,
     >              somare, filare, np2are,
     >              cfaare, famare,
     >              facare, posifa,
     >              hettri, aretri, filtri,
     >              hetqua, arequa, filqua,
     >              cfaqua, famqua,
     >              tritet, cotrte, aretet, hettet,
     >              filtet,
     >              quahex, coquhe, arehex, hethex,
     >              filhex,
     >              facpyr, cofapy, arepyr, hetpyr,
     >              facpen, cofape, arepen, hetpen,
     >              voltri, pypetr,
     >              volqua, pypequ,
     >              nbarf0, arefro,
     >              nbquf0, quafro,
     >              ulsort, langue, codret)
c
      endif
c
c
      if ( codret.eq.0 ) then
c
      if ( (nbcoa2+nbcoq2).gt.0 ) then
c
        if ( nbcoq2.gt.0 ) then
          write (ulsort,texte(langue,8)) mess14(langue,3,4), nbcoq2
        endif
c
        if ( nbcoa2.gt.0 ) then
          write (ulsort,texte(langue,8)) mess14(langue,3,1), nbcoa2
        endif
c
      else
c
        write (ulsort,texte(langue,9))
c
      endif
c
      endif
#endif
c
c====
c 5. Tant qu'il y a eu une correction, on recommence les tests
c====
c
      if ( codret.eq.0 ) then
c
      if ( (nbcoa1+nbcoq1+nbcoq2+nbcoa2).gt.0 ) then
c
c       On raccourcit les listes des quadrangles et aretes a controler
c
        jaux = nbarf0
        nbarf0 = 0
        do 51 , iaux = 1 , jaux
          if ( arefro(iaux).gt.0 ) then
            nbarf0 = nbarf0 + 1
            arefro(nbarf0) = arefro(iaux)
          endif
   51   continue
c
        jaux = nbquf0
        nbquf0 = 0
        do 52 , iaux = 1 , jaux
          if ( quafro(iaux).gt.0 ) then
            nbquf0 = nbquf0 + 1
            quafro(nbquf0) = quafro(iaux)
          endif
   52   continue
c
        goto 20
c
      endif
c
      endif
c
   59   continue
c
c====
c 6. La fin
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
