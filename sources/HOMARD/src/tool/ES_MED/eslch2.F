      subroutine eslch2 ( idfmed, nomcha, numdtx, typcha,
     >                    nbtmed, litmed,
     >                    nbsqch, nbtvch, nbtvlu,
     >                    nbcham, nbseal, caetal, cartal,
     >                    caraen, carare, caraca,
     >                    nbprof, liprof,
     >                    nblopg, lilopg,
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
c  Entree-Sortie - Lecture d'un CHamp au format MED - phase 2
c  -      -        -            --                          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med en entree       .
c . nomcha . e   . char64 . nom du champ a lire                        .
c . numdtx . e   .    1   . numero du dernier pas de temps             .
c . typcha . e   .   1    . edin64/edfl64 selon entier/reel            .
c . nbtmed . e   .   1    . nombre de types MED                        .
c . litmed . e   .0:nbtmed. liste des types MED                        .
c . nbsqch . e   .   1    . nombre de sequences associees a ce champ   .
c . nbtvch . e   .    1   . nombre total de tableaux pour le champ     .
c . nbtvlu .  s  .    1   . nombre de tableaux effectivement lus       .
c . nbcham . e   .   1    . numero du dernier champ enregistre         .
c . nbseal . e   .    1   . nombre de sequences a lire                 .
c .        .     .        . si -1, on lit tous les champs du fichier   .
c . caetal . es  .  12 *  . caracteristiques entieres de chaque        .
c .        .     . nbseal . tableau a lire                             .
c .        .     .        . 1. type de support au sens MED             .
c .        .     .        .  -1, si on prend tous les supports         .
c .        .     .        . 2. 2, on prend le dernier pas de temps     .
c .        .     .        .    1, le numero du pas de temps est fourni .
c .        .     .        .    0, sinon                                .
c .        .     .        . 3. numero du pas de temps                  .
c .        .     .        . 4. 2, on prend le dernier numero d'ordre   .
c .        .     .        .    1, le numero d'ordre est fourni         .
c .        .     .        .    0, sinon                                .
c .        .     .        . 5. numero d'ordre                          .
c .        .     .        . 6. 2, on prend le dernier instant          .
c .        .     .        .    1, l'instant est fourni                 .
c .        .     .        .    0, sinon                                .
c .        .     .        . 7. 1, si aux noeuds par elements, 0 sinon, .
c .        .     .        .   -1, si non precise                       .
c .        .     .        . 8. numero du champ noeuds/element associe  .
c .        .     .        . 9. numero du champ associe dans HOMARD     .
c .        .     .        . 10. type d'interpolation                   .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  1 si degre 1, 2 si degre 2, 3 si iso-P2   .
c .        .     .        . 11. 1, s'il fait partie du champ en cours  .
c .        .     .        .    d'examen, 0, sinon                      .
c .        .     .        . 12. type de champ edfl64/edin64            .
c . cartal . e   . nbseal . caracteristiques reelles de chaque         .
c .        .     .        . tableau a lire                             .
c .        .     .        . 1. instant                                 .
c . caraen .  s  . nbinec*. caracteristiques entieres des tableaux du  .
c .        .     . nbtvch . champ en cours d'examen                    .
c .        .     .        . 1. type de support au sens MED             .
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
c . carare .  s  . nbtvch . caracteristiques reelles des tableaux      .
c .        .     .        . 1. valeur du pas de temps                  .
c . caraca .  s  . nbincc*. caracteristiques caracteres des tableaux   .
c .        .     . nbtvch . du champ en cours d'examen                 .
c .        .     .        . 1. nom de l'objet fonction                 .
c .        .     .        . 2. nom de l'objet profil, blanc sinon      .
c .        .     .        . 3. nom de l'objet localisation des points  .
c .        .     .        . de Gauss, blanc sinon                      .
c . nbprof . es  .   1    . nombre cumule de profils a lire            .
c . liprof .  s  .9*nbrpro. 1-8 : nom du -i-eme profil lu              .
c .        .     .        . 9 : nom de l'objet de type 'Profil' associe.
c . nblopg . es  .   1    . nombre cumule de localisations Gauss a lire.
c . lilopg .  s  .9*nbrlpg. 1-8 : nom de la -i-eme localisation lue    .
c .        .     .        . 9 : nom de l'objet de type 'LocaPG' associe.
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
      parameter ( nompro = 'ESLCH2' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "esutil.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer numdtx, typcha, nbsqch, nbtvch, nbtvlu, nbtmed
      integer nbcham, nbseal
      integer litmed(0:nbtmed)
      integer caraen(nbinec,nbtvch)
      integer caetal(12,*)
      integer nbprof, nblopg
c
      double precision cartal(*)
      double precision carare(nbtvch)
c
      character*8 caraca(nbincc,nbtvch)
      character*8 liprof(*)
      character*8 lilopg(*)
      character*64 nomcha
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      double precision epsilo
      parameter ( epsilo = 1.d-6 )
c
      integer iaux, jaux
      integer typent, typgeo
      integer nbval
      integer ngauss, nbvapr, carsup, typint
      integer numseq
      integer numdt, numit
      integer nrtmed
c
      character*8 obprof, oblopg
      character*64 nolopg
      character*64 noprof
      character*64 saux64
c
      double precision instan
c
      logical logaux
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
      texte(1,4) = '(''Lecture d''''un nouveau profil.'')'
      texte(1,5) =
     > '(''Lecture d''''une nouvelle localisation de Gauss.'')'
c
      texte(2,4) = '(''Readings of a new profile.'')'
      texte(2,5) = '(''Readings of a new Gauss localization.'')'
c
#include "esimpr.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,32)) nomcha
      write (ulsort,90002) 'Nombre de sequences a lire (nbseal)',nbseal
      write (ulsort,90002) 'Nombre total de sequences  (nbsqch)',nbsqch
      write (ulsort,90002) 'Dernier pas de temps (numdtx)', numdtx
#endif
c
c====
c 2. Si on veut le dernier pas de temps, on memorise sa valeur
c====
c
      do 20 , iaux = 1 , nbseal
c
        if ( caetal(2,iaux).eq.2 .or. caetal(6,iaux).eq.2 ) then
          caetal(2,iaux) = 2
          caetal(3,iaux) = numdtx
          caetal(6,iaux) = -2
        endif
c
   20 continue
c
c====
c 3. On parcourt les sequences du champ
c    Recuperation du pas de temps et numero d'iteration de la sequence
c====
c
      nbtvlu = 0
c
      do 30 , numseq = 1, nbsqch
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '----- Sequence numero', numseq
#endif
c
        if ( codret.eq.0 ) then
c
        iaux = numseq
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MFDCSI', nompro
#endif
        call mfdcsi ( idfmed, nomcha, iaux,
     >                numdt, numit, instan, codret )
        if ( codret.ne.0 ) then
          write (ulsort,texte(langue,17)) nomcha
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,113)) numdt
        write (ulsort,texte(langue,114)) numit
        write (ulsort,texte(langue,115)) instan
#endif
c
        endif
c
c====
c 4. On parcourt tous les types de support
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Exploration des supports, codret', codret
#endif
c
        do 40 , nrtmed = 0 , 2*nbtmed
c
c 4.1. ==> Le couple (typent,typgeo)
c
          if ( codret.eq.0 ) then
c
          if ( nrtmed.eq.0 ) then
            typent = ednoeu
            typgeo = litmed(nrtmed)
          elseif ( nrtmed.le.nbtmed ) then
            typent = edmail
            typgeo = litmed(nrtmed)
          else
            typent = ednoma
            typgeo = litmed(nrtmed-nbtmed)
          endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,texte(langue,60)) typent
      write (ulsort,texte(langue,64)) typgeo
#endif
c
          endif
c
c 4.2. ==> Nombre de profils pour cette sequence et cette entite
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDNPF', nompro
#endif
          call mfdnpf ( idfmed, nomcha,
     >                  numdt, numit, typent, typgeo,
     >                  noprof, nolopg, iaux, codret )
c
          if ( codret.ne.0 ) then
            write (ulsort,texte(langue,60)) typent
            write (ulsort,texte(langue,64)) typgeo
            write (ulsort,texte(langue,2)) codret
          endif
c
          endif
c
c 4.3. ==> Diagostic pour ce couple (typent,typgeo)
c  0 profil : aucune valeur n'est presente ; on passe au couple suivant
c >1 profil : HOMARD ne sait pas faire (en principe filtre par eslch1)
c  1 profil : impeccable
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,86)) iaux
      if ( iaux.eq.1 ) then
        write (ulsort,texte(langue,61)) noprof
      endif
      write (ulsort,texte(langue,81)) nolopg
#endif
c
          if ( iaux.eq.0 ) then
            goto 40
          elseif ( iaux.gt.1 ) then
            write (ulsort,texte(langue,86)) iaux
            codret = 43
          endif
c
          endif
c
c 4.4. ==> ce tableau fait-il partie de la liste requise ?
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) '---------- Examen du support'
          write (ulsort,texte(langue,60)) typent
          write (ulsort,texte(langue,64)) typgeo
#endif
c
          if ( nbseal.gt.0 ) then
cgn      print *, '.. numdt, numit de la sequence = ', numdt, numit
c
cgn      print *, '.. nbseal = ',nbseal
            jaux = -1
            do 44 , iaux = 1 , nbseal
cgn      print *, '... support MED    caetal(1,',iaux,') =',caetal(1,iaux)
cgn      print *, '... typgeo =',typgeo
              if ( caetal(1,iaux).eq.-1 .or.
     >             caetal(1,iaux).eq.typgeo ) then
cgn      write(ulsort,*) '... examen ? caetal(11,',iaux,') =',
cgn     >        caetal(11,iaux)
                if ( caetal(11,iaux).eq.1 ) then
cgn      write(ulsort,*) '... pas de temps ? caetal(2,',iaux,') = ',
cgn     >        caetal(2,iaux)
cgn      write(ulsort,*) '... pas de temps = caetal(3,',iaux,') = ',
cgn     >        caetal(3,iaux)
cgn      write(ulsort,*) '... nro ordre ?    caetal(4,',iaux,') = ',
cgn     >        caetal(4,iaux)
cgn      write(ulsort,*) '... nro ordre =    caetal(5,',iaux,') = ',
cgn     >        caetal(5,iaux)
cgn      write(ulsort,*) '... instant ?      caetal(6,',iaux,') = ',
cgn     >        caetal(6,iaux)
cgn      write(ulsort,*) '... no/el ?        caetal(7,',iaux,') = ',
cgn     >        caetal(7,iaux)
cgn      write(ulsort,*) '... nr chp no/el   caetal(8,',iaux,') = ',
cgn     >        caetal(8,iaux)
cgn      write(ulsort,*) '... instant =      cartal(',iaux,') = ',cartal(iaux)
cgn      write(ulsort,*) '... epsilo =',epsilo
cgn      write(ulsort,*) '... abs(cartal(iaux)-instan) =',abs(cartal(iaux)-instan)
c
                  logaux = .false.
c
c                 A-t-on le bon numero d'iteration ?
c
                  if ( caetal(4,iaux).eq.1 .or.
     >                 caetal(4,iaux).eq.2 ) then
                    if ( caetal(5,iaux).eq.numit ) then
cgn                    write(ulsort,*)'glop'
                      logaux = .true.
                    endif
                  endif
c
c                 A-t-on le bon numero d'instant / le bon instant ?
c
                  if ( caetal(2,iaux).eq.1 .or.
     >                 caetal(2,iaux).eq.2 ) then
                    if ( caetal(3,iaux).eq.numdt ) then
cgn                    write(ulsort,*)'glop'
                      logaux = .true.
                    else
                      logaux = .false.
                    endif
                  endif
                  if ( caetal(6,iaux).eq.1 .or.
     >                 caetal(6,iaux).eq.2 ) then
                    if (abs(cartal(iaux)-instan).le.epsilo) then
cgn                    write(ulsort,*)'glop'
                      logaux = .true.
                    else
                      logaux = .false.
                    endif
                  endif
c
c                 Rien n'a ete demande
c
                  if ( caetal(2,iaux).eq.0 .and.
     >                 caetal(4,iaux).eq.0 .and.
     >                 caetal(6,iaux).eq.0) then
                    logaux = .true.
                  endif
c
c                 Enregistrement
c
cgn                  write(ulsort,99001)'logaux',logaux
                  if ( logaux ) then
                    jaux = nrtmed
                    carsup = caetal(7,iaux)
                    typint = caetal(10,iaux)
cgn      write(ulsort,*) '... no/el ?        caetal(7,',iaux,') = ',
cgn     >        caetal(7,iaux)
c
                    caetal(9,iaux) = nbcham+1
cgn      print *, '... nr chp         caetal(9,',iaux,') = ',
cgn     >        caetal(9,iaux)
                    typcha = caetal(12,iaux)
cgn                    write(ulsort,90002)'carsup',carsup
cgn                    write(ulsort,90002)'typint',typint
cgn                    write(ulsort,90002)'typcha',typcha
                  endif
                endif
              endif
   44       continue
cgn      print *, 'A la fin de 44, .. jaux = ', jaux
c
c           rien n'est bon, donc on passe au couple suivant
            if ( jaux.eq.-1 ) then
              goto 40
            endif
c
          endif
c
          endif
c
c 4.5. ==> le profil s'il existe
c
          if ( noprof.ne.ednopl ) then
c
c 4.5.1. ==> ce profil est-il deja lu ?
c
            if ( codret.eq.0 ) then
c
            do 451 , iaux = 1 , nbprof
              if ( codret.eq.0 ) then
                call uts8ch ( liprof(9*(iaux-1)+1), 64, saux64,
     >                        ulsort, langue, codret )
                if ( saux64.eq.noprof ) then
                  obprof = liprof(9*iaux)
                  call gmliat ( obprof, 2, nbvapr, codret )
                  goto 459
                endif
              endif
  451       continue
c
            endif
c
c 4.5.2. ==> le profil n'est pas lu. On le lit.
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,4))
            write (ulsort,texte(langue,3)) 'ESLPR1', nompro
#endif
            call eslpr1 ( idfmed,
     >                    noprof, obprof, nbvapr,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
            nbprof = nbprof + 1
            call utchs8 ( noprof, 64, liprof(9*(nbprof-1)+1),
     >                    ulsort, langue, codret )
            liprof(9*nbprof) = obprof
c
            endif
c
#ifdef _DEBUG_HOMARD_
            call gmprsx (nompro,obprof)
            call gmprsx (nompro,obprof//'.NomProfi')
            call gmprot (nompro,obprof//'.ListEnti',1,30)
#endif
c
  459       continue
c
          endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,62)) nbvapr
#endif
c
c 4.6. ==> la localisation des points de Gauss eventuelle
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.6. pts Gauss eventuel ; codret', codret
#endif
          if ( nolopg.eq.ednoga .or. typent.eq.ednoma ) then
cgn          if ( ngauss.eq.ednopg .or. typent.eq.ednoma .or.
cgn     >         ngauss.eq.1 ) then VERRUE SATURNE
c
            oblopg = blan08
c
          elseif ( nolopg.ne.edngen ) then
c
c            VERRUE en attendant la correction de certains cas-tests
c
            if ( nolopg(1:5).eq.'GLOP_' ) then
c                              4567890123456789012
              nolopg(14:32) = '                   '
              nolopg(33:64) = blan32
            endif
c
c 4.6.1. ==> la localisation est-elle deja lue ?
c
            if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,81)) nolopg
#endif
c
            do 461 , iaux = 1 , nblopg
              if ( codret.eq.0 ) then
                call uts8ch ( lilopg(9*(iaux-1)+1), 64, saux64,
     >                        ulsort, langue, codret )
                if ( saux64.eq.nolopg ) then
                  oblopg = lilopg(9*iaux)
                  goto 469
                endif
              endif
  461       continue
c
            endif
c
c 4.6.2. ==> la localisation n'est pas lue. On la lit.
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,5))
            write (ulsort,texte(langue,3)) 'ESLPG1', nompro
#endif
            call eslpg1 ( idfmed,
     >                    nolopg, oblopg,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
            nblopg = nblopg + 1
            lilopg(9*nblopg) = oblopg
            call utchs8 ( nolopg, 64, lilopg(9*(nblopg-1)+1),
     >                    ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
            call gmprsx (nompro,oblopg)
            call gmprsx (nompro,oblopg//'.NomLocPG')
            call gmprsx (nompro,oblopg//'.CoorNoeu')
            call gmprsx (nompro,oblopg//'.CoorPtGa')
            call gmprsx (nompro,oblopg//'.PoidPtGa')
#endif
c
            endif
c
  469       continue
c
          endif
c
c 4.7. ==> nombre de valeurs
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDNPN', nompro
#endif
          call mfdnpn ( idfmed, nomcha,
     >                  numdt, numit, typent, typgeo,
     >                  noprof, edstco, nbvapr, nolopg, ngauss,
     >                  nbval, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,58)) nbval
      if ( noprof.ne.ednopl ) then
        write (ulsort,texte(langue,61)) noprof
        write (ulsort,texte(langue,62)) nbvapr
      endif
      write (ulsort,texte(langue,57)) ngauss
      if ( nolopg.ne.ednoga ) then
        write (ulsort,texte(langue,81)) nolopg
      endif
#endif
c
          endif
c
          if ( codret.eq.0 ) then
c
          if ( noprof.eq.ednopl ) then
            nbvapr = -1
            obprof = blan08
          endif
c
          endif
c
c 4.8. ==> determination de la caracteristique du support
c              1, si aux noeuds par elements
c              2, si aux points de Gauss, associe avec
c                 un champ aux noeuds par elements
c              3, si aux points de Gauss autonome
c              0, sinon
c              Pour un champ aux noeuds par element, a-t-on le bon
c              nombre de pseudo-points de Gauss ?
c
          if ( codret.eq.0 ) then
c
          if ( ngauss.eq.1 .or. ngauss.eq.ednopg ) then
            carsup = 0
          else
c
            if ( typent.eq.ednoma ) then
              oblopg = blan08
              carsup = 1
              iaux = mod(typgeo,100)
              if ( iaux.ne.ngauss ) then
                write (ulsort,texte(langue,32)) nomcha
                write (ulsort,texte(langue,66))
                write (ulsort,texte(langue,64)) typgeo
                write (ulsort,texte(langue,57)) ngauss
                write (ulsort,texte(langue,34)) iaux
                codret = 1
              endif
            else
              carsup = 3
            endif
c
          endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,65+carsup))
#endif
c
          endif
c
c 4.9. ==> si c'est bon, on enregistre
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.9. enregistre ; codret', codret
#endif
c
c 4.9.1. ==> enregistrement d'un nouveau tableau
c
          if ( codret.eq.0 ) then
c
          nbtvlu = nbtvlu + 1
          caraen(1,nbtvlu) = typgeo
          caraen(2,nbtvlu) = numdt
          caraen(3,nbtvlu) = numit
          caraen(4,nbtvlu) = ngauss
          caraen(5,nbtvlu) = nbval
          caraen(6,nbtvlu) = nbvapr
          caraen(7,nbtvlu) = 0
          caraen(8,nbtvlu) = carsup
          caraen(11,nbtvlu) = typint
          caraen(12,nbtvlu) = typcha
          if ( numdt.ne.ednodt ) then
            carare(nbtvlu) = instan
          else
            carare(nbtvlu) = -1789.d0
          endif
          caraca(2,nbtvlu) = obprof
          caraca(3,nbtvlu) = oblopg
c
          endif
c
c 4.9.2. ==> Si d'autres supports sont presents aux memes instants,
c            on doit memoriser les correspondances
c
          if ( codret.eq.0 ) then
c
cgn          print *,'nbtvlu =',nbtvlu
cgn          print *,'champ de type',typgeo
          do 492 , iaux = 1 , nbtvlu-1
cgn         print *,'. champ',iaux,' de types associes',caraen(7,iaux)
cgn         print *,caraen(2,iaux),caraen(3,iaux),caraen(7,iaux)
            if ( caraen(2,iaux).eq.numdt .and.
     >           caraen(3,iaux).eq.numit ) then
c             insertion du champ en lecture comme associe au champ iaux
              caraen(7,iaux) = caraen(7,iaux) + 1
              jaux = caraen(7,iaux)
              if ( 20+jaux.gt.nbinec ) then
                codret = 492
                write (ulsort,90002) 'nbinec est trop petit', nbinec
                goto 30
              endif
              caraen(20+jaux,iaux) = typgeo
c             insertion du champ iaux comme associe au champ enlecture
              caraen(7,nbtvlu) = caraen(7,nbtvlu) + 1
              jaux = caraen(7,nbtvlu)
              if ( 20+jaux.gt.nbinec ) then
                codret = 492
                write (ulsort,90002) 'nbinec est trop petit', nbinec
                goto 30
              endif
              caraen(20+jaux,nbtvlu) = caraen(1,iaux)
            endif
  492     continue
c
          endif
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,*) ' '
          write (ulsort,texte(langue,32)) nomcha
          write (ulsort,90002) 'Caracteristiques du tableau', nbtvlu
          write (ulsort,texte(langue,69)) caraen(12,nbtvlu)
          write (ulsort,texte(langue,64)) caraen(1,nbtvlu)
          write (ulsort,texte(langue,113)) caraen(2,nbtvlu)
          write (ulsort,texte(langue,114)) caraen(3,nbtvlu)
          if ( numdt.ne.ednodt ) then
            write (ulsort,texte(langue,115)) carare(nbtvlu)
          endif
          write (ulsort,texte(langue,57)) caraen(4,nbtvlu)
          write (ulsort,texte(langue,58)) caraen(5,nbtvlu)
          do 4999 , iaux = 1, caraen(7,nbtvlu)
            write (ulsort,texte(langue,60)) caraen(20+iaux,nbtvlu)
 4999     continue
          if ( caraen(6,nbtvlu).gt.0 ) then
            write (ulsort,texte(langue,61)) noprof
          endif
          write (ulsort,texte(langue,65+carsup))
          if ( caraen(8,nbtvlu).gt.0 ) then
            write (ulsort,texte(langue,81)) nolopg
          endif
cgn          write(*,91020)(caraen(iaux,nbtvlu),iaux=1,nbinec)
          endif
#endif
cc
   40   continue
c
cgn        endif
c
   30 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'a la fin de '//nompro//', nbtvlu',nbtvlu
#endif
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
