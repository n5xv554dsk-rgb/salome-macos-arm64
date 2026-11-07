      subroutine utb3e0 ( hetnoe, coonoe,
     >                    numcoi, coinpt, coinnn,
     >                    somare,
     >                    arequa,
     >                    hethex, quahex, coquhe, arehex, np2are,
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
c    UTilitaire - Bilan - option 3 - phase E0
c    --           -              -         --
c ______________________________________________________________________
c
c but : controle l'interpenetration des hexaedres
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
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
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
      parameter ( nompro = 'UTB3E0' )
c
      integer typenh
      parameter ( typenh = 6 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombhe.h"
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
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto)
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
      integer lehexa, lenoeu
      integer nucoin, ptcoin, ptcode, ptcofi
      integer sommet(20), nbsomm
      integer listar(12)
c
      double precision v0(6,3)
      double precision v1(3), v2(3), v3(3), v4(3)
      double precision v5(3), v6(3), v7(3), v8(3)
      double precision v12(3), v14(3), v16(3)
      double precision v83(3), v85(3), v87(3)
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
c
#ifdef _DEBUG_HOMARD_
      integer glop
      data glop / 0 /
#endif
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
#include "utb300.h"
c
#include "utb301.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpbco', nbpbco
#endif
c
c 1.2. ==> constantes
c
      codret = 0
c
      if ( degre.eq.1 ) then
        nbsomm = 8
      else
        nbsomm = 20
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbheto', nbheto
      write (ulsort,90002) 'nbhecf', nbhecf
      write (ulsort,90002) 'degre ', degre
#endif
c
c====
c 2. controle de la non-interpenetration des hexaedres
c    remarque : on ne s'interesse qu'aux actifs car les autres sont
c    censes avoir ete controles aux iterations anterieures
c====
cgn      call gtdems (92)
c
      do 20 , lehexa = 1 , nbheto
c
#ifdef _DEBUG_HOMARD_
        if ( lehexa.lt.0 ) then
          glop = 1
      write (ulsort,*) ' '
      write (ulsort,90002) mess14(langue,1,typenh), lehexa
      write (ulsort,90112) 'etat', lehexa,hethex(lehexa)
cgn      write (ulsort,90112) 'nbpbco', typenh,nbpbco(typenh)
        else
          glop = 0
        endif
#endif
c
        if ( mod(hethex(lehexa),1000).eq.0 ) then
cgn      call gtdems (93)
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,90112) nompro//' quahex', lehexa,
     >                     (quahex(lehexa,iaux),iaux=1,6)
      write (ulsort,90112) nompro//' coquhe', lehexa,
     >                     (coquhe(lehexa,iaux),iaux=1,6)
        endif
#endif
c
          if ( nbpbco(typenh).eq.-1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
            nbpbco(typenh) = 0
          endif
c
#include "utb3e1.h"
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
          write (ulsort,14203) sommet(1), v1(1), v1(2), v1(3)
          write (ulsort,14203) sommet(2), v2(1), v2(2), v2(3)
          write (ulsort,14203) sommet(3), v3(1), v3(2), v3(3)
          write (ulsort,14203) sommet(4), v4(1), v4(2), v4(3)
          write (ulsort,14203) sommet(5), v5(1), v5(2), v5(3)
          write (ulsort,14203) sommet(6), v6(1), v6(2), v6(3)
          write (ulsort,14203) sommet(7), v7(1), v7(2), v7(3)
          write (ulsort,14203) sommet(8), v8(1), v8(2), v8(3)
          write (ulsort,90004) 'X min/max', xmin, xmax
          write (ulsort,90004) 'Y min/max', ymin, ymax
          write (ulsort,90004) 'Z min/max', zmin, zmax
          write (ulsort,90002) 'numip1, numap1',numip1, numap1
        endif
#endif
c
          do 23 , lenoeu = numip1, numap1
c
#include "utb304.h"
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 .and. lenoeu.lt.0 ) then
          write (ulsort,*) 'apres utb304', logaux(7)
          write (ulsort,90004) 'vn', vn
        endif
#endif
c
#include "utb305.h"
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 .and. lenoeu.lt.0 ) then
          write (ulsort,*) 'apres utb305', logaux(7)
        endif
#endif
c
#include "utb306.h"
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 .and. lenoeu.lt.0 ) then
          write (ulsort,*) 'apres utb306', logaux(7)
        endif
#endif
c
#include "utb3e2.h"
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 .and. lenoeu.lt.0 ) then
          write (ulsort,*) 'apres utb3e2', logaux(7)
        endif
#endif
c
c 2.3.9. ==> si logaux(7) est encore vrai, c'est que le noeud est
c            a l'interieur de l'hexaedre ... malaise ...
c
            if ( logaux(7) ) then
c
              iaux = lehexa
c
#include "utb302.h"
c
              write (ulbila,14203) sommet(1), v1(1), v1(2), v1(3)
              write (ulbila,14203) sommet(2), v2(1), v2(2), v2(3)
              write (ulbila,14203) sommet(3), v3(1), v3(2), v3(3)
              write (ulbila,14203) sommet(4), v4(1), v4(2), v4(3)
              write (ulbila,14203) sommet(5), v5(1), v5(2), v5(3)
              write (ulbila,14203) sommet(6), v6(1), v6(2), v6(3)
              write (ulbila,14203) sommet(7), v7(1), v7(2), v7(3)
              write (ulbila,14203) sommet(8), v8(1), v8(2), v8(3)
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
c====
c 3. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpbco', nbpbco
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
