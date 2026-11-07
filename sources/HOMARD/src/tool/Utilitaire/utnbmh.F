      subroutine utnbmh ( nombre,
     >                    nbnois, nbnoei, nbnomp,
     >                    nbnop1, nbnop2, nbnoim,
     >                    nbeutc, nbevca, nbevto,
     >                    nbelem, nbmaae, nbmafe, nbmane,
     >                    nbmapo, nbsegm, nbtria, nbtetr,
     >                    nbquad, nbhexa, nbpent, nbpyra,
     >                    numano, numael,
     >                    nvoare, nvosom,
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
c    UTilitaire - NomBres pour le Maillage HOMARD
c    --           -- -            -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nombre .  e  .   25   . le tableau des nombres                     .
c . nbnois .   s .    1   . nombre de noeuds isoles                    .
c . nbnomp .   s .    1   . nombre de noeuds support de mailles-points .
c . nbnop1 .   s .    1   . nombre de noeuds p1                        .
c . nbnop2 .   s .    1   . nombre de noeuds p2                        .
c . nbnoim .   s .    1   . nombre de noeuds internes aux mailles      .
c . nbeutc .   s .    1   . nombre d'elements utiles au calcul         .
c . nbevca .   s .    1   . nombre d'elements de volumes dans le calcul.
c . nbevto .   s .    1   . nombre d'elements de volumes total         .
c . nbelem .   s .    1   . nombre d'elements dans le calcul           .
c . nbmaae .   s .    1   . nombre maximum d'aretes par element        .
c . nbmafe .   s .    1   . nombre maximum de faces par element        .
c . nbmane .   s .    1   . nombre maximum de noeuds par element       .
c . nbmapo .   s .    1   . nombre de mailles-points dans le maillage  .
c . nbsegm .   s .    1   . nombre de segments dans le maillage        .
c . nbtria .   s .    1   . nombre de triangles dans le maillage       .
c . nbtetr .   s .    1   . nombre de tetraedres dans le maillage      .
c . nbquad .   s .    1   . nombre de quadrangles dans le maillage     .
c . nbhexa .   s .    1   . nombre d'hexaedres dans le maillage        .
c . nbpent .   s .    1   . nombre de pentaedres dans le maillage      .
c . nbpyra .   s .    1   . nombre de pyramides dans le maillage       .
c . numano .   s .    1   . numero maximum de noeud dans le maillage   .
c . numael .   s .    1   . numero maximum d'element dans le maillage  .
c . nvoare .   s .    1   . nombre de voisins par arete                .
c . nvosom .   s .    1   . nombre de voisins par sommet               .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . autre : probleme                           .
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
      parameter ( nompro = 'UTNBMH' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nombre(*)
c
      integer nbnois, nbnoei, nbnomp
      integer nbnop1, nbnop2, nbnoim
      integer nbeutc, nbevca, nbevto
      integer nbelem, nbmaae, nbmafe, nbmane
      integer nbmapo, nbsegm, nbtria, nbtetr,
     >        nbquad, nbhexa, nbpent, nbpyra
      integer numano, numael
      integer nvoare, nvosom
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
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
#include "impr03.h"
c
c====
c 2. valeurs
c====
c
      nbnois = nombre( 1)
      nbnoei = nombre( 2)
      nbnomp = nombre( 3)
      nbnop1 = nombre( 4)
      nbnop2 = nombre( 5)
      nbnoim = nombre( 6)
      nbeutc = nombre( 7)
      nbevca = nombre( 8)
      nbevto = nombre( 9)
      nbelem = nombre(10)
      nbmaae = nombre(11)
      nbmafe = nombre(12)
      nbmane = nombre(13)
      nbmapo = nombre(14)
      nbsegm = nombre(15)
      nbtetr = nombre(16)
      nbtria = nombre(17)
      nbquad = nombre(18)
      numael = nombre(19)
      numano = nombre(20)
      nvoare = nombre(21)
      nvosom = nombre(22)
      nbhexa = nombre(23)
      nbpyra = nombre(24)
      nbpent = nombre(25)
c
c====
c 3. la fin
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
