      subroutine esleno ( idfmed, nomamd,
     >                    nhnoeu,
     >                    dimcst, lgnoig, nbnoco,
     >                    ltbiau, tbiaux,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : LEcture des NOeuds
c  -      -        --          --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . dimcst . e   .   1    . 0, si toutes les coordonnees varient       .
c .        .     .        . i, si la i-eme est constante et n'est pas  .
c .        .     .        .    memorisee sur chaque noeud              .
c . lgnoig . e   .   1    . nombre de noeuds lies aux elements ignores .
c . nbnoco . e   .   1    . nbr noeuds pour la non-conformite initiale .
c . ltbiau . e   .    1   . longueur allouee a tbiaux                  .
c . tbiaux .     .    *   . tableau tampon entier                      .
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
      parameter ( nompro = 'ESLENO' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
#include "gmreel.h"
c
#include "envca1.h"
#include "nombno.h"
#include "dicfen.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer dimcst, lgnoig, nbnoco
      integer ltbiau, tbiaux(*)
c
      character*8 nhnoeu
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6
      integer codre0
      integer adnoig
      integer pcoono
      integer pfamno, pcfano
c
      character*8 nhnofa
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''. Lecture des noeuds.'')'
c
      texte(2,4) = '(''. Readings of nodes.'')'
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. Gestion de la memoire
c====
c 2.1. ==> la base
c
      call gmecat ( nhnoeu, 1, nbnoto, codre1 )
      call gmecat ( nhnoeu, 2, dimcst, codre2 )
      call gmecat ( nhnoeu, 3, lgnoig, codre3 )
      call gmecat ( nhnoeu, 4, nbnoco, codre4 )
      call gmaloj ( nhnoeu//'.InfoGene', ' ', lgnoig, adnoig, codre5 )
      iaux = sdim * nbnoto
      call gmaloj ( nhnoeu//'.Coor', ' ', iaux, pcoono, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
c 2.2. ==> appel du programme generique pour l'allocation de
c          la branche liee aux familles
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALFE', nompro
#endif
      iaux = -1
      call utalfe ( iaux, nhnoeu,
     >              nbnoto, nctfno, nbfnoe,
     >              nhnofa, pfamno, pcfano,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 3. Lectures
c====
c 3.1. ==> Lecture de la connectivite et des familles
c
      if ( codret.eq.0 ) then
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMNO', nompro
#endif
      call eslmno ( idfmed, nomamd,
     >                iaux,
     >              nbnoto, sdim, rmem(pcoono), imem(pfamno),
     >              ulsort, langue, codret )
c
      endif
c
c 2.2. ==> Lecture des complements
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLEN1', nompro
#endif
      call eslen1 ( idfmed, nomamd,
     >              nhnoeu,
     >              dimcst,
     >              ltbiau, tbiaux,
     >              ulsort, langue, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro, nhnoeu )
      call gmprsx ( nompro, nhnoeu//'.Coor' )
      call gmprsx ( nompro, nhnoeu//'.HistEtat' )
      call gmprsx ( nompro, nhnoeu//'.AretSupp' )
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
