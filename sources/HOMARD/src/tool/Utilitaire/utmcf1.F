      subroutine utmcf1 ( nbfran, casfre,
     >                    cacfpo, cacfta, casfnf,
     >                    nbfich,
     >                    nomref, lgnofi, poinno,
     >                    nomufi, nomstr,
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
c     UTilitaire : Mot-Cle - caracterisation des Frontieres - 1
c     --           -   -                         -            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfran . e   .    1   . nombre de frontieres analytiques           .
c . casfre .  s  .13nbfran. caracteristiques des frontieres analytiques.
c .        .     .        . 1 : 1., si cylindre                        .
c .        .     .        .     2., si sphere                          .
c .        .     .        .     3., si cone par  origine, axe et angle .
c .        .     .        .     4., si cone par 2 centres et 2 rayons  .
c .        .     .        .     5., si tore                            .
c .        .     .        . de 2 a 13 :                                .
c .        .     .        . . cylindre : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              8 :     rayon                 .
c .        .     .        . . sphere   : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              8 :     rayon                 .
c .        .     .        . . cone     : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              13 :    angle en degre        .
c .        .     .        . . cone 2   : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              8 :     rayon                 .
c .        .     .        .              9,10,11:xcent2, ycent2, zcent2.
c .        .     .        .              12 :    rayon2                .
c .        .     .        . . tore     : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              8 :     rayon de revolution   .
c .        .     .        .              12 :    rayon primaire        .
c . cacfpo .  s  .0:nbfran. pointeurs sur le tableau du nom frontieres .
c . cacfta .  s  .10nbfran. taille du nom des frontieres               .
c . casfnf .  s  .10nbfran. nom des frontieres                         .
c . nbfich . e   .    1   . nombre de fichiers                         .
c . nomref . e   . nbfich . nom de reference des fichiers              .
c . lgnofi . e   . nbfich . longueurs des noms des fichiers            .
c . poinno . e   .0:nbfich. pointeur dans le tableau des noms          .
c . nomufi . e   . lgtanf . noms des fichiers                          .
c . nomstr . e   . nbfich . nom des structures                         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme de lecture                    .
c .        .     .        . 3 : type inconnu                           .
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
      parameter ( nompro = 'UTMCF1' )
c
#include "nblang.h"
#include "motcle.h"
c
      integer nbmcle
      parameter ( nbmcle = 13 )
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbfran
      integer nbfich
      integer lgnofi(nbfich), poinno(0:nbfich)
      integer cacfpo(0:nbfran), cacfta(10*nbfran)
c
      character*8 nomref(nbfich), nomufi(*), nomstr(nbfich)
      character*8 casfnf(10*nbfran)
c
      double precision casfre(nbmcle,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nrfich
      integer nrfran, tyfran
      integer numero, nrmcle
c
      character*8 mclref(0:nbmcle)
      character*200 sau200
c
      logical mccode(0:nbmcle)
      logical mccod2(0:nbmcle)
c
      double precision daux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
      character*24 messag(nblang,5)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
c 1.1. ==> tout va bien
c
      codret = 0
c
c 1.2. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de frontiere(s) analytique(s) :'',i8)'
      texte(1,5) =
     > '(/,''Numero de la frontiere en cours de recherche :'',i8)'
      texte(1,6) = '(''Type de la frontiere : '',a)'
      texte(1,7) = '(''Le type '',i8,'' est inconnu.'')'
      texte(1,8) = '(''La valeur de '',a,'' est indecodable.'')'
c
      texte(2,4) = '(''Number of analytical boundarie(s):'',i8)'
      texte(2,5) = '(/,''Search for boundary #'',i8)'
      texte(2,6) = '(''Type of boundary: '',a)'
      texte(2,7) = '(''The type #'',i8,'' is unknown.'')'
      texte(2,8) = '(''The value for '',a,'' cannot be uncoded.'')'
c
#include "impr03.h"
c
c                    123456789012345678901234
      messag(1,1) = 'Cylindre                '
      messag(1,2) = 'Sphere                  '
      messag(1,3) = 'Cone                    '
      messag(1,4) = 'Cone                    '
      messag(1,5) = 'Tore                    '
c
      messag(2,1) = 'Cylindre                '
      messag(2,2) = 'Sphere                  '
      messag(2,3) = 'Cone                    '
      messag(2,4) = 'Cone                    '
      messag(2,5) = 'Torus                   '
c
c 1.3. ==> preliminaires
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbfran
#endif
      mclref( 0) = mcfanm
      mclref( 1) = mcfaty
      mclref( 2) = mcfaxc
      mclref( 3) = mcfayc
      mclref( 4) = mcfazc
      mclref( 5) = mcfaxa
      mclref( 6) = mcfaya
      mclref( 7) = mcfaza
      mclref( 8) = mcfara
      mclref( 9) = mcfax2
      mclref(10) = mcfay2
      mclref(11) = mcfaz2
      mclref(12) = mcfar2
      mclref(13) = mcfaan
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,93020) 'Mots-cles', mclref
#endif
c
      cacfpo(0) = 0
c
c====
c 2. on parcourt toutes les posssibilites de frontieres
c====
c
      do 20 , nrfran = 1 , nbfran
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) nrfran
#endif
c
c 2.0. ==> On n'a rien au debut
c
        do 201 , iaux = 0 , nbmcle
          mccode(iaux) = .false.
          mccod2(iaux) = .false.
  201   continue
c
        do 200 , nrfich = 1 , nbfich
c
c 2.1. ==> si c'est un des mots-cles possibles, on verifie si c'est
c          pour la bonne frontiere
c
          if ( codret.eq.0 ) then
c
          nrmcle = -1
          do 21 , iaux = 0 , nbmcle
            if ( nomref(nrfich).eq.mclref(iaux) ) then
              nrmcle = iaux
              goto 211
            endif
   21     continue
c
  211     continue
c
          if ( nrmcle.ge.0 ) then
c
            call utchen ( nomstr(nrfich), numero,
     >                    ulsort, langue, codret )
c
            if ( nrfran.ne.numero ) then
              goto 200
            endif
c
          else
c
            goto 200
c
          endif
c
c
          endif
c
c 2.2. ==> recherche de la valeur
c 2.2.1. ==> Mise sous forme de chaine de la 3eme donnee sur la ligne
c
          if ( codret.eq.0 ) then
c
          iaux = poinno(nrfich-1) + 1
          jaux = lgnofi(nrfich)
          call uts8ch ( nomufi(iaux), jaux, sau200,
     >                  ulsort, langue, codret )
c
          endif
c
c 2.2.2. ==> Conversions
c
          if ( codret.eq.0 ) then
c
c 2.2.2.1. ==> Stockage du nom de la frontiere
c
          if ( nrmcle.eq.0 ) then
c
            iaux = mod(lgnofi(nrfich),8)
            kaux = (lgnofi(nrfich) - iaux)/8
            if ( iaux.ne.0 ) then
              kaux = kaux + 1
            endif
            cacfpo(nrfran) = cacfpo(nrfran-1) + kaux
            jaux = 1
            do 2221 , iaux = 1 , kaux
              cacfta(cacfpo(nrfran-1)+iaux) = 8
              casfnf(cacfpo(nrfran-1)+iaux) = sau200(jaux:jaux+7)
              jaux = jaux + 8
 2221       continue
            iaux = mod(lgnofi(nrfich),8)
            if ( iaux.ne.0 ) then
              cacfta(cacfpo(nrfran)) = iaux
            endif
c
c 2.2.2.2. ==> Conversion du type : entier a decoder, puis reel
c
          elseif ( nrmcle.eq.1 ) then
c
            call utchen ( sau200, tyfran,
     >                    ulsort, langue, codret )
c
            casfre(nrmcle,nrfran) = dble(tyfran)
c
c 2.2.2.3. ==> Conversion des coordonnees : reel
c
          elseif ( nrmcle.ge.2 ) then
c
            call utchre ( sau200, daux,
     >                    ulsort, langue, codret )
            casfre(nrmcle,nrfran) = daux
cgn              write (ulsort,90004) '---'//mclref(nrmcle), daux
c
            if ( codret.ne.0 ) then
              write (ulsort,texte(langue,5)) nrfran
              write (ulsort,texte(langue,8)) mclref(nrmcle)
            endif
c
          endif
c
          endif
c
c 2.2.3. ==> Archivage
c
          if ( codret.eq.0 ) then
c
          mccode(nrmcle) = .true.
c
          endif
c
c 2.3. ==> si on a tout trouve, on passe a la frontiere suivante,
c          apres controle
c
          if ( codret.eq.0 ) then
c
          if ( mccode(1) ) then
c
            tyfran = nint(casfre(1,nrfran))
c
c 2.3.1. ==> Cas du cylindre
c
            if ( tyfran.eq.1 ) then
c
              if ( mccode(0) .and.
     >             mccode(2) .and. mccode(3) .and.
     >             mccode(4) .and. mccode(5) .and.
     >             mccode(6) .and. mccode(7) .and.
     >             mccode(8) ) then
#ifdef _DEBUG_HOMARD_
                write (ulsort,texte(langue,6)) messag(langue,tyfran)
                write (ulsort,90004) 'X centre', casfre(2,nrfran)
                write (ulsort,90004) 'Y centre', casfre(3,nrfran)
                write (ulsort,90004) 'Z centre', casfre(4,nrfran)
                write (ulsort,90004) 'X axe   ', casfre(5,nrfran)
                write (ulsort,90004) 'Y axe   ', casfre(6,nrfran)
                write (ulsort,90004) 'Z axe   ', casfre(7,nrfran)
                write (ulsort,90004) 'Rayon   ', casfre(8,nrfran)
#endif
c
                goto 20
c
              endif
c
c 2.3.2. ==> Cas de la sphere
c
            elseif ( tyfran.eq.2 ) then
c
              if ( mccode(0) .and.
     >             mccode(2) .and. mccode(3) .and.
     >             mccode(4) .and. mccode(8) ) then
#ifdef _DEBUG_HOMARD_
                write (ulsort,texte(langue,6)) messag(langue,tyfran)
                write (ulsort,90004) 'X centre', casfre(2,nrfran)
                write (ulsort,90004) 'Y centre', casfre(3,nrfran)
                write (ulsort,90004) 'Z centre', casfre(4,nrfran)
                write (ulsort,90004) 'Rayon   ', casfre(8,nrfran)
#endif
c
                goto 20
c
              endif
c
c 2.3.3. ==> Cas du cone defini par centre, axe et angle
c
            elseif ( tyfran.eq.3 ) then
c
              if ( mccode(0) .and.
     >             mccode( 2) .and. mccode( 3) .and.
     >             mccode( 4) .and.
     >             mccode( 5) .and. mccode( 6) .and.
     >             mccode( 7) .and. mccode(13) ) then
#ifdef _DEBUG_HOMARD_
                write (ulsort,texte(langue,6)) messag(langue,tyfran)
                write (ulsort,90004) 'X centre', casfre( 2,nrfran)
                write (ulsort,90004) 'Y centre', casfre( 3,nrfran)
                write (ulsort,90004) 'Z centre', casfre( 4,nrfran)
                write (ulsort,90004) 'X axe   ', casfre(5,nrfran)
                write (ulsort,90004) 'Y axe   ', casfre(6,nrfran)
                write (ulsort,90004) 'Z axe   ', casfre(7,nrfran)
                write (ulsort,90004) 'Angle   ', casfre(13,nrfran)
#endif
c
                goto 20
c
              endif
c
c 2.3.4. ==> Cas du cone defini par 2 centres et 2 rayons
c
            elseif ( tyfran.eq.4 ) then
c
              if ( mccode(0) .and.
     >             mccode( 2) .and. mccode( 3) .and.
     >             mccode( 4) .and. mccode( 8) .and.
     >             mccode( 9) .and. mccode(10) .and.
     >             mccode(11) .and. mccode(12) ) then
#ifdef _DEBUG_HOMARD_
                write (ulsort,texte(langue,6)) messag(langue,tyfran)
                write (ulsort,90004) 'X centre  ', casfre( 2,nrfran)
                write (ulsort,90004) 'Y centre  ', casfre( 3,nrfran)
                write (ulsort,90004) 'Z centre  ', casfre( 4,nrfran)
                write (ulsort,90004) 'Rayon     ', casfre( 8,nrfran)
                write (ulsort,90004) 'X centre 2', casfre( 9,nrfran)
                write (ulsort,90004) 'Y centre 2', casfre(10,nrfran)
                write (ulsort,90004) 'Z centre 2', casfre(11,nrfran)
                write (ulsort,90004) 'Rayon    2', casfre(12,nrfran)
#endif
c
                goto 20
c
              endif
c
c 2.3.5. ==> Cas du tore
c
            elseif ( tyfran.eq.5 ) then
c
              if ( mccode(0) .and.
     >             mccode( 2) .and. mccode( 3) .and.
     >             mccode( 4) .and.
     >             mccode( 5) .and. mccode( 6) .and.
     >             mccode( 7) .and.
     >             mccode( 8) .and. mccode(12) ) then
#ifdef _DEBUG_HOMARD_
                write (ulsort,texte(langue,6)) messag(langue,tyfran)
                write (ulsort,90004) 'X centre', casfre( 2,nrfran)
                write (ulsort,90004) 'Y centre', casfre( 3,nrfran)
                write (ulsort,90004) 'Z centre', casfre( 4,nrfran)
                write (ulsort,90004) 'X axe   ', casfre( 5,nrfran)
                write (ulsort,90004) 'Y axe   ', casfre( 6,nrfran)
                write (ulsort,90004) 'Z axe   ', casfre( 7,nrfran)
                write (ulsort,90004) 'R revolu', casfre( 8,nrfran)
                write (ulsort,90004) 'R primai', casfre(12,nrfran)
#endif
c
                goto 20
c
              endif
c
c 2.3.n. ==> Type inconnu
c
            else
              write (ulsort,texte(langue,7)) tyfran
              codret = 3
            endif
c
          endif
c
          endif
c
  200   continue
c
c 2.4. ==> si on arrive ici, c'est qu'il en manque pour la
c          frontiere courante
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,5)) nrfran
        write (ulsort,texte(langue,6)) messag(langue,tyfran)
        mccod2(1) = .true.
        if ( tyfran.eq.1 ) then
          do 241 , iaux = 2 , 8
            mccod2(iaux) = .true.
  241     continue
        elseif ( tyfran.eq.2 ) then
          do 242 , iaux = 2 , 4
            mccod2(iaux) = .true.
  242     continue
          mccod2(8) = .true.
        elseif ( tyfran.eq.3 ) then
          do 243 , iaux = 2 , 7
            mccod2(iaux) = .true.
  243     continue
          mccod2(13) = .true.
        elseif ( tyfran.eq.4 ) then
          do 2441 , iaux = 2 , 4
            mccod2(iaux) = .true.
 2441     continue
          do 2442 , iaux = 8 , 12
            mccod2(iaux) = .true.
 2442     continue
        elseif ( tyfran.eq.5 ) then
          do 2451 , iaux = 2 , 8
            mccod2(iaux) = .true.
 2451     continue
          mccod2(12) = .true.
        endif
#ifdef _DEBUG_HOMARD_
        write(ulsort,99002) 'mccod2', mccod2
        write(ulsort,99002) 'mccode', mccode
#endif
        do 24 , iaux = 0 , nbmcle
          if ( .not.mccode(iaux) .and. mccod2(iaux) ) then
            write (ulsort,texte(langue,8)) mclref(iaux)
          endif
   24   continue
c
        codret = 2
c
        endif
c
   20 continue
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
      call dmflsh(iaux)
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
