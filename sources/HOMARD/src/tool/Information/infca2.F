      subroutine infca2 ( numfic,
     >                    nbcham, nocham,
     >                    nrocha, nrocmp, nrotab,
     >                    coonoe,
     >                    nnoeca, ntreca, nqueca,
     >                    nnoeho, ntreho, nqueho,
     >                    lgnoin, lgtrin, lgquin,
     >                    nnoein, ntrein, nquein,
     >                    decanu,
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
c   INformation : Fichiers Champs ASCII - 2eme partie
c   --            -        -      -       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numfic . es  .   1    . numero du fichier a ecrire                 .
c . nbcham . e   .   1    . nombre de champs definis                   .
c . nocham . e   . nbcham . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . nrocha . e   .   1    . nunero du champ retenu pour le coloriage   .
c .        .     .        . -1 si coloriage selon la qualite           .
c . nrocmp . e   .   1    . numero de la composante retenue            .
c . nrotab . e   .   1    . numero du tableau associe au pas de temps  .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . nnoeca . e   . renoto . noeuds en entree dans le calcul            .
c . ntreca . e   . retrto . nro des triangles dans le calcul en entree .
c . nqueca . e   . requto . nro des quads dans le calcul en entree     .
c . nnoeho . e   .    *   . nro des noeuds dans HOMARD en entree       .
c . ntreho . e   .    *   . nro des triangles dans HOMARD en entree    .
c . nqueho . e   .    *   . nro des quads dans HOMARD en entree        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . decanu . e   .  -1:7  . decalage des numerotations selon le type   .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans les memoires             .
c .        .     .        . 3 : probleme dans les fichiers             .
c .        .     .        . 5 : probleme autre                         .
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
      parameter ( nompro = 'INFCA2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "nombno.h"
#include "envca1.h"
#include "envada.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer numfic
      integer nbcham
      integer nrocha, nrocmp, nrotab
      integer nnoeca(renoto), ntreca(retrto), nqueca(requto)
      integer nnoeho(*), ntreho(*), nqueho(*)
      integer lgnoin, lgtrin, lgquin
      integer nnoein(*), ntrein(*), nquein(*)
      integer decanu(-1:7)
c
      character*8 nocham(nbcham)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nuroul, lnomfl
      integer nbquvi, nbtrvi
      integer adquvi, adtrvi
      integer adquva, adtrva
      integer nbenti
c
      character*8 saux08
      character*8 notrva
      character*20 titre0
      character*200 nomflo
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
      texte(1,9) = '(''Caracterisation de la fonction'')'
c
      texte(2,9) = '(''Characteristics of function'')'
c
c====
c 2. les valeurs
c====
c
c 2.1. ==> determination de la fonction
c
      if ( codret.eq.0 ) then
c
c     tableau notrva
      call gmalot ( notrva, 'reel    ', nbnoto, adtrva, codret )
c
      endif
c
      adquva = 1
      adquvi = 1
      adtrvi = 1
c
c 2.2. ==> recherche des valeurs du champ
c          Remarque : on met une valeur bidon a nbtrvi et nbquvi pour
c                     ne pas avoir de message avec ftnchek
c
      if ( nrotab.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        nbtrvi = 1
        nbquvi = 1
        iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFFRE', nompro
#endif
        call inffre ( iaux, rmem(adtrva), rmem(adquva), titre0,
     >                nocham(nrocha), nrocmp, nrotab,
     >                nbtrvi, nbquvi,
     >                imem(adtrvi), imem(adquvi),
     >                nnoeca, ntreca, nqueca,
     >                nnoeho, ntreho, nqueho,
     >                lgnoin, lgtrin, lgquin,
     >                nnoein, ntrein, nquein,
     >                decanu,
     >                ulsort, langue, codret )
c
        endif
c
      else
c
        codret = 12
c
      endif
c
c====
c 3. ecriture des valeurs
c====
c
      if ( codret.eq.0 ) then
c
c 3.1 ==> ouverture du fichier
c
      if ( codret.eq.0 ) then
c
      numfic = numfic + 1
c
      saux08 = '        '
      iaux = -5
      call utulbi ( nuroul, nomflo, lnomfl,
     >                iaux, saux08, nbiter, numfic,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2. ==> ecriture
c
      if ( codret.eq.0 ) then
c
      nbenti = renoto
c
      if ( sdim.eq.1 ) then
c
        do 321 , iaux = 1 , nbenti
c
          write (nuroul,32000) coonoe(nnoeca(iaux),1),
     >                         rmem(adtrva+iaux-1)
c
  321   continue
c
      elseif ( sdim.eq.2 ) then
c
        do 322 , iaux = 1 , nbenti
c
          write (nuroul,32000) coonoe(nnoeca(iaux),1),
     >                         coonoe(nnoeca(iaux),2),
     >                         rmem(adtrva+iaux-1)
c
  322   continue
c
      elseif ( sdim.eq.3 ) then
c
        do 333 , iaux = 1 , nbenti
c
          write (nuroul,32000) coonoe(nnoeca(iaux),1),
     >                         coonoe(nnoeca(iaux),2),
     >                         coonoe(nnoeca(iaux),3),
     >                         rmem(adtrva+iaux-1)
c
  333   continue
c
      else
c
        codret = 15
c
      endif
c
32000 format(10g17.9)
c
      endif
c
c 3.3. ==> fermeture du fichier
c
      if ( codret.eq.0 ) then
c
      call gufeul ( nuroul , codret)
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
cgn      call gmprsx (nompro, notrvi )
#endif
c
c====
c 4. menage
c====
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( notrva, codret )
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
