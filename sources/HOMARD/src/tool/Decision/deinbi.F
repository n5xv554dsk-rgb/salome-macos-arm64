      subroutine deinbi ( nbvent, ncmpin,
     >                    nosupp, noindi,
     >                    arsupp, arindi,
     >                    trsupp, trindi,
     >                    qusupp, quindi,
     >                    tesupp, teindi,
     >                    hesupp, heindi,
     >                    pysupp, pyindi,
     >                    pesupp, peindi,
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
c traitement des DEcisions - INitialisations - BIlan
c                --          --                --
c    impression des histogrammes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbvent .  e .   -1:7  . nombre d'entites actives pour chaque type  .
c .        .     .        . d'element au sens HOMARD avec indicateur   .
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . nosupp . e   . nbnoto . support pour les noeuds                    .
c . noindi . e   . nbnoto . valeurs pour les noeuds                    .
c . arsupp . e   . nbarto . support pour les aretes                    .
c . arindi . e   . nbarto . valeurs pour les aretes                    .
c . trsupp . e   . nbtrto . support pour les triangles                 .
c . trindi . e   . nbtrto . valeurs pour les triangles                 .
c . qusupp . e   . nbquto . support pour les quadrangles               .
c . quindi . e   . nbquto . valeurs pour les quadrangles               .
c . tesupp . e   . nbteto . support pour les tetraedres                .
c . teindi . e   . nbteto . valeurs pour les tetraedres                .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
c . heindi . e   . nbheto . valeurs pour les hexaedres                 .
c . pysupp . e   . nbpyto . support pour les pyramides                 .
c . pyindi . e   . nbpyto . valeurs pour les pyramides                 .
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
      parameter ( nompro = 'DEINBI' )
c
#include "nblang.h"
c
c 0.2. ==> communs
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
      integer nbvent(-1:7)
      integer ncmpin
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
c====
c 2. impression selon le type d'entite
c====
c
c 2.1. ==> au moins un indicateur est exprime sur les tetraedres
c
      iaux = 3
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEINB1_te', nompro
#endif
        call deinb1 ( iaux, nbteto, ncmpin,
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
        write (ulsort,texte(langue,3)) 'DEINB1_qu', nompro
#endif
        call deinb1 ( iaux, nbquto, ncmpin,
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
        write (ulsort,texte(langue,3)) 'DEINB1_tr', nompro
#endif
        call deinb1 ( iaux, nbtrto, ncmpin,
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
        write (ulsort,texte(langue,3)) 'DEINB1_ar', nompro
#endif
        call deinb1 ( iaux, nbarto, ncmpin,
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
        write (ulsort,texte(langue,3)) 'DEINB1_no', nompro
#endif
        call deinb1 ( iaux, nbnoto, ncmpin,
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
        write (ulsort,texte(langue,3)) 'DEINB1_py', nompro
#endif
        call deinb1 ( iaux, nbpyto, ncmpin,
     >                pysupp, pyindi,
     >                ulsort, langue, codret)
c
      endif
c
c 2.5. ==> au moins un indicateur est exprime sur les hexaedres
c
      iaux = 6
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEINB1_he', nompro
#endif
        call deinb1 ( iaux, nbheto, ncmpin,
     >                hesupp, heindi,
     >                ulsort, langue, codret)
c
      endif
c
c 2.6. ==> au moins un indicateur est exprime sur les pentaedres
c
      iaux = 7
      if ( nbvent(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEINB1_pe', nompro
#endif
        call deinb1 ( iaux, nbpeto, ncmpin,
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
