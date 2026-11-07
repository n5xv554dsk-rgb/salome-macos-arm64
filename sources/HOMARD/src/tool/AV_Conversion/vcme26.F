      subroutine vcme26 ( typenh, numfam,
     >                    nctfen, ncffen, cofxet, cofxep,
     >                    notfen, nofaen, cofaen,
     >                    nbfae0, nbfaen, cfaent,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 26
c     -                 -             -        -               --
c Determine les familles pour le lien face avant / face arriere
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
c . numfam . es  .    1   . numero de la derniere famille traitee      .
c . nctfen . e   .    1   . nombre de caracteristique des f. entite    .
c . ncffen . e   .    1   . nombre de caracteristique figees entite    .
c . cofxet . e   .    1   . code de la famille de l'entite translatee  .
c . cofxep . e   .    1   . code de la position de l'entite            .
c . notfen . e   .  1     . nombre d'origine des carac. des f. entite  .
c . nofaen . e   .  1     . nombre d'origine de familles de l'entite   .
c . cofaen . e   . notfen*. codes d'origine des familles de l'entite   .
c .        .     . nofaen .                                            .
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
c .        .     .        . n+1 : famille du noeud extrude             .
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
      parameter ( nompro = 'VCME26' )
c
#include "nblang.h"
#include "cofaar.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh, numfam
      integer nctfen, ncffen, cofxet, cofxep
      integer notfen, nofaen, cofaen(notfen,nofaen)
      integer nbfae0, nbfaen, cfaent(nctfen,nbfae0)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lafami, famdeb
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
      texte(1,4) = '(''Familles d''''extrusion des '',a)'
c
      texte(2,4) = '(''Description of families of extruded '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,90002) 'numfam', numfam
      write (ulsort,90002) 'nctfen', nctfen
      write (ulsort,90002) 'ncffen', ncffen
      write (ulsort,90002) 'cofxet', cofxet
      write (ulsort,90002) 'cofxep', cofxep
      write (ulsort,90002) 'notfen', notfen
      write (ulsort,90002) 'nofaen', nofaen
      write (ulsort,90002) 'nbfae0', nbfae0
      write (ulsort,90002) 'nbfaen', nbfaen
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'A l''entree de '//nompro//', nbfaen', nbfaen
      write (ulsort,*) 'Codes des familles des ',mess14(langue,3,typenh)
      do 5991 , iaux = 1 , nofaen
        write(ulsort,90022) 'Famille originale 3D', iaux,
     >                      (cofaen(jaux,iaux),jaux=1,notfen)
 5991 continue
      do 5992 , iaux = 1 , nbfaen
        write(ulsort,90022) 'Famille', iaux,
     >                      (cfaent(jaux,iaux),jaux=1,nctfen)
 5992 continue
#endif
c
      codret = 0
c
c====
c 2. Parcours des familles de la face avant
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. parcours ; codret', codret
#endif
c
      famdeb = numfam + 1
      do 20 , lafami = famdeb, nbfaen
c
        if ( cfaent(cofxep,lafami).eq.0 ) then
cgn      write (ulsort,90012) '. Famille de '//mess14(langue,1,typenh),
cgn     >                     lafami
c
c 2.1. ==> On veut une famille :
c          . qui a les caracteristiques de celle du maillage 3D
c          . les valeurs pour l'extrusion sont nulles
c          . la position doit etre arriere
c
c 2.1.1. ==> Rien a priori
c
          do 211 , iaux = 1 , nctfen
            caract(iaux) = 0
  211     continue
c
c 2.1.2. ==> Les caracteristiques d'origine de la famille
c
          jaux = cfaent(cofxet,lafami)
          do 212 , iaux = 1 , notfen
            caract(iaux) = cofaen(iaux,jaux)
  212     continue
c
c 2.1.3. ==> L'entite est a l'arriere
c
          caract(cofxep) = 1
cgn      write (ulsort,90005) 'Caract.',(caract(iaux),iaux=1,nctfen)
c
c 2.2. ==> Recherche d'une situation analogue dans les familles
c          Remarque : on ne tient pas compte des codes lies a
c                     l'extrusion car ils ne serviront jamais pour des
c                     entites placees sur la face arriere
c 2.2.1. ==> Pour une arete, sans tenir compte de l'orientation
c
          if ( typenh.eq.1 ) then
c
            do 221 , iaux = 1 , nbfaen
c
              do 2211 , jaux = 1 , ncffen
                if ( jaux.ne.cofifa ) then
                  if ( cfaent(jaux,iaux).ne.caract(jaux) ) then
                    goto 221
                  endif
                endif
 2211         continue
c
              nufaex = iaux
              goto 24
c
  221     continue
c
c 2.2.2. ==> Autre entite
c
          else
c
            do 222 , iaux = 1 , nbfaen
c
              do 2221 , jaux = 1 , ncffen
                if ( cfaent(jaux,iaux).ne.caract(jaux) ) then
                  goto 222
                endif
 2221         continue
c
              nufaex = iaux
cgn            write (ulsort,90002) '.. Correspond a la famille', nufaex
              goto 24
c
  222     continue
c
          endif
c
c 2.3. ==> Creation d'une nouvelle famille
c 2.3.1. ==> S'il n'y a plus de places, on sort et on recommencera
c            pour cette famille
c
          if ( nbfaen.ge.nbfae0-1 ) then
c
            numfam = lafami - 1
            nbfaen = -nbfaen
            goto 2999
c
c 2.3.2. ==> Creation
c
          else
c
c 2.3.2.1. ==> La famille avec les memes caracteristiques
c
            nbfaen = nbfaen + 1
cgn         write (ulsort,90002) '.. Creation de la famille', nbfaen
cgn         write (ulsort,90005) '.. avec',(caract(iaux),iaux=1,nctfen)
            do 2321 , iaux = 1 , nctfen
              cfaent(iaux,nbfaen) = caract(iaux)
 2321       continue
            nufaex = nbfaen
c
c 2.3.2.2. ==> Pour les aretes, la famille avec l'orientation inverse
c
            if ( typenh.eq.1 ) then
c
              if ( cfaent(coorfa,nbfaen).ne.0 ) then
c
                nbfaen = nbfaen + 1
cgn         write (ulsort,90015) '.. Creation de la famille', nbfaen,
cgn     >                        ' d''orientation opposee'
                do 2322 , iaux = 1 , nctfen
                  cfaent(iaux,nbfaen) = caract(iaux)
 2322           continue
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
c 2.4. ==> Enregistrement de la nouvelle famille pour la famille
c
   24     continue
c
          cfaent(cofxet,lafami) = nufaex
c
        endif
c
   20 continue
c
 2999 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'A la sortie de '//nompro//', nbfaen', nbfaen
      write (ulsort,*) 'Codes des familles des ',mess14(langue,3,typenh)
      do 6992 , iaux = 1 , abs(nbfaen)
        write(ulsort,90022) 'Famille', iaux,
     >                      (cfaent(jaux,iaux),jaux=1,nctfen)
 6992 continue
#endif
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
