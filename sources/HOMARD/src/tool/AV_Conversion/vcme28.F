      subroutine vcme28 ( numfam,
     >                    nbftr0,
     >                    notftr, nofatr, cofatr,
     >                    cfatri,
     >                    cfaqua,
     >                    cfahex,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 28
c     -                 -             -        -               --
c Determine les familles pour le decoupage des quadrangles en triangles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numfam . es  .    1   . numero de la derniere famille traitee      .
c . nbftr0 . e   .  1     . nombre de familles pour le dimensionnement .
c . notftr . e   .  1     . nombre d'origine des carac. des triangles  .
c . nofatr . e   .  1     . nombre d'origine de familles de triangles  .
c . cofatr . e   . notftr*. codes d'origine des familles des triangles .
c .        .     . nofatr .                                            .
c . cfatri . es  . nctftr*. codes des familles des triangles           .
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
c . cfaqua . es  . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        .   7 : famille du quadrangle extrude        .
c .        .     .        .   8 : famille du volume perpendiculaire    .
c .        .     .        .   9 : code du quadrangle dans hexa ou penta.
c .        .     .        .  10 : position du quadrangle               .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . cfahex . e   . nctfhe*. codes des familles des hexaedres           .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c .        .     .        . si extrusion :                             .
c .        .     .        .   3 : famille des pentaedres de conformite .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . e   .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'VCME28' )
c
#include "nblang.h"
#include "consts.h"
#include "cofaar.h"
#include "coftex.h"
#include "cofext.h"
#include "cofexq.h"
#include "cofexh.h"
#include "coftfq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "meddc0.h"
#include "dicfen.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      integer numfam
      integer nbftr0
      integer notftr, nofatr, cofatr(notftr,nofatr)
      integer cfatri(nctftr,nbftri)
      integer cfaqua(nctfqu,nbfqua)
      integer cfahex(nctfhe,nbfhex)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lafami, famdeb
      integer fahohe
      integer caract(100)
      integer nufaex
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'numfam', numfam
      write (ulsort,90002) 'notftr', notftr
      write (ulsort,90002) 'nofatr', nofatr
      write (ulsort,90002) 'nbftr0', nbftr0
      write (ulsort,90002) 'nbfqua', nbfqua
      write (ulsort,90002) 'nctfqu', nctfqu
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Codes des familles des quadrangles'
      do 5991 , iaux = 1 , nbfqua
        write(ulsort,90012) 'Famille', iaux,
     >                      (cfaqua(jaux,iaux),jaux=1,nctfqu)
 5991 continue
      write (ulsort,*) 'Codes des familles des triangles'
      do 5992 , iaux = 1 , nofatr
        write(ulsort,90012) 'Famille originale 3D', iaux,
     >                      (cofatr(jaux,iaux),jaux=1,notftr)
 5992 continue
      do 5993 , iaux = 1 , nbftri
        write(ulsort,90012) 'Famille', iaux,
     >                      (cfatri(jaux,iaux),jaux=1,nctftr)
 5993 continue
#endif
c
      codret = 0
c
c====
c 2. Parcours des familles des faces avant et arriere des quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. parcours ; codret', codret
#endif
c
      famdeb = numfam + 1
      do 20 , lafami = famdeb, nbfqua
c
        if ( cfaqua(cofxqp,lafami).le.1 ) then
cgn        write (ulsort,90002) '. Famille de quadrangle', lafami
c
c 2.1. ==> La famille d'origine du triangle de conformite
c
          fahohe = cfaqua(coftfq,lafami)
cgn      write (ulsort,90002) '.. Famille origine HOMARD tria', fahohe
c
c 2.1. ==> On veut une famille similaire
c
c 2.1.1. ==> Rien a priori
c
          do 211 , iaux = 1 , nctftr
            caract(iaux) = 0
  211     continue
c
c 2.1.2. ==> Les caracteristiques d'origine de la famille
c
          do 212 , iaux = 1 , notftr
            caract(iaux) = cofatr(iaux,fahohe)
  212     continue
c
c 2.1.3. ==> L'orientation doit rester la meme
c
          if ( cfaqua(cofxqo,lafami).le.4 ) then
            if ( caract(cofxto).gt.3 ) then
              caract(cofxto) = 1
            endif
          else
            if ( caract(cofxto).le.3 ) then
              caract(cofxto) = 4
            endif
          endif
c
c 2.1.4. ==> Pour une face avant, le pentaedre construit est deduit
c            de l'hexaedre construit sur le quadrangle
c            Sinon, on s'en moque.
c
          if ( cfaqua(cofxqp,lafami).eq.0 ) then
            caract(cofxtx) = cfahex(cofexh,cfaqua(cofxqx,lafami))
          endif
c
c 2.1.5. ==> Le triangle est a la meme position que le quadrangle
c
          caract(nctftr) = cfaqua(cofxqp,lafami)
cgn        write (ulsort,90005) 'Caract.',(caract(iaux),iaux=1,nctftr)
c
c 2.2. ==> Recherche d'une situation analogue dans les familles
c
          do 221 , iaux = 1 , nbftri
c
            do 2211 , jaux = 1 , ncfftr
              if ( cfatri(jaux,iaux).ne.caract(jaux) ) then
                goto 221
              endif
 2211       continue
c
            nufaex = iaux
cgn            write (ulsort,90002) '.. Correspond a la famille', nufaex
            goto 24
c
  221     continue
c
c 2.3. ==> Creation d'une nouvelle famille
c 2.3.1. ==> S'il n'y a plus de places, on sort et on recommencera
c            pour cette famille
c
          if ( nbftri.ge.nbftr0 ) then
c
            numfam = lafami - 1
            nbftri = -nbftri
            goto 2999
c
c 2.3.2. ==> Creation
c
          else
c
c 2.3.2.1. ==> La famille avec les memes caracteristiques
c
            nbftri = nbftri + 1
cgn         write (ulsort,90002) '.. Creation de la famille', nbfatr
cgn         write (ulsort,90005) '.. avec',(caract(iaux),iaux=1,nctftr)
            do 2321 , iaux = 1 , nctftr
              cfatri(iaux,nbftri) = caract(iaux)
 2321       continue
            nufaex = nbftri
c
          endif
c
c 2.4. ==> Enregistrement de la famille de triangles associe a
c          la famille des quadrangles
c
   24     continue
c
          cfaqua(coftfq,lafami) = nufaex
c
        endif
c
   20 continue
c
 2999 continue
c
c====
c 3. Quand toutes les familles ont ete crees, on gere les extrusions
c    des triangles
c====
c
      if ( nbftri.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        do 30 , lafami = 1, nbfqua
c
          if ( cfaqua(cofxqp,lafami).eq.0 ) then
c
c 3.1. ==> La famille du triangle de conformite
c
            fahohe = cfaqua(coftfq,lafami)
cgn            write (ulsort,90002) '.. Famille tria', fahohe
c
c 3.2. ==> La famille du quadrangle translate
c
            iaux = cfaqua(cofxqt,lafami)
cgn            write (ulsort,90002) '.. Famille quad translate', iaux
c
c 3.3. ==> La famille du triangle de conformite pour
c          le quadrangle translate
c
            jaux = cfaqua(coftfq,iaux)
cgn            write (ulsort,90002) '.. Famille tria translate', jaux
c
c 3.4. ==> Mise en place de la correspondance
c
            cfatri(cofxtt,fahohe) = jaux
c
          endif
c
   30   continue
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'A la sortie de '//nompro//', nbfqua', nbfqua
      write (ulsort,*) 'Codes des familles des quadrangles'
      do 6991 , iaux = 1 , abs(nbfqua)
        write(ulsort,90012) 'Famille', iaux,
     >                      (cfaqua(jaux,iaux),jaux=1,nctfqu)
 6991 continue
      write (ulsort,90002) 'A la sortie de '//nompro//', nbftri', nbftri
      write (ulsort,*) 'Codes des familles des triangles'
      do 6992 , iaux = 1 , abs(nbftri)
        write(ulsort,90012) 'Famille', iaux,
     >                      (cfatri(jaux,iaux),jaux=1,nctftr)
 6992 continue
#endif
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
