      subroutine deisv5 ( lamail, ncmpin, usacmp,
     >                    nbenti, enindi, eninin,
     >                    tesupp, teinin,
     >                    hesupp, heinin,
     >                    pysupp, pyinin,
     >                    pesupp, peinin,
     >                    nbvote, voiste,
     >                    nbvohe, voishe,
     >                    nbvopy, voispy,
     >                    nbvope, voispe,
     >                    valaux,
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
c    traitement des DEcisions - Initialisations - par Saut - Volumes - 5
c                   --          -                     -      -         -
c    Calcul des sauts sur tous les voisins
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lamail . e   .   1    . la maille en cours d'examen                .
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . nbenti . e   .   1    . nombre d'entites courantes                 .
c . eninin . e   . ncmpin . valeur brute de l'indicateur sur la maille .
c . enindi . es  . ncmpin . valeur du saut de l'indicateur             .
c . tesupp . e   . nbteto . support pour les tetraedres                .
c . teinin . e   . nbteto . valeurs initiales pour les tetraedres      .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
c . heinin . e   . nbheto . valeurs initiales pour les hexaedres       .
c . pysupp . e   . nbpyto . support pour les pyramides                 .
c . pyinin . e   . nbpyto . valeurs initiales pour les pyramides       .
c . pesupp . e   . nbpeto . support pour les pentaedres                .
c . peinin . e   . nbpeto . valeurs initiales pour les pentaedres      .
c . nbvote . e   .    1   . nombre de voisins de type tetraedre        .
c . voiste . e   . nbvote . les voisins de type tetraedre              .
c . nbvohe . e   .    1   . nombre de voisins de type hexaedre         .
c . voishe . e   . nbvohe . les voisins de type hexaedre               .
c . nbvopy . e   .    1   . nombre de voisins de type pyramide         .
c . voispy . e   . nbvopy . les voisins de type pyramide               .
c . nbvope . e   .    1   . nombre de voisins de type pentaedre        .
c . voispe . e   . nbvope . les voisins de type pentaedre              .
c . valaux . a   . ncmpin . tableau auxiliaire                         .
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
      parameter ( nompro = 'DEISV5' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "infini.h"
#include "impr02.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer lamail
      integer ncmpin
      integer usacmp
      integer nbenti
      integer tesupp(nbteto)
      integer hesupp(nbheto)
      integer pysupp(nbpyto)
      integer pesupp(nbpeto)
c
      integer nbvote, voiste(*)
      integer nbvohe, voishe(*)
      integer nbvopy, voispy(*)
      integer nbvope, voispe(*)
c
      integer ulsort, langue, codret
c
      double precision eninin(nbenti,ncmpin), enindi(nbenti,ncmpin)
      double precision teinin(nbteto,ncmpin)
      double precision heinin(nbheto,ncmpin)
      double precision pyinin(nbpyto,ncmpin)
      double precision peinin(nbpeto,ncmpin)
      double precision valaux(ncmpin)
c
c 0.4. ==> variables locales
c
      integer iaux
c
      double precision vasmax
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Saut avec les '',i10,1x,a)'
c
      texte(2,4) = '(''. Jump with the '',i10,1x,a)'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbvote', nbvote
      write (ulsort,90002) 'nbvohe', nbvohe
      write (ulsort,90002) 'nbvopy', nbvopy
      write (ulsort,90002) 'nbvope', nbvope
#endif
c
      vasmax = vinfne
c
c====
c 2. Saut avec des voisins tetraedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Saut avec tetraedres ; codret = ', codret
#endif
c
      if ( nbvote.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbvote, mess14(langue,3,3)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV4 / tetr', nompro
#endif
        call deisv4 ( ncmpin, usacmp, vasmax,
     >                lamail, nbvote, voiste,
     >                nbenti, enindi, eninin,
     >                nbteto, tesupp, teinin,
     >                valaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 3. Saut avec des voisins hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Saut avec hexaedres ; codret = ', codret
#endif
c
      if ( nbvohe.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbvohe, mess14(langue,3,6)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV4 / hexa', nompro
#endif
        call deisv4 ( ncmpin, usacmp, vasmax,
     >                lamail, nbvohe, voishe,
     >                nbenti, enindi, eninin,
     >                nbheto, hesupp, heinin,
     >                valaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 4. Saut avec des voisins pyramides
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Saut avec pyramides ; codret = ', codret
#endif
c
      if ( nbvopy.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbvopy, mess14(langue,3,5)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV4 / pyra', nompro
#endif
        call deisv4 ( ncmpin, usacmp, vasmax,
     >                lamail, nbvopy, voispy,
     >                nbenti, enindi, eninin,
     >                nbpyto, pysupp, pyinin,
     >                valaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 5. Saut avec des voisins pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Saut avec pentaedres ; codret = ', codret
#endif
c
      if ( nbvope.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbvope, mess14(langue,3,7)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV4 / pent', nompro
#endif
        call deisv4 ( ncmpin, usacmp, vasmax,
     >                lamail, nbvope, voispe,
     >                nbenti, enindi, eninin,
     >                nbpeto, pesupp, peinin,
     >                valaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 6. la fin
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
