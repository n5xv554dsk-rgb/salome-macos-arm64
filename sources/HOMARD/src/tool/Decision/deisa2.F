      subroutine deisa2 ( nbvent, ncmpin, usacmp,
     >                    nosupp, noindi,
     >                    arsupp, arindi,
     >                    trsupp, trindi,
     >                    qusupp, quindi,
     >                    tesupp, teindi, teinin,
     >                    hesupp, heindi, heinin,
     >                    pysupp, pyindi, pyinin,
     >                    pesupp, peindi, peinin,
     >                    hetare, somare, filare, merare,
     >                    hettri, aretri, filtri, pertri,
     >                    hetqua, arequa, filqua, perqua,
     >                    hettet, tritet, pertet, pthepe,
     >                    hethex, quahex, filhex, perhex, fhpyte,
     >                    facpyr,
     >                    facpen,
     >                    posifa, facare,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
     >                    tabent, tabree,
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
c traitement des DEcisions - Initialisations - SAut - etape 2
c                --          -                 --           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbvent .  e .   -1:7  . nombre d'entites actives pour chaque type  .
c .        .     .        . d'element au sens HOMARD avec indicateur   .
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . nosupp . e   . nbnoto . support pour les noeuds                    .
c . noindi . es  . nbnoto . valeurs reelles pour les noeuds            .
c . arsupp .  s  . nbarto . support pour les aretes                    .
c . arindi .  s  . nbarto . valeurs reelles pour les aretes            .
c . trsupp . e   . nbtrto . support pour les triangles                 .
c . trindi .  s  . nbtrto . valeurs pour les triangles                 .
c . qusupp . e   . nbquto . support pour les quadrangles               .
c . quindi .  s  . nbquto . valeurs pour les quadrangles               .
c . tesupp . e   . nbteto . support pour les tetraedres                .
c . teindi . es  . nbteto . valeurs pour les tetraedres                .
c . teinin . a   . nbteto . valeurs initiales pour les tetraedres      .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
c . heindi . es  . nbheto . valeurs pour les hexaedres                 .
c . heinin . a   . nbheto . valeurs initiales pour les hexaedres       .
c . pysupp . e   . nbpyto . support pour les pyramides                 .
c . pyindi . es  . nbpyto . valeurs pour les pyramides                 .
c . pyinin . a   . nbpyto . valeurs initiales pour les pyramides       .
c . pesupp . e   . nbpeto . support pour les pentaedres                .
c . peindi . es  . nbpeto . valeurs pour les pentaedres                .
c . peinin . a   . nbpeto . valeurs initiales pour les pentaedres      .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . fils des aretes                            .
c . merare . e   . nbarto . pere des aretes                            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . pertri . e   . nbtrto . pere des triangles                         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . fils des quadrangles                       .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
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
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
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
c . tabent . aux .   *    . tableau auxiliaire entier                  .
c . tabree . aux .   *    . tableau auxiliaire reel                    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme dans les fichiers             .
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
      parameter ( nompro = 'DEISA2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer nbvent(-1:7), ncmpin
      integer usacmp
      integer nosupp(nbnoto)
      integer arsupp(nbarto)
      integer trsupp(nbtrto)
      integer qusupp(nbquto)
      integer tesupp(nbteto)
      integer hesupp(nbheto)
      integer pysupp(nbpyto)
      integer pesupp(nbpeto)
      integer hetare(nbarto), somare(2,nbarto)
      integer filare(nbarto), merare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer filtri(nbtrto), pertri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer filqua(nbquto), perqua(nbquto)
      integer hettet(nbteto), tritet(nbtecf,4)
      integer pertet(nbteto), pthepe(*)
      integer hethex(nbheto), quahex(nbhecf,6)
      integer filhex(nbheto), perhex(nbheto)
      integer fhpyte(2,nbheco)
      integer facpyr(nbpycf,5)
      integer facpen(nbpecf,5)
      integer posifa(0:nbarto), facare(nbfaar)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer volqua(2,nbquto), pypequ(2,*)
      integer tabent(2,*)
c
      integer ulsort, langue, codret
c
      double precision noindi(nbnoto,ncmpin)
      double precision arindi(nbarto,ncmpin)
      double precision trindi(nbtrto,ncmpin)
      double precision quindi(nbquto,ncmpin)
      double precision teindi(nbteto,ncmpin), teinin(nbteto,ncmpin)
      double precision heindi(nbheto,ncmpin), heinin(nbheto,ncmpin)
      double precision pyindi(nbpyto,ncmpin), pyinin(nbpyto,ncmpin)
      double precision peindi(nbpeto,ncmpin), peinin(nbpeto,ncmpin)
      double precision tabree(ncmpin,*)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nbmess
      parameter ( nbmess = 10 )
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
      texte(1,4) = '(''. Indicateur defini sur les '',i10,1x,a)'
      texte(1,5) = '(''. Saut de l''''indicateur le long des '',a)'
      texte(1,6) =
     > '(''. Saut de l''''indicateur a la traversee des '',a)'
c
      texte(2,4) = '(''. Indicator defined over the '',i10,1x,a)'
      texte(2,5) = '(''. Jump of error indicator along the '',a)'
      texte(2,6) = '(''. Jump of error indicator through the '',a)'
c
#include "impr03.h"
c
c====
c 2. Au moins un indicateur est exprime sur les noeuds
c====
c
      if ( codret.eq.0 ) then
c
      iaux = -1
      if ( nbvent(iaux).gt.0 ) then
c
        write (ulsort,texte(langue,4)) nbnoto, mess14(langue,3,iaux)
        write (ulsort,texte(langue,5)) mess14(langue,3,1)
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEISNO', nompro
#endif
        call deisno ( ncmpin, nosupp, noindi,
     >                arsupp, arindi, jaux,
     >                hetare, somare,
     >                ulsort, langue, codret )
c
        nbvent(1) = jaux
c
      endif
c
      endif
c
c====
c 3. Au moins un indicateur est exprime sur les aretes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      if ( nbvent(iaux).gt.0 .and. nbvent(iaux).eq.0 ) then
c
        write (ulsort,texte(langue,4)) nbarto, mess14(langue,3,iaux)
        write(ulsort,*) 'A Programmer'
        write(ulsort,*) 'To Do ...'
        codret = 12
c
      endif
c
      endif
c
c====
c 4. Au moins un indicateur est exprime sur les faces
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. faces ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvent(2).gt.0 .or. nbvent(4).gt.0 ) then
c
        if ( nbvent(2).eq.0 ) then
          iaux = 4
          jaux = nbvent(4)
        elseif ( nbvent(4).eq.0 ) then
          iaux = 2
          jaux = nbvent(2)
        else
          iaux = 8
          jaux = nbvent(2) + nbvent(4)
        endif
        write (ulsort,texte(langue,4)) jaux, mess14(langue,3,iaux)
        write (ulsort,texte(langue,6)) mess14(langue,3,1)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEISFA', nompro
#endif
        call deisfa ( ncmpin, usacmp,
     >                trsupp, trindi, qusupp, quindi,
     >                hetare, filare, merare,
     >                posifa, facare,
     >                hettri, aretri, hetqua, arequa,
     >                tabent, tabree,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. Au moins un indicateur est exprime sur les volumes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. volumes ; codret', codret
#endif
c
      if ( nbvent(3).gt.0 .or. nbvent(5).gt.0 .or.
     >     nbvent(6).gt.0 .or. nbvent(7).gt.0 ) then
c
c 5.1. ==> sauvegardes des valeurs initiales
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEISV0', nompro
#endif
        call deisv0 ( ncmpin, nbvent,
     >                tesupp, teindi, teinin,
     >                hesupp, heindi, heinin,
     >                pysupp, pyindi, pyinin,
     >                pesupp, peindi, peinin,
     >                ulsort, langue, codret )
c
        endif
c
c 5.2. ==> Saut entre entites
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.2. saut ; codret', codret
#endif
c
c 5.2.1. ==> L'indicateur est exprime exclusivement sur les tetraedres
c
        if ( nbvent(3).gt.0 .and. nbvent(5).eq.0 .and.
     >       nbvent(6).eq.0 .and. nbvent(7).eq.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 3
          write (ulsort,texte(langue,4)) nbteto, mess14(langue,3,iaux)
          write (ulsort,texte(langue,6)) mess14(langue,3,2)
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'DEISV1_te', nompro
#endif
          call deisv1 ( ncmpin, usacmp, nbteto, iaux,
     >                  tesupp, teindi,
     >                  hettri, filtri, pertri,
     >                  hetqua, filqua, perqua,
     >                  hettet, tritet,
     >                  voltri, volqua,
     >                  tabent, teinin,
     >                  ulsort, langue, codret )
c
          endif
c
c 5.2.2. ==> L'indicateur est exprime exclusivement sur les hexaedres
c
        elseif ( nbvent(3).eq.0 .and. nbvent(5).eq.0 .and.
     >           nbvent(6).gt.0 .and. nbvent(7).eq.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 6
          write (ulsort,texte(langue,4)) nbheto, mess14(langue,3,iaux)
          write (ulsort,texte(langue,6)) mess14(langue,3,4)
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEISV1_he', nompro
#endif
          call deisv1 ( ncmpin, usacmp, nbheto, iaux,
     >                  hesupp, heindi,
     >                  hettri, filtri, pertri,
     >                  hetqua, filqua, perqua,
     >                  hethex, quahex,
     >                  voltri, volqua,
     >                  tabent, heinin,
     >                  ulsort, langue, codret )
c
          endif
c
c 5.2.3. ==> L'indicateur est reparti sur plusieurs types de volumes
c
        else
c
          if ( codret.eq.0 ) then
c
          jaux = nbvent(3) + nbvent(5)+ nbvent(6)+ nbvent(7)
          iaux = 9
          write (ulsort,texte(langue,4)) jaux, mess14(langue,3,iaux)
          write (ulsort,texte(langue,6)) mess14(langue,3,8)
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'DEISV2', nompro
#endif
          call deisv2 ( ncmpin, usacmp,
     >                  tesupp, teindi, teinin,
     >                  hesupp, heindi, heinin,
     >                  pysupp, pyindi, pyinin,
     >                  pesupp, peindi, peinin,
     >                  hettri, pertri,
     >                  hetqua, filqua, perqua,
     >                  tritet, pertet, pthepe,
     >                  quahex, hethex, filhex, perhex, fhpyte,
     >                  facpyr,
     >                  facpen,
     >                  voltri, pypetr,
     >                  volqua, pypequ,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
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
