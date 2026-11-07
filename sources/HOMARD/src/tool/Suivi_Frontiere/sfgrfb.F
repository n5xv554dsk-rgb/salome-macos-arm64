      subroutine sfgrfb ( nocmaf, ncafdg,
     >                    nblign, nbf, nbgrmx,
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
c   Suivi de Frontiere - GRoupes de la Frontiere - phase B
c   -        -           --            -                 -
c remarque : sfgrfa et sfgrfb sont des clones
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocmaf . e   . char*8 . nom de l'objet maillage de la frontiere    .
c . ncafdg . es  . char*8 . nom de l'objet groupes/attributs frontiere .
c . nblign .   s .    1   . nombre de lignes a considerer              .
c . nbf    . e   .   1    . nombre de familles du maillage frontiere   .
c . nbgrmx . e   .   1    . nombre maxi de groupes dans les familles   .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme avec la memoire               .
c .        .     .        . 3 : probleme avec le fichier               .
c .        .     .        . 5 : contenu incorrect                      .
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
      parameter ( nompro = 'SFGRFB' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer nblign, nbf, nbgrmx
c
      character*8 nocmaf, ncafdg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lgtabl
      integer adtyel, adfael
      integer pointl, pttgrl, ptngrl
      integer adgrtb, adgrpo, adnufa
      integer nbmail, nbfseg
      integer ptrav1, ptrav2
      integer codre1, codre2
      integer codre0
c
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. recuperation des adresses
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. adresses et reperage ; codret', codret
#endif
c
c 2.1. ==> le tableau trav1 contiendra la liste des familles du maillage
c          frontiere qui contiennent au moins un groupe. Il est alloue
c          au maximum theorique qui vaut le nombre total de groupes
c          constituant les familles + 1 pour la famille nulle
c          le tableau trav2 contiendra la liste des numeros des groupes
c          voulus et qui sont effectivement un groupe frontiere
c
      if ( codret.eq.0 ) then
c
      iaux = nbgrmx + 1
      call gmalot ( ntrav1, 'entier  ',   iaux, ptrav1, codre1 )
      call gmalot ( ntrav2, 'entier  ', nblign, ptrav2, codre2)
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 2.2. ==> adresses et filtrage
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nocmaf )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFGRF0', nompro
#endif
      call sfgrf0 ( nocmaf,
     >              nbmail,
     >              adtyel, adfael,
     >              adnufa, adgrpo, adgrtb,
     >              nbfseg, imem(ptrav1),
     >              ulsort, langue, codret)
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,ntrav1 )
      call gmprsx (nompro,ntrav2 )
#endif
c
      endif
c
c====
c 3. recuperation des caracteristiques de la liste
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. recuperation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,ncafdg )
      call gmprsx (nompro,ncafdg//'.Pointeur' )
      call gmprsx (nompro,ncafdg//'.Table' )
      call gmprsx (nompro,ncafdg//'.Taille' )
#endif
      iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
      call utadpt ( ncafdg, iaux,
     >              jaux, lgtabl,
     >              pointl, pttgrl, ptngrl,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. on verifie les tableaux
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. remplissage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
cgn      call gmprsx (nompro, ncfami//'.Groupe.Pointeur' )
cgn      call gmprsx (nompro, ncfami//'.Groupe.Table' )
cgn      call gmprsx (nompro, ncfami//'.Numero' )
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFGRF3', nompro
#endif
      call sfgrf3 ( nbfseg,
     >              nbf, nbgrmx, nblign, lgtabl,
     >              imem(pointl), imem(pttgrl), smem(ptngrl),
     >              imem(adgrpo), smem(adgrtb), imem(adnufa),
     >              imem(ptrav1), imem(ptrav2), ncafdg,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,ncafdg )
      call gmprsx (nompro,ncafdg//'.Pointeur' )
      call gmprsx (nompro,ncafdg//'.Table' )
      call gmprsx (nompro,ncafdg//'.Taille' )
#endif
c
      endif
c
c====
c 5. menage
c====
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre1 )
      call gmlboj ( ntrav2 , codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
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
