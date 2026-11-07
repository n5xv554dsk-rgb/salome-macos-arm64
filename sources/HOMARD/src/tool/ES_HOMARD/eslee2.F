      subroutine eslee2 ( idfmed, nomamd,
     >                    nhenti,
     >                    typenh, typgeo, typent,
     >                    nbenti, nbencf, nbenca,
     >                    tbiaux,
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
c  Entree-Sortie : LEcture d'une Entite - 3
c  -      -        --            -        -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   .   1    . nom du maillage MED voulu                  .
c . typenh . e   .   1    . code des entites                           .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . typgeo . e   .   1    . type geometrique au sens MED               .
c . typent . e   .   1    . type d'entite au sens MED                  .
c . nbenti . e   .   1    . nombre d'entites                           .
c . nbencf . e   .   1    . nombre d'entites decrites par faces        .
c . nbenca . e   .   1    . nombre d'entites decrites par aretes       .
c . tbiaux .     .    *   . tableau tampon                             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'ESLEE2' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
#include "impr02.h"
#include "enti01.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer typenh, typgeo, typent
      integer nbenti, nbencf, nbenca
      integer tbiaux(*)
c
      character*8 nhenti
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer nbcmax
      parameter ( nbcmax = 20 )
c
      integer iaux, jaux, kaux
      integer iaux1, iaux2, iaux3
      integer nbcomp
      integer adress
      integer adhist
      integer nbinsu
      integer numdt, numit
c
      character*8 saux08
      character*16 saux16
      character*16 nomcmp(nbcmax), unicmp(nbcmax)
      character*64 nomcha
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
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
      texte(1,4) = '(''... Lecture des complements pour les '',a)'
      texte(1,5) =
     > '(''Impossible de trouver le nombre d''''infos supps.'')'
c
      texte(2,4) = '(''... Readings of additional terms for '',a)'
      texte(2,5) = '(''The number of info supp cannot be found'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
c
#include "impr03.h"
c
#include "esimpr.h"
c
c====
c 2. Lecture sous forme de champ pour les tableaux a une valeur
c    par entite
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Lecture champ ; codret', codret
#endif
c
c 2.1. ==> Reperage du champ et du nombre de ses composantes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLE01_'//suffix(3,typenh),nompro
#endif
      nomcha = blan64
      nomcha(1:8) = suffix(3,typenh)
      iaux = 0
      call esle01 ( idfmed, nomamd, nomcha,
     >              nbcomp, nomcmp, unicmp,
     >              iaux, jaux,
     >              ulsort, langue, codret)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbcomp', nbcomp
      write (ulsort,90003) 'nomcmp', (nomcmp(iaux),iaux=1,nbcomp)
#endif
c
c 2.2. ==> Lecture des valeurs du champ, en mode non entrelace.
c    En fortran, cela correspond au stockage memoire suivant :
c    tbiaux(1,1), tbiaux(2,1), tbiaux(3,1), ..., tbiaux(nbenti,1),
c    tbiaux(1,2), tbiaux(2,2), tbiaux(3,2), ..., tbiaux(nbenti,2),
c    ...
c    tbiaux(1,nbcomp), tbiaux(2,nbcomp), ..., tbiaux(nbenti,nbcomp)
c    on a ainsi toutes les valeurs pour la premiere composante, puis
c    toutes les valeurs pour la seconde composante, etc.
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. Lecture ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
c                A TRAITER plus tard
cgn#ifdef _DEBUG_HOMARD_
cgn       write (ulsort,texte(langue,3)) 'MFDIVR', nompro
cgn #endif
cgn       call mfdivr ( idfmed, nomcha, numdt, numit,
cgn      >              ednoeu, iaux, ednoin,
cgn      >              edall,
cgn      >              tbiaux, codret )
c
      numdt = ednodt
      numit = ednoit
      noprof = blan64
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDIPR', nompro
#endif
      call mfdipr ( idfmed, nomcha, numdt, numit,
     >              typent, typgeo, 1, noprof, ednoin,
     >              edall,
     >              tbiaux, codret )
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,18)) nomcha
      endif
c
      endif
c
c 2.3. ==> Transfert
c 2.3.1. ==> Les composantes standard
c            Point special pour InfoSupp :
c            . Pour les segments, c'est 1 : le numero du noeud milieu
c              donc on le traite comme une composante standard
c            . Pour les mailles 3D, ce sont les codes des faces dans les
c              volumes ; on le traitera plus tard
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3.1. Transfert standard ; codret', codret
      write (ulsort,90002) 'typenh', typenh
#endif
c
      if ( codret.eq.0 ) then
c
      if ( typenh.eq.1 ) then
        saux16 = 'HistEtatNiveau  '
      else
        saux16 = 'InfoSupp        '
      endif
c
      do 231 , iaux = 1 , nbcomp
cgn        write (ulsort,90016) 'nomcmp', iaux, nomcmp(iaux)//'xxxxx'
c
        if ( codret.eq.0 ) then
c
c                             1234567890123456
        if ( nomcmp(iaux).ne.'HistEtatNiveau  ' .and.
     >       nomcmp(iaux).ne.saux16 ) then
c
          saux08 = nomcmp(iaux)(1:8)
cgn          write(ulsort,90003) 'Composante', saux08
c
          if ( codret.eq.0 ) then
c
          if ( saux08.eq.'Famille ' ) then
            call gmadoj ( nhenti//'.Famille.EntiFamm',
     >                    adress, jaux, codret )
          else
            call gmaloj ( nhenti//'.'//saux08, ' ',
     >                    nbenti, adress, codret )
          endif
c
          endif
c
          if ( codret.eq.0 ) then
c
          kaux = nbenti*(iaux-1)
          adress = adress - 1
          do 2311 , jaux = 1 , nbenti
            imem(adress+jaux) = tbiaux(kaux+jaux)
 2311     continue
c
          endif
c
        endif
c
        endif
c
  231 continue
c
cgn      call gmprsx ( nompro,nhenti//'.Famille')
cgn      call gmprsx ( nompro,nhenti//'.Famille.EntiFamm')
c
      endif
c
c 2.3.2. ==> Historique et niveau rassembles (eventuellement) sur
c            la premiere composante (cf. esece1).
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3.2 ; Historique niveau ; codret', codret
#endif
c
      if ( nomcmp(1).eq.'HistEtatNiveau  ' ) then
c                        1234567890123456
c
c 2.3.2.1. ==> Historique
c
        if ( codret.eq.0 ) then
c
        call gmaloj ( nhenti//'.HistEtat', ' ', nbenti, adhist, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'tbiaux :'
cgn      write (ulsort,91141) (iaux,tbiaux(iaux),iaux=1,nbenti)
      write (ulsort,91141) (iaux,tbiaux(iaux),iaux=1,10)
      write (ulsort,91141) (iaux,tbiaux(iaux),iaux=nbenti-10,nbenti)
#endif
c
        adhist = adhist - 1
        do 2321 , jaux = 1 , nbenti
          imem(adhist+jaux) = mod(tbiaux(jaux),1000000)
 2321   continue
c
cgn        call gmprsx ( nompro,nhenti//'.HistEtat')
c
        endif
c
c 2.3.2.2. ==> Puis niveau
c
        if ( codret.eq.0 ) then
c
        call gmaloj ( nhenti//'.Niveau  ', ' ', nbenti, adress, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        adress = adress - 1
        do 2322 , jaux = 1 , nbenti
          imem(adress+jaux) = (tbiaux(jaux)-imem(adhist+jaux))/1000000
 2322   continue
c
cgn        call gmprsx ( nompro,nhenti//'.Niveau  ')
c
        endif
c
      endif
c
c 2.3.3. ==> Les informations supplementaires, sauf pour les segments
c            . Pour les mailles 3D, ce sont les codes des faces dans les
c              volumes ; c'est un nombre compris entre 1 et 8 et il y
c              a autant d'informations que de nombre des faces,
c              donc 3, 4, 5 ou 6 selon le cas
c            Remarque : InfoSupp est stocke sur la derniere
c                       composante (cf. esece1).
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3.3. informations supp ; codret', codret
      write (ulsort,90002) 'typenh', typenh
#endif
c
      if ( typenh.ge.2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90016) 'nomcmp', nbcomp, nomcmp(nbcomp)//'xxxxx'
#endif
c
c 2.3.3.1. ==> Des informations ont ete stockees
c
        if (nomcmp(nbcomp).eq.'InfoSupp        ' ) then
c                              1234567890123456
c
c 2.3.3.1.1. ==> Decompte du nombre d'informations
c
          if ( codret.eq.0 ) then
c
          nbinsu = 1
          kaux = tbiaux(nbenti*nbcomp-nbenca)
c
          jaux = 1
          do 2331 , iaux = 1 , 10
c
            jaux = jaux * 10
            if ( kaux.ge.jaux ) then
              nbinsu = nbinsu + 1
            else
              goto 23311
            endif
c
 2331     continue
c
          write (ulsort,texte(langue,5))
          codret = 1
c
23311     continue
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) '==> nbinsu', nbinsu
#endif
c
          endif
c
c 2.3.3.1.2. ==> Allocation
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3.3.1.2 Allocation ; codret', codret
#endif
c
          if ( codret.eq.0 ) then
c
          jaux = nbencf*nbinsu
          call gmaloj ( nhenti//'.InfoSupp', ' ', jaux, adress, codret )
          adress = adress - 1
c
          endif
c
c 2.3.3.1.3. ==> Transfert
c
          if ( codret.eq.0 ) then
c
          kaux = nbenti*(nbcomp-1)
          adress = adress + nbencf*(nbinsu-1)
          do 23331 , jaux = 1 , nbencf
            imem(adress+jaux) = mod(tbiaux(kaux+jaux),10)
23331     continue
c
          iaux1 = 10
          do 23332 , iaux = nbinsu-1, 1 , -1
c
            iaux2 = iaux1
            iaux1 = 10*iaux1
            adress = adress - nbencf
            do 23333 , jaux = 1 , nbencf
              iaux3 = mod(tbiaux(kaux+jaux),iaux1)
              imem(adress+jaux) = ( iaux3 - mod(iaux3,iaux2) ) / iaux2
23333       continue
c
23332     continue
c
          endif
c
cgn          call gmprsx ( nompro,nhenti//'.InfoSupp' )
c
c 2.3.3.2. ==> Rien n'a ete stocke : on alloue un tableau vide pour
c              les volumes
c
        else
c
          if ( typenh.ne.4 ) then
c
            jaux = 0
            call gmaloj ( nhenti//'.InfoSupp', ' ', jaux,
     >                    adress, codret )
c
          endif
c
        endif
c
      endif
c
c====
c 3. Lecture sous forme de profil pour les informations supplementaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Lecture profil ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLE02_'//mess14(langue,1,typenh),
     >                                nompro
#endif
      call esle02 ( idfmed,
     >              typenh, nhenti, nbenca,
     >              ulsort, langue, codret)
c
      endif
cgn      call gmprsx(nompro, nhenti//'.ConnAret')
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
