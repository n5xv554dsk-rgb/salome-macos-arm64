      subroutine deini3 ( nohind,
     >                    nbvtri, nbvqua,
     >                    nbvtet, nbvhex, nbvpyr, nbvpen,
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
c traitement des DEcisions - INITialisations - phase 3
c                --          ---                     -
c ______________________________________________________________________
c  Suppressions de structures apres suppression de la conformite :
c  on supprime la branche d'une entite s'il n'y en a plus (nbento=0) et
c  s'il y avait un indicateur auparavant (nbvent>0)
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nohind . e   .  ch8   . nom de l'objet contenant l'indicateur      .
c . nbvent . es  .   1    . nombre de valeurs pour l'entite            .
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
      parameter ( nompro = 'DEINI3' )
c
#include "nblang.h"
#include "impr02.h"
c
c 0.2. ==> communs
c
#include "enti01.h"
#include "envex1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      character*8 nohind
c
      integer nbvtri, nbvqua
      integer nbvtet, nbvhex, nbvpyr, nbvpen
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
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
      texte(1,4) = '(''. Suppression de la branche sur les '',a)'
c
      texte(2,4) = '(''. Suppression of branch for '',a)'
c
c====
c 2. Par type de mailles
c====
c
      do 21 , iaux = 2, 7
c
        if ( codret.eq.0 ) then
c
        if ( iaux.eq.2 ) then
          jaux = nbvtri
          kaux = nbtrto
        elseif ( iaux.eq.3 ) then
          jaux = nbvtet
          kaux = nbteto
        elseif ( iaux.eq.4 ) then
          jaux = nbvqua
          kaux = nbquto
        elseif ( iaux.eq.5 ) then
          jaux = nbvpyr
          kaux = nbpyto
        elseif ( iaux.eq.6 ) then
          jaux = nbvhex
          kaux = nbheto
        else
          jaux = nbvpen
          kaux = nbpeto
        endif
c
        if ( jaux.ne.0 .and. kaux.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,4)) mess14(langue,3,iaux)
#endif
          call gmsgoj ( nohind//'.'//suffix(1,iaux)(1:5) , codret )
c
          if ( codret.eq.0 ) then
c
            if ( iaux.eq.2 ) then
              nbvtri = 0
            elseif ( iaux.eq.3 ) then
              nbvtet = 0
            elseif ( iaux.eq.4 ) then
              nbvqua = 0
            elseif ( iaux.eq.5 ) then
              nbvpyr = 0
            elseif ( iaux.eq.6 ) then
              nbvhex = 0
            else
              nbvpen = 0
            endif
c
          else
c
            jaux = iaux
c
          endif
c
        endif
c
        endif
c
   21 continue
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4)) mess14(langue,3,jaux)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
