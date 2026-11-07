      subroutine utnc04 ( nbanci, arreca, arrecb,
     >                    nouare, tabaux,
     >                    arenoe,
     >                    somare, hetare, np2are,
     >                    merare, filare, insoar,
     >                    coexar, narsho, narsca,
     >                    ngenar,
     >                    aretri, arequa,
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
c    UTilitaire - Non Conformite - phase 04
c    --           -   -                  --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbanci . e   .    1   . nombre d'aretes de non conformite initiale .
c .        .     .        . egal au nombre d'aretes recouvrant 2 autres.
c . arreca . es  .2*nbanci. liste des aretes recouvrant une autre      .
c . arrecb . es  .2*nbanci. liste des aretes recouvertes par une autre .
c . nouare . e   . nbarto . nouveau numero des aretes                  .
c . tabaux . a   .   *    . tableau auxiliaire                         .
c . arenoe . es  . nbnoto . 0 pour un sommet, le numero de l'arete pour.
c .        .     .        . un noeud milieu                            .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . hetare . es  . nbarto . historique de l'etat des aretes            .
c . np2are . es  . nbarto . noeud milieux des aretes                   .
c . merare . es  . nbarto . mere des aretes                            .
c . filare . es  . nbarto . premiere fille des aretes                  .
c . insoar . es  . nbarto . information sur les sommets des aretes     .
c . coexar . es  . nbarto*. codes de conditions aux limites portants   .
c .        .     . nctfar . sur les aretes                             .
c . narsho . es  . rsarac . numero des aretes dans HOMARD              .
c . narsca . es  . rsarto . numero des aretes du calcul                .
c . ngenar . es  . nbarto . nombre de generations au-dessus des aretes .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
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
      parameter ( nompro = 'UTNC04' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "envca1.h"
#include "dicfen.h"
#include "nbutil.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      integer nbanci
      integer arreca(2*nbanci), arrecb(2*nbanci)
      integer nouare(0:nbarto)
      integer tabaux(*)
      integer arenoe(nbnoto)
      integer somare(2,nbarto), hetare(nbarto), np2are(nbarto)
      integer filare(nbarto), merare(nbarto), insoar(nbarto)
      integer coexar(nbarto,nctfar)
      integer narsho(rsarac), narsca(rsarto)
      integer ngenar(nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer ifin
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
      codret = 0
c
c====
c 2. A-t-on vraiment besoin ?
c====
c
      afaire = .false.
      do 21 , iaux = 1 , nbarto
c
        if ( nouare(iaux).ne.iaux ) then
cgn      print *,iaux, nouare(iaux)
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
c 3. Prise en compte du changement de numerotation des aretes
c    dans les tableaux de reperage des non conformites
c====
c
      ifin = 2*nbanci
      do 31 , iaux = 1 , ifin
cgn      if ( iaux.eq.10 .or. iaux.eq.15 ) then
cgn          write (ulsort,*) 'arreca(',iaux,') = ',arreca(iaux)
cgn          write (ulsort,*) 'arrecb(',iaux,') = ',arrecb(iaux)
cgn      write (ulsort,*)'nouare(',arreca(iaux),') = ',nouare(arreca(iaux))
cgn      write (ulsort,*)'nouare(',arrecb(iaux),') = ',nouare(arrecb(iaux))
cgn      endif
c
        arreca(iaux) = nouare(arreca(iaux))
        arrecb(iaux) = nouare(arrecb(iaux))
c
   31 continue
c
c====
c 4. Renumerotation des aretes liees aux noeuds
c====
c
      do 41 , iaux = 1 , nbnoto
c
        arenoe(iaux) = nouare(arenoe(iaux))
c
   41 continue
c
c====
c 5. Renumerotation des caracteristiques liees aux aretes
c====
c 5.1. ==> Sommets
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - somare', nompro
#endif
      call utchnu ( iaux, nbarto, nouare,
     >              jaux, nbarto, somare,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
c 5.2. ==> Historiques de l'etat
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - hetare', nompro
#endif
      call utchnu ( iaux, nbarto, nouare,
     >              jaux, nbarto, hetare,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
c 5.3. ==> Eventuel noeud milieu
c
      if ( degre.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 1
        jaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCHNU - np2are', nompro
#endif
        call utchnu ( iaux, nbarto, nouare,
     >                jaux, nbarto, np2are,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 5.4. ==> Eventuelle information sur les sommets
c
      if ( nbelig.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 1
        jaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCHNU - insoar', nompro
#endif
        call utchnu ( iaux, nbarto, nouare,
     >                jaux, nbarto, insoar,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 5.5. ==> Code externe sur les conditions aux limites
c
      if ( codret.eq.0 ) then
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - coexar', nompro
#endif
      call utchnu ( iaux, nbarto, nouare,
     >              nbarto, nctfar, coexar,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
c 5.6. ==> Filiation
c
      if ( codret.eq.0 ) then
c
      do 561 , iaux = 1 , nbarto
        filare(iaux) = 0
        merare(iaux) = 0
  561 continue
c
      kaux = 2*nbanci
      do 562 , iaux = 1 , kaux
        jaux = arreca(iaux)
        if ( filare(jaux).eq.0 ) then
          filare(jaux) = arrecb(iaux)
          hetare(jaux) = 2
        else
          filare(jaux) = min(arrecb(iaux),filare(jaux))
        endif
        merare(arrecb(iaux)) = jaux
  562 continue
c
      endif
cgn        do jaux=1,nbarto
cgn        print *,filare(jaux),merare(jaux)
cgn        enddo
c
c 5.7. ==> Eventuelle renumerotation avec le code de calcul
c
      if ( rsarac.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 2
        jaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCHNU - narsho', nompro
#endif
        call utchnu ( iaux, nbarto, nouare,
     >                jaux, rsarac, narsho,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      if ( rsarto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 1
        jaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCHNU - narsca', nompro
#endif
        call utchnu ( iaux, nbarto, nouare,
     >                jaux, rsarto, narsca,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 5.8. ==> Nombre de generations de l'ascendance
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - ngenar', nompro
#endif
      call utchnu ( iaux, nbarto, nouare,
     >              jaux, nbarto, ngenar,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 6. Renumerotation des aretes definissant les triangles
c====
c
      if ( nbtrto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCHNU - aretri', nompro
#endif
        iaux = 2
        jaux = 3
        call utchnu ( iaux, nbarto, nouare,
     >                nbtrto, jaux, aretri,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
cgn        do jaux=1,nbtrto
cgn        print *,(aretri(jaux,iaux),iaux=1,3)
cgn        enddo
c
      endif
c
c====
c 7. Renumerotation des aretes definissant les quadrangles
c====
c
      if ( nbquto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCHNU - arequa', nompro
#endif
        iaux = 2
        jaux = 4
        call utchnu ( iaux, nbarto, nouare,
     >                nbquto, jaux, arequa,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
cgn        do jaux=1,nbquto
cgn        print *,(arequa(jaux,iaux),iaux=1,4)
cgn        enddo
c
      endif
c
      endif
c
c====
c 8. la fin
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
