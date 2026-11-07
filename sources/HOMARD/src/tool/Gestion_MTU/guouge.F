      subroutine guouge ( fichie, lfichi, statfi, lgenre,
     >                    nuroul, codret )
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
c but : programme generique d'ouverture d'un fichier
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . fichie . e   . ch<200 . nom du fichier a ouvrir                    .
c . lfichi . e   .    1   . longueur du nom du fichier a ouvrir        .
c . statfi . e   .    1   . statut voulu pour l'ouverture              .
c .        .     .        . 3 : ouvert en form/sequ                    .
c .        .     .        . 4 : ouvert en bina/sequ                    .
c . lgenre . e   .    1   . longueur d'enregistrement si acces direct  .
c . nuroul .  s  .    1   . numero de l'unite logique attribuee        .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme d'ouverture du fichier        .
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
      parameter ( nompro = 'GUOUGE' )
c
#ifdef _DEBUG_HOMARD_
#include "genbla.h"
#endif
c
#include "gunbul.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer lfichi, statfi, lgenre
      integer nuroul
c
      character*(*) fichie
c
      integer codret
c
c 0.4. ==> variables locales
c
#include "gulggt.h"
c
      integer ulsort
      integer typarr
      integer iaux, deb, fin, lficlo
c
      integer guimp, raison
      integer i, code
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
c
      character*200 nomfic(mbmxul)
      character*200 ficloc
      character*6 nompra
c
#ifdef _DEBUG_HOMARD_
      integer langue
c
      integer nbmess
      parameter ( nbmess = 3 )
      character*80 texte(nblang,nbmess)
#endif
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c===
c 1. recuperation de l'information
c===
c
#ifdef _DEBUG_HOMARD_
#include "impr01.h"
#endif
c
      code = 1
      call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
      ulsort = gunmbr(16)
#ifdef _DEBUG_HOMARD_
      langue = gunmbr(17)
#endif
      typarr = gunmbr(18)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 2. verifications
c====
c
      codret = 0
      nuroul = 0
      ficloc = ' '
c
c 2.1. ==> type d'ouverture
c
      if ( statfi.eq.3 ) then
        nompra = 'GUOUFS'
      elseif ( statfi.eq.4 ) then
        nompra = 'GUOUBS'
      elseif ( statfi.eq.5 ) then
        nompra = 'GUOUBD'
      else
        write(ulsort,11000) '?     '
        if (len(fichie).gt.0) then
        write(ulsort,21000) nuroul,fichie(1:min(200,len(fichie))),statfi
        else
        write(ulsort,*) ' statfi = ',statfi,
     >                  ' (devrait etre entre 3 et 5)'
        endif
        if ( typarr.eq.0 ) then
          guimp = 1
          raison = 1
          call gustop ( nompro, ulsort, guimp, raison )
        else
          codret = 3
        endif
      endif
c
c 2.2. ==> longueur du nom du fichier
c
      if ( codret.eq.0 ) then
c
        iaux = len ( fichie )
c
        if ( lfichi.gt.iaux ) then
          write(ulsort,11000) nompra
          if ( iaux.gt.0 ) then
            write(ulsort,22000) fichie(1:min(200,iaux)), lfichi, iaux
          endif
          if ( typarr.eq.0 ) then
            guimp = 1
            raison = 1
            call gustop ( nompro, ulsort, guimp, raison )
          else
            codret = 3
          endif
        else
          deb = max(0,lfichi)+1
          do 221 i = 1, lfichi
            if (fichie(i:i).ne.' ') then
              deb = i
              goto 222
            endif
  221     continue
  222     continue
          fin = deb-1
          do 223 i = lfichi, deb, -1
            if (fichie(i:i).ne.' ') then
              fin = i
              goto 224
            endif
  223     continue
  224     continue
          lficlo = fin-deb+1
        endif
c
      endif
c
      if ( codret.eq.0 ) then
c
        if ( lficlo.le.0 .or. lficlo.gt.200 ) then
          write(ulsort,11000) nompra
          if ( iaux.gt.0 ) then
          write(ulsort,23000) fichie(1:min(200,len(fichie))), lfichi
          endif
          if ( typarr.eq.0 ) then
            guimp = 1
            raison = 1
            call gustop ( nompro, ulsort, guimp, raison )
          else
            codret = 3
          endif
        endif
c
      endif
c
c 2.3. ==> nom du fichier
c
      if ( codret.eq.0 ) then
c
        ficloc(1:lficlo) = fichie(deb:fin)
        do 23, i = lficlo+1, 200
           ficloc(i:i) = ' '
   23   continue
c
      endif
c
c 2.4. ==> est-ce que ce fichier n'est pas deja ouvert ?
c
      if ( codret.eq.0 ) then
c
        nuroul = 0
c
        do 241, i = 1, mbmxul
c
          if ( statut(i).ge.1 .and. statut(i).le.5 ) then
            if ( lnomfi(i).eq.lficlo ) then
              if ( nomfic(i)(1:lficlo).eq.ficloc(1:lficlo) ) then
                nuroul = i
                goto 242
              endif
            endif
          endif
c
  241   continue
c
  242   continue
c
        if ( nuroul.ne.0 ) then
          write(ulsort,11000) nompra
          write(ulsort,24000) ficloc, nuroul
          if ( typarr.eq.0 ) then
            guimp = 1
            raison = 1
            call gustop ( nompro, ulsort, guimp, raison )
          else
            codret = 3
          endif
        endif
c
      endif
c
c 2.5. ==> recherche de la premiere unite libre
c
      if ( codret.eq.0 ) then
c
        do 251, i = 1, mbmxul
          if ( statut(i).eq.0 ) then
            nuroul = i
            goto 252
          endif
  251   continue
c
        write(ulsort,11000) nompra
        write(ulsort,25000) ficloc
        if ( typarr.eq.0 ) then
          guimp = 1
          raison = 1
          call gustop ( nompro, ulsort, guimp, raison )
        else
          codret = 3
        endif
c
  252   continue
c
      endif
c
c====
c 3. tout est bon, on peut ouvrir
c====
c
      if ( codret.eq.0 ) then
c
        if ( statfi.eq.3 ) then
c
          call dmoufs ( nuroul, ficloc, lficlo, ulsort, codret )
c
        elseif ( statfi.eq.4 ) then
c
          call dmoubs ( nuroul, ficloc, lficlo, ulsort, codret )
c
        endif
c
       if (codret.ne.0) then
         write(ulsort,11000) nompra
         write(ulsort,32000) nuroul, codret, ficloc
         if ( typarr.eq.0 ) then
           guimp = 1
           raison = 1
           call gustop ( nompro, ulsort, guimp, raison )
         else
           codret = 3
         endif
       endif
c
      endif
c
c===
c 4. archivage de l'information
c===
c
      if ( codret.eq.0 ) then
c
        statut(nuroul) = statfi
        lnomfi(nuroul) = lficlo
        nomfic(nuroul) = ficloc
c
c     (9): nb actuel d'unites ouvertes form/sequ
c     (10): nb actuel d'unites ouvertes bina/sequ
c     (11): nb actuel d'unites ouvertes bina/dire standard
c     (12): nb actuel d'unites ouvertes bina/dire special
c
        gunmbr(statfi+6) = gunmbr(statfi+6) + 1
c
c     (1): nbre maxi d'unites ouvertes form/sequ
c     (2): nbre maxi d'unites ouvertes bina/sequ
c     (3): nbre maxi d'unites ouvertes bina/dire standard
c     (4): nbre maxi d'unites ouvertes bina/dire special
c
        gunmbr(statfi-2) = max(gunmbr(statfi-2),gunmbr(statfi+6))
c
c     (5): nbre total d'unites ouvertes form/sequ
c     (6): nbre total d'unites ouvertes bina/sequ
c     (7): nbre total d'unites ouvertes bina/dire standard
c     (8): nbre total d'unites ouvertes bina/dire special
c
        gunmbr(statfi+2) = gunmbr(statfi+2) + 1
c
c     (13): nbre maxi d'unites ouvertes tous types confondus
        gunmbr(13) = max ( gunmbr(13),
     >                     gunmbr(9)+gunmbr(10)+gunmbr(11)+gunmbr(12) )
c
        code = 0
        call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
      endif
c
c====
c 5. formats
c====
c
11000 format(
     >/,'Sous-programme GUOUGE, appele par ',a6,' :')
c
21000 format(
     >/,'Erreur lors de l''ouverture de l''unite ',i2,
     >/,'Fichier :',
     >/,a200,
     >/,'Le statut ',i8,' est inconnu. Il faut 3 ou 4.')
22000 format(
     >/,'Fichier :',
     >/,a200,
     >/,'La longueur de son nom vaut ',i6,
     >/,'... ce qui est assez curieux ...',
     >/,'car la variable est dimensionnee a ',i6,' en amont.')
23000 format(
     >/,'Fichier :',
     >/,a200,
     >/,'La longueur de son nom vaut ',i6,
     >/,'... ce qui est assez curieux ... Il faut entre 1 et 200.')
c
24000 format(
     >/,'Fichier :',
     >/,a200,
     >/,'L''ouverture est impossible car ce fichier l''est deja',
     >/,'sur l''unite ',i8,'.')
c
25000 format(
     >/,'Fichier :',
     >/,a200,
     >/,'L''ouverture est impossible car les mbmxul unites sont deja',
     >/,'utilisees.')
c
32000 format(
     >/,'Erreur lors de l''ouverture de l''unite ',i2,
     >/,'Code de retour ',i8,
     >/,'Fichier :',
     >/,a200)
c
      end
