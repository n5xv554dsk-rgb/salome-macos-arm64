      subroutine pcmex2 ( indtri, indpen,
     >                    nouvar, nouvtr, nouvqu, nouvpe,
     >                    hettri, aretri,
     >                    filtri, pertri, nivtri,
     >                    famtri, cfatri, pentri,
     >                    arequa, nivqua,
     >                    famqua, cfaqua,
     >                    hetpen, facpen, cofape,
     >                    filpen, perpen,
     >                    fampen,
     >                    somare,
     >                    entxar,
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
c    aPres adaptation - Conversion de Maillage EXtrude - phase 2
c     -                 -             -        --              -
c    Duplication des triangles et creation des pentaedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtri . es  . 1      . indice du dernier triangle cree            .
c . indpen . es  .   1    . indice du dernier pentaedre cree           .
c . nouvar . e   .   1    . nouveau nombre d'aretes                    .
c . nouvtr . e   .   1    . nouveau nombre de triangles                .
c . nouvqu . e   .   1    . nouveau nombre de quadrangles              .
c . nouvpe . e   .   1    . nouveau nombre de pentaedres               .
c . hettri . es  . nouvtr . historitre de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . famtri . es  . nouvtr . famille des triangles                      .
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
c . pentri .  s  . nbtrto . pentaedre sur un triangle de la face avant .
c . arequa . es  .nouvqu*4. numeros des 4 aretes des quadrangles       .
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
c . hetpen . es  . nouvpe . historique de l'etat des pentaedres        .
c . facpen . e   .nouvpf*5. numeros des faces des pentaedres           .
c . cofape . e   .nouvpf*5. code des faces des pentaedres              .
c . filpen . es  . nouvpe . premier fils des pentaedres                .
c . perpen . e   . nouvpe . pere des pentaedres                        .
c . fampen . es  . nouvpe . famille des pentaedres                     .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . entxar . e   .2*nbarto. entites liees a l'extrusion de l'arete     .
c .        .     .        . 1 : l'arete                                .
c .        .     .        . 2 : le quadrangle perpendiculaire          .
c .        .     .        . 3 : la 2eme arete de ce quadrangle         .
c . ulsort . e   .   1    . numero d'unite logitre de la liste standard.
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
      parameter ( nompro = 'PCMEX2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nbfami.h"
#include "cofext.h"
#include "cofexq.h"
#include "dicfen.h"
#include "nombar.h"
#include "nombtr.h"
c
c 0.3. ==> arguments
c
      integer indtri, indpen
      integer nouvar, nouvtr, nouvqu, nouvpe
c
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), nivtri(nouvtr)
      integer famtri(nouvtr), cfatri(nctftr,nbftri)
      integer pentri(nouvtr)
      integer arequa(nouvqu,4), nivqua(nouvqu)
      integer famqua(nouvqu), cfaqua(nctfqu,nbfqua)
      integer hetpen(nouvpe)
      integer facpen(nouvpe,5), cofape(nouvpe,5)
      integer filpen(nouvpe), perpen(nouvpe)
      integer fampen(nouvpe)
c
      integer somare(2,nouvar)
      integer entxar(2,nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer letria
      integer atrba1, atrba2, atrba3
      integer atrex1, atrex2, atrex3
      integer arepen(9)
      integer sompe1, sompe2, sompe3
c
      logical oripos, oripox
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
      texte(1,4) = '(''Nombre de triangles actifs :'',i10)'
c
      texte(2,4) = '(''Number of active triangles:'',i10)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbtrac
#endif
c
c====
c 2. parcours des triangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. parcours triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbtrto', nbtrto
      write (ulsort,90002) 'nouvtr', nouvtr
      write (ulsort,90002) 'nouvpe', nouvpe
#endif
c
      do 20 , letria = 1 , nbtrto
c
        if ( mod(hettri(letria),10).eq.0 ) then
c
cgn        write (ulsort,*) ' '
cgn        write (ulsort,90012) '.. Aretes du triangle de base',
cgn     >                       letria, aretri(letria,1),
cgn     >                       aretri(letria,2), aretri(letria,3)
cgn        write (ulsort,90002) '.... Famille', famtri(letria)
cgn        write (ulsort,90002) '.... codes',
cgn     >             (cfatri(iaux,famtri(letria)),iaux=1,nctftr)
c
c 2.1. ==> Orientations
c          oripo. est vrai si le triangle entre dans le volume
c 2.1.1. ==> Orientation du triangle de base
c
          if ( cfatri(cofxto,famtri(letria)).le.3 ) then
            oripos = .True.
          else
            oripos = .False.
          endif
cgn        write (ulsort,99001) '.. La base entre dans le volume', oripos
c
c 2.1.2. ==> Orientation du triangle extrude
c
          if ( cfatri(cofxto,cfatri(cofxtt,famtri(letria))).le.3 ) then
            oripox = .True.
          else
            oripox = .False.
          endif
cgn        write (ulsort,99001) '.. L''extru entre dans le volume', oripox
c
c 2.2. ===> Creation du nouveau triangle
c 2.2.1. ==> Aretes extrudees en tant que bord du triangle
c
          atrex1 = entxar(1,aretri(letria,1))
          atrex2 = entxar(1,aretri(letria,2))
          atrex3 = entxar(1,aretri(letria,3))
c
c 2.2.2. ==> Creation
c            Attention a garder la meme orientation qu'au depart
c
          indtri = indtri + 1
c
          aretri(indtri,1) = atrex1
          if ( (       oripos .and. .not. oripox ) .or.
     >         ( .not. oripos .and.       oripox ) ) then
            aretri(indtri,2) = atrex2
            aretri(indtri,3) = atrex3
          else
            aretri(indtri,2) = atrex3
            aretri(indtri,3) = atrex2
          endif
cgn        write (ulsort,90012) '.. Aretes du triangle extrude',
cgn     >                       indtri, aretri(indtri,1),
cgn     >                       aretri(indtri,2), aretri(indtri,3)
          hettri(indtri) = 50
          filtri(indtri) = 0
          pertri(indtri) = 0
          nivtri(indtri) = nivtri(letria)
          famtri(indtri) = cfatri(cofxtt,famtri(letria))
cgn      write (ulsort,90012) '.. Famille du triangle translate',
cgn     >                       indtri, famtri(indtri)
c
c 2.3. ===> Creation du volume joignant ces deux triangles
c       face 1 : on postule :
c                - c'est le triangle a la base de l'extrusion
c                - sa 1ere arete est la 1ere du pentaedre
c                - il est positionne avec la meme orientation qu'au
c                  depart
c                On en deduit le code :
c                . si l'orientation est positive, code 1 : (a1, a2, a3)
c                . si l'orientation est negative, code 4 : (a1, a3, a2)
c       face 2 : c'est le triangle qui est l'extrusion de la face 1.
c                Ses aretes sont les extrudees des aretes de la face 1 :
c                1ere arete = extrusion de a1 = a4
c                On en deduit le code :
c                . si la face 1 entre et la face 2 sort ou si la face 1
c                  sort et la face 2 entre :
c                  2eme arete = extrusion de a2 = a5
c                  3eme arete = extrusion de a3 = a6
c                  donc code 1
c                . sinon, code 4
c       face 3 : c'est le quadrangle qui est l'extrusion de l'arete 1
c                du pentaedre.
c                1ere arete = a1 = 1ere arete du triangle de base
c                2eme arete = celle qui part du 1er sommet de a1
c                3eme arete = extrusion de a1 = a4 = 1ere arete
c                             du triangle extrude
c                4eme arete = celle qui part du 2nd sommet de a1
c                . si le 1er sommet de a1 est sommet de a2, la 2eme
c                  arete du quadrangle est a7 ;
c                  la face est (a1,a7,a4,a9) donc code 5
c                . sinon, la 2eme arete du quadrangle est a9 ;
c                  la face est (a1,a9,a4,a7) donc code 1
c       face 4 : c'est le quadrangle qui est l'extrusion de l'arete 2
c                du pentaedre.
c                1ere arete = a2
c                2eme arete = celle qui part du 1er sommet de a2
c                3eme arete = extrusion de a2 = a5
c                4eme arete = celle qui part du 2nd sommet de a2
c                . si l'orientation est positive :
c                  a2 = 2eme arete du triangle de base
c                . sinon :
c                  a2 = 3eme arete du triangle de base
c                . si le 1er sommet de a2 est sommet de a3, la 2eme
c                  arete du quadrangle est a8 ;
c                  la face est (a2,a8,a5,a7) donc code 5
c                . sinon, la face est (a2,a7,a5,a8) donc code 1
c       face 5 : c'est le quadrangle qui est l'extrusion de l'arete 3
c                de la face 1.
c                1ere arete = a3
c                2eme arete = celle qui part du 1er sommet de a3
c                3eme arete = extrusion de a3 = a6
c                4eme arete = celle qui part du 2nd sommet de a3
c                . si l'orientation est positive :
c                  a3 = 3eme arete du triangle
c                . sinon :
c                  a3 = 2eme arete du triangle de base
c                . si le 1er sommet de a3 est sommet de a1, la 2eme
c                  arete du quadrangle est a9 ;
c                  la face est (a3,a9,a6,a8) donc code 5
c                . sinon, la face est (a3,a8,a6,a9) donc code 1
c
c 2.3.1. ==> Triangle de base
c
          atrba1 = aretri(letria,1)
          atrba2 = aretri(letria,2)
          atrba3 = aretri(letria,3)
c
cgn        write (ulsort,90002) '.... Fac ext',
cgn     >        entxar(2,atrba1), entxar(2,atrba2), entxar(2,atrba3)
c
c 2.3.2. ==> Les aretes et les sommets du pentaedre
c
          arepen(1) = atrba1
          if ( oripos ) then
            arepen(2) = atrba2
            arepen(3) = atrba3
          else
            arepen(2) = atrba3
            arepen(3) = atrba2
          endif
cgn          write (ulsort,90002) '.... Ar. Pen',
cgn     >                arepen(1), arepen(2), arepen(3)
c
          call utsotr ( somare, arepen(1), arepen(2), arepen(3),
     >                  sompe1, sompe2, sompe3 )
cgn        write (ulsort,90002) '.... So. Pen', sompe1, sompe2, sompe3
c
c 2.3.3. ==> Creation du pentaedre
c
          indpen = indpen + 1
cgn          write (ulsort,90002) '.... pentaedre ', indpen
c
c 2.3.3.1. ==> Face 1 : la base
c
          facpen(indpen,1) = letria
          if ( oripos ) then
            cofape(indpen,1) = 1
          else
            cofape(indpen,1) = 4
          endif
cgn        write (ulsort,90012) '.... code de la face 1',
cgn     > facpen(indpen,1), cofape(indpen,1)
c
c 2.3.3.2. ==> Face 2 : le triangle extrude
c
          facpen(indpen,2) = indtri
          if ( (       oripos .and. .not. oripox ) .or.
     >         ( .not. oripos .and.       oripox ) ) then
            cofape(indpen,2) = 1
          else
            cofape(indpen,2) = 4
          endif
cgn        write (ulsort,90012) '.... code de la face 2',
cgn     >  facpen(indpen,2), cofape(indpen,2)
c
c 2.3.3.3. ==> Face 3 : le quadrangle construit sur la 1ere arete
c
          facpen(indpen,3) = entxar(2,arepen(1))
          iaux = somare(1,arequa(facpen(indpen,3),2))
cgn        write (ulsort,90012) '.... 1er som de l''arete',
cgn     >  arequa(facpen(indpen,3),2),iaux
          if ( iaux.eq.sompe1 ) then
            cofape(indpen,3) = 5
          else
            cofape(indpen,3) = 1
          endif
          nivqua(facpen(indpen,3)) = nivtri(letria)
cgn        write (ulsort,90012) '.... code de la face 3',
cgn     >  facpen(indpen,3),cofape(indpen,3)
c
c 2.3.3.4. ==> Face 4 : le quadrangle construit sur la 2eme arete
c
          facpen(indpen,4) = entxar(2,arepen(2))
          iaux = somare(1,arequa(facpen(indpen,4),2))
cgn        write (ulsort,90012) '.... 1er som de l''arete',
cgn     >  arequa(facpen(indpen,4),2),iaux
          if ( iaux.eq.sompe2 ) then
            cofape(indpen,4) = 5
          else
            cofape(indpen,4) = 1
          endif
          nivqua(facpen(indpen,4)) = nivtri(letria)
cgn        write (ulsort,90012) '.... code de la face 4',
cgn     >  facpen(indpen,4),cofape(indpen,4)
c
c 2.3.3.5. ==> Face 5 : le quadrangle construit sur la 3eme arete
c
          facpen(indpen,5) = entxar(2,arepen(3))
          iaux = somare(1,arequa(facpen(indpen,5),2))
cgn        write (ulsort,90012) '.... 1er som de l''arete',
cgn     >  arequa(facpen(indpen,5),2),iaux
          if ( iaux.eq.sompe3 ) then
            cofape(indpen,5) = 5
          else
            cofape(indpen,5) = 1
          endif
          nivqua(facpen(indpen,5)) = nivtri(letria)
cgn        write (ulsort,90012) '.... code de la face 5',
cgn     >  facpen(indpen,5),cofape(indpen,5)
c
c 2.3.3.6. ==> Caracteristiques generales
c
cgn        write (ulsort,90002) '.... Faces',(facpen(indpen,iaux),iaux=1,5)
cgn        write (ulsort,90002) '.... Codes',(cofape(indpen,iaux),iaux=1,5)
          hetpen(indpen) = 5500
          filpen(indpen) = 0
          perpen(indpen) = 0
          fampen(indpen) = cfatri(cofxtx,famtri(letria))
cgn        write (ulsort,90002) '.... Famille',fampen(indpen)
c
        endif
c
c 2.3.4. ==> Correspondances
c
        if ( mod(hettri(letria),10).eq.0 ) then
c
          pentri(letria) = indpen
          pentri(indtri) = 0
c
        else
c
          pentri(letria) = 0
c
        endif
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'indtri', indtri
      write (ulsort,90002) 'indpen', indpen
#endif
c
      endif
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
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
