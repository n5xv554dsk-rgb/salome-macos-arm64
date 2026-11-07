      subroutine utulls ( ulsort, codret )
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
c  Retourne le numero d'unite logique associee a la liste standard
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ulsort .  s  .    1   . unite logique de la liste standard         .
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
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer ulsort, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lnomfi, ulsost
c
      character*8 typfic
      character*200 nomfic
c
#include "motcle.h"
#include "langue.h"
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
cgn      write(*,*) 'debut de utulls'
c====
c 1.  recherche du nom de fichier unix associe a la liste standard
c====
c
      call gusost ( ulsost )
cgn      write(*,*) 'retour de gusost'
c
      typfic = mclist
      iaux = 0
#ifdef _DEBUG_HOMARD_
      jaux = 1
#else
      jaux = 0
#endif
      call utfino ( typfic, iaux, nomfic, lnomfi,
     >              jaux,
     >              ulsost, langue, codret )
cgn      write(*,*) 'retour de utfino'
c
c====
c 2. recherche de l'unite logique associee
c====
c
      if ( codret.eq.0 ) then
c
         call gucara ( nomfic, lnomfi, ulsort, codret )
         if ( codret.eq.0 ) then
           if ( ulsort.eq.0 ) then
             codret = 3
           endif
         endif
c
      elseif ( codret.eq.2 ) then
c
         ulsort = ulsost
         codret = 0
c
      else
c
         codret = 2
c
      endif
cgn      write(*,*) 'fin de utulls'
c
      end
