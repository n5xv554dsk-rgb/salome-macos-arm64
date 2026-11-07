      subroutine eslsm5 ( nbfonc, defonc, nofonc, nbseal,
     >                    nbpafo, noinpf, option,
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
c  Entree-Sortie - Lecture d'une Solution au format MED - phase 5
c  -      -        -             -                  -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .   1    . nombre de fonctions                        .
c . defonc . e   . nbinec*. description des fonctions en entier        .
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
c . nbseal . e   .    1   . nombre de sequences a lire                 .
c .        .     .        . si -1, on lit tous les champs du fichier   .
c . nbpafo .   s .   1    . nombre de paquets de fonctions             .
c . noinpf .   s . nbpafo . nom des objets qui contiennent la          .
c .        .     .        . description de chaque paquet de fonctions  .
c . option . e   .   1    . 1 : on controle que l'on a les couples (aux.
c .        .     .        . noeuds par element/aux points de Gauss)    .
c .        .     .        . 0 : pas de controle                        .
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
      parameter ( nompro = 'ESLSM5' )
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
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer nbfonc, nbpafo, nbseal
      integer defonc(nbinec,*)
      integer option
c
      character*8 nofonc(3,nbfonc), noinpf(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux, maux, naux
      integer nrfonc, nrinpf, nbfopa, nrpafo
      integer nrofon
      integer typcha
      integer typgeo, ngauss, nbenmx, nbvapr, nbtyas
      integer carsup, typint, nbtafo
      integer advale, advalr, adobch, adprpg, adtyas
      integer typch2
      integer typge2, ngaus2, nbenm2, nbvap2, nbtya2
      integer carsu2, nbtaf2, typin2
      integer advae2, advar2, adobc2, adobp2, adtya2
      integer adobfo, adtyge
      integer adobf2, adtyg2
      integer typgpf, ngaupf, carspf, typipf
      integer tbiaux(nbinec)
c
      character*8 nomfon, saux08
      character*8 obpafo
      character*8 tbsaux(1)
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      tbsaux(1) = blan08
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
      texte(1,4) = '(''Creation du paquet de fonctions '',i3,'' : '',a)'
      texte(1,5) =
     > '(''Ajout de la '',i3,''-eme fonction dans le paquet '',a)'
      texte(1,6) = '(''Impossible de trouver la fonction.'')'
      texte(1,7) = '(''Impossible de trouver le paquet.'')'
      texte(1,8) = '(''Nombre de paquets crees :'',i8)'
c
      texte(2,4) = '(''Creation of pack of functions # '',i3,'' : '',a)'
      texte(2,5) = '(''Addition of '',i3,''-th function in pack '',a)'
      texte(2,6) = '(''Function cannot be found.'')'
      texte(2,7) = '(''Pack cannot be found.'')'
      texte(2,8) = '(''Number of created packs :'',i8)'
c
#include "impr03.h"
c
      nbpafo = 0
c
c====
c 2. regroupement des fonctions en paquets
c====
c
      do 20 , nrfonc = 1 , nbfonc
c
c 2.1. ==> caracteristiques de la fonction a ranger
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,36)) nompro, nrfonc
        call gmprsx (nompro, nofonc(2,nrfonc) )
cgn        call gmprsx (nompro, nofonc(2,nrfonc)//'.InfoCham' )
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'utcafo', nompro
#endif
        call utcafo ( nofonc(2,nrfonc),
     >                typcha,
     >                typgeo, ngauss, nbenmx, nbvapr, nbtyas,
     >                carsup, nbtafo, typint,
     >                advale, advalr, adobch, adprpg, adtyas,
     >                ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'Fonction numero ', nrfonc
        write (ulsort,90002) 'typgeo', typgeo
        write (ulsort,90002) 'ngauss', ngauss
        write (ulsort,90002) 'nbenmx', nbenmx
        write (ulsort,90002) 'nbvapr', nbvapr
        write (ulsort,90002) 'nbtyas', nbtyas
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,90002) 'typint', typint
        write (ulsort,90002) 'nbtafo', nbtafo
        write (ulsort,90003) 'champ ', smem(adobch)
        write (ulsort,*) 'Profil   ', smem(adprpg)
        write (ulsort,*) 'Loca PG  ', smem(adprpg+1)
        write (ulsort,*) 'Fonc. As.', smem(adprpg+2)
#endif
c
        endif
c
c 2.2. ==> on recherche s'il existe un paquet convenable
c
        nrinpf = 0
c
        do 22 , iaux = 1 , nbpafo
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) '. Examen du paquet numero', iaux
#endif
c
c 2.2.1. ==> caracteristiques de l'iaux-eme paquet de fonction
c
          if ( codret.eq.0 ) then
c
          obpafo = noinpf(iaux)
c
#ifdef _DEBUG_HOMARD_
          call gmprsx (nompro, obpafo )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
          call utcapf ( obpafo,
     >                  nbfopa, typgpf, ngaupf, carspf, typipf,
     >                  adobfo, adtyge,
     >                  ulsort, langue, codret )
cgn        write (ulsort,90002) 'kaux/tnpass', kaux
cgn        write (ulsort,90002) 'laux/ngauss', laux
cgn        write (ulsort,90002) 'maux/carsup', maux
cgn        write (ulsort,90002) 'naux/typint', naux
c
          endif
c
c 2.2.2. ==> le paquet convient si le support geometrique est
c            simple, tout est identique
c
          if ( typgpf.gt.0 ) then
c
            if ( typgeo.eq.typgpf .and.
     >           ngauss.eq.ngaupf .and.
     >           carsup.eq.carspf .and.
     >           typint.eq.typipf ) then
              nrinpf = iaux
              goto 23
            endif
c
c 2.2.3. ==>  ou ... si le support est multiple, le champ est le meme
c
          elseif ( typgpf.lt.0 ) then
c
              do 223 , jaux = 1 , nbfopa
c
                if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'utcafo', nompro
#endif
c
                call utcafo ( smem(adobfo+jaux-1),
     >                        typch2,
     >                        typge2, ngaus2, nbenm2, nbvap2, nbtya2,
     >                        carsu2, nbtaf2, typin2,
     >                        advae2, advar2, adobc2, adobp2, adtya2,
     >                        ulsort, langue, codret )
c
                endif
c
                if ( codret.eq.0 ) then
c
                if ( smem(adobch).eq.smem(adobc2) ) then
                  nrinpf = iaux
                  goto 23
                endif
c
                endif
c
  223         continue
c
            endif
c
   22   continue
c
c 2.3. ==> creation d'un nouveau paquet
c
   23   continue
c
        if ( nrinpf.eq.0 ) then
c
          if ( codret.eq.0 ) then
c
          nbfopa = 0
          if ( nbtyas.le.0 ) then
            typgpf = typgeo
          else
            typgpf = -(nbtyas+1)
          endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALPF', nompro
#endif
          call utalpf ( obpafo,
     >                  nbfopa, typgpf, ngauss, carsup, typint,
     >                  adobfo, adtyge,
     >                  ulsort, langue, codret )
c
          endif
#ifdef _DEBUG_HOMARD_
          call gmprsx ( nompro//' - apres UTALPF', obpafo )
#endif
c
          if ( codret.eq.0 ) then
c
          nbpafo = nbpafo + 1
          noinpf(nbpafo) = obpafo
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,4)) nbpafo, obpafo
#endif
c
          endif
c
          if ( nbtyas.gt.0 ) then
c
            if ( codret.eq.0 ) then
c
            do 231 ,iaux = 1 , nbtyas
              tbiaux(iaux) = imem(adtyas+iaux-1)
  231       continue
            tbiaux(nbtyas+1) = typgeo
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMOPF', nompro
#endif
c
            iaux = nbtyas+1
            jaux = 5
            call utmopf ( obpafo, jaux,
     >                    iaux, tbsaux, tbiaux,
     >                    nofonc(2,nrfonc),
     >                    nbfopa, kaux, laux, maux, naux,
     >                    adobfo,
     >                    ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
            call gmprsx (nompro, obpafo//'.TypeSuAs' )
#endif
c
            endif
c
          endif
c
        endif
c
c 2.4. ==> ajout de la fonction dans le paquet
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMOPF', nompro
#endif
c
        jaux = 1
        call utmopf ( obpafo, jaux,
     >                nbpafo, tbsaux, tbiaux,
     >                nofonc(2,nrfonc),
     >                nbfopa, kaux, laux, maux, naux,
     >                adobfo,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) nbfopa, obpafo
        call gmprsx (nompro, obpafo )
        call gmprsx (nompro, obpafo//'.Fonction' )
#endif
c
        endif
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,8)) nbpafo
      write (ulsort,93010) (noinpf(nrpafo),nrpafo = 1 , nbpafo)
      endif
#endif
c
c====
c 3. gestion des couples (aux noeuds par element/aux points de Gauss)
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. gestion des couples, codret',codret
#endif
c
      if ( option.eq.1 ) then
c
      do 30 , nrpafo = 1 , nbpafo
c
c 3.1. ==> caracteristiques du paquet
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'Paquet numero', nrpafo
#endif
c
        if ( codret.eq.0 ) then
c
        obpafo = noinpf(nrpafo)
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, obpafo )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
c
        call utcapf ( obpafo,
     >                nbfopa, nbtyas, ngauss, carsup, typint,
     >                adobfo, adtyge,
     >                ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,65+carsup))
        write (ulsort,90002) 'nbfopa', nbfopa
        write (ulsort,90002) 'nbtyas', nbtyas
        write (ulsort,90002) 'ngauss', ngauss
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,90002) 'typint', typint
        write (ulsort,93010) (smem(adobfo+iaux),' ',iaux=0,nbfopa)
#endif
c
        endif
c
c 3.2. ==> on poursuit si c'est un paquet aux noeuds par element ou
c          aux points de Gauss
c
        if ( carsup.ge.1 .and. carsup.le.2 ) then
c
c 3.2.1. ==> Recherche du numero global de la premiere des fonctions
c            du paquet
c
          if ( codret.eq.0 ) then
c
          nomfon = smem(adobfo)
          do 321 , iaux = 1 , nbfonc
            if ( nofonc(2,iaux).eq.nomfon ) then
              nrofon = iaux
              goto 3210
            endif
  321     continue
          codret = 4
          write (ulsort,texte(langue,6))
c
 3210     continue
c
          endif
c
c 3.2.2. ==> Numero global et nom de la fonction associee
c
          if ( codret.eq.0 ) then
c
          iaux = defonc(9,nrofon)
          saux08 = nofonc(2,iaux)
c
          endif
c
c 3.2.3. ==> Recherche du paquet contenant cette fonction associee
c            Rearque : inutile de chercher dans le paquet courant ...
c
          if ( codret.eq.0 ) then
c
          do 323 , iaux = 1 , nbpafo
c
            if ( iaux.ne.nrpafo ) then
c
              if ( codret.eq.0 ) then
c
              obpafo = noinpf(iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
              call utcapf ( obpafo,
     >                      jaux, kaux, laux, maux, naux,
     >                      adobf2, adtyg2,
     >                      ulsort, langue, codret )
c
              endif
c
              if ( codret.eq.0 ) then
c
              do 3231 , nrofon = 1 , jaux
                if ( smem(adobf2+nrofon-1).eq.saux08 ) then
                  smem(adobfo+nbfopa) = obpafo
                  goto 3230
                endif
 3231         continue
c
              endif
c
            endif
c
  323     continue
c
          if ( nbseal.gt.0 .and. carsup.eq.2 ) then
            write (ulsort,texte(langue,7))
            codret = 5
          endif
c
 3230     continue
c
          endif
c
        endif
c
   30 continue
c
      endif
c
c====
c 4. la fin
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

