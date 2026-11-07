      subroutine gmdmp (letype, gmimp)
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
c but : gere l'impression generale
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letype . e   . char8  . type des structures a imprimer             .
c .        .     .        . 'entier  ' -> appel gmdmpi : entier        .
c .        .     .        . 'reel    ' -> appel gmdmpr : reel          .
c .        .     .        . 'chaine  ' -> appel gmdmps : chaine        .
c .        .     .        . 'struct  ' -> appel gmdmpt : structure     .
c .        .     .        . 'dicosdgm' -> appel gmdmpt : dictionnaire  .
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
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtors.h"
#include "gmimpr.h"
c
c 0.3. ==> arguments
c
      character*8 letype
      integer gmimp
c
c 0.4. ==> variables locales
c
      character*8 typem
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. appel du programme specialise ad-hoc
c====
c
cgn      print *,'letype =',letype
      call gbminu(letype,typem)
c
      if ( typem.eq.nomtyb(1) ) then
         call gmdmpi ( gmimp )
      else if ( typem.eq.nomtyb(2) ) then
         call gmdmpr ( gmimp )
      else if ( typem.eq.nomtyb(3) ) then
         call gmdmps ( gmimp )
      else if ( typem.eq.nomtyb(4) ) then
         call gmdmpt( 2, gmimp )
      else if ( typem.eq.'dicosdgm' ) then
         call gmdmpt( 1, gmimp )
      else
         write(ulsort,*) 'GMDMP -> type : ',letype,' inconnu'
         call dmabor
      endif
c
      end
