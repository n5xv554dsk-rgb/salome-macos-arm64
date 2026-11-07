      subroutine utpr06 ( option,
     >                    nbentn, nbentp,
     >                    volfac, neneho,
     >                    nvolho, nvolca,
     >                    obpcan, obpcap,
     >                    adpcan, adpcap,
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
c    UTilitaire - PRofil operation 06
c    --           --               --
c
c  Cree deux profils etendus pour les interpolations si extrusion
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . -1 : on cree l'etape n                     .
c .        .     .        .  0 : on cree les 2 etapes                  .
c .        .     .        .  1 : on cree l'etape p                     .
c . nbentn . e   .   1    . nombre d'entites calcul a l'etape n        .
c . nbentp . e   .   1    . nombre d'entites calcul a l'etape p        .
c . volfac . e   .    *   . volumes de la face                         .
c . neneho . e   .    *   . numero des entites en entree dans HOMARD   .
c . nvolho . e   .    *   . numero des entites volumes en entree       .
c . nvolca . e   .    *   . numero des entites volumes (cf. vcmext)    .
c . obpcan .  s  . char*8 . nom de l'objet profil etendu a l'etape n   .
c . obpcap .  s  . char*8 . nom de l'objet profil etendu a l'etape p   .
c .        .     .        . ce profil est mis a 0 par defaut           .
c . adpcan .  s  .   1    . adresse du tableau entier associe a obpcan .
c . adpcap .  s  .   1    . adresse du tableau entier associe a obpcap .
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
      parameter ( nompro = 'UTPR06' )
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
      integer option
      integer nbentn, nbentp
      integer neneho(*)
      integer volfac(*)
      integer nvolho(*)
      integer nvolca(*)
      integer adpcan, adpcap
c
      character*8 obpcan, obpcap
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codre1, codre2
      integer codre0
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
      texte(1,4) =
     > '(''Longueur du profil etendu a l''''etape '',a1,'' : '',i10)'
      texte(1,5) =
     > '(''Creation du profil etendu a l''''etape '',a1,'' : '',a)'
c
      texte(2,4) =
     > '(''Longueur du profil etendu a l''''etape '',a1,'': '',i10)'
      texte(2,5) =
     > '(''Creation of long profile at stage '',a1,'': '',a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
#endif
c
c====
c 2. allocations des deux tableaux entiers des profils etendus
c====
c
#ifdef _DEBUG_HOMARD_
      if ( option.le.0 ) then
        write (ulsort,texte(langue,4)) 'n', nbentn
      endif
      if ( option.ge.0 ) then
        write (ulsort,texte(langue,4)) 'p', nbentp
      endif
#endif
c
      if ( option.le.0 ) then
        call gmalot ( obpcan, 'entier  ', nbentn, adpcan, codre1 )
      else
        codre1 = 0
      endif
c
      if ( option.ge.0 ) then
        call gmalot ( obpcap, 'entier  ', nbentp, adpcap, codre2 )
      else
        codre2 = 0
      endif
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
      if ( option.le.0 ) then
        write (ulsort,texte(langue,5)) 'n', obpcan
      endif
      if ( option.ge.0 ) then
        write (ulsort,texte(langue,5)) 'p', obpcap
      endif
#endif
c
c====
c 3. remplissage du tableau a l'etape n
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. remplissage n ; codret', codret
#endif
c
      if ( option.le.0 ) then
c
        if ( codret.eq.0 ) then
c
        do 31 , iaux = 1 , nbentn
          jaux = neneho(iaux)
          if ( jaux.gt.0 ) then
cgn      write (ulsort,90002) 'iaux', iaux
cgn      write (ulsort,90112) '- volfac', jaux, volfac(jaux)
cgn      write (ulsort,90002) '- nvolca', nvolca(volfac(jaux))
cgn      write (ulsort,90002) '- profil', nvolho(nvolca(volfac(jaux)))
            imem(adpcan-1+iaux) = nvolho(nvolca(volfac(jaux)))
          else
            imem(adpcan-1+iaux) = 0
          endif
   31   continue
c
        endif
c
cgn      call gmprsx (nompro, obpcan )
c
      endif
c
c====
c 4. remplissage du tableau a l'etape p : rien a priori
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. remplissage p ; codret', codret
#endif
c
      if ( option.ge.0 ) then
c
        if ( codret.eq.0 ) then
c
        do 41 , iaux = adpcap , adpcap+nbentp-1
          imem(iaux) = 0
   41   continue
c
cgn        call gmprsx (nompro, obpcap )
c
      endif
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
