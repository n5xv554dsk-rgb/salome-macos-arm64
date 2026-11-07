      subroutine cmraff ( nomail,
     >                    indnoe, indare, indtri, indqua,
     >                    indtet, indhex, indpen,
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
c    Creation du Maillage - RAFFinement
c    -           -          ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indqua . es  .   1    . indice du dernier quadrangle cree          .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indhex . es  .   1    . indice du dernier hexaedre cree            .
c . indpen . es  .   1    . indice du dernier pentaedre cree           .
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
      parameter ( nompro = 'CMRAFF' )
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
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nouvnb.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer indnoe, indare, indtri, indqua
      integer indtet, indhex, indpen
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
      integer nretap, nrsset
      integer iaux, jaux
c
      integer codre0, codre1, codre2
      integer pdecar, pdecfa
      integer phetno, pcoono, pareno
      integer phetar, psomar, pfilar, pmerar, pnp2ar
      integer phettr, paretr, pfiltr, ppertr, pnivtr, adnmtr
      integer phetqu, parequ, pfilqu, pperqu, pnivqu, adnmqu
      integer phette, ptrite, pcotrt, pfilte, pperte
      integer phethe, pquahe, pcoquh, pfilhe, pperhe, adnmhe
      integer phetpe, pfacpe, pcofap, pfilpe, pperpe
      integer pfamno, pcfano
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
      integer pfamte
      integer pfamhe
      integer pfampe
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1, ntrav2
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
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
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
      texte(1,4) = '(/,a6,'' RAFFINEMENT STANDARD DU MAILLAGE'')'
      texte(1,5) = '(39(''=''),/)'
      texte(1,6) =
     > '(5x,''Nombre de '',a,'' crees :'',i10,'' ; total : '',i10)'
c
      texte(2,4) = '(/,a6,'' STANDARD REFINEMENT OF MESH'')'
      texte(2,5) = '(34(''=''),/)'
      texte(2,6) =
     > '(5x,''Number of new '',a,'' :'',i10,'' ; total : '',i10)'
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
cgn      call gmprot(nompro//' -0',nharet//'.Famille.EntiFamm',1,26)
cgn      call gmprot(nompro//' -0', nharet//'.Famille.EntiFamm',27,118)
c
c 2.2. ==> tableaux
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 7770
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono, pareno,   jaux,  jaux,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 7770
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
      call utad02 ( iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >              pfamar, pcfaar,   jaux,
     >              jaux  , pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        iaux = 85470
        if ( mod(mailet,2).eq.0 ) then
          iaux = iaux*19
        endif
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                pfamtr, pcfatr,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                adnmtr,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 85470
        if ( mod(mailet,3).eq.0 ) then
          iaux = iaux*19
        endif
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                pfamqu, pcfaqu,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                adnmqu,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        iaux = 2730
        call utad02 ( iaux, nhtetr,
     >                phette, ptrite, pfilte, pperte,
     >                pfamte,   jaux,   jaux,
     >                jaux  , pcotrt,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 2730
        if ( mod(mailet,5).eq.0 ) then
          iaux = iaux*19
        endif
        call utad02 ( iaux, nhhexa,
     >                phethe, pquahe, pfilhe, pperhe,
     >                pfamhe,   jaux,   jaux,
     >                jaux  , pcoquh,   jaux,
     >                adnmhe,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        iaux = 2730
        call utad02 ( iaux, nhpent,
     >                phetpe, pfacpe, pfilpe, pperpe,
     >                pfampe,   jaux,   jaux,
     >                jaux  , pcofap,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      ntrav1 = taopts(11)
      call gmadoj ( ntrav1, pdecar, iaux, codre1 )
      ntrav2 = taopts(12)
      call gmadoj ( ntrav2, pdecfa, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
cgn      call gmprsx (nompro,ntrav1)
cgn      call gmprsx (nompro,ntrav2)
c
      endif
c
c====
c 3. decoupage des aretes en degre 1 et degre 2
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. aretes ; codret', codret
      write (ulsort,90002) 'indare', indare
#endif
c
#ifdef _DEBUG_HOMARD_
      do 3011 , iaux = 1 , nbarto
      if ( iaux.eq.-1661 ) then
        write (ulsort,9001) 'arete', iaux,
     >  imem(psomar+2*iaux-2), imem(psomar+2*iaux-1),
     >  imem(pfilar+iaux-1),imem(phetar+iaux-1),imem(pdecar+iaux)
      endif
 3011 continue
 9001 format(a,i8,', som :',2i8,', fille',i8,', e/d',i3,3i2)
#endif
c
      if ( codret.eq.0 ) then
c
      if ( degre.eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMRDA1', nompro
#endif
        call cmrda1
     >         ( rmem(pcoono), imem(phetno), imem(pareno), imem(psomar),
     >           imem(phetar), imem(pfilar), imem(pmerar), imem(pdecar),
     >           imem(pcfaar), imem(pfamar), imem(pfamno),
     >           indnoe, indare,
     >           ulsort, langue, codret )
c
      elseif ( degre.eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMRDA2', nompro
#endif
        call cmrda2
     >         ( imem(phetno), imem(psomar), imem(phetar), imem(pfilar),
     >           imem(pmerar), imem(pdecar), imem(pnp2ar),
     >           imem(pcfaar), imem(pfamar),
     >           indare,
     >           ulsort, langue, codret )
c
      else
        write(ulsort,90050) degre
        codret = 5
      endif
c
      endif
#ifdef _DEBUG_HOMARD_
cgn      do 30012 , iaux = 1 , nbarto
cgn      if ( iaux.eq.478 ) then
cgn        write (ulsort,9001) 'arete', iaux,
cgn     >  imem(psomar+2*iaux-2), imem(psomar+2*iaux-1),
cgn     >   imem(pfilar+iaux-1),imem(phetar+iaux-1),imem(pdecar+iaux)
cgn      endif
cgn30012 continue
#endif
cgn      write(ulsort,90002) 'indare', indare
cgn      call gmprot(nompro//' -1',nharet//'.Famille.EntiFamm',1,26)
cgn      call gmprot(nompro//' -1', nharet//'.Famille.EntiFamm',27,118)
c
c====
c 4. decoupage des triangles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMRDTR', nompro
#endif
      call cmrdtr
     >         ( imem(psomar), imem(phetar), imem(pfilar), imem(pmerar),
     >           imem(paretr), imem(phettr), imem(pfiltr), imem(ppertr),
     >           imem(pnivtr), imem(pdecfa),
     >           imem(pfamar), imem(pfamtr),
     >           indare, indtri,
     >           imem(pcfatr),
     >           ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. decoupage des quadrangles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMRDQU', nompro
#endif
      call cmrdqu
     >         ( rmem(pcoono), imem(phetno), imem(pareno),
     >           imem(psomar), imem(phetar), imem(pfilar), imem(pmerar),
     >           imem(parequ), imem(phetqu), imem(pfilqu), imem(pperqu),
     >           imem(pnivqu), imem(adnmqu), imem(pdecfa),
     >           imem(pfamno), imem(pfamar), imem(pfamqu),
     >           indnoe, indare, indqua,
     >           imem(pcfaqu),
     >           ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 6. decoupage des tetraedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. tetraedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMRDTE', nompro
#endif
        call cmrdte
     >         ( rmem(pcoono),
     >           imem(psomar), imem(phetar), imem(pfilar), imem(pmerar),
     >           imem(paretr), imem(phettr),
     >           imem(pfiltr), imem(ppertr), imem(pnivtr),
     >           imem(ptrite), imem(pcotrt), imem(phette), imem(pfilte),
     >           imem(pperte),
     >           imem(pfamar), imem(pfamtr), imem(pfamte),
     >           indare, indtri, indtet,
     >           ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 7. decoupage des hexaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMRDHE', nompro
#endif
        call cmrdhe
     >         ( rmem(pcoono), imem(phetno), imem(pareno),
     >           imem(psomar), imem(phetar), imem(pfilar), imem(pmerar),
     >           imem(parequ), imem(phetqu),
     >           imem(pfilqu), imem(pperqu), imem(pnivqu),
     >           imem(pquahe), imem(pcoquh), imem(phethe),
     >           imem(pfilhe), imem(pperhe), imem(adnmhe),
     >           imem(pfamno), imem(pfamar), imem(pfamqu), imem(pfamhe),
     >           indnoe, indare, indqua, indhex,
     >           ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 8 decoupage des pentaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMRDPE', nompro
#endif
        call cmrdpe
     >         ( imem(psomar), imem(phetar), imem(pfilar), imem(pmerar),
     >           imem(paretr), imem(phettr),
     >           imem(pfiltr), imem(ppertr), imem(pnivtr),
     >           imem(parequ), imem(phetqu),
     >           imem(pfilqu), imem(pperqu), imem(pnivqu),
     >           imem(pfacpe), imem(pcofap), imem(phetpe),
     >           imem(pfilpe), imem(pperpe),
     >           imem(pfamar), imem(pfamtr), imem(pfamqu), imem(pfampe),
     >           indare, indtri, indqua, indpen,
     >           ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 9. verifications des nombres d'entites crees et impressions
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. verifications ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      write(ulsort,texte(langue,6)) mess14(langue,3,-1),
     >                              indnoe-nbnoto, indnoe
      write(ulsort,texte(langue,6)) mess14(langue,3,1),
     >                              indare-nbarto, indare
      if ( nbtrto.ne.0 ) then
        write(ulsort,texte(langue,6)) mess14(langue,3,2),
     >                                indtri-nbtrto, indtri
      endif
      if ( nbquto.ne.0 ) then
        write(ulsort,texte(langue,6)) mess14(langue,3,4),
     >                                indqua-nbquto, indqua
      endif
      if ( nbteto.ne.0 ) then
        write(ulsort,texte(langue,6)) mess14(langue,3,3),
     >                                indtet-nbteto, indtet
      endif
      if ( nbheto.ne.0 ) then
        write(ulsort,texte(langue,6)) mess14(langue,3,6),
     >                                indhex-nbheto, indhex
      endif
      if ( nbpeto.ne.0 ) then
        write(ulsort,texte(langue,6)) mess14(langue,3,7),
     >                                indpen-nbpeto, indpen
      endif
c
      iaux = 0
      if ( degre.eq.1 ) then
        if ( indnoe.ne.nouvno ) then
          write(ulsort,90100) mess14(langue,3,-1), permno-nbnoto
          iaux = iaux + 1
        endif
      endif
      if ( indare.ne.permar ) then
        write(ulsort,90100) mess14(langue,3,1), permar-nbarto
        iaux = iaux + 1
      endif
      if ( nbtrto.ne.0 .and. indtri.ne.permtr ) then
        write(ulsort,90100) mess14(langue,3,2), permtr-nbtrto
        iaux = iaux + 1
      endif
      if ( nbquto.ne.0 .and. indqua.ne.permqu ) then
        write(ulsort,90100) mess14(langue,3,4), permqu-nbquto
        iaux = iaux + 1
      endif
      if ( nbteto.ne.0 .and. indtet.ne.permte ) then
        write(ulsort,90100) mess14(langue,3,3), permte-nbteto
        iaux = iaux + 1
      endif
      if ( nbheto.ne.0 .and. indhex.ne.permhe ) then
        write(ulsort,90100) mess14(langue,3,6), permhe-nbheto
        iaux = iaux + 1
      endif
      if ( nbpeto.ne.0 .and. indpen.ne.permpe ) then
        write(ulsort,90100) mess14(langue,3,7), permpe-nbpeto
        iaux = iaux + 1
      endif
c
      if ( iaux.ne.0 ) then
        codret = 4
      endif
c
      endif
cgn      call gmprsx(nompro,nhnoeu)
c
90050 format(/,5x,'Le degre d''interpolation est : ',i1,
     >       /,5x,'Seules les discretisations de degres 1 et 2 sont ',
     >            'supportees',/)
90100 format(/,5x,'Nombre de ',a,' crees incorrect, ',
     >       /,5x,'On en attendait ',i10,'  nouveaux.')
c
c====
c 10. la fin
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
c=======================================================================
      endif
c=======================================================================
c
      end
