      subroutine utbil1 ( nomail, commen, typbil, action,
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
c    UTilitaire - BILan sur le maillage - phase 1
c    --           ---                           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . commen . e   . ch80   . commentaire a ecrire en tete               .
c . typbil . e   .   1    . type de bilan                              .
c .        .     .        . la valeur de typbil est le produit de :    .
c .        .     .        .  0 : rien du tout                          .
c .        .     .        .  2 : nombre d'entites homard               .
c .        .     .        .  3 : interpenetration des mailles          .
c .        .     .        .  5 : qualite des mailles                   .
c .        .     .        .  7 : nombre d'entites du calcul            .
c .        .     .        . 11 : connexite                             .
c .        .     .        . 13 : tailles des sous-domaines             .
c .        .     .        . 17 : diagnostic des elements du calcul     .
c .        .     .        . 19 : diametre des mailles                  .
c . action . e   .char8/10. action en cours                            .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTBIL1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "envca2.h"
#include "envada.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
      character*(*) action
      character*(*) commen
c
      integer typbil
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nrosec
      integer phetno, pcoono, adcocs
      integer psomar, phetar
      integer advotr, adpptr
      integer advoqu, adppqu
      integer paretr, phettr, pnivtr, ppertr
      integer parequ, phetqu, pnivqu
      integer ptrite, pcotrt, parete, phette, pperte, adtes2
      integer pquahe, pcoquh, parehe, phethe, pperhe
      integer pfacpy, pcofay, parepy, phetpy, pperpy, adpys2
      integer pfacpe, pcofap, parepe, phetpe, pperpe
      integer pnp2ar
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer pfamno, pcfano
      integer pfammp, pcfamp
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
      integer pfamte, pcfate
      integer pfamhe, pcfahe
      integer pfampy, pcfapy
      integer pfampe, pcfape
      integer ptrav1, ptrav2, ptrav3, ptrav4, ptrav5
      integer ptrav6, ptrav7
      integer ptra11, ptra12, ptra13, ptra14
      integer ptra15, ptra16
      integer ptra17, ptra18
      integer ltrav1
      integer adnumf, pinftb
      integer adpoin, adtail, adtabl
      integer nbpqt
c
      integer codava
      integer iaux, jaux, kaux, laux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
      integer nuroul, lnomfl
      integer nbgrfm, nbfmed, ngrouc, nbelig
c
      logical voinoe
c
      character*8 ntrav1, ntrav2, ntrav3, ntrav4, ntrav5
      character*8 ntrav6, ntrav7
      character*8 ntra11, ntra12, ntra13, ntra14
      character*8 ntra15, ntra16
      character*8 ntra17, ntra18
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*16 unicoo(2,3)
      character*200 nomflo
c
      integer nbmess
      parameter (nbmess = 30 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
      if ( typbil.ne.0 ) then
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
      texte(1,4) = '(5x,''Date de creation : '',a48)'
      texte(1,5) = '(5x,''Dimension :'',i2)'
      texte(1,6) = '(5x,''Degre :'',i2)'
      texte(1,7) = '(5x,''C''''est un maillage de depart.'')'
      texte(1,8) =
     > '(5x,''C''''est un maillage obtenu apres une adaptation.'')'
      texte(1,9) =
     >'(5x,''C''''est un maillage obtenu apres '',i6,'' adaptations.'')'
      texte(1,10) = '(5x,''Le niveau minimum actif est :'',i6)'
      texte(1,11) = '(5x,''Le niveau minimum actif est :'',i6,''.5'')'
      texte(1,12) = '(5x,''Le niveau maximum actif est :'',i6)'
      texte(1,13) = '(5x,''Le niveau maximum actif est :'',i6,''.5'')'
      texte(1,14) =
     > '(/,9x,'//
     >'''Direction    |       Unite       |  Minimum   |  Maximum'')'
      texte(1,15) = '(5x,a16,'' | '',a16,2x,2(''|'',g12.5))'
      texte(1,19) = '(''On impose un code de retour nul.'')'
      texte(1,20) =
     > '(5x,''Le maillage est non-conforme a 1 arete coupee.'')'
      texte(1,21) = '(5x,''Le maillage est conforme par boites.'')'
      texte(1,22) = '(5x,''Le maillage est conforme.'')'
      texte(1,23) =
     >'(5x,'//
     >'''Le maillage est non-conforme a max 2 aretes non coupees.'')'
      texte(1,24) =
     > '(5x,''Le maillage est non-conforme a 1 noeud pendant.'')'
      texte(1,25) =
     > '(5x,''Le maillage est non-conforme sans contrainte.'')'
      texte(1,26) =
     > '(5x,''Le maillage est non-conforme par construction.'')'
      texte(1,30) = '(//,''ANALYSE DU MAILLAGE'',/,19(''=''),/)'
c
      texte(2,4) = '(5x,''Date of creation : '',a48)'
      texte(2,5) = '(5x,''Dimension :'',i2)'
      texte(2,6) = '(5x,''Degree :'',i2)'
      texte(2,7) = '(5x,''This is an initial mesh.'')'
      texte(2,8) =
     > '(5x,''This is a mesh obtained after one adaptation.'')'
      texte(2,9) =
     > '(5x,''This is a mesh obtained after '',i6,'' adaptations.'')'
      texte(2,10) = '(5x,''The minimum active level is:'',i6)'
      texte(2,11) = '(5x,''The minimum active level is:'',i6,''.5'')'
      texte(2,12) = '(5x,''The maximum active level is:'',i6)'
      texte(2,13) = '(5x,''The maximum active level is:'',i6,''.5'')'
      texte(2,14) =
     > '(/,9x,'//
     >'''Direction    |        Unit       |  Minimum   |  Maximum'')'
      texte(2,15) = '(5x,a16,'' | '',a16,2x,2(''|'',g12.5))'
      texte(2,19) = '(''A zero error code is imposed.'')'
      texte(2,20) =
     > '(5x,''The mesh is non-conformal with 1 cut edge.'')'
      texte(2,21) = '(5x,''The mesh is conformal with boxes.'')'
      texte(2,22) = '(5x,''The mesh is conformal.'')'
      texte(2,23) =
     > '(5x,''The mesh is non-conformal with at max 2 non cut edges.'')'
      texte(2,24) =
     > '(5x,''The mesh is non-conformal with 1 hanging node.'')'
      texte(2,25) =
     > '(5x,''The mesh is non-conformal without any rule.'')'
      texte(2,26) =
     > '(5x,''The mesh is non-conformal from the beginning.'')'
      texte(2,30) = '(//,''ANALYSIS OF THE MESH'',/,20(''=''),/)'
c
#include "impr03.h"
c
10050 format (5x,a50)
10080 format (5x,a80)
10063 format (5x,63('-'))
c
c====
c 2. determination des pointeurs associes aux structures de
c    donnees passees en argument
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. ==> tableaux ; codret', codret
      call dmflsh(iaux)
#endif
c
c 2.2.1. ==> les standards
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 3*19
      if ( mod(typbil,3).eq.0 ) then
        iaux = iaux*2
      endif
      if ( mod(typbil,7).eq.0 ) then
        iaux = iaux*7
      endif
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono,   jaux,   jaux, adcocs,
     >              ulsort, langue, codret )
c
      if ( nbmpto.ne.0 ) then
c
        if ( mod(typbil,7).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_mp', nompro
#endif
          iaux = 259
          call utad02 (   iaux, nhmapo,
     >                  jaux  , jaux  , jaux  , jaux,
     >                  pfammp, pcfamp,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 2
      if ( mod(typbil,7).eq.0 .or.
     >     mod(typbil,11).eq.0 .or.
     >     mod(typbil,13).eq.0  .or.
     >     mod(typbil,17).eq.0 ) then
        iaux = iaux*259
      endif
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
      call utad02 (   iaux, nharet,
     >              phetar, psomar, jaux  , jaux,
     >              pfamar, pcfaar,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        iaux = 2
        if ( mod(typbil,5).eq.0 .or.
     >       mod(typbil,7).eq.0 .or.
     >       mod(typbil,11).eq.0 .or.
     >       mod(typbil,13).eq.0 .or.
     >       mod(typbil,19).eq.0 ) then
          iaux = iaux*14245
        else
          if ( mod(typbil,17).eq.0 ) then
            iaux = iaux*259
          else
            iaux = iaux*55
          endif
        endif
        call utad02 (   iaux, nhtria,
     >                phettr, paretr, jaux  , ppertr,
     >                pfamtr, pcfatr,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 2
        if ( mod(typbil,5).eq.0 .or.
     >       mod(typbil,7).eq.0 .or.
     >       mod(typbil,11).eq.0 .or.
     >       mod(typbil,13).eq.0 .or.
     >       mod(typbil,19).eq.0 ) then
          iaux = iaux*14245
        else
          if ( mod(typbil,17).eq.0 ) then
            iaux = iaux*259
          else
            iaux = iaux*55
          endif
        endif
        call utad02 (   iaux, nhquad,
     >                phetqu, parequ, jaux  ,   jaux,
     >                pfamqu, pcfaqu,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
        iaux = 26
        if ( mod(typbil,7).eq.0 .or.
     >       mod(typbil,11).eq.0 .or.
     >       mod(typbil,13).eq.0 .or.
     >       mod(typbil,17).eq.0 ) then
          iaux = iaux*259
        endif
        if ( nbteh1.gt.0 .or. nbteh2.gt.0 .or. nbteh3.gt.0 .or.
     >       nbteh4.gt.0 .or.
     >       nbtep0.gt.0 .or. nbtep1.gt.0 .or. nbtep2.gt.0 .or.
     >       nbtep3.gt.0 .or. nbtep4.gt.0 .or. nbtep5.gt.0 .or.
     >       nbtedh.gt.0 .or. nbtedp.gt.0 ) then
          iaux = iaux*5*17
        endif
        if ( nbteca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        call utad02 (   iaux, nhtetr,
     >                phette, ptrite, jaux  , pperte,
     >                pfamte, pcfate,   jaux,
     >                  jaux, pcotrt, adtes2,
     >                  jaux,   jaux, parete,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
        iaux = 26
        if ( mod(typbil,7).eq.0 .or.
     >       mod(typbil,11).eq.0 .or.
     >       mod(typbil,13).eq.0 .or.
     >       mod(typbil,17).eq.0 ) then
          iaux = iaux*259
        endif
        if ( mod(typbil,7).eq.0 ) then
          iaux = iaux*5
        endif
        if ( nbheca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 (   iaux, nhhexa,
     >                phethe, pquahe, jaux  , pperhe,
     >                pfamhe, pcfahe,   jaux,
     >                  jaux, pcoquh,   jaux,
     >                  jaux,   jaux, parehe,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 ) then
c
        iaux = 26
        if ( mod(typbil,7).eq.0 .or.
     >       mod(typbil,11).eq.0 .or.
     >       mod(typbil,13).eq.0 .or.
     >       mod(typbil,17).eq.0 ) then
          iaux = iaux*259
        endif
        if ( nbpyh1.gt.0 .or. nbpyh2.gt.0 .or. nbpyh3.gt.0 .or.
     >       nbpyh4.gt.0 .or.
     >       nbpyp0.gt.0 .or. nbpyp1.gt.0 .or. nbpyp2.gt.0 .or.
     >       nbpyp3.gt.0 .or. nbpyp4.gt.0 .or. nbpyp5.gt.0 .or.
     >       nbpydh.gt.0 .or. nbpydp.gt.0 ) then
          iaux = iaux*5*17
        endif
        if ( nbpyca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        call utad02 (   iaux, nhpyra,
     >                phetpy, pfacpy, jaux  , pperpy,
     >                pfampy, pcfapy,   jaux,
     >                  jaux, pcofay, adpys2,
     >                  jaux,   jaux, parepy,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
        iaux = 26
        if ( mod(typbil,7).eq.0 .or.
     >       mod(typbil,11).eq.0 .or.
     >       mod(typbil,13).eq.0 .or.
     >       mod(typbil,17).eq.0 ) then
          iaux = iaux*259
        endif
        if ( mod(typbil,7).eq.0 ) then
          iaux = iaux*5
        endif
        if ( nbpeca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 (   iaux, nhpent,
     >                phetpe, pfacpe, jaux  , pperpe,
     >                pfampe, pcfape,   jaux,
     >                  jaux, pcofap,   jaux,
     >                  jaux,   jaux, parepe,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.2.2. ==> les voisinages
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Debut etape 2.2.2 : codret', codret
#endif
c
c 2.2.2.1. ==> les voisinages des noeuds s'ils sont absents
c
      voinoe = .false.
c
      if ( mod(typbil,11).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmobal ( nhvois//'.0D/1D', codre1 )
c
        if ( codre1.eq.0 ) then
          codret = 0
        elseif ( codre1.eq.1 ) then
          voinoe = .true.
        else
          codret = 2
        endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( .not.voinoe ) then
c
          iaux = 1
          jaux = 0
          kaux = 0
          laux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
          call utvois ( nomail, nhvois,
     >                    iaux,   jaux,   kaux,   laux,
     >                  ppovos, pvoiso,
     >                  nbfaar, pposif, pfacar,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
      endif
c
c 2.2.2.2. ==> les adresses
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
        iaux = iaux*13*17
      endif
      if ( mod(typbil,11).eq.0 ) then
        iaux = iaux*2
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      call utad04 ( iaux, nhvois,
     >              ppovos, pvoiso, pposif, pfacar,
     >              advotr, advoqu,
     >                jaux,   jaux, adpptr, adppqu,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
cgn      call gmprsx (nompro,nhvois)
cgn      call gmprsx (nompro,nhvois//'.PyPe/Tri')
c
c 2.2.3. ==> les infos complementaires eventuelles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Debut etape 2.2.3 : codret', codret
#endif
c
c 2.2.3.1. ==> les unites des coordonnees
c              si rien n'est defini, on suppose que ce sont x, y et z
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhsupe//'.Tab7', codre0 )
c
      if ( codre0.eq.0 ) then
c                      1234567890123456
        unicoo(1,1) = 'x               '
        unicoo(2,1) = 'Inconnue        '
        unicoo(1,2) = 'y               '
        unicoo(2,2) = 'Inconnue        '
        unicoo(1,3) = 'z               '
        unicoo(2,3) = 'Inconnue        '
c
      elseif ( codre0.eq.2 ) then
c
        call gmadoj ( nhsups//'.Tab3', pinftb, iaux, codre1 )
        call gmliat ( nhsups, 3, iaux, codre2 )
        nbpqt = iaux/10
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        if ( codret.eq.0 ) then
c
        do 2231 , iaux = 1, nbpqt
c
          jaux = pinftb + 10*(iaux-1)
cgn        write (ulsort,90064) iaux, '%'//smem(jaux)//
cgn     >  smem(jaux+1)//smem(jaux+2)//smem(jaux+3)//'%'
c
c 2.1. Repere et noms des coordonnees
c
          if ( smem(jaux).eq.'NomCo   ' ) then
c
            do 22311 , kaux = 1 , sdim
              unicoo(1,kaux) = smem(jaux+2*kaux-1)//smem(jaux+2*kaux)
cgn              write (ulsort,90064) kaux, '%'//unicoo(1,kaux)//'%'
22311       continue
c
c 2.2. Unites des coordonnees
c
          elseif ( smem(jaux).eq.'UniteCo ' ) then
c
            do 22312 , kaux = 1 , sdim
              unicoo(2,kaux) = smem(jaux+2*kaux-1)//smem(jaux+2*kaux)
cgn              write (ulsort,90064) kaux, '%'//unicoo(2,kaux)//'%'
22312       continue
c
          endif
c
 2231   continue
c
        endif
c
      else
c
        codret = max ( abs(codre0), codret )
c
      endif
c
      endif
c
c 2.2.3.2. ==> les noms des sous-domaines du calcul
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2.3.2. noms sd : codret', codret
#endif
c
cgn        call gmprsx ( nompro//' nhsupe', nhsupe )
cgn        call gmprsx ( nompro//' nhsups', nhsups )
      if ( codret.eq.0 ) then
c
      call gmobal ( nhsupe//'.Tab9', codre0 )
c
      if ( codre0.eq.0 ) then
c
        nbfmed = 0
c
      elseif ( codre0.eq.2 ) then
c
        call gmliat ( nhsupe, 9, nbfmed, codre0 )
        codret = max ( abs(codre0), codret )
c
        if ( nbfmed.gt.1 ) then
c
          call gmliat ( nhsupe, 6, iaux, codre1 )
          call gmadoj ( nhsupe//'.Tab9', adnumf, iaux, codre2 )
          call gmadoj ( nhsupe//'.Tab5', adpoin, iaux, codre3 )
          call gmadoj ( nhsupe//'.Tab6', adtail, iaux, codre4 )
          call gmadoj ( nhsups//'.Tab2', adtabl, iaux, codre5 )
c
          codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3, codre4, codre5 )
c
          ngrouc = iaux/10
c
        else
c
          ngrouc = 0
c
        endif
c
      else
c
        codret = max ( abs(codre0), codret )
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'codret', codret
      write(ulsort,90002) 'nbfmed', nbfmed
      write(ulsort,90002) 'ngrouc', ngrouc
#endif
      if ( nbfmed.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 10*ngrouc
        call gmalot ( ntra17, 'chaine  ',   iaux, ptra17, codre1 )
        call gmalot ( ntra18, 'entier  ', ngrouc, ptra18, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFMLG', nompro
#endif
        call utfmlg ( nbfmed, ngrouc,
     >                imem(adpoin), imem(adtail), smem(adtabl),
     >                nbgrfm, smem(ptra17), imem(ptra18),
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 10*ngrouc
        jaux = 10*nbgrfm
        call gmmod ( ntra17, ptra17,   iaux,   jaux, 1, 1, codre1 )
        call gmmod ( ntra18, ptra18, ngrouc, nbgrfm, 1, 1, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,90002) 'nbgrfm', nbgrfm
        call gmprsx ( nompro, ntra17 )
        call gmprsx ( nompro, ntra18 )
#endif
c
        endif
c
      endif
c
c 2.2.3.3. ==> les elements elimines
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2.3.3. elements elimines : codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhelig, 1, nbelig, codre0 )
      codret = max ( abs(codre0), codret )
c
      endif
c
c====
c 3. allocation de tableaux de travail
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Debut etape 3 : codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      if ( mod(typbil,5).eq.0 .or. mod(typbil,19).eq.0 ) then
        ltrav1 = max ( nbtrto, nbquto,
     >                 nbteto, nbpyto, nbheto, nbpeto )
        iaux = max ( iaux, 2*ltrav1)
      endif
      if ( mod(typbil,7).eq.0  ) then
        iaux = max ( iaux, 2*nivsup+3 )
      endif
      if ( mod(typbil,11).eq.0 ) then
        iaux = max ( iaux,
     >               nbarto,
     >               nbtrto + nbquto,
     >               nbteac + nbheac + nbpyac + nbpeac )
      endif
      if ( mod(typbil,13).eq.0 ) then
        iaux = max ( iaux,
     >               nbarac,
     >               nbtrac + nbquac,
     >               nbteac + nbheac + nbpyac + nbpeac )
      endif
      if ( mod(typbil,17).eq.0 ) then
        iaux = max ( iaux,
     >               nbnoto )
      endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'lg de tabaui (trav1) : ', iaux
#endif
      call gmalot ( ntrav1, 'entier  ', iaux, ptrav1, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      if ( mod(typbil,11).eq.0 ) then
        iaux = max ( iaux,
     >               nbnoto )
      endif
      if ( mod(typbil,13).eq.0 ) then
        iaux = max ( iaux,
     >               nbfmed )
      endif
c
      call gmalot ( ntrav2, 'entier  ', iaux, ptrav2, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(typbil,11).eq.0 ) then
c
        call gmalot ( ntrav2, 'entier  ', nbnoto, ptrav2, codre1 )
        call gmalot ( ntrav3, 'entier  ', nbarto, ptrav3, codre2 )
        iaux = max( nbarto, nbquto + nbtrto + 1 )
        call gmalot ( ntrav4, 'entier  ', iaux, ptrav4, codre3 )
        jaux = max ( nbarto, nbquto + nbtrto + 1,
     >               nbteto + nbheto + nbpyto + nbpeto )
        call gmalot ( ntrav5, 'entier  ', jaux, ptrav5, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,90002) 'lg de trav2', nbnoto
        write(ulsort,90002) 'lg de trav3', nbarto
        write(ulsort,90002) 'lg de trav4', iaux
        write(ulsort,90002) 'lg de trav5', Jaux
#endif
c
        jaux = nbquto + nbtrto + 1
        call gmalot ( ntra11, 'entier  ',   jaux, ptra11, codre1 )
        call gmalot ( ntra12, 'entier  ', nbnoto, ptra12, codre2 )
        call gmalot ( ntra13, 'entier  ', nbarto, ptra13, codre3 )
        call gmalot ( ntra14, 'entier  ',   jaux, ptra14, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        call gmalot ( ntra15, 'entier  ', nbarto, ptra15, codre1 )
        call gmalot ( ntra16, 'entier  ', nbarto, ptra16, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      if ( mod(typbil,5).eq.0 .or. mod(typbil,19).eq.0 ) then
        iaux = max ( iaux, nbtrto, nbquto,
     >               nbteto, nbpyto, nbheto, nbpeto )
      endif
      if ( mod(typbil,13).eq.0 ) then
        iaux = max ( iaux,
     >               nbarac,
     >               nbtrac + nbquac,
     >               nbteac + nbheac + nbpyac + nbpeac )
      endif
c
      if ( iaux.ne.0 ) then
#ifdef _DEBUG_HOMARD_
        write(ulsort,90002) 'lg de tabaur (trav6)', iaux
#endif
        call gmalot ( ntrav6, 'reel    ', iaux, ptrav6, codret )
        if ( codret.eq.0 ) then
        if ( mod(typbil,5).eq.0 ) then
          call gmalot ( ntrav7, 'reel    ', iaux, ptrav7, codret )
        endif
        endif
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'Fin etape 3 avec codret', codret
#endif
c
c====
c 4. fichier de sortie du bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Debut etape 4 : codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTULBI', nompro
#endif
      iaux = 1
      jaux = -1
      if ( rafdef.eq.31 ) then
        kaux = 1
      else
        kaux = nbiter
      endif
      call utulbi ( nuroul, nomflo, lnomfl,
     >                iaux, action, kaux, jaux,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'Fin etape 4 avec codret', codret
#endif
c
c====
c 5. bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Debut etape 5 : codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      write (nuroul,texte(langue,30))
c
      endif
c
c 5.1. ==> ecriture des generalites
c
      if ( codret.eq.0 ) then
c
      iaux = min (50, len(commen))
      if ( iaux.gt.0 ) then
        write (nuroul,10050) commen(1:iaux)
      endif
      write (nuroul,10080) titre
      write (nuroul,texte(langue,4)) ladate
      write (nuroul,texte(langue,5)) sdim
      write (nuroul,texte(langue,6)) degre
      if ( nbiter.eq.0 ) then
        write (nuroul,texte(langue,7))
      else
        if ( nbiter.eq.1 ) then
          write (nuroul,texte(langue,8))
        else
          write (nuroul,texte(langue,9)) nbiter
        endif
        iaux = mod(niincf,10)
        if ( iaux.ne.0 ) then
          if ( nivinf.le.((niincf-5)/10) ) then
            iaux = 0
          endif
        endif
        if ( iaux.eq.0 ) then
          write (nuroul,texte(langue,10)) nivinf
        else
          write (nuroul,texte(langue,11)) (niincf-5)/10
        endif
        iaux = mod(nisucf,10)
        if ( iaux.eq.0 ) then
          write (nuroul,texte(langue,12)) nivsup
        else
          write (nuroul,texte(langue,13)) (nisucf-5)/10
        endif
      endif
#ifdef _DEBUG_HOMARD_
      iaux = 21 + min(maconf,4)
      write (nuroul,texte(langue,iaux))
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      write (nuroul,texte(langue,14))
      write (nuroul,10063)
      do 51 , iaux = 1 , sdim
        if ( rmem(adcocs+6+iaux).ge.0.d0 ) then
          write (nuroul,texte(langue,15)) unicoo(1,iaux),unicoo(2,iaux),
     >    rmem(adcocs+iaux), rmem(adcocs+3+iaux)
#ifdef _DEBUG_HOMARD_
        else
          write (nuroul,texte(langue,15)) unicoo(1,iaux),unicoo(2,iaux),
     >    rmem(adcocs+iaux), rmem(adcocs+3+iaux)
#endif
        endif
   51 continue
c
      endif
c
c 5.2. ==> denombrement des entites au sens homard :
c          typbil est multiple de 2
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '5.2 Nombres HOMARD codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(typbil,2).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB02A', nompro
#endif
        call utb02a ( imem(phetar),
     >                imem(phettr), imem(ppertr), imem(advotr),
     >                imem(phetqu), imem(advoqu),
     >                imem(pposif), imem(pfacar),
     >                nuroul, ulsort, langue, codret )
c
      endif
c
      endif
c
c 5.3. ==> controle de la non-interpenetration des mailles :
c          typbil est multiple de 3
C          attention : a faire pour HEXA, PYRA, PENT
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '5.3. Interpenetration codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      taetco(4) = taetco(4) + 1
      nrosec = taetco(4)
c
      if ( mod(typbil,3).eq.0 ) then
c
        if ( action(1:4).eq.'info' ) then
          call gtdems (nrosec)
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB03A', nompro
#endif
        call utb03a ( imem(phetno), rmem(pcoono),
     >                imem(phetar), imem(psomar), imem(pposif),
     >                imem(phettr), imem(paretr), imem(advotr),
     >                imem(phetqu), imem(parequ), imem(advoqu),
     >                imem(ptrite), imem(pcotrt), imem(parete),
     >                imem(phette),
     >                imem(pquahe), imem(pcoquh), imem(parehe),
     >                imem(phethe),
     >                imem(pfacpy), imem(pcofay), imem(parepy),
     >                imem(phetpy),
     >                imem(pfacpe), imem(pcofap), imem(parepe),
     >                imem(phetpe),
     >                imem(pnp2ar),
     >                rmem(adcocs+1), rmem(adcocs+4), rmem(adcocs+7),
     >                nuroul, ulsort, langue, codret )
c
        if ( action(1:4).eq.'info' ) then
          call gtfims (nrosec)
        endif
c
       endif
c
      endif
c
c 5.4. ==> qualite des mailles : typbil est multiple de 5
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '5.4. Qualite codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      taetco(4) = taetco(4) + 1
      nrosec = taetco(4)
c
        if ( mod(typbil,5).eq.0 ) then
c
        if ( action(1:4).eq.'info' ) then
          call gtdems (nrosec)
        endif
c
        iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB05A', nompro
#endif
        call utb05a ( iaux,
     >                rmem(pcoono), imem(psomar),
     >                imem(phettr), imem(paretr),
     >                imem(pfamtr), imem(pcfatr),
     >                imem(phetqu), imem(parequ),
     >                imem(pfamqu), imem(pcfaqu),
     >                imem(ptrite), imem(pcotrt), imem(parete),
     >                imem(phette),
     >                imem(pquahe), imem(pcoquh), imem(parehe),
     >                imem(phethe),
     >                imem(pfacpy), imem(pcofay), imem(parepy),
     >                imem(phetpy),
     >                imem(pfacpe), imem(pcofap), imem(parepe),
     >                imem(phetpe),
     >                nbiter,
     >                jaux,
     >                imem(ptrav1), imem(ptrav1+ltrav1),
     >                rmem(ptrav6), rmem(ptrav7),
     >                nuroul,
     >                ulsort, langue, codret )
c
        if ( action(1:4).eq.'info' ) then
          call gtfims (nrosec)
        endif
c
        endif
c
      endif
c
c 5.5. ==> denombrement des entites du maillage de calcul :
c          typbil est multiple de 7
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '5.5. Nombres calcul ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(typbil,7).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB07A', nompro
#endif
        call utb07a ( imem(phetar),
     >                imem(phettr), imem(pnivtr), imem(ppertr),
     >                imem(advotr),
     >                imem(phetqu), imem(pnivqu),
     >                imem(advoqu),
     >                imem(phette), imem(ptrite),
     >                imem(pperte), imem(adtes2),
     >                imem(phethe), imem(pquahe), imem(pperhe),
     >                imem(phetpy), imem(pfacpy),
     >                imem(pperpy), imem(adpys2),
     >                imem(phetpe), imem(pfacpe), imem(pperpe),
     >                imem(pposif), imem(pfacar),
     >                imem(pfamno), imem(pcfano),
     >                imem(pfammp), imem(pcfamp),
     >                imem(pfamar), imem(pcfaar),
     >                imem(pfamtr), imem(pcfatr),
     >                imem(pfamqu), imem(pcfaqu),
     >                imem(pfamte), imem(pcfate),
     >                imem(pfamhe), imem(pcfahe),
     >                imem(pfampy), imem(pcfapy),
     >                imem(pfampe), imem(pcfape),
     >                imem(ptrav1),
     >                nuroul, ulsort, langue, codret )
c
      endif
c
      endif
c
c 5.6. ==> analyse de la connexite du maillage de calcul :
c          typbil est multiple de 11
c          remarque : l'analyse est possible seulement si le maillage
c                     est conforme
c          remarque : impossible si on a elimine des mailles
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '5.6. Connexite ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      taetco(4) = taetco(4) + 1
      nrosec = taetco(4)
c
      if ( mod(typbil,11).eq.0 ) then
c
        if ( nbelig.eq.0 ) then
c
        if ( ( maconf.eq.-1 ) .or. ( maconf.eq.0 ) ) then
c
          if ( action(1:4).eq.'info' ) then
            call gtdems (nrosec)
          endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11A', nompro
#endif
          call utb11a ( imem(phetar), imem(psomar),
     >                  imem(phettr), imem(paretr),
     >                  imem(advotr), imem(adpptr),
     >                  imem(phetqu), imem(parequ),
     >                  imem(advoqu), imem(adppqu),
     >                  imem(phette), imem(ptrite),
     >                  imem(phethe), imem(pquahe),
     >                  imem(phetpy), imem(pfacpy),
     >                  imem(phetpe), imem(pfacpe),
     >                  imem(ppovos), imem(pvoiso),
     >                  imem(pposif), imem(pfacar),
     >                  imem(pfamar), imem(pcfaar),
     >                  imem(pfamtr), imem(pcfatr),
     >                  imem(pfamqu), imem(pcfaqu),
     >                  imem(pfamte), imem(pcfate),
     >                  imem(pfamhe), imem(pcfahe),
     >                  imem(pfampy), imem(pcfapy),
     >                  imem(pfampe), imem(pcfape),
     >                  imem(ptrav1), imem(ptrav2),
     >                  imem(ptrav3), imem(ptrav4),
     >                  imem(ptra11), imem(ptra12),
     >                  imem(ptra13), imem(ptra14),
     >                  imem(ptra15), imem(ptra16),
     >                  imem(ptrav5),
     >                  nuroul,
     >                  ulsort, langue, codret )
c
          if ( action(1:4).eq.'info' ) then
            call gtfims (nrosec)
          endif
c
        endif
c
        endif
c
      endif
c
      endif
c
c 5.7. ==> longueurs, surfaces et volumes des sous-domaines du maillage
c          de calcul : typbil est multiple de 13
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '5.7. tailles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      taetco(4) = taetco(4) + 1
      nrosec = taetco(4)
c
      if ( mod(typbil,13).eq.0 ) then
c
        if ( action(1:4).eq.'info' ) then
          call gtdems (nrosec)
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB13A', nompro
#endif
        call utb13a ( rmem(pcoono),
     >                imem(psomar), imem(phetar),
     >                imem(phettr), imem(paretr),
     >                imem(phetqu), imem(parequ),
     >                imem(ptrite), imem(pcotrt), imem(parete),
     >                imem(phette),
     >                imem(pquahe), imem(pcoquh), imem(parehe),
     >                imem(phethe),
     >                imem(pfacpy), imem(pcofay), imem(parepy),
     >                imem(phetpy),
     >                imem(pfacpe), imem(pcofap), imem(parepe),
     >                imem(phetpe),
     >                imem(pfamar), imem(pcfaar),
     >                imem(pfamtr), imem(pcfatr),
     >                imem(pfamqu), imem(pcfaqu),
     >                imem(pfamte), imem(pcfate),
     >                imem(pfamhe), imem(pcfahe),
     >                imem(pfampy), imem(pcfapy),
     >                imem(pfampe), imem(pcfape),
     >                nbfmed, imem(adnumf), unicoo,
     >                imem(adpoin), imem(adtail), smem(adtabl),
     >                nbgrfm, smem(ptra17), imem(ptra18),
     >                imem(ptrav1), rmem(ptrav6),
     >                imem(ptrav2),
     >                nuroul,
     >                ulsort, langue, codret )
c
        if ( action(1:4).eq.'info' ) then
          call gtfims (nrosec)
        endif
c
      endif
c
      endif
c
c 5.8. ==> caracteristiques du calcul : typbil est multiple de 17
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '5.8. caracteristiques ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      taetco(4) = taetco(4) + 1
      nrosec = taetco(4)
c
      if ( mod(typbil,17).eq.0 ) then
c
        if ( action(1:4).eq.'info' ) then
          call gtdems (nrosec)
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17A', nompro
#endif
        call utb17a ( imem(phetar), imem(psomar), imem(pnp2ar),
     >                imem(pposif), imem(pfacar),
     >                imem(phettr), imem(paretr),
     >                imem(phetqu), imem(parequ),
     >                imem(phette),
     >                imem(ptrite), imem(pcotrt), imem(parete),
     >                imem(phethe),
     >                imem(pquahe), imem(pcoquh), imem(parehe),
     >                imem(phetpy),
     >                imem(pfacpy), imem(pcofay), imem(parepy),
     >                imem(phetpe),
     >                imem(pfacpe), imem(pcofap), imem(parepe),
     >                imem(advotr),
     >                imem(advoqu),
     >                imem(pfamar), imem(pcfaar),
     >                imem(pfamtr), imem(pcfatr),
     >                imem(pfamqu), imem(pcfaqu),
     >                imem(ptrav1),
     >                nuroul,
     >                ulsort, langue, codret )
c
        if ( action(1:4).eq.'info' ) then
          call gtfims (nrosec)
        endif
c
      endif
c
      endif
c
c 5.9. ==> diametre des mailles : typbil est multiple de 19
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '5.9. diametre codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      taetco(4) = taetco(4) + 1
      nrosec = taetco(4)
c
        if ( mod(typbil,19).eq.0 ) then
c
        if ( action(1:4).eq.'info' ) then
          call gtdems (nrosec)
        endif
c
        iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB19A', nompro
#endif
        call utb19a ( iaux,
     >                rmem(pcoono), imem(psomar),
     >                imem(phettr), imem(paretr),
     >                imem(pfamtr), imem(pcfatr),
     >                imem(phetqu), imem(parequ),
     >                imem(pfamqu), imem(pcfaqu),
     >                imem(ptrite), imem(pcotrt), imem(parete),
     >                imem(phette),
     >                imem(pquahe), imem(pcoquh), imem(parehe),
     >                imem(phethe),
     >                imem(pfacpy), imem(pcofay), imem(parepy),
     >                imem(phetpy),
     >                imem(pfacpe), imem(pcofap), imem(parepe),
     >                imem(phetpe),
     >                nbiter,
     >                imem(ptrav1), rmem(ptrav6),
     >                nuroul,
     >                ulsort, langue, codret )
c
        if ( action(1:4).eq.'info' ) then
          call gtfims (nrosec)
        endif
c
        endif
c
      endif
c
c====
c 6. menage
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '6. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nuroul.ne.ulsort ) then
        call gufeul ( nuroul , codret)
      endif
c
      if ( mod(typbil,5).eq.0 .or.
     >     mod(typbil,7).eq.0 .or.
     >     mod(typbil,11).eq.0 .or.
     >     mod(typbil,13).eq.0 .or.
     >     mod(typbil,17).eq.0 .or.
     >     mod(typbil,19).eq.0  ) then
cgn        write(ulsort,*) 'trav1'
cgn        call gmprsx (nompro, ntrav1)
        call gmlboj ( ntrav1 , codret )
      endif
c
      if ( mod(typbil,11).eq.0 .or.
     >     mod(typbil,13).eq.0 ) then
cgn        write(ulsort,*) 'trav2'
cgn        call gmprsx (nompro, ntrav2)
        call gmlboj ( ntrav2 , codret )
      endif
c
      if ( mod(typbil,11).eq.0 ) then
c
cgn        write(ulsort,*) 'trav3'
cgn        call gmprsx (nompro, ntrav3)
        call gmlboj ( ntrav3, codre1 )
cgn        write(ulsort,*) 'trav4'
cgn        call gmprsx (nompro, ntrav4)
        call gmlboj ( ntrav4, codre2 )
cgn        write(ulsort,*) 'trav5'
cgn        call gmprsx (nompro, ntrav5)
        call gmlboj ( ntrav5, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
        call gmlboj ( ntra11, codre1 )
        call gmlboj ( ntra12, codre2 )
        call gmlboj ( ntra13, codre3 )
        call gmlboj ( ntra14, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        call gmlboj ( ntra15, codre1 )
        call gmlboj ( ntra16, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
c
      if ( nbfmed.gt.0 ) then
c
        call gmlboj ( ntra17, codre1 )
        call gmlboj ( ntra18, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
c
      if ( mod(typbil,5).eq.0 .or.
     >     mod(typbil,13).eq.0 .or.
     >     mod(typbil,19).eq.0 ) then
cgn        write(ulsort,*) 'trav6'
cgn        call gmprsx (nompro, ntrav6)
        call gmlboj ( ntrav6, codre0 )
        codret = max ( abs(codre0), codret )
      endif
      if ( mod(typbil,5).eq.0 ) then
        call gmlboj ( ntrav7, codre0 )
        codret = max ( abs(codre0), codret )
      endif
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(typbil,11).eq.0 ) then
c
        if ( .not.voinoe ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '.... Suppression de nhvois.0D/1D'
#endif
          call gmsgoj ( nhvois//'.0D/1D', codret )
c
        endif
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'Fin etape 6 avec codret', codret
#endif
c
c====
c 7. on impose un code de retour toujours nul
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,19))
#endif
      codret = 0
c
      write(ulsort,*) taetco(4)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c=======================================================================
      endif
c=======================================================================
c
      end
