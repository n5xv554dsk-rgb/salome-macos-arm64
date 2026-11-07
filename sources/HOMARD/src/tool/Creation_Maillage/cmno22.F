      subroutine cmno22 ( nomail,
     >                    indnoe, nuarde, nuarfi,
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
c    Creation du Maillage - les NOeuds P2
c    -           -              --      -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . indnoe . es  . 1      . indice du dernier noeud cree               .
c . nuarde . e   . 1      . debut des numeros d'aretes a traiter       .
c . nuarfi . e   . 1      . fin des numeros d'aretes a traiter         .
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
      parameter ( nompro = 'CMNO22' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "envca1.h"
#include "nouvnb.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer indnoe, nuarde, nuarfi
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer phetno, pareno, pcoono
      integer phetar, psomar, pfilar, pnp2ar, pmerar
      integer pfamar, pcfano, pfamno
      integer nnoep2
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
      texte(1,5) = '(5x,''Nombre de noeuds p2 (milieux) crees : '',i10)'
      texte(1,8) =
     > '(5x,''Au depart, nombre de '',a,'' : '',i10)'
      texte(1,9) =
     > '(5x,''A la fin, nombre de '',a,'' : '',i10)'
c
      texte(2,5) = '(5x,''Number of p2 nodes (center) created: '',i10)'
      texte(2,8) =
     > '(5x,''At the beginning, number of created '',a,'': '',i10)'
      texte(2,9) =
     > '(5x,''At the end, number of created '',a,'': '',i10)'
c
#include "impr03.h"
c
c====
c 2. recuperation des pointeurs
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c 2.2. ==> tableaux
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 210
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono, pareno,   jaux,  jaux,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 2730
      call utad02 ( iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >              pfamar,   jaux,   jaux,
     >              jaux  , pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. creation effective des noeuds p2
c    attention : a une epoque, on distinguait les bords droits et les
c    bords courbes. En fait, le traitement applique a ces bords courbes
c    etait mauvais.
c    En atttente d'un autre algorithme mais qui semble plutot complique,
c    on suppose qu'une nouvelle arete est toujours un segment de droite.
c    Si on veut mieux approcher des bords courbes, il faut utiliser
c    l'option de suivi de frontiere.
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), indnoe
      write (ulsort,90002) 'nouvar', nouvar
      write (ulsort,90002) 'nouvno', nouvno
      write (ulsort,90002) 'permp2', permp2
      write (ulsort,90002) 'nouvp2', nouvp2
      write (ulsort,90002) 'permim', permim
      write (ulsort,90002) 'nouvim', nouvim
      write (ulsort,90002) 'nuarde', nuarde
      write (ulsort,90002) 'nuarfi', nuarfi
#endif
      nnoep2 = indnoe
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOAD', nompro
#endif
      call utnoad ( rmem(pcoono),
     >              imem(phetno), imem(pareno), imem(pfamno),
     >              imem(psomar), imem(pnp2ar),
     >              indnoe, nouvno,
     >              nuarde, nuarfi )
c
      endif
c
      nnoep2 = indnoe - nnoep2
      write (ulsort,texte(langue,5)) nnoep2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) mess14(langue,3,-1), indnoe
#endif
c
c====
c 4. la fin
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
