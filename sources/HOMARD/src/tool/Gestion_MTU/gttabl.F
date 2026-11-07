      subroutine gttabl ( code, nbsep1, nbrapp, ouvert, titsec, tpscpu )
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
c    'Gestion du Temps : memorisation des TABLes'
c     -          -                        ----
c ______________________________________________________________________
c
c but : archiver ou redonner les listes caracteristiques de la
c       gestion des mesures de temps
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . code   . e   .    1   . 0 : on archive les tableaux de l'appelant  .
c .        .     .        . 1 : on renvoie les tableaux vers l'appelant.
c . nbsep1 . e   .    1   . nombre de sections possibles               .
c . nbrapp . e/s .   -4:  . -4 : pilotage des impressions              .
c .        .     . nbsep1 . -3 : numero de code de la langue des messa..
c .        .     .        . -2 : numero de l'annee de depart           .
c .        .     .        . -1 : nombre de secondes au depart depuis le.
c .        .     .        . depuis le debut de l'annee                 .
c .        .     .        . 0 : numero de l'unite logique ou imprimer  .
c .        .     .        . les messages du gestionnaire de temps      .
c .        .     .        . i>0 : nombre de fois ou la i-eme section a .
c .        .     .        . ete mesuree                                .
c . ouvert . e/s . nbsep1 . vrai ou faux, selon que la i-eme section   .
c .        .     .        . est en cours de mesure ou non              .
c . titsec . e/s . nbsep1 . titre de la i-eme section                  .
c . tpscpu . e/s .0:nbsep1. 0 : cumul du temps systeme                 .
c .        .     .        . i>0 : cumul du temps user de la i-eme      .
c .        .     .        . section                                    .
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
      parameter ( nompro = 'GTTABL' )
c
#include "genbla.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer code, nbsep1
c
#include "gtdita.h"
c
c 0.4. ==> variables locales
c
      integer enstul
      integer iaux
c
      integer nbsec0
      parameter ( nbsec0 = 301 )
c
      integer ulsort, langue
      integer nbrap0(-4:nbsec0)
c
      double precision tpscp0(0:nbsec0)
c
      logical ouver0(nbsec0)
      logical initia
c
      character*24 titse0(nblang,nbsec0)
c
      integer nbmess
      parameter ( nbmess = 10 )
c
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data initia / .false. /
      data langue / 1 /
c
c ... juste pour ne plus avoir de messages ftnchek :
c
      data nbrap0(0) / 6 /
c ______________________________________________________________________
c
c====
c 1. initialisation des messages
c====
c
#include "impr01.h"
c
c====
c 2. verifications
c====
c
c 2.1. ==> unite pour la sortie standard
c
      if ( initia ) then
c
        ulsort = nbrap0(0)
c
      else
c
        call dmunit ( enstul, ulsort )
c
c 2.2. ==> l'initialisation n'est pas faite
c
        if ( code.ne.0 ) then
      write (ulsort,texte(langue,1)) 'Entree', nompro
          write (ulsort,22000)
          call dmflsh (iaux)
          call dmabor
        else
          initia = .true.
        endif
c
      endif
c
c 2.3. ==> la place reservee ici est trop petite
c
      if ( nbsep1.gt.nbsec0 ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,23000) nbsec0, nbsep1
        call dmabor
      endif
c
22000 format(
     > 'L''initialisation du gestionnaire des mesures de temps',
     >/'de calcul n''a pas ete faite.',
     >/'Il faut faire appel a GTINIT.',//)
c
23000 format(
     > 'Les tableaux d''archivage sont dimensionnes a nbsec0 = ',i4,
     >/'Or il doit archiver des tableaux dimensionnes a nbsep1 = ',i9,
     >/'C''est trop juste. Il faut augmenter nbsec0 dans GTTABL.',//)
c
c====
c 2. on archive les informations transmises par l'appelant
c====
c
      if ( code.eq.0 ) then
c
        call ugtaci (nbrap0, nbrapp, -4, nbsep1)
        call ugtacr (tpscp0, tpscpu, 0, nbsep1)
        call ugtacl (ouver0, ouvert, 1, nbsep1)
        iaux = nblang*nbsep1
        call ugtacs (titse0, titsec, 1, iaux )
c
c===
c 3. on renvoie a l'appelant
c====
c
      else if ( code.eq.1 ) then
c
        call ugtaci (nbrapp, nbrap0, -4, nbsep1)
        call ugtacr (tpscpu, tpscp0, 0, nbsep1)
        call ugtacl (ouvert, ouver0, 1, nbsep1)
        iaux = nblang*nbsep1
        call ugtacs (titsec, titse0, 1, iaux )
c
c===
c 4. probleme
c====
c
      else
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,40000) code
        call dmabor
c
      endif
c
40000 format(
     > 'Le choix ',i4,' pour le premier argument ne correspond ',
     > 'a aucune option possible.',
     >/'Il faut 0 pour archiver ou 1 pour recuperer.',/)
c
      end
