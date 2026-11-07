      subroutine utosno ( typobs, nomobs,
     >                    optimp,
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
c  but : renvoyer le nom terminal de l'objet structure correspondant
c        au un objet de nom symbolique donne
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typobs . e   .  ch8   . nom symbolique de l'objet                  .
c . nomobs .  s  .  ch8   . nom unix de l'objet associe                .
c . optimp . e   .    1   . 0 : pas d'affichage de message             .
c .        .     .        . 1 : affichage de message d'erreur          .
c . ulsort . e   .    1   . unite logique d'impression                 .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : pas de nom dans la base                .
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
      parameter ( nompro = 'UTOSNO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      character*8 typobs
      character*8 nomobs
c
      integer optimp
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "utliob.h"
c
      integer iaux
      integer adnore, adnoos
      integer nbfich
c
      character*8 nomaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1.  messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) = '(''Objet '',a,'' : recuperation impossible.'')'
      texte(1,4) = '(''Objet '',a,'' : nom terminal introuvable.'')'
c
      texte(2,10) = '(''Object '',a,'': recovery is impossible.'')'
      texte(2,4) = '(''Object '',a,'': final name is missing.'')'
c
c====
c 2. recherche des adresses des objets GM lies aux noms des objets
c====
c
      nomaux = osliob
c
      call gmliat ( nomaux, 1, nbfich, codret )
c
      call gmadoj ( nomaux//'.NomRefer', adnore, iaux, codret)
c
      call gmadoj ( nomaux//'.NomObjSt', adnoos, iaux, codret)
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,10)) nomaux
        codret = 2
      endif
c
c====
c 3. recherche du nom de l'objet
c====
c
      if ( codret.eq.0 ) then
c
        do 31 , iaux = 1 , nbfich
#ifdef _DEBUG_HOMARD_
          nomaux = smem(adnore+iaux-1)
#endif
          if ( smem(adnore+iaux-1).eq.typobs ) then
            nomobs = smem(adnoos+iaux-1)
            goto 32
          endif
   31   continue
c
        codret = 2
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,1)) 'Sortie', nompro
#else
        if ( optimp.gt.0 ) then
#endif
        write (ulsort,texte(langue,4)) typobs
#ifdef _DEBUG_HOMARD_
c
#else
        endif
#endif
c
   32   continue
c
      endif
c
      end
