      subroutine vcfia0 ( lgopti, taopti, lgoptr, taoptr,
     >                    lgopts, taopts,
     >                    option,
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
c    aVant adaptation - FIltrage de l'ADaptation
c     -                 --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options entieres   .
c . taopti . e   . lgopti . tableau des options entieres               .
c . lgoptr . e   .   1    . longueur du tableau des options reelles    .
c . taoptr . es  . lgoptr . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . option . e   .   1    . option de filtrage                         .
c .        .     .        . 1 : par des groupes                        .
c .        .     .        . 2 : par un diametre minimal                .
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
      parameter ( nompro = 'VCFIA0' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "envca1.h"
#include "impr02.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombno.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "dicfen.h"
#include "nbfamm.h"
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
      integer option
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
c
      integer ngrofi, adgfpt, adgftb
      integer nbfmed, pnumfa, pgrpo, pgrtab
      integer nbfamd
      integer pcoono, psomar
      integer paretr, parequ
      integer ptrite, pcotrt, parete
      integer pquahe, pcoquh, parehe
      integer pfacpy, pcofay, parepy
      integer pfacpe, pcofap, parepe
      integer adhist, adcode, adcoar
      integer adfami, adcofa
      integer adinsu
      integer advotr, advoqu
      integer pvolfa
      integer typenh, nbento, nbencf, nbenca, nctfen, nbfenm
      integer typend
      integer admemo, admema, admemt, admemq
      integer adtra1, adtra2
c
      integer codre1, codre2
      integer codre0
      integer iaux, jaux, kaux
      integer ideb, ifin
c
      logical afaire
c
      double precision diammi
c
      character*6 saux
      character*8 nhenti
      character*8 typobs, obfiad, nomail
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1, ntrav2
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
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
      texte(1,4) = '(''Filtrage par des groupes'',/,24(''-''))'
      texte(1,5) = '(''Filtrage par un diametre minimal'',/,32(''-''))'
      texte(1,6) = '(/,''Influence sur les'',i10,1x,a)'
      texte(1,7) = '('' Diametre minimal :'',g15.6)'
      texte(1,8) =
     > '(/,''Aucun groupe n''''est present dans le maillage.'')'
      texte(1,9) = '(''L''''adaptation est supprimee.'')'
      texte(1,10) = '(''Nombre de '',a,'' filtres :'',i10,'' sur'',i10)'
c
      texte(2,4) = '(''Filtering among groups'',/,22(''-''))'
      texte(2,5) =
     > '(''Filtering with a minimal diameter'',/,33(''-''))'
      texte(2,6) = '(/,''Influence over the'',i10,1x,a)'
      texte(2,7) = '('' Minimal diameter:'',g15.6)'
      texte(2,8) = '(/,''No group is present in the mesh.'')'
      texte(2,9) = '(''Adaptation is cancelled.'')'
      texte(2,10) =
     > '(''Number of filtered '',a,'':'',i10,'' over'',i10)'
c
      if ( option.ge.1 .and. option.le.2 ) then
        write (ulsort,texte(langue,3+option))
      else
        codret = 1
      endif
c
#include "impr03.h"
c
c====
c 2. les structures de base
c====
c
c 2.1. ==> le maillage homard a l'iteration n
c
      if ( codret.eq.0 ) then
c
      typobs = mchman
      iaux = 0
      call utosno ( typobs, nomail, iaux, ulsort, langue, codret )
c
      endif
c
c 2.2. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
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
     >              ulsort, langue, codret)
c
      endif
c
c 2.3. ==> voisinages
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      iaux = 1
      if ( nbteto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*5
      endif
      if ( nbheto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*7
      endif
c
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux,  jaux,   jaux,
     >              advotr, advoqu,
     >                jaux,   jaux,  jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
cgn      call gmprsx (nompro,obfiad)
cgn      call gmprsx (nompro,obfiad//'.Pointeur')
cgn      call gmprsx (nompro,obfiad//'.Taille')
cgn      call gmprsx (nompro,obfiad//'.Table')
c
c====
c 3. Prealables
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Prealables ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      afaire = .true.
c
c 3.1. ==> Prealable pour le filtrage par des groupes
c
      if ( option.eq.1 ) then
c
c 3.1. ==> Decodage des adresses des groupes de filtrage
c
        if ( codret.eq.0 ) then
c
        obfiad = taopts(15)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCFIA1', nompro
#endif
        call vcfia1 ( obfiad, nhsupe, nhsups,
     >                ngrofi, adgfpt, adgftb,
     >                nbfmed, pnumfa, pgrpo, pgrtab,
     >                ntrav1, adtra1, ntrav2, adtra2,
     >                ulsort, langue, codret )
c
        endif
c
c 3.2. ==> Reperage des numeros de familles MED concernees
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCFIA2', nompro
#endif
        call vcfia2 ( ngrofi, imem(adgfpt), smem(adgftb),
     >                nbfmed, imem(pnumfa),
     >                imem(pgrpo), smem(pgrtab),
     >                nbfamd,
     >                imem(adtra1), imem(adtra2),
     >                ulsort, langue, codret )
c
        endif
c
c 3.3. ==> Si aucun groupe n'est present, on ne fait plus ni
c          raffinement ni deraffinement car aucune entite n'appartient
c          aux groupes voulus
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. Suppression ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        if ( nbfamd.eq.0 ) then
          taopti(27) = 0
          taopti(31) = 0
          taopti(32) = 0
          write (ulsort,texte(langue,8))
          write (ulsort,texte(langue,9))
          afaire = .false.
        endif
c
        endif
c
c 3.4. ==> Menage
c
        if ( codret.eq.0 ) then
c
        call gmsgoj ( obfiad, codre1 )
        call gmlboj ( ntrav1, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
c 3.2. ==> Prealable pour le filtrage par le diametre minimal
c
      elseif ( option.eq.2 ) then
c
        diammi = taoptr(3)
        write (ulsort,texte(langue,7)) diammi
c
      endif
c
      endif
c
c====
c 4. Allocation du tableau de memorisation
c    Par defaut, il est vide.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Allocation ; codret', codret
#endif
c
      if ( afaire ) then
c
        if ( codret.eq.0 ) then
c
        call gmalot ( obfiad, '10TabEnt', 0, iaux, codret )
        iaux = 30 - option
        taopts(iaux) = obfiad
cgn      write (ulsort,90002) nompro, ', obfiad = ', obfiad,', iaux =', iaux
c
        endif
c
        if ( codret.eq.0 ) then
c
        jaux = 0
        do 41 , iaux = 1 , 10
          if ( codret.eq.0 ) then
          call gmecat ( obfiad, iaux, jaux, codret )
          endif
   41   continue
c
        endif
c
      endif
c
c====
c 5. Boucle sur tous les types d'entites
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Boucle ; codret', codret
#endif
c
      if ( afaire ) then
c
c 5.1. ==> Type d'entites concernees
c          . Pour les groupes : toutes
c          . Pour le diametres : au moins des aretes
c
      if ( codret.eq.0 ) then
c
      if ( option.eq.1 ) then
        typend = -1
      else
        typend = 1
      endif
c
      do 51 , typenh = typend , 7
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. Boucle pour les ', mess14(langue,3,typenh)
#endif
c
c 5.2. ==> Nombre d'entites concernees
c
        if ( codret.eq.0 ) then
c
        nbencf = 0
        nbenca = 0
c
        if ( typenh.eq.-1 ) then
          nbento = nbnoto
          nctfen = nctfno
          nbfenm = nbfnom
          nhenti = nhnoeu
        elseif ( typenh.eq.0 ) then
          nbento = nbmpto
          nctfen = nctfmp
          nbfenm = nbfmpm
          nhenti = nhmapo
        elseif ( typenh.eq.1 ) then
          nbento = nbarto
          nctfen = nctfar
          nbfenm = nbfarm
          nhenti = nharet
        elseif ( typenh.eq.2 ) then
          nbento = nbtrto
          nctfen = nctftr
          nbfenm = nbftrm
          nhenti = nhtria
        elseif ( typenh.eq.3 ) then
          nbento = nbteto
          nbencf = nbtecf
          nbenca = nbteca
          nctfen = nctfte
          nbfenm = nbftem
          nhenti = nhtetr
        elseif ( typenh.eq.4 ) then
          nbento = nbquto
          nctfen = nctfqu
          nbfenm = nbfqum
          nhenti = nhquad
        elseif ( typenh.eq.5 ) then
          nbento = nbpyto
          nbencf = nbpycf
          nbenca = nbpyca
          nctfen = nctfpy
          nbfenm = nbfpym
          nhenti = nhpyra
        elseif ( typenh.eq.6 ) then
          nbento = nbheto
          nbencf = nbhecf
          nbenca = nbheca
          nctfen = nctfhe
          nbfenm = nbfhem
          nhenti = nhhexa
        elseif ( typenh.eq.7 ) then
          nbento = nbpeto
          nbencf = nbpecf
          nbenca = nbpeca
          nctfen = nctfpe
          nbfenm = nbfpem
          nhenti = nhpent
        endif
c
        if ( nbento.ne.0 ) then
c
c 5.3. ==> Allocation de la branche de memorisation
c          Pour les aretes, triangles, quadrangles, on s'en souvient
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,6)) nbento, mess14(langue,3,typenh)
#endif
c
          iaux = typenh + 2
          call utench ( iaux, 'g', jaux, saux,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          saux = '.Tab'//saux(1:1)
c
          call gmecat ( obfiad, iaux, nbento, codre1 )
          call gmaloj ( obfiad//saux, ' ', nbento, admemo, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
c
          if ( typenh.eq.1 ) then
            admema = admemo
          elseif ( typenh.eq.2 ) then
            admemt = admemo
          elseif ( typenh.eq.4 ) then
            admemq = admemo
          endif
c
          endif
c
c 5.4. ==> Adresses des caracteristiques des entites
c          On prend les adresses de l'entite courante et ce qu'il faut
c          pour calculer le diametre dans l'option 2
c
c 5.4.1. ==> Les noeuds
c
          if ( codret.eq.0 ) then
c
          iaux = 1
          if ( typenh.eq.-1 ) then
c           fami, cofa
            iaux = 7
          elseif ( option.eq.2 ) then
c           coordonnnes
            iaux = 3
          endif
c
          if ( iaux.ne.1 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'iaux', iaux
          write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
            call utad01 ( iaux, nhnoeu,
     >                      jaux,
     >                    adfami, adcofa,   jaux,
     >                    pcoono,   jaux,   jaux,   jaux,
     >                    ulsort, langue, codret )
c
          endif
c
          endif
c
c 5.4.2. ==> Entite courante, si ce n'est pas un noeud :
c            . 2*7*37 : famille et l'historique
c            . 13  : codes pour les volumes (182 au final)
c            . 31  : eventuelle connectivite par aretes (5462 au final)
c
          if ( typenh.ne.-1 ) then
c
            if ( codret.eq.0 ) then
c
            iaux = 518
            if ( typenh.eq.3 .or. typenh.ge.5 ) then
              iaux = 13*iaux
            endif
            if ( nbenca.gt.0 ) then
              iaux = iaux*31
            endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'iaux', iaux
          write (ulsort,texte(langue,3)) 'UTAD02-courant', nompro
#endif
            call utad02 ( iaux, nhenti,
     >                    adhist, adcode,   jaux,   jaux,
     >                    adfami, adcofa,   jaux,
     >                    jaux  , adinsu,   jaux,
     >                      jaux,   jaux, adcoar,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
            if ( typenh.eq.1 ) then
              psomar = adcode
            elseif ( typenh.eq.2 ) then
              paretr = adcode
            elseif ( typenh.eq.3 ) then
              ptrite = adcode
              pcotrt = adinsu
              parete = adcoar
            elseif ( typenh.eq.4 ) then
              parequ = adcode
            elseif ( typenh.eq.5 ) then
              pfacpy = adcode
              pcofay = adinsu
              parepy = adcoar
            elseif ( typenh.eq.6 ) then
              pquahe = adcode
              pcoquh = adinsu
              parehe = adcoar
            elseif ( typenh.eq.7 ) then
              pfacpe = adcode
              pcofap = adinsu
              parepe = adcoar
            endif
c
            endif
c
          endif
c
c 5.4.3. ==> Complements pour les diametres
c
          if ( option.eq.2 ) then
c
c 5.4.3.1. ==> Les aretes : toujours
c
            if ( codret.eq.0 ) then
c
            if ( typenh.ne.1 ) then
c
              iaux = 2
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02-arete', nompro
#endif
              call utad02 ( iaux, nharet,
     >                      kaux  , psomar,   jaux,   jaux,
     >                      jaux  ,   jaux,   jaux,
     >                      jaux  ,   jaux,   jaux,
     >                      jaux  ,   jaux,   jaux,
     >                      ulsort, langue, codret )
c
              endif
c
            endif
c
c 5.4.3.2. ==> Les triangles : pour les tetraedres ou les pyramides
c
            if ( typenh.eq.3 .or. typenh.eq.5 ) then
c
              if ( codret.eq.0 ) then
c
              iaux = 2
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02-triangles', nompro
#endif
              call utad02 ( iaux, nhtria,
     >                      kaux  , paretr,   jaux,   jaux,
     >                      jaux  ,   jaux,   jaux,
     >                      jaux  ,   jaux,   jaux,
     >                      jaux  ,   jaux,   jaux,
     >                      ulsort, langue, codret )
c
              endif
c
              endif
c
c 5.4.3.3. ==> Les quadrangles : pour les hexaedres ou les pentaedres
c
            if ( typenh.ge.6 ) then
c
              if ( codret.eq.0 ) then
c
              iaux = 2
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02-quadrangles', nompro
#endif
              call utad02 ( iaux, nhquad,
     >                      kaux  , parequ,   jaux,   jaux,
     >                      jaux  ,   jaux,   jaux,
     >                      jaux  ,   jaux,   jaux,
     >                      jaux  ,   jaux,   jaux,
     >                      ulsort, langue, codret )
c
              endif
c
            endif
c
c 5.4.3.4. ==> Les voisinages : pour les faces ou les aretes
c
            if ( codret.eq.0 ) then
c
              if ( typenh.eq.2 ) then
c
                pvolfa = advotr
c
              elseif ( typenh.eq.4 ) then
c
                pvolfa = advoqu
c
              endif
c
            endif
c
          endif
c
c 5.5. ==> Traitement
c 5.5.1. ==> Traitement pour le filtrage par des groupes
c
          if ( option.eq.1 ) then
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'VCFIA3', nompro
#endif
            call vcfia3 ( nbfamd, imem(adtra2),
     >                    typenh, nbento, nctfen, nbfenm,
     >                    imem(adfami), imem(adcofa),
     >                    imem(admemo),
     >                    ulsort, langue, codret )
c
            endif
c
c 5.5.2. ==> Traitement pour le diametre minimal
c
          elseif ( option.eq.2 ) then
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'VCFIA4', nompro
#endif
            call vcfia4 ( diammi,
     >                    typenh, nbento, nctfen, nbfenm,
     >                    imem(adfami), imem(adcofa),
     >                    rmem(pcoono), imem(psomar),
     >                    imem(paretr), imem(parequ),
     >                    imem(ptrite), imem(pcotrt), imem(parete),
     >                    imem(pquahe), imem(pcoquh), imem(parehe),
     >                    imem(pfacpy), imem(pcofay), imem(parepy),
     >                    imem(pfacpe), imem(pcofap), imem(parepe),
     >                    imem(pvolfa),
     >                    imem(admemo),
     >                    imem(admema), imem(admemt), imem(admemq),
     >                    ulsort, langue, codret )
c
            endif
c
          endif
c
        endif
c
        endif
c
   51 continue
c
      endif
c
cgn      if ( codret.eq.0 ) then
cgn      if ( option.eq.2 ) then
cgn      call gmprsx (nompro,obfiad)
cgn      call gmprot (nompro,obfiad//'.Tab3', 1, nbarto)
cgn      call gmprot (nompro,obfiad//'.Tab4', 1, nbtrto)
cgn      call gmprot (nompro,obfiad//'.Tab5', 1, nbteto)
cgn      endif
cgn      endif
c
      endif
c
      if ( option.eq.1 ) then
c
        if ( codret.eq.0 ) then
c
        call gmlboj ( ntrav2, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
      endif
c
c====
c 6. Si toutes les entites sont retenues, on inhibe le filtrage
c====
c
      do 61 , typenh = -1 , 7
c
c 6.1. ==> Nombre de valeurs
c
        if ( codret.eq.0 ) then
c
        iaux = typenh + 2
        call gmliat ( obfiad, iaux, nbento, codret )
c
        endif
c
c 6.2. ==> Adresse des valeurs s'il y en a
c
        if ( codret.eq.0 ) then
c
        if ( nbento.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,6)) nbento, mess14(langue,3,typenh)
#endif
c
          if ( codret.eq.0 ) then
c
          iaux = typenh + 2
          call utench ( iaux, 'g', jaux, saux,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          saux = '.Tab'//saux(1:1)
          call gmadoj ( obfiad//saux, admemo, iaux, codret )
c
          endif
c
c 6.3. ==> Si toutes les entites sont retenues, on inhibe le filtrage
c
          if ( codret.eq.0 ) then
c
          ideb = admemo
          ifin = ideb + nbento - 1
          jaux = 0
          do 63 , iaux = ideb, ifin
            if ( imem(iaux).ne.0 ) then
              jaux = jaux + 1
            endif
   63     continue
cc
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,10)) mess14(langue,3,typenh),
     >                                    jaux, nbento
#endif
c
          if ( jaux.eq.0 ) then
c
            iaux = typenh + 2
            jaux = 0
            call gmecat ( obfiad, iaux, jaux, codre0 )
            codret = max ( abs(codre0), codret )
c
          endif
c
          endif

        endif
c
        endif
c
   61 continue
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
c=======================================================================
      endif
c=======================================================================
c
      end
