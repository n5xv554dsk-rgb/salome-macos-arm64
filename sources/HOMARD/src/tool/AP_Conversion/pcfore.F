      subroutine pcfore ( option, extrus,
     >                    nnfopa, anobfo,
     >                    npfopa, nppafo,
     >                    nbpara, carenf, carchf,
     >                    nbtrav, litrav,
     >                    adpetr, adhequ,
     >                    adnohn, admphn, adarhn, adtrhn, adquhn,
     >                    adtehn, adpyhn, adhehn, adpehn,
     >                    adnocn, admpcn, adarcn, adtrcn, adqucn,
     >                    adtecn, adpycn, adhecn, adpecn,
     >                    adnoin, admpin, adarin, adtrin, adquin,
     >                    adtein, adpyin, adhein, adpein,
     >                    lgnoin, lgmpin, lgarin, lgtrin, lgquin,
     >                    lgtein, lgpyin, lghein, lgpein,
     >                    decanu,
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
c    aPres adaptation - Fonctions - REcuperation
c     -                 --          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . option du traitement                       .
c .        .     .        . -1 : Pas de changement dans le maillage    .
c .        .     .        .  0 : Adaptation complete                   .
c .        .     .        .  1 : Modification de degre                 .
c . extrus . e   .    1   . prise en compte d'extrusion                .
c . nnfopa . e   .   1    . nombre de fonctions du paquet iteration n  .
c . anobfo . e   .   1    . adresse des noms des fonctions n           .
c . npfopa .  s  .   1    . nombre de fonctions du paquet iteration p  .
c . nppafo . es  .    1   . nom du paquet de fonctions iteration p     .
c . nbpara . e   .   1    . nombre de parametres a enregistrer par fonc.
c . carenf .   s .nbpara* . caracteristiques entieres des fonctions :  .
c .        .     .  nnfopa.  1 : 0, pour une fonction ancienne isolee  .
c .        .     .        .      1, pour une ancienne associee a une   .
c .        .     .        .         autre fonction                     .
c .        .     .        .      -1, pour une nouvelle fonction        .
c .        .     .        .  2 : typcha                                .
c .        .     .        .  3 : typgeo                                .
c .        .     .        .  4 : nbtyas                                .
c .        .     .        .  5 : ngauss                                .
c .        .     .        .  6 : nnenmx                                .
c .        .     .        .  7 : nnvapr                                .
c .        .     .        .  8 : carsup                                .
c .        .     .        .  9 : nbtafo                                .
c .        .     .        . 10 : anvale                                .
c .        .     .        . 11 : anvalr                                .
c .        .     .        . 12 : anobch                                .
c .        .     .        . 13 : anprpg                                .
c .        .     .        . 14 : anlipr                                .
c .        .     .        . 15 : npenmx                                .
c .        .     .        . 16 : npvapr                                .
c .        .     .        . 17 : apvale                                .
c .        .     .        . 18 : apvalr                                .
c .        .     .        . 19 : apobch                                .
c .        .     .        . 20 : apprpg                                .
c .        .     .        . 21 : apvatt                                .
c .        .     .        . 22 : apvane                                .
c .        .     .        . 23 : antyas                                .
c .        .     .        . 24 : aptyas                                .
c .        .     .        . 25 : numero de la 1ere fonction associee   .
c .        .     .        . 26 : numero de la 2nde fonction associee   .
c . carchf . es  .nbpara* . caracteristiques caracteres des fonctions :.
c .        .     .  nnfopa.  1 : nom de la fonction                    .
c .        .     .        .  2 : nom de la fonction n associee         .
c .        .     .        .  3 : nom de la fonction p associee         .
c .        .     .        .  4 : obpcan                                .
c .        .     .        .  5 : obpcap                                .
c .        .     .        .  6 : obprof                                .
c .        .     .        .  7 : oblopg                                .
c .        .     .        .  8 : si aux points de Gauss, nom de la     .
c .        .     .        .      fonction n ELNO correspondante        .
c .        .     .        .  9 : si aux points de Gauss, nom de la     .
c .        .     .        .      fonction p ELNO correspondante        .
c . nbtrav . es  .   1    . nombre de tableaux de travail crees        .
c . litrav . es  .   *    . liste des noms de tableaux de travail crees.
c . adnohn . e   .   1    . adresse de la renum. des noeuds en entree  .
c . admphn . e   .   1    . adresse de la renum. des m.poi. en entree  .
c . adarhn . e   .   1    . adresse de la renum. des aretes en entree  .
c . adtrhn . e   .   1    . adresse de la renum. des tria. en entree   .
c . adquhn . e   .   1    . adresse de la renum. des quad. en entree   .
c . adtehn . e   .   1    . adresse de la renum. des tetras. en entree .
c . adpyhn . e   .   1    . adresse de la renum. des pyras. en entree  .
c . adhehn . e   .   1    . adresse de la renum. des hexas. en entree  .
c . adpehn . e   .   1    . adresse de la renum. des pentas. en entree .
c . decanu . e   .  -1:7  . decalage des numerotations selon le type   .
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
      parameter ( nompro = 'PCFORE' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#ifdef _DEBUG_HOMARD_
#include "gmreel.h"
#endif
#include "gmenti.h"
#include "gmstri.h"
c
#include "nombtr.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nbutil.h"
#include "nomber.h"
#include "nombsr.h"
#include "esutil.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbpara
      integer nnfopa, anobfo
      integer npfopa
      integer nbtrav
      integer adpetr, adhequ
      integer carenf(nbpara,*)
      integer adnohn, admphn, adarhn, adtrhn, adquhn
      integer adtehn, adpyhn, adhehn, adpehn
      integer adnocn, admpcn, adarcn, adtrcn, adqucn
      integer adtecn, adpycn, adhecn, adpecn
      integer adnoin, admpin, adarin, adtrin, adquin
      integer adtein, adpyin, adhein, adpein
      integer lgnoin, lgmpin, lgarin, lgtrin, lgquin
      integer lgtein, lgpyin, lghein, lgpein
      integer decanu(-1:7)
c
      character*8 nppafo
      character*8 carchf(nbpara,*)
      character*8 litrav(*)
c
      logical extrus
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux, maux, naux
      integer nrfonc, nrfonm
      integer nbent2, ngaus2, dimcp2, typge2, nrfon2
      integer nbent3, ngaus3, dimcp3, typge3, nrfon3
c
      integer typfon, typcha, typgeo, nbtyas
      integer ngauss, nnenmx, nnvapr
      integer carsup, nbtafo, typint
      integer anvale, anvalr, anobch, anprpg, antyas
      integer apvale, apvalr, apobch, apprpg, aptyas
      integer nbpg, nbsufo
      integer anlipr
      integer apvatt
      integer apobfo, aptyge
      integer apobfa, aptyga
      integer adtra1
c
      integer reenac, rsenac
      integer advofa, advohn, advocn
      integer adenhn, adencn
      integer lgenin, adenin
      integer adpcan, adpcap
      integer tbiaux(nbinec), lgtbix
      integer decala
c
      character*8 nnfonc
      character*8 obpcan, obpcap, oblopg
      character*8 oblop2
      character*8 oblop3
      character*8 nppafa
      character*8 saux08
      character*8 tbsaux(1)
      character*8 ntrav1
      character*64 noprof
      character*64 nolop2
      character*64 nolop3
c
      logical afair2, afair3
      logical extrul
c
      integer nbmess
      parameter ( nbmess = 120 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "esimpr.h"
c
      texte(1,4) = '(/,60(''-''),/,''Fonction '',i3,'', objet = '',a)'
      texte(1,5) = '(''Type de support geometrique :'',i5)'
      texte(1,6) = '(''On ne sait pas faire aujourd''''hui.'',/)'
      texte(1,7) = '(/,''Creation de la fonction a l''''iteration p'')'
      texte(1,8) = '(/,''Probleme de conformite ?'')'
      texte(1,9) =
     > '(/,''Creation d''''une fonction pour la conformite'')'
      texte(1,10) = '(''En retour de '',a,'', codret ='',i13)'
      texte(1,13) = '(''... Premiere valeur : '',g14.7)'
      texte(1,14) = '(''... Derniere valeur : '',g14.7)'
      texte(1,15) = '(''... Profil : '',a32)'
      texte(1,16) = '(''... Premiere(s) valeur(s) : '',5i10)'
      texte(1,17) = '(''... Derniere(s) valeur(s) : '',5i10)'
      texte(1,18) =
     > '(''Les deux longueurs de profil sont differentes !'')'
      texte(1,19) = '(''Caracteristiques du support :'',i5)'
c
      texte(2,4) = '(/,60(''-''),/,''Function '',i3,'', objet = '',a)'
      texte(2,5) = '(''Geometric support type :'',i5)'
      texte(2,6) = '(''It cannot be solved.'',/)'
      texte(2,7) = '(/,''Creation of a function for iteration # p'')'
      texte(2,8) = '(/,''Pending nodes ?'')'
      texte(2,9) = '(/,''Creation of a function for pending nodes'')'
      texte(2,10) = '(''Back from '',a,'', codret ='',i13)'
      texte(2,13) = '(''... First value : '',g14.7)'
      texte(2,14) = '(''... Last value  : '',g14.7)'
      texte(2,15) = '(''... Profile : '',a32)'
      texte(2,16) = '(''... First value(s) : '',5i10)'
      texte(2,17) = '(''... Last value(s)  : '',5i10)'
      texte(2,18) =
     > '(''The two lengths of profile are not the same !'')'
      texte(2,19) = '(''Characteristics of the support:'',i5)'
c
#include "impr03.h"
c
      npfopa = 0
      nrfonm = nnfopa
c
c====
c 2. prealable pour les couples (aux noeuds par element/aux points
c    de Gauss)
c====
c
c 2.1. ==> decodage de nppafo, paquet a l'iteration p
c
#ifdef _DEBUG_HOMARD_
cgn      call gmprsx (nompro,nppafo)
cgn      call gmprsx (nompro,nppafo//'.Fonction')
cgn      call gmprsx (nompro,nppafo//'.TypeSuAs')
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
      call utcapf ( nppafo,
     >              iaux, jaux, kaux, laux, maux,
     >              apobfo, aptyge,
     >              ulsort, langue, codret )
c
c 2.2. ==> si c'est un champ aux points de Gauss, on repere nppafa,
c          paquet correspondant, a l'iteration p.
c
      if ( laux.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
        nppafa = smem(apobfo+npfopa)
cgn        write (ulsort,*) 'Paquet correspondant ==> ',nppafa
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
      call gmprsx (nompro,nppafa)
      call gmprsx (nompro,nppafa//'.Fonction')
#endif
        call utcapf ( nppafa,
     >                iaux, jaux, kaux, laux, maux,
     >                apobfa, aptyga,
     >                ulsort, langue, codret )
c
        endif
c
        endif
c
c====
c 3. parcours des fonctions du paquet a l'iteration n
c====
c
      do 30 , nrfonc = 1 , nnfopa
c
        nnfonc = smem(anobfo+nrfonc-1)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nrfonc, nnfonc
        call gmprsx (nompro,nnfonc)
        call gmprsx (nompro,nnfonc//'.InfoPrPG')
        call gmprsx (nompro,nnfonc//'.TypeSuAs')
#endif
c
c 3.1. ==> caracteristiques de la fonction a l'iteration n
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
        call utcafo ( nnfonc,
     >                typcha,
     >                typgeo, ngauss, nnenmx, nnvapr, nbtyas,
     >                carsup, nbtafo, typint,
     >                anvale, anvalr, anobch, anprpg, antyas,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) 'utcafo', codret
#endif
c
        nbpg = ngauss
        oblopg = smem(anprpg+1)
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'typgeo', typgeo
        write (ulsort,90002) 'ngauss', ngauss
        write (ulsort,90002) 'nnenmx', nnenmx
        write (ulsort,90002) 'nnvapr', nnvapr
        write (ulsort,90002) 'nbtyas', nbtyas
        if ( nbtyas.gt.0 ) then
        write (ulsort,90002)
     >  '==> typass', (imem(antyas+iaux-1),iaux=1,nbtyas)
        endif
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,90002) 'nbtafo', nbtafo
        write (ulsort,*) '.. oblopg : ', oblopg
cgn        write (ulsort,texte(langue,13)) rmem(anvalr)
cgn        write (ulsort,texte(langue,14))
cgn     >  rmem(anvalr+nnenmx*nbtafo*nbpg-1)
#endif
c
        if ( nbtyas.ge.1 ) then
          typfon = 1
        else
          typfon = 0
        endif
        carenf( 1,nrfonc) = typfon
        carenf( 2,nrfonc) = typcha
        carenf( 3,nrfonc) = typgeo
        carenf( 4,nrfonc) = nbtyas
        carenf( 5,nrfonc) = nbpg
        carenf( 6,nrfonc) = nnenmx
        carenf( 7,nrfonc) = nnvapr
        carenf( 8,nrfonc) = carsup
        carenf( 9,nrfonc) = nbtafo
        carenf(10,nrfonc) = anvale
        carenf(11,nrfonc) = anvalr
        carenf(12,nrfonc) = anobch
        carenf(13,nrfonc) = anprpg
        carenf(23,nrfonc) = antyas
c
        carchf( 2,nrfonc) = nnfonc
        carchf( 7,nrfonc) = oblopg
c
        endif
c
c 3.2. ==> pour une fonction aux points de Gausss avec un champ aux
c          noeuds par elements associe, la fonction associee
c
        if ( carsup.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
        carchf(8,nrfonc) = smem(anprpg+2)
        carchf(9,nrfonc) = smem(apobfa+nrfonc-1)
cgn        call gmprsx (nompro,carchf(9,nrfonc))
c
        endif
c
        endif
c
c 3.3. ==> le profil eventuel
c
        if ( nnvapr.gt.0 ) then
c
c 3.3.1. ==> les caracteristiques du profil
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCAPR', nompro
#endif
          call utcapr ( smem(anprpg),
     >                  jaux, noprof, anlipr,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,10)) 'utcapr', codret
          write (ulsort,texte(langue,13)) 'jaux', jaux
          write (ulsort,texte(langue,15)) noprof
          write (ulsort,texte(langue,16))
     >                    (imem(anlipr+iaux),iaux=0,min(4,jaux-1))
          if ( nnvapr.gt.5 ) then
            write (ulsort,texte(langue,17))
     >                    (imem(anlipr+iaux),iaux=jaux-5,jaux-1)
          endif
#endif
c
c 3.3.2. ==> on verifie que les longueurs sont bien les memes : celle
c            enregistree dans le profil, jaux, et celle enregistree
c            dans la fonction, nnvapr.
c
          if ( jaux.ne.nnvapr ) then
            write (ulsort,90002) 'nnvapr', nnvapr
            write (ulsort,90002) 'jaux  ', jaux
            write (ulsort,texte(langue,18))
            codret = 3
          endif
c
          carenf(14,nrfonc) = anlipr
c
          endif
c
        endif
c
c 3.4. ==> creation de fonctions associees pour la conformite :
c    . quand la fonction courante est definie sur des quadrangles,
c      des hexaedres ou des pentaedres
c    . que des mailles de conformite sont presentes
c    . qu'il n'a pas de fonction associee sur ces mailles de conformite
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. creer une fonction ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,8))
        write (ulsort,90002) 'typgeo', typgeo
        write (ulsort,90002) 'nbtyas', nbtyas
        write (ulsort,90002) 'ngauss', ngauss
        write (ulsort,90002) 'nbtafo', nbtafo
        write (ulsort,90002) 'nbtrq3', nbtrq3
        write (ulsort,90002) 'nbheco', nbheco
        write (ulsort,90002) 'nbpeco', nbpeco
        write (ulsort,90002) 'nbtyas', nbtyas
#endif
c
        nrfon2 = -1
        afair2 = .false.
        ngaus2 = ngauss
        nrfon3 = -1
        afair3 = .false.
        ngaus3 = ngauss
        typge3 = 0
c
        if ( ( typgeo.eq.edqua4 .or. typgeo.eq.edqua8 ) .and.
     >        nbtrq3.gt.0 ) then
          if ( typgeo.eq.edqua4 ) then
            nbent2 = nbtria
            typge2 = edtri3
            if ( carsup.eq.1 ) then
              ngaus2 = 3
              dimcp2 = 2
            elseif ( carsup.eq.2 .or. carsup.eq.3 ) then
              codret = 341
            endif
          else
            nbent2 = nbtria
            typge2 = edtri6
            if ( carsup.eq.1 ) then
              ngaus2 = 6
              dimcp2 = 2
            elseif ( carsup.eq.2 .or. carsup.eq.3 ) then
              codret = 342
            endif
          endif
          afair2 = .true.
          do 341 , iaux = 1 , nbtyas
            if ( imem(antyas+iaux-1).eq.typge2 ) then
              nrfon2 = iaux
              afair2 = .false.
            endif
  341     continue
c
        elseif ( ( ( typgeo.eq.edhex8 .or. typgeo.eq.edhe20 ) .and.
     >             nbheco.ne.0 ) .or.
     >            ( ( typgeo.eq.edpen6 .or. typgeo.eq.edpe15 ) .and.
     >             nbpeco.ne.0 ) ) then
          if ( typgeo.eq.edhex8 .or. typgeo.eq.edpen6 ) then
            nbent2 = nbtetr
            typge2 = edtet4
            nbent3 = nbpyra
            typge3 = edpyr5
            if ( carsup.eq.1 ) then
              ngaus2 = 4
              ngaus3 = 5
              dimcp2 = 3
              dimcp3 = 3
            elseif ( carsup.eq.2 .or. carsup.eq.3 ) then
              codret = 343
            endif
          elseif ( typgeo.eq.edhe20 .or. typgeo.eq.edpe15  ) then
            nbent2 = nbtetr
            typge2 = edte10
            nbent3 = nbpyra
            typge3 = edpy13
            if ( carsup.eq.1 ) then
              ngaus2 = 10
              ngaus3 = 13
              dimcp2 = 3
              dimcp3 = 3
            elseif ( carsup.eq.2 .or. carsup.eq.3 ) then
              codret = 344
            endif
          else
            codret = 340
          endif
          afair2 = .true.
          afair3 = .true.
          do 342 , iaux = 1 , nbtyas
            if ( imem(antyas+iaux-1).eq.typge2 ) then
              nrfon2 = iaux
              afair2 = .false.
            endif
            if ( imem(antyas+iaux-1).eq.typge3 ) then
              nrfon3 = iaux
              afair3 = .false.
            endif
  342     continue
c
        endif
c
        if ( codret.ne.0 ) then
c
        write (ulsort,texte(langue,5)) typgeo
        write (ulsort,texte(langue,19)) carsup
        write (ulsort,texte(langue,68))
        write (ulsort,texte(langue,6))
c
        endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,99001) 'afair2', afair2
        write (ulsort,99001) 'afair3', afair3
#endif
c
c 3.5. ==> bilan sur les types
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.5. bilan type ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
c       memorisation des eventuels types associes deja presents
c
        lgtbix = 0
        do 35 , iaux = 1 , nbtyas
          lgtbix = lgtbix + 1
          tbiaux(lgtbix) = imem(antyas+iaux-1)
   35   continue
c
c       si conformite, ajout du type courant et du/des types associes
c
        if ( afair2 .or. afair3 ) then
c
          lgtbix = lgtbix + 1
          tbiaux(lgtbix) = typgeo
          if ( afair2 ) then
            lgtbix = lgtbix + 1
            tbiaux(lgtbix) = typge2
          endif
          if ( afair3 ) then
            lgtbix = lgtbix + 1
            tbiaux(lgtbix) = typge3
          endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'tbiaux = ', (tbiaux(iaux),iaux=1,lgtbix)
#endif
        endif
c
c 3.6. ==> la fonction similaire a l'iteration p
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.6. similaire ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7))
#endif
c
        if ( typgeo.eq.0 ) then
          nbsufo = rsnoto
        elseif ( typgeo.eq.edseg2 .or. typgeo.eq.edseg3 ) then
          nbsufo = nbsegm
        elseif ( typgeo.eq.edtri3 .or. typgeo.eq.edtri6 ) then
          nbsufo = nbtria
        elseif ( typgeo.eq.edqua4 .or. typgeo.eq.edqua8 ) then
          nbsufo = nbquad
        elseif ( typgeo.eq.edtet4 .or. typgeo.eq.edte10 ) then
          nbsufo = nbtetr
        elseif ( typgeo.eq.edhex8 .or. typgeo.eq.edhe20 ) then
          nbsufo = nbhexa
        elseif ( typgeo.eq.edpyr5 .or. typgeo.eq.edpy13 ) then
          nbsufo = nbpyra
        elseif ( typgeo.eq.edpen6 .or. typgeo.eq.edpe15 ) then
          nbsufo = nbpent
        else
          write (ulsort,texte(langue,5)) typgeo
          write (ulsort,texte(langue,6))
          codret = 3
        endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = nrfonc
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'PCFOR1_p', nompro
#endif
        call pcfor1 ( option,
     >                nnfonc, iaux,
     >                nbpara, carenf, carchf,
     >                nppafo, npfopa,
     >                nbtrav, litrav,
     >                typfon, typcha, typgeo, nbtyas,
     >                ngauss, nbsufo, nnvapr,
     >                carsup, nbtafo, typint,
     >                lgtbix, tbiaux,
     >                apvale, apvalr, apobch, apprpg, aptyas,
     >                apvatt,
     >                ulsort, langue, codret )
c
        endif
c
c 3.7. ==> pour les champs aux noeuds par elements, creation de la
c          localisation des pseudo "points de Gauss"
c          REMARQUE : on ne cree plus rien
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) '3.7. pseudo ; codret', codret
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,99001) 'afair2', afair2
        write (ulsort,99001) 'afair3', afair3
#endif
c
        if ( afair2 .and. carsup.eq.1793 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCRPG-2', nompro
#endif
          call utcrpg ( oblop2,
     >                  nolop2, typge2, ngaus2, dimcp2, carsup,
     >                  ulsort, langue, codret )
c
          endif
c
        else
c
          oblop2 = blan08
c
        endif
c
        if ( afair3 .and. carsup.eq.1793 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCRPG-3', nompro
#endif
          call utcrpg ( oblop3,
     >                  nolop3, typge3, ngaus3, dimcp3, carsup,
     >                  ulsort, langue, codret )
c
          endif
c
        else
c
          oblop3 = blan08
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90003) 'oblop2', oblop2
        write (ulsort,90003) 'oblop3', oblop3
#endif
c
c 3.8. ==> creation des fonctions pour la conformite
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.8. conformite ; codret', codret
#endif
c 3.8.1. ==> 1ere fonction
c
        if ( afair2 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,9))
#endif
c
          nrfonm = nrfonm + 1
          nrfon2 = nrfonm
          typfon = -1
          laux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFOR1_2', nompro
#endif
          call pcfor1 ( option,
     >                  nnfonc, nrfon2,
     >                  nbpara, carenf, carchf,
     >                  nppafo, npfopa,
     >                  nbtrav, litrav,
     >                  typfon, typcha, typge2, nbtyas,
     >                  ngaus2, nbent2, laux,
     >                  carsup, nbtafo, typint,
     >                  lgtbix, tbiaux,
     >                  apvale, apvalr, apobch, apprpg, aptyas,
     >                  apvatt,
     >                  ulsort, langue, codret )
c
          carchf( 2,nrfon2) = nnfonc
          carchf( 3,nrfon2) = carchf( 1,nrfonc)
          carchf( 7,nrfon2) = oblop2
c
          endif
c
        endif
c
c 3.8.2. ==> 2nde fonction
c
        if ( afair3 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,9))
#endif
c
          nrfonm = nrfonm + 1
          nrfon3 = nrfonm
          typfon = -1
          laux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFOR1_3', nompro
#endif
          call pcfor1 ( option,
     >                  nnfonc, nrfon3,
     >                  nbpara, carenf, carchf,
     >                  nppafo, npfopa,
     >                  nbtrav, litrav,
     >                  typfon, typcha, typge3, nbtyas,
     >                  ngaus3, nbent3, laux,
     >                  carsup, nbtafo, typint,
     >                  lgtbix, tbiaux,
     >                  apvale, apvalr, apobch, apprpg, aptyas,
     >                  apvatt,
     >                  ulsort, langue, codret )
c
          carchf( 2,nrfon3) = nnfonc
          carchf( 3,nrfon3) = carchf( 1,nrfonc)
          carchf( 7,nrfon3) = oblop3
c
          endif
c
        endif
c
c 3.9. ==> modification des types associes du paquet de fonction
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.9. modification ; codret', codret
#endif
c
        if ( afair2 .or. afair3 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMOPF', nompro
#endif
          iaux = 5
          call utmopf ( nppafo, iaux,
     >                  lgtbix, tbsaux, tbiaux,
     >                  saux08,
     >                  jaux, nbtyas, ngauss, laux, maux,
     >                  naux,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        call gmprsx (nompro, nppafo )
        call gmprsx (nompro, nppafo//'.Fonction' )
        call gmprsx (nompro, nppafo//'.TypeSuAs')
        endif
#endif
c
c 3.10. ==> Enregistrement des numeros de fonctions associees,
c           reelles ou fictives
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nrfon2', nrfon2
        write (ulsort,90002) 'nrfon3', nrfon3
#endif
c
        carenf(25,nrfonc) = nrfon2
        carenf(26,nrfonc) = nrfon3
c
        endif
c
   30 continue
c
c====
c 4. preparation des profils des fonctions du paquet
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Preparation ; codret', codret
#endif
c
      do 40 , nrfonc = 1 , nrfonm
c
cgn      print 1788,(carenf(iaux,nrfonc),iaux=1,nbpara)
c
c 4.1. ==> recuperation des informations
c
        if ( codret.eq.0 ) then
c
        typgeo = carenf( 3,nrfonc)
        nnvapr = carenf( 7,nrfonc)
        anlipr = carenf(14,nrfonc)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'nnvapr', nnvapr
#endif
c
        extrul = .false.
        if ( typgeo.eq.0 ) then
          reenac = renoac
          rsenac = rsnoto
          adenhn = adnohn
          adencn = adnocn
          lgenin = lgnoin
          adenin = adnoin
          decala = decanu(-1)
        elseif ( typgeo.eq.edpoi1 ) then
          reenac = rempac
          rsenac = rsmpac
          adenhn = admphn
          adencn = admpcn
          lgenin = lgmpin
          adenin = admpin
          decala = decanu(0)
        elseif ( typgeo.eq.edseg2 .or. typgeo.eq.edseg3 ) then
          reenac = rearac
          rsenac = rsarac
          adenhn = adarhn
          adencn = adarcn
          lgenin = lgarin
          adenin = adarin
          decala = decanu(1)
        elseif ( typgeo.eq.edtri3 .or. typgeo.eq.edtri6 ) then
          reenac = retrac
          rsenac = rstrac
          adenhn = adtrhn
          adencn = adtrcn
          lgenin = lgtrin
          adenin = adtrin
          decala = decanu(2)
          extrul = extrus
          advofa = adpetr
          advohn = adpehn
          advocn = adpecn
        elseif ( typgeo.eq.edqua4 .or. typgeo.eq.edqua8 ) then
          reenac = requac
          rsenac = rsquac
          adenhn = adquhn
          adencn = adqucn
          lgenin = lgquin
          adenin = adquin
          decala = decanu(4)
          extrul = extrus
          advofa = adhequ
          advohn = adhehn
          advocn = adhecn
        elseif ( typgeo.eq.edtet4 .or. typgeo.eq.edte10 ) then
          reenac = reteac
          rsenac = rsteac
          adenhn = adtehn
          adencn = adtecn
          lgenin = lgtein
          adenin = adtein
          decala = decanu(3)
        elseif ( typgeo.eq.edpyr5 .or. typgeo.eq.edpy13  ) then
          reenac = repyac
          rsenac = rspyac
          adenhn = adpyhn
          adencn = adpycn
          lgenin = lgpyin
          adenin = adpyin
          decala = decanu(5)
        elseif ( typgeo.eq.edhex8 .or. typgeo.eq.edhe20  ) then
          reenac = reheac
          rsenac = rsheac
          adenhn = adhehn
          adencn = adhecn
          lgenin = lghein
          adenin = adhein
          decala = decanu(6)
        elseif ( typgeo.eq.edpen6 .or. typgeo.eq.edpe15  ) then
          reenac = repeac
          rsenac = rspeac
          adenhn = adpehn
          adencn = adpecn
          lgenin = lgpein
          adenin = adpein
          decala = decanu(7)
        else
          codret = 41
        endif
c
        endif
c
c 4.2. ==> tableau reciproque de nenin
c
        if ( lgenin.gt.0 .and. nnvapr.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          call gmalot ( ntrav1, 'entier  ', reenac, adtra1, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTTBRC', nompro
#endif
          call uttbrc ( iaux,
     >                  lgenin, imem(adenin), reenac, imem(adtra1),
     >                  ulsort, langue, codret)
c
          endif
c
        endif
c
c 4.3. ==> prise en compte du profil
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nnvapr', nnvapr
        write (ulsort,90002) 'reenac', reenac
        write (ulsort,90002) 'rsenac', rsenac
        write (ulsort,90002) 'decala', decala
        write (ulsort,99001) 'extrul', extrul
#endif
c
        if ( .not.extrul ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR05', nompro
#endif
          call utpr05 ( iaux, nnvapr, imem(anlipr),
     >                  reenac, rsenac,
     >                  imem(adenhn), imem(adencn), decala,
     >                  lgenin, imem(adenin), imem(adtra1),
     >                  obpcan, obpcap,
     >                  adpcan, adpcap,
     >                  ulsort, langue, codret )
c
          endif
c
        else
c
          if ( codret.eq.0 ) then
c
          iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR06', nompro
#endif
          call utpr06 ( iaux,
     >                  reenac, rsenac,
     >                  imem(advofa), imem(adenhn),
     >                  imem(advohn), imem(advocn),
     >                  obpcan, obpcap,
     >                  adpcan, adpcap,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
cgn        call gmprsx (nompro,obpcap)
c
c 4.4. ==> archivage
c
        if ( codret.eq.0 ) then
c
        carchf (4,nrfonc) = obpcan
        nbtrav = nbtrav + 1
        litrav(nbtrav) = obpcan
cgn      write (ulsort,*)'4.3 nbtrav =', nbtrav,', obpcan = ', obpcan
cgn        print *,'litrav(',nbtrav,') = ',litrav(nbtrav)
c
        carchf (5,nrfonc) = obpcap
        nbtrav = nbtrav + 1
        litrav(nbtrav) = obpcap
cgn      write (ulsort,*)'4.3 nbtrav =', nbtrav,', obpcap = ', obpcap
cgn        print *,'litrav(',nbtrav,') = ',litrav(nbtrav)
c
        endif
c
      nnfonc = carchf(1,nrfonc)
cgn      write (*,texte(langue,4)) nrfonc, nnfonc
cgn      write (*,1788)(carenf(iaux,nrfonc),iaux=1,nbpara)
cgn 1788 format(10I8)
cgn      write (*,1789)(carchf(iaux,nrfonc),iaux=1,nbpara)
cgn 1789 format(10(a8,1x))
c
c 4.5. ==> menage
c
        if ( lgenin.gt.0 .and. nnvapr.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          call gmlboj ( ntrav1 , codret )
c
          endif
c
        endif
c
   40 continue
c
c====
c 5. la fin
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
