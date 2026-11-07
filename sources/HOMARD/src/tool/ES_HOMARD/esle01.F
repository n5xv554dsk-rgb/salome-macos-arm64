      subroutine esle01 ( idfmed, nomamd, nomcha,
     >                    nbcomp, nomcmp, unicmp,
     >                    optio1, optio2,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : LEcture noeud-maille - 01
c  -      -        --                     --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . nomcha . e   . char64 . nom du champ MED voulu                     .
c . nbcomp .  s  .   1    . nombre de composantes du champ             .
c . nomcmp .  s  .   *    . nom des composantes du champ               .
c . unicmp .  s  .   *    . unite des composantes du champ             .
c . optio1 . e   .   *    . 0 : erreur si le champ n'est pas trouve    .
c .        .     .        . 1 : pas de probleme                        .
c . optio2 .  s  .   1    . 0 ou 1 selon la presence du champ          .
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
      parameter ( nompro = 'ESLE01' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer optio1, optio2
      integer nbcomp
c
      character*16 nomcmp(*), unicmp(*)
      character*64 nomamd
      character*64 nomcha
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer nbchfi, nrocha
      integer typcha
      integer nbseq
c
      character*16 dtunit
      character*64 nomch0
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,''Lecture du champ : '',a64)'
      texte(1,5) = '(''Type du champ : '',i2)'
      texte(1,6) =
     > '(''Numero !     Composante     !       Unite'',/,49(''-''))'
      texte(1,7) = '(i6,'' !  '',a16,''  !  '',a16)'
c
      texte(2,4) = '(/,''Readings of field: '',a64)'
      texte(2,5) = '(''Type of field: '',i2)'
      texte(2,6) =
     > '(''  #    !     Component      !       Unit'',/,49(''-''))'
      texte(2,7) = '(i6,'' !  '',a16,''  !  '',a16)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomcha
#endif
c
#include "esimpr.h"
c
c 1.2. ==> champ absent a priori
c
      optio2 = 0
c
c====
c 2. Lectures
c====
c 2.1. ==> nombre de champs dans le fichier
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDNFD', nompro
#endif
      call mfdnfd ( idfmed, nbchfi, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbchfi', nbchfi
#endif
c
      endif
c
      do 20 , nrocha = 1 , nbchfi
c
c 2.2. ==> nombre de composantes du champ courant
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDNFC', nompro
#endif
        iaux = nrocha
        call mfdnfc ( idfmed, iaux, nbcomp, codret )
c
        endif
c
c 2.3. ==> lecture du nom du champ, des noms et des unites
c          de ses composantes
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDFDI', nompro
#endif
c
        nomch0 = blan64
        iaux = nrocha
        jaux = edtrue
        call mfdfdi ( idfmed, iaux, nomch0, nomamd, jaux,
     >                typcha, nomcmp, unicmp,
     >                dtunit, nbseq, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,93020) 'caracteristiques du champ', nomch0
      write (ulsort,texte(langue,5)) typcha
      write (ulsort,texte(langue,6))
      do 231 , iaux = 1 , nbcomp
        write (ulsort,texte(langue,7)) iaux, nomcmp(iaux), unicmp(iaux)
  231 continue
        endif
#endif
c
        endif
c
c 2.4. ==> Si c'est le bon, on sort
c
        if ( codret.eq.0 ) then
c
        if ( nomch0.eq.nomcha ) then
c
          if ( typcha.ne.edint ) then
            codret = 231
          endif
          if ( nbseq.ne.1 ) then
            write (ulsort,90002) 'nbseq ', nbseq
            codret = 232
            goto 30
          endif
c
          optio2 = 1
          goto 40
c
        endif
c
        endif
c
   20 continue
c
c====
c 2.5. ==> Impossible de trouver le bon champ
c====
c
   30 continue
c
      if ( optio1.eq.0 ) then
c
        write (ulsort,texte(langue,32)) nomcha
        write (ulsort,texte(langue,92))
        write (ulsort,90002) 'Nombre de champs presents', nbchfi
        do 301 , nrocha = 1 , nbchfi
          iaux = nrocha
          call mfdnfc ( idfmed, iaux, nbcomp, codret )
          nomch0 = blan64
          jaux = edtrue
          call mfdfdi ( idfmed, iaux, nomch0, nomamd, jaux,
     >                  typcha, nomcmp, unicmp,
     >                  dtunit, nbseq, codret )
        write (ulsort,texte(langue,32)) nomch0
        write (ulsort,texte(langue,5)) typcha
  301   continue
        codret = 1
c
      endif
c
c====
c 4. la fin
c====
c
   40 continue
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
