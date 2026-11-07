      subroutine utpr04 ( obpro1, obpro2,
     >                    bilan,
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
c    UTilitaire - PRofil operation 04
c    --           --               --
c
c  Compare deux profils
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . obpro1 . e   . char*8 . nom de l'objet de type 'Profil' numero 1   .
c . obpro2 . e   . char*8 . nom de l'objet de type 'Profil' numero 2   .
c . bilan  .   s .   1    . bilan de la comparaison :                  .
c .        .     .        . 0 : identite totale                        .
c .        .     .        . 1 : liste identique, mais noms differents  .
c .        .     .        . 2 : liste differente avec meme nombre      .
c .        .     .        .  de valeurs                                .
c .        .     .        . 3 : nombre de valeurs differents           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . autre : probleme dans l'allocation         .
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
      parameter ( nompro = 'UTPR04' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer bilan
c
      character*8 obpro1, obpro2
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbvap1, adlip1, lgnop1
      integer nbvap2, adlip2, lgnop2
c
      character*64 nopro1, nopro2
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
      texte(1,4) = '(''Profil numero '',i1)'
      texte(1,5) = '(''. Objet de type ''''Profil'''' associe : '',a)'
      texte(1,6) = '(''. Longueur : '',i10)'
      texte(1,7) = '(''. Nom      : '',a)'
      texte(1,8) = '(''. 1ere valeur     : '',i10)'
      texte(1,9) = '(''. Derniere valeur : '',i10)'
c
      texte(2,4) = '(''Profil # '',i1)'
      texte(2,5) =
     > '(''. Object of type ''''Profil'''' connected to : '',a)'
      texte(2,6) = '(''. Length : '',i10)'
      texte(2,7) = '(''. Name   : '',a)'
      texte(2,8) = '(''. First value   : '',i10)'
      texte(2,9) = '(''. Last value    : '',i10)'
c
c====
c 2. caracteristiques
c====
c 2.1. ==> profil 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 1
      write (ulsort,texte(langue,5)) obpro1
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPR', nompro
#endif
      call utcapr ( obpro1,
     >              nbvap1, nopro1, adlip1,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nbvap1
      write (ulsort,texte(langue,7)) nopro1
      write (ulsort,texte(langue,8)) imem(adlip1)
      write (ulsort,texte(langue,9)) imem(adlip1+nbvap1-1)
#endif
c
c 2.2. ==> profil 2
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 2
      write (ulsort,texte(langue,5)) obpro2
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPR', nompro
#endif
      call utcapr ( obpro2,
     >              nbvap2, nopro2, adlip2,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nbvap2
      write (ulsort,texte(langue,7)) nopro2
      write (ulsort,texte(langue,8)) imem(adlip2)
      write (ulsort,texte(langue,9)) imem(adlip2+nbvap2-1)
#endif
c
      endif
c
c====
c 3. tri sur le nombre de valeurs
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbvap1.ne.nbvap2 ) then
c
        bilan = 3
        goto 9999
c
      endif
c
      endif
c
c====
c 4. tri sur les valeurs
c====
c
      if ( codret.eq.0 ) then
c
      do 41 , iaux = 0 , nbvap1-1
c
        if ( imem(adlip1+iaux).ne.imem(adlip2+iaux) ) then
c
          bilan = 2
          goto 9999
c
        endif
c
   41 continue
c
      endif
c
c====
c 5. tri sur le nom
c====
c
      if ( codret.eq.0 ) then
c
      call utlgut ( lgnop1, nopro1,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call utlgut ( lgnop2, nopro2,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( lgnop1.eq.lgnop2 ) then
c
        if ( nopro1.eq.nopro2 ) then
          bilan = 0
        else
          bilan = 1
        endif
c
      else
c
          bilan = 1
c
      endif
c
      endif
c
c====
c 6. la fin
c====
c
 9999 continue
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
