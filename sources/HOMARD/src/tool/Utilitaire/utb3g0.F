      subroutine utb3g0 ( hetnoe, coonoe,
     >                    numcoi, coinpt, coinnn,
     >                    somare,
     >                    arequa,
     >                    hetpen, facpen, cofape, arepen, np2are,
     >                    nbpbco, mess08, mess54,
     >                    ulbila, ulsort, langue, codret )
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
c    UTilitaire - Bilan - option 3 - phase G0
c    --           -              -         --
c ______________________________________________________________________
c
c but : controle l'interpenetration des pentaedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetnoe . e   . nbnoto . historique de l'etat des noeuds            .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . numcoi . e   . nbnoto . numero de la coincidence du noeud          .
c . coinpt . e   .   *    . pointeur de la i-eme coincidence dans coinn.
c . coinnn . e   .   *    . liste des noeuds coincidents               .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . nbpbco . es  .  -1:7  . nombre de problemes de coincidences        .
c . mess54 . e   .nblang,*. messages                                   .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB3G0' )
c
      integer typenh
      parameter ( typenh = 7 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombpe.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer hetnoe(nbnoto)
      integer numcoi(nbnoto), coinpt(*), coinnn(*)
      integer somare(2,nbarto)
      integer arequa(nbquto,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto)
      integer np2are(nbarto)
      integer nbpbco(-1:7)
c
      character*08 mess08(nblang,*)
      character*54 mess54(nblang,*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lepent, lenoeu
      integer nucoin, ptcoin, ptcode, ptcofi
      integer sommet(15), nbsomm
      integer listar(9)
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      double precision v0(5,3)
      double precision v1(3), v2(3), v3(3), v4(3), v5(3), v6(3)
      double precision v12(3), v13(3), v14(3)
      double precision v52(3), v54(3), v56(3)
      double precision vn(3)
      double precision xmax, xmin, ymax, ymin, zmax, zmin
      double precision prmito, prmilo
      double precision daux1
c
      logical logaux(7)
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
#include "utb300.h"
c
#include "utb301.h"
c
c 1.2. ==> constantes
c
      codret = 0
c
      if ( degre.eq.1 ) then
        nbsomm = 6
      else
        nbsomm = 15
      endif
c
c====
c 2. controle de la non-interpenetration des pentaedres
c    remarque : on ne s'interesse qu'aux actifs car les autres sont
c    censes avoir ete controles aux iterations anterieures
c====
cgn      call gtdems (92)
c
      do 20 , lepent = 1 , nbpeto
c
#ifdef _DEBUG_HOMARD_
        if ( lepent.lt.0 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
        if ( mod(hetpen(lepent),100).eq.0 ) then
cgn      call gtdems (93)
c
          if ( nbpbco(typenh).eq.-1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
            nbpbco(typenh) = 0
          endif
c
#include "utb3g1.h"
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
          write (ulsort,14203) sommet(1), v1(1), v1(2), v1(3)
          write (ulsort,14203) sommet(2), v2(1), v2(2), v2(3)
          write (ulsort,14203) sommet(3), v3(1), v3(2), v3(3)
          write (ulsort,14203) sommet(4), v4(1), v4(2), v4(3)
          write (ulsort,14203) sommet(5), v5(1), v5(2), v5(3)
          write (ulsort,14203) sommet(6), v6(1), v6(2), v6(3)
          write (ulsort,*) xmin, xmax
          write (ulsort,*) ymin, ymax
          write (ulsort,*) zmin, zmax
        endif
#endif
c
          do 23 , lenoeu = numip1, numap1
c
#include "utb304.h"
c
#include "utb305.h"
c
#include "utb306.h"
c
#include "utb3g2.h"
c
c 2.3.9. ==> si logaux(7) est encore vrai, c'est que le noeud est
c            a l'interieur du pentaedre ... malaise ...
c
            if ( logaux(7) ) then
c
              iaux = lepent
c
#include "utb302.h"
c
              write (ulbila,14203) sommet(1), v1(1), v1(2), v1(3)
              write (ulbila,14203) sommet(2), v2(1), v2(2), v2(3)
              write (ulbila,14203) sommet(3), v3(1), v3(2), v3(3)
              write (ulbila,14203) sommet(4), v4(1), v4(2), v4(3)
              write (ulbila,14203) sommet(5), v5(1), v5(2), v5(3)
              write (ulbila,14203) sommet(6), v6(1), v6(2), v6(3)
c
              write (ulbila,10200)
c
            endif
c
   23     continue
c
        endif
c
   20 continue
cgn      call gtfims (92)
c
      end
