      subroutine utnc14 ( nbnocq, qureca, qurecb,
     >                    nouqua, tabaux,
     >                    arequa, hetqua,
     >                    filqua, perqua,
     >                    coexqu, nqusho, nqusca,
     >                    quahex,
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
c    UTilitaire - Non Conformite - phase 14
c    --           -   -                  --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbnocq . e   .    1   . nombre de non conformites de quadrangles   .
c . qureca . e   .4*nbnocq. liste des quad. recouvrant un autre        .
c . qurecb . e   .4*nbnocq. liste des quad. recouverts par un autre    .
c . nouqua . e   . nbquto . nouveau numero des quadrangles             .
c . tabaux . a   .   *    . tableau auxiliaire                         .
c . arequa . es  .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . es  . nbquto . historique de l'etat des quadrangles       .
c . filqua . es  . nbquto . premier fils des quadrangles               .
c . perqua . es  . nbquto . pere des quadrangles                       .
c . coexqu . es  . nbquto*. codes de conditions aux limites portants   .
c .        .     . nctfqu . sur les quadrangles                        .
c . nqusho . es  . rsquac . numero des quadrangles dans HOMARD         .
c . nqusca . es  . rsquto . numero des quadrangles du calcul           .
c . quahex . es  .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
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
      parameter ( nompro = 'UTNC14' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombqu.h"
#include "nombhe.h"
#include "dicfen.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      integer nbnocq
      integer qureca(4*nbnocq), qurecb(4*nbnocq)
      integer nouqua(0:nbquto)
      integer tabaux(*)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer filqua(nbquto), perqua(nbquto)
      integer coexqu(nbquto,nctfqu)
      integer nqusho(rsquac), nqusca(rsquto)
      integer quahex(nbhecf,6)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer ifin
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
c 2. Prise en compte du changement de numerotation des aretes
c    dans les tableaux de reperage des non conformites
c====
c
      ifin = 4*nbnocq
      do 21 , iaux = 1 , ifin
c
        qureca(iaux) = nouqua(qureca(iaux))
        qurecb(iaux) = nouqua(qurecb(iaux))
c
   21 continue
c
c====
c 3. Renumerotation des caracteristiques liees aux quadrangles
c====
c 3.1. ==> Aretes
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHNU - arequa', nompro
#endif
      call utchnu ( iaux, nbquto, nouqua,
     >              nbquto, jaux, arequa,
     >              tabaux,
     >              ulsort, langue, codret )
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
      write (ulsort,texte(langue,3)) 'UTCHNU - hetqua', nompro
#endif
      call utchnu ( iaux, nbquto, nouqua,
     >              jaux, nbquto, hetqua,
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
      write (ulsort,texte(langue,3)) 'UTCHNU - coexqu', nompro
#endif
      call utchnu ( iaux, nbquto, nouqua,
     >              nbquto, nctfqu, coexqu,
     >              tabaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.4. ==> Filiation
c
      if ( codret.eq.0 ) then
c
      do 341 , iaux = 1 , nbquto
        filqua(iaux) = 0
        perqua(iaux) = 0
  341 continue
c
      kaux = 4*nbnocq
      do 342 , iaux = 1 , kaux
        jaux = qureca(iaux)
        if ( filqua(jaux).eq.0 ) then
          filqua(jaux) = qurecb(iaux)
          hetqua(jaux) = 4
        else
          filqua(jaux) = min(qurecb(iaux),filqua(jaux))
        endif
        perqua(qurecb(iaux)) = jaux
  342 continue
c
      endif
cgn        do jaux=1,nbquto
cgn        print *,filqua(jaux),perqua(jaux)
cgn        enddo
c
c 3.7. ==> Eventuelle renumerotation avec le code de calcul
c
      if ( rsquac.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 2
        jaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCHNU - nqusho', nompro
#endif
        call utchnu ( iaux, nbquto, nouqua,
     >                jaux, rsquac, nqusho,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      if ( rsquto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 1
        jaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCHNU - nqusca', nompro
#endif
        call utchnu ( iaux, nbquto, nouqua,
     >                jaux, rsquto, nqusca,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 4. Renumerotation des quadrangles definissant les hexaedres
c====
c
      if ( nbheto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCHNU - quahex', nompro
#endif
cgn        iaux=437
cgn        write(ulsort,1000) iaux, (quahex(iaux,jaux),jaux=1,6)
cgn 1000 format(i10,' :',6i10)
        iaux = 2
        jaux = 6
        call utchnu ( iaux, nbquto, nouqua,
     >                nbheto, jaux, quahex,
     >                tabaux,
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
