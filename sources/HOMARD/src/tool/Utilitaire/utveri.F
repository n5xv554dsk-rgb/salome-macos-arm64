      subroutine utveri ( action, nomail,
     >                    nmprog, avappr,
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
c   UTilitaire : VERIfication
c   --            ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . action . e   . char8  . action en cours                            .
c . nomail . e   . char8  . nom de l'objet maillage homard a verifier  .
c . nmprog . e   . char*  . nom du programme a pister                  .
c . avappr . e   .   1    . 1 : impression avant l'appel a "nmprog"    .
c .        .     .        . 2 : impression apres l'appel a "nmprog"    .
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
      parameter ( nompro = 'UTVERI' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "envada.h"
c
c 0.3. ==> arguments
c
      character*8 action
      character*8 nomail
      character*(*) nmprog
c
      integer avappr
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre0
      integer codre1, codre2, codre3
c
      integer iaux, jaux, kaux
      integer pcoono, psomar
      integer paretr
      integer parequ
      integer phette, ptrite, pcotrt, parete
      integer phethe, pquahe, pcoquh, parehe
      integer phetpy, pfacpy, pcofay, parepy
      integer phetpe, pfacpe, pcofap, parepe
      integer   sdim,   mdim
      integer  degre, maconf, homolo, hierar
      integer rafdef, nbmane, typcca, typsfr, maextr
      integer mailet
      integer nbnoal, nbtral, nbqual
      integer nbteal, nbtaal
      integer nbheal, nbhaal
      integer nbpyal, nbyaal
      integer nbpeal, nbpaal
      integer nuroul, lnomfl
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*15 saux15
      character*200 nomflo
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
      texte(1,4) = '(/,''A l''''entree de '',a,'' :'',/)'
      texte(1,5) = '(/,''Avant appel a '',a,'' :'')'
      texte(1,6) = '(/,''Apres appel a '',a,'' :'')'
      texte(1,7) = '(/,''Mauvais code pour '',a,'' : '',i8,/)'
      texte(1,8) = '(''Le maillage est a corriger.'',/,27(''=''))'
      texte(1,9) = '(''Action en cours : '',a)'
c
      texte(2,4) = '(/,''At the beginning of '',a,'' :'',/)'
      texte(2,5) = '(/,''Before calling '',a,'':'')'
      texte(2,6) = '(/,''After calling '',a,'':'')'
      texte(2,7) = '(/,''Bad code for '',a,'': '',i8,/)'
      texte(2,8) = '(''This mesh is not correct.'',/,25(''=''))'
      texte(2,9) = '(''Current action: '',a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      if ( avappr.ge.0 .and. avappr.le.2 ) then
        write (ulsort,texte(langue,4+avappr)) nmprog
      else
        write (ulsort,texte(langue,7)) nmprog, avappr
      endif
      write (ulsort,texte(langue,9)) action
#endif
c
      codret = 0
c
c====
c 2. recuperation des pointeurs
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
      call gmliat ( nhnoeu, 1, nbnoal, codre1 )
      call gmadoj ( nhnoeu//'.Coor', pcoono, iaux, codre2 )
      call gmadoj ( nharet//'.ConnDesc', psomar, iaux, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      if ( nbtrto.ne.0 ) then
c
        call gmliat ( nhtria, 1, nbtral, codre1 )
        call gmadoj ( nhtria//'.ConnDesc', paretr, iaux, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
        call gmliat ( nhquad, 1, nbqual, codre1 )
        call gmadoj ( nhquad//'.ConnDesc', parequ, iaux, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
        call gmliat ( nhtetr, 1, nbteal, codre1 )
        call gmliat ( nhtetr, 2, nbtaal, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        iaux = 26
        if ( nbtaal.gt.0 ) then
          iaux = iaux*31
        endif
        call utad02 (   iaux, nhtetr,
     >                phette, ptrite,  jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcotrt,   jaux,
     >                  jaux,   jaux, parete,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
        call gmliat ( nhhexa, 1, nbheal, codre1 )
        call gmliat ( nhhexa, 2, nbhaal, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 26
        if ( nbhaal.gt.0 ) then
          iaux = iaux*31
        endif
        call utad02 (   iaux, nhhexa,
     >                phethe, pquahe,  jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcoquh,   jaux,
     >                  jaux,   jaux, parehe,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 ) then
c
        call gmliat ( nhpyra, 1, nbpyal, codre1 )
        call gmliat ( nhpyra, 2, nbyaal, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        iaux = 26
        if ( nbyaal.gt.0 ) then
          iaux = iaux*31
        endif
        call utad02 (   iaux, nhpyra,
     >                phetpy, pfacpy,  jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcofay,   jaux,
     >                  jaux,   jaux, parepy,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
        call gmliat ( nhpent, 1, nbpeal, codre1 )
        call gmliat ( nhpent, 2, nbpaal, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        iaux = 26
        if ( nbpaal.gt.0 ) then
          iaux = iaux*31
        endif
        call utad02 (   iaux, nhpent,
     >                phetpe, pfacpe,  jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcofap,   jaux,
     >                  jaux,   jaux, parepe,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 3. fichier de sortie du bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. fichier sortie ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      saux15 = 'verif_'//action
      iaux = 1
      jaux = -1
      if ( rafdef.eq.31 ) then
        kaux = 1
      else
        kaux = nbiter
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTULBI', nompro
#endif
      call utulbi ( nuroul, nomflo, lnomfl,
     >                iaux, saux15, kaux, jaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. controles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. controles ; codret', codret
#endif
c
c 4.1. ==> les aretes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTEARE', nompro
#endif
      call uteare ( nbarto, nbnoto, imem(psomar),
     >              nmprog, avappr, nuroul,
     >              ulsort, langue, codret )
c
      endif
c
c 4.2. ==> les triangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. tria ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTETRI', nompro
#endif
        call utetri ( nbtrto, nbtral,
     >                imem(paretr), imem(psomar),
     >                nmprog, avappr, nuroul,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 4.3. ==> les quadrangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.3. quad ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTEQUA', nompro
#endif
        call utequa ( nbquto, nbqual, nbnoal, sdim,
     >                rmem(pcoono), imem(psomar), imem(parequ),
     >                nmprog, avappr, nuroul,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 4.4. ==> les tetraedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.4. tetr ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbteto.ne.0 ) then
c
        iaux = nbteal - nbtaal
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTETET', nompro
#endif
        call utetet ( nbteto, iaux, nbtaal, nbtral,
     >                imem(psomar), imem(paretr),
     >                imem(ptrite), imem(pcotrt), imem(parete),
     >                nmprog, avappr, nuroul,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 4.5. ==> les hexaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.5. hexa ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.ne.0 ) then
c
        iaux = nbheal - nbhaal
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTEHEX', nompro
#endif
        call utehex ( nbheto, iaux, nbhaal, nbqual,
     >                imem(psomar), imem(parequ),
     >                imem(pquahe), imem(pcoquh), imem(parehe),
     >                nmprog, avappr, nuroul,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 4.6. ==> les pyramides
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.6. pyra ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpyto.ne.0 ) then
c
        iaux = nbpyal - nbyaal
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTEPYR', nompro
#endif
        call utepyr ( nbpyto, iaux, nbyaal, nbtral,
     >                imem(psomar), imem(paretr),
     >                imem(pfacpy), imem(pcofay), imem(parepy),
     >                nmprog, avappr, nuroul,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 4.7. ==> les pentaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.7. pent ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpeto.ne.0 ) then
c
        iaux = nbpeal - nbpaal
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTEPEN', nompro
#endif
        call utepen ( nbpeto, iaux, nbpaal, nbqual,
     >                imem(psomar),
     >                imem(parequ),
     >                imem(pfacpe), imem(pcofap), imem(parepe),
     >                nmprog, avappr, nuroul,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. fermeture du fichier de sortie du bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. fermeture ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gufeul ( nuroul , codret )
c
      endif
c
c====
c 6. On impose un code de retour nul si c'est un maillage avec ajout
c    de joint car par construction des mailles sont aplaties
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. impose ; codret', codret
#endif
c
      if ( rafdef.eq.31 ) then
c
        codret = 0
c
      endif
c
c====
c 7. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (nuroul,texte(langue,8))
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
