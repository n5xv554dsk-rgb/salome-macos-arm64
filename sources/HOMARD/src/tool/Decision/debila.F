      subroutine debila ( nomail,
     >                    lgopti, taopti, lgopts, taopts,
     >                    lgetco, taetco,
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
c traitement des DEcisions - BILAn
c                --          ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : encore des incoherences de conformites .
c .        .     .        . 2 : probleme de memoire                    .
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
      parameter ( nompro = 'DEBILA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
c
#include "nombqu.h"
#include "nombtr.h"
#include "nombhe.h"
#include "nombpe.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer lgopti
      integer taopti(lgopti)
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
      integer nretap, nrsset
      integer iaux, jaux
c
      integer phetar
      integer phettr, paretr
      integer phetqu, parequ
      integer phethe, pquahe
      integer phetpe, pfacpe
c
      integer pdecar, pdecfa
c
      integer codre0, codre1, codre2
c
      character*6 saux
      character*8 ntrav1, ntrav2
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
      texte(1,4) = '(/,a6,'' CONTROLE DES DECISIONS'')'
      texte(1,5) = '(29(''=''),/)'
      texte(1,10) = '(''Code retour de '',a6,'' ='',i4,/)'
c
      texte(2,4) = '(/,a6,'' CONTROL OF DECISIONS'')'
      texte(2,5) = '(27(''=''),/)'
      texte(2,10) = '(''Error code from '',a6,'' ='',i4,/)'
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
#include "impr03.h"
c
c====
c 2. recuperation des pointeurs, initialisations
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
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
c 2.2. ==> tableaux
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( nharet//'.HistEtat', phetar, iaux, codret )
c
      if ( nbtrto.ne.0 ) then
        iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
      endif
c
      if ( nbquto.ne.0 ) then
        iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
      endif
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 2
        call utad02 (   iaux, nhhexa,
     >                phethe, pquahe,   jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpecf.ne.0 ) then
c
        iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 ( iaux, nhpent,
     >                phetpe, pfacpe, jaux  ,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      ntrav1 = taopts(11)
      call gmadoj ( ntrav1, pdecar, iaux, codre1 )
      ntrav2 = taopts(12)
      call gmadoj ( ntrav2, pdecfa, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 3. bilan des decisions
c====
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) '3. bilan des decisions ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEBIL1', nompro
#endif
c
        call debil1
     >        ( taopti(30),
     >          imem(pdecfa), imem(pdecar),
     >          imem(phetar),
     >          imem(phettr), imem(paretr),
     >          imem(phetqu), imem(parequ),
     >          imem(phethe), imem(pquahe),
     >          imem(phetpe), imem(pfacpe),
     >          ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) 'DEBIL1', codret
#endif
c
      endif
c
c====
c 4. la fin
c    en mode normal, on imprime seulement s'il y a un pb de memoire
c====
c
#ifdef _DEBUG_HOMARD_
      if ( codret.ne.-1789 ) then
#else
      if ( codret.eq.2 ) then
#endif
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
      end
