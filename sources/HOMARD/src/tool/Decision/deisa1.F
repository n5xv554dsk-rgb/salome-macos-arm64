      subroutine deisa1 ( nbvent, ncmpin, usacmp,
     >                    nosupp, noindi,
     >                    arsupp, arindi,
     >                    trsupp, trindi,
     >                    qusupp, quindi,
     >                    tesupp, teindi,
     >                    hesupp, heindi,
     >                    pysupp, pyindi,
     >                    pesupp, peindi,
     >                    nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    nomail, nhvois,
     >                    ulsort, langue, codret)
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
c traitement des DEcisions - Initialisations - SAut - etape 1
c                --          -                 --           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbvent .  e .   -1:7  . nombre d'entites actives pour chaque type  .
c .        .     .        . d'element au sens HOMARD avec indicateur   .
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . nosupp . e   . nbnoto . support pour les noeuds                    .
c . noindi . es  . nbnoto . valeurs reelles pour les noeuds            .
c . arsupp .  s  . nbarto . support pour les aretes                    .
c . arindi .  s  . nbarto . valeurs reelles pour les aretes            .
c . trsupp . e   . nbtrto . support pour les triangles                 .
c . trindi .  s  . nbtrto . valeurs pour les triangles                 .
c . qusupp . e   . nbquto . support pour les quadrangles               .
c . quindi .  s  . nbquto . valeurs pour les quadrangles               .
c . tesupp . e   . nbteto . support pour les tetraedres                .
c . teindi .  s  . nbteto . valeurs pour les tetraedres                .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
c . heindi .  s  . nbheto . valeurs pour les hexaedres                 .
c . pysupp . e   . nbpyto . support pour les pyramides                 .
c . pyindi .  s  . nbpyto . valeurs pour les pyramides                 .
c . pesupp . e   . nbpeto . support pour les pentaedres                .
c . peindi .  s  . nbpeto . valeurs pour les pentaedres                .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme dans les fichiers             .
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
      parameter ( nompro = 'DEISA1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmreel.h"
#include "gmenti.h"
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer nbvent(-1:7), ncmpin
      integer usacmp
      integer nosupp(nbnoto)
      integer arsupp(nbarto)
      integer trsupp(nbtrto)
      integer qusupp(nbquto)
      integer tesupp(nbteto)
      integer hesupp(nbheto)
      integer pysupp(nbpyto)
      integer pesupp(nbpeto)
c
      integer ulsort, langue, codret
c
      double precision noindi(nbnoto,ncmpin)
      double precision arindi(nbarto,ncmpin)
      double precision trindi(nbtrto,ncmpin)
      double precision quindi(nbquto,ncmpin)
      double precision teindi(nbteto,ncmpin)
      double precision heindi(nbheto,ncmpin)
      double precision pyindi(nbpyto,ncmpin)
      double precision peindi(nbpeto,ncmpin)
c
      character*8 nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nomail, nhvois
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6
      integer codre0
c
      integer phetar, psomar, pfilar, pmerar
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer phettr, paretr, pfiltr, ppertr
      integer phetqu, parequ, pfilqu, pperqu
      integer phette, ptrite, pfilte, pperte, adtes2
      integer phethe, pquahe, pfilhe, pperhe, adhes2
      integer phetpy, pfacpy, pperpy, adpys2
      integer phetpe, pfacpe, pperpe
      integer adtra1, adtra2
      integer adtrte, adtrhe, adtrpy, adtrpe
      integer advotr, adpptr
      integer advoqu, adppqu
c
      character*8 ntrav1, ntrav2
      character*8 ntrate, ntrahe, ntrapy, ntrape
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
c====
c 2. les tableaux
c====
c
c 2.1. ==> les tableaux de travail
c
      if ( codret.eq.0 ) then
c
      iaux = max(4*(nbquto+nbtrto), nbarto)
      call gmalot ( ntrav1, 'entier  ', iaux, adtra1, codre1 )
      iaux = max(2*(nbquto+nbtrto), nbarto, nbnoto)
      iaux = iaux * ncmpin
      call gmalot ( ntrav2, 'reel    ', iaux, adtra2, codre2 )
      iaux = nbteto * ncmpin
      call gmalot ( ntrate, 'reel    ', iaux, adtrte, codre3 )
      iaux = nbheto * ncmpin
      call gmalot ( ntrahe, 'reel    ', iaux, adtrhe, codre4 )
      iaux = nbpyto * ncmpin
      call gmalot ( ntrapy, 'reel    ', iaux, adtrpy, codre5 )
      iaux = nbpeto * ncmpin
      call gmalot ( ntrape, 'reel    ', iaux, adtrpe, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
      endif
c
c 2.2. ==> les tableaux du maillage
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. les tableaux ; codret', codret
#endif
c
      if ( nbvent(-1).ne.0 .or. nbvent(1).ne.0 .or.
     >      nbvent(2).ne.0 .or. nbvent(4).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
        iaux = 30
        call utad02 ( iaux, nharet,
     >                phetar, psomar, pfilar, pmerar,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbvent(2).ne.0 .or. nbvent(3).ne.0 .or.
     >     ( nbtrto.gt.0 .and. nbvent(4).ne.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        iaux = 30
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbvent(4).ne.0 .or. nbvent(6).ne.0 .or.
     >     ( nbquto.gt.0 .and. nbvent(2).ne.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 30
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbvent(3).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        iaux = 2*3
        if ( nbteca.gt.0 ) then
          iaux = iaux*5*17
        endif
        call utad02 ( iaux, nhtetr,
     >                phette, ptrite, pfilte, pperte,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux, adtes2,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbvent(5).ne.0 .or.
     >     ( nbpyto.gt.0 .and. nbvent(3).ne.0 ) .or.
     >     ( nbpyto.gt.0 .and. nbvent(6).ne.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        iaux = 2
        if ( nbpyca.gt.0 ) then
          iaux = iaux*5*17
        endif
        call utad02 ( iaux, nhpyra,
     >                phetpy, pfacpy, jaux  , pperpy,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux, adpys2,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbvent(6).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 2*3
        if ( nbheco.gt.0 ) then
          iaux = iaux*5*17
        endif
        call utad02 ( iaux, nhhexa,
     >                phethe, pquahe, pfilhe, pperhe,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux, adhes2,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbvent(7).ne.0 .or.
     >     ( nbpeto.gt.0 .and. nbvent(3).ne.0 ) .or.
     >     ( nbpeto.gt.0 .and. nbvent(6).ne.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        iaux = 2
        if ( nbpeca.gt.0 ) then
          iaux = iaux*5
        endif
        call utad02 ( iaux, nhpent,
     >                phetpe, pfacpe, jaux  , pperpe,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
c 2.3. ==> Voisinages
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. ==> Voisinages ; codret', codret
#endif
c
      if ( nbvent(-1).ne.0 ) then
c
        if ( codret.eq.0 ) then
c
       iaux = 1
       jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
       call utvois ( nomail, nhvois,
     >               iaux, jaux, jaux, jaux,
     >               ppovos, pvoiso,
     >               kaux, kaux, kaux,
     >               ulsort, langue, codret)
c
        endif
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      iaux = 1
      if ( nbvent(-1).ne.0 ) then
        iaux = iaux*2
      endif
      if ( nbvent(2).ne.0 .or. nbvent(4).ne.0 ) then
        iaux = iaux*3
      endif
      if ( nbvent(3).ne.0 ) then
        iaux = iaux*5
        if ( nbpyto.gt.0 .or. nbpeto.gt.0 ) then
          iaux = iaux*13
        endif
      endif
      if ( nbvent(6).ne.0 ) then
        iaux = iaux*7
        if ( nbpyto.gt.0 .or. nbpeto.gt.0 ) then
          iaux = iaux*17
        endif
      endif
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
c
c====
c 3. Operation
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. operation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISA2', nompro
#endif
      call deisa2 ( nbvent, ncmpin, usacmp,
     >              nosupp, noindi,
     >              arsupp, arindi,
     >              trsupp, trindi,
     >              qusupp, quindi,
     >              tesupp, teindi, rmem(adtrte),
     >              hesupp, heindi, rmem(adtrhe),
     >              pysupp, pyindi, rmem(adtrpy),
     >              pesupp, peindi, rmem(adtrpe),
     >              imem(phetar), imem(psomar),
     >              imem(pfilar), imem(pmerar),
     >              imem(phettr), imem(paretr),
     >              imem(pfiltr), imem(ppertr),
     >              imem(phetqu), imem(parequ),
     >              imem(pfilqu), imem(pperqu),
     >              imem(phette), imem(ptrite),
     >              imem(pperte), imem(adtes2),
     >              imem(phethe), imem(pquahe),
     >              imem(pfilhe), imem(pperhe), imem(adhes2),
     >              imem(pfacpy),
     >              imem(pfacpe),
     >              imem(pposif), imem(pfacar),
     >              imem(advotr), imem(adpptr),
     >              imem(advoqu), imem(adppqu),
     >              imem(adtra1), rmem(adtra2),
     >              ulsort, langue, codret)
c
      endif
c
c====
c 4. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
      call gmlboj ( ntrate, codre3 )
      call gmlboj ( ntrahe, codre4 )
      call gmlboj ( ntrapy, codre5 )
      call gmlboj ( ntrape, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
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
