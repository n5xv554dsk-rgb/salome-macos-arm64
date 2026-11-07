      subroutine utnbmc ( nombre,
     >                    nbmaae, nbmafe, nbmnei,
     >                    numano, numael,
     >                    nbma2d, nbma3d,
     >                    nbmapo, nbsegm, nbtria, nbtetr,
     >                    nbquad, nbhexa, nbpent, nbpyra,
     >                    nbfmed, nbfmen, ngrouc,
     >                    nbequi,
     >                    nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
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
c    UTilitaire - NomBres pour le Maillage de Calcul
c    --           -- -            -           -
c ______________________________________________________________________
c
c C'est le contenu du common nbutil
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nombre .  e  .   36   . le tableau des nombres                     .
c . nbmaae .   s .    1   . nombre maximum d'aretes par element        .
c . nbmafe .   s .    1   . nombre maximum de faces par element        .
c . nbmnei .   s .    1   . nombre max. de noeuds des elements ignores .
c . numano .   s .    1   . numero maximum de noeud dans le maillage   .
c . numael .   s .    1   . numero maximum d'element dans le maillage  .
c . nbma2d .   s .    1   . nombre total de mailles 2D                 .
c . nbma3d .   s .    1   . nombre total de mailles 3D                 .
c . nbmapo .   s .    1   . nombre de mailles-points dans le maillage  .
c . nbsegm .   s .    1   . nombre de segments dans le maillage        .
c . nbtria .   s .    1   . nombre de triangles dans le maillage       .
c . nbtetr .   s .    1   . nombre de tetraedres dans le maillage      .
c . nbquad .   s .    1   . nombre de quadrangles dans le maillage     .
c . nbhexa .   s .    1   . nombre d'hexaedres dans le maillage        .
c . nbpent .   s .    1   . nombre de pentaedres dans le maillage      .
c . nbpyra .   s .    1   . nombre de pyramides dans le maillage       .
c . nbfmed .   s .    1   . nombre total de familles MED               .
c . nbfmen .   s .    1   . nombre de familles MED pour les noeuds     .
c . ngrouc .   s .    1   . nombre de groupes cumules dans les familles.
c . nbequi .   s .    1   . nombre total d'equivalences                .
c . nbeqno .   s .    1   . nombre total de paires equiv. de noeuds    .
c . nbeqmp .   s .    1   . nombre total de paires equiv. de m-points.
c . nbeqar .   s .    1   . nombre total de paires equiv. d'aretes     .
c . nbeqtr .   s .    1   . nombre total de paires equiv. de triangles .
c . nbeqqu .   s .    1   . nombre total de paires equiv. de quad.     .
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
      parameter ( nompro = 'UTNBMC' )
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
      integer nbmaae, nbmafe, nbmnei
      integer numano, numael
      integer nbma2d, nbma3d
      integer nbmapo, nbsegm, nbtria, nbtetr,
     >        nbquad, nbhexa, nbpent, nbpyra
      integer nbfmed, nbfmen, ngrouc
      integer nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
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
      nbmaae = nombre( 1)
      nbmafe = nombre( 2)
      nbmnei = nombre( 3)
      numano = nombre( 4)
      numael = nombre( 5)
      nbma2d = nombre( 6)
      nbma3d = nombre( 7)
      nbmapo = nombre(12)
      nbsegm = nombre(13)
      nbtria = nombre(14)
      nbtetr = nombre(15)
      nbquad = nombre(17)
      nbhexa = nombre(18)
      nbpent = nombre(19)
      nbpyra = nombre(20)
      nbfmed = nombre(22)
      nbfmen = nombre(23)
      ngrouc = nombre(24)
      nbequi = nombre(31)
      nbeqno = nombre(32)
      nbeqmp = nombre(33)
      nbeqar = nombre(34)
      nbeqtr = nombre(35)
      nbeqqu = nombre(36)
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
