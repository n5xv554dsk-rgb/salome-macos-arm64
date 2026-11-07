      subroutine utmcz0 ( nbzord, cazord,
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
c     UTilitaire : Mot-Cle - caracterisation des Zones a Raffiner - 0
c     --           -   -               -                            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbzord . es  .    1   . nombre de zones a raffiner/deraffiner      .
c .        .     .        . si negatif, les zones sont 2D (en x et y)  .
c . cazord .  s  .  20 *  . caracteristiques zone a raffiner/deraffiner.
c .        .     . nbzord . 1 : >0 si a raffiner, <0 si a deraffiner   .
c .        .     .        . . si rectangle :                           .
c .        .     .        . 1 : +-1                                    .
c .        .     .        . de 2 a 5 : xmin, xmax, ymin, ymax          .
c .        .     .        . . si parallelepipede :                     .
c .        .     .        . 1 : +-2                                    .
c .        .     .        . de 2 a 7 : xmin, xmax, ymin, ymax          .
c .        .     .        .            zmin, zmax                      .
c .        .     .        . . si disque :                              .
c .        .     .        . 1 : +-3                                    .
c .        .     .        . de  8 a 10 : rayon, xcentr, ycentr         .
c .        .     .        . . si sphere :                              .
c .        .     .        . 1 : +-4                                    .
c .        .     .        . de  8 a 11 : rayon, xcentr, ycentr, zcentr .
c .        .     .        . . si cylindre :                            .
c .        .     .        . 1 : +-5                                    .
c .        .     .        . 8          : rayon                         .
c .        .     .        . de 12 a 14 : xaxe, yaxe, zaxe              .
c .        .     .        . de 15 a 17 : xbase, ybase, zbase           .
c .        .     .        . 18         : hauteur                       .
c .        .     .        . . si disque perce :                        .
c .        .     .        . 1 : +-6                                    .
c .        .     .        . de  9 a 10 : xcentr, ycentr                .
c .        .     .        . 19         : rayon interieur               .
c .        .     .        . 20         : rayon exterieur               .
c .        .     .        . . si tuyau :                               .
c .        .     .        . 1 : +-7                                    .
c .        .     .        . de 12 a 14 : xaxe, yaxe, zaxe              .
c .        .     .        . de 15 a 17 : xbase, ybase, zbase           .
c .        .     .        . 18         : hauteur                       .
c .        .     .        . 19         : rayon interieur               .
c .        .     .        . 20         : rayon exterieur               .
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
      parameter ( nompro = 'UTMCZ0' )
c
#include "nblang.h"
#include "motcle.h"
c
      integer nbmcle
      parameter ( nbmcle = 20 )
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbzord
      integer nbfich
      integer lgnofi(nbfich), poinno(0:nbfich)
c
      character*8 nomref(nbfich), nomufi(*), nomstr(nbfich)
c
      double precision cazord(nbmcle,nbzord)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nrfich
      integer nrzord, tyzord, tyzosi
      integer numero, nrmcle
c
      character*8 mclref(nbmcle)
      character*200 sau200
c
      logical mccode(nbmcle)
      logical mccod2(nbmcle)
c
      double precision daux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
      character*13 messag(nblang,7)
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
      texte(1,4) = '(''Nombre de zones a raffiner :'',i8)'
      texte(1,5) = '(''Numero de la zone en cours de recherche :'',i8)'
      texte(1,6) = '(''Type de la zone : '',a)'
      texte(1,7) = '(''Le type '',i8,'' est inconnu.'')'
      texte(1,8) = '(''La valeur de '',a,'' est indecodable.'')'
c
      texte(2,4) = '(''Number of zones to refine :'',i8)'
      texte(2,5) = '(''Search for zone #'',i8)'
      texte(2,6) = '(''Type of zone : '',a)'
      texte(2,7) = '(''The type #'',i8,'' is unknown.'')'
      texte(2,8) = '(''The value for '',a,'' cannot be uncoded.'')'
c
c                    1234567890123
      messag(1,1) = 'Rectangle    '
      messag(1,2) = 'Parallepipede'
      messag(1,3) = 'Disque       '
      messag(1,4) = 'Sphere       '
      messag(1,5) = 'Cylindre     '
      messag(1,6) = 'Disque perce '
      messag(1,7) = 'Tuyau        '
c
      messag(2,1) = 'Rectangle    '
      messag(2,2) = 'Parallepiped '
      messag(2,3) = 'Disk         '
      messag(2,4) = 'Sphere       '
      messag(2,5) = 'Cylindre     '
      messag(2,6) = 'Disk         '
      messag(2,7) = 'Pipe         '
c
c 1.3. ==> preliminaires
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbzord
#endif
      mclref( 1) = mczrty
      mclref( 2) = mcrxmi
      mclref( 3) = mcrxma
      mclref( 4) = mcrymi
      mclref( 5) = mcryma
      mclref( 6) = mcrzmi
      mclref( 7) = mcrzma
      mclref( 8) = mcrray
      mclref( 9) = mcrxce
      mclref(10) = mcryce
      mclref(11) = mcrzce
      mclref(12) = mcrxax
      mclref(13) = mcryax
      mclref(14) = mcrzax
      mclref(15) = mcrxba
      mclref(16) = mcryba
      mclref(17) = mcrzba
      mclref(18) = mcrhau
      mclref(19) = mcrrai
      mclref(20) = mcrrae
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) mclref
#endif
c
c====
c 2. on parcourt toutes les posssibilites de zones de raffinement
c====
c
      do 20 , nrzord = 1 , nbzord
c
c 2.0. ==> On n'a rien au debut
c
        do 201 , iaux = 1 , nbmcle
          mccode(iaux) = .false.
  201   continue
c
        do 200 , nrfich = 1 , nbfich
c
c 2.1. ==> si c'est un des mots-cles possibles, on verifie si c'est
c          pour la bonne zone
c
          if ( codret.eq.0 ) then
c
cgn      write(ulsort,*) nomref(nrfich)
          nrmcle = -1
          do 21 , iaux = 1 , nbmcle
cgn      write(ulsort,*) 'mclref(',iaux,') =', mclref(iaux)
            if ( nomref(nrfich).eq.mclref(iaux) ) then
              nrmcle = iaux
cgn      write(ulsort,*) '==> nrmcle =',iaux
              goto 211
            endif
   21     continue
c
  211     continue
c
          if ( nrmcle.ge.1 ) then
c
            call utchen ( nomstr(nrfich), numero,
     >                    ulsort, langue, codret )
c
            if ( nrzord.ne.numero ) then
              goto 200
            endif
c
          else
c
            goto 200
c
          endif
c
          endif
c
c 2.2. ==> Recherche de la valeur
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
cgn      write(ulsort,*) 'nrmcle =',nrmcle,nomufi(iaux),
cgn     >'sau200 = ',sau200
c
c 2.2.2. ==> Conversions
c
          if ( codret.eq.0 ) then
c
c 2.2.2.1. ==> Conversion du type : entier a decoder, puis reel
c
          if ( nrmcle.eq.1 ) then
c
            call utchen ( sau200, tyzord,
     >                    ulsort, langue, codret )
c
            cazord(nrmcle,nrzord) = dble(tyzord)
            if ( tyzord.gt.0 ) then
              tyzosi = 1
            else
              tyzosi = -1
            endif
            tyzord = abs(tyzord)
c
c 2.2.2.2. ==> Conversion des coordonnees : reel
c
          elseif ( nrmcle.ge.2 ) then
c
            call utchre ( sau200, daux,
     >                    ulsort, langue, codret )
            cazord(nrmcle,nrzord) = daux
c
            if ( codret.ne.0 ) then
              write (ulsort,texte(langue,5)) nrzord
              write (ulsort,texte(langue,8)) mclref(nrmcle)
            endif
c
          endif
c
          endif
c
c 2.2.3. ==> Memorisation du passage par le mot-cle
c
          if ( codret.eq.0 ) then
c
          mccode(nrmcle) = .true.
c
          endif
c
c 2.3. ==> Controle ; si on a tout trouve, on passe a la zone suivante
c
          if ( codret.eq.0 ) then
c
          if ( mccode(1) ) then
c
c 2.3.1. ==> Cas du rectangle
c
            if ( tyzord.eq.1 ) then
c
              if ( mccode(2) .and. mccode(3) .and.
     >             mccode(4) .and. mccode(5) ) then
c
                goto 20
c
              endif
c
c 2.3.2. ==> Cas du parallelepipede
c
            elseif ( tyzord.eq.2 ) then
c
              if ( mccode(2) .and. mccode(3) .and.
     >             mccode(4) .and. mccode(5) .and.
     >             mccode(6) .and. mccode(7) ) then
c
                goto 20
c
              endif
c
c 2.3.3. ==> Cas du disque
c
            elseif ( tyzord.eq.3 ) then
c
              if ( mccode( 8) .and. mccode( 9) .and.
     >             mccode(10) ) then
c
                goto 20
c
              endif
c
c 2.3.4. ==> Cas de la sphere
c
            elseif ( tyzord.eq.4 ) then
c
              if ( mccode( 8) .and. mccode( 9) .and.
     >             mccode(10) .and. mccode(11) ) then
c
                goto 20
c
              endif
c
c 2.3.5. ==> Cas du cylindre
c
            elseif ( tyzord.eq.5 ) then
c
              if ( mccode( 8) .and.
     >             mccode(12) .and. mccode(13) .and.
     >             mccode(14) .and. mccode(15) .and.
     >             mccode(16) .and. mccode(17) .and.
     >             mccode(18) ) then
c
                goto 20
c
              endif
c
c 2.3.6. ==> Cas du disque perce
c
            elseif ( tyzord.eq.6 ) then
c
              if ( mccode( 9) .and. mccode(10) .and.
     >             mccode(19) .and. mccode(20) ) then
c
                goto 20
c
              endif
c
c 2.3.7. ==> Cas du tuyau
c
            elseif ( tyzord.eq.7 ) then
c
              if ( mccode(12) .and. mccode(13) .and.
     >             mccode(14) .and. mccode(15) .and.
     >             mccode(16) .and. mccode(17) .and.
     >             mccode(18) .and. mccode(19) .and.
     >             mccode(20) ) then
c
                goto 20
c
              endif
c
c 2.3.n. ==> Type inconnu
c
            else
              write (ulsort,texte(langue,7)) tyzord*tyzosi
              codret = 3
            endif
c
          endif
c
          endif
c
  200   continue
c
c 2.4. ==> si on arrive ici, c'est qu'il en manque pour la zone courante
c
        if ( codret.eq.0 ) then
c
        do 240 , iaux = 1 , nbmcle
          mccod2(iaux) = .false.
  240   continue
c
        write (ulsort,texte(langue,5)) nrzord
        write (ulsort,texte(langue,6)) messag(langue,tyzord)
        if ( tyzord.eq.1 ) then
          do 241 , iaux = 2 , 5
            mccod2(iaux) = .true.
  241     continue
        elseif ( tyzord.eq.2 ) then
          do 242 , iaux = 2 , 7
            mccod2(iaux) = .true.
  242     continue
        elseif ( tyzord.eq.3 ) then
          do 243 , iaux = 8 , 10
            mccod2(iaux) = .true.
  243     continue
        elseif ( tyzord.eq.4 ) then
          do 244 , iaux = 8 , 11
            mccod2(iaux) = .true.
  244     continue
        elseif ( tyzord.ge.5 ) then
          mccod2(8) = .true.
          do 245 , iaux = 12 , 18
            mccod2(iaux) = .true.
  245     continue
        elseif ( tyzord.eq.6 ) then
          do 246 , iaux = 8 , 10
            mccod2(iaux) = .true.
  246     continue
          mccod2(19) = .true.
        elseif ( tyzord.eq.7 ) then
          mccod2(8) = .true.
          do 248 , iaux = 12 , 19
            mccod2(iaux) = .true.
  248     continue
        endif
        do 24 , iaux = 2 , nbmcle
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
