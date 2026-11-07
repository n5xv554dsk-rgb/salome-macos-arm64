      subroutine eslch4 ( idfmed,
     >                    nrocha, nomcha, nbcomp, nbtvch,
     >                    obcham, caraen, caraca,
     >                    nbfonc, defonc, nofonc,
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
c  Entree-Sortie - Lecture d'un CHamp au format MED - phase 4
c  -      -        -            --                          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med en entree       .
c . nrocha . e   .    1   . numero du champ dans le rangement HOMARD   .
c . nomcha . e   . char64 . nom du champ a explorer                    .
c . nbcomp . e   .   1    . nombre de composantes                      .
c . nbtvch . e   .   1    . nombre de tableaux associes a ce champ     .
c . obcham . e   . char8  . nom de l'objet de type 'InfoCham' associe  .
c . caraen . e   . nbinec*. caracteristiques entieres des tableaux du  .
c .        .     . nbtvch . champ en cours d'examen                    .
c .        .     .        . 1. type de support au sens MED             .
c .        .     .        .  -1, si on prend tous les supports         .
c .        .     .        . 2. numero du pas de temps                  .
c .        .     .        . 3. numero d'ordre                          .
c .        .     .        . 4. nombre de points de Gauss               .
c .        .     .        . 5. nombre d'entites support                .
c .        .     .        . 6. nombre de valeurs du profil eventuel    .
c .        .     .        . 7. nombre de supports associes             .
c .        .     .        . 8. 1, si aux noeuds par elements           .
c .        .     .        .    2, si aux points de Gauss, associe avec .
c .        .     .        .       un champ aux noeuds par elements     .
c .        .     .        .    3, si aux points de Gauss autonome      .
c .        .     .        .    0, sinon                                .
c .        .     .        . 9. numero du 1er tableau dans la fonction  .
c .        .     .        . 10. si champ elga, numero du champ elno    .
c .        .     .        .     si champ elno, numero du champ elga si .
c .        .     .        .     il existe, sinon -1                    .
c .        .     .        . 11. type interpolation                     .
c .        .     .        .       0, si automatique                    .
c .        .     .        .       1 si degre 1, 2 si degre 2,          .
c .        .     .        .       3 si iso-P2                          .
c .        .     .        . 12. type de champ edfl64/edin64            .
c .        .     .        . 21-nbinec. type des supports associes      .
c . caraca . e   . nbincc*. caracteristiques caracteres des tableaux   .
c .        .     . nbtvch . du champ en cours d'examen                 .
c .        .     .        . 1. nom de l'objet fonction                 .
c .        .     .        . 2. nom de l'objet profil, blanc sinon      .
c .        .     .        . 3. nom de l'objet localisation des points  .
c .        .     .        . de Gauss, blanc sinon                      .
c . nbfonc . es  .   1    . nombre de fonctions classees               .
c . defonc . es  . nbinec*. description des fonctions en entier        .
c .        .     . nbfonc . 1. type de support au sens MED             .
c .        .     .        . 2. nombre de points de Gauss               .
c .        .     .        . 3. nombre de valeurs                       .
c .        .     .        . 4. nombre de valeurs du profil eventuel    .
c .        .     .        . 5. nombre de supports associes             .
c .        .     .        . 6. 1, si aux noeuds par elements           .
c .        .     .        .    2, si aux points de Gauss, associe avec .
c .        .     .        .       un champ aux noeuds par elements     .
c .        .     .        .    3, si aux points de Gauss autonome      .
c .        .     .        .    0, sinon                                .
c .        .     .        . 7. nombre de tableaux de ce type           .
c .        .     .        . 8. numero du tableau dans la fonction      .
c .        .     .        . 9. numero de la fonction associee si champ .
c .        .     .        .    aux noeuds par element ou points de Gaus.
c .        .     .        . 10. numero HOMARD du champ associe         .
c .        .     .        . 11. type interpolation                     .
c .        .     .        .       0, si automatique                    .
c .        .     .        .       1 si degre 1, 2 si degre 2,          .
c .        .     .        .       3 si iso-P2                          .
c .        .     .        . 21-nbinec. type des supports associes      .
c . nofonc . e   .3*nbfonc. description des fonctions en caracteres    .
c .        .     .        . 1. nom de l'objet profil, blanc sinon      .
c .        .     .        . 2. nom de l'objet fonction                 .
c .        .     .        . 3. nom de l'objet localisation des points  .
c .        .     .        . de Gauss, blanc sinon                      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .        .     .        . 100 : aucune fonction semblable au champ   .
c .        .     .        .       n'a ete trouvee                      .
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
      parameter ( nompro = 'ESLCH4' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "esutil.h"
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer nrocha
      integer nbcomp, nbtvch
      integer nbfonc
      integer caraen(nbinec,nbtvch)
      integer defonc(nbinec,nbfonc)
c
      character*8 nofonc(3,nbfonc)
      character*8 obcham
      character*8 caraca(nbincc,nbtvch)
      character*64 nomcha
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer typenh
      integer nbvalc
      integer nrotv, nrfonc
      integer numdt, numit
      integer nbpg
      integer nrtafo
      integer typgeo, ngauss, nbenmx, nbvapr, nbtyas
      integer carsup, nbtafo, typint, typcha
      integer advale, advalr, adobch, adprpg, adtyas
      integer adtra1
      integer adlipr
c
      logical trouve
c
      character*8 ntrav1
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
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
      texte(1,4) = '(''Numero du champ :'',i5)'
      texte(1,5) =
     > '(''Aucune fonction n''''a les caracteristiques du champ.'')'
c
      texte(2,4) = '(''Field # :'',i5)'
      texte(2,5) =
     > '(''No function with same characteristics than the field.'')'
c
#include "impr03.h"
c
#include "esimpr.h"
c
c====
c 2. on parcourt tous les tableaux
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,32)) nomcha
      write (ulsort,texte(langue,4)) nrocha
      write (ulsort,texte(langue,111)) nbtvch
#endif
c
      codret = 0
c
      do 20 , nrotv = 1 , nbtvch
c
c 2.1. ==> on cherche quelle fonction deja enregistree a les
c          memes caracteristiques de support, de points de Gauss et
c          de profil, meme type d'interpolation
c          si on ne la trouve pas, malaise ...
c
        if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,38)) 'caraen/caraca', nrotv
        write (ulsort,texte(langue,64)) caraen(1,nrotv)
        write (ulsort,texte(langue,113)) caraen(2,nrotv)
        write (ulsort,texte(langue,114)) caraen(3,nrotv)
        write (ulsort,texte(langue,57)) caraen(4,nrotv)
        write (ulsort,texte(langue,58)) caraen(5,nrotv)
        write (ulsort,texte(langue,62)) caraen(6,nrotv)
        do 2111 , iaux = 1 , caraen(7,nrotv)
          write (ulsort,texte(langue,60)) caraen(20+iaux,nrotv)
 2111   continue
        if ( caraen(11,nrotv).ge.0 .and. caraen(11,nrotv).le.3 ) then
          write (ulsort,texte(langue,100+caraen(11,nrotv)))
        else
          write (ulsort,texte(langue,104))
        endif
        write (ulsort,texte(langue,65+caraen(8,nrotv)))
        write (ulsort,texte(langue,61)) caraca(2,nrotv)
        write (ulsort,texte(langue,81)) caraca(3,nrotv)
#endif
c
        trouve = .false.
c
        do 21 , iaux = 1 , nbfonc
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) 'Fonction numero ', iaux
          write (ulsort,*) ' . defonc(1,iaux)  = ', defonc(1,iaux)
          write (ulsort,*) ' . defonc(2,iaux)  = ', defonc(2,iaux)
          write (ulsort,*) ' . defonc(5,iaux)  = ', defonc(5,iaux)
          write (ulsort,*) ' . defonc(11,iaux) = ', defonc(11,iaux)
          write (ulsort,*) ' . nofonc(1,iaux) = ', nofonc(1,iaux)
          write (ulsort,*) ' . nofonc(3,iaux) = ', nofonc(3,iaux)
#endif
          if ( defonc( 1,iaux).eq.caraen( 1,nrotv) .and.
     >         defonc( 2,iaux).eq.caraen( 4,nrotv) .and.
     >         defonc( 5,iaux).eq.caraen( 7,nrotv) .and.
     >         defonc(11,iaux).eq.caraen(11,nrotv) .and.
     >         defonc(12,iaux).eq.caraen(12,nrotv) .and.
     >         nofonc(1,iaux).eq.caraca(2,nrotv) .and.
     >         nofonc(3,iaux).eq.caraca(3,nrotv) ) then
c
            trouve = .true.
c
cgn            write (ulsort,*) ' ... defonc(6,iaux) = ', defonc(6,iaux)
            if ( defonc(6,iaux).ne.0 ) then
cgn        write (ulsort,*) ' ..... defonc(10,iaux) = ', defonc(10,iaux)
              if ( defonc(10,iaux).ne.nrocha ) then
                trouve = .false.
              endif
            endif
c
            if ( trouve ) then
              nrfonc = iaux
              goto 220
            endif
c
          endif
c
   21   continue
c
        write (ulsort,texte(langue,32)) nomcha
        write (ulsort,texte(langue,111)) nbtvch
        write (ulsort,texte(langue,5))
        codret = 100
c
        endif
c
c 2.2. ==> recuperation de la fonction
c
  220   continue
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro,nofonc(2,nrfonc))
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
        call utcafo ( nofonc(2,nrfonc),
     >                typcha,
     >                typgeo, ngauss, nbenmx, nbvapr, nbtyas,
     >                carsup, nbtafo, typint,
     >                advale, advalr, adobch, adprpg, adtyas,
     >                ulsort, langue, codret )
c
c
        endif
c
        if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) ' '
        write (ulsort,texte(langue,36)) nompro, nrfonc
        write (ulsort,texte(langue,64)) typgeo
        write (ulsort,texte(langue,60)) nbtyas
        write (ulsort,texte(langue,111)) nbtafo
        write (ulsort,texte(langue,57)) ngauss
        write (ulsort,texte(langue,58)) nbenmx
        write (ulsort,texte(langue,62)) nbvapr
        write (ulsort,90002) 'typcha', typcha
#endif
c
        caraca(1,nrotv) = nofonc(2,nrfonc)
        if ( nbvapr.gt.0 ) then
          nbvalc = nbvapr
        else
          nbvalc = nbenmx
        endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '==> nbvalc = ',nbvalc
#endif
c
        endif
c
c 2.3. ==> decodage eventuel du profil
c
        if ( codret.eq.0 ) then
c
        if ( nbvapr.gt.0 ) then
          iaux = nbvapr
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPR', nompro
#endif
          call utcapr ( caraca(2,nrotv),
     >                  nbvapr, noprof, adlipr,
     >                  ulsort, langue, codret )
          if ( nbvapr.ne.iaux ) then
            codret = 23
          endif
        else
          noprof = blan64
        endif
c
        endif
c
c 2.4. ==> lecture
c
c 2.4.1. ==> caracteristiques
c
cgn                  print *,'Avant 2.4.1, codret = ',codret
        if ( codret.eq.0 ) then
c
        numdt  = caraen(2,nrotv)
        numit = caraen(3,nrotv)
cgn      print *,'numdt, numit, ngauss = ',numdt, numit, ngauss
        if ( ngauss.eq.ednopg ) then
          nbpg = 1
        else
          nbpg = ngauss
        endif
c
        if ( typgeo.eq.0 ) then
          typenh = ednoeu
        else
          if ( caraen(8,nrotv).eq.1 ) then
            typenh = ednoma
          else
            typenh = edmail
          endif
        endif
c
        endif
c
c 2.4.2. ==> allocation d'un tableau de travail
c            remarque : on est oblige d'allouer au nombre maximal de
c                       valeurs, meme dans le cas de profil.
c
        if ( codret.eq.0 ) then
        iaux = nbenmx*nbpg*nbcomp
cgn      print *,
cgn     >'nbenmx*nbpg*nbcomp=',nbenmx,'*',nbpg,'*',nbcomp,'=',iaux
        if ( typcha.eq.edfl64 ) then
          call gmalot ( ntrav1, 'reel    ', iaux, adtra1, codret )
        else
          call gmalot ( ntrav1, 'entier  ', iaux, adtra1, codret )
        endif
        endif
c
c 2.4.3. ==> lecture MED brutale
c
c    . Sans points de Gauss :
c    Dans la phase de transfert dans les tableaux HOMARD, le tableau
c    trav1 sera declare ainsi : trav1(nbpg,nbvalc,nbcomp), ce qui
c    corrrespond a trav1(nbvalc,nbcomp) sans points de Gauss.
c
c    En fortran, cela correspond au stockage memoire suivant :
c    trav1(1,1), trav1(2,1), trav1(3,1), ..., trav1(nbvalc,1),
c    trav1(1,2), trav1(2,2), trav1(3,2), ..., trav1(nbvalc,2),
c    ...
c    trav1(1,nbcomp), trav1(2,nbcomp), ..., trav1(nbvalc,nbcomp)
c    on a ainsi toutes les valeurs pour la premiere composante, puis
c    toutes les valeurs pour la seconde composante, etc.
c
c    . Avec nbpg points de Gauss :
c    Dans la phase de transfert dans les tableaux HOMARD, le tableau
c    trav1 sera declare ainsi : trav1(nbpg,nbvalc,nbcomp).
c
c    En fortran, cela correspond au stockage memoire suivant :
c    trav1(1,1,1), trav1(2,1,1), ..., trav1(nbpg,1,1), trav1(1,2,1),
c    trav1(2,2,1), ..., trav1(nbpg,2,1), trav1(1,3,1), ...,
c    trav1(1,nbvalc,1), trav1(2,nbvalc,1), ..., trav1(nbpg,nbvalc,1),
c    trav1(1,1,2), trav1(2,1,2), ..., trav1(nbpg,1,2), trav1(1,2,2),
c    trav1(2,2,2), ..., trav1(nbpg,2,2), trav1(1,3,2), ...,
c    trav1(1,nbvalc,2), trav1(2,nbvalc,2), ..., trav1(nbpg,nbvalc,2),
c    ...
c    trav1(1,1,nrcomp), trav1(2,1,nrcomp), ..., trav1(nbpg,1,nrcomp),
c    trav1(1,2,nrcomp), trav1(2,2,nrcomp), ..., trav1(nbpg,2,nrcomp),
c    trav1(1,3,nrcomp), ..., trav1(nbpg,nbvalc,nrcomp)
c    on a ainsi tous les points de Gauss de la premiere maille de la
c    premiere composante, puis tous les points de Gauss de la
c    deuxieme maille de la premiere composante, etc. jusqu'a la fin de
c    la premiere composante. Ensuite on recommence avec la deuxieme
c    composante.
c
c    . Remarque : C'est ce que MED appelle le mode non entrelace.
c
c    . Remarque : il faut lire selon ce mode non entrelace car on n'est
c                 jamais certain de la numerotation des mailles.
c
cgn                  print *,'Avant 2.3.3, codret = ',codret
cgn      print *,'idfmed = ',idfmed
cgn          write (ulsort,texte(langue,32)) nomcha
cgn          write (ulsort,texte(langue,113)) numdt
cgn          write (ulsort,texte(langue,114)) numit
cgn          write (ulsort,texte(langue,61)) noprof
cgn      print *,'rmem(adtra1) = ',rmem(adtra1)
cgn      print *,'ednoin, edall, edstco = ', ednoin, edall, edstco
cgn      print *,'typenh, typgeo, numdt, numit = ',
cgn     >typenh, typgeo,numdt, numit
        if ( codret.eq.0 ) then
        if ( typcha.eq.edfl64 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MFDRPR', nompro
#endif
          call mfdrpr ( idfmed, nomcha, numdt, numit,
     >                  typenh, typgeo,
     >                  edstco, noprof, ednoin, edall,
     >                  rmem(adtra1), codret )
        else
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MFDIPR', nompro
#endif
          call mfdipr ( idfmed, nomcha, numdt, numit,
     >                  typenh, typgeo,
     >                  edstco, noprof, ednoin, edall,
     >                  imem(adtra1), codret )
        endif
c
cgn      print *,'codret de mfdrpr = ',codret
cgn      print *,'rmem(adtra1) = ',rmem(adtra1)
cgn      print *,'rmem(adtra1+1) = ',rmem(adtra1+1)
cgn      print *,'rmem(final-1) = ',rmem(adtra1+nbenmx*nbpg*nbcomp-2)
cgn      print *,'rmem(final) = ',rmem(adtra1+nbenmx*nbpg*nbcomp-1)
cgn      print *,'noprof = ',noprof
cgn      print 1789,
cgn     > (rmem(iaux),iaux=adtra1,adtra1+nbenmx*nbpg*nbcomp-1)
cgn 1789 format(12g14.6)
cgn          nrtafo=0
cgn           do 4444,iaux=0,143511
cgn                if ( rmem(adtra1+iaux).gt.1.d-7) nrtafo=nrtafo+1
cgn 4444       continue
cgn                print *,nrtafo
        if ( codret.ne.0 ) then
          write (ulsort,texte(langue,18)) nomcha
          write (ulsort,texte(langue,113)) numdt
          write (ulsort,texte(langue,114)) numit
          write (ulsort,texte(langue,61)) noprof
        endif
        endif
cgn        if ( nbpg.gt.1 ) then
cgncc        if ( nbpg.gt.1 .or. typgeo.eq.206 ) then
cgn          call gmprsx (nompro, ntrav1 )
cgn          print *,'en mode non entrelace'
cgn          print 1789,
cgn     >     (rmem(iaux),iaux=adtra1,adtra1+nbvalc*nbcomp*nbpg-1)
cgn 1789     format(12g14.6)
cgn           iaux = nbvalc*nbpg*nbcomp
cgn        call toto1 ( iaux, rmem(adtra1), ulsort )
cgn           iaux = nbvalc*nbpg
cgn        call toto2 ( iaux, nbcomp,rmem(adtra1), ulsort )
cgn        call toto3 ( nbpg, nbvalc,nbcomp,rmem(adtra1), ulsort )
cgn        endif
c
c 2.5. ==> le profil (eventuellement)
c
        if ( codret.eq.0 ) then
c
        smem(adprpg) = caraca(2,nrotv)
c
        endif
c
c 2.6. ==> la localisation des points de Gauss (eventuellement)
c
        if ( codret.eq.0 ) then
c
        smem(adprpg+1) = caraca(3,nrotv)
c
        endif
c
c 2.7. ==> transfert, composante par composante
c
cgn                  print *,'Avant 2.6, codret = ',codret
        if ( codret.eq.0 ) then
c
        nrtafo = defonc(8,nrfonc)
c
        caraen(9,nrotv) = nrtafo
c
        if ( typcha.eq.edfl64 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'ESLCH5', nompro
#endif
          call eslch5 ( nrtafo,
     >                  nbtafo, nbpg, nbvalc, nbcomp,
     >                  rmem(advalr), rmem(adtra1),
     >                  obcham, smem(adobch),
     >                  ulsort, langue, codret )
c
        else
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'ESLCH8', nompro
#endif
          call eslch8 ( nrtafo,
     >                  nbtafo, nbpg, nbvalc, nbcomp,
     >                  imem(advale), imem(adtra1),
     >                  obcham, smem(adobch),
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        defonc(8,nrfonc) = nrtafo
c
        endif
c
c 2.8. ==> liberation du tableau de lecture
c
        if ( codret.eq.0 ) then
          call gmlboj ( ntrav1, codret )
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
cgn        call gmprsx (nompro,nofonc(2,nrfonc)//'.ValeursR')
        call gmprot (nompro,nofonc(2,nrfonc)//'.ValeursR',1,100)
        call gmprsx (nompro,nofonc(2,nrfonc)//'.InfoCham')
        call gmprsx (nompro,nofonc(2,nrfonc)//'.InfoPrPG')
        endif
#endif
c
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
