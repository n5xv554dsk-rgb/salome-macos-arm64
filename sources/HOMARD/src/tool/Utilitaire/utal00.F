      subroutine utal00 ( option, optimp,
     >                    nomail, ndecar, ndecfa,
     >                    indnoe, indnp2, indnim, indare,
     >                    indtri, indqua,
     >                    indtet, indhex, indpen,
     >                    nbsoan, nbsono,
     >                    nbnoan, nbnono,
     >                    nbaran, nbarno,
     >                    nbtran, nbtrno,
     >                    nbquan, nbquno,
     >                    nbtean, nbteno,
     >                    nbhean, nbheno,
     >                    nbpean, nbpeno,
     >                    nbpyan, nbpyno,
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
c     UTilitaire : ALlocations - 00
c     --           --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . type de traitement                         .
c .        .     .        . 0 : raffinement                            .
c .        .     .        . 1 : deraffinement                          .
c .        .     .        . 2 : conformite                             .
c . optimp . e   .   1    . impressions 0:non, 1:oui                   .
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . ndecar . e   .  ch8   . nom de l'objet des decisions sur les aretes.
c . ndecfa . e   .  ch8   . nom de l'objet des decisions sur les faces .
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indnp2 . es  .   1    . nombre de noeuds p2 en vigueur             .
c . indnim . es  .   1    . nombre de noeuds internes en vigueur       .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indqua . es  .   1    . indice du dernier quadrangle cree          .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indhex . es  .   1    . indice du dernier hexaedre cree            .
c . indpen . es  .   1    . indice du dernier pentaedre cree           .
c . nbsoan . s   .    1   . nombre de sommets - ancien                 .
c . nbsono . s   .    1   . nombre de sommets - nouveau                .
c . nbnoan . e   .    1   . nombre de noeuds - ancien                  .
c . nbnono . e   .    1   . nombre de noeuds - nouveau                 .
c . nbaran . e   .    1   . nombre d'aretes - ancien                   .
c . nbarno . e   .    1   . nombre d'aretes - nouveau                  .
c . nbtran . e   .    1   . nombre de triangles - ancien               .
c . nbtrno . e   .    1   . nombre de triangles - nouveau              .
c . nbquan . e   .    1   . nombre de quadrangles - ancien             .
c . nbquno . e   .    1   . nombre de quadrangles - nouveau            .
c . nbtean . e   .    1   . nombre de tetraedres - ancien              .
c . nbteno . e   .    1   . nombre de tetraedres - nouveau             .
c . nbhean . e   .    1   . nombre d'hexaedres - ancien                .
c . nbheno . e   .    1   . nombre d'hexaedres - nouveau               .
c . nbpean . e   .    1   . nombre de pentaedres - ancien              .
c . nbpeno . e   .    1   . nombre de pentaedres - nouveau             .
c . nbpyan . e   .    1   . nombre de pyramides - ancien               .
c . nbpyno . e   .    1   . nombre de pyramides - nouveau              .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .   1    . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . e/s .   1    . code de retour des modules                 .
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
      parameter ( nompro = 'UTAL00' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer option
      integer optimp
c
      character*8 nomail
      character*8 ndecar, ndecfa
c
      integer indnoe, indnp2, indnim, indare, indtri, indqua
      integer indtet, indhex, indpen
      integer nbsoan, nbsono
      integer nbnoan, nbnono
      integer nbaran, nbarno
      integer nbtran, nbtrno
      integer nbquan, nbquno
      integer nbtean, nbteno
      integer nbhean, nbheno
      integer nbpean, nbpeno
      integer nbpyan, nbpyno
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer codre0
      integer codre1, codre2, codre3
      integer pdecfa, pdecar
      integer phettr, paretr
      integer phetqu, parequ
      integer phette, ptrite
      integer phethe, pquahe
      integer phetpe, pfacpe
cgn      integer phetpy, pfacpy
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
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
#endif
c
c====
c 2. recuperation des pointeurs
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
c
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
c====
c 3. recuperation des adresses
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. recuperation ; codret', codret
#endif
c
      if ( option.eq.0 ) then
c
c 3.1. ==> Quelques nombres
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhtetr, 1, nbtean, codre1 )
      call gmliat ( nhhexa, 1, nbhean, codre2 )
      call gmliat ( nhpent, 1, nbpean, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbtean', nbtean
      write (ulsort,90002) 'nbhean', nbhean
      write (ulsort,90002) 'nbpean', nbpean
#endif
c
      endif
c
c 3.2. ==> Adresses
c
      if ( codret.eq.0 ) then
c
      if ( nbtean.ne.0 .or. nbpean.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbhean.ne.0 .or. nbpean.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbtean.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhtetr,
     >                phette, ptrite, jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbhean.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhhexa,
     >                phethe, pquahe, jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpean.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhpent,
     >                phetpe, pfacpe, jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.3. ==> Decisions
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ndecar, pdecar, iaux, codre1 )
      call gmadoj ( ndecfa, pdecfa, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      else
c
        write (ulsort,*) 'Arret dans ', nompro
        stop
c
      endif
c
c====
c 4. decompte des nouvelles entites a creer
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. decompte ; codret', codret
#endif
c
      if ( option.eq.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPLRA', nompro
#endif
c
      call utplra ( optimp,
     >              indnoe, indnp2, indnim, indare,
     >              indtri, indqua, indtet, indhex, indpen,
     >              imem(pdecar), imem(pdecfa),
     >              imem(phettr),
     >              imem(phetqu),
     >              imem(ptrite), imem(phette),
     >              imem(pquahe), imem(phethe),
     >              imem(pfacpe), imem(phetpe),
     >              nbsoan, nbsono,
     >              nbnoan, nbnono,
     >              nbaran, nbarno,
     >              nbtran, nbtrno,
     >              nbquan, nbquno,
     >              nbtean, nbteno,
     >              nbhean, nbheno,
     >              nbpean, nbpeno,
     >              nbpyan, nbpyno,
     >              ulsort, langue, codret )
c
      endif
c
      endif
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
