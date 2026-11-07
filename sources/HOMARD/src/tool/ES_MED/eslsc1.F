      subroutine eslsc1 ( nomfic, lnomfi,
     >                    messin,
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
c  Entree-Sortie - Lecture d'une Solution - Champs presents - phase 1
c  -      -        -             -          -                       -
c  Affichage des noms des champs contenus dans le fichier
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomfic . e   . char*  . nom du fichier                             .
c . lnomfi . e   .    1   . longueur du nom du fichier                 .
c . messin . e   .   1    . message d'informations                     .
c .        .     .        . impressions MED si multiple de 3           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'ESLSC1' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
#include "litme0.h"
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
      character*200 nomfic
c
      integer messin
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer*8 idfmed
      integer typcha
      integer iaux
      integer adnocp
      integer nbchfi, nrocha, nbcomp
      integer lmesh, nbsqch
      integer nbtvch, numdtx
c
      character*8 ntrav1
      character*16 dtunit
      character*64 nomcha
      character*64 saux64
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
      texte(1,7) =
     > '(/,''Description des'',i6,'' champs presents dans le fichier'')'
c
      texte(2,7) =
     > '(/,''Description of the'',i6,'' field in this file'')'
c
 1000 format (53('-'))
c
#include "esimpr.h"
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. prealables
c====
c
#include "litmed.h"
c
c 2.1. ==> ouverture du fichier MED
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
c 2.2. ==> nombre de champs dans le fichier
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDNFD', nompro
#endif
      call mfdnfd ( idfmed, nbchfi, codret )
c
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,7)) nbchfi
      write (ulsort,*) nomfic(1:lnomfi)
      endif
c
      endif
c
c====
c 3. caracterisation des champs
c====
c
      if ( codret.eq.0 ) then
c
      do 30 , nrocha = 1 , nbchfi
c
        write (ulsort,1000)
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,*) ' '
        write (ulsort,90002) 'Champ numero', nrocha
        endif
#endif
c
c 3.1. ==> nombre de composantes du champ courant
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
c 3.2. ==> allocation des tableaux decrivant le champ et ses composantes
c         remarque : ce dimensionnement suppose que :
c                    1. le nom des composantes se code sur 16 caracteres
c                    2. le nom des unites des composantes se code sur 16
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'Nombre de composantes', nbcomp
#endif
        iaux = 4*nbcomp
        call gmalot ( ntrav1, 'chaine  ', iaux, adnocp, codret )
c
        endif
c
c 3.3. ==> lecture du nom du champ, des noms et des unites
c          de ses composantes
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDFDI', nompro
#endif
        nomcha = blan64
        iaux = nrocha
        call mfdfdi ( idfmed, iaux,
     >                nomcha, saux64, lmesh, typcha,
     >                smem(adnocp), smem(adnocp+2*nbcomp),
     >                dtunit, nbsqch, codret )
c
        endif
c
c 3.4. ==> Affichage
c
        if ( codret.eq.0 ) then
        call utlgut ( iaux, saux64, ulsort, langue, codret )
        endif
        if ( codret.eq.0 ) then
        write (ulsort,texte(langue,96)) saux64(1:iaux)
        endif
c
        if ( codret.eq.0 ) then
        call utlgut ( iaux, nomcha, ulsort, langue, codret )
        endif
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,32)) nomcha(1:iaux)
        do 34 , iaux = 1 , nbcomp
          write (ulsort,texte(langue,54))
     >           smem(adnocp+2*iaux-2)//smem(adnocp+2*iaux-1)
   34   continue
c
        endif
c
c
c 3.5. ==> Menage
c
        if ( codret.eq.0 ) then
c
        call gmlboj ( ntrav1, codret )
c
        endif
c
c 3.6. ==> On parcourt toutes les sequences et tous les types de support
c
        if ( codret.eq.0 ) then
c
        iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLCH1', nompro
#endif
        call eslch1 ( idfmed, nomcha, nbsqch,
     >                nbtmed, litmed,
     >                iaux,
     >                nbtvch, numdtx,
     >                ulsort, langue, codret )
c
        endif
c
   30 continue
c
      write (ulsort,1000)
c
      endif
c
c====
c 4. fermeture du fichier
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*)'Avant 4, codret = ',codret
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
c====
c 5. la fin
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

