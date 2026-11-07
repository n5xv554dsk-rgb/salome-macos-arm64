      subroutine vcme30 ( numfam,
     >                    nbfar0,
     >                    nofaar, cofaar,
     >                    nbfnoe, cfanoe,
     >                    nbfare, cfaare,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 30
c     -                 -             -        -               --
c Determine les familles pour le lien face avant / face perpendiculaire
c au cours de l'extrusion des noeuds
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numfam . es  .    1   . numero de la derniere famille traitee      .
c . nbfar0 . e   .  1     . nombre de familles pour le dimensionnement .
c . nofaar . e   .  1     . nombre d'origine de familles d'aretes      .
c . cofaar . e   . ncffar*. codes d'origine des familles d'aretes      .
c .        .     . nofaar .                                            .
c . nbfnoe .  e  .  1     . nombre de familles de noeuds enregistrees  .
c . cfanoe . e   . nctfno*. codes des familles des noeuds              .
c .        .     . nbfnoe .   1 : famille MED                          .
c .        .     .        . si extrusion :                             .
c .        .     .        .   2 : famille du noeud extrude             .
c .        .     .        .   3 : famille de l'arete perpendiculaire   .
c .        .     .        .   4 : position du noeud                    .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nbfare .  es .  1     . nombre de familles d'aretes enregistrees   .
c . cfaare .  es . nctfar*. codes des familles des aretes              .
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
      parameter ( nompro = 'VCME30' )
c
#include "nblang.h"
#include "cofaar.h"
#include "cofexn.h"
#include "cofexa.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "dicfen.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer numfam
      integer nbfar0
      integer nofaar, cofaar(ncffar,nofaar)
      integer nbfnoe, cfanoe(nctfno,nbfnoe)
      integer nbfare, cfaare(nctfar,nbfar0)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lafami, famdeb, famarx
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
      write (ulsort,texte(langue,4)) mess14(langue,3,1)
      write (ulsort,90002) 'numfam', numfam
      write (ulsort,90002) 'nctfno', nctfno
      write (ulsort,90002) 'cofxnx', cofxnx
      write (ulsort,90002) 'nctfar', nctfar
      write (ulsort,90002) 'ncffar', ncffar
      write (ulsort,90002) 'ncffar', ncffar
      write (ulsort,90002) 'nofaar', nofaar
      write (ulsort,90002) 'nbfar0', nbfar0
      write (ulsort,90002) 'nbfnoe', nbfnoe
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Codes des familles des ',mess14(langue,3,1)
      do 5991 , iaux = 1 , nofaar
        write(ulsort,90012) 'Famille originale 3D', iaux,
     >                      (cofaar(jaux,iaux),jaux=1,ncffar)
 5991 continue
      do 5992 , iaux = 1 , nbfare
        write(ulsort,90022) 'Famille', iaux,
     >                      (cfaare(jaux,iaux),jaux=1,nctfar)
 5992 continue
      write (ulsort,*) 'Codes des familles des ',mess14(langue,3,-1)
      do 5993 , iaux = 1 , nbfnoe
        write(ulsort,90022) 'Famille', iaux,
     >                      (cfanoe(jaux,iaux),jaux=1,nctfno)
 5993 continue
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
      do 20 , lafami = famdeb, nbfnoe
c
        famarx = cfanoe(cofxnx,lafami)
        if ( famarx.ne.0 ) then
cgn      write (ulsort,90012)
cgn     > '. Famille de '//mess14(langue,1,-1), lafami
cgn      write (ulsort,90012)
cgn     > '. Famille de '//mess14(langue,1,1), famarx
c
c 2.1. ==> On veut une famille d'aretes :
c          . qui a les caracteristiques de celle du maillage 3D pour :
c          . les valeurs pour l'extrusion sont nulles
c          . la position doit etre perpendiculaire
c
c 2.1.1. ==> Les caracteristiques d'origine de la famille
c
          do 211 , iaux = 1 , ncffar
            caract(iaux) = cofaar(iaux,famarx)
  211     continue
c
c 2.1.2. ==> On complete par les proprietes de l'extrusion bidon
c
          do 212 , iaux = ncffar+1 , nctfar
            caract(iaux) = 0
  212     continue
c
c 2.1.3. ==> L'entite est perpendiculaire
c
          caract(cofxap) = 2
cgn      write (ulsort,90005) 'Caract.',(caract(iaux),iaux=1,nctfar)
c
c 2.2. ==> Recherche d'une situation analogue dans les familles,
c
          do 221 , iaux = 1 , nbfare
c
            do 2211 , jaux = 1 , ncffar
              if ( cfaare(jaux,iaux).ne.caract(jaux) ) then
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
          if ( nbfare.ge.nbfar0-1 ) then
c
            numfam = lafami - 1
            nbfare = -nbfare
            goto 2999
c
c 2.3.2. ==> Creation
c
          else
c
c 2.3.2.1. ==> La famille avec les memes caracteristiques
c
            nbfare = nbfare + 1
cgn         write (ulsort,90002) '.. Creation de la famille', nbfare
cgn         write (ulsort,90005) '.. avec',(caract(iaux),iaux=1,nctfar)
            do 2321 , iaux = 1 , nctfar
              cfaare(iaux,nbfare) = caract(iaux)
 2321       continue
            nufaex = nbfare
c
c 2.3.2.2. ==> La famille avec l'orientation inverse
c
            if ( cfaare(coorfa,nbfare).ne.0 ) then
c
              nbfare = nbfare + 1
cgn         write (ulsort,90015) '.. Creation de la famille', nbfare,
cgn     >                        ' d''orientation opposee'
c
              do 2322 , iaux = 1 , nctfar
                cfaare(iaux,nbfare) = caract(iaux)
 2322         continue
              cfaare(coorfa,nbfare) = -cfaare(coorfa,nbfare-1)
              cfaare(cofifa,nbfare  ) = nbfare-1
              cfaare(cofifa,nbfare-1) = nbfare
c
            else
c
              cfaare(cofifa,nbfare) = nbfare
c
            endif
c
          endif
c
c 2.4. ==> Enregistrement de la nouvelle famille pour la famille
c
   24     continue
c
          cfanoe(cofxnx,lafami) = nufaex
c
        endif
c
   20 continue
c
 2999 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'A la sortie de '//nompro//', nbfare', nbfare
      write (ulsort,*) 'Codes des familles des ',mess14(langue,3,1)
      do 6992 , iaux = 1 , abs(nbfare)
        write(ulsort,90022) 'Famille', iaux,
     >                      (cfaare(jaux,iaux),jaux=1,nctfar)
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
