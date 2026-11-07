      subroutine utmcc0 ( nbcham,
     >                    caetal, cactal, cartal,
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
c     UTilitaire : Mot-Cle - liste des Champs a mettre a jour - 0
c     --           -   -               -                        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbcham . e   .    1   . nombre de champs a mettre a jour           .
c . cactal .  s  .8*nbseal. caracteristiques caracteres de chaque      .
c .        .     .        . tableau a lire                             .
c .        .     .        . 1,2,3,4. nom du champ associe              .
c . caetal .  s  .  12 *  . caracteristiques entieres de chaque        .
c .        .     . nbseal . tableau a lire                             .
c .        .     .        . 1. type de support au sens MED             .
c .        .     .        .  -1, si on prend tous les supports         .
c .        .     .        . 2. 1, si numero du pas de temps, 0 sinon   .
c .        .     .        . 3. numero du pas de temps                  .
c .        .     .        . 4. 1, si numero d'ordre, 0 sinon           .
c .        .     .        . 5. numero d'ordre                          .
c .        .     .        . 6. 1, si instant, 0 sinon                  .
c .        .     .        . 7. 1, si aux noeuds par elements, 0 sinon, .
c .        .     .        .   -1, si non precise                       .
c .        .     .        . 8. numero du champ noeuds/element associe  .
c .        .     .        . 9. numero du champ associe dans HOMARD     .
c .        .     .        . 10. type d'interpolation                   .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  1 si degre 1, 2 si degre 2, 3 si iso-P2   .
c .        .     .        . 11. sans objet a ce stade du traitement    .
c .        .     .        . 12. type de champ edfl64/edin64            .
c . cartal .  s  . nbseal . caracteristiques reelles de chaque         .
c .        .     .        . tableau a lire                             .
c .        .     .        . 1. instant                                 .
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
c .        .     .        . 1 : la configuration est perdue            .
c .        .     .        . 2 : probleme de lecture                    .
c .        .     .        . 8 : Allocation impossible                  .
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
      parameter ( nompro = 'UTMCC0' )
c
#include "nblang.h"
#include "motcle.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbcham
      integer caetal(12,nbcham)
      integer nbfich
      integer lgnofi(nbfich), poinno(0:nbfich)
c
      double precision cartal(*)
c
      character*8 cactal(*)
      character*8 nomref(nbfich), nomufi(*), nomstr(nbfich)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nrcham, nrfich
      integer numero
c
      double precision daux
c
      character*8 motcle
      character*200 sau200
c
      logical chnom, chnum, chpdt, chins, chcas, chncn
c
      integer nbmess
      parameter ( nbmess = 20 )
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
      texte(1,4) = '(''Nombre de champs a mettre a jour :'',i8)'
      texte(1,5) = '(/,''Numero du champ en cours de recherche :'',i8)'
      texte(1,6) = '('' .. ==> Nom du champ : '',a)'
      texte(1,7) = '(''Le nom est introuvable.'')'
      texte(1,8) = '('' .. ==> Numero d''''ordre :'',i8)'
      texte(1,9) = '(''Le numero d''''ordre est introuvable.'')'
      texte(1,10) = '('' .. ==> Numero du pas de temps :'',i8)'
      texte(1,11) = '(''Le numero de pas de temps est introuvable.'')'
      texte(1,12) = '('' .. ==> Instant                :'',g12.5)'
      texte(1,13) = '(''L''''instant est introuvable.'')'
      texte(1,14) = '('' .. ==> Caracteristique du support : '',a)'
      texte(1,15) =
     > '(''La caracteristique du support est inconnue : '',a)'
      texte(1,16) = '('' .. ==> Numero du champ associe :'',i8)'
c
      texte(2,4) = '(''Number of files to update :'',i8)'
      texte(2,5) = '(/,''Search for field #'',i8)'
      texte(2,6) = '('' .. ==> Name of the field : '',a)'
      texte(2,7) = '(''Name of the field cannot be found.'')'
      texte(2,8) = '('' .. ==> Rank number :'',i8)'
      texte(2,9) = '(''Rank number cannot be found.'')'
      texte(2,10) = '('' .. ==> Time step # :'',i8)'
      texte(2,11) = '(''Time step # cannot be found.'')'
      texte(2,12) = '('' .. ==> Instant     :'',g12.5)'
      texte(2,13) = '(''Instant cannot be found.'')'
      texte(2,14) = '('' .. ==> Characteristic of support : '',a)'
      texte(2,15) =
     > '(''The characteristic of support is unknown : '',a)'
      texte(2,16) = '(''. Number for the associated field :'',i8)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbcham
#endif
c
      codret = 0
c
c====
c 2. on parcourt toutes les posssibilites de champs
c====
c
      do 20 , nrcham = 1 , nbcham
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) nrcham
#endif
        chnom = .false.
        chnum = .false.
        chpdt = .false.
        chins = .false.
        chcas = .false.
        chncn = .false.
c
        caetal(2,nrcham) = 0
        caetal(4,nrcham) = 0
        caetal(6,nrcham) = 0
        caetal(9,nrcham) = 0
        caetal(10,nrcham) = 0
c
        do 200 , nrfich = 1 , nbfich
c
c 2.1. ==> si c'est un des mots-cles possibles, on verifie que c'est
c          pour le bon champ
c
          if ( codret.eq.0 ) then
c
          motcle = nomref(nrfich)
cgn      write (ulsort,*) '.. motcle = ',motcle
c
          if ( motcle.eq.mcchno .or.
     >         motcle.eq.mcchcs .or.
     >         motcle.eq.mcchpt .or.
     >         motcle.eq.mcchnu .or.
     >         motcle.eq.mcchin .or.
     >         motcle.eq.mcchti .or.
     >         motcle.eq.mcchnc ) then
c
cgn      write (ulsort,*) '.. nomstr(nrfich) = ',nomstr(nrfich)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHEN', nompro
#endif
            call utchen ( nomstr(nrfich), numero,
     >                    ulsort, langue, codret )
c
cgn      write (ulsort,*) '.. motcle = ',motcle,' ',nrcham,' ',numero
            if ( nrcham.eq.numero ) then
c
              if ( motcle.eq.mcchno ) then
                goto 22
              elseif ( motcle.eq.mcchcs ) then
                goto 23
              elseif ( motcle.eq.mcchpt .or. motcle.eq.mcchnu ) then
                goto 24
              elseif ( motcle.eq.mcchin ) then
                goto 25
              elseif ( motcle.eq.mcchti ) then
                goto 26
              else
                goto 27
              endif
            else
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
c 2.2. ==> recherche du nom du champ
c
   22     continue
c
          if ( codret.eq.0 ) then
c
cgn      write (ulsort,90002) 'debut de 22 continue ; nrcham', nrcham
c
          jaux = 8*(nrcham-1)
          do 221 , iaux = jaux+1 , jaux+8
            cactal(iaux) = blan08
  221     continue
          kaux = poinno(nrfich-1) + 1
          do 222 , iaux = kaux, poinno(nrfich)
            jaux = jaux + 1
            cactal(jaux) = nomufi(iaux)
  222     continue
          chnom = .true.
#ifdef _DEBUG_HOMARD_
          jaux = poinno(nrfich-1) + 1
          kaux = lgnofi(nrfich)
          call uts8ch ( nomufi(jaux), kaux, sau200,
     >                  ulsort, langue, codret )
          write (ulsort,texte(langue,6)) sau200(1:kaux)
#endif
c
          goto 28
c
          endif
c
c 2.3. ==> recherche de la caracteristique du support du champ
c          par defaut, il est standard
c
   23     continue
c
          if ( codret.eq.0 ) then
c
cgn      write (ulsort,90002) 'debut de 23 continue ; nrcham', nrcham
c
          caetal(7,nrcham) = 0
c
          jaux = 1
          kaux = poinno(nrfich-1) + 1
          do 231 , iaux = kaux, poinno(nrfich)
            sau200(jaux:jaux+7) = nomufi(iaux)
            jaux = jaux + 8
  231     continue
c
          do 232 , iaux = jaux , 200
            sau200(iaux:iaux) = ' '
  232     continue
c
          call utlgut ( iaux, sau200,
     >                  ulsort, langue, codret )
c
          jaux = 1
c
          if ( iaux.eq.8 ) then
c                                   12345678
            if ( sau200(1:iaux).eq.'standard' ) then
              caetal(7,nrcham) = 1
              jaux = 0
            endif
c
          elseif ( iaux.eq.22 ) then
c                                   1234567890123456789012
            if ( sau200(1:iaux).eq.'aux_noeuds_par_element' ) then
              caetal(7,nrcham) = 1
              jaux = 0
            endif
c
          endif
          if ( jaux.ne.0 ) then
            write (ulsort,texte(langue,15)) sau200(1:iaux)
            codret = 1
#ifdef _DEBUG_HOMARD_
          else
            write (ulsort,texte(langue,14)) sau200(1:iaux)
#endif
          endif
c
          chcas = .true.
c
          goto 28
c
          endif
c
c 2.4. ==> recherche de numero d'ordre du champ
c
   24     continue
c
          if ( codret.eq.0 ) then
c
cgn      write (ulsort,90002) 'debut de 24 continue ; nrcham', nrcham
c
          jaux = poinno(nrfich-1) + 1
          kaux = lgnofi(nrfich)
          call uts8ch ( nomufi(jaux), kaux, sau200,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHEN', nompro
#endif
          call utchen ( sau200, iaux,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          if ( motcle.eq.mcchpt ) then
            caetal(2,nrcham) = 1
            caetal(3,nrcham) = iaux
            chpdt = .true.
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,10)) iaux
#endif
          else
            caetal(4,nrcham) = 1
            caetal(5,nrcham) = iaux
            chnum = .true.
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8)) iaux
#endif
          endif
c
          goto 28
c
          endif
c
c 2.5. ==> recherche de l'instant du champ
c
   25     continue
c
          if ( codret.eq.0 ) then
c
cgn      write (ulsort,90002) 'debut de 25 continue ; nrcham', nrcham
c
          jaux = poinno(nrfich-1) + 1
          kaux = lgnofi(nrfich)
          call uts8ch ( nomufi(jaux), kaux, sau200,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHRE', nompro
#endif
          call utchre ( sau200, daux,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          caetal(6,nrcham) = 1
          cartal(nrcham) = daux
          chins = .true.
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,12)) daux
#endif
c
          goto 28
c
          endif
c
c 2.6. ==> recherche du type d'interpolation
c
   26     continue
c
          if ( codret.eq.0 ) then
c
cgn      write (ulsort,90002) 'debut de 26 continue ; nrcham', nrcham
c
          jaux = poinno(nrfich-1) + 1
          kaux = lgnofi(nrfich)
          call uts8ch ( nomufi(jaux), kaux, sau200,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHEN', nompro
#endif
          call utchen ( sau200, iaux,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          caetal(10,nrcham) = iaux
c
          goto 28
c
          endif
c
c 2.7. ==> recherche du numero du champ aux noeuds par elements associe
c          au champ courant.
c          remarque : on ne peut pas controler ici que c'est un vrai
c                     champ aux points de Gauss
c
   27     continue
c
          if ( codret.eq.0 ) then
c
cgn      write (ulsort,90002) 'debut de 27 continue ; nrcham', nrcham
c
          jaux = poinno(nrfich-1) + 1
          kaux = lgnofi(nrfich)
          call uts8ch ( nomufi(jaux), kaux, sau200,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHEN', nompro
#endif
          call utchen ( sau200, iaux,
     >                  ulsort, langue, codret )
c
          caetal(8,nrcham) = iaux
          chncn = .true.
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,16)) iaux
#endif
c
          goto 28
c
          endif
c
c 2.8. ==> si on a tout trouve, on passe au champ suivant
c
   28     continue
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '... arrivee dans 28 continue'
      write (ulsort,90003) 'chnom', chnom
      write (ulsort,90003) 'chnum', chnum
      write (ulsort,90003) 'chpdt', chpdt
      write (ulsort,90003) 'chins', chins
      write (ulsort,90003) 'chcas', chcas
      write (ulsort,90003) 'chncn', chncn
#endif
c
          if ( chnom .and.
     >         ( ( chnum .and. chpdt ) .or. chins ) .and.
     >         chcas .and. chncn ) then
            caetal(1,nrcham) = -1
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,*) '... ==> OK 28 ; passage au champ suivant'
#endif
            goto 20
          endif
c
          endif
c
  200   continue
c
c 2.9. ==> si on arrive ici, il faut verifier qu'il ne manque rien
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'debut de 29 continue'
      write (ulsort,90003) 'chnom', chnom
      write (ulsort,90003) 'chnum', chnum
      write (ulsort,90003) 'chpdt', chpdt
      write (ulsort,90003) 'chins', chins
      write (ulsort,90003) 'chcas', chcas
      write (ulsort,90003) 'chncn', chncn
#endif
c
c 2.9.1. ==> s'il ne manque que la caracteristique du support ou les
c            indications temporelles, on suppose que ce champ est
c            standard
c
        if ( chnom ) then
c
          caetal(1,nrcham) = -1
          if ( .not.chcas ) then
            caetal(7,nrcham) = 0
          endif
          if ( .not.chncn ) then
            caetal(8,nrcham) = 0
          endif
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) '... ==> OK 29 ; passage au champ suivant'
#endif
c
c 2.9.2. ==> s'il manque le nom, probleme ...
c
        else
c
          write (ulsort,texte(langue,5)) nrcham
          write (ulsort,texte(langue,7))
#ifdef _DEBUG_HOMARD_
          if ( .not.chnum ) then
            write (ulsort,texte(langue,9))
          endif
          if ( .not.chpdt ) then
            write (ulsort,texte(langue,11))
          endif
          if ( .not.chins ) then
            write (ulsort,texte(langue,13))
          endif
#endif
          codret = 1
c
        endif
c
        endif
c
cgn      print texte(langue,6), sau200(1:kaux)
cgn      print *, '... support MED    caetal(1,',nrcham,') = ',
cgn     >     caetal(1,nrcham)
cgn      print *, '... pas de temps ? caetal(2,',nrcham,') = ',
cgn     >     caetal(2,nrcham)
cgn      print *, '... pas de temps = caetal(3,',nrcham,') = ',
cgn     >     caetal(3,nrcham)
cgn      print *, '... nro ordre ?    caetal(4,',nrcham,') = ',
cgn     >     caetal(4,nrcham)
cgn      print *, '... nro ordre =    caetal(5,',nrcham,') = ',
cgn     >     caetal(5,nrcham)
cgn      print *, '... instant ?      caetal(6,',nrcham,') = ',
cgn     >     caetal(6,nrcham)
cgn      print *, '... no/el ?        caetal(7,',nrcham,') = ',
cgn     >     caetal(7,nrcham)
cgn      print *, '... nr chp no/el   caetal(8,',nrcham,') = ',
cgn     >     caetal(8,nrcham)
cgn      print *, '... typint         caetal(10,',nrcham,') = ',
cgn     >     caetal(10,nrcham)
cgn      print *, '... instant =      cartal(',nrcham,') = ',
cgn     >     cartal(nrcham)
   20 continue
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
