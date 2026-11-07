      subroutine vcme22 ( typenh, nument, cofxeo,
     >                    nbinfx, nctfen, nbenti,
     >                    notfen, nofaen, cofaen,
     >                    nbfae0, nbfaen, cfaent,
     >                    fament, posent, inxent,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 22
c     -                 -             -        -              --
c Determine les familles pour un type de mailles de la face avant
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .    1   . type d'entites                             .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : segments                             .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nument . es  .    1   . numero de la derniere entite traitee       .
c . cofxeo . e   .    1   . orientation de l'entite comme face/volume  .
c . nbinfx . e   .    1   . nombre d'informations pour inxent          .
c . nctfen . e   .    1   . nombre de caracteristique des f. entite    .
c . nbenti . e   .    1   . nombre d'entites                           .
c . notfen . e   .  1     . nombre d'origine des carac. des f. entite  .
c . nofaen . e   .  1     . nombre d'origine de familles de l'entite   .
c . cofaen . e   . notfen*. codes d'origine des familles de l'entite   .
c .        .     . nofaen .                                            .
c . fament . e   . nbenti . famille des entites                        .
c . posent . e   . nbenti . position des entites                       .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c .        .     .        . 2 : perpendiculaire                        .
c . inxent . e   . nbinfx*. informations pour l'extrusion des entites  .
c .        .     . nbenti . 1 : famille de l'entite extrudee           .
c .        .     .        . 2 : famille de l'entite perpendiculaire    .
c .        .     .        . Si triangle ou quadrangle :                .
c .        .     .        . 3 : code de la face dans le volume         .
c . nbfae0 .  e  .  1     . nombre de familles pour le dimensionnement .
c . nbfaen .  es .  1     . nombre de familles enregistrees            .
c . cfaent .  es . nctfen*. codes des familles d'entites               .
c .        .     . nbfaen .   1 : famille MED                          .
c .        .     .        . si maille-point :                          .
c .        .     .        .   2 : type de maille-point                 .
c .        .     .        .   3 : famille des sommets                  .
c .        .     .        . si arete :                                 .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c .        .     .        . si triangle :                              .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c .        .     .        . si quadrangle :                            .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c .        .     .        . si extrusion et noeud/arete/tria/quad :    .
c .        .     .        . n+1 : famille de l'entite extrudee         .
c .        .     .        . n+2 : famille de l'entite perpendiculaire  .
c .        .     .        . si extrusion et triangle ou quadrangle :   .
c .        .     .        . n+3 : code de la face dans le volume       .
c .        .     .        . si extrusion :                             .
c .        .     .        . n+3/4 : position de l'entite               .
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
      parameter ( nompro = 'VCME22' )
c
#include "nblang.h"
#include "cofaar.h"
#include "cofexq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh, nument
      integer cofxeo
      integer nbinfx, nctfen, nbenti
      integer notfen, nofaen, cofaen(notfen,nofaen)
      integer nbfae0, nbfaen, cfaent(nctfen,nbfae0)
c
      integer fament(nbenti), posent(nbenti), inxent(nbinfx,nbenti)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer lentit, entdeb
      integer caract(100)
      integer nufaex
      integer posmax
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
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,90002) 'nument', nument
      write (ulsort,90002) 'nbinfx', nbinfx
      write (ulsort,90002) 'nctfen', nctfen
      write (ulsort,90002) 'nbenti', nbenti
      write (ulsort,90002) 'notfen', notfen
      write (ulsort,90002) 'nofaen', nofaen
      write (ulsort,90002) 'nbfae0', nbfae0
      write (ulsort,90002) 'nbfaen', nbfaen
#endif
c
#ifdef _DEBUG_HOMARD_
49900 format(33x,a)
      write (ulsort,*)
     >      'Informations d''extrusion des ', mess14(langue,3,typenh)
      if ( typenh.eq.-1 ) then
        write(ulsort,49900) ' famille fa noe ex  fa arete'
      elseif ( typenh.eq.1 ) then
        write(ulsort,49900)
     > ' famille fa are ex   fa quad code q/vo face perp'
      elseif ( typenh.eq.2 ) then
        write(ulsort,49900) 'famille fa tri ex   fa pent code t/pe'
      else
        write(ulsort,49900)
     >  'famille  position fa qua ex   fa hexa code q/vo'
      endif
      do 4991 , lentit = 1 , nbenti
        if ( posent(lentit).eq.0 ) then
          write(ulsort,90012)
     >                mess14(langue,2,typenh),lentit,fament(lentit),
     >                (inxent(jaux,lentit),jaux=1,nbinfx)
        endif
 4991 continue
      write (ulsort,*) 'Codes des familles d''origine des ',
     >                 mess14(langue,3,typenh)
      do 5991 , iaux = 1 , nofaen
        write(ulsort,90012) 'Famille origine', iaux,
     >                      (cofaen(jaux,iaux),jaux=1,notfen)
 5991 continue
#endif
c
      codret = 0
c
c====
c 2. Creation des premieres familles, libres
c    Dans l'ordre : famille a l'avant, a l'arriere, perpendiculaire
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. famille libre ; codret', codret
#endif
c
      if ( nbfaen.eq.0 ) then
c
        if ( typenh.eq.-1 .or. typenh.eq.2 ) then
          kaux = 2
        else
          kaux = 3
        endif
c
        do 21 , iaux = 1 , kaux
c
c 2.1. ==> La famille libre de base
c
          nbfaen = nbfaen + 1
          do 211 , jaux = 1 , notfen
            cfaent(jaux,nbfaen) = cofaen(jaux,1)
  211     continue
c
          if ( iaux.eq.1 ) then
            do 2121 , jaux = notfen+1 , nctfen-1
              cfaent(jaux,nbfaen) = 1
 2121       continue
          else
            do 2122 , jaux = notfen+1 , nctfen-1
              cfaent(jaux,nbfaen) = 0
 2122       continue
          endif
c
c         Pour les faces, on met un code 1 pour la relation
c         avec les volumes
          if ( typenh.ge.2 ) then
            cfaent(cofxeo,nbfaen) = 1
          endif
c
c         Pour les quadrangles, on met un code 1 pour la 1ere
c         composante de la normale
          if ( typenh.ge.4 ) then
            cfaent(cofxqt,nbfaen) = 1
          endif
c
c         Position
          cfaent(nctfen,nbfaen) = iaux-1
cgn          write (ulsort,90002) '.. Creation de la famille libre', nbfaen
cgn          write (ulsort,90005) '.. avec',
cgn     >                         (cfaent(jaux,nbfaen),jaux=1,nctfen)
c
   21   continue
c
      endif
c
c====
c 3. Parcours des entites
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. parcours ; codret', codret
#endif
c
      if ( typenh.le.1 ) then
        posmax = 0
      elseif ( typenh.eq.2 ) then
        posmax = 1
      else
        posmax = 2
      endif
cgn      write (ulsort,90002) 'posmax', posmax
c
      entdeb = nument + 1
      do 30 , lentit = entdeb, nbenti
c
        if ( posent(lentit).le.posmax ) then
cgn      write (ulsort,90012) '. Famille du '//mess14(langue,1,typenh),
cgn     >                     lentit, fament(lentit)
cgn      write (ulsort,90002) '.. position', posent(lentit)
c
c 3.1. ==> Les caracteristiques de l'entite courante
c 3.1.1. ==> On commence par les caracteristiques d'origine
c            de la famille de l'entite courante
c
          do 311 , iaux = 1 , notfen
            caract(iaux) = cofaen(iaux,fament(lentit))
  311     continue
c
c 3.1.2. ==> On complete par les proprietes de l'extrusion
c            Remarque : dans le cas des aretes, la derniere information,
c                       code de la face perpendiculaire dans le volume,
c                       est ecrasee par la position. Elle sera utilisee
c                       plus tard
c
          do 312 , iaux = 1 , nbinfx
            caract(notfen+iaux) = inxent(iaux,lentit)
  312     continue
c
c 3.1.3. ==> Position de l'entite
c
          caract(nctfen) = posent(lentit)
cgn      write (ulsort,90005) 'Caract.',(caract(iaux),iaux=1,nctfen)
c
c 3.2. ==> Recherche d'une situation analogue
c
          do 32 , iaux = 1 , nbfaen
c
            do 321 , jaux = 1 , nctfen
              if ( cfaent(jaux,iaux).ne.caract(jaux) ) then
                goto 32
              endif
  321       continue
c
            nufaex = iaux
cgn            write (ulsort,90002) '.. Correspond a la famille', nufaex
            goto 34
c
   32     continue
c
c 3.3. ==> Creation d'une nouvelle famille
c 3.3.1. ==> S'il n'y a plus de places, on sort et on recommencera
c            pour cette famille
c
          if ( nbfaen.ge.nbfae0-1 ) then
c
            nument = lentit - 1
            nbfaen = -nbfaen
            goto 3999
c
c 3.3.2. ==> Creation
c
          else
c
c 3.3.2.1. ==> La famille avec les memes caracteristiques
c
            nbfaen = nbfaen + 1
cgn         write (ulsort,90002) '.. Creation de la famille', nbfaen
cgn         write (ulsort,90005) '.. avec',(caract(iaux),iaux=1,nctfen)
            do 3321 , iaux = 1 , nctfen
              cfaent(iaux,nbfaen) = caract(iaux)
 3321       continue
            nufaex = nbfaen
c
c 3.3.2.2. ==> Pour les aretes, la famille avec l'orientation inverse
c
            if ( typenh.eq.1 ) then
c
            if ( cfaent(coorfa,nbfaen).ne.0 ) then
c
                nbfaen = nbfaen + 1
cgn         write (ulsort,90015) '.. Creation de la famille', nbfaen,
cgn     >                        ' d''orientation opposee'
                do 3322 , iaux = 1 , nctfen
                  cfaent(iaux,nbfaen) = caract(iaux)
 3322           continue
                cfaent(coorfa,nbfaen) = -cfaent(coorfa,nbfaen-1)
                cfaent(cofifa,nbfaen  ) = nbfaen-1
                cfaent(cofifa,nbfaen-1) = nbfaen
c
              else
c
                cfaent(cofifa,nbfaen) = nbfaen
c
              endif
c
            endif
c
          endif
c
c 3.4. ==> Enregistrement de la nouvelle famille pour l'entite
c
   34     continue
c
          fament(lentit) = nufaex
c
        endif
c
   30 continue
c
 3999 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'A la sortie de '//nompro//', nbfaen', nbfaen
      if ( typenh.eq.4 ) then
      write (ulsort,*) '... Codes des familles des ',
     >                 mess14(langue,3,typenh)
      do 5992 , iaux = 1 , abs(nbfaen)
        write(ulsort,90022) 'Famille', iaux,
     >                      (cfaent(jaux,iaux),jaux=1,nctfen)
 5992 continue
      endif
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
