      subroutine esesmd ( nosolu, nomfic, lnomfi,
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
c  Entree-Sortie - Ecriture d'une Solution au format MED
c  -      -        -              -                  - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nosolu . e   . char*8 . nom de l'objet solution a ecrire           .
c . nomfic . e   .char*200. nom du fichier ou ecrire la solution       .
c . lnomfi . e   .   1    . longueur du nom du fichier                 .
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
c .        .     .        . -1 : fichier inconnu                       .
c .        .     .        . -2 : nom de maillage inconnu               .
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
      parameter ( nompro = 'ESESMD' )
c
#include "nblang.h"
#include "consts.h"
c
#include "motcle.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer lnomfi
c
      character*8 nosolu
      character*200 nomfic
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer*8 idfmed
c
      integer nbcham, nbfonc, nbprof, nblopg
      integer adinch, adinpf, adinpr, adinlg
      integer lnomam
c
      character*8 typobs
      character*64 nomamd
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,5) = '(''Champ : '')'
c
      texte(2,5) = '(''Field : '')'
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nosolu )
cgn      call gmprsx (nompro, nosolu//'.InfoCham' )
cgn      call gmprsx (nompro, nosolu//'.InfoPaFo' )
cgn      call gmprsx (nompro, nosolu//'.InfoProf' )
      call gmprsx (nompro, nosolu//'.InfoLoPG' )
#endif
c
c====
c 2. determination des pointeurs associes aux tableaux
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCASO', nompro
#endif
      call utcaso ( nosolu,
     >              nbcham, nbfonc, nbprof, nblopg,
     >              adinch, adinpf, adinpr, adinlg,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx('1er champ :', smem(adinch))
      call gmprsx('1er champ Cham_Car :', smem(adinch)//'.Cham_Car')
      if ( nbcham.ge.2 ) then
      call gmprsx('2nd champ :', smem(adinch+1))
      call gmprsx('2nd champ Cham_Car :', smem(adinch+1)//'.Cham_Car')
      endif
#endif
c
c====
c 3. ecriture des valeurs, seulement s'il y en a ...
c====
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> nom du maillage de calcul
c
      if ( codret.eq.0 ) then
      typobs = mccnmp
      iaux = 0
      jaux = 0
      call utfino ( typobs, iaux, nomamd, lnomam,
     >                jaux,
     >              ulsort, langue, codret )
      if ( codret.ne.0 ) then
        call utosme ( typobs, ulsort, langue )
        if ( codret.eq.4 ) then
          write (ulsort,texte(langue,52)) lnomam
          write (ulsort,texte(langue,53)) len(nomamd)
          codret = -2
        endif
      endif
      endif
c
c 3.2. ==> ouverture en mode d'enrichissement
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'EFOUVR', nompro
#endif
      call mfiope ( idfmed, nomfic(1:lnomfi), edrdwr, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,9))
      endif
c
      endif
c
c 3.3. ==> ecriture veritable
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESESM1', nompro
#endif
      call esesm1 ( idfmed, nomamd,
     >              nbcham, smem(adinch), nbprof, smem(adinpr),
     >              nblopg, smem(adinlg),
     >              ulsort, langue, codret )
c
      endif
c
c 3.4. ==> fermeture du fichier
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
      endif
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
      if ( codret.ne.-1 ) then
        write (ulsort,texte(langue,8)) nomfic
      endif
      if ( codret.gt.0 ) then
        write (ulsort,texte(langue,22)) nomamd
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
