      subroutine utecf0 ( maextr, typenh, nbento,
     >                    nbfaen, nbfcf1, nbfcf2,
     >                    nctfen, ncffen, ncxfen, ncefen,
     >                    fament, cfaent,
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
c    UTilitaire - ECriture des Codes de Familles d'entites - 0
c    --           -            -        -                    -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . maextr . e   .   1    . maillage extrude                           .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : selon X                                .
c .        .     .        . 2 : selon Y                                .
c .        .     .        . 3 : selon Z (cas de Saturne ou Neptune)    .
c . typenh . e   .    1   . type d'entites                             .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : segments                             .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   3 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nbento . e   .    1   . nombre d'entites                           .
c . nbfaen . e   .    1   . nombre de familles enregistrees            .
c . nbfcf1 . e   .    1   . nombre de familles pour la conformite - 1  .
c . nbfcf2 . e   .    1   . nombre de familles pour la conformite - 2  .
c . nctfen . e   .    1   . nombre total de caracteristiques familles  .
c . ncefen . e   .    1   . nombre de caracteristiques d'equivalence   .
c . ncffen . e   .    1   . nombre fige de caracteristiques            .
c . fament . e   . nbento . famille des entites                        .
c . cfaent . e   . nctfen*. codes des familles d'entites               .
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
c .        .     .        .   3 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c .        .     .        . si quadrangle :                            .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   3 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c .        .     .        . si tetraedre, hexaedre, pyramide, pentaedre.
c .        .     .        .   2 : type de mailles                      .
c .        .     .        . si hexaedre :                              .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   3 : famille des pyramides de conformite  .
c .        .     .        . si extrusion et noeud/arete/tria/quad :    .
c .        .     .        . n+1 : famille du noeud extrude             .
c .        .     .        . n+2 : famille de l'arete perpendiculaire   .
c .        .     .        . si extrusion et triangle ou quadrangle :   .
c .        .     .        . n+3 : code de la face dans le volume       .
c .        .     .        . si extrusion :                             .
c .        .     .        . n+3/4 : position de l'entite               .
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
      parameter ( nompro = 'UTECF0' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer maextr
      integer typenh, nbento
      integer nbfaen, nbfcf1, nbfcf2
      integer nctfen, ncffen, ncxfen, ncefen
      integer fament(nbento)
      integer cfaent(nctfen,nbfaen)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbmi01, nbmi21, nbmx20, nbmx40, nbmxxx
      integer iaux, jaux, kaux
      integer nbenfa
      integer lgstar(-1:7)
c
      character*80 saux80
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data lgstar / 33, 53, 93, 63, 43, 83, 43, 63, 63  /
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
     > '(/,5x,123(''-''),/,/,5x,''Description des familles des '',a)'
      texte(1,5) = '(5x,''Nombre de familles          : '',i8)'
      texte(1,6) = '(5x,''Nombre de codes par famille : '',i3)'
c
      texte(2,4) =
     > '(/,5x,123(''-''),/,/,5x,''Description of families of '',a)'
      texte(2,5) = '(5x,''Number of families        : '',i8)'
      texte(2,6) = '(5x,''Number of codes per family: '',i3)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. En tete
c====
c
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nbfaen
      write (ulsort,texte(langue,6)) nctfen
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nctfen, ncffen, ncxfen, ncefen',
     >                      nctfen, ncffen, ncxfen, ncefen
#endif
c
c====
c 3. Les familles
c====
c
      if ( nbfaen.gt.0 ) then
c
c 3.1. ==> les caracteristiques de base
c 3.1.1. ==> sans extrusion
c
        if ( maextr.eq.0 ) then
c
          if ( nbfcf1.eq.0 .and. nbfcf2.eq.0 ) then
            kaux = 2
          else
            kaux = 0
          endif
c
          if ( typenh.eq.-1 ) then
            write (ulsort,11001)
            write (ulsort,20090)
          elseif ( typenh.eq.0 ) then
            write (ulsort,11003)
            write (ulsort,30090)
          elseif ( typenh.eq.1 ) then
            write (ulsort,11007)
            write (ulsort,40090)
          elseif ( typenh.eq.2 ) then
            write (ulsort,11004)
            write (ulsort,50090)
          elseif ( typenh.eq.3 .or. typenh.eq.5 ) then
            write (ulsort,11002)
            write (ulsort,60090) mess14(1,3,typenh)(1:10)
          elseif ( typenh.eq.4 ) then
            write (ulsort,11006)
            write (ulsort,70090)
          elseif ( typenh.eq.6 .or. typenh.eq.7 ) then
            if ( nbfcf1.eq.0 .and. nbfcf2.eq.0 ) then
              write (ulsort,11002)
              write (ulsort,60090) mess14(1,3,typenh)(1:10)
              kaux = 2
            else
              write (ulsort,11004)
              write (ulsort,80090) mess14(1,3,typenh)(1:10)
            endif
          endif
c
          do 311, iaux = 1, nbfaen
c
            nbenfa = 0
            do 312, jaux = 1, nbento
              if ( fament(jaux).eq.iaux ) then
                nbenfa = nbenfa + 1
              endif
  312       continue
            if ( typenh.eq.-1 ) then
              write (ulsort,12001) iaux, nbenfa,
     >                             (cfaent(jaux,iaux),jaux=1,ncffen)
            elseif ( typenh.eq.0 ) then
              write (ulsort,12003) iaux, nbenfa,
     >                             (cfaent(jaux,iaux),jaux=1,ncffen)
            elseif ( typenh.eq.1 ) then
              write (ulsort,12007) iaux, nbenfa,
     >                             (cfaent(jaux,iaux),jaux=1,ncffen)
            elseif ( typenh.eq.2 ) then
              write (ulsort,12004) iaux, nbenfa,
     >                             (cfaent(jaux,iaux),jaux=1,ncffen)
            elseif ( typenh.eq.3 .or. typenh.eq.5 ) then
              write (ulsort,12002) iaux, nbenfa,
     >                             (cfaent(jaux,iaux),jaux=1,ncffen)
            elseif ( typenh.eq.4 ) then
              write (ulsort,12006) iaux, nbenfa,
     >                             (cfaent(jaux,iaux),jaux=1,ncffen)
            elseif ( typenh.eq.6 .or. typenh.eq.7 ) then
              if ( kaux.eq.0 ) then
                write (ulsort,12004) iaux, nbenfa,
     >                             (cfaent(jaux,iaux),jaux=1,ncffen)
              else
                write (ulsort,12002) iaux, nbenfa,
     >                           (cfaent(jaux,iaux),jaux=1,ncffen-kaux)
              endif
            endif
c
  311     continue
c
          if ( typenh.eq.6 .or. typenh.eq.7 ) then
            if ( kaux.ne.0 ) then
              kaux = -2
            endif
          endif
c
c 3.1.2. ==> avec extrusion
c            Remarque : ce sont seulement des noeuds, aretes,
c                       triangles, quadrangles
c
        else
c
          if ( typenh.eq.-1 ) then
            write (ulsort,11004)
            write (ulsort,20091)
            kaux = 3
          elseif ( typenh.eq.1 ) then
            write (ulsort,11010)
            write (ulsort,40091)
            kaux = 3
          elseif ( typenh.eq.2 ) then
            write (ulsort,11008)
            write (ulsort,50091)
            kaux = 4
          elseif ( typenh.eq.4 ) then
            write (ulsort,11010)
            write (ulsort,70091)
            kaux = 4
          elseif ( typenh.eq.6 ) then
            write (ulsort,11003)
            write (ulsort,80091) mess14(1,3,typenh)(1:10)
            kaux = 1
          elseif ( typenh.eq.7 ) then
            write (ulsort,11002)
            write (ulsort,60090) mess14(1,3,typenh)(1:10)
            kaux = 2
          endif
c
          do 313, iaux = 1, nbfaen
c
            nbenfa = 0
            do 314, jaux = 1, nbento
              if ( fament(jaux).eq.iaux ) then
                nbenfa = nbenfa + 1
              endif
  314       continue
            if ( typenh.eq.-1 ) then
              write (ulsort,12005) iaux, nbenfa,
     >                         (cfaent(jaux,iaux),jaux=1,ncffen+ncxfen)
            elseif ( typenh.eq.1 ) then
              write (ulsort,12010) iaux, nbenfa,
     >                         (cfaent(jaux,iaux),jaux=1,ncffen+ncxfen)
            elseif ( typenh.eq.2 ) then
              write (ulsort,12008) iaux, nbenfa,
     >                         (cfaent(jaux,iaux),jaux=1,ncffen+ncxfen)
            elseif ( typenh.eq.4 ) then
              write (ulsort,12010) iaux, nbenfa,
     >                         (cfaent(jaux,iaux),jaux=1,ncffen+ncxfen)
            elseif ( typenh.eq.6 ) then
              write (ulsort,12004) iaux, nbenfa,
     >                           (cfaent(jaux,iaux),jaux=1,ncffen-kaux)
            elseif ( typenh.eq.7 ) then
              write (ulsort,12004) iaux, nbenfa,
     >                           (cfaent(jaux,iaux),jaux=1,ncffen-kaux)
            endif
c
  313     continue
c
          if ( typenh.eq.6 ) then
            kaux = -1
          elseif ( typenh.eq.7 ) then
            kaux = -2
          endif
c
        endif
c
c 3.1.3. ==> Ligne finale du tableau
c
        saux80 = '(5x,   (''*''))'
        write(saux80(5:7),'(i3)') lgstar(typenh) + kaux*10
        write (ulsort,saux80)
c
c 3.2. ==> les eventuelles equivalences
c
        if ( ncefen.gt.0 ) then
c
          nbmi01 = ncffen +  1
          nbmi21 = nbmi01 + 20
          nbmx20 = ncffen + 20
          nbmx40 = nbmx20 + 20
          nbmxxx = nctfen
          write (ulsort,10020) (jaux,jaux=nbmi01,nbmx20)
          do 33, iaux = 1, nbfaen
            if ( ncefen.le.20 ) then
              write (ulsort,10091) iaux,
     >        (cfaent(jaux,iaux),jaux=nbmi01,nbmxxx),
     >        (-1,jaux=nbmxxx+1,nbmx20)
            else
              write (ulsort,10091) iaux,
     >        (cfaent(jaux,iaux),jaux=nbmi01,nbmx20)
              write (ulsort,10092) iaux,
     >        (cfaent(jaux,iaux),jaux=nbmi21,nbmxxx),
     >        (-1,jaux=nbmxxx+1,nbmx40)
            endif
   33     continue
          write (ulsort,10093)
c
        endif
c
      endif
c
c====
c 4. formats
c====
c
c formats communs
c ---------------
10020 format(
     >/,5x,74('*'),
     >/,5x,'* Num. code*',20i3,' *',
     >/,5x,74('*'),
     >/,5x,'* Num. de  *     Equivalence 0:non, 1:oui,',
     >     ' -1:equivalence non definie    *',
     >/,5x,'* Famille  *  1  2  3  3  5  6  7  8  9 10',
     >     ' 11 12 13 14 15 16 17 18 19 20 *',
     >/,5x,74('*'))
10091 format(
     >  5x,'*',i8,'  *',20i3,' *')
10092 format(
     >  5x,'*',8x,'  *',20i3,' *')
10093 format(
     >  5x,74('*'))
c
11001 format(
     >/,5x,33('*'),
     >/,5x,'* Numero du code :    *    1    *',
     >/,5x,33('*'))
11002 format(
     >/,5x,43('*'),
     >/,5x,'* Numero du code :    *    1    *    2    *'
     >/,5x,43('*'))
11003 format(
     >/,5x,53('*'),
     >/,5x,'* Numero du code :    *    1    *    2    *    3    *'
     >/,5x,53('*'))
11004 format(
     >/,5x,63('*'),
     >/,5x,'* Numero du code :    *    1    *    2    *    3    *',
     >     '    4    *',
     >/,5x,63('*'))
11006 format(
     >/,5x,83('*'),
     >/,5x,'* Numero du code :    *    1    *    2    *    3    *',
     >     '    4    *    5    *    6    *',
     >/,5x,83('*'))
11007 format(
     >/,5x,93('*'),
     >/,5x,'* Numero du code :    *    1    *    2    *    3    *',
     >     '    4    *    5    *    6    *    7    *',
     >/,5x,93('*'))
11008 format(
     >/,5x,103('*'),
     >/,5x,'* Numero du code :    *    1    *    2    *    3    *',
     >     '    4    *    5    *    6    *    7    *    8    *',
     >/,5x,103('*'))
11010 format(
     >/,5x,123('*'),
     >/,5x,'* Numero du code :    *    1    *    2    *    3    *',
     >     '    4    *    5    *    6    *    7    *    8    *',
     >     '    9    *   10    *',
     >/,5x,123('*'))
c
12001 format(
     >  5x,'*',i8,' *',i10,   ' *',i8 ,' *')
12002 format(
     >  5x,'*',i8,' *',i10, 2(' *',i8),' *')
12003 format(
     >  5x,'*',i8,' *',i10, 3(' *',i8),' *')
12004 format(
     >  5x,'*',i8,' *',i10, 4(' *',i8),' *')
12005 format(
     >  5x,'*',i8,' *',i10, 5(' *',i8),' *')
12006 format(
     >  5x,'*',i8,' *',i10, 6(' *',i8),' *')
12007 format(
     >  5x,'*',i8,' *',i10, 7(' *',i8),' *')
12008 format(
     >  5x,'*',i8,' *',i10, 8(' *',i8),' *')
12010 format(
     >  5x,'*',i8,' *',i10,10(' *',i8),' *')
c
c formats pour les familles de noeuds
c -----------------------------------
20090 format(
     >  5x,'* Num. de *  Nombre   * Famille *',
     >/,5x,'* Famille * de noeuds *   MED   *',
     >/,5x,33('*'))
20091 format(
     >  5x,'* Num. de *  Nombre   * Famille * Famille * Famille *',
     >     ' Position*',
     >/,5x,'* Famille * de noeuds *   MED   *no. tran.*ligne ex.*',
     >     '         *',
     >/,5x,63('*'))
c
c formats pour les familles de mailles-points
c -------------------------------------------
30090 format(
     >  5x,'* Num. de *  Nombre   * Famille *  Type   * Famille *'
     >/,5x,'* Famille * ma.points *   MED   *         * sommets *',
     >/,5x,53('*'))
c
c formats pour les familles d'aretes
c ----------------------------------
40090 format(
     >  5x,'* Num. de *  Nombre   * Famille *  Type   * Orient. *',
     >     ' Famille *  Numero * Famille *  Numero *',
     >/,5x,'* Famille * d''aretes  *   MED   *         *         *',
     >     ' or. inv * ligne fr*front ina* surf. fr*',
     >/,5x,93('*'))
40091 format(
     >  5x,'* Num. de *  Nombre   * Famille *  Type   * Orient. *',
     >     ' Famille *  Numero * Famille *  Numero *',
     >     ' Famille * Famille * Position*',
     >/,5x,'* Famille * d''aretes  *   MED   *         *         *',
     >     ' or. inv * ligne fr*front ina* surf. fr*',
     >     'ar. tran.* quad ex.*         *',
     >/,5x,123('*'))
c
c formats pour les familles de triangles
c --------------------------------------
50090 format(
     >  5x,'* Num. de *  Nombre   * Famille *  Type   *  Numero *',
     >     ' Fa. aret*',
     >/,5x,'* Famille * triangles *   MED   *         *  surface*',
     >     ' surface *',
     >/,5x,63('*'))
50091 format(
     >  5x,'* Num. de *  Nombre   * Famille *  Type   *  Numero *',
     >     ' Fa. aret*',
     >     ' Famille * Famille *  Code   * Position*',
     >/,5x,'* Famille * triangles *   MED   *         *  surface*',
     >     ' surface *',
     >     'tr. tran.* pent ex.*tria/pent*         *',
     >/,5x,103('*'))
c
c formats pour les familles de tetraedres, pyramides
c --------------------------------------------------
60090 format(
     >  5x,'* Num. de *  Nombre   * Famille *  Type   *',
     >/,5x,'* Famille * ',a10,   '*   MED   *         *',
     >/,5x,43('*'))
c
c formats pour les familles de quadrangles
c ----------------------------------------
70090 format(
     >  5x,'* Num. de *  Nombre   * Famille *  Type   *  Numero *',
     >     ' Fa. aret* Fa. tria* Famille *',
     >/,5x,'* Famille * de quads. *   MED   *         *  surface*',
     >     ' surface * confor. *front ina*',
     >/,5x,83('*'))
70091 format(
     >  5x,'* Num. de *  Nombre   * Famille *  Type   *  Numero *',
     >     ' Fa. aret* Fa. tria* Famille *',
     >     ' Fa. q tr* Fa. h ex*  Code   * Position*',
     >/,5x,'* Famille *   quads.  *   MED   *         *  surface*',
     >     ' surface * confor. *front ina*',
     >     '/normale1*/normale2*quad h/p *         *',
     >/,5x,123('*'))
c
c formats pour les familles d'hexaedres, pentaedres
c -------------------------------------------------
80090 format(
     >  5x,'* Num. de *  Nombre   * Famille *  Type   * Famille *',
     >     ' Famille *',
     >/,5x,'* Famille * ',a10,   '*   MED   *         *  tetr.  *',
     >     '  pyra.  *',
     >/,5x,63('*'))
80091 format(
     >  5x,'* Num. de *  Nombre   * Famille *  Type   * Famille *',
     >/,5x,'* Famille * ',a10,   '*   MED   *         *  pent.  *',
     >/,5x,53('*'))
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
