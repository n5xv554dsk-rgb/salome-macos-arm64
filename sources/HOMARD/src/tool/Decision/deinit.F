      subroutine deinit ( nomail, nohind,
     >                    lgopti, taopti, lgoptr, taoptr,
     >                    lgopts, taopts, lgetco, taetco,
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
c traitement des DEcisions - INITialisations
c                --          ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . nohind . e   .  ch8   . nom de l'objet contenant l'indicateur      .
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgoptr . e   .   1    . longueur du tableau des options reelles    .
c . taoptr . e   . lgoptr . tableau des options reelles                .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
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
      parameter ( nompro = 'DEINIT' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "envca1.h"
#include "envada.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail, nohind
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgoptr
      double precision taoptr(lgoptr)
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nrosec
      integer nretap, nrsset
      integer iaux, jaux
      integer ideb, ifin
c
      integer pdecfa, pdecar
      integer ppovos, pvoiso
      integer pnoemp, phetmp
      integer psomar, phetar, pfilar, pmerar, pnp2ar
      integer pposif, pfacar
      integer paretr, phettr, pfiltr, ppertr, pnivtr, advotr
      integer parequ, phetqu, pfilqu, pperqu, pnivqu, advoqu
      integer ptrite, phette, pfilte
      integer pfacpy, phetpy
      integer pquahe, phethe, pfilhe
      integer pfacpe, phetpe, pfilpe
      integer adpptr, adppqu
      integer adtra3
c
      integer codre0, codre1, codre2
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1, ntrav2, ntrav3
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
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.1. ==> le debut des mesures de temps
c
      nrosec = taetco(4)
      call gtdems (nrosec)
c
c 1.3. ==> les messages
c
      texte(1,4) =
     > '(/,a6,'' INITIALISATION ET FILTRAGE DES DECISIONS'')'
      texte(1,5) = '(47(''=''),/)'
      texte(1,6) = '(/,''Decisions sur les '',a)'
      texte(1,7) = '(/,5x,''Bilan de l''''initialisation'')'
c
      texte(2,4) =
     > '(/,a6,'' INITIALISATION AND FILTERING OF DECISIONS'')'
      texte(2,5) = '(48(''=''),/)'
      texte(2,6) = '(/,''Decisions over '',a)'
      texte(2,7) = '(/,5x,''Summary after the initialisation'')'
c
#include "impr03.h"
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
c 2. gestion des tableaux
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
      if ( nbmpto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_mp', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhmapo,
     >                phetmp, pnoemp, jaux  , jaux  ,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( taopti(19).gt.0 ) then
c
        if ( nbmpto.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVGAN', nompro
#endif
c
          iaux = 1
          call utvgan ( nhvois, nhnoeu, nharet,
     >                  iaux,
     >                  ppovos, pvoiso,
     >                  ulsort, langue, codret)
c
          endif
c
        endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 6
      if ( nbiter.gt.0 .and. taopti(38).ne.0 ) then
        iaux = iaux*5
      endif
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 ( iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >                jaux,   jaux,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( nbtrto.ne.0 ) then
c
        iaux = 66
        if ( nbiter.gt.0 .and. taopti(38).ne.0 ) then
          iaux = iaux*5
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                  jaux,   jaux,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
        iaux = 330
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                  jaux,   jaux,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
        iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        call utad02 ( iaux, nhtetr,
     >                phette, ptrite, pfilte, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
        iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 ( iaux, nhhexa,
     >                phethe, pquahe, pfilhe, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 ) then
c
        iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        call utad02 ( iaux, nhpyra,
     >                phetpy, pfacpy,   jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
        iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 ( iaux, nhpent,
     >                phetpe, pfacpe, pfilpe, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 3
      if ( nbteto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*5
      endif
      if ( nbheto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*7
      endif
      if ( nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*221
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >              advotr, advoqu,
     >                jaux,   jaux, adpptr, adppqu,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c 2.3. ==> les decisions sur les faces et les aretes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. decare/decfac ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = nbarto + 1
      call gmalot ( ntrav1, 'entier  ', iaux, pdecar, codre1 )
      iaux = nbquto + nbtrto + 1
      call gmalot ( ntrav2, 'entier  ', iaux, pdecfa, codre2 )
      codre0 = min ( codre1, codre2)
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
        taopts(11) = ntrav1
        taopts(12) = ntrav2
      endif
c
c    A priori, rien ne se passe, donc on met 0
c
      if ( codret.eq.0 ) then
c
      ideb = pdecar
      ifin = pdecar + nbarto
      do 231 , iaux = ideb , ifin
        imem(iaux) = 0
  231 continue
c
      ideb = pdecfa
      ifin = pdecfa + nbtrto + nbquto
      do 232 , iaux = ideb , ifin
        imem(iaux) = 0
  232 continue
c
      endif
c
c 2.4. ==> tableau de travail
c
      if ( codret.eq.0 ) then
c
      iaux = nbquto + nbtrto + 1
      call gmalot ( ntrav3, 'entier  ', iaux, adtra3, codret )
c
      endif
c
c====
c 3. initialisations des tableaux des decisions sur les faces et
c    les aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. initialisations ; codret', codret
      write (ulsort,90002) 'taopti(31)/pilraf', taopti(31)
      write (ulsort,90002) 'taopti(32)/pilder', taopti(32)
      write (ulsort,90002) 'taopti(19)/filada', taopti(19)
      write (ulsort,90004) 'taoptr( 3)/diammi', taoptr( 3)
#endif
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> Cas du raffinement uniforme sans filtrage
c
      if ( taopti(31).eq.-1 .and.
     >   (  taopti(19).eq.0 .and. taoptr(3).le.0.d0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINUN', nompro
cgn      call gmprsx (nompro,nhvois)
#endif
        call deinun
     >       ( taopti(31), taopti(32), taopti(33), taopti(34),
     >         imem(pdecfa), imem(pdecar),
     >         imem(phetar),
     >         imem(phettr),
     >         imem(phetqu),
     >         ulsort, langue, codret )
c
c 3.2. ==> Cas du pilotage par zone, par indicateur ou raffinement
c          uniforme avec filtrage ou deraffinement uniforme
c
      elseif ( taopti(31).gt.0 .or. taopti(32).gt.0 .or.
     >         ( taopti(31).eq.-1 .and.
     >           ( taopti(19).gt.0 .or. taoptr(3).gt.0.d0 ) ) .or.
     >         taopti(32).eq.-1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINNU', nompro
#endif
c
        call deinnu
     >       ( nomail, nohind,
     >         taopti(30), taopti(31), taopti(32),
     >         taopti(33), taopti(34),
     >         taopti( 6), taopti( 7), taoptr( 1), taoptr( 2),
     >         taopti( 8),
     >         taopti(19), taoptr( 3), taopti(37), taopti(38),
     >         taopti(44),
     >         imem(pdecar), imem(pdecfa),
     >         imem(ppovos), imem(pvoiso),
     >         imem(pnoemp),
     >         imem(psomar), imem(phetar), imem(pfilar), imem(pmerar),
     >         imem(pnp2ar), imem(pposif), imem(pfacar),
     >         imem(paretr), imem(phettr),
     >         imem(pfiltr), imem(ppertr), imem(pnivtr),
     >         imem(advotr), imem(adpptr),
     >         imem(parequ), imem(phetqu),
     >         imem(pfilqu), imem(pperqu), imem(pnivqu),
     >         imem(advoqu),
     >         imem(ptrite), imem(phette), imem(pfilte),
     >         imem(pquahe), imem(phethe), imem(pfilhe),
     >         imem(pfacpy), imem(phetpy),
     >         imem(pfacpe), imem(phetpe), imem(pfilpe),
     >         imem(adtra3),
     >         lgopts, taopts,
     >         ulsort, langue, codret)
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      iaux = 2
      call delist ( nomail, 'DEINNU', iaux,
     >              lgopts, taopts,
     >              ulsort, langue, codret )
c
      endif
#endif
c
      endif
c
      endif
c
c====
c 4. Menage du fitrage eventuel
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( taopti(19).gt.0 ) then
c
        if ( nbmpto.ne.0 ) then
          call gmsgoj ( nhvois//'.0D/1D' , codre0 )
          codret = max ( abs(codre0), codret )
        endif
c
      endif
c
      endif
c
c====
c 5. decompte des decisions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. decompte des decisions ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,7))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DECPTE', nompro
#endif
      call decpte
     >        ( taopti(31), taopti(32),
     >          imem(pdecar), imem(pdecfa),
     >          imem(phettr), imem(phetqu), imem(ptrite), imem(phette),
     >          imem(pquahe), imem(phethe),
     >          imem(pfacpy), imem(phetpy),
     >          imem(pfacpe), imem(phetpe),
     >          ulsort, langue, codret )
c
      endif
c
c====
c 6. la fin
c====
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav3, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
       if ( codret.eq.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,1)
        call gmprot ( 'DECARE a la fin de '//nompro,
     >                ntrav1 , 1, min(50,nbarto+1) )
        if ( nbarto.gt.50 ) then
          call gmprot ( 'DECARE a la fin de '//nompro,
     >                   ntrav1 , max(51,nbarto-49), nbarto+1 )
        endif
        write (ulsort,texte(langue,6)) mess14(langue,3,8)
        call gmprot ( 'DECFAC a la fin de '//nompro,
     >                ntrav2 , 1, min(50,nbtrto+nbquto+1) )
        if ( nbtrto+nbquto.gt.50 ) then
        call gmprot ( 'DECFAC a la fin de '//nompro,
     >          ntrav2 , max(51,nbtrto+nbquto-49), nbtrto+nbquto+1)
        endif
        endif
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'en sortie de ',nompro
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,91010) (imem(pdecfa+nbquto+iaux),iaux=1,nbtrto)
      write (ulsort,91010) (imem(pdecar+iaux),iaux=0,nbarto)
#endif
#ifdef _DEBUG_HOMARD_
      do 111,iaux=1,nbtrto
      if (imem(pdecfa+nbquto+iaux).ne.0 ) then
        write (ulsort,90002) 'tr ',iaux
      endif
  111 continue
#endif
#ifdef _DEBUG_HOMARD_
      do 112,iaux=1,nbquto
      if (imem(pdecfa-1+iaux).ne.0 ) then
        write (ulsort,90002) 'qu ',iaux
      endif
  112 continue
#ifdef _DEBUG_HOMARD_
#endif
      do 113,iaux=1,nbarto
      if (imem(pdecar+iaux-1).ne.0 ) then
        write (ulsort,90002) 'ar ',iaux
      endif
  113 continue
#endif
c
c 6.1. ==> message si erreur
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
c 6.2. ==> fin des mesures de temps de la section
c
      call gtfims (nrosec)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
c=======================================================================
      endif
c=======================================================================
c
      end
