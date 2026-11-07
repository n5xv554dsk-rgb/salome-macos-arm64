      subroutine eslmmd ( mcfich, mcmail,
     >                    typcca, nocmai,
     >                    option, messin,
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
c  Entree-Sortie - Lecture du Maillage au format MeD
c  -      -        -          -                  - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . mcfich . e   . char*8 . mot-cle correspondant au fichier a lire    .
c . mcmail . e   . char*8 . mot-cle correspondant au maillage a lire   .
c . typcca . e   .   1    . type du code de calcul                     .
c . nocmai .  s  . char*8 . nom de l'objet maillage lu                 .
c . option . e   .    1   . option de lecture du maillage              .
c .        .     .        . 1 : lecture integrale                      .
c .        .     .        . 2 : uniquement les coordonnees des noeuds  .
c . messin . e   .   1    . message d'informations                     .
c .        .     .        . impressions MED si multiple de 3           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . en entree = celui du module d'avant        .
c .        .     .        . en sortie = celui du module en cours       .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 2x : probleme dans les memoires            .
c .        .     .        . 3x : probleme dans les fichiers            .
c .        .     .        . -10 : fichier inconnu                      .
c .        .     .        . -20 : nom de maillage inconnu              .
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
      parameter ( nompro = 'ESLMMD' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer typcca
c
      integer option
      integer messin
c
      character*8 mcfich, mcmail, nocmai
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre0
c
      integer pfamen, pcoonc, pnunoe, adcocs
      integer pfamee, pnoeel, ptypel, pnuele
      integer pnomfa, pnumfa
      integer pgrpo, pgrtai
      integer pgrtab, pcexno
      integer pinfpt, pinftl, pinftb
      integer adeqpo, adeqin
      integer adeqno, adeqmp, adeqar, adeqtr, adeqqu
      integer adeqte, adeqhe
      integer adnomb
      integer ptrav1
      integer*8 idfmed
      integer lnomfi, lnomam
      integer nbnoto
      integer typrep
      integer nbpqt
c
      integer nctfno
      integer sdimca, mdimca
      integer degre, mailet, maconf, homolo, hierar, nbmane
      integer nbelem, nbmaae, nbmafe,
     >        nbmapo, nbsegm, nbtria, nbtetr,
     >        nbquad, nbhexa, nbpent, nbpyra,
     >        numael, numano,
     >        nbfmed, nbfmen, ngrouc, nbgrm,
     >        nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
      integer nbeqte, nbeqhe
c
      character*80 titre
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
c
      character*8 typobs
      character*8 ntrav1
      character*16 nomaxe(3), uniaxe(3)
      character*64 nomamd
      character*200 nomfic
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
#endif
c
c====
c 2. premiers decodages
c====
c
c 2.1. ==> les constantes
c
      nctfno = 1
c
c 2.2. ==> nom du fichier contenant le maillage
c
      typobs = mcfich
      iaux = 0
      jaux = 1
      call utfino ( typobs, iaux, nomfic, lnomfi,
     >              jaux,
     >              ulsort, langue, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,8)) 'en entree'
        codret = -10
      endif
c
c 2.3. ==> nom du maillage dans ce fichier
c
      if ( codret.eq.0 ) then
      typobs = mcmail
      iaux = 0
      jaux = 0
      call utfino ( typobs, iaux, nomamd, lnomam,
     >              jaux,
     >              ulsort, langue, codret )
      if ( codret.ne.0 ) then
        call utosme ( typobs, ulsort, langue )
        if ( codret.eq.4 ) then
          write (ulsort,texte(langue,52)) lnomam
          write (ulsort,texte(langue,53)) len(nomamd)
        endif
        codret = -20
      endif
      endif
cgn      write(ulsort,90002) 'Fin etape 2 avec codret', codret
c
c====
c 3. premiere lecture du fichier
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. premiere lecture ; codret', codret
#endif
c
c 3.1. ==> ouverture du fichier
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      iaux = max(3,messin)
#else
      iaux = messin
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESOUVL', nompro
#endif
      call esouvl ( idfmed, nomfic(1:lnomfi), iaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2. ==> le maillage est-il present dans le fichier ?
c          si oui, on retourne les dimensions de l'espace et du maillage
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLNOM', nompro
#endif
      call eslnom ( idfmed, nomamd, lnomam,
     >              sdimca, mdimca,
     >              typrep, nomaxe, uniaxe,
     >              ulsort, langue, codret )
c
      endif
cgn      write(ulsort,90002) 'Fin etape 3.2. avec codret', codret
cgn      write (ulsort,90002) 'sdimca', sdimca
cgn      write (ulsort,90002) 'mdimca', mdimca
c
c 3.3. ==> premiere lecture : noms et dimensions
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMM1', nompro
#endif
      call eslmm1 ( idfmed, nomamd, lnomam,
     >              titre,
     >              sdimca, mdimca,
     >               degre, mailet, homolo, nbmane,
     >              nbelem, nbmaae, nbmafe,
     >              nbmapo, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpent, nbpyra,
     >              nbfmed, ngrouc, nbgrm,
     >              nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >              nbnoto,
     >              ulsort, langue, codret )
c
      endif
cgn      write(ulsort,90002) 'Fin etape 3.3. avec codret', codret
cgn      write (ulsort,90002) 'degre ', degre
c
c====
c 4. allocation des tableaux
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. allocation ; codret', codret
#endif
c
c 4.1. ==> allocation de l'objet de tete
c          remarque : on suppose que le maillage est conforme
c                     c'est a la conversion qu'on fera le tri
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      jaux = 2
      if ( typcca.eq.16 ) then
        hierar = 1
      else
        hierar = 0
      endif
      maconf = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTACMA', nompro
#endif
      call utacma ( nocmai, iaux, typcca,
     >              sdimca, mdimca,
     >               degre, mailet, maconf, homolo, hierar,
     >              nbnoto, nctfno, nbelem, nbmane, jaux,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret )
c
      endif
c
c 4.2. ==> objets lies au maillage de calcul
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. ; codret', codret
#endif
c
c 4.2.1. ==> les informations generales
c            Remarque : elles sont regroupees par paquets de
c                       80 caracteres pour  gerer la conversion en
c                       pseudo-groupe dans hom.med
c            . paquet 1 : 1 : 'NomCo  '
c                         2/3, 4/5, 6/7 : nom coordonnees
c                         8 : nom du repere utilise
c            . paquet 2 : 1 : 'UniteCo '
c                         2/3, 4/5, 6/7 : unite coordonnees
c            . paquet 3 : titre (limite a 80 caracteres)
c            . paquet 4 : 1 : 'NOMAMD  '
c                         2-7 : nom du maillage
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      nbpqt = 4
      call gmecat ( ncinfo, 1, nbpqt+1, codre1 )
      call gmaloj ( ncinfo//'.Pointeur', ' ', nbpqt+1, pinfpt, codre3 )
      call gmecat ( ncinfo, 2, 10*nbpqt, codre2 )
      call gmaloj ( ncinfo//'.Taille'  , ' ', 10*nbpqt, pinftl, codre4 )
      call gmaloj ( ncinfo//'.Table'   , ' ', 10*nbpqt, pinftb, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
      endif
c
c 4.2.2. ==> les noeuds
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2.2. noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( option.eq.1 ) then
        call gmaloj ( ncnoeu//'.NumeExte', ' ', nbnoto, pnunoe, codre1 )
        call gmaloj ( ncnoeu//'.FamilMED', ' ', nbnoto, pfamen, codre2 )
        iaux = 11
        call gmaloj ( ncnoeu//'.CoorCons', ' ', iaux  , adcocs, codre3 )
        iaux = nbnoto * nctfno
        call gmaloj ( nccoex//'.Noeud'   , ' ', iaux  , pcexno, codre4 )
      else
        codre1 = 0
        codre2 = 0
        codre3 = 0
        codre4 = 0
      endif
      iaux = nbnoto*sdimca
      call gmaloj ( ncnoeu//'.Coor'    , ' ', iaux  , pcoonc, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
c 4.2.3. ==> les elements
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2.3. elements ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( nccono//'.NumeExte', ' ', nbelem, pnuele, codre1 )
      call gmaloj ( nccono//'.FamilMED' , ' ', nbelem, pfamee, codre2 )
      call gmaloj ( nccono//'.Type', ' ',     nbelem, ptypel, codre3 )
      iaux = nbelem*nbmane
      call gmaloj ( nccono//'.Noeuds'  , ' ', iaux  , pnoeel, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
      endif
c
c 4.2.4. ==> les familles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2.4. familles ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      call gmecat ( ncfami, 1, nbfmed, codre1 )
      call gmecat ( ncfami, 2, ngrouc, codre2 )
      call gmaloj ( ncfami//'.Numero', ' ', nbfmed , pnumfa, codre3 )
      iaux = 10*nbfmed
      call gmaloj ( ncfami//'.Nom', ' ', iaux , pnomfa, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      call gmaloj ( ncfami//'.Groupe',  ' ', 0, iaux, codre1 )
      call gmaloj ( ncfami//'.Groupe.Pointeur', ' ',
     >              nbfmed+1, pgrpo, codre2 )
      iaux = 10*ngrouc
      call gmaloj ( ncfami//'.Groupe.Taille', ' ',
     >              iaux, pgrtai, codre3 )
      call gmaloj ( ncfami//'.Groupe.Table', ' ',
     >              iaux, pgrtab, codre4 )
      call gmecat ( ncfami//'.Groupe', 1, nbfmed, codre5 )
      call gmecat ( ncfami//'.Groupe', 2, ngrouc*10, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
      endif
c
      endif
c
c 4.2.5. ==> les equivalences
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2.5. equivalences ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      nbeqte = 0
      nbeqhe = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTACME', nompro
#endif
      call utacme ( ncequi,
     >              nbequi,
     >              nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >              nbeqte, nbeqhe,
     >              adeqpo, adeqin,
     >              adeqno, adeqmp, adeqar, adeqtr, adeqqu,
     >              adeqte, adeqhe,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ncequi )
      call gmprsx (nompro, ncequi//'.Pointeur' )
      call gmprsx (nompro, ncequi//'.InfoGene' )
#endif
c
      endif
c
      endif
c
c 4.3. ==> tableaux de travail
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.3. tableaux de travail ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      if ( sdimca.eq.1 ) then
        iaux = nbelem*nbmane
      elseif ( sdimca.eq.2 ) then
        iaux = nbelem*nbmane + nbsegm
      else
        iaux = nbelem*nbmane + nbsegm + nbtria
      endif
      call gmalot ( ntrav1, 'entier  ', iaux, ptrav1, codret )
c
      endif
c
      endif
cgn      write(ulsort,90002) 'Fin etape 4 avec codret', codret
c
c====
c 5. remplissage des tableaux
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. remplissage tableaux ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMM2', nompro
#endif
      call eslmm2 ( idfmed, nomamd,
     >              option,
     >              titre,
     >              degre, mailet, sdimca, nbmane, nbelem,
     >              nbmapo, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpent, nbpyra,
     >              nbfmed, nbfmen, ngrouc,
     >              nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >              nbnoto, numano, numael,
     >              imem(pnunoe), imem(pfamen), rmem(pcoonc),
     >         imem(pnuele), imem(pfamee), imem(pnoeel), imem(ptypel),
     >              imem(pgrpo), imem(pgrtai), smem(pgrtab),
     >              nbpqt, imem(pinfpt), imem(pinftl), smem(pinftb),
     >              typrep, nomaxe, uniaxe,
     >              imem(pnumfa), smem(pnomfa),
     >              imem(adeqpo), smem(adeqin),
     >              imem(adeqno), imem(adeqmp), imem(adeqar),
     >              imem(adeqtr), imem(adeqqu),
     >              imem(ptrav1),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ncnoeu )
cgn      call gmprsx (nompro, ncnoeu//'.Coor' )
      call gmprsx (nompro, nccono )
cgn      call gmprsx (nompro, nccono//'.Type' )
cgn      call gmprsx (nompro, nccono//'.Noeuds' )
cgn      call gmprsx (nompro, nccono//'.FamilMED' )
#endif
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ncinfo )
      call gmprsx (nompro, ncinfo//'.Pointeur' )
      call gmprsx (nompro, ncinfo//'.Taille'   )
      call gmprsx (nompro, ncinfo//'.Table'    )
#endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ncequi )
      call gmprsx (nompro, ncequi//'.Pointeur' )
      call gmprsx (nompro, ncequi//'.InfoGene' )
      call gmprsx (nompro, ncequi//'.Noeud' )
      call gmprsx (nompro, ncequi//'.Point' )
      call gmprsx (nompro, ncequi//'.Arete' )
      call gmprsx (nompro, ncequi//'.Trian' )
      call gmprsx (nompro, ncequi//'.Quadr' )
#endif
c
      endif
c
c===
c 6. les nombres
c===
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. les nombres ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      call gmecat ( ncfami, 3, nbfmen, codre1 )
      call gmadoj ( ncnomb, adnomb, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      imem(adnomb)    = nbmaae
      imem(adnomb+1)  = nbmafe
      imem(adnomb+2)  = -1
      imem(adnomb+3)  = numano
      imem(adnomb+4)  = numael
      imem(adnomb+5)  = nbtria + nbquad
      imem(adnomb+6)  = nbtetr + nbhexa + nbpent + nbpyra
      imem(adnomb+11) = nbmapo
      imem(adnomb+12) = nbsegm
      imem(adnomb+13) = nbtria
      imem(adnomb+14) = nbtetr
      imem(adnomb+15) = -1
      imem(adnomb+16) = nbquad
      imem(adnomb+17) = nbhexa
      imem(adnomb+18) = nbpent
      imem(adnomb+19) = nbpyra
      imem(adnomb+21) = nbfmed
      imem(adnomb+22) = nbfmen
      imem(adnomb+23) = ngrouc
      imem(adnomb+30) = nbequi
      imem(adnomb+31) = nbeqno
      imem(adnomb+32) = nbeqmp
      imem(adnomb+33) = nbeqar
      imem(adnomb+34) = nbeqtr
      imem(adnomb+35) = nbeqqu
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ncnomb )
#endif
c
      endif
c
      endif
c
c===
c 7. nettoyage
c===
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. nettoyage ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codret )
c
      endif
c
      endif
c
c===
c 8. fermeture du fichier
c===
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. fermeture du fichier ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFICLO', nompro
#endif
      call mficlo ( idfmed, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,8)) nomfic(1:lnomfi)
        write (ulsort,texte(langue,10))
      endif
c
      endif
c
c====
c 9. Reperage des coordonnes extremes et controle
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. Reperage ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
c 9.1. ==> calcul
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMMC1', nompro
#endif
      call utmmc1 ( sdimca, nbnoto,
     >              rmem(pcoonc), rmem(adcocs), iaux, ncnoeu,
     >              ulsort, langue, codret )
c
      endif
c
c 9.2. ==> iaux est la dimension reelle du probleme
c
      if ( codret.eq.0 ) then
c
      if ( iaux.lt.2 ) then
        if ( nbtria.gt.0 .or. nbquad.gt.0 .or.
     >       nbtetr.gt.0 .or. nbhexa.gt.0 .or.
     >       nbpyra.gt.0 .or. nbpent.gt.0 ) then
           codret = 2
        endif
      else if ( iaux.lt.3 ) then
        if ( nbtetr.gt.0 .or. nbhexa.gt.0 .or.
     >       nbpyra.gt.0 .or. nbpent.gt.0 ) then
           codret = 2
        endif
      endif
      if ( codret.eq.2 ) then
        write (ulsort,texte(langue,99))
      endif
c
      endif
c
      endif
c
c====
c 10. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. la fin ; codret', codret
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      if ( codret.ne.-10 ) then
        write (ulsort,texte(langue,8)) nomfic
        if ( codret.ne.-20 ) then
          write (ulsort,texte(langue,22)) nomamd
        endif
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
