      subroutine vcinrr ( nbvent,
     >                    nosupp, noindi,
     >                    arsupp, arindi,
     >                    trsupp, trindi,
     >                    qusupp, quindi,
     >                    tesupp, teindi,
     >                    hesupp, heindi,
     >                    pysupp, pyindi,
     >                    pesupp, peindi,
     >                    nbvapr, listpr,
     >                    nbtafo, nbvind, indica,
     >                    ncmpin, nucomp,
     >                    nnovho,
     >                    narvho,
     >                    ntrvho,
     >                    nquvho,
     >                    ntevho,
     >                    nhevho,
     >                    npyvho,
     >                    npevho,
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
c    aVant adaptation - Conversion d'INdicateur - REel
c     -                 -            --           --
c but : conversion de l'indicateur d'erreur
c       valeurs reelles double precision de l'indicateur
c               ========================
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbvent .  e .   -1:7  . nombre d'entites actives pour chaque type  .
c .        .     .        . d'element au sens HOMARD avec indicateur   .
c . nosupp .  s  . nbnoto . support pour les noeuds                    .
c . noindi .  s  . nbnoto . valeurs pour les noeuds                    .
c . arsupp .  s  . nbarto . support pour les aretes                    .
c . arindi .  s  . nbarto . valeurs pour les aretes                    .
c . trsupp .  s  . nbtrto . support pour les triangles                 .
c . trindi .  s  . nbtrto . valeurs pour les triangles                 .
c . qusupp .  s  . nbquto . support pour les quadrangles               .
c . quindi .  s  . nbquto . valeurs pour les quadrangles               .
c . tesupp .  s  . nbteto . support pour les tetraedres                .
c . teindi .  s  . nbteto . valeurs pour les tetraedres                .
c . hesupp .  s  . nbheto . support pour les hexaedres                 .
c . heindi .  s  . nbheto . valeurs pour les hexaedres                 .
c . pysupp .  s  . nbpyto . support pour les pyramides                 .
c . pyindi .  s  . nbpyto . valeurs pour les pyramides                 .
c . pesupp .  s  . nbpeto . support pour les pentaedres                .
c . peindi .  s  . nbpeto . valeurs pour les pentaedres                .
c . nbvapr . e   .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil                       .
c . listpr . e   .   *    . liste des numeros d'elements ou l'indica-  .
c .        .     .        . teur est defini.                           .
c . nbtafo . e   .   1    . nombre de tableaux dans la fonction        .
c . nbvind . e   .   1    . nombre d'entites maximum                   .
c . indica . e   . nbtafo . valeurs de l'indicateur                    .
c .        .     .*nbvind .                                            .
c . ncmpin . e   .   1    . nombre de composantes retenues             .
c . nucomp . e   . ncmpin . numeros des composantes retenues           .
c . nnovho . e   . rvnoto . numero des noeuds dans homard              .
c . narvho . e   . rvarac . numero des aretes dans homard              .
c . ntrvho . e   . rvtrac . numero des triangles dans HOMARD           .
c . nquvho . e   . rvquac . numero des quadrangles dans HOMARD         .
c . ntevho . e   . rvteac . numero des tetraedres dans HOMARD          .
c . nhevho . e   . rvheac . numero des hexaedres dans HOMARD           .
c . npyvho . e   . rvpyac . numero des pyramides dans HOMARD           .
c . npevho . e   . rvpeac . numero des pentaedres dans HOMARD          .
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
      parameter ( nompro = 'VCINRR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
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
      integer nbvent(-1:7)
      integer nosupp(nbnoto)
      integer arsupp(nbarto)
      integer trsupp(nbtrto)
      integer qusupp(nbquto)
      integer tesupp(nbteto)
      integer hesupp(nbheto)
      integer pysupp(nbpyto)
      integer pesupp(nbpeto)
      integer nbvapr
      integer nbtafo, nbvind
      integer ncmpin, nucomp(ncmpin)
      integer listpr(*)
c
      integer nnovho(*)
      integer narvho(*)
      integer ntrvho(*)
      integer nquvho(*)
      integer ntevho(*)
      integer nhevho(*)
      integer npyvho(*)
      integer npevho(*)
c
      integer ulsort, langue, codret
c
      double precision noindi(nbnoto,ncmpin), arindi(nbarto,ncmpin)
      double precision trindi(nbtrto,ncmpin), quindi(nbquto,ncmpin)
      double precision teindi(nbteto,ncmpin), heindi(nbheto,ncmpin)
      double precision pyindi(nbpyto,ncmpin), peindi(nbpeto,ncmpin)
      double precision indica(nbtafo,nbvind)
c
c 0.4. ==> variables locales
c
      integer iaux
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
      texte(1,4) = '(''. Indicateur d''''erreur sur les '',i10,1x,a)'
c
      texte(2,4) = '(''. Error indicator over '',i10,1x,a)'
c
#include "impr03.h"
c
cgn        do 111 , iaux = 1 , nbtafo
cgn        do 111 , jaux = 1 , nbvind
cgn          write (ulsort,90124) 'indica',iaux,jaux,indica(iaux,jaux)
cgn 111    continue
cgn        do 112 , iaux = 1 , rvtrac
cgn         write (ulsort,90112) 'ntrvho',iaux,ntrvho(iaux)
cgn 112    continue
cgn      print *, 'dans ',nompro,', tyelho, nbvapr = ',tyelho, nbvapr
cgn      print *, 'dans ',nompro,', nbtafo,nbvind = ',nbtafo,nbvind
c
c====
c 2. conversion selon le type d'entite
c====
c
c 2.1. ==> au moins un indicateur est exprime sur les tetraedres
c
      iaux = 3
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbteto, mess14(langue,3,iaux)
#endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCINR1_te', nompro
#endif
        call vcinr1 ( nbteto, nbvent(iaux), nbvapr,
     >                nbtafo, nbvind, ncmpin, nucomp,
     >                indica, ntevho, listpr,
     >                tesupp, teindi,
     >                ulsort, langue, codret)
c
      endif
c
c 2.2. ==> au moins un indicateur est exprime sur les quadrangles
c
      iaux = 4
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbquto, mess14(langue,3,iaux)
#endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCINR1_qu', nompro
#endif
        call vcinr1 ( nbquto, nbvent(iaux), nbvapr,
     >                nbtafo, nbvind, ncmpin, nucomp,
     >                indica, nquvho, listpr,
     >                qusupp, quindi,
     >                ulsort, langue, codret)
c
      endif
c
c 2.3. ==> au moins un indicateur est exprime sur les triangles
c
      iaux = 2
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbtrto, mess14(langue,3,iaux)
#endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCINR1_tr', nompro
#endif
        call vcinr1 ( nbtrto, nbvent(iaux), nbvapr,
     >                nbtafo, nbvind, ncmpin, nucomp,
     >                indica, ntrvho, listpr,
     >                trsupp, trindi,
     >                ulsort, langue, codret)
c
      endif
c
c 2.4. ==> au moins un indicateur est exprime sur les aretes
c
      iaux = 1
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbarto, mess14(langue,3,iaux)
#endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCINR1_ar', nompro
#endif
        call vcinr1 ( nbarto, nbvent(iaux), nbvapr,
     >                nbtafo, nbvind, ncmpin, nucomp,
     >                indica, narvho, listpr,
     >                arsupp, arindi,
     >                ulsort, langue, codret)
c
      endif
c
c 2.5. ==> au moins un indicateur est exprime sur les noeuds
c
      iaux = -1
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbnoto, mess14(langue,3,iaux)
#endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCINR1_no', nompro
#endif
        call vcinr1 ( nbnoto, nbvent(iaux), nbvapr,
     >                nbtafo, nbvind, ncmpin, nucomp,
     >                indica, nnovho, listpr,
     >                nosupp, noindi,
     >                ulsort, langue, codret)
c
      endif
c
c 2.5. ==> au moins un indicateur est exprime sur les pyramides
c
      iaux = 5
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbpyto, mess14(langue,3,iaux)
#endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCINR1_py', nompro
#endif
        call vcinr1 ( nbpyto, nbvent(iaux), nbvapr,
     >                nbtafo, nbvind, ncmpin, nucomp,
     >                indica, npyvho, listpr,
     >                pysupp, pyindi,
     >                ulsort, langue, codret)
c
      endif
c
c 2.6. ==> au moins un indicateur est exprime sur les hexaedres
c
      iaux = 6
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbheto, mess14(langue,3,iaux)
#endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCINR1_he', nompro
#endif
        call vcinr1 ( nbheto, nbvent(iaux), nbvapr,
     >                nbtafo, nbvind, ncmpin, nucomp,
     >                indica, nhevho, listpr,
     >                hesupp, heindi,
     >                ulsort, langue, codret)
c
      endif
c
c 2.7. ==> au moins un indicateur est exprime sur les pentaedres
c
      iaux = 7
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbheto, mess14(langue,3,iaux)
#endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCINR1_pe', nompro
#endif
        call vcinr1 ( nbpeto, nbvent(iaux), nbvapr,
     >                nbtafo, nbvind, ncmpin, nucomp,
     >                indica, npevho, listpr,
     >                pesupp, peindi,
     >                ulsort, langue, codret)
c
      endif
c
c====
c 3. la fin
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
