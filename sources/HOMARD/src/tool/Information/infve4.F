      subroutine infve4 ( fotrva, foquva,
     >                    coonoe, somare, aretri, arequa,
     >                    nbtrvi, nbquvi,
     >                    nntrvi, nnquvi,
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
c   INformation : Fichiers VEctoriel - 4eme partie
c   --            -        --          -
c ______________________________________________________________________
c
c recherche des qualites
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . fotrva .  s  . nbtrvi . fonctions triangles : valeur               .
c . foquva .  s  . nbquvi . fonctions quadrangles : valeur             .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nbtrvi . e   .   1    . nombre triangles visualisables             .
c . nbquvi . e   .   1    . nombre de quadrangles visualisables        .
c . nntrvi . e   .10nbtrvi. 1 : niveau du triangle a afficher          .
c .        .     .        . 2 : numero HOMARD du triangle              .
c .        .     .        . 3, 4, 5 : numeros des noeuds p1            .
c .        .     .        . 6 : famille du triangle                    .
c .        .     .        . 7, 8, 9 : numeros des noeuds p2            .
c .        .     .        . 10 : numero du noeud interne               .
c . nnquvi . e   .12nbquvi. 1 : niveau du quadrangle a afficher        .
c .        .     .        . 2 : numero HOMARD du quadrangle            .
c .        .     .        . 3, 4, 5, 6 : numeros des noeuds p1         .
c .        .     .        . 7 : famille du quadrangle                  .
c .        .     .        . 8, 9, 10, 11 : numeros des noeuds p2       .
c .        .     .        . 12 : numero du noeud interne               .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'INFVE4' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
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
c
c 0.3. ==> arguments
c
      integer nbtrvi, nbquvi
      integer nntrvi(10,nbtrvi)
      integer nnquvi(12,nbquvi)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3), arequa(nbquto,4)
c
      double precision fotrva(*), foquva(*)
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer letria, lequad
c
      double precision qual, daux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c_______________________________________________________________________
c
c====
c 1. initialisation
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
      texte(1,4) = '(''Recherche des qualites des mailles'')'
c
      texte(2,4) = '(''Research of mesh qualities'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
cgn 1789   format(i4,12f13.6)
c
c====
c 2. Parcours des differentes mailles
c====
c 2.1. ==> les triangles
c
      do 21 , iaux = 1 , nbtrvi
c
        letria = nntrvi(2,iaux)
c
        call utqtri ( letria, qual, daux,
     >                coonoe, somare, aretri )
c
        fotrva(iaux) = qual
cgn      print 1789,iaux,fotrva(iaux)
c
   21 continue
c
c 2.2. ==> les quadrangles
c
      do 22 , iaux = 1 , nbquvi
c
        lequad = nnquvi(2,iaux)
c
        call utqqua ( lequad, qual, daux,
     >                coonoe, somare, arequa )
c
        foquva(iaux) = qual
cgn      print 1789,iaux,fotrva(iaux)
c
   22 continue
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
