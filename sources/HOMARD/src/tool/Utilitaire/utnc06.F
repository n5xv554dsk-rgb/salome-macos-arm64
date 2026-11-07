      subroutine utnc06 ( option,
     >                    nounoe, tabaux, tbdaux,
     >                    coonoe, hetnoe, arenoe,
     >                    coexno, nnosho, nnosca,
     >                    ngenno,
     >                    noempo,
     >                    somare,
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
c    UTilitaire - Non Conformite - phase 06
c    --           -   -                  --
c    Prise en compte des renumerotations des noeuds
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . 0 : on renumerote tout                     .
c .        .     .        . 1 : on ne renumerote pas ngenno            .
c . nounoe . e   . nbarto . nouveau numero des noeuds                  .
c . tabaux . a   .   *    . tableau auxiliaire entier                  .
c . tbdaux . a   .   *    . tableau auxiliaire reel                    .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hetnoe . es  . nbnoto . historique de l'etat des noeuds            .
c . arenoe . es  . nbnoto . 0 pour un sommet, le numero de l'arete pour.
c .        .     .        . un noeud milieu                            .
c . coexno . es  . nbnoto*. codes de conditions aux limites portants   .
c .        .     . nctfno . sur les noeuds                             .
c . nnosho . es  . rsnoac . numero des noeuds dans HOMARD              .
c . nnosca . es  . rsnoto . numero des noeuds dans le calcul           .
c . ngenno . es  . nbnoto . nombre de generations au-dessus des noeuds .
c . noempo . es  . nbmpto . numeros des noeuds associes aux mailles    .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'UTNC06' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "impr02.h"
#include "envex1.h"
c
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "envca1.h"
#include "dicfen.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nounoe(0:nbnoto)
      integer tabaux(*)
      integer hetnoe(nbnoto), arenoe(nbnoto)
      integer ngenno(nbnoto)
      integer noempo(nbmpto)
      integer somare(2,nbarto)
      integer coexno(nbnoto,nctfno)
      integer nnosho(rsnoac), nnosca(rsnoto)
c
      double precision tbdaux(nbnoto,sdim)
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      logical afaire
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Renumerotation complete des tableaux lies aux '',a)'
      texte(1,5) =
     > '(''Renumerotation des tableaux lies aux '',a,''sauf ngenno'')'
      texte(1,6) = '(''Examen du '',a,i10)'
c
      texte(2,4) = '(''Total renumbering of arrays connected to '',a)'
      texte(2,5) =
     > '(''Renumbering of arrays connected to '',a,''except ngenno'')'
      texte(2,6) = '(''Examination of '',a,i10)'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      if ( option.eq.0 ) then
        write (ulsort,texte(langue,4)) mess14(langue,3,-1)
      else
        write (ulsort,texte(langue,5)) mess14(langue,3,-1)
      endif
#endif
c
c====
c 2. A-t-on vraiment besoin ?
c====
c
      afaire = .false.
      do 21 , iaux = 1 , nbnoto
c
        if ( nounoe(iaux).ne.iaux ) then
cgn      print *,iaux, nounoe(iaux)
          afaire = .true.
          goto 29
        endif
c
   21 continue
c
   29 continue
cgn      print *, 'afaire = ',afaire
c
      if ( afaire ) then
c
c====
c 3. Renumerotation des caracteristiques liees aux noeuds
c====
c 3.1. ==> Coordonnees
c
      if ( codret.eq.0 ) then
c
      do 311 , iaux = 1 , nbnoto
        do 3111 , jaux = 1 , sdim
          tbdaux(iaux,jaux) = coonoe(iaux,jaux)
 3111   continue
  311 continue
c
      do 312 , iaux = 1 , nbnoto
c
cgn      write (ulsort,*) iaux,' ==> ',nounoe(iaux)
        if ( nounoe(iaux).ne.iaux ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,-1), iaux
#endif
          do 3121 , jaux = 1 , sdim
            coonoe(nounoe(iaux),jaux) = tbdaux(iaux,jaux)
 3121     continue
        endif
c
  312 continue
c
      endif
c
c 3.2. ==> Historiques de l'etat
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - hetnoe', nompro
#endif
      call utchnu ( iaux, nbnoto, nounoe,
     >              jaux, nbnoto, hetnoe,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.3. ==> Code externe sur les conditions aux limites
c
      if ( codret.eq.0 ) then
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - coexno', nompro
#endif
      call utchnu ( iaux, nbnoto, nounoe,
     >              nbnoto, nctfno, coexno,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.4. ==> Arete sur le noeud
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - arenoe', nompro
#endif
      call utchnu ( iaux, nbnoto, nounoe,
     >              jaux, nbnoto, arenoe,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.5. ==> Renumerotation avec le code de calcul
c
      if ( codret.eq.0 ) then
c
      iaux = 2
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - nnosho', nompro
#endif
      call utchnu ( iaux, nbnoto, nounoe,
     >              jaux, rsnoac, nnosho,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - nnosca', nompro
#endif
      call utchnu ( iaux, nbnoto, nounoe,
     >              jaux, rsnoto, nnosca,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.6. ==> Nombre de generations de l'ascendance
c
      if ( codret.eq.0 ) then
c
      if ( option.ne.1 ) then
c
      iaux = 1
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - ngenno', nompro
#endif
      call utchnu ( iaux, nbnoto, nounoe,
     >              jaux, nbnoto, ngenno,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 4. Renumerotation des sommets definissant les aretes
c    Il faut corriger eventuellement l'orientation des aretes
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - somare', nompro
#endif
      iaux = 2
      jaux = 2
      call utchnu ( iaux, nbnoto, nounoe,
     >              jaux, nbarto, somare,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 41 , iaux = 1 , nbarto
        if ( somare(1,iaux).gt.somare(2,iaux) ) then
          jaux = somare(1,iaux)
          somare(1,iaux) = somare(2,iaux)
          somare(2,iaux) = jaux
        endif
   41 continue
c
      endif
c
c====
c 5. Eventuellement, renumerotation des sommets definissant
c    les mailles-points
c====
c
      if ( nbmpto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - noempo', nompro
#endif
        iaux = 2
        jaux = 1
        call utchnu ( iaux, nbnoto, nounoe,
     >                jaux, nbmpto, noempo,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
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
