      subroutine gbcara  ( nomtab , nrotab, adut , ilong , type8 )
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
c ......................................................................
c .  derniere modif octo 93 at prise en compte du type simple precision
c .           modif octo 93 gn prise en compte du type double precision
c .           modif juin 93 jyb prise en compte du type character*8
c .           modif 15/06/89 jc jyb
c ......................................................................
c .       recherche les caracteristiques d'un tableau (position,longueur
c .     et type ) a partir de son nom. retourne un code d'erreur si le
c .     nom n'est pas repertorie ou si il y a ambiguite.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomtab . e   . ch*8   . nom du tableau a rechercher                .
c . nrotab .  s  .   1    . numero du tableau dans sa categorie        .
c . adut   .  s  .   1    . adresse de debut de tableau dans le maxi-  .
c .        .     .        . tableau associe a son type                 .
c . ilong  .  s  .   1    . dimension du tableau                       .
c . type8  .  s  . ch*8   . type de tableau ou probleme rencontre      .
c . coergm .  s  .    1   . code de retour d'erreur                    .
c .        .     .        . 0 tableau trouve                           .
c .        .     .        . 1 tableau non trouve                       .
c .        .     .        . 2 tableau repertorie plusieurs fois reel   .
c .        .     .        . 3 tableau repertorie plusieurs fois ent    .
c .        .     .        . 4 tableau repertorie plusieurs fois simp   .
c .        .     .        . 5 tableau repertorie plusieurs fois char   .
c .        .     .        . 6 tableau repertorie plusieurs fois comp   .
c .        .     .        . 7 tableau repertorie dans deux types       .
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
      character*6 nompro
      parameter ( nompro = 'GBCARA' )
c
#include "genbla.h"
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmtail.h"
#include "gmtyge.h"
c
#include "gmtrrl.h"
#include "gmtren.h"
#include "gmtrst.h"
c
#include "gmalrl.h"
#include "gmalen.h"
#include "gmalst.h"
c
#include "envex1.h"
#include "gmcoer.h"
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character*8 nomtab
      character*8 type8
c
      integer nrotab, adut , ilong
c
c 0.4. ==> variables locales
c
      character*8 nomvar
c
      integer iaux
      integer icpti, icptr, icpts
      integer i, iadd
      integer ltype, ad0, ad1
      integer nbcain
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
      character*1 carint(1)
c
c 0.5. ==> initialisations
c
      data nbcain     / 0 /
c
      data carint(1) / ' ' /
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
      texte(1,10) =
     > '(''Nom de l''''objet a rechercher en memoire centrale :'')'
      texte(1,11) = '(''L''''objet n''''est pas alloue.'')'
      texte(1,12) = '(''Present plusieurs fois dans les reels.'')'
      texte(1,13) = '(''Present plusieurs fois dans les entiers.'')'
      texte(1,14) = '(''Present plusieurs fois dans les chaines.'')'
      texte(1,15) = '(''Present dans deux types.'')'
      texte(1,18) = '(''Mode de gestion de la memoire inconnu.'')'
      texte(1,20) = '(''Le nom est incorrect.'')'
c
      texte(2,10) =
     > '(''Name of the wanted object in central memory :'')'
      texte(2,11) = '(''The object is not allocated.'')'
      texte(2,12) = '(''Present several times in reals.'')'
      texte(2,13) = '(''Present several times in integers.'')'
      texte(2,14) = '(''Present several times in character.'')'
      texte(2,15) = '(''Present in two types.'')'
      texte(2,18) = '(''Unknown memory management mode.'')'
      texte(2,20) = '(''Name is uncorrect.'')'
c
#ifdef _DEBUG_HOMARD_
c      write (ulsort,90000)
      write (ulsort,texte(langue,10))
      write (ulsort,*) nomtab
#endif
c
c====
c 1. verifications
c====
c
      call gmntve ( nomtab, nomvar, nbcain, carint, coergm )
c
cgn      write (ulsort,*) coergm
      if ( coergm.ne.0 ) then
        coergm = 10
      endif
c
c====
c 2. recherche du nombre d'occurences dans les tableaux
c    entiers, reels et character*8
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Recherche ; coergm = ', coergm
#endif
c
      if ( coergm.eq.0 ) then
c
         nrotab  = 0
c
         icpti = 0
         do 21  i = 1, nballi
           if ( nomvar.eq.nomali(i) ) then
              icpti = icpti + 1
              nrotab  = i
           endif
   21    continue
c
         icptr = 0
         do 22  i = 1, nballr
           if ( nomvar.eq.nomalr(i) ) then
              icptr = icptr + 1
              nrotab  = i
           endif
   22    continue
c
         icpts = 0
         do 23  i = 1, nballs
           if ( nomvar.eq.nomals(i) ) then
              icpts = icpts + 1
              nrotab  = i
           endif
   23    continue
c
      endif
c
c====
c 3. bilan de la recherche
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Bilan de la recherche ; coergm = ', coergm
#endif
c
      if ( coergm.eq.0 ) then
c
c 3.1. ==> cas sympa : le tableau n'apparait qu'une seule fois
c
      if ( (icptr + icpti + icpts).eq.1 ) then
c
c 3.1.1. ==> chez les entiers
c
         if ( icpti.eq.1 ) then
c
           iadd   =  ptalli (nrotab)
           ilong  =  lgalli (nrotab)
           type8  = 'entier  '
           ltype = tentie
           ad0 = adcom(1)
           ad1 = admem(1)
c
c 3.1.2. ==> chez les reels double precison
c
         elseif ( icptr.eq.1 ) then
           iadd   =  ptallr (nrotab)
           ilong  =  lgallr (nrotab)
           type8  = 'reel    '
           ltype = treel
           ad0 = adcom(2)
           ad1 = admem(2)
c
c 3.1.3. ==> chez les character*8
c
         elseif ( icpts.eq.1 ) then
c
           iadd   =  ptalls (nrotab)
           ilong  =  lgalls (nrotab)
           type8  = 'chaine  '
           ltype = tchain
           ad0 = adcom(3)
           ad1 = admem(3)
c
         endif
c
c 3.1.6. ==> correction de l'adresse utile
c
         if ( modgm.eq.0 ) then
            adut = ((ad1-ad0)/ltype) + iadd
            coergm = 0
         else if ( modgm.eq.1 ) then
            adut = ((ad1-ad0)/ltype) + iadd + 1
            coergm = 0
         else if ( modgm.eq.2 ) then
c
c mode dynamique :
c
            adut = (iadd-ad0)/ltype
c
c en particulier pour les "gros types",
c on n'a pas vraiment de garantie que la division precedente
c "tombe juste". Le fait d'avoir en fait alloue un peu plus grand
c (cf. appel a gbalme dans gmalog) permet de se mettre a l'abris
c de ce genre de probleme (entre autres).
c
            if ( adut*ltype .ge. iadd-ad0 ) then
              adut = adut + 1
            else
              adut = adut + 2
            endif
c
            coergm = 0
c
         else
            coergm = 8
         endif
c
      else
c
c 3.2. ==> autres cas : mise a zero des grandeurs puis messages
c
c 3.2.1. ==> mise a zero des grandeurs
c
         iadd   =  0
         ilong  =  0
c
c 3.2.2. ==> 1er cas : le tableau n'apparait pas
c
         if ( (icpti + icptr + icpts).eq.0 ) then
           type8  = 'absent  '
           coergm = 1
         endif
c
c 3.2.3. ==> Cas pas sympa : ou le tableau apparait plusieurs fois
c
c 3.2.3.1. ==> dans les reels
c
         if ( icptr .gt. 1 ) then
           coergm = 2
           type8  = 'multip  '
         endif
c
c 3.2.3.2. ==> dans les entiers
c
         if ( icpti .gt. 1 ) then
           coergm = 3
           type8  = 'multip  '
         endif
c
c 3.2.3.3. ==> dans les character*8
c
         if ( icpts .gt. 1 ) then
           coergm = 4
           type8  = 'multip  '
         endif
c
c 3.2.3.4. ==> dans deux categories
c
         if ( (icptr*icpti).ne.0 ) then
           coergm = 5
           type8  = 'multip  '
         endif
c
         if ( (icptr*icpts).ne.0 ) then
           coergm = 5
           type8  = 'multip  '
         endif
c
         if ( (icpti*icpts).ne.0 ) then
           coergm = 5
           type8  = 'multip  '
         endif
c
      endif
c
      endif
c
c====
c 4. gestion des erreurs
c====
c
      if ( coergm.ne.0 ) then
cgn          write(1,*)coergm
c
         iaux = 10+abs(coergm)
c
#ifdef _DEBUG_HOMARD_
         write (ulsort,texte(langue,iaux))
#endif
c
         if ( iaux.eq.20 ) then
#include "envex2.h"
            call ugstop('gbcara',ulsort,1,1,1)
         endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90000)
90000 format (70('='))
c
#endif
c
      end
