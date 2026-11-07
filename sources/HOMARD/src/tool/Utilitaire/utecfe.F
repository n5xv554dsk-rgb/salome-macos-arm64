      subroutine utecfe ( maextr,
     >                    famnoe, cfanoe,
     >                    fammpo, cfampo,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
     >                    famtet, cfatet,
     >                    famhex, cfahex,
     >                    fampyr, cfapyr,
     >                    fampen, cfapen,
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
c    UTilitaire - ECriture des Codes de Familles d'Entites
c    --           -            -        -          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . maextr . e   .   1    . maillage extrude                           .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : selon X                                .
c .        .     .        . 2 : selon Y                                .
c .        .     .        . 3 : selon Z (cas de Saturne ou Neptune)    .
c . famnoe . e   . nbnoto . famille des noeuds                         .
c . cfanoe . e   . nctfno*. codes des familles des noeuds              .
c .        .     . nbfnoe .   1 : famille MED                          .
c .        .     .        . si extrusion :                             .
c .        .     .        .   2 : famille du noeud extrude             .
c .        .     .        .   3 : famille de l'arete perpendiculaire   .
c .        .     .        .   4 : position du noeud                    .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . fammpo . e   . nbmpto . famille des mailles-points                 .
c . cfampo . e   . nctfmp*. codes des familles des mailles-points      .
c .        .     . nbfmpo .   1 : famille MED                          .
c .        .     .        .   2 : type de maille-point                 .
c .        .     .        .   3 : famille des sommets                  .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famare . e   . nbarto . famille des aretes                         .
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
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . si extrusion :                             .
c .        .     .        .   5 : famille du triangle extrude          .
c .        .     .        .   6 : famille du pent. perpendiculaire     .
c .        .     .        .   7 : code du triangle dans le pentaedre   .
c .        .     .        .   8 : position du triangle                 .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
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
c . famtet . e   . nbteto . famille des tetraedres                     .
c . cfatet . e   . nctfte*. codes des familles des tetraedres          .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
c . famhex . e   . nbheto . famille des hexaedres                      .
c . cfahex . e   . nctfhe*. codes des familles des hexaedres           .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c .        .     .        . si extrusion :                             .
c .        .     .        .   3 : famille des pentaedres de conformite .
c . fampyr . e   . nbpyto . famille des pyramides                      .
c . cfapyr . e   . nctfpy*. codes des familles des pyramides           .
c .        .     . nbfpyr .   1 : famille MED                          .
c .        .     .        .   2 : type de pyramides                    .
c . fampen . e   . nbpeto . famille des pentaedres                     .
c . cfapen . e   . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
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
      parameter ( nompro = 'UTECFE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer maextr
      integer famnoe(nbnoto), cfanoe(nctfno,nbfnoe)
      integer fammpo(nbmpto), cfampo(nctfmp,nbfmpo)
      integer famare(nbarto), cfaare(nctfar,nbfare)
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
      integer famqua(nbquto), cfaqua(nctfqu,nbfqua)
      integer famtet(nbteto), cfatet(nctfte,nbftet)
      integer famhex(nbheto), cfahex(nctfhe,nbfhex)
      integer fampyr(nbpyto), cfapyr(nctfpy,nbfpyr)
      integer fampen(nbpeto), cfapen(nctfpe,nbfpen)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
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
c====
c 2. liste des familles de noeuds
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECF0_NO', nompro
#endif
      iaux = -1
      jaux = 1
      call utecf0 ( maextr,   iaux, nbnoto,
     >              nbfnoe,   jaux,   jaux,
     >              nctfno, ncffno, ncxfno, ncefno,
     >              famnoe, cfanoe,
     >              ulsort, langue, codret )
c
c====
c 3. Liste eventuelle des familles de mailles-points
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbfmpo.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECF0_MP', nompro
#endif
        iaux = 0
        jaux = -1
        kaux = 0
        call utecf0 ( maextr,   iaux, nbmpto,
     >                nbfmpo,   jaux,   jaux,
     >                nctfmp, ncffmp,   kaux, ncefmp,
     >                fammpo, cfampo,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 4. Liste des familles d'aretes
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECF0_AR', nompro
#endif
      iaux = 1
      jaux = -1
      call utecf0 ( maextr,   iaux, nbarto,
     >              nbfare,   jaux,   jaux,
     >              nctfar, ncffar, ncxfar, ncefar,
     >              famare, cfaare,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. Liste eventuelle des familles de triangles
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbftri.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECF0_TR', nompro
#endif
        iaux = 2
        jaux = -1
        call utecf0 ( maextr,   iaux, nbtrto,
     >                nbftri,   jaux,   jaux,
     >                nctftr, ncfftr, ncxftr, nceftr,
     >                famtri, cfatri,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 6. Liste eventuelle des familles de quadrangles
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbfqua.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECF0_QU', nompro
#endif
        iaux = 4
        jaux = -1
        call utecf0 ( maextr,   iaux, nbquto,
     >                nbfqua, nbftri,   jaux,
     >                nctfqu, ncffqu, ncxfqu, ncefqu,
     >                famqua, cfaqua,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 7. liste eventuelle des familles de tetraedres
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbftet.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECF0_TE', nompro
#endif
        iaux = 3
        jaux = -1
        kaux = 0
        call utecf0 ( maextr,   iaux, nbteto,
     >                nbftet,   jaux,   jaux,
     >                nctfte, ncffte,   kaux,   kaux,
     >                famtet, cfatet,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 8. liste eventuelle des familles d'hexaedres
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbfhex.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECF0_HE', nompro
#endif
        iaux = 6
        kaux = 0
        call utecf0 ( maextr,   iaux, nbheto,
     >                nbfhex, nbftet, nbfpyr,
     >                nctfhe, ncffhe,   kaux,   kaux,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 9. liste eventuelle des familles de pyramides
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbfpyr.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECF0_PY', nompro
#endif
        iaux = 5
        jaux = -1
        kaux = 0
        call utecf0 ( maextr,   iaux, nbpyto,
     >                nbfpyr,   jaux,   jaux,
     >                nctfpy, ncffpy,   kaux,   kaux,
     >                fampyr, cfapyr,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 10. liste eventuelle des familles de pentaedres
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbfpen.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECF0_PE', nompro
#endif
        iaux = 7
        kaux = 0
        call utecf0 ( maextr,   iaux, nbpeto,
     >                nbfpen, nbftet, nbfpyr,
     >                nctfpe, ncffpe,   kaux,   kaux,
     >                fampen, cfapen,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 11. la fin
c====
c
      if ( codret.eq.0 ) then
c
 1100 format(/,5x,123('-'),/)
      write (ulsort,1100)
c
      endif
c
c====
c 12. la fin
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
