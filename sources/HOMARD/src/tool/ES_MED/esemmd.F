      subroutine esemmd ( nocmai, mcfima, mcnoma, typouv,
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
c  Entree-Sortie - Ecriture d'un Maillage au format MeD
c  -      -        -             -                  - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocmai . e   . char*8 . nom de l'objet maillage calcul             .
c . mcfima . e   . char*8 . mot-cle pour le fichier du maillage        .
c . mcnoma . e   . char*8 . mot-cle du nom du maillage dans le fichier .
c . typouv . e   .   1    . type d'ouverture du fichier a ecrire       .
c .        .     .        . 0 : ecrasement                             .
c .        .     .        . 1 : enrichissement                         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . en entree = celui du module d'avant        .
c .        .     .        . en sortie = celui du module en cours       .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'ESEMMD' )
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
#include "nbutil.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer typouv
c
      character*8 nocmai, mcfima, mcnoma
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer adnomb
      integer pfamen, pcoonc, pfamee, pnoeel, ptypel
      integer pgrpo, pgrtab
      integer pnumfa, pnomfa
      integer nbpqt
      integer pinftb
      integer adeqpo, adeqin
      integer adeqno, adeqar, adeqtr, adeqqu
      integer adeqte, adeqhe
      integer ptrav1, ptrav2
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6
      integer codre0
c
      integer*8 idfmed
      integer lnomfi, lnomam
      integer nbnomb
      integer nbnoto
c
      character*8 typobs
      character*8 ntrav1, ntrav2
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
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
c
c====
c 2. premiers decodages
c====
c
c 2.1. ==> nom du fichier contenant le maillage
c
      typobs = mcfima
      iaux = 0
      jaux = 1
      call utfino ( typobs, iaux, nomfic, lnomfi,
     >              jaux,
     >              ulsort, langue, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,8)) 'en sortie'
        codret = -10
      endif
c
c 2.2. ==> nom du maillage dans le fichier
c
      if ( codret.eq.0 ) then
      typobs = mcnoma
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
c
c====
c 3. ouverture en mode d'ecrasement ou d'enrichissement
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. ouverture ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( typouv.eq.0 ) then
        iaux = edcrea
      else
        iaux = edrdwr
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFIOPE', nompro
#endif
      call mfiope ( idfmed, nomfic(1:lnomfi), iaux, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,9))
      endif
      endif
c
c====
c 4. recuperation des donnees du maillage de calcul
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. recuperation ; codret', codret
#endif
c
c 4.1. ==> l'objet de tete
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nocmai )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMC', nompro
#endif
      call utnomc ( nocmai,
     >              sdimca, mdimca,
     >               degre, mailet, maconf, homolo, hierar,
     >              nbnomb,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'sdimca', sdimca
      write (ulsort,90002) 'mdimca', mdimca
      call gmprsx (nompro, ncnoeu )
      call gmprsx (nompro, nccono )
      call gmprsx (nompro, ncfami )
      call gmprsx (nompro,ncfami//'.Nom')
      call gmprsx (nompro,ncfami//'.Groupe')
#endif
c
      endif
c
c 4.2. ==> objets lies au maillage de calcul
c
c 4.2.1. ==> les informations generales
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ncinfo//'.Table'   , pinftb, iaux, codre0 )
      call gmliat ( ncinfo, 1, iaux, codre2 )
      nbpqt = iaux - 1
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 4.2.2. ==> les nombres
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ncnomb, adnomb, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNBMC', nompro
#endif
      call utnbmc ( imem(adnomb),
     >              nbmaae, nbmafe, nbmnei,
     >              numano, numael,
     >              nbma2d, nbma3d,
     >              nbmapo, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpent, nbpyra,
     >              nbfmed, nbfmen, ngrouc,
     >              nbequi,
     >              nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >              ulsort, langue, codret )
c
      endif
c
c 4.2.3. ==> les nombres
c
      if ( codret.eq.0 ) then
c
      call gmliat ( ncnoeu, 1, nbnoto, codre1 )
      call gmliat ( nccono, 1, nbelem, codre2 )
      call gmliat ( nccono, 2, nbmane, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
c 4.2.4. ==> les adresses
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD11', nompro
#endif
      iaux = 6006
      call utad11 ( iaux, ncnoeu, nccono,
     >              pcoonc, pfamen,   jaux,  jaux,
     >              ptypel, pfamee, pnoeel,  jaux,
     >              ulsort, langue, codret )
c
c 4.2.5. ==> les familles
c
      pnumfa = 1
      pnomfa = 1
      pgrpo = 1
      pgrtab = 1
c
      if ( nbfmed.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD13', nompro
#endif
        iaux = 6
        if ( ngrouc.gt.0 ) then
          iaux = iaux*5
        endif
        call utad13 ( iaux, ncfami,
     >                pnumfa, pnomfa,
     >                pgrpo,   jaux, pgrtab,
     >                ulsort, langue, codret )
c
      endif
cgn        call gmprsx (nompro, ncfami//'.Groupe')
cgn        call gmprsx (nompro, ncfami//'.Groupe.Pointeur')
cgn        call gmprsx (nompro, ncfami//'.Groupe.Taille')
cgn        call gmprsx (nompro, ncfami//'.Groupe.Table')
c
c 4.2.6. ==> les equivalences
c
      if ( nbequi.ne.0 ) then
c
      call gmadoj ( ncequi//'.Pointeur', adeqpo, iaux, codre1 )
      call gmadoj ( ncequi//'.InfoGene', adeqin, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      call gmadoj ( ncequi//'.Noeud', adeqno, iaux, codre1 )
      call gmadoj ( ncequi//'.Arete', adeqar, iaux, codre2 )
      call gmadoj ( ncequi//'.Trian', adeqtr, iaux, codre3 )
      call gmadoj ( ncequi//'.Quadr', adeqqu, iaux, codre4 )
      call gmadoj ( ncequi//'.Tetra', adeqte, iaux, codre5 )
      call gmadoj ( ncequi//'.Hexae', adeqhe, iaux, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
      endif
c
c 4.2.7. ==> la frontiere
c
      endif
c
c 4.3. ==> tableaux de travail
c
      if ( codret.eq.0 ) then
c
      iaux = nbelem*(nbmane+1)+nbsegm+nbtria
      call gmalot ( ntrav1, 'entier  ', iaux   , ptrav1, codre1 )
      call gmalot ( ntrav2, 'entier  ', nbelem , ptrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
      endif
c
c===
c 5. ecriture proprement dite
c===
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. ecriture ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMM1', nompro
#endif
      call esemm1 ( idfmed, nomamd, lnomam,
     >         nbnoto,
     >         rmem(pcoonc), imem(pfamen), imem(pnoeel),
     >         imem(pfamee), imem(ptypel),
     >         imem(pnumfa), smem(pnomfa),
     >         imem(pgrpo), smem(pgrtab),
     >          nbpqt, smem(pinftb),
     >         imem(adeqpo), smem(adeqin),
     >         imem(adeqno),
     >         imem(adeqar), imem(adeqtr), imem(adeqqu),
     >         imem(adeqte), imem(adeqhe),
     >         imem(ptrav1), imem(ptrav2),
     >         ulsort, langue, codret )
c
      endif
c
c===
c 6. nettoyage
c===
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre1 )
      call gmlboj ( ntrav2 , codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c===
c 7. fermeture du fichier
c===
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFICLO', nompro
#endif
      call mficlo ( idfmed, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,10))
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
