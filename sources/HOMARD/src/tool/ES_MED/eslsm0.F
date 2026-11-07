      subroutine eslsm0 ( nocson, nomfic, lnomfi,
     >                    nomamd, lnomam,
     >                    nbseal, nbtosv,
     >                    cactal, caetal, cartal,
     >                    messin, option,
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
c  Entree-Sortie - Lecture d'une Solution au format Med - phase 0
c  -      -        -             -                  -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocson .   s . char*8 . nom de l'objet solution calcul iteration n .
c . nomfic . e   . char*  . nom du fichier                             .
c . lnomfi . e   .    1   . longueur du nom du fichier                 .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . lnomam . e   .    1   . longueur du nom du maillage                .
c . nbseal . e   .    1   . nombre de sequences a lire                 .
c .        .     .        . si -1, on lit tous les champs du fichier   .
c . nbtosv .  s  .    1   . nombre total de sequences lues             .
c . cactal . e   .8*nbseal. caracteristiques caracteres de chaque      .
c .        .     .        . tableau a lire                             .
c .        .     .        . 1,...,8. nom du champ associe              .
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
c . messin . e   .   1    . message d'informations                     .
c .        .     .        . impressions MED si multiple de 3           .
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
c  ESLSMD -> ESLSM0 -> ESOUVL -> ESVERI -> MFICOM
c /ESLIMD                               -> MLBSTV
c                                       -> MFIOPE
c                                       -> MFISVR
c                                       -> MFICLO
c                             -> MFIOPE
c                             -> ESLENT -> MFICOR
c                   -> ESLNOM -> MMHNMH
c                             -> MMHMII
c                   -> MFDNFD
c                   -> MLCNLC
c                   -> ESLSM1 -> MFDNFC
c                             -> MFDFDI
c                             -> ESLCH1
c                             -> ESLCH2 -> MFDCSI
c                                       -> MFDNPF
c                                       -> ESLPR1 -> MPFPSN
c                                                 -> MPFPRR
c                                       -> ESLPG1 -> ESLPG2 -> MLCNLC
c                                                           -> MLCLCI
c                                                 -> MLCLOR
c                                       -> MFDNPN
c                             -> ESLCH6
c                   -> ESLSM2 -> ESLCH3
c                             -> ESLCH7
c                   -> ESLSM3
c                   -> ESLSM4 -> ESLCH4 -> MFDRPR
c                                       -> ESLCH5
c                   -> ESLSM5
c         -> MFICLO
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
      parameter ( nompro = 'ESLSM0' )
c
#include "nblang.h"
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
      integer lnomfi, lnomam
      integer nbseal, nbtosv
      integer caetal(12,*)
c
      double precision cartal(*)
c
      character*8 nocson
      character*8 cactal(*)
      character*64 nomamd
      character*200 nomfic
c
      integer messin, option
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codre1, codre2
      integer codre0
c
      integer nbchfi, nbcham, nbfonc, nbprof, nblopg
      integer nbrpro, nbrlpg
      integer nbpafo
      integer adinch, adinpf, adinpr, adinlg
      integer adtra1, adtra2
      integer typrep
c
      integer*8 idfmed
c
      character*8 ntrav1, ntrav2
      character*16 nomaxe(3), uniaxe(3)
#ifdef _DEBUG_HOMARD_
      character*8 saux08
#endif
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
#include "impr03.h"
c
#include "esimpr.h"
c
c====
c 2. prealables
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. prealables ; codret', codret
#endif
c
c 2.1. ==> ouverture du fichier MED
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      iaux = max(3,messin)
#else
      iaux = messin
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESOUVL', nompro
#endif
      call esouvl ( idfmed, nomfic(1:lnomfi), iaux,
     >              ulsort, langue, codret )
c
      endif
c
c 2.2. ==> le maillage est-il present dans le fichier ?
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLNOM', nompro
#endif
      call eslnom ( idfmed, nomamd, lnomam,
     >                iaux,   jaux,
     >              typrep, nomaxe, uniaxe,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. nombre de champs dans le fichier : s'il n'y en n'a pas, on met
c    tout a zero et on passera par-dessus la suite
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. nb champs dans fichier ; codret', codret
#endif
c
c 3.1. ==> nombre de champs dans le fichier
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDNFD', nompro
#endif
      call mfdnfd ( idfmed, nbchfi, codret )
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90002) 'Nombre de champs dans le fichier', nbchfi
      endif
#endif
c
      endif
c
c 3.2. ==> nombre de localisations de points de Gauss dans le fichier
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MLCNLC', nompro
#endif
      call mlcnlc ( idfmed, nbrlpg, codret )
      if ( codret.ne.0 ) then
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,79))
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,82)) nbrlpg
#endif
c
      endif
c
c 3.3. ==> nombre de profils dans le fichier
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFNPF', nompro
#endif
      call mpfnpf ( idfmed, nbrpro, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,86)) nbrpro
#endif
c
      endif
c
c 3.4. ==> allocation de l'objet solution : la tete et la
c          branche des champs
c          On suppose qu'il n'y a ni fonction, ni profil, ni
c          localisation de points de Gauss
c
      if ( codret.eq.0 ) then
c
      iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALSO', nompro
#endif
      call utalso ( nocson,
     >              nbchfi, iaux, iaux, iaux,
     >              adinch, adinpf, adinpr, adinlg,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. caracterisations des champs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. caracterisations champs ; codret', codret
#endif
c
      nbtosv = 0
      nbprof = 0
      nblopg = 0
c
      if ( nbchfi.ne.0 ) then
c
c 4.1. ==> tableaux temporaires pour stocker les noms des eventuels
c          profils et localisations de points de Gauss a lire
c
        if ( codret.eq.0 ) then
c
        iaux = 9*nbchfi*nbrpro
        call gmalot ( ntrav1, 'chaine', iaux, adtra1, codre1 )
        iaux = 9*nbchfi*nbrlpg
        call gmalot ( ntrav2, 'chaine', iaux, adtra2, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
c 4.2. ==> A partir des nbchfi champs contenus dans le fichier, on
c          cree les caracteristiques de ce qu'il faut lire. On
c          recupere leur nombre, nbcham, et le nombre total de
c          tableaux de valeurs auxquels cela correspond, nbtosv
c          On ne s'interesse ici qu'aux caracteristiques des tableaux
c          de valeurs.
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSM1', nompro
#endif
        call eslsm1 ( idfmed, nomamd,
     >                nbchfi, option,
     >                nbseal, cactal, caetal, cartal,
     >                nbcham, smem(adinch), nbtosv,
     >                nbprof, smem(adtra1),
     >                nblopg, smem(adtra2),
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbseal',nbseal
      if ( nbseal.gt.0 ) then
      write (ulsort,90005) 'caetal',(caetal(iaux,1),iaux=1,12)
      write (ulsort,90004) 'cartal',cartal(1)
      endif
      if ( codret.eq.0 ) then
        write (ulsort,90002) 'Nbre de champs a lire (nbcham)   ', nbcham
        write (ulsort,90002) 'Nbre cumule de sequences (nbtosv)', nbtosv
        write (ulsort,90002) 'Nbre cumule de profils (nbprof)  ', nbprof
cgn        call gmprsx (nompro, ntrav1 )
      endif
#endif
c
c 4.3. ==> stockage de l'information sur les champs dans la
c          structure solution
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)'Avant 4.3., codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nocson, 1, nbcham, codre1 )
        call gmmod ( nocson//'.InfoCham',
     >               adinch, nbchfi, nbcham, 1, 1, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
40000 format(/,'Apres 4.3., solution ',a8,/,29('='),/)
        write (ulsort,40000) nocson
        call gmprsx (nompro, nocson )
        call gmprsx (nompro, nocson//'.InfoCham' )
cgn        call gmprsx (nompro, '%%%%%%14' )
cgn        call gmprsx (nompro, '%%%%%%14.Nom_Comp' )
cgn        call gmprsx (nompro, '%%%%%%17.Cham_Ent' )
cgn        call gmprsx (nompro, '%%%%%%18.Cham_Ent' )
cgn        call gmprsx (nompro, '%%%%%%14.Cham_Ree' )
cgn        call gmprsx (nompro, '%%%%%%14.Cham_Car' )
        endif
#endif
c
c 4.4.==> creations des structures representant les profils
c         necessaires aux champs a lire
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)'Avant 4.4., codret', codret
#endif
c
        if ( nbprof.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
          call gmaloj ( nocson//'.InfoProf', ' ',
     >                  nbprof, adinpr, codre1 )
          call gmecat ( nocson, 3, nbprof, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
          endif
c
          if ( codret.eq.0 ) then
c
          do 44 , iaux = 1 , nbprof
            smem(adinpr+iaux-1) = smem(adtra1+5*iaux-1)
   44     continue
c
          endif
c
#ifdef _DEBUG_HOMARD_
40004 format(/,'Apres 4.4., solution ',a8,/,29('='),/)
          if ( codret.eq.0 ) then
          write (ulsort,40004) nocson
          call gmprsx (nompro, nocson )
          call gmprsx (nompro, nocson//'.InfoProf' )
cgn          call gmprsx (nompro, '%%%%%%%6' )
cgn          call gmprsx (nompro, '%%%%%%%6.NomProfi' )
cgn          call gmprsx (nompro, '%%%%%%%6.ListEnti' )
          endif
#endif
c
        endif
c
c 4.5. ==> creations des structures representant les localisations de
c          points de Gauss necessaires aux champs a lire
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Avant 4.5., codret', codret
#endif
c
        if ( nblopg.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
          call gmaloj ( nocson//'.InfoLoPG', ' ',
     >                  nblopg, adinlg, codre1 )
          call gmecat ( nocson, 4, nblopg, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
          endif
c
          if ( codret.eq.0 ) then
c
          do 45 , iaux = 1 , nblopg
            smem(adinlg+iaux-1) = smem(adtra2+9*iaux-1)
   45     continue
c
          endif
c
#ifdef _DEBUG_HOMARD_
40005 format(/,'Apres 4.5., solution ',a8,/,29('='),/)
          if ( codret.eq.0 ) then
          write (ulsort,40005) nocson
          call gmprsx (nompro, nocson )
          call gmprsx (nompro, nocson//'.InfoLoPG' )
          endif
#endif
c
        endif
c
c 4.6. ==> menage
c
        if ( codret.eq.0 ) then
c
        call gmlboj ( ntrav1, codre1 )
        call gmlboj ( ntrav2, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
      endif
c
c====
c 5. les fonctions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. les fonctions ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtosv.ne.0 ) then
c
c 5.1.==> classement des champs en fonctions
c         a priori, on suppose qu'il y a autant de fonctions differents
c         que de tableaux ; on pourrait corriger ensuite en fonction
c         des regroupements qui auront ete faits dans eslsm2, mais
c         c'est inutile de passer du temps a cela car les tableaux
c         sont detruits a la fin de cette sequence.
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'Nombre de fonctions suppose', nbtosv
        write (ulsort,90002) 'nbinec', nbinec
#endif
        iaux = nbinec*nbtosv
        call gmalot ( ntrav1, 'entier', iaux, adtra1, codre1 )
        iaux = 3*nbtosv
        call gmalot ( ntrav2, 'chaine', iaux, adtra2, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSM2', nompro
#endif
        call eslsm2 ( nbcham, smem(adinch), nbseal,
     >                nbfonc, imem(adtra1), smem(adtra2), option,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,90002) 'Nombre de fonctions (nbfonc)',nbfonc
        call gmprsx (nompro, ntrav1 )
        call gmprsx (nompro, ntrav2 )
       endif
#endif
c
c 5.2. ==> creations des structures pour les fonctions
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)'Avant 5.2, codret',codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSM3', nompro
#endif
c
        call eslsm3 ( nbfonc, imem(adtra1),
     >                smem(adtra2),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        call gmprsx (nompro, ntrav2 )
        endif
#endif
c
        endif
c
c 5.3. ==> lecture des valeurs numeriques et des eventuels profils
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)'Avant 5.3, codret',codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSM4', nompro
#endif
c
        call eslsm4 ( idfmed,
     >                nbcham, smem(adinch),
     >                nbfonc, imem(adtra1), smem(adtra2),
     >                ulsort, langue, codret )
c
        endif
c
c 5.4. ==> regroupement des fonctions en paquets
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Avant 5.4, codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        call gmaloj ( nocson//'.InfoPaFo', ' ', nbfonc, adinpf, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSM5', nompro
#endif
c
        call eslsm5 ( nbfonc, imem(adtra1), smem(adtra2), nbseal,
     >                nbpafo, smem(adinpf), option,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nocson, 2, nbpafo, codre1 )
        call gmmod ( nocson//'.InfoPaFo',
     >               adinpf, nbfonc, nbpafo, 1, 1, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,40054) nocson
        endif
40054 format(/,'Apres 5.4., solution ',a8,/,29('='),/)
        call gmprsx (nompro, nocson )
        call gmprsx (nompro, nocson//'.InfoPaFo' )
        do 54555 , iaux = adinpf , adinpf+nbpafo-1
        call gmprsx (nompro, smem(iaux) )
54555   continue
        call gmprsx (nompro, '%%Fo002I' )
        call gmprsx (nompro, '%%%%%%12' )
        call gmprsx (nompro,'%%%%%%12.ValeursR')
        call gmprsx (nompro,'%%%%%%12.InfoPrPG')
        call gmprsx (nompro, '%%%%%%10' )
        write (ulsort,*) '+++++++++++++++++++++++++++++++++++++++++'
#endif
c
        endif
c
c 5.5. ==> menage
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)'Avant 5.5, codret',codret
#endif
c
        if ( codret.eq.0 ) then
c
ccc        call gmprsx (nompro, ntrav1 )
        call gmlboj ( ntrav1, codre1 )
ccc        call gmprsx (nompro, ntrav2 )
        call gmlboj ( ntrav2, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
      endif
c
      endif
c
c====
c 6. fermeture du fichier
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. fermeture du fichier ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFICLO', nompro
#endif
      call mficlo( idfmed, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,10))
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
33333 format(80('*'))
44444 format(80('='))
      if ( codret.eq.0 ) then
      call gmprsx (nompro, nocson )
      call gmprsx (nompro, nocson//'.InfoCham' )
      call gmprsx (nompro, nocson//'.InfoPaFo' )
      call gmprsx (nompro, nocson//'.InfoProf' )
      write (ulsort,44444)
      do 61 , iaux = 6,20,2
      call utench ( iaux, 'd', codre0, saux08,
     >              ulsort, langue, codret )
      if (iaux.le.9 ) then
        saux08(1:7) = '%%%%%%%'
      else
        saux08(1:6) = '%%%%%%'
      endif
      call gmprsx (nompro,saux08)
      call gmprsx (nompro,saux08//'.NomProfi')
      call gmprsx (nompro,saux08//'.ListEnti')
      write (ulsort,33333)
61    continue
      write (ulsort,44444)
      do 62 , iaux = 42,46
      call utench ( iaux, 'd', codre0, saux08,
     >              ulsort, langue, codret )
      if (iaux.le.9 ) then
        saux08(1:7) = '%%%%%%%'
      else
        saux08(1:6) = '%%%%%%'
      endif
      call gmprsx (nompro,saux08)
      call gmprsx (nompro,saux08//'.Fonction')
      if ( iaux.eq.42 ) then
      call gmprsx (nompro,'%%%%%%36')
      call gmprsx (nompro,'%%%%%%36.ValeursR')
      call gmprsx (nompro,'%%%%%%36.InfoPrPG')
      write (ulsort,33333)
      endif
      call utench ( iaux-5, 'd', codre0, saux08,
     >              ulsort, langue, codret )
      saux08(1:6) = '%%%%%%'
      call gmprsx (nompro,saux08)
      call gmprsx (nompro,saux08//'.ValeursR')
      call gmprsx (nompro,saux08//'.InfoPrPG')
      write (ulsort,33333)
62    continue
      write (ulsort,44444)
      do 63 , iaux = 5,34
      if ( mod(iaux,2).eq.1 .or. iaux.ge.21 ) then
      call utench ( iaux, 'd', codre0, saux08,
     >              ulsort, langue, codret )
      if (iaux.le.9 ) then
        saux08(1:7) = '%%%%%%%'
      else
        saux08(1:6) = '%%%%%%'
      endif
      call gmprsx (nompro,saux08)
      endif
63    continue
cgn      call gmprsx (nompro, '%%%%%%14' )
cgn      call gmprsx (nompro, '%%%%%%14.Nom_Comp' )
cgn      call gmprsx (nompro, '%%%%%%14.Cham_Ent' )
cgn      call gmprsx (nompro, '%%%%%%14.Cham_Ree' )
cgn      call gmprsx (nompro, '%%%%%%14.Cham_Car' )
cgn      call gmprsx (nompro, '%%%%%%23' )
cgn      call gmprsx (nompro, '%%Fo004J')
cgn      call gmprsx (nompro, '%%%%%%21' )
cgn      call gmprsx (nompro, '%%%%%%21.InfoPrPG' )
      endif
#endif
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
      write (ulsort,texte(langue,8)) nomfic
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
