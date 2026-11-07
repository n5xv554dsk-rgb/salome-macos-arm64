      subroutine vcmver ( modhom, nomail, action,
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
c    aVant adaptation - Conversion de Maillage - VERification
c     -                 -             --         --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . modhom . e   .    1   . mode de fonctionnement de homard           .
c . nomail . es  . char*8 . nom de l'objet maillage homard iteration n .
c . action . e   . char8  . action en cours                            .
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
      parameter ( nompro = 'VCMVER' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
#ifdef _DEBUG_HOMARD_
#include "dicfen.h"
#include "nbfami.h"
#endif
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer modhom
c
      character*8 nomail
      character*8 action
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer phetar, psomar
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer phettr, paretr
      integer phetqu, parequ
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
c
      integer ptrav1, ptrav2, ptrav3, ptrav4, ptrav5
      integer ptra15, ptra16
c
      integer iaux, jaux, kaux, laux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
      integer nbquad, nbblqu
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1, ntrav2, ntrav3, ntrav4, ntrav5
      character*8 ntra15, ntra16
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
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
      texte(1,7) = '(''Erreur pour ce maillage au format '',a)'
      texte(1,8) = '(i6,'' blocs de '',a,/)'
      texte(1,9) =
     > '(''Le maillage initial ne doit comporter que la boite 0.'',/)'
      texte(1,10) = '(5x,''Verifications complementaires'',/)'
c
      texte(2,7) = '(''Error with this mesh from '',a)'
      texte(2,8) = '(i6,'' blocks of '',a,/)'
      texte(2,9) = '(''Initial mesh must contain only box # 0.'',/)'
      texte(2,10) = '(5x,''Additional controls'',/)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10))
#endif
c
c====
c 2. Controle preliminaire du maillage d'entree
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVERI', nompro
#endif
c
      iaux = 0
      call utveri ( action, nomail, nompro, iaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. recuperation des donnees du maillage d'entree
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. recuperation des donnees ; codret = ', codret
#endif
c
c 3.1. ==> structure generale
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
c 3.2. ==> adresses des tableaux
c
      if ( typcca.eq.16 ) then
c
c 3.2.1. ==> les aretes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 14
      call utad02 ( iaux, nharet,
     >              phetar, psomar,   jaux, jaux,
     >              pfamar, pcfaar,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2.2. ==> les voisinages
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      iaux = 1
      jaux = 0
      kaux = 0
      laux = 0
      call utvois ( nomail, nhvois,
     >                iaux,   jaux,   kaux,   laux,
     >              ppovos, pvoiso,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      iaux = 3
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >                jaux,   jaux,
     >                jaux,   jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2.3. ==> les quadrangles
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhquad, codret )
      if ( codret.eq.1 ) then
        call gmliat( nhquad, 1, nbquad, codret )
      elseif ( codret.ne.0 ) then
        codret = 2
      endif
c
      endif
c
      if ( nbquad.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 14
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ,   jaux,   jaux,
     >                pfamqu, pcfaqu,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 3.2.4. ==> divers
c
      phettr = 1
      paretr = 1
      pfamtr = 1
      pcfatr = 1
c
      endif
c
c====
c 4. recherche des blocs dans le cas d'Athena
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. recherche blocs Athena ; codret = ', codret
#endif
c
      if ( typcca.eq.16 ) then
c
c 4.1. ==> allocation de structures temporaires
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', nbquto, ptrav1, codre1 )
      call gmalot ( ntrav2, 'entier  ', nbnoto, ptrav2, codre2 )
      call gmalot ( ntrav3, 'entier  ', nbarto, ptrav3, codre3 )
      iaux = nbquto + nbtrto + 1
      call gmalot ( ntrav4, 'entier  ', iaux, ptrav4, codre4 )
      iaux = nbquto + 1
      call gmalot ( ntrav5, 'entier  ', iaux, ptrav5, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      call gmalot ( ntra15, 'entier  ', nbarto, ptra15, codre1 )
      call gmalot ( ntra16, 'entier  ', nbarto, ptra16, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 4.2. ==> les blocs
c
      if ( codret.eq.0 ) then
c
c       on examine toutes les faces
c
      jaux = nbquto + nbtrto
      do 42 , iaux = 0, jaux
        imem(ptrav4+iaux) = 1
   42 continue
      imem(ptrav4+nbquto) = 0
      iaux = 0
      jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11C', nompro
#endif
      call utb11c ( nbblqu, iaux, imem(ptrav4),
     >              imem(phetar), imem(psomar),
     >              imem(phettr), imem(paretr),
     >              imem(phetqu), imem(parequ),
     >              imem(ppovos), imem(pvoiso),
     >              imem(pposif), imem(pfacar),
     >              imem(pfamar), imem(pcfaar),
     >              imem(pfamtr), imem(pcfatr),
     >              imem(pfamqu), imem(pcfaqu),
     >              imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >              imem(ptra15), imem(ptra16),
     >              imem(ptrav5),
     >              jaux, ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
10000 format(3x,20i4)
10001 format(4x,80('-'))
      write(ulsort,*) 'Fin etape 3 avec codret = ', codret
      write(ulsort,texte(langue,8)) nbblqu, mess14(langue,3,4)
      write(ulsort,10000) (iaux,iaux=1,min(20,nbquto))
      write(ulsort,10001)
      write(ulsort,10000) (imem(ptrav1+iaux),iaux=0,min(20,nbquto-1))
      write(ulsort,10000) (imem(pcfaqu+iaux),iaux=0,nctfqu*nbfqua-1)
      write(ulsort,10000) (imem(pfamqu+iaux),iaux=0,min(20,nbquto-1))
#endif
c
      endif
c
c 4.3. ==> diagnostic
c
      if ( codret.eq.0 ) then
c
      if ( nbblqu.ne.1 ) then
c
#include "mslve4.h"
      write(ulsort,texte(langue,8)) nbblqu, mess14(langue,3,4)
      write(ulsort,texte(langue,9))
      codret = 12
c
      endif
c
      endif
c
c 4.4. ==> menage
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
      call gmlboj ( ntrav3, codre3 )
      call gmlboj ( ntrav4, codre4 )
      call gmlboj ( ntrav5, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      call gmlboj ( ntra15, codre1 )
      call gmlboj ( ntra16, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      endif
c
c====
c 5. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. fin ; codret = ', codret
#endif
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
