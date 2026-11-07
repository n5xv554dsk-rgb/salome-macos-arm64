      subroutine utulfd ( action, nbiter, nuroul, codret )
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
c  Retourne le numero d'unite logique associee au fichier des donnees
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . action . e   . char*8 . action courante                            .
c . nbiter . e   .    1   . numero d'iteration courante                .
c . nuroul .  s  .    1   . unite logique de la liste standard         .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : pas de mot-cle dans la base            .
c .        .     .        . 3 : fichier de la liste standard non ouvert.
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
#include "consts.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer nbiter
      integer nuroul, codret
c
      character*8 action
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer ulsort
      integer lnomfl
c
      character*16 motcle
      character*200 nomflo
c
#include "langue.h"
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      call utulls ( ulsort, codret )
c
c====
c 1. Elaboration du nom de fichier associe au fichier des donnees
c====
c
      motcle = blan16
c
      if ( action(1:7).eq.'info_av' ) then
        if ( nbiter.eq.0 ) then
          motcle(1:4) = 'info'
        else
          motcle(1:10) = 'info_avant'
        endif
c
      elseif ( action(1:7).eq.'info_ap' ) then
        motcle(1:10) = 'info_apres'
c
      endif
cgn      write (*,*) 'motcle = ', motcle(1:10)
c
c====
c 2. recherche de l'unite logique associee
c====
c
      if ( codret.eq.0 ) then
c
      iaux = 2
      jaux = -1
c
      call utulbi ( nuroul, nomflo, lnomfl,
     >                iaux, motcle, nbiter, jaux,
     >              ulsort, langue, codret )
cgn      write (*,*) nuroul,codret
c
      endif
c
      end
