      subroutine vcmex0 ( option,
     >                    coocst,
     >                    coonoe, posnoe,
     >                    somare, posare,
     >                    aretri, postri,
     >                    arequa, posqua, inxqua,
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
c    aVant adaptation - Conversion de Maillage EXtrude - phase 0
c     -                 -             -        --              -
c   Trie les noeuds, aretes, triangles et quadrangles selon leur
c  position : avant, arriere et perpendiculaire
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . option avec ou sans remplissage de inxqua  .
c . coocst . e   .   11   . 1 : coordonnee constante eventuelle        .
c .        .     .        . 2, 3, 4 : xmin, ymin, zmin                 .
c .        .     .        . 5, 6, 7 : xmax, ymax, zmax                 .
c .        .     .        . 8, 9, 10 : -1 si constant, max-min sinon   .
c .        .     .        . 11 : max des (max-min)                     .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . posnoe . s   . nbnoto . position des noeuds                        .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . posare . s   . nbarto . position des aretes                        .
c .        .     .        . 0 : arete avant                            .
c .        .     .        . 1 : arete arriere                          .
c .        .     .        . 2 : arete perpendiculaire                  .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . postri . s   . nbtrto . position des triangles                     .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c .        .     .        . 2 : face perpendiculaire                   .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . posqua . s   . nbquto . position des quadrangles                   .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c .        .     .        . 2 : face perpendiculaire                   .
c . inxqua .  s  .3*nbquto. informations pour l'extrusion des quads    .
c .        .     .        . Pour un quadrangle a l'avant :             .
c .        .     .        .  1 : famille du quadrangle extrude         .
c .        .     .        .  2 : famille de l'hexaedre                 .
c .        .     .        .  3 : orientation du quadrangle dans le vol..
c .        .     .        . Pour un quadrangle a l'arriere :           .
c .        .     .        .  1 : inutile                               .
c .        .     .        .  2 : inutile                               .
c .        .     .        .  3 : orientation du quadrangle dans le vol..
c .        .     .        . Pour un quadrangle perpendiculaire :       .
c .        .     .        .  1 : sens de la 1ere compos. de la normale .
c .        .     .        .  2 : sens de la 2eme compos. de la normale .
c .        .     .        .  3 : orientation du quadrangle dans le vol..
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
      parameter ( nompro = 'VCMEX0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer option
      integer                   posnoe(nbnoto)
      integer somare(2,nbarto), posare(nbarto)
      integer aretri(nbtrto,3), postri(nbtrto)
      integer arequa(nbquto,4), posqua(nbquto), inxqua(3,nbquto)
c
      double precision coocst(11)
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer iaux1, iaux2, iaux3, iaux4
      integer coor12(2)
c
      double precision daux
      double precision normal(3)
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
      texte(1,4) =
     > '(''Direction '',a1,'' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(1,5) = '(''Nombre de noeuds :'',i10)'
      texte(1,6) = '(''==> epaisseur maximale = '',g13.5)'
      texte(1,7) = '(''==> coordonnee '',a3,'' ='',g13.5)'
c
      texte(2,4) =
     > '(a1,''direction '','' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(2,5) = '(''Number of nodes :'',i10)'
      texte(2,6) = '(''==> maximal thickness:'',g13.5)'
      texte(2,7) = '(''==> '',a3,'' coordinate:'',g13.5)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. caracterisation de l'extrusion
c====
c
      if ( maextr.eq.1 ) then
        coor12(1) = 2
        coor12(2) = 3
      elseif ( maextr.eq.2 ) then
        coor12(1) = 1
        coor12(2) = 3
      elseif ( maextr.eq.3 ) then
        coor12(1) = 1
        coor12(2) = 2
      else
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,5)) nbnoto
      write (ulsort,texte(langue,4)) 'x', coocst(2), coocst(5)
      write (ulsort,texte(langue,4)) 'y', coocst(3), coocst(6)
      write (ulsort,texte(langue,4)) 'z', coocst(4), coocst(7)
      write (ulsort,texte(langue,6)) coocst(11)
      write (ulsort,texte(langue,7)) 'inf', coocst(maextr+1)
      write (ulsort,texte(langue,7)) 'sup', coocst(maextr+4)
      write (ulsort,90002) 'maextr', maextr
      endif
#endif
c
c====
c 3. classement des noeuds
c    on retient tous ceux qui sont dans le plan cooinf
c    on teste la proximite de cooinf au millionieme de l'epaisseur
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. classement noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbnoto', nbnoto
#endif
c
      daux = coocst(10)*1.d-6
c
      do 31 , iaux = 1 , nbnoto
c
        if ( abs(coonoe(iaux,maextr)-coocst(maextr+1)).le.daux ) then
          posnoe(iaux) = 0
        else
          posnoe(iaux) = 1
        endif
c
   31 continue
c
      endif
c
c====
c 4. classement des aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. classement aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbarto', nbarto
#endif
c
      do 41 , iaux = 1 , nbarto
c
        iaux1 = posnoe(somare(1,iaux))
        iaux2 = posnoe(somare(2,iaux))
        if ( ( iaux1.eq.0 ) .and. ( iaux2.eq.0 ) ) then
          posare(iaux) = 0
        elseif ( ( iaux1.eq.1 ) .and. ( iaux2.eq.1) ) then
          posare(iaux) = 1
        else
          posare(iaux) = 2
        endif
c
   41 continue
c
      endif
c
c====
c 5. classement des triangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. classement triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbtrto', nbtrto
#endif
c
      do 51 , iaux = 1 , nbtrto
c
        iaux1 = posare(aretri(iaux,1))
        iaux2 = posare(aretri(iaux,2))
        iaux3 = posare(aretri(iaux,3))
        if ( ( iaux1.eq.0 ) .and.
     >       ( iaux2.eq.0 ) .and.
     >       ( iaux3.eq.0 ) ) then
          postri(iaux) = 0
        elseif ( ( iaux1.eq.1 ) .and.
     >           ( iaux2.eq.1 ) .and.
     >           ( iaux3.eq.1 ) ) then
          postri(iaux) = 1
        else
          postri(iaux) = 2
        endif
c
   51 continue
c
      endif
c
c====
c 6. classement des quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. classement quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbquto', nbquto
#endif
c
      do 61 , iaux = 1 , nbquto
c
        iaux1 = posare(arequa(iaux,1))
        iaux2 = posare(arequa(iaux,2))
        iaux3 = posare(arequa(iaux,3))
        iaux4 = posare(arequa(iaux,4))
c
c 6.1.1. ==> Face avant
c
        if ( ( iaux1.eq.0 ) .and.
     >       ( iaux2.eq.0 ) .and.
     >       ( iaux3.eq.0 ) .and.
     >       ( iaux4.eq.0 ) ) then
          posqua(iaux) = 0
c
c 6.1.2. ==> Face arriere
c
        elseif ( ( iaux1.eq.1 ) .and.
     >           ( iaux2.eq.1 ) .and.
     >           ( iaux3.eq.1 ) .and.
     >           ( iaux4.eq.1 ) ) then
          posqua(iaux) = 1
c
c 6.1.3. ==> Face perpendiculaire
c
        else
          posqua(iaux) = 2
cgn          write (ulsort,90002) 'Quadrangle', iaux
c
          if ( option.ne.0 ) then
c
c 6.1.3.1. ==> Calcul du vecteur normal
c
            call utnqua ( iaux, normal,
     >                    nbnoto, nbquto,
     >                    coonoe, somare, arequa )
c
cgn          write (ulsort,90004) '. Vecteur normal', normal
c
c 6.1.3.2. ==> Enregistrement de la caracterisation
c
            do 6132 , jaux = 1 , 2
c
              iaux1 = coor12(jaux)
              if ( normal(iaux1).gt.1.d-6 ) then
                iaux2 = 1
              elseif ( normal(iaux1).lt.-1.d-6 ) then
                iaux2 = -1
              else
                iaux2 = 0
              endif
cgn            write (ulsort,90002) '. iaux2', iaux2
c
              inxqua(jaux,iaux) = iaux2
c
 6132       continue
c
          endif
c
        endif
c
   61 continue
c
      endif
c
c====
c 7. la fin
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
