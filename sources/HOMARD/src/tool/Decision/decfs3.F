      subroutine decfs3 ( hettri, filtri,
     >                    hetqua, filqua,
     >                    hettet, filtet,
     >                    hethex, filhex,
     >                    hetpen, filpen,
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
c traitement des DEcisions - mise en ConFormite - Suppression
c                --                  -  -         -
c                            des fils
c ______________________________________________________________________
c On parcourt toutes les entites qui sont decoupees par conformite :
c . on supprime la reference aux fils
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . filtri . e   . nbtrto . fils des triangles                         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . fils des hexaedres                         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon : nombre de tetraedres a problemes   .
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
      parameter ( nompro = 'DECFS3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer hettri(nbtrto), filtri(nbtrto)
      integer hetqua(nbquto), filqua(nbquto)
      integer hettet(nbteto), filtet(nbteto)
      integer hethex(nbheto), filhex(nbheto)
      integer hetpen(nbpeto), filpen(nbpeto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer etat
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
c
      texte(1,4) =
     > '(''Suppression des fils de conformites pour les '',a)'
c
      texte(2,4) =
     > '(''Suppression of the sons for the conformities for '',a)'
c
      codret = 0
c
c====
c 2. les triangles
c====
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,2)
#endif
c
cgn 1793 format('Etat du ',a,i10,' :',i4)
      do 22 , iaux = 1 , nbtrto
c
        etat = mod(hettri(iaux),10)
c
        if ( etat.ge.1 .and. etat.le.3 ) then
cgn      write (ulsort,1793) mess14(langue,1,2), iaux, etat
c
          filtri(iaux) = 0
c
        endif
c
   22 continue
c
      endif
c
c====
c 3. les quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Quadrangles ; codret = ', codret
#endif
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,4)
#endif
c
      do 32 , iaux = 1 , nbquto
c
        etat = mod(hetqua(iaux),100)
c
        if ( etat.eq.21 .or. etat.eq.22 .or.
     >       ( etat.ge.31 .and. etat.le.34 ) .or.
     >       ( etat.ge.41 .and. etat.le.44 ) ) then
cgn      write (ulsort,1793) mess14(langue,1,4), iaux, etat
c
          filqua(iaux) = 0
c
        endif
c
   32 continue
c
      endif
c
c====
c 4. les tetraedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Tetraedres ; codret = ', codret
#endif
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,3)
#endif
c
      do 42 , iaux = 1 , nbteto
c
        etat = mod(hettet(iaux),100)
c
        if ( ( etat.ge.21 .and. etat.le.36 ) .or.
     >       ( etat.ge.41 .and. etat.le.47 ) ) then
c
          filtet(iaux) = 0
c
        endif
c
   42 continue
c
cgn      write (ulsort,1790) (iaux,teindr(iaux),iaux = 1 , nbteto)
cgn 1790 format(5(i4,' :',g12.5))
      endif
c
c====
c 5. les hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Hexaedres ; codret = ', codret
#endif
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,6)
#endif
c
      do 52 , iaux = 1 , nbheto
c
        etat = mod(hethex(iaux),1000)
c
        if ( etat.ge.11 ) then
c
          filhex(iaux) = 0
c
        endif
c
   52 continue
c
      endif
c
c====
c 6. les pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. Pentaedres ; codret = ', codret
#endif
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,7)
#endif
c
      do 62 , iaux = 1 , nbpeto
c
        etat = mod(hetpen(iaux),100)
c
        if ( ( etat.ge. 1 .and. etat.le. 6 ) .or.
     >       ( etat.ge.17 .and. etat.le.19 ) .or.
     >       ( etat.ge.21 .and. etat.le.26 ) .or.
     >       ( etat.ge.31 .and. etat.le.36 ) .or.
     >       ( etat.ge.43 .and. etat.le.45 ) .or.
     >       ( etat.ge.51 .and. etat.le.52 ) ) then
c
          filpen(iaux) = 0
c
        endif
c
   62 continue
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
      write (ulsort,texte(langue,6)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
