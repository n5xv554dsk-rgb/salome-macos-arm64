      subroutine deisv0 ( ncmpin, nbvent,
     >                    tesupp, teindi, teinin,
     >                    hesupp, heindi, heinin,
     >                    pysupp, pyindi, pyinin,
     >                    pesupp, peindi, peinin,
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
c    traitement des DEcisions - Initialisations - par Saut - Volumes - 0
c                   --          -                     -      -         -
c
c    Sauvegarde des valeurs initiales
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . nbvent .  e .   -1:7  . nombre d'entites actives pour chaque type  .
c .        .     .        . d'element au sens HOMARD avec indicateur   .
c . tesupp . e   . nbteto . support pour les tetraedres                .
c . teindi . e   . nbteto . valeurs pour les tetraedres                .
c . teinin .  s  . nbteto . valeurs initiales pour les tetraedres      .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
c . heindi . e   . nbheto . valeurs pour les hexaedres                 .
c . heinin .  s  . nbheto . valeurs initiales pour les hexaedres       .
c . pysupp . e   . nbpyto . support pour les pyramides                 .
c . pyindi . e   . nbpyto . valeurs pour les pyramides                 .
c . pyinin .  s  . nbpyto . valeurs initiales pour les pyramides       .
c . pesupp . e   . nbpeto . support pour les pentaedres                .
c . peindi . e   . nbpeto . valeurs pour les pentaedres                .
c . peinin .  s  . nbpeto . valeurs initiales pour les pentaedres      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEISV0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer ncmpin
      integer nbvent(-1:7)
      integer tesupp(nbteto)
      integer hesupp(nbheto)
      integer pysupp(nbpyto)
      integer pesupp(nbpeto)
c
      double precision teindi(nbteto,ncmpin), teinin(nbteto,ncmpin)
      double precision heindi(nbheto,ncmpin), heinin(nbheto,ncmpin)
      double precision pyindi(nbpyto,ncmpin), pyinin(nbpyto,ncmpin)
      double precision peindi(nbpeto,ncmpin), peinin(nbpeto,ncmpin)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nrcomp
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. prealables
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =' (''Sauvegardes des indicateurs sur les '',i10,1x,a)'
c
      texte(2,4) = '(''Saving of indicator over '',i10,1x,a)'
c
      codret = 0
c
c====
c 2. Sauvegardes des indicateurs
c====
c 2.1. ==> Sur les tetraedres
c
      if ( nbvent(3).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbteto, mess14(langue,3,3)
#endif
c
      do 21 , iaux = 1 , nbteto
        if ( tesupp(iaux).ne.0 ) then
          do 211 , nrcomp = 1 , ncmpin
            teinin(iaux,nrcomp) = teindi(iaux,nrcomp)
  211     continue
        endif
   21 continue
c
      endif
c
c 2.2. ==> Sur les hexaedres
c
      if ( nbvent(6).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbheto, mess14(langue,3,6)
#endif
c
      do 22 , iaux = 1 , nbheto
        if ( hesupp(iaux).ne.0 ) then
          do 221 , nrcomp = 1 , ncmpin
            heinin(iaux,nrcomp) = heindi(iaux,nrcomp)
  221     continue
        endif
   22 continue
c
      endif
c
c 2.3. ==> Sur les pyramides
c
      if ( nbvent(5).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbpyto, mess14(langue,3,5)
#endif
c
      do 23 , iaux = 1 , nbpyto
        if ( pysupp(iaux).ne.0 ) then
          do 231 , nrcomp = 1 , ncmpin
            pyinin(iaux,nrcomp) = pyindi(iaux,nrcomp)
  231     continue
        endif
   23 continue
c
      endif
c
c 2.4. ==> Sur les pentaedres
c
      if ( nbvent(7).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbpeto, mess14(langue,3,7)
#endif
c
      do 24 , iaux = 1 , nbpeto
        if ( pesupp(iaux).ne.0 ) then
          do 241 , nrcomp = 1 , ncmpin
            peinin(iaux,nrcomp) = peindi(iaux,nrcomp)
  241     continue
        endif
   24 continue
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
