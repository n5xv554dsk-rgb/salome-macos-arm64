      subroutine pcsipe ( nbfop2, profho, vap2ho,
     >                    hetpen, facpen, cofape, filpen, fppyte,
     >                    somare, np2are,
     >                    aretri, arequa,
     >                    tritet, cotrte,
     >                    facpyr, cofapy,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c    interpolation iso/p2 sur les noeuds - decoupage des PEntaedres
c                  -                                     --
c remarque : on devrait optimiser cela car si le pentaedre etait dans
c            un etat de decoupage similaire, on recalcule une valeur
c            qui est deja presente
c remarque : pcsipe et pcsipe sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop2 . e   .    1   . nombre de fonctions P2                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vap2ho . es  . nbfop2*. variables p1 numerotation homard           .
c .        .     . nbnoto .                                            .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. codes des faces des pentaedres             .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'PCSIPE' )
c
#include "nblang.h"
#include "fracte.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(*)
      integer hetpen(nbpeto), facpen(nbpecf,5), cofape(nbpecf,5)
      integer filpen(nbpeto), fppyte(2,nbpeco)
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5)
c
      double precision vap2ho(nbfop2,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lepent
      integer typdec, etanp1
      integer sm, nuv
      integer listar(9), listno(15)
      integer nbarco
      integer nuaret(15)
c
      logical afaire
c
      double precision daux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
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
#include "impr03.h"
c
      codret = 0
c
      do 100 , jaux = 1, nbpeto
c
        lepent = jaux
c
c====
c 2. recherche des types d'interpolations a faire
c====
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,3)) 'PCS0PE', nompro
#endif
        call pcs0pe ( lepent, profho,
     >                hetpen, facpen, cofape, filpen, fppyte,
     >                somare, np2are,
     >                aretri, arequa,
     >                tritet, cotrte,
     >                facpyr, cofapy,
     >                afaire, listar, listno, typdec, etanp1, sm )
cgn      write(ulsort,90002) 'typdec',typdec
c
        endif
c
        if ( afaire ) then
c
c====
c 3. L'eventuel noeud central
c       decoupage selon 2 aretes tria/tria
c       decoupage selon 1 face traingulaire
c====
c
        if ( codret.eq.0 ) then
c
        if ( mod(typdec,2).eq.0 ) then
c
          profho(sm) = 1
c
c         formule iso-p2 :
c         interpolation = moyenne des valeurs sur les noeuds au milieu
c                         des aretes du pentaedre
c
          do 31 , nuv = 1, nbfop2
c
            daux = 0.d0
            do 311 , iaux = 9 , 15
              daux = daux + vap2ho(nuv,listno(iaux))
  311       continue
            vap2ho(nuv,sm) = unssix * daux
cgn        write(ulsort,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
c
   31     continue
c
        endif
c
        endif
c
c====
c 4. Recuperation des aretes internes
c====
c
        if ( codret.eq.0 ) then
c
        iaux = 1
c
c 4.1. ==> Du centre aux milieux d'aretes
c            (selon 2 aretes tri ou 1 face tri)
c
        if ( mod(typdec,5).eq.0 ) then
          iaux = iaux*3
        endif
c
c 4.2. ==> Du centre aux sommets
c           (selon 2 aretes tri ou 1 face tri)
c
        if ( mod(typdec,7).eq.0 ) then
          iaux = iaux*2
        endif
c
c 4.3. ==> Entre les milieux de faces
c            D'un milieu d'arete a un autre
c            D'un milieu d'arete a un sommet
c            D'un milieu de face a un sommet
c
        if ( mod(typdec,3).eq.0 .or.
     >       mod(typdec,11).eq.0 .or.
     >       mod(typdec,13).eq.0 .or.
     >       mod(typdec,17).eq.0 ) then
          iaux = iaux*5
        endif
c
c 4.4. ==> Les aretes
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,3)) 'UTAIPE', nompro
#endif
        call utaipe ( lepent, iaux,
     >                hetpen, facpen, filpen, fppyte,
     >                aretri,
     >                tritet, cotrte,
     >                nbarco, nuaret,
     >                ulsort, langue, codret )
c
        endif
c
c====
c 5. Les valeurs
c====
c
        if ( codret.eq.0 ) then
cgn      write(ulsort,90002) 'Aretes', (nuaret(iaux),iaux=1,nbarco)
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,3)) 'PCSI00', nompro
#endif
        call pcsi00 ( nbfop2, profho, vap2ho,
     >                somare, np2are,
     >                nbarco, nuaret )
c
        endif
c
        endif
c
  100 continue
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
