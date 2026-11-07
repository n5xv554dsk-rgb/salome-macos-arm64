      subroutine holopt ( lgopti, taopti, lgoptr, taoptr,
     >                    lgopts, taopts,
     >                    lgetco, taetco,
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
c   HOMARD : Lecture des OPTions
c   --       -           ---
c   Remarque : les options ont deja ete lues ; elles sont decodees ici
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . es  . lgopti . tableau des options                        .
c . lgoptr . e   .   1    . longueur du tableau des options reelles    .
c . taoptr . es  . lgoptr . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . es  . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 6 : impossible de decoder les options      .
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
      parameter ( nompro = 'HOLOPT' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "infini.h"
c
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgoptr
      double precision taoptr(lgoptr)
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbmomx
      parameter ( nbmomx = 11 )
c
      integer codava
      integer nretap, nrsset
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6
      integer codre0, nbmot
      integer adopti(nbmomx), imopti(nbmomx)
      integer iaux, jaux, kaux, laux
c
      double precision daux
c
      character*6 saux
      character*8 saux08
      character*8 motcle(nbmomx)
c
      integer nbmess
      parameter ( nbmess = 11 )
      character*80 texte(nblang,nbmess)
c
c====
c 1. messages
c====
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
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
#include "melopt.h"
#include "impr03.h"
c
c 1.3. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.4. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. valeurs par defaut
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Defaut', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> les options generales
c
c   3 : type de bilan sur le maillage
c   5 : ecriture des fichiers au format HOMARD
c       on met un faux defaut, qui sera modifie dans holver s'il n'y a
c       pas eu surcharge.
c   6 : type de donnees sur les seuils hauts
c   7 : type de donnees sur les seuils bas
c   9 : messages d'information
c
      taopti(3) = 7
      taopti(5) = -1
      taopti(6) = 0
      taopti(7) = 0
      taopti(9) = 1
c
c 2.2. ==> le mode d'utilisation de HOMARD
c
      taopti(4) = 1
      taopts(30) = 'homa    '
c                   12345678
c
c 2.3. ==> le pilotage de l'adaptation
c
      taopti(31) = 1
      taopti(32) = 1
      taopti(33) = -1
      taopti(34) = -1
      taopti(35) = 0
      taopti(36) = 1
      taopti(38) = 0
      taopti(43) = 50
      taopti(44) = -1
      taopti(45) = -1
      taopti(49) = 0
c
c 2.4. ==> les seuils
c
      taoptr(1) =  vinfpo
      taoptr(2) = -vinfpo
      taoptr(3) = -vinfpo
c
c 2.5. ==> la modification du maillage
c
      taopti(41) = 0
c
c 2.6. ==> les maillages extrudes
c          coordonnees initiales
c
      taopti(39) = 0
      taopti(40) = 1
      taoptr(4) = -1789.d0
c
c 2.7. ==> numero de pas de temps, numero d'ordre ou valeur de l'instant
c          de l'indicateur d'erreur du code de calcul associe :
c          aucun par defaut
c
      taopti(15) = -2
      taopti(16) = -2
      taopti(17) = -2
c
c 2.8. ==> mise a jour de tous les champs : non par defaut
c
      taopti(20) = 0
c
c 2.9. ==> la creation des joints
c
      taopti(42) = 0
c
c 2.10. ==> le numero d'iteration
c          le type du code de calcul associe
c
      taopti(10) = -1
      taopti(11) = -1
c
c 2.11. ==> le suivi de frontiere
c
      taopti(29) = 1
c
      endif
c
c====
c 3. decodage des options en oui/non
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Decodage oui/non', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbmot = 3
c
      motcle(1) = mcchto
      motcle(2) = mcmdeg
      motcle(3) = mcjoin
c
      adopti(1) = 20
      adopti(2) = 41
      adopti(3) = 42
c
      do 31 , iaux = 1 , nbmot
c
        jaux = taopti(adopti(iaux))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) motcle(iaux)
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLO00', nompro
#endif
        call utlo00 ( motcle(iaux), jaux, ulsort, langue, codre0 )
c
        if ( codre0.eq.0 ) then
          taopti(adopti(iaux)) = jaux
        else
          codret = 6
        endif
cgn        write (ulsort,90002) motcle(iaux), jaux
c
   31 continue
c
      endif
c
c====
c 4. decodage des options numeriques entieres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Decodage entiers', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbmot = 11
c
      motcle( 1) = mctybi
      motcle( 2) = mcinfo
      motcle( 3) = mcnvma
      motcle( 4) = mcnvmi
      motcle( 5) = mcnbme
      motcle( 6) = mcmoho
      motcle( 7) = mcnuit
      motcle( 8) = mcsufr
      motcle( 9) = mcinad
      motcle(10) = mcpacm
      motcle(11) = mcnbsc
c
      adopti( 1) = 3
      adopti( 2) = 9
      adopti( 3) = 33
      adopti( 4) = 34
      adopti( 5) = 35
      adopti( 6) = 4
      adopti( 7) = 10
      adopti( 8) = 29
      adopti( 9) = 38
      adopti(10) = 43
      adopti(11) = 44
c
      imopti( 1) = 1
      imopti( 2) = 1
      imopti( 3) = 1
      imopti( 4) = 1
      imopti( 5) = 1
      imopti( 6) = 1
      imopti( 7) = 1
      imopti( 8) = 1
      imopti( 9) = 1
      imopti(10) = 1
      imopti(11) = 1
c
      do 41 , iaux = 1 , nbmot
c
        jaux = taopti(adopti(iaux))
        kaux = imopti(iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) motcle(iaux)
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMCEN', nompro
#endif
        call utmcen ( motcle(iaux), jaux, kaux,
     >                ulsort, langue, codre0 )
c
        if ( codre0.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) jaux
#endif
          taopti(adopti(iaux)) = jaux
cgn          if ( iaux.eq.4 .or. iaux.eq.5 ) then
cgn            taopti(adopti(iaux)+2) = 1
cgn          endif
c
        elseif ( codre0.eq.4 ) then
          codre0 = 0
c
        else
          write (ulsort,texte(langue,6)) motcle(iaux)
          jaux = 7+(codre0-2)/3
          write (ulsort,texte(langue,jaux))
          codret = 6
c
        endif
c
   41 continue
c
      endif
c
c====
c 5. decodage des options numeriques reelles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Decodage reels', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbmot = 10
c
      motcle(1) = mcseuh
      motcle(2) = mcseub
      motcle(3) = mcserh
      motcle(4) = mcserb
      motcle(5) = mcseph
      motcle(6) = mcsepb
      motcle(7) = mcsesh
      motcle(8) = mcsesb
      motcle(9) = mcdimi
      motcle(10) = mccex2
c
      adopti(1) = 1
      adopti(2) = 2
      adopti(3) = 1
      adopti(4) = 2
      adopti(5) = 1
      adopti(6) = 2
      adopti(7) = 1
      adopti(8) = 2
      adopti(9) = 3
      adopti(10) = 4
c
      do 51 , iaux = 1 , nbmot
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) motcle(iaux)
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMCRE', nompro
#endif
        call utmcre ( motcle(iaux), daux,
     >                ulsort, langue, codre0 )
c
        if ( codre0.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) daux
#endif
          taoptr(adopti(iaux)) = daux
c
          if ( iaux.eq.1 ) then
            if ( taopti(6).eq.0 ) then
              taopti(6) = 1
            else
              taopti(6) = -1
            endif
          elseif ( iaux.eq.2 ) then
            if ( taopti(7).eq.0 ) then
              taopti(7) = 1
            else
              taopti(7) = -1
            endif
          elseif ( iaux.eq.3 ) then
            if ( taopti(6).eq.0 ) then
              taopti(6) = 2
            else
              taopti(6) = -1
            endif
          elseif ( iaux.eq.4 ) then
            if ( taopti(7).eq.0 ) then
              taopti(7) = 2
            else
              taopti(7) = -1
            endif
          elseif ( iaux.eq.5 ) then
            if ( taopti(6).eq.0 ) then
              taopti(6) = 3
            else
              taopti(6) = -1
            endif
          elseif ( iaux.eq.6 ) then
            if ( taopti(7).eq.0 ) then
              taopti(7) = 3
            else
              taopti(7) = -1
            endif
          elseif ( iaux.eq.7 ) then
            if ( taopti(6).eq.0 ) then
              taopti(6) = 4
            else
              taopti(6) = -1
            endif
          elseif ( iaux.eq.8 ) then
            if ( taopti(7).eq.0 ) then
              taopti(7) = 4
            else
              taopti(7) = -1
            endif
          endif
c
        elseif ( codre0.eq.4 ) then
          codre0 = 0
c
        else
          write (ulsort,texte(langue,6)) motcle(iaux)
          jaux = 7+(codre0-2)/3
          write (ulsort,texte(langue,jaux))
          codret = 6
c
        endif
c
   51 continue
c
      endif
c
c====
c 6. decodage des options caracteres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Decodage caracteres', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbmot = 1
c
      motcle(1) = mcacti
c
      adopti(1) = 30
c
      do 61 , iaux = 1 , nbmot
c
        saux08 = taopts(adopti(iaux))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) motcle(iaux)
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMCCH', nompro
#endif
        call utmcch ( motcle(iaux), jaux, saux08,
     >                ulsort, langue, codre0 )
c
        if ( codre0.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) saux08
#endif
          taopts(adopti(iaux)) = saux08
c
        elseif ( codre0.eq.4 ) then
          codre0 = 0
c
        else
          write (ulsort,texte(langue,6)) motcle(iaux)
          jaux = 7+(codre0-2)/3
          write (ulsort,texte(langue,jaux))
          codret = 6
c
        endif
c
   61 continue
c
      endif
c
c====
c 7. options textuelles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. Decodage texte - codret', codret
#endif
c
c 7.1. ==> Caracteristiques du maillage
c
      if ( codret.eq.0 ) then
c
c 7.1.1. ==> type de conformite
c
      motcle(1) = mctyco
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLO02', nompro
#endif
      call utlo02 ( motcle(1), taopti(30), ulsort, langue, codre1 )
c
c 7.1.2. ==> type de code de calcul associe
c
      motcle(1) = mcccas
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLO01', nompro
#endif
      call utlo01 ( motcle(1), taopti(11), ulsort, langue, codre2 )
c
c 7.1.3. ==> Le maillage extrude
c
      motcle(1) = mcmext
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLO11', nompro
#endif
      call utlo11 ( motcle(1), taopti(39), taopti(11),
     >              ulsort, langue, codre3 )
c
c 7.1.4. ==> choix des coordonnees pour les maillages extrudes
c
      motcle(1) = mccex1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTLO05', nompro
#endif
      call utlo05 ( motcle(1), taopti(40), taopti(4), taopti(39),
     >            ulsort, langue, codre4 )
c
c 7.1.5. ==> bilan
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c 7.2. ==> Pilotage du raffinement
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7.2. Pilotage raffinement - codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 7.2.1. ==> type de raffinement
c
      motcle(1) = mctyra
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLO03', nompro
#endif
      call utlo03 ( motcle(1), taopti(31), ulsort, langue, codre1 )
c
c 7.2.2. ==> type de deraffinement
c
      motcle(1) = mctyde
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLO03', nompro
#endif
      call utlo03 ( motcle(1), taopti(32), ulsort, langue, codre2 )
c
c 7.2.3. ==> contraintes de raffinement
c
      motcle(1) = mccora
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLO04', nompro
#endif
      call utlo04 ( motcle(1), taopti(36), taopti(30),
     >              ulsort, langue, codre3 )
c
c 7.2.4. ==> usage des composantes de l'indicateur
c
      motcle(1) = mcmfi1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLO06', nompro
#endif
      call utlo06 ( motcle(1), taopti(8), ulsort, langue, codre4 )
c
c 7.2.5. ==> mode de fonctionnement de l'indicateur d'erreur
c
      motcle(1) = mcmfi2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLO07', nompro
#endif
      call utlo07 ( motcle(1), taopti(18), ulsort, langue, codre5 )
c
c 7.2.6. ==> parametres temporels pour l'indicateur d'erreur
c
      codre6 = 0
c
      nbmot = 3
c
      motcle(1) = mcntin
      motcle(2) = mcnoin
      motcle(3) = mcinin
c
      do 726 , iaux = 1 , nbmot
c
        if ( codre6.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) motcle(iaux)
#endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTLO08', nompro
#endif
        jaux = iaux
        call utlo08 ( motcle(jaux), jaux, kaux, daux, laux,
     >                ulsort, langue, codre6 )
c
        endif
c
        if ( codre6.eq.0 .and. laux.ne.0 ) then
c
          if ( iaux.eq.1 ) then
            taopti(13) = kaux
            taopti(15) = laux
          elseif ( iaux.eq.2 ) then
            taopti(14) = kaux
            taopti(16) = laux
          else
            taoptr(10) = daux
            taopti(17) = laux
          endif
c
        endif
c
  726 continue
c
c 7.2.5. ==> bilan
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
      endif
c
c 7.3. ==> ecriture des fichiers HOMARD
c
      if ( codret.eq.0 ) then
c
      motcle(1) = mcecfh
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLO09', nompro
#endif
      call utlo09 ( motcle(1), taopti(5), ulsort, langue, codret )
c
      endif
c
c 7.4. ==> champs complementaires
c
      if ( codret.eq.0 ) then
c
      taopti(12) = 1
      nbmot = 5
c
      motcle(1) = mcicni
      motcle(2) = mcicqu
      motcle(3) = mcicdi
      motcle(4) = mcicpa
      motcle(5) = mcicvr
c
      do 74 , iaux = 1 , nbmot
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) motcle(iaux)
#endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTLO10', nompro
#endif
         call utlo10 ( motcle(iaux), laux, ulsort, langue, codret )
c
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'codre2, laux', codre2, laux
#endif
c
        if ( codre2.eq.0 .and. laux.ne.0 ) then
c
          if ( iaux.eq.1 ) then
            taopti(12) = taopti(12)*2
          elseif ( iaux.eq.2 ) then
            taopti(12) = taopti(12)*3
          elseif ( iaux.eq.3 ) then
            taopti(12) = taopti(12)*5
          elseif ( iaux.eq.4 ) then
            taopti(12) = taopti(12)*7
          elseif ( iaux.eq.5 ) then
            taopti(12) = taopti(12)*11
          endif
c
        endif
c
   74 continue
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'taopti(12)', taopti(12)
#endif
c
c====
c 8. options sous forme de liste
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. Decodage liste', codret
#endif
c
c 8.1. ==> les groupes filtrant l'adaptation
c
      if ( codret.eq.0 ) then
c
      motcle(1) = mcgrad
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMCLS', nompro
#endif
      call utmcls ( motcle(1), iaux, taopts(15), taopti(19),
     >              ulsort, langue, codre0 )
c
      endif
c
c 8.2. ==> les zones geometriques a raffiner
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMCZR', nompro
#endif
      call utmczr ( taopts(19), taopti(37),
     >              ulsort, langue, codret )
c
      endif
c
c 8.3. ==> les champs a mettre a jour
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMCLC', nompro
#endif
      call utmclc ( taopti(20), taopti(28), taopts(18),
     >              ulsort, langue, codret )
c
      endif
c
c 8.4. ==> la frontiere
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'taopti(29) - suifro', taopti(29)
#endif
c
c 8.4.1. ==> les groupes formant la frontiere discrete
c
      if ( mod(taopti(29),2).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        motcle(1) = mcgrfd
        iaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTMCLS', nompro
#endif
         call utmcls ( motcle(1), iaux, taopts(17), jaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 8.4.2. ==> les frontieres analytiques
c
      if ( mod(taopti(29),3).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTMCFA', nompro
#endif
        call utmcfa ( taopts(25), taopts(26), taopts(23), taopts(24),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 8.4.3. ==> les groupes formant la frontiere CAO
c
      if ( mod(taopti(29),5).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        motcle(1) = mcgrfr
        iaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTMCLS', nompro
#endif
         call utmcls ( motcle(1), iaux, taopts(17), jaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 9. transmission des consignes d'impression
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. impression', codret
#endif
c
c 9.1. ==> mesures de temps
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GTINFO', nompro
#endif
      call gtinfo ( taopti(9) )
c
      endif
c
c 9.2. ==> bilan memoire
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GMINFO', nompro
#endif
      call gminfo ( taopti(9) )
c
      endif
c
c====
c 10. type d'elements autorises
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. type elements autorises', codret
#endif
c
      if ( codret.eq.0 ) then
c
      motcle(1) = mctyel
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLOEA', nompro
#endif
      call utloea ( motcle(1), taopti(49), ulsort, langue, codret )
c
      endif
c
c====
c 11. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'taopti'
      write (ulsort,91020) taopti
      write (ulsort,*) 'taoptr'
      write (ulsort,92010) taoptr
      write (ulsort,*) 'taopts'
      write (ulsort,93010) taopts
#endif
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
c=======================================================================
      endif
c=======================================================================
c
      end
