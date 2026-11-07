      subroutine pcmex1 ( indare, indqua, nouvno, nouvar, nouvqu,
     >                    coonoe,
     >                    hetare, somare,
     >                    filare, merare,
     >                    famare, cfaare,
     >                    hetqua, arequa,
     >                    filqua, perqua, nivqua,
     >                    famqua, cfaqua,
     >                    entxno, entxar,
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
c    aPres adaptation - Conversion de Maillage EXtrude - phase 1
c     -                 -             -        --              -
c    Duplication des aretes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indqua . es  . 1      . indice du dernier quadrangle cree          .
c . nouvno . e   .   1    . nouveau nombre de noeuds                   .
c . nouvar . e   .   1    . nouveau nombre d'aretes                    .
c . nouvqu . e   .   1    . nouveau nombre de quadrangles              .
c . coonoe . e   . nouvno . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . fille ainee de chaque arete                .
c . merare . es  . nouvar . mere de chaque arete                       .
c . famare . es  . nouvar . famille des aretes                         .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . si extrusion :                             .
c .        .     .        .   8 : famille de l'arete extrudee          .
c .        .     .        .   9 : famille du quadrangle perpendiculaire.
c .        .     .        .  10 : position de l'arete                  .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . hetqua . es  . nouvqu . historique de l'etat des quadrangles       .
c . arequa . es  .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . es  . nouvqu . premier fils des quadrangles               .
c . perqua . es  . nouvqu . pere des quadrangles                       .
c . nivqua . es  . nouvqu . niveau des quadrangles                     .
c . famqua . es  . nouvqu . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . Pour un quadrangle a l'avant :             .
c .        .     .        .   7 : famille du quadrangle extrude        .
c .        .     .        .   8 : famille du volume perpendiculaire    .
c .        .     .        . Pour un quadrangle perpendiculaire :       .
c .        .     .        .   7 : sens de la 1ere compos. de la normale.
c .        .     .        .   8 : sens de la 2eme compos. de la normale.
c .        .     .        .   9 : code du quadrangle dans hexa ou penta.
c .        .     .        .  10 : position du quadrangle               .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . entxno . e   .2*nbnoto. entites liees a l'extrusion du noeud       .
c .        .     .        . 1 : le noeud                               .
c .        .     .        . 2 : l'arete perpendiculaire                .
c . entxar .  s  .2*nbarto. entites liees a l'extrusion de l'arete     .
c .        .     .        . 1 : l'arete                                .
c .        .     .        . 2 : le quadrangle perpendiculaire          .
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
      parameter ( nompro = 'PCMEX1' )
c
#include "nblang.h"
#include "cofexa.h"
#include "cofexq.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nbfami.h"
#include "envca1.h"
#include "dicfen.h"
#include "nombno.h"
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer indare, indqua, nouvno, nouvar, nouvqu
c
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar)
      integer famare(nouvar), cfaare(nctfar,nbfare)
      integer hetqua(nouvqu), arequa(nouvqu,4)
      integer filqua(nouvqu), perqua(nouvqu), nivqua(nouvqu)
      integer famqua(nouvqu), cfaqua(nctfqu,nbfqua)
c
      integer entxno(2,nbnoto)
      integer entxar(2,nbarto)
c
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer iaux1, iaux2
      integer larete
      integer coor12(2)
      integer etat
c
      double precision daux
      double precision vn(3), normal(3)
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
      texte(1,4) = '(''Nombre d''''aretes actives :'',i10)'
c
      texte(2,4) = '(''Number of active edges:'',i10)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbarac
      write (ulsort,90002) 'maconf', maconf
#endif
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
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90002) 'maextr', maextr
      endif
#endif
c
c====
c 3. parcours des aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. parcours aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbarto', nbarto
      write (ulsort,90002) 'nouvar', nouvar
      write (ulsort,90002) 'nouvqu', nouvqu
#endif
c
      if ( ( maconf.eq.0 ) .or. ( maconf.eq.-1 ) ) then
        etat = 0
      else
        etat = 10
      endif
c
      do 30 , larete = 1 , nbarto
c
        if ( mod(hetare(larete),10).le.etat ) then
c
cgn        if ( larete.le.2 .or. larete.eq.53 ) then
cgn        write (ulsort,*) ' '
cgn        write (ulsort,90012)
cgn     >     '.. Famille de l''arete de base', larete, famare(larete)
cgn        write (ulsort,90022) '.... caract.',
cgn     >             (cfaare(iaux,famare(larete)),iaux=1,nctfar)
cgn      endif
c
c 3.1. ===> Creation de la nouvelle arete
c 3.1.1. ==> Noeuds extrudes depuis les extremites de l'arete
c
          iaux1 = entxno(1,somare(1,larete))
          iaux2 = entxno(1,somare(2,larete))
c
c 3.1.2. ==> Creation
c
          indare = indare + 1
c
          somare(1,indare) = min(iaux1,iaux2)
          somare(2,indare) = max(iaux1,iaux2)
          hetare(indare) = 50
          filare(indare) = 0
          merare(indare) = 0
          famare(indare) = cfaare(cofxat,famare(larete))
cgn        if ( larete.le.2 .or. larete.eq.53 ) then
cgn        write (ulsort,90015) '.... ==> Creation de l''arete', indare,
cgn     > ' entre',somare(1,indare),somare(2,indare)
cgn      endif
c
c 3.2. ===> Creation du quadrangle joignant ces deux aretes
c 3.2.1. ==> Aretes partant des extremites de l'arete
c
          iaux1 = entxno(2,somare(1,larete))
          iaux2 = entxno(2,somare(2,larete))
cgn        if ( larete.le.2 .or. larete.eq.53 ) then
cgn        write (ulsort,90012) '.... Aretes perp a l''arete',
cgn     >                       larete, iaux1, iaux2
cgn      endif
c
c 3.2.2. ==> Creation
c
          indqua = indqua + 1
c
          hetqua(indqua) = 5500
          filqua(indqua) = 0
          perqua(indqua) = 0
          nivqua(indqua) = 0
          famqua(indqua) = cfaare(cofxax,famare(larete))
c
          arequa(indqua,1) = larete
          arequa(indqua,2) = iaux1
          arequa(indqua,3) = indare
          arequa(indqua,4) = iaux2
c
cgn        if ( larete.le.2 .or. larete.eq.53 ) then
cgn        write (ulsort,90002) '.... ==> Creation du quad', indqua
cgn        write (ulsort,90002) '.... Aretes', arequa(indqua,1),
cgn     >arequa(indqua,2) , arequa(indqua,3), arequa(indqua,4)
cgn        write (ulsort,90002) '... Familles homard et med',
cgn     >          famqua(indqua), cfaqua(cofamd,famqua(indqua))
cgn      endif
c
c 3.2.3. ==> Controle de l'orientation
c 3.2.3.1. ==> Normale voulue
c
          iaux1 = cfaqua(cofxqt,famqua(indqua))
          iaux2 = cfaqua(cofxqx,famqua(indqua))
          vn(maextr) = 0.d0
          vn(coor12(1)) = dble(iaux1)
          vn(coor12(2)) = dble(iaux2)
cgn        if ( larete.le.2 .or. larete.eq.53 ) then
cgn          write (ulsort,90004) '... Normale voulue', vn
cgn        endif
c
c 3.2.3.2. ==> Calcul du vecteur normal
c
          call utnqua ( indqua, normal,
     >                  nouvno, nouvqu,
     >                  coonoe, somare, arequa )
c
cgn        if ( larete.le.2 .or. larete.eq.53 ) then
cgn          write (ulsort,90004) '... Vecteur normal', normal
cgn        endif
c
c 3.2.3.3. ==> Produit scalaire
c
          daux = vn(1)*normal(1) + vn(2)*normal(2) + vn(3)*normal(3)
cgn        if ( larete.le.2 .or. larete.eq.53 ) then
cgn          write (ulsort,90004) '... ==> produit scalaire', daux
cgn        endif
c
c 3.2.3.4. ==> Reorientation eventuelle
c
          if ( daux.lt.-0.5d0 ) then
cgn        if ( larete.le.2 .or. larete.eq.53 ) then
cgn            write (ulsort,*) '... reorientation'
cgn        endif
            iaux1 = arequa(indqua,2)
            arequa(indqua,2) = arequa(indqua,4)
            arequa(indqua,4) = iaux1
cgn        if ( larete.le.2 .or. larete.eq.53 ) then
cgn        write (ulsort,90002) '.... Aretes', arequa(indqua,1),
cgn     >arequa(indqua,2) , arequa(indqua,3), arequa(indqua,4)
cgn      endif
           endif
c
c 3.3. ===> Memorisation de l'extrusion de l'arete
c
          entxar(1,larete) = indare
          entxar(2,larete) = indqua
c
#ifdef _DEBUG_HOMARD_
        else
cgn        if ( larete.le.2 .or. larete.eq.53 ) then
        write (ulsort,90012) '.. Fille de', larete, filare(larete)
cgn          endif
#endif
        endif
c
   30 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'indare', indare
      write (ulsort,90002) 'indqua', indqua
      do 2221 , iaux = 1 , nbarto
      write (ulsort,90112) 'entxar',iaux,entxar(1,iaux), entxar(2,iaux)
 2221 continue
#endif
c
      endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
