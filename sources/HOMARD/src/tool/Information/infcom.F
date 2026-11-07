      subroutine infcom ( lgopti, taopti, lgopts, taopts,
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
c  INformation - inFormation COMplementaires
c  --              -         ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'INFCOM' )
c
#include "nblang.h"
#include "motcle.h"
#include "consts.h"
c
      integer nbrcas
      parameter ( nbrcas = 5 )
c
c 0.2. ==> communs
c
#include "indefs.h"
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
#include "envex1.h"
#include "impr02.h"
#include "meddc0.h"
c
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombqu.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
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
      integer iaux, jaux, kaux
      integer nrsect
      integer nbrca0
      integer tab(-2:7,nbrcas)
      integer numcas
      integer nbcham, nucham, nbpafo, nupafo, nbtvch, nutvch, nbtafo
      integer adinch
      integer adinpf
      integer adcaen, adcare, adcaca
      integer typenh
      integer nbento, nbencf, nbenca
      integer typgeo
      integer lnocmd
c
      integer   sdim,   mdim
      integer  degre, maconf, homolo, hierar
      integer rafdef, nbmane, typcca, typsfr, maextr
      integer mailet
c
      integer caopti(nbrcas), nbcomp(nbrcas), coderf(nbrcas)
c
      integer nparrc, nptrrc, npqurc
      integer npterc, npherc, npperc, nppyrc
      integer adarrc, adtrrc, adqurc
      integer adterc, adherc, adperc, adpyrc
      integer npenrc, adenrc
c
      character*2 saux02
      character*8 typobs
      character*8 nocsol
      character*8 nhenti
      character*8 canotr(nblang,nbrcas)
      character*16 nomcom(12), unicom(12)
      character*64 nochmd
c
      character*8 obcham
      character*8 nohmai
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      data coderf / 2, 3, 5, 7, 11 /
      data nbcomp / 1, 1, 1, 1, 12 /
      data caopti / 0, 0, 0, 0, 0 /
      data canotr / 'Niveau  ', 'Level   ',
     >              'Qualite ', 'Quality ',
     >              'Diametre', 'Diameter',
     >              'Parent  ', 'Parent  ',
     >              'VoisinHo', 'NeighbHo' /
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
      texte(1,4) = '(''Creation de l''''objet '', a8)'
      texte(1,5) = '(''Type de traitement : '', a)'
      texte(1,6) = '(''.. Examen des'',i10,1x,a)'
c
      texte(2,4) = '(''Creation of the object '', a8)'
      texte(2,5) = '(''Type of treatment: '', a)'
      texte(2,6) = '(''.. Examination of the'',i10,1x,a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'taopti(12)', taopti(12)
#endif
c
c====
c 2. le maillage homard
c====
c
      typobs = mchmap
      iaux = 0
      call utosno ( typobs, nohmai, iaux, ulsort, langue, codret )
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nohmai,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. Tri des options
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Tri des options ; codret', codret
#endif
c
c 3.1. ==> En l'absence de recollement, on supprime ce choix
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90003) 'nospec', taopts(20)
#endif
      if ( taopts(20).eq.sindef ) then
        nbrca0 = nbrcas - 1
      else
        call gmobal ( taopts(20), codret )
        if ( codret.eq.1 ) then
          nbrca0 = nbrcas
          codret = 0
        else
          nbrca0 = nbrcas - 1
        endif
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbrcas', nbrcas
      write (ulsort,90002) 'nbrca0', nbrca0
#endif
c
c 3.2. ==> Decodage de l'option
c
      nbcham = 0
c
      do 32 , iaux = 1, nbrca0
c
        if ( mod(taopti(12),coderf(iaux)).eq.0 ) then
          caopti(iaux) = 1
          nbcham = nbcham + 1
          write (ulsort,texte(langue,5)) canotr(langue,iaux)
        else
          caopti(iaux) = 0
        endif
c
   32 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'caopti', caopti
#endif
c
c====
c 4. Allocation de la structure de tete
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Allocation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFC00', nompro
#endif
      call infc00 ( nbrca0, caopti, nbcham,
     >              tab,
     >              nocsol, nbpafo,
     >              adinch, adinpf,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      do 4444 , iaux = 1, nbrca0
      write (ulsort,90015) 'tab de', iaux,' :',
     >                     (tab(jaux,iaux),jaux=-2,7)
 4444 continue
      write (ulsort,90002) 'nbcham', nbcham
      write (ulsort,texte(langue,4)) nocsol
#endif
c
      if ( nbcham.eq.0 ) then
        taopti(12) = 1
      else
        taopts(31) = nocsol
      endif
c
      endif
c
c====
c 5. Remplissage champs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Remplissage ; codret', codret
#endif
c
      nucham = 0
      nupafo = 0
c
      do 51 , kaux = 1 , nbrca0
c
        if ( codret.eq.0 ) then
c
        numcas = kaux
        nbtvch = tab(-2,numcas)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'numcas', numcas
      write (ulsort,90002) 'nbtvch', nbtvch
#endif
c
        if ( nbtvch.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) "Cas de "//canotr(langue,numcas)
#endif
c
          nrsect = 90 + kaux
          call gtdems (nrsect)
c
          nutvch = 0
c
c 5.1. ==> Nom du champ
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.1. Nom du champ ; codret', codret
#endif
c
          if ( codret.eq.0 ) then
c
          nochmd = blan64
          if ( numcas.eq.1 ) then
            typobs = mcicni
          elseif ( numcas.eq.2 ) then
            typobs = mcicqu
          elseif ( numcas.eq.3 ) then
            typobs = mcicdi
          elseif ( numcas.eq.4 ) then
            typobs = mcicpa
          elseif ( numcas.eq.5 ) then
            typobs = mcicvr
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90003) 'typobs', typobs
#endif
          iaux = 0
          jaux = 1
          call utfino ( typobs, iaux, nochmd, lnocmd,
     >                  jaux,
     >                  ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) nochmd(1:lnocmd), lnocmd
#endif
c
          endif
c
c 5.2. ==> Adresses pour le recollement
c
          if ( numcas.eq.5 ) then
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
            call gmprsx ( nompro, taopts(20) )
#endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD41', nompro
#endif
            call utad41 ( taopts(20),
     >                    nparrc, nptrrc, npqurc,
     >                    npterc, npherc, npperc, nppyrc,
     >                    adarrc, adtrrc, adqurc,
     >                    adterc, adherc, adperc, adpyrc,
     >                    ulsort, langue, codret)
c
          endif
c
        endif
c
c 5.2. ==> Structures d'information sur les champs
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.2. InfoCham ; codret', codret
#endif
c
          if ( codret.eq.0 ) then
c
          nucham = nucham + 1
          nbtafo = nbcomp(numcas)
          do 52 , iaux = 1 , nbtafo
            nomcom(iaux) = blan16
            nomcom(iaux)(1:1) = 'V'
            if ( iaux.gt.1 ) then
              call utench ( iaux, '0', jaux, saux02,
     >                      ulsort, langue, codret )
              nomcom(iaux)(2:3) = saux02
            endif
            unicom(iaux) = blan16
   52     continue
          if ( numcas.le.3 ) then
            iaux = edfl64
          else
            iaux = edint
          endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFC01', nompro
#endif
          call infc01 ( nbtvch,
     >                  adinch,
     >                  nucham, nochmd, iaux,
     >                  nbtafo, nomcom, unicom,
     >                  obcham, adcaen, adcare, adcaca,
     >                  ulsort, langue, codret )
c
          endif
c
c 5.3. ==> Remplissage
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.3. Remplissage ; codret', codret
#endif
c
          do 53 , typenh = -1 , 7
c
            jaux = tab(typenh,numcas)
            if ( jaux.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) jaux, mess14(langue,3,typenh)
#endif
c
            if ( codret.eq.0 ) then
c
            nupafo = nupafo + 1
            nutvch = nutvch + 1
            nbencf = 0
            nbenca = 0
c
            if ( typenh.eq.-1 ) then
              nhenti = nhnoeu
              nbento = nbnoto
              typgeo = 0
            elseif ( typenh.eq.0 ) then
              nhenti = nhmapo
              nbento = nbmpto
              typgeo = edpoi1
            elseif ( typenh.eq.1 ) then
              nhenti = nharet
              nbento = nbarto
              if ( degre.eq.1 ) then
                typgeo = edseg2
              else
                typgeo = edseg3
              endif
           elseif ( typenh.eq.2 ) then
              nhenti = nhtria
              nbento = nbtrto
              if ( degre.eq.1 ) then
                typgeo = edtri3
              else
                typgeo = edtri6
              endif
            elseif ( typenh.eq.3 ) then
              nhenti = nhtetr
              nbento = nbteto
              nbencf = nbtecf
              nbenca = nbteca
              if ( degre.eq.1 ) then
                typgeo = edtet4
              else
                typgeo = edte10
              endif
            elseif ( typenh.eq.4 ) then
              nhenti = nhquad
              nbento = nbquto
              if ( degre.eq.1 ) then
                typgeo = edqua4
              else
                typgeo = edqua8
              endif
            elseif ( typenh.eq.5 ) then
              nhenti = nhpyra
              nbento = nbpyto
              nbencf = nbpycf
              nbenca = nbpyca
              if ( degre.eq.1 ) then
                typgeo = edpyr5
              else
                typgeo = edpy13
              endif
            elseif ( typenh.eq.6 ) then
              nhenti = nhhexa
              nbento = nbheto
              nbencf = nbhecf
              nbenca = nbheca
              if ( degre.eq.1 ) then
                typgeo = edhex8
              else
                typgeo = edhe20
              endif
              npenrc = npqurc
              adenrc = adherc
#ifdef _DEBUG_HOMARD_
              if ( numcas.eq.5 ) then
                call gmprsx ( nompro, taopts(20)//'.Tab5' )
              endif
#endif
            elseif ( typenh.eq.7 ) then
              nhenti = nhpent
              nbento = nbpeto
              nbencf = nbpecf
              nbenca = nbpeca
              if ( degre.eq.1 ) then
                typgeo = edpen6
              else
                typgeo = edpe15
              endif
            endif
c
            iaux = typenh
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3))
     >      'INFC02 - '//mess14(langue,3,typenh), nompro
#endif
            call infc02 ( numcas,
     >                    iaux, nhenti, nbento, nbencf, nbenca,
     >                    nbtvch, nutvch,
     >                    nbtafo, jaux, typgeo,
     >                    obcham, nupafo, smem(adinpf),
     >                    nhnoeu, nharet, nhtria, nhquad,
     >                    nhhexa, nhpent, norenu,
     >                    imem(adcaen), rmem(adcare), smem(adcaca),
     >                    npenrc, imem(adenrc),
     >                    ulsort, langue, codret )
c
            endif
c
            endif
c
   53     continue
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,90015) 'OBJET InfoCham'
          call gmprsx ( nompro, obcham )
          call gmprsx ( nompro, obcham//'.Nom_Comp' )
          call gmprsx ( nompro, obcham//'.Cham_Ent' )
          call gmprsx ( nompro, obcham//'.Cham_Ree' )
          call gmprsx ( nompro, obcham//'.Cham_Car' )
          endif
#endif
c
          call gtfims (nrsect)
c
        endif
c
        endif
c
   51 continue
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90015) 'OBJET Solution'
      call gmprsx ( nompro, nocsol//'.InfoCham' )
      call gmprsx ( nompro, nocsol//'.InfoPaFo' )
cgn      call gmprsx ( nompro, '%%%%%%10' )
cgn      call gmprsx ( nompro, '%%%%%%%9' )
cgn      call gmprsx ( nompro, '%%%%%%%9.ValeursE' )
cgn      call gmprsx ( nompro, '%%%%%%19' )
cgn      call gmprsx ( nompro, '%%%%%%18' )
cgn      call gmprsx ( nompro, '%%%%%%18.ValeursE' )
      endif
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbrca0.eq.5 ) then
        call gmlboj ( taopts(20), codret )
        taopts(20) = sindef
      endif
c
      endif
c
c====
c 6. pour le cas extrude, passage du 2D au 3D
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Cas extrude ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( taopti(39).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSEXT', nompro
#endif
        iaux = 2
        call utsext ( nocsol, iaux, taopti(11),
     >                lgetco, taetco,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 7. la fin
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
