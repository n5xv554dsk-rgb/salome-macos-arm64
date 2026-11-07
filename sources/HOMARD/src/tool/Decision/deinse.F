      subroutine deinse ( typenh,
     >                    seuihe, seuibe,
     >                    pilraf, pilder,
     >                    typseh, typseb, seuilh, seuilb, nbsoci,
     >                    indtab, tabind,
     >                    ulsort, langue, codret)
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
c traitement des DEcisions - INitialisation des SEuils
c                --          --                 --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . type d'entites concernees                  .
c .        .     .        . -1 : noeuds                                .
c .        .     .        . 1 : aretes                                 .
c .        .     .        . 2 : triangles                              .
c .        .     .        . 3 : tetraedres                             .
c .        .     .        . 4 : quadrangles                            .
c .        .     .        . 5 : pyramides                              .
c .        .     .        . 6 : hexaedres                              .
c .        .     .        . 7 : pentaedres                             .
c . seuihe .  s  .   1    . borne superieure absolue de l'erreur entite.
c . seuibe .  s  .   1    . borne inferieure absolue de l'erreur entite.
c . pilraf . e   .   1    . pilotage du raffinement                    .
c .        .     .        . -1 : raffinement uniforme                  .
c .        .     .        .  0 : pas de raffinement                    .
c .        .     .        .  1 : raffinement libre                     .
c .        .     .        .  2 : raff. libre homogene en type d'element.
c . pilder . e   .   1    . pilotage du deraffinement                  .
c .        .     .        . 0 : pas de deraffinement                   .
c .        .     .        . 1 : deraffinement libre                    .
c .        .     .        . -1 : deraffinement uniforme                .
c . typseh . e   .   1    . type de seuil haut                         .
c .        .     .        . 1 : absolu                                 .
c .        .     .        . 2 : relatif                                .
c .        .     .        . 3 : pourcentage d'entites                  .
c .        .     .        . 4 : moyenne + nh*ecart-type                .
c .        .     .        . 5 : cible en nombre de noeuds              .
c . typseb . e   .   1    . type de seuil bas                          .
c .        .     .        . 1 : absolu                                 .
c .        .     .        . 2 : relatif                                .
c .        .     .        . 3 : pourcentage d'entites                  .
c .        .     .        . 4 : moyenne - nb*ecart-type                .
c . seuilh . e   .   1    . borne superieure de l'erreur (absolue,     .
c .        .     .        . relatif, pourcentage d'entites ou nh)      .
c . seuilb . e   .   1    . borne inferieure de l'erreur (absolue,     .
c .        .     .        . relatif, pourcentage d'entites ou nb)      .
c . nbsoci . e   .   1    . cible en nombre de sommets  (-1 si non)    .
c . indtab . e   .   1    . dernier indice affecte dans tabind         .
c . tabind . e   . indtab . tableau de l'indicateur                    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 4 : nombres d'entites incoherents          .
c .        .     .        . 2 : probleme dans le traitement            .
c .        .     .        . 3 : les seuils sont mal definis            .
c .        .     .        . 5 : mauvaise cible                         .
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
      parameter ( nompro = 'DEINSE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envada.h"
c
#include "gmenti.h"
#include "infini.h"
#include "precis.h"
#include "impr02.h"
#include "nombno.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer typenh
      integer pilraf, pilder
      integer typseh, typseb
      integer nbsoci
      integer indtab
c
      integer ulsort, langue, codret
c
      double precision seuibe, seuihe
      double precision seuilb, seuilh
      double precision tabind(indtab)
c
c 0.4. ==> variables locales
c
      integer iaux
cgn      integer jaux
      integer ptrav1
      integer codre0
c
      double precision vmin, vmax
      double precision vmoy, sigma
      double precision daux
c
      character*8 ntrav1
cgn      character*8 saux08
cgn      character*80 repere
c
      logical lgaux1, lgaux2, lgaux3
c
      integer nbmess
      parameter (nbmess = 16 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
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
cgn      write (ulsort,90002) 'typenh', typenh
cgn      write (ulsort,90002) 'pilraf', pilraf
cgn      write (ulsort,90002) 'pilder', pilder
cgn      write (ulsort,90002) 'typseh', typseh
cgn      write (ulsort,90004) 'seuilh', seuilh
cgn      write (ulsort,90002) 'typseb', typseb
cgn      write (ulsort,90004) 'seuilb', seuilb
cgn 1400 format(5(i5,' : ',i11,' |'))
cgn 1401 format(5(i5,' : ',g11.4,' |'))
c
      texte(1,4) = '(''Le seuil haut n''''est pas defini.'')'
      texte(1,5) = '(''Le seuil bas n''''est pas defini.'')'
      texte(1,6) = '(''Entite '',i10)'
      texte(1,7) = '(''. Nombre d''''entites actives :'',i10)'
      texte(1,8) =
     >'(''. Nombre d''''entites designees par le support :'',i10)'
      texte(1,9) = '(5x,a14,'' : seuil haut ='',g13.5,/)'
      texte(1,10) = '(5x,a14,'' : seuil bas  ='',g13.5,/)'
      texte(1,11) = '(''Recherche des seuils pour les '',a))'
      texte(1,12) = '(''On prend la valeur brute de l''''indicateur.'')'
      texte(1,13) =
     > '(''On prend la valeur absolue de l''''indicateur.'')'
      texte(1,14) = '(''Nombre de sommets actuel :'',i10)'
      texte(1,15) = '(''Nombre de sommets voulu  :'',i10)'
      texte(1,16) = '(''Impossible'')'
c
      texte(2,4) = '(''Upper threshold is not defined.'')'
      texte(2,5) = '(''Lower threshold is not defined.'')'
      texte(2,6) = '(''Entity '',i10)'
      texte(2,7) = '(''. Number of active entities :'',i10)'
      texte(2,8) =
     >'(''. Number of entities declared by support of error :'',i10)'
      texte(2,9) = '(5x,a14,'': Upper threshold ='',g13.5,/)'
      texte(2,10) = '(5x,a14,'': Lower threshold ='',g13.5,/)'
      texte(2,11) = '(''Thresholds for the '',a))'
      texte(2,12) = '(''Inlet value for indicator is taken.'')'
      texte(2,13) = '(''Absolute value for indicator is taken.'')'
      texte(2,14) = '(''Number of vertices          :'',i10)'
      texte(2,15) = '(''Targetted number of vertices:'',i10)'
      texte(2,16) = '(''Impossible'')'
c
c====
c 2. Prealables
c====
c 2.1. ==> Controles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typseh', typseh
      write (ulsort,90002) 'typseb', typseb
#endif
c
      if ( pilraf.gt.0 .and. typseh.eq.0 .and. nbsoci.le.0 ) then
        write (ulsort,texte(langue,4))
        codret = 3
      endif
c
      if ( nbiter.gt.0 ) then
c
        if ( pilder.gt.0 .and. typseb.eq.0 ) then
          write (ulsort,texte(langue,5))
          codret = 3
        endif
c
      endif
c 2.2. ==> Par defaut, on prend des valeurs extremes inhibant toute
c          adaptation
c
      seuihe = vinfpo
      seuibe = vinfne
c
c 2.3. ==> Pour une cible, on va estimer un pourcentage de mailles
c 2.3.1. ==> Au premier passage, on va estimer un pourcentage de mailles
c
      if ( typseh.eq.5 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,14)) nbnop1
        write (ulsort,texte(langue,15)) nbsoci
#endif
c
        if ( nbsoci.lt.nbnop1 ) then
          write (ulsort,texte(langue,14)) nbnop1
          write (ulsort,texte(langue,15)) nbsoci
          write (ulsort,texte(langue,16))
          codret = 5
        endif
c
        if ( codret.eq.0 ) then
c
        daux = dble(nbsoci)/dble(nbnop1)
cgn        write (ulsort,90004) 'nbsoci/nbnop1', daux
c
        daux = daux - 1.d0
        if ( mdim.eq.1 ) then
          daux = daux
        elseif ( mdim.eq.2 ) then
          daux = daux/2.d0
        else
          daux = daux/4.d0
        endif
cgn        write (ulsort,90004) 'daux', daux
        seuilh = 100.d0 * daux
        seuilh = min(seuilh, 100.d0)
#ifdef _DEBUG_HOMARD_
        write (ulsort,90004) 'seuilh', seuilh
#endif
c
        endif
c
      endif
c
c 2.3.2. ==> Ensuite, on transfere
c
      if ( codret.eq.0 ) then
c
      if ( ( typseh.eq.0 ) .and. (nbsoci.gt.0 ) ) then
c
        seuihe = seuilh
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,3,typenh)
#endif
c
c====
c 3. si les seuils sont definis par des valeurs absolues
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. seuils en valeur absolue ; codret',codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( pilraf.gt.0 .and. typseh.eq.1 ) then
        seuihe = seuilh
      endif
c
      if ( pilder.gt.0 .and. typseb.eq.1 ) then
        seuibe = seuilb
      endif
c
      endif
c
c====
c 4. determination des seuils si :
c    . un des seuils est fourni en relatif
c    . un des seuils est fourni en pourcentage d'entites
c    . un des seuils est fourni en mu+n.sigma
c    . un nombre de noeuds cibles est recherche
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. determination des seuils ; codret',codret
#endif
c
      if ( ( pilraf.gt.0 .and. typseh.ge.2 .and. typseh.le.5 ) .or.
     >     ( pilder.gt.0 .and. typseb.ge.2 .and. typseb.le.4 ) ) then
c
c 4.1. ==> allocation du tableau de travail pour uttris
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'Allocation pour',
     >                     indtab, ' '//mess14(langue,3,typenh)
#endif
c
        call gmalot ( ntrav1, 'entier  ', indtab, ptrav1, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
c 4.2. ==> tri
c          On a besoin de la valeur max dans les cas suivants :
c              - raffinement ou deraffinement libre, seuil exprime
c                en relatif et valant plus de 0%
c              - raffinement libre, seuil exprime en pourcentage
c                d'elements et valant moins de 0%
c              - deraffinement libre, seuil exprime en pourcentage
c                d'elements et valant plus de 100%
c          On a besoin de la valeur min dans les cas suivants :
c              - raffinement ou deraffinement libre, seuil exprime
c                en relatif et valant moins de 100%
c              - raffinement libre, seuil exprime en pourcentage
c                d'elements et valant plus de 100%
c              - deraffinement libre, seuil exprime en pourcentage
c                d'elements et valant moins de 0%
c          On a besoin de la valeur moy et de l'ecart-type dans les
c          cas suivants :
c              - raffinement ou deraffinement libre, seuil exprime
c                en moyenne + coeff*(ecart-type)
c
c   lgaux1 = calcul de la valeur minimale
c   lgaux2 = calcul de la valeur maximale
c   lgaux3 = calcul de la valeur moyenne et de l'ecart-type
c
        if ( codret.eq.0 ) then
c
        lgaux1 = .false.
        lgaux2 = .false.
        lgaux3 = .false.
c
c 4.2.1. ==> examen du raffinement
c
        if ( pilraf.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93030) '4.2.1. Examen du raffinement'
#endif
c         relatif
          if ( typseh.eq.2 ) then
            if ( abs(seuilh).le.epsima ) then
              lgaux1 = .true.
            elseif ( abs(seuilh-100.d0).le.epsima ) then
              lgaux2 = .true.
            else
              lgaux1 = .true.
              lgaux2 = .true.
            endif
c         pourcentage d'entites
          elseif ( typseh.eq.3 .or. typseh.eq.5 ) then
            if ( abs(seuilh).le.epsima ) then
              lgaux2 = .true.
            elseif ( abs(seuilh-100.d0).le.epsima ) then
              lgaux1 = .true.
            else
              lgaux1 = .true.
              lgaux2 = .true.
            endif
          elseif ( typseh.eq.4 ) then
            lgaux3 = .true.
          endif
c
        endif
c
c 4.2.2. ==> examen du deraffinement
c
        if ( pilder.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93030) '4.2.2. Examen du deraffinement'
#endif
c         relatif
          if ( typseb.eq.2 ) then
            if ( abs(seuilb).le.epsima ) then
              lgaux1 = .true.
            elseif ( abs(seuilb-100.d0).le.epsima ) then
              lgaux2 = .true.
            else
              lgaux1 = .true.
              lgaux2 = .true.
            endif
c         pourcentage d'entites
          elseif ( typseb.eq.3 ) then
            if ( abs(seuilb).le.epsima ) then
              lgaux1 = .true.
            elseif ( abs(seuilb-100.d0).le.epsima ) then
              lgaux2 = .true.
            else
              lgaux1 = .true.
              lgaux2 = .true.
            endif
          elseif ( typseb.eq.4 ) then
            lgaux3 = .true.
          endif
c
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,99001) 'lgaux1', lgaux1
      write (ulsort,99001) 'lgaux2', lgaux2
      write (ulsort,99001) 'lgaux3', lgaux3
#endif
c
        endif
c
c 4.3. ==> Calcul
c
        if ( codret.eq.0 ) then
c
c 4.3.1. ==> Mini/maxi
c
        if ( lgaux1 .or. lgaux2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93030) '4.3.1. Mini/maxi'
#endif
c
          vmin = vinfpo
          vmax = vinfne
          if ( lgaux1 .and. lgaux2 ) then
            do 4311 , iaux = 1, indtab
              vmin = min(vmin,tabind(iaux))
              vmax = max(vmax,tabind(iaux))
 4311       continue
          elseif ( lgaux2 ) then
            do 4312 , iaux = 1, indtab
              vmax = max(vmax,tabind(iaux))
 4312       continue
          else
            do 4313 , iaux = 1, indtab
              vmin = min(vmin,tabind(iaux))
 4313       continue
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'vmin', vmin
      write (ulsort,90004) 'vmax', vmax
#endif
c
c 4.3.2. ==> Moyenne et ecart-type
c
        elseif ( lgaux3 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93030) '4.3.2. Moyenne et ecart-type'
#endif
c
          vmoy = 0.d0
          daux = 0.d0
          do 432 , iaux = 1, indtab
            vmoy = vmoy + tabind(iaux)
            daux = daux + tabind(iaux)**2
  432     continue
          vmoy = vmoy/dble(indtab)
          daux = daux/dble(indtab)
          sigma = sqrt(daux - vmoy**2)
#ifdef _DEBUG_HOMARD_
          write(ulsort,90004) 'vmoy ', vmoy
          write(ulsort,90004) 'sigma', sigma
#endif
c
        endif
c
        endif
c
c 4.4. ==> Deduction des seuils si exprime en pourcentage d'entites
c 4.4.1. ==> si le seuil haut est exprime en pourcentage d'entites,
c            strictement compris entre 0 et 100, on repere la valeur
c            de seuil
c
        if ( codret.eq.0 ) then
c
        if ( pilraf.gt.0 .and.
     >       ( typseh.eq.3 .or. typseh.eq.5 ) ) then
c
          if (        abs(seuilh).gt.epsima .and.
     >         abs(seuilh-100.d0).gt.epsima ) then
c
cgn      write (ulsort,1401)(iaux,tabind(iaux),iaux=1,indtab)
            iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTTRIS', nompro
#endif
            call uttris ( seuihe,
     >                    iaux, imem(ptrav1),
     >                    seuilh, indtab, tabind,
     >                    ulsort, langue, codret )
c
cgn      codre0 = nint(seuilh*dble(indtab)/100.d0)
cgn      if ( indtab.ge.2 ) codre0 = min(codre0+1,indtab)
cgn      write (ulsort,*) '================== ptrav1 ========='
cgn      write (ulsort,1400) (iaux,imem(ptrav1+iaux-1),iaux=1,codre0)
cgn      write (ulsort,*) '=================='
cgn      write (ulsort,*) '=========== ptrav1 trie pour haut ========'
cgn      write (ulsort,1401)
cgn     >(iaux,tabind(imem(ptrav1+iaux-1)),iaux=1,codre0)
cgn      write (ulsort,90004) '==> seuihe',seuihe
          endif
c
        endif
c
        endif
c
c 4.4.2. ==> si le seuil bas est exprime en pourcentage d'entites,
c            strictement compris entre 0 et 100, on repere la valeur
c            de seuil
c
        if ( codret.eq.0 ) then
c
        if ( pilder.gt.0 .and. typseh.eq.3 ) then
c
          if (        abs(seuilh).gt.epsima .and.
     >         abs(seuilh-100.d0).gt.epsima ) then
c
            iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTTRIS', nompro
#endif
            call uttris ( seuibe,
     >                    iaux, imem(ptrav1),
     >                    seuilb, indtab , tabind,
     >                    ulsort, langue, codret )
c
cgn      codre0 = nint(seuilb*dble(indtab)/100.d0)
cgn      if ( indtab.ge.2 ) codre0 = min(codre0+1,indtab)
cgn      write (ulsort,*) '================== ptrav1 ========='
cgn      write (ulsort,1400) (iaux,imem(ptrav1+iaux-1),iaux=1,codre0)
cgn      write (ulsort,*) '=================='
cgn      write (ulsort,*) '=========== ptrav1 trie pour bas ========'
cgn      write (ulsort,1401)
cgn     >(iaux,tabind(imem(ptrav1+iaux-1)),iaux=1,codre0)
cgn      write (ulsort,90004) '==> seuibe',seuibe
          endif
c
        endif
c
        endif
c
c 4.5. ==> Les seuils definitifs
c
        if ( codret.eq.0 ) then
c
c 4.5.1. ==> en raffinement
c
        if ( pilraf.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93030) '4.5.1. Seuil en raffinement'
#endif
c
c       relatif
        if ( typseh.eq.2 ) then
          if ( abs(vmax-vmin).le.epsima ) then
            seuihe = vmax + epsima
          elseif ( abs(seuilh).le.epsima ) then
            seuihe = 0.999d0*vmin
          elseif ( abs(seuilh-100.d0).le.epsima ) then
            seuihe = 1.5d0*vmax
          else
            seuihe = vmin + seuilh*(vmax-vmin)/100.d0
          endif
c       pourcentage d'entites
        elseif ( typseh.eq.3 .or. typseh.eq.5 ) then
          if ( abs(vmax-vmin).le.epsima ) then
            seuihe = vmax + epsima
          elseif ( abs(seuilh).le.epsima ) then
            seuihe = 1.5d0*vmax
          elseif ( abs(seuilh-100.d0).le.epsima ) then
            seuihe = 0.999d0*vmin
          endif
c       moyenne et ecart-type
        elseif ( typseh.eq.4 ) then
          if ( abs(sigma).le.epsima ) then
            seuihe = vmoy + epsima
          else
            seuihe = vmoy + seuilh*sigma
          endif
        endif
c
        endif
c
c 4.5.2. ==> en deraffinement
c
        if ( pilder.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93030) '4.5.2. Seuil en deraffinement'
#endif
c
c       relatif
        if ( typseb.eq.2 ) then
          if ( abs(vmax-vmin).le.epsima ) then
            seuibe = vmin - epsima
          elseif ( abs(seuilb).le.epsima ) then
            seuibe = 0.999d0*vmin
          elseif ( abs(seuilb-100.d0).le.epsima ) then
            seuibe = 1.5d0*vmax
          else
            seuibe = vmin + seuilb*(vmax-vmin)/100.d0
          endif
c       pourcentage d'entites
        elseif ( typseb.eq.3 ) then
          if ( abs(vmax-vmin).le.epsima ) then
            seuibe = vmin - epsima
          elseif ( abs(seuilb).le.epsima ) then
            seuibe = 0.999d0*vmin
          elseif ( abs(seuilb-100.d0).le.epsima ) then
            seuibe = 1.5d0*vmax
          endif
c       moyenne et ecart-type
        elseif ( typseh.eq.4 ) then
          if ( abs(sigma).le.epsima ) then
            seuibe = vmoy - epsima
          else
            seuibe = vmoy - seuilb*sigma
          endif
        endif
c
        endif
c
        endif
c
c 4.6. ==> liberation des tableaux temporaires
c
        if ( codret.eq.0 ) then
c
        call gmlboj ( ntrav1 , codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
      endif
c
c====
c 5. Ecriture sur la sortie standard et sur le fichier recapitulatif
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Ecriture standard ; codret',codret
#endif
c
      if ( pilraf.gt.0 .and.
     >     ( ( typseh.ge.1 .and. typseh.le.5 ) .or.
     >       ( typseh.eq.0 .and. nbsoci.gt.0 ) ) ) then
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,9)) mess14(langue,4,typenh), seuihe
c
cgn        iaux = 2
cgn        jaux = 25
cgnc                         12345678901
cgn        repere(1:jaux) = 'Seuil haut '//mess14(langue,4,typenh)
cgn#ifdef _DEBUG_HOMARD_
cgn      write (ulsort,texte(langue,3)) 'UTSYNT', nompro
cgn#endif
cgn        call utsynt ( repere, jaux,
cgn     >                iaux, jaux, seuihe, saux08, jaux,
cgn     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      if ( nbiter.gt.0 ) then
c
      if ( pilder.gt.0 .and. typseb.ge.1 .and. typseb.le.4 ) then
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,10)) mess14(langue,4,typenh), seuibe
c
cgn        iaux = 2
cgn        jaux = 24
cgnc                         1234567890
cgn        repere(1:jaux) = 'Seuil bas '//mess14(langue,4,typenh)
cgn#ifdef _DEBUG_HOMARD_
cgn      write (ulsort,texte(langue,3)) 'UTSYNT', nompro
cgn#endif
cgn        call utsynt ( repere, jaux,
cgn     >                iaux, jaux, seuibe, saux08, jaux,
cgn     >                ulsort, langue, codret )
c
        endif
c
        endif
c
      endif
      if ( typseh.eq.5 ) then
        typseh = 0
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) '==> seuihe', seuihe
      write (ulsort,90004) '==> seuibe', seuibe
#endif
c
c====
c 6. la fin
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
