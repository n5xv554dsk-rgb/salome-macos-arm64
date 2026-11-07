      subroutine infc03 ( numcas,
     >                    typenh, nbcomp, nbenti, nbentf, nbenta,
     >                    codent, insuen, coaent,
     >                    perent, pehepe, nentca,
     >                    coonoe, somare, merare,
     >                    aretri, pertri, nivtri,
     >                    arequa, perqua, nivqua,
     >                    quahex, facpen,
     >                    npenrc, entrec,
     >                    nbentc, profil, vafoti, vafotr,
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
c  INformation - inFormations Complementaires - phase 03
c  --              -          -                       --
c  Calcul des valeurs
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
c . nbcomp . e   .   1    . nombre de composantes                      .
c . nbenti . e   .   1    . nombre total d'entites concernees          .
c . nbentf . e   .   1    . nombre d'entites concernees - par faces    .
c . nbenta . e   .   1    . nombre d'entites concernees - par aretes   .
c . codent . e   .    *   . connectivite descendante des entites       .
c . insuen . e   .    *   . informations supplementaires des entites   .
c . coaent . e   .    *   . connectivite par aretes des entites        .
c . perent . e   . nbenti . pere des entites                           .
c .        .     .        . pour un tetraedre ou une pyramide          .
c .        .     .        . si perent(i) > 0 : numero du pere meme type.
c .        .     .        . si perent(i) < 0 : -numero dans pehepe     .
c . pehepe . e   .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . nentca . e   .   *    . numero des entites dans le calcul          .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . merare . e   . nbarto . mere de chaque arete                       .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . pertri . e   . nbtrto . pere des triangles                         .
c . nivtri . e   . nbtrto . niveau dans le raffinement/deraffinement   .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . npenrc . e   .    1   . nombre de paires d'entites recollees       .
c . entrec . e   .3*npenrc. paires des entites voisines faces a recol. .
c . nbentc . e   .   1    . nombre total d'entites du calcul           .
c . profil .  s  . nbentc . pour chaque entite du calcul :             .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vafoti .  s  . nbentc . tableau temporaire de la fonction          .
c . vafotr .  s  . nbentc . tableau temporaire de la fonction          .
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
      parameter ( nompro = 'INFC03' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "impr02.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer numcas
      integer typenh, nbcomp, nbenti, nbentf, nbenta
      integer codent(nbentf,*), insuen(nbentf,*), coaent(nbenta,*)
      integer perent(nbenti), pehepe(*), nentca(*)
      integer somare(2,nbarto), merare(nbarto)
      integer aretri(nbtrto,3), pertri(nbtrto), nivtri(nbtrto)
      integer arequa(nbquto,4), perqua(nbquto), nivqua(nbquto)
      integer quahex(nbhecf,6)
      integer facpen(nbpecf,5)
      integer npenrc, entrec(3,npenrc)
c
      integer nbentc
      integer profil(nbentc)
      integer vafoti(nbentc)
c
      double precision coonoe(nbnoto,sdim)
      double precision vafotr(nbentc)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
      texte(1,4) = '(''.. Examen des '',a)'
c
      texte(2,4) = '(''.. Examination of the '',a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,90002) 'nbentc', nbentc
#endif
c
      codret = 0
c
c====
c 2. Les triangles
c====
c
      if ( typenh.eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. triangles ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFC32', nompro
#endif
        call infc32 ( numcas, nbcomp, nbentc,
     >                profil, vafoti, vafotr,
     >                aretri, pertri, nivtri,
     >                nentca,
     >                coonoe, somare,
     >                ulsort, langue, codret )
c
        endif
c
c====
c 3. Les tetraedres
c====
c
      elseif ( typenh.eq.3 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. tetraedres ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFC33', nompro
#endif
        call infc33 ( numcas, nbcomp, nbentc,
     >                profil, vafoti, vafotr,
     >                codent, insuen, coaent,
     >                perent, pehepe, nentca,
     >                coonoe, somare,
     >                aretri, nivtri,
     >                nivqua,
     >                quahex, facpen,
     >                npenrc, entrec,
     >                ulsort, langue, codret )
c
        endif
c
c====
c 4. Les quadrangles
c====
c
      elseif ( typenh.eq.4 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. quadrangles ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFC34', nompro
#endif
        call infc34 ( numcas, nbcomp, nbentc,
     >                profil, vafoti, vafotr,
     >                arequa, perqua, nivqua,
     >                nentca,
     >                coonoe, somare,
     >                ulsort, langue, codret )
c
        endif
c
c====
c 5. Les pyramides
c====
c
      elseif ( typenh.eq.5 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. pyramides ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFC35', nompro
#endif
        call infc35 ( numcas, nbcomp, nbentc,
     >                profil, vafoti, vafotr,
     >                codent, insuen, coaent,
     >                perent, pehepe, nentca,
     >                coonoe, somare,
     >                aretri, nivtri,
     >                nivqua,
     >                quahex, facpen,
     >                ulsort, langue, codret )
c
        endif
c
c====
c 6. Les hexaedres
c====
c
      elseif ( typenh.eq.6 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. hexaedres ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFC36', nompro
#endif
        call infc36 ( numcas, nbcomp, nbentc,
     >                profil, vafoti, vafotr,
     >                codent, insuen, coaent,
     >                perent, nentca,
     >                coonoe, somare,
     >                arequa, nivqua,
     >                npenrc, entrec,
     >                ulsort, langue, codret )
c
        endif
c
c====
c 7. Les pentaedres
c====
c
      elseif ( typenh.eq.7 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. pentaedres ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFC37', nompro
#endif
        call infc37 ( numcas, nbcomp, nbentc,
     >                profil, vafoti, vafotr,
     >                codent, insuen, coaent,
     >                perent, nentca,
     >                coonoe, somare,
     >                nivtri,
     >                arequa, nivqua,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 8. la fin
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
