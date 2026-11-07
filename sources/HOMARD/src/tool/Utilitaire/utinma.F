      subroutine utinma ( option, saux,
     >                      sdim,   mdim,  degre,
     >                    nbnoto, nbnop1, nbnop2, nbnoim,
     >                    nbnois, nbnomp,
     >                    nbnoei, nbmail,
     >                    nbmapo, nbsegm, nbtria, nbquad,
     >                    nbtetr, nbhexa, nbpyra, nbpent,
     >                    nbelig,
     >                    nbmane, nbmaae, nbmafe,
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
c    UTilitaire - INformation sur le MAillage
c    --           --                 --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option .  e  .    1   . option d'impressions                       .
c .        .     .        . 0 : tout                                   .
c .        .     .        . 1 : le minimum                             .
c . saux   .  e  .   *    . texte complementaire                       .
c . sdim   .  e  .   1    . dimension de l'espace                      .
c . mdim   .  e  .   1    . dimension du maillage                      .
c . degre  .  e  .   1    . degre du maillage                          .
c . nbnoto .  e  .   1    . nombre total de noeuds du maillage         .
c . nbnop1 .  e  .   1    . nombre de sommets du maillage (noeuds p1)  .
c . nbnop2 .  e  .   1    . nombre de noeuds milieux d'aretes du       .
c .        .     .        .  maillage (noeuds p2)                      .
c . nbnoim .  e  .   1    . nombre de noeuds internes aux mailles      .
c . nbnois .  e  .   1    . nombre de noeuds isoles                    .
c . nbnomp .  e  .   1    . nombre de noeuds support de maille-point   .
c .        .     .        . uniquement                                 .
c . nbnoei .  e  .   1    . nombre de noeuds d'elements ignores        .
c . nbmail .  e  .   1    . nombre de mailles dans le maillage         .
c . nbmapo .  e  .   1    . nombre de mailles-points dans le maillage  .
c . nbsegm .  e  .   1    . nombre de segments dans le maillage        .
c . nbtria .  e  .   1    . nombre de triangles dans le maillage       .
c . nbtetr .  e  .   1    . nombre de tetraedres dans le maillage      .
c . nbquad .  e  .   1    . nombre de quadrangles dans le maillage     .
c . nbhexa .  e  .   1    . nombre d'hexaedres dans le maillage        .
c . nbpent .  e  .   1    . nombre de pentaedres dans le maillage      .
c . nbpyra .  e  .   1    . nombre de pyramides dans le maillage       .
c . nbelig .  e  .   1    . nombre de mailles ignorees                 .
c . nbmane .  e  .   1    . nombre maximum de noeuds par element       .
c . nbmaae .  e  .   1    . nombre maximum d'aretes par element        .
c . nbmafe .  e  .   1    . nombre maximum de faces par element        .
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
      parameter ( nompro = 'UTINMA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
      integer sdim, mdim, degre
      integer nbnoto, nbnop1, nbnop2, nbnoim
      integer nbnois, nbnomp
      integer nbnoei
      integer nbmail
      integer nbmapo, nbsegm, nbtria, nbquad
      integer nbtetr, nbhexa, nbpyra, nbpent
      integer nbelig
      integer nbmane, nbmaae, nbmafe
c
      character*(*) saux
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 40 )
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
     > '(5x,''Caracteristiques du maillage '',a,/)'
      texte(1,5) =
     > '(8x,''Degre                                         :'',i11)'
      texte(1,6) =
     > '(8x,''Dimension de l''''espace                         :'',i11)'
      texte(1,7) =
     > '(8x,''Dimension du maillage                         :'',i11)'
      texte(1,11) =
     > '(8x,''Nombre de noeuds                              :'',i11)'
      texte(1,12) =
     > '(8x,''. dont noeuds isoles                          :'',i11)'
      texte(1,13) =
     > '(8x,''. dont noeuds maille-point uniquement         :'',i11)'
      texte(1,14) =
     > '(8x,''. dont noeuds sommets                         :'',i11)'
      texte(1,15) =
     > '(8x,''. dont noeuds milieux                         :'',i11)'
      texte(1,16) =
     > '(8x,''. dont noeuds internes aux mailles            :'',i11)'
      texte(1,21) =
     > '(8x,''Nombre de mailles                             :'',i11)'
      texte(1,22) =
     > '(8x,''. Mailles'',i2,''D'',34x,'':'',i11)'
      texte(1,23) =
     > '(8x,''. '',a14,30x,'':'',i11)'
      texte(1,24) =
     > '(10x,''. '',a14,28x,'':'',i11)'
      texte(1,31) =
     > '(8x,''Nombre maximum de faces par maille            :'',i11)'
      texte(1,32) =
     > '(8x,''Nombre maximum d''''aretes par maille            :'',i11)'
      texte(1,33) =
     > '(8x,''Nombre maximum de noeuds par maille           :'',i11)'
      texte(1,39) =
     > '(8x,''. dont noeuds de mailles ignorees uniquement  :'',i11)'
      texte(1,40) =
     > '(8x,''. Elimination de'',i11,1x,a14)'
c
      texte(2,4) =
     > '(5x,''Characteristics of the mesh '',a,/)'
      texte(2,5) =
     > '(8x,''Degree                                        :'',i11)'
      texte(2,6) =
     > '(8x,''Dimension of the space                        :'',i11)'
      texte(2,7) =
     > '(8x,''Dimension of the mesh                         :'',i11)'
      texte(2,11) =
     > '(8x,''Number of nodes                               :'',i11)'
      texte(2,12) =
     > '(8x,''. included isolated nodes                     :'',i11)'
      texte(2,13) =
     > '(8x,''. included only mesh-point nodes              :'',i11)'
      texte(2,14) =
     > '(8x,''. included nodes vertices                     :'',i11)'
      texte(2,15) =
     > '(8x,''. included nodes center of edges              :'',i11)'
      texte(2,16) =
     > '(8x,''. included internal nodes                     :'',i11)'
      texte(2,21) =
     > '(8x,''Number of meshes                              :'',i11)'
      texte(2,22) =
     > '(8x,''.'',i2,''D meshes'',35x,'':'',i11)'
      texte(2,23) =
     > '(8x,''. '',a14,30x,'':'',i11)'
      texte(2,24) =
     > '(10x,''. '',a14,28x,'':'',i11)'
      texte(2,31) =
     > '(8x,''Maximum number of faces per mesh              :'',i11)'
      texte(2,32) =
     > '(8x,''Maximum number of edges per mesh              :'',i11)'
      texte(2,33) =
     > '(8x,''Maximum number of nodes per mesh              :'',i11)'
      texte(2,39) =
     > '(8x,''. included only ignored meshes nodes          :'',i11)'
      texte(2,40) =
     > '(8x,''. Elimination of'',i11,1x,a14)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. impression
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. impression ; codret', codret
      call dmflsh(iaux)
#endif
c
      if ( codret.eq.0 ) then
c
      write(ulsort,texte(langue,4)) saux
      write(ulsort,texte(langue,6)) sdim
      write(ulsort,texte(langue,7)) mdim
      write(ulsort,texte(langue,5)) degre
c
c 2.1. ==> Les noeuds
c
      write(ulsort,texte(langue,11)) nbnoto
c
      if ( option.eq.0 ) then
c
        if ( nbnois.ne.0 ) then
          write(ulsort,texte(langue,12)) nbnois
        endif
        if ( nbnomp.ne.0 ) then
          write(ulsort,texte(langue,13)) nbnomp
        endif
        write(ulsort,texte(langue,14)) nbnop1
        if ( nbnop2.ne.0 ) then
          write(ulsort,texte(langue,15)) nbnop2
        endif
        if ( nbnoim.ne.0 ) then
          write(ulsort,texte(langue,16)) nbnoim
        endif
        if ( nbnoei.ne.0 ) then
          write(ulsort,texte(langue,39)) nbnoei
        endif
c
      endif
c
c 2.2. ==> Les mailles
c
      write(ulsort,texte(langue,21)) nbmail
c
c 2.2.1. ==> 0D
c
      if ( nbmapo.ne.0 ) then
        write(ulsort,texte(langue,23)) mess14(langue,4,0), nbmapo
      endif
c
c 2.2.2. ==> 1D
c
      if ( nbsegm.ne.0 ) then
        write(ulsort,texte(langue,23)) mess14(langue,4,1), nbsegm
      endif
c
c 2.2.3. ==> 2D
c
      iaux = nbtria + nbquad
c
      if ( iaux.eq.nbtria .or. iaux.eq.nbquad ) then
c
        if ( nbtria.ne.0 ) then
          write(ulsort,texte(langue,23)) mess14(langue,4,2), nbtria
        endif
        if ( nbquad.ne.0 ) then
          write(ulsort,texte(langue,23)) mess14(langue,4,4), nbquad
        endif
c
      else
c
        write(ulsort,texte(langue,22)) 2, iaux
        write(ulsort,texte(langue,24)) mess14(langue,3,2), nbtria
        write(ulsort,texte(langue,24)) mess14(langue,3,4), nbquad
c
      endif
c
c 2.2.4. ==> 3D
c
      iaux = nbtetr + nbhexa + nbpyra + nbpent
c
      if ( iaux.eq.nbtetr .or. iaux.eq.nbhexa .or.
     >     iaux.eq.nbpyra .or. iaux.eq.nbpent ) then
c
        if ( nbtetr.ne.0 ) then
          write(ulsort,texte(langue,23)) mess14(langue,4,3), nbtetr
        endif
        if ( nbhexa.ne.0 ) then
          write(ulsort,texte(langue,23)) mess14(langue,4,6), nbhexa
        endif
        if ( nbpyra.ne.0 ) then
          write(ulsort,texte(langue,23)) mess14(langue,4,5), nbpyra
        endif
        if ( nbpent.ne.0 ) then
          write(ulsort,texte(langue,23)) mess14(langue,4,7), nbpent
        endif
c
      else
c
        write(ulsort,texte(langue,22)) 3, iaux
        if ( nbtetr.ne.0 ) then
          write(ulsort,texte(langue,24)) mess14(langue,3,3), nbtetr
        endif
        if ( nbhexa.ne.0 ) then
          write(ulsort,texte(langue,24)) mess14(langue,3,6), nbhexa
        endif
        if ( nbpyra.ne.0 ) then
          write(ulsort,texte(langue,24)) mess14(langue,3,5), nbpyra
        endif
        if ( nbpent.ne.0 ) then
          write(ulsort,texte(langue,24)) mess14(langue,3,7), nbpent
        endif
c
      endif
c
c 2.2.5. ==> Caracteristiques des mailles
c
      if ( option.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        if ( nbmafe.ge.0 ) then
#else
        if ( nbmafe.gt.0 ) then
#endif
          write(ulsort,texte(langue,31)) nbmafe
        endif
        write(ulsort,texte(langue,32)) nbmaae
        write(ulsort,texte(langue,33)) nbmane
c
      endif
c
c 2.2.6. ==> Mailles eliminees
c
      if ( option.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        if ( nbelig.ne.0 ) then
          write(ulsort,texte(langue,40)) nbelig, mess14(langue,3,5)
        endif
#endif
c
      endif
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
