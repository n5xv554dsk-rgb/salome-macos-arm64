      subroutine utmcf2 ( nbfrgr,
     >                    calfpo, calfta, calfnm,
     >                    calgpo, calgta, calgnm,
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
c     UTilitaire : Mot-Cle - caracterisation des Frontieres - 2
c     --           -   -                         -            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfrgr . e   .    1   . nombre de liens frontieres/groupes         .
c . calfpo .  s  .0:nbfrgr. pointeurs sur le tableau du nom frontieres .
c . calfta .  s  .10nbfrgr. taille du nom des frontieres               .
c . calfnm .  s  .10nbfrgr. nom des frontieres                         .
c . calgpo .  s  .0:nbfrgr. pointeurs sur le tableau du nom groupes    .
c . calgta .  s  .10nbfrgr. taille du nom des groupes                  .
c . calgnm .  s  .10nbfrgr. nom des groupes                            .
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
      parameter ( nompro = 'UTMCF2' )
c
#include "nblang.h"
#include "motcle.h"
c
      integer nbmcle
      parameter ( nbmcle = 1 )
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbfrgr
      integer nbfich
      integer lgnofi(nbfich), poinno(0:nbfich)
      integer calfpo(0:nbfrgr), calfta(10*nbfrgr)
      integer calgpo(0:nbfrgr), calgta(10*nbfrgr)
c
      character*8 calfnm(10*nbfrgr)
      character*8 calgnm(10*nbfrgr)
      character*8 nomref(nbfich), nomufi(*), nomstr(nbfich)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nrfich
      integer nrfrgr
      integer numero, nrmcle
c
      character*8 mclref(0:nbmcle)
      character*200 sau200
c
      logical mccode(0:nbmcle)
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
      texte(1,4) = '(''Nombre de lien(s) frontiere/groupe :'',i8)'
      texte(1,5) =
     > '(''Numero du lien en cours de recherche :'',i8)'
      texte(1,8) = '(''La valeur de '',a,'' est indecodable.'')'
c
      texte(2,4) = '(''Number of link(s) boundary/group:'',i8)'
      texte(2,5) = '(''Search for link #'',i8)'
      texte(2,8) = '(''The value for '',a,'' cannot be uncoded.'')'
c
c 1.3. ==> preliminaires
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbfrgr
#endif
      mclref( 0) = mcfgfr
      mclref( 1) = mcfggr
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) mclref
#endif
c
      calfpo(0) = 0
      calgpo(0) = 0
c
c====
c 2. on parcourt toutes les posssibilites de liens
c====
c
      do 20 , nrfrgr = 1 , nbfrgr
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nrfrgr
#endif
c
c 2.0. ==> On n'a rien au debut
c
        do 201 , iaux = 0 , nbmcle
          mccode(iaux) = .false.
  201   continue
c
        do 200 , nrfich = 1 , nbfich
c
c 2.1. ==> si c'est un des mots-cles possibles, on verifie si c'est
c          pour le bon lien
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
            if ( nrfrgr.ne.numero ) then
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) sau200
#endif
          endif
c
c 2.2.2. ==> Conversions
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'nrmcle =', nrmcle
#endif
c
c 2.2.2.1. ==> Stockage du nom de la frontiere
c
          if ( nrmcle.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Stockage du nom de la frontiere'
#endif
c
            iaux = mod(lgnofi(nrfich),8)
            kaux = (lgnofi(nrfich) - iaux)/8
            if ( iaux.ne.0 ) then
              kaux = kaux + 1
            endif
            calfpo(nrfrgr) = calfpo(nrfrgr-1) + kaux
            jaux = 1
            do 2221 , iaux = 1 , kaux
              calfta(calfpo(nrfrgr-1)+iaux) = 8
              calfnm(calfpo(nrfrgr-1)+iaux) = sau200(jaux:jaux+7)
              jaux = jaux + 8
 2221       continue
            iaux = mod(lgnofi(nrfich),8)
            if ( iaux.ne.0 ) then
              calfta(calfpo(nrfrgr)) = iaux
            endif
c
c 2.2.2.2. ==> Stockage du nom du groupe
c
          else
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Stockage du nom du groupe'
#endif
c
            iaux = mod(lgnofi(nrfich),8)
            kaux = (lgnofi(nrfich) - iaux)/8
            if ( iaux.ne.0 ) then
              kaux = kaux + 1
            endif
            calgpo(nrfrgr) = calgpo(nrfrgr-1) + kaux
            jaux = 1
            do 2222 , iaux = 1 , kaux
              calgta(calgpo(nrfrgr-1)+iaux) = 8
              calgnm(calgpo(nrfrgr-1)+iaux) = sau200(jaux:jaux+7)
              jaux = jaux + 8
 2222       continue
            iaux = mod(lgnofi(nrfich),8)
            if ( iaux.ne.0 ) then
              calgta(calgpo(nrfrgr)) = iaux
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
          if ( mccode(0) .and. mccode(1) ) then
c
            goto 20
c
          endif
c
          endif
c
c
  200   continue
c
c 2.4. ==> si on arrive ici, c'est qu'il en manque pour la
c          frontiere courante
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,5)) nrfrgr
        do 24 , iaux = 0 , nbmcle
          if ( .not.mccode(iaux) ) then
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
