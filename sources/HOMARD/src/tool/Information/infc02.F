      subroutine infc02 ( numcas,
     >                    typenh, nhenti, nbenti, nbentf, nbenta,
     >                    nbtvch, nutvch,
     >                    nbcomp, nbench, typgeo,
     >                    obcham, nupafo, infopf,
     >                    nhnoeu, nharet, nhtria, nhquad,
     >                    nhhexa, nhpent, norenu,
     >                    caraen, carare, caraca,
     >                    npenrc, entrec,
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
c  INformation - inFormations Complementaires - phase 02
c  --              -          -                       --
c ______________________________________________________________________
c  Creation de la fonction et du paquet
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numcas . e   .   1    . numero du cas en cours de traitement       .
c .        .     .        . 1 : niveau                                 .
c .        .     .        . 2 : qualite                                .
c .        .     .        . 3 : diametre                               .
c .        .     .        . 4 : parente                                .
c .        .     .        . 5 : voisins des recollements               .
c . typenh . e   .   1    . type d'entites concernees                  .
c .        .     .        . 0 : noeuds                                 .
c .        .     .        . 1 : aretes                                 .
c .        .     .        . 2 : triangles                              .
c .        .     .        . 3 : tetraedres                             .
c .        .     .        . 4 : quadrangles                            .
c .        .     .        . 5 : pyramides                              .
c .        .     .        . 6 : hexaedres                              .
c .        .     .        . 7 : pentaedres                             .
c . nhenti . e   . char*8 . structure de l'entite                      .
c . nbenti . e   .   1    . nombre total d'entites concernees          .
c . nbentf . e   .   1    . nombre d'entites concernees - par faces    .
c . nbenta . e   .   1    . nombre d'entites concernees - par aretes   .
c . nbtvch . e   .   1    . nombre de tableaux associes                .
c . nutvch . e   .   1    . numero du tableau en cours                 .
c . nbcomp . e   .   1    . nombre de composantes                      .
c . nbench . e   .   1    . nombre d'entites du champ                  .
c . typgeo . e   .   1    . type geometrique au sens med               .
c . obcham . e   .   1    . nom de l'objet InfoCham associe            .
c . infopf . e   .   *    . informations sur les paquets de fonctions  .
c . nhnoeu . e   . char8  . nom de l'objet decrivant les noeuds        .
c . nharet . e   . char8  . nom de l'objet decrivant les aretes        .
c . nhtria . e   . char8  . nom de l'objet decrivant les triangles     .
c . nhquad . e   . char8  . nom de l'objet decrivant les quadrangles   .
c . nhhexa . e   . char8  . nom de l'objet decrivant les hexaedres     .
c . nhpent . e   . char8  . nom de l'objet decrivant les pentaedres    .
c . norenu . e   . char8  . nom de la branche Renum du maillage HOMARD .
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
c . carare . e   . nbtvch . caracteristiques reelles du champ          .
c .        .     .        . 1. valeur du pas de temps                  .
c . caraca . e   . nbincc*. caracteristiques caracteres des tableaux   .
c .        .     . nbsqch . du champ en cours d'examen                 .
c .        .     .        . 1. nom de l'objet fonction                 .
c .        .     .        . 2. nom de l'objet profil, blanc sinon      .
c .        .     .        . 3. nom de l'objet localisation des points  .
c .        .     .        . de Gauss, blanc sinon                      .
c . npenrc . e   .  2*x   . nombre de paires d'entites recollees       .
c . entrec . e   .2*npenrc. paires des entites voisines faces a recol. .
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
      parameter ( nompro = 'INFC02' )
c
#include "nblang.h"
#include "consts.h"
#include "esutil.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
#include "nombsr.h"
c
#include "nombhe.h"
#include "nombpe.h"
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer numcas
      integer typenh, nbenti, nbentf, nbenta
      integer nbtvch, nutvch, nupafo
      integer nbcomp, nbench, typgeo
      integer caraen(nbinec,nbtvch)
c
      integer npenrc, entrec(2,npenrc)
c
      double precision carare(nbtvch)
c
      character*8 nhenti
      character*8 nhnoeu, nharet, nhtria, nhquad
      character*8 nhhexa, nhpent, norenu
      character*8 infopf(*)
      character*8 obcham
      character*8 caraca(nbincc,nbtvch)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer adhist, adcode, adinsu, adcoar, admere, adins2
      integer pcoono
      integer phetar, psomar, pmerar
      integer phettr, paretr, ppertr, pnivtr
      integer phetqu, parequ, pperqu, pnivqu
      integer phethe, pquahe
      integer phetpe, pfacpe
      integer adencn
c
      integer ngauss, nbtyas
      integer carsup, typint, typcha
      integer nbvapr
      integer advale, advalr, adobch, adprpg, adtyas
      integer adobfo, adtyge
      integer adprof, advatt
c
      integer codre1, codre2
      integer codre0
c
      character*8 nofonc, nopafo
      character*8 ntrav1, ntrav2
c
      integer nbmess
      parameter ( nbmess = 10 )
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
      texte(1,4) = '(''.. Examen des'',i10,1x,a)'
      texte(1,5) = '(''.. Nombre de tableau du champ :'',i10)'
c
      texte(2,4) = '(''.. Examination of the'',i10,1x,a)'
      texte(2,5) = '(''.. Number of arrays for this field:'',i10)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbench, mess14(langue,3,typenh)
      write (ulsort,texte(langue,5)) nbtvch
      write (ulsort,90002) 'numcas', numcas
#endif
c
      codret = 0
c
c====
c 2. Decodage de la structure
c====
c 2.1. ==> La structure principale
c
      if ( codret.eq.0 ) then
c
      if ( typenh.ne.2 .and. typenh.ne.4 ) then
c
        iaux = 2
        if ( typenh.eq.3 .or. typenh.eq.5 .or.
     >       typenh.eq.6 .or. typenh.eq.7 ) then
          iaux = iaux*5*13
c         quand des hexaedres et/ou des pentaedres sont coupes par
c         conformite, il faut recuperer un tableau sur les parentes
c         pour les tetraedres et les pyramides
          if ( ( typenh.eq.3 .or. typenh.eq.5 ) .and.
     >         ( nbheco.gt.0 .or. nbpeco.gt.0 ) ) then
            iaux = iaux*17
          endif
        endif
        if ( nbenta.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD02_'//mess14(1,5,typenh),
     >                                  nompro
#endif
        call utad02 (   iaux, nhenti,
     >                adhist, adcode,   jaux, admere,
     >                  jaux,   jaux,   jaux,
     >                  jaux, adinsu, adins2,
     >                  jaux,   jaux, adcoar,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.2. ==> Les coordonnees des noeuds si besoin
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( numcas.eq.2 .or. numcas.eq.3 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
        iaux = 3
        call utad01 ( iaux, nhnoeu,
     >                  jaux,
     >                    jaux,   jaux,   jaux,
     >                pcoono,   jaux,   jaux,  jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.3. ==> Les aretes si besoin
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( numcas.eq.2 .or. numcas.eq.3 .or. numcas.eq.7 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD02_aret', nompro
#endif
        iaux = 10
        call utad02 (   iaux, nharet,
     >                phetar, psomar,   jaux, pmerar,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.4. ==> Les triangles si besoin
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( typenh.eq.2 .or.
     >     typenh.eq.3 .or. typenh.eq.5 .or. typenh.eq.7 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD02_tria', nompro
#endif
        iaux = 110
        call utad02 (   iaux, nhtria,
     >                phettr, paretr,   jaux, ppertr,
     >                  jaux,   jaux,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.5. ==> Les quadrangles si besoin
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.5. quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( typenh.eq.4 .or.
     >     typenh.eq.5 .or. typenh.eq.6 .or. typenh.eq.7 .or.
     >     ( typenh.eq.3 .and. ( nbheco.gt.0 .or. nbpeco.gt.0 ) ) ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD02_quad', nompro
#endif
        iaux = 110
        call utad02 (   iaux, nhquad,
     >                phetqu, parequ,   jaux, pperqu,
     >                  jaux,   jaux,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.6. ==> Les hexaedres si besoin
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.6. hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.gt.0 ) then
c
        if ( typenh.eq.3 .or. typenh.eq.5 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD02_hexa', nompro
#endif
          iaux = 2
          call utad02 (   iaux, nhhexa,
     >                  phethe, pquahe,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
      endif
c
c 2.7. ==> Les pentaedres si besoin
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.7. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpeto.gt.0 ) then
c
        if ( typenh.eq.3 .or. typenh.eq.5 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD02_pent', nompro
#endif
          iaux = 2
          call utad02 (   iaux, nhpent,
     >                  phetpe, pfacpe,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
      endif
c
c====
c 3. Creation de la fonction
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Creation fonction ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( numcas.le.3 ) then
        typcha = edfl64
      else
        typcha = edint
      endif
      ngauss = ednopg
      nbvapr = -1
      nbtyas = 0
      carsup = 0
      typint = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALFO', nompro
#endif
      call utalfo ( nofonc, typcha,
     >              typgeo, ngauss, nbench, nbvapr, nbtyas,
     >              carsup, nbcomp, typint,
     >              advale, advalr, adobch, adprpg, adtyas,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      smem(adobch)   = obcham
c
      smem(adprpg)   = blan08
      smem(adprpg+1) = blan08
      smem(adprpg+2) = blan08
c
      caraen( 1,nutvch) = typgeo
      caraen( 2,nutvch) = ednodt
      caraen( 3,nutvch) = ednoit
      caraen( 4,nutvch) = ngauss
      caraen( 5,nutvch) = nbench
      caraen( 6,nutvch) = nbvapr
      caraen( 7,nutvch) = 1
      caraen( 8,nutvch) = 0
      caraen( 9,nutvch) = 1
      caraen(10,nutvch) = 0
      caraen(11,nutvch) = 0
      caraen(12,nutvch) = 0
c
      carare(nutvch) = edundt
c
      caraca(1,nutvch) = nofonc
      caraca(2,nutvch) = blan08
      caraca(3,nutvch) = blan08
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90015) 'OBJET fonction'
      call gmprsx ( nompro, nofonc )
      call gmprsx ( nompro, nofonc//'.InfoCham' )
cgn      call gmprsx ( nompro, nofonc//'.InfoPrPG' )
      endif
#endif
c
c====
c 4. Creation du paquet de fonctions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Creation paquet ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALPF', nompro
#endif
      call utalpf ( nopafo,
     >              iaux, typgeo, ngauss, carsup, typint,
     >              adobfo, adtyge,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      smem(adobfo)   = nofonc
      smem(adobfo+1) = blan08
c
      infopf(nupafo) = nopafo
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90015) 'OBJET paquet de fonctions'
      call gmprsx ( nompro, nopafo )
      call gmprsx ( nompro, nopafo//'.Fonction' )
      endif
#endif
c
c====
c 5. Les valeurs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. valeurs ; codret', codret
#endif
c
c 5.1. ==> Tableaux temporaires
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', rseutc, adprof, codre1 )
      iaux = nbcomp*rseutc
      if ( numcas.le.3 ) then
        call gmalot ( ntrav2, 'reel    ', iaux, advatt, codre2 )
      else
        call gmalot ( ntrav2, 'entier  ', iaux, advatt, codre2 )
      endif
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 5.2. ==> Tableau de travail
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03', nompro
#endif
      iaux = 7
      call utre03 ( typenh, iaux, norenu,
     >              jaux, jaux, jaux, adencn,
     >              ulsort, langue, codret)
c
      endif
c
c 5.3. ==> Calcul
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFC03', nompro
#endif
      call infc03 ( numcas, typenh, nbcomp, nbenti, nbentf, nbenta,
     >              imem(adcode), imem(adinsu), imem(adcoar),
     >              imem(admere), imem(adins2), imem(adencn),
     >              rmem(pcoono), imem(psomar), imem(pmerar),
     >              imem(paretr), imem(ppertr), imem(pnivtr),
     >              imem(parequ), imem(pperqu), imem(pnivqu),
     >              imem(pquahe), imem(pfacpe),
     >              npenrc, entrec,
     >              rseutc, imem(adprof), imem(advatt), rmem(advatt),
     >              ulsort, langue, codret )
c
      endif
c
c 5.4. ==> Mise a jour des numerotations
c
      if ( numcas.le.3 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSRC1', nompro
#endif
        call utsrc1 ( nbcomp, rseutc,
     >                imem(adprof), rmem(advatt), rmem(advalr) )
c
        endif
c
      else
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSRC3', nompro
#endif
        call utsrc3 ( nbcomp, rseutc,
     >                imem(adprof), imem(advatt), imem(advale) )
c
        endif
c
      endif
c
c 5.5. ==> Menage
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90015) 'OBJET fonction'
      call gmprsx ( nompro, nofonc//'.ValeursE' )
      call gmprsx ( nompro, nofonc//'.ValeursR' )
      endif
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
