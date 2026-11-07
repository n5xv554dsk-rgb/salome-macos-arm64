      subroutine vcme32 ( numare,
     >                    nofaqu, cofaqu,
     >                    famare, posare, inxare,
     >                    inxqua,
     >                    nbfar0, nbfare, cfaare,
     >                    nbfqu0, nbfqua, cfaqua,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 32
c     -                 -             -        -               --
c Determine les familles pour le lien face avant / face perpendiculaire
c au cours de l'extrusion des aretes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numare . es  .    1   . numero de la derniere arete traitee        .
c . nofaqu . e   .  1     . nombre d'origine de familles de quadrangles.
c . cofaqu . e   . ncffqu*. codes d'origine des familles des quads.    .
c .        .     . nofaqu .                                            .
c . famare . es  . nbarto . famille des aretes                         .
c . posare . e   . nbarto . position des aretes                        .
c .        .     .        . 0 : arete avant                            .
c .        .     .        . 1 : arete arriere                          .
c .        .     .        . 2 : arete perpendiculaire                  .
c . inxare . e   .4*nbarto. informations pour l'extrusion des aretes   .
c .        .     .        . 1 : famille de l'arete extrudee            .
c .        .     .        . 2 : famille du quadrangle perpendiculaire  .
c .        .     .        . 3 : code du quadrangle dans le volume      .
c .        .     .        . 4 : quadrangle perpendiculaire             .
c . inxqua . es  .3*nbquto. informations pour l'extrusion des quads    .
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
c . nbfar0 . e   .  1     . nombre de familles d'aretes pour le dim.   .
c . nbfare .  e  .  1     . nombre de familles d'aretes enregistrees   .
c . cfaare .  e  . nctfar*. codes des familles des aretes              .
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
c . nbfqu0 . e   .  1     . nombre de familles de quads pour le dim.   .
c . nbfqua .  es .  1     . nombre de familles de quadrangles          .
c . cfaqua .  es . nctfqu*. codes des familles des quadrangles         .
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
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      parameter ( nompro = 'VCME32' )
c
#include "nblang.h"
#include "cofaar.h"
#include "cofexa.h"
#include "cofexq.h"
#include "coftfq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "dicfen.h"
#include "nombar.h"
#include "nombqu.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer numare
      integer nofaqu, cofaqu(ncffqu,nofaqu)
      integer famare(nbarto), posare(nbarto), inxare(4,nbarto)
      integer inxqua(3,nbquto)
      integer nbfar0, nbfare, cfaare(nctfar,nbfare)
      integer nbfqu0, nbfqua, cfaqua(nctfqu,nbfqu0)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer larete, aredeb
      integer caract(100)
      integer nufaar, nufaqu
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
      texte(1,4) = '(''Familles d''''extrusion des '',a)'
c
      texte(2,4) = '(''Description of families of extruded '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,4)
      write (ulsort,90002) 'numare', numare
      write (ulsort,90002) 'nctfar', nctfar
      write (ulsort,90002) 'cofxax', cofxax
      write (ulsort,90002) 'cofxap', cofxap
      write (ulsort,90002) 'nctfqu', nctfqu
      write (ulsort,90002) 'ncffqu', ncffqu
      write (ulsort,90002) 'ncffar', ncffar
      write (ulsort,90002) 'nofaqu', nofaqu
      write (ulsort,90002) 'nbfar0', nbfar0
      write (ulsort,90002) 'nbfare', nbfare
      write (ulsort,90002) 'nbfqu0', nbfqu0
      write (ulsort,90002) 'nbfqua', nbfqua
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Codes des familles des ',mess14(langue,3,4)
      do 5991 , iaux = 1 , nofaqu
        write(ulsort,90012) 'Famille originale 3D', iaux,
     >                      (cofaqu(jaux,iaux),jaux=1,ncffqu)
 5991 continue
      do 5992 , iaux = 1 , nbfqua
        write(ulsort,90022) 'Famille', iaux,
     >                      (cfaqua(jaux,iaux),jaux=1,nctfqu)
 5992 continue
      write (ulsort,*) 'Codes des familles des ',mess14(langue,3,1)
      do 5993 , iaux = 1 , nbfare
        write(ulsort,90022) 'Famille', iaux,
     >                      (cfaare(jaux,iaux),jaux=1,nctfar)
 5993 continue
49900 format(/,24x,a)
      write(ulsort,49900)
     > ' famille fa are ex   fa quad code q/vo face perp'
      do 4992 , iaux = 1 , nbarto
        if ( posare(iaux).eq.0 ) then
        write(ulsort,90012) 'arete',iaux,famare(iaux),
     >  inxare(1,iaux),inxare(2,iaux),inxare(3,iaux),inxare(4,iaux)
        endif
 4992 continue
#endif
c
      codret = 0
c
c====
c 2. Au premier passage, on met une valeur nulle a la famille du
c    quadrangle perpendiculaire
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. parcours ; codret', codret
#endif
c
      if ( numare.eq.0 ) then
c
        do 20 , iaux = 1, nbfare
          cfaare(cofxax,iaux) = 0
   20   continue
c
      endif
c
c====
c 3. Parcours des aretes de la face avant
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. parcours ; codret', codret
#endif
c
      aredeb = numare + 1
      do 30 , larete = aredeb, nbarto
c
        if ( posare(larete).eq.0 ) then
cgn      write (ulsort,90012) '. Famille de l''arete',
cgn     >                     larete, famare(larete)
c
c 3.1. ==> On veut une famille de quadrangle :
c          . qui a les caracteristiques de celle du maillage 3D
c          . les valeurs pour l'extrusion sont nulles
c          . la position doit etre perpendiculaire
c
c 3.1.1. ==> Les caracteristiques d'origine de la famille
c
          jaux = inxare(2,larete)
cgn      write (ulsort,90002) '.. Famille d''origine du quad', jaux
          do 311 , iaux = 1 , ncffqu
            caract(iaux) = cofaqu(iaux,jaux)
  311     continue
          caract(coftfq) = 0
c
c 3.1.2. ==> On complete par les proprietes de la normale du quadrangle
c
          jaux = inxare(4,larete)
          caract(cofxqt) = inxqua(1,jaux)
          caract(cofxqx) = inxqua(2,jaux)
c
c 3.1.3. ==> Le code de la face dans le volume
c
          caract(cofxqo) = inxare(3,larete)
c
c 3.1.4. ==> L'entite est perpendiculaire
c
          caract(cofxqp) = 2
cgn      write (ulsort,90005) '.. Caract.',(caract(iaux),iaux=1,nctfqu)
c
c 3.2. ==> Recherche d'une situation analogue dans les familles
c          Remarque : on ne tient pas compte des codes lies a la famille
c                     du triangle de conformite car il ne servira jamais
c                     pour des quadrangles places sur la face
c                     perpendiculaire
c
          do 321 , iaux = 1 , nbfqua
c
            do 3211 , jaux = 1 , nctfqu
              if ( jaux.ne.coftfq ) then
                if ( cfaqua(jaux,iaux).ne.caract(jaux) ) then
                  goto 321
                endif
              endif
 3211       continue
c
            nufaex = iaux
cgn            write (ulsort,90002) '.. Correspond a la famille', nufaex
            goto 34
c
  321     continue
c
c 3.3. ==> Creation d'une nouvelle famille
c 3.3.1. ==> S'il n'y a plus de places, on sort et on recommencera
c            pour cette famille
c
          if ( nbfqua.ge.nbfqu0 ) then
c
            numare = larete - 1
            nbfqua = -nbfqua
            goto 3999
c
c 3.3.2. ==> Creation avec les memes caracteristiques
c
          else
c
            nbfqua = nbfqua + 1
cgn         write (ulsort,90002) '.. Creation de la famille', nbfqua
cgn         write (ulsort,90005) '.. avec',(caract(iaux),iaux=1,nctfqu)
            do 3321 , iaux = 1 , nctfqu
              cfaqua(iaux,nbfqua) = caract(iaux)
 3321       continue
            nufaex = nbfqua
c
          endif
c
c 3.4. ==> Enregistrement de la nouvelle famille de quadrangles
c          . pour la famille d'aretes
c          . pour la famille d'aretes d'orientation opposee
c
   34     continue
c
c 3.4.1. ==> La famille d'aretes a deja ete enregistree
c
cgn         write (ulsort,90002) '. fam quad pour fam are',
cgn     >  famare(larete),  cfaare(cofxax,famare(larete)),nufaex
          if ( cfaare(cofxax,famare(larete)).eq.nufaex ) then
c
cgn        write (ulsort,90002)
cgn     > '.. deja vu pour',famare(larete),iaux, nufaex
            goto 30
c
c 3.4.2. ==> La famille d'aretes a deja ete vue : il faut la dupliquer
c
          elseif ( ( cfaare(cofxax,famare(larete)).ne.nufaex ) .and.
     >             ( cfaare(cofxax,famare(larete)).ne.0 ) ) then
c
c 3.4.2.1. ==> S'il n'y a plus de places, on sort et on recommencera
c              pour cette famille
c
            if ( nbfare.ge.nbfar0-4 ) then
c
              numare = larete - 1
              nbfare = -nbfare
              goto 3999
c
c 3.4.2.2. ==> Creation avec les memes caracteristiques
c
            else
c
              nbfare = nbfare + 1
cgn         write (ulsort,90002) '.. Creation de la famille', nbfare
cgn         write (ulsort,90005)
cgn     >   '.. avec',(cfaare(iaux,famare(larete)),iaux=1,nctfar)
              do 3421 , iaux = 1 , nctfar
                cfaare(iaux,nbfare) = cfaare(iaux,famare(larete))
 3421         continue
              cfaare(cofxax,nbfare) = 0
              famare(larete) = nbfare
c
              nbfare = nbfare + 1
cgn         write (ulsort,90002) '.. Creation de la famille', nbfare
              do 3422 , iaux = 1 , nctfar
                cfaare(iaux,nbfare) = cfaare(iaux,famare(larete))
 3422         continue
              cfaare(cofxat,nbfare-1) = nbfare
              cfaare(cofxat,nbfare) = 0
              cfaare(cofxap,nbfare) = 1
c
c           Les familles avec l'orientation inverse
c
              if ( cfaare(coorfa,famare(larete)).ne.0 ) then
c
                nbfare = nbfare + 2
cgn         write (ulsort,90002) '.. Creation des familles opposees'
                do 3423 , iaux = 1 , nctfar
                  cfaare(iaux,nbfare-1) = cfaare(iaux,nbfare-3)
                  cfaare(iaux,nbfare)   = cfaare(iaux,nbfare-2)
 3423           continue
                cfaare(coorfa,nbfare-1) = -cfaare(coorfa,nbfare-3)
                cfaare(coorfa,nbfare  ) = -cfaare(coorfa,nbfare-2)
                cfaare(cofifa,nbfare-3) = nbfare-1
                cfaare(cofifa,nbfare-1) = nbfare-3
                cfaare(cofifa,nbfare-2) = nbfare
                cfaare(cofifa,nbfare  ) = nbfare-2
c
              else
c
                cfaare(cofifa,nbfare-1) = nbfare-1
                cfaare(cofifa,nbfare)   = nbfare
c
              endif
c
            endif
c
          endif
c
c 3.4.3. ==> Enregistrement
c
          cfaare(cofxax,famare(larete)) = nufaex
          iaux = cfaare(cofifa,famare(larete))
          cfaare(cofxax,iaux) = nufaex
cgn        write (ulsort,90002)
cgn     > '.. enregistrement pour',famare(larete),iaux, nufaex
c
        endif
c
   30 continue
c
 3999 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'A la sortie de '//nompro//', nbfare', nbfare
      write (ulsort,*) 'Codes des familles des ',mess14(langue,3,1)
      do 6991 , iaux = 1 , abs(nbfare)
        write(ulsort,90022) 'Famille', iaux,
     >                      (cfaare(jaux,iaux),jaux=1,nctfar)
 6991 continue
      write (ulsort,90002) 'A la sortie de '//nompro//', nbfqua', nbfqua
      write (ulsort,*) 'Codes des familles des ',mess14(langue,3,4)
      do 6992 , iaux = 1 , abs(nbfqua)
        write(ulsort,90022) 'Famille', iaux,
     >                      (cfaqua(jaux,iaux),jaux=1,nctfqu)
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
