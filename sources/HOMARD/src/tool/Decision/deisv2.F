      subroutine deisv2 ( ncmpin, usacmp,
     >                    tesupp, teindi, teinin,
     >                    hesupp, heindi, heinin,
     >                    pysupp, pyindi, pyinin,
     >                    pesupp, peindi, peinin,
     >                    hettri, pertri,
     >                    hetqua, filqua, perqua,
     >                    tritet, pertet, pthepe,
     >                    quahex, hethex, filhex, perhex, fhpyte,
     >                    facpyr,
     >                    facpen,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
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
c    traitement des DEcisions - Initialisations - par Saut - Volumes - 2
c                   --          -                     -      -         -
c   attention : on ne traite pas les cas non-conformes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . tesupp . e   . nbteto . support pour les tetraedres                .
c . teindi . es  . nbteto . valeurs pour les tetraedres                .
c . teinin . e   . nbteto . valeurs initiales pour les tetraedres      .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
c . heindi . es  . nbheto . valeurs pour les hexaedres                 .
c . heinin . e   . nbheto . valeurs initiales pour les hexaedres       .
c . pysupp . e   . nbpyto . support pour les pyramides                 .
c . pyindi . es  . nbpyto . valeurs pour les pyramides                 .
c . pyinin . e   . nbpyto . valeurs initiales pour les pyramides       .
c . pesupp . e   . nbpeto . support pour les pentaedres                .
c . peindi . es  . nbpeto . valeurs pour les pentaedres                .
c . peinin . e   . nbpeto . valeurs initiales pour les pentaedres      .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . pertri . e   . nbtrto . pere des triangles                         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . fils des quadrangles                       .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . tritet . e   .nbtecf*4. numeros des triangles des tetraedres       .
c . pertet . e   . nbteto . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . pthepe . e   .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . perhex . e   . nbheto . pere des hexaedres                         .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pyramides          .
c . voltri . es  .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEISV2' )
c
#include "nblang.h"
c
      integer lgdaux
      parameter( lgdaux = 500 )
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer ncmpin
      integer usacmp
      integer tesupp(nbteto)
      integer hesupp(nbheto)
      integer pysupp(nbpyto)
      integer pesupp(nbpeto)
      integer hettri(nbtrto), pertri(nbtrto)
      integer hetqua(nbquto), filqua(nbquto), perqua(nbquto)
      integer tritet(nbtecf,4)
      integer pertet(nbteto), pthepe(*)
      integer quahex(nbhecf,6)
      integer hethex(nbheto), filhex(nbheto), perhex(nbheto)
      integer fhpyte(2,nbheco)
      integer facpyr(nbpycf,5)
      integer facpen(nbpecf,5)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer volqua(2,nbquto), pypequ(2,*)
c
      integer ulsort, langue, codret
c
      double precision teindi(nbteto,ncmpin), teinin(nbteto,ncmpin)
      double precision heindi(nbheto,ncmpin), heinin(nbheto,ncmpin)
      double precision pyindi(nbpyto,ncmpin), pyinin(nbpyto,ncmpin)
      double precision peindi(nbpeto,ncmpin), peinin(nbpeto,ncmpin)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer laface, typfac
      integer lamail, typenh
c
      double precision valaux(lgdaux)
c
      integer nbfite, nbvote, voiste(lgdaux)
      integer nbfihe, nbvohe, voishe(lgdaux)
      integer nbfipy, nbvopy, voispy(lgdaux)
      integer nbfipe, nbvope, voispe(lgdaux)
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
c 1.1. ==> Les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Saut a la traversee des faces'')'
      texte(1,5) =
     > '(''On veut'',i6,'' composantes, mais taille de daux ='',i6)'
      texte(1,6) = '(''. Examen du '',a,i10)'
c
      texte(2,4) = '(''. Jump through the faces'')'
      texte(2,5) =
     > '(i6,''components are requested, but size of daux equals'',i6)'
      texte(2,6) = '(''. Examen du '',a,i10)'
c
#include "impr03.h"
20000 format(a,i10,a,20g16.8)
20001 format(2(a,i10))
c
      codret = 0
c
c 1.2. ==> controle
c
      if ( ncmpin.gt.lgdaux ) then
        write (ulsort,texte(langue,5)) ncmpin, lgdaux
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. Calcul du saut entre chaque tetraedre et ses voisins
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. parcours tetraedre ; codret = ', codret
      write (ulsort,90002) 'nbtecf', nbtecf
#endif
c
      typfac = 2
      typenh = 3
      do 21 , iaux = 1 , nbtecf
c
        if ( tesupp(iaux).gt.0 ) then
c
        lamail = iaux
cgn      write (ulsort,*) 'lamail = ', lamail
c
c 2.1.1. ==> Recherche des voisins par chacune des faces
c
        nbvote = 0
        nbvohe = 0
        nbvopy = 0
        nbvope = 0
c
        do 211 , kaux = 1 , 4
c
          if ( codret.eq.0 ) then
c
          laface = tritet(iaux,kaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV6 / tetr', nompro
#endif
          call deisv6 ( laface, typfac, lamail, typenh,
     >                  hettri, pertri,
     >                  hetqua, perqua,
     >                  pertet,
     >                  hethex, filhex, perhex, fhpyte,
     >                  voltri, pypetr,
     >                  volqua, pypequ,
     >                  nbvote, voiste,
     >                  nbvohe, voishe,
     >                  nbvopy, voispy,
     >                  nbvope, voispe,
     >                  ulsort, langue, codret )
c
          endif
c
  211   continue
c
c 2.1.2. ==> Retrait de la maille courante de la liste des voisins
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV7 / tetr', nompro
#endif
cc        call deisv7 ( lamail, nbvote, voiste,
cc     >                ulsort, langue, codret )
c
        endif
c
c 2.1.3. ==> Calcul des sauts
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV5 / tetr', nompro
#endif
        call deisv5 ( lamail, ncmpin, usacmp,
     >                nbteto, teindi, teinin,
     >                tesupp, teinin,
     >                hesupp, heinin,
     >                pysupp, pyinin,
     >                pesupp, peinin,
     >                nbvote, voiste,
     >                nbvohe, voishe,
     >                nbvopy, voispy,
     >                nbvope, voispe,
     >                valaux,
     >                ulsort, langue, codret)
c
        endif
c
        endif
c
   21 continue
c
c====
c 3. Calcul du saut entre chaque hexaedre et ses voisins
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. parcours hexaedre ; codret = ', codret
      write (ulsort,90002) 'nbhecf', nbhecf
#endif
c
      typfac = 4
      typenh = 6
      do 31 , iaux = 1 , nbhecf
c
        if ( hesupp(iaux).gt.0 ) then
c
        lamail = iaux
cgn      write (ulsort,*) 'lamail = ', lamail
c
c 3.1.1. ==> Recherche des voisins par chacune des faces
c
        nbvote = 0
        nbvohe = 0
        nbvopy = 0
        nbvope = 0
c
        do 311 , kaux = 1 , 6
c
          if ( codret.eq.0 ) then
c
          laface = quahex(iaux,kaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV6 / hexa', nompro
#endif
          call deisv6 ( laface, typfac, lamail, typenh,
     >                  hettri, pertri,
     >                  hetqua, perqua,
     >                  pertet,
     >                  hethex, filhex, perhex, fhpyte,
     >                  voltri, pypetr,
     >                  volqua, pypequ,
     >                  nbvote, voiste,
     >                  nbvohe, voishe,
     >                  nbvopy, voispy,
     >                  nbvope, voispe,
     >                  ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'apres la face', kaux
      write (ulsort,90002) 'nbvote', nbvote
      write (ulsort,90002) 'nbvohe', nbvohe
      write (ulsort,90002) 'nbvopy', nbvopy
      write (ulsort,90002) 'nbvope', nbvope
#endif
c
          endif
c
  311   continue
c
c 3.1.2. ==> Retrait de la maille courante de la liste des voisins
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV7 / hexa', nompro
#endif
cc        call deisv7 ( lamail, nbvohe, voishe,
cc     >                ulsort, langue, codret )
c
        endif
c
c 3.1.3. ==> Calcul des sauts
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV5 / hexa', nompro
#endif
        call deisv5 ( lamail, ncmpin, usacmp,
     >                nbheto, heindi, heinin,
     >                tesupp, teinin,
     >                hesupp, heinin,
     >                pysupp, pyinin,
     >                pesupp, peinin,
     >                nbvote, voiste,
     >                nbvohe, voishe,
     >                nbvopy, voispy,
     >                nbvope, voispe,
     >                valaux,
     >                ulsort, langue, codret)
c
        endif
c
        endif
c
   31 continue
c
c====
c 4. Calcul du saut entre chaque pyramide et ses voisins
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. parcours pyramide ; codret = ', codret
      write (ulsort,90002) 'nbpycf', nbpycf
#endif
c
      typenh = 5
      do 41 , iaux = 1 , nbpycf
c
        if ( pysupp(iaux).gt.0 ) then
c
        lamail = iaux
cgn      write (ulsort,*) 'lamail = ', lamail
c
c 4.1.1. ==> Recherche des voisins par chacune des faces
c
        nbvote = 0
        nbvohe = 0
        nbvopy = 0
        nbvope = 0
c
        do 411 , kaux = 1 , 5
c
          if ( codret.eq.0 ) then
c
          laface = facpyr(iaux,kaux)
          if ( kaux.le.4 ) then
            typfac = 2
          else
            typfac = 4
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV6 / pyra', nompro
#endif
          call deisv6 ( laface, typfac, lamail, typenh,
     >                  hettri, pertri,
     >                  hetqua, perqua,
     >                  pertet,
     >                  hethex, filhex, perhex, fhpyte,
     >                  voltri, pypetr,
     >                  volqua, pypequ,
     >                  nbvote, voiste,
     >                  nbvohe, voishe,
     >                  nbvopy, voispy,
     >                  nbvope, voispe,
     >                  ulsort, langue, codret )
c
          endif
c
  411   continue
c
c 4.1.2. ==> Retrait de la maille courante de la liste des voisins
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV7 / pyra', nompro
#endif
cc        call deisv7 ( lamail, nbvopy, voispy,
cc     >                ulsort, langue, codret )
c
        endif
c
c 4.1.3. ==> Calcul des sauts
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV5 / pyra', nompro
#endif
        call deisv5 ( lamail, ncmpin, usacmp,
     >                nbpyto, pyindi, pyinin,
     >                tesupp, teinin,
     >                hesupp, heinin,
     >                pysupp, pyinin,
     >                pesupp, peinin,
     >                nbvote, voiste,
     >                nbvohe, voishe,
     >                nbvopy, voispy,
     >                nbvope, voispe,
     >                valaux,
     >                ulsort, langue, codret)
c
        endif
c
        endif
c
   41 continue
c
c====
c 5. Calcul du saut entre chaque pentaedre et ses voisins
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. parcours pentaedre ; codret = ', codret
      write (ulsort,90002) 'nbpecf', nbpecf
#endif
c
      typenh = 7
      do 51 , iaux = 1 , nbpecf
c
        if ( pesupp(iaux).gt.0 ) then
c
        lamail = iaux
c
c 5.1.1. ==> Recherche des voisins par chacune des faces
c
        nbvote = 0
        nbvohe = 0
        nbvopy = 0
        nbvope = 0
c
        do 511 , kaux = 1 , 5
c
          if ( codret.eq.0 ) then
c
          laface = facpen(iaux,kaux)
          if ( kaux.le.2 ) then
            typfac = 2
          else
            typfac = 4
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV6 / pent', nompro
#endif
          call deisv6 ( laface, typfac, lamail, typenh,
     >                  hettri, pertri,
     >                  hetqua, perqua,
     >                  pertet,
     >                  hethex, filhex, perhex, fhpyte,
     >                  voltri, pypetr,
     >                  volqua, pypequ,
     >                  nbvote, voiste,
     >                  nbvohe, voishe,
     >                  nbvopy, voispy,
     >                  nbvope, voispe,
     >                  ulsort, langue, codret )
c
          endif
c
  511   continue
c
c 5.1.2. ==> Retrait de la maille courante de la liste des voisins
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV7 / pent', nompro
#endif
        call deisv7 ( lamail, nbvope, voispe,
     >                ulsort, langue, codret )
c
        endif
c
c 5.1.3. ==> Calcul des sauts
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV5 / pent', nompro
#endif
        call deisv5 ( lamail, ncmpin, usacmp,
     >                nbpeto, peindi, peinin,
     >                tesupp, teinin,
     >                hesupp, heinin,
     >                pysupp, pyinin,
     >                pesupp, peinin,
     >                nbvote, voiste,
     >                nbvohe, voishe,
     >                nbvopy, voispy,
     >                nbvope, voispe,
     >                valaux,
     >                ulsort, langue, codret)
c
        endif
c
        endif
c
   51 continue
c
c====
c 6. Calcul des sauts pour les fils des hexaedres coupes par conformite
c    s'ils sont decrits par aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. fils des hexaedres ; codret = ', codret
#endif
c
      if ( nbteca.gt.0 .or. nbheca.gt.0 .or. nbpyca.gt.0 ) then
c
        do 61 , jaux = 1 , nbhecf
c
          iaux = jaux
c
          if ( mod(hethex(iaux),1000).ge.11 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) mess14(langue,1,6), iaux
#endif
c
c 6.1. ==> Recherche des mailles a considerer
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISV8', nompro
#endif
            call deisv8 ( iaux,
     >                    filqua,
     >                    hethex, quahex,
     >                    filhex, fhpyte,
     >                    volqua,
     >                    nbfite, nbvote, voiste,
     >                    nbfihe, nbvohe, voishe,
     >                    nbfipy, nbvopy, voispy,
     >                    ulsort, langue, codret )
c
            endif
c
c 6.2. ==> Calcul des sauts entre chaque fils de l'hexaedre et les
c          voisins contenus dans la liste
c
            if ( codret.eq.0 ) then
c
            do 621 , kaux = 1 , nbfite
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) '. DEISV5 / tetr', nompro
#endif
              call deisv5 ( voiste(kaux), ncmpin, usacmp,
     >                      nbteto, teindi, teinin,
     >                      tesupp, teinin,
     >                      hesupp, heinin,
     >                      pysupp, pyinin,
     >                      pesupp, peinin,
     >                      nbvote, voiste,
     >                      nbvohe, voishe,
     >                      nbvopy, voispy,
     >                      nbvope, voispe,
     >                      valaux,
     >                      ulsort, langue, codret)
  621       continue
c
            do 622 , kaux = 1 , nbfihe
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) '. DEISV5 / hexa', nompro
#endif
              call deisv5 ( voishe(kaux), ncmpin, usacmp,
     >                      nbheto, heindi, heinin,
     >                      tesupp, teinin,
     >                      hesupp, heinin,
     >                      pysupp, pyinin,
     >                      pesupp, peinin,
     >                      nbvote, voiste,
     >                      nbvohe, voishe,
     >                      nbvopy, voispy,
     >                      nbvope, voispe,
     >                      valaux,
     >                      ulsort, langue, codret)
  622       continue
c
            do 623 , kaux = 1 , nbfipy
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) '. DEISV5 / pyra', nompro
#endif
              call deisv5 ( voispy(kaux), ncmpin, usacmp,
     >                      nbpyto, pyindi, pyinin,
     >                      tesupp, teinin,
     >                      hesupp, heinin,
     >                      pysupp, pyinin,
     >                      pesupp, peinin,
     >                      nbvote, voiste,
     >                      nbvohe, voishe,
     >                      nbvopy, voispy,
     >                      nbvope, voispe,
     >                      valaux,
     >                      ulsort, langue, codret)
  623       continue
c
            endif
c
          endif
c
   61   continue
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
