      subroutine utvar1 ( nbsomm, arsoen, listar, somare,
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
c    UTilitaire - Verification des ARetes - 1
c    --           -                --       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbsomm . e   .   1    . nombre de sommets de l'entite              .
c . arsoen . e   .nbsomm**. numero des aretes liees aux sommets        .
c . listar . e   . nbaret . liste des aretes a examiner                .
c . somare . e   . 2*nbar . numeros des extremites d'arete             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : pas assez d'arete dans la liste        .
c .        .     .        . 2 : mauvais type de verification           .
c .        .     .        . 10 : les aretes ne se suivent pas          .
c .        .     .        . 11 : la suite des aretes ne ferme pas      .
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
      parameter ( nompro = 'UTVAR1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbsomm
      integer arsoen(3,nbsomm)
      integer listar(*), somare(2,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer arete1, arete2, arete3
      integer s1
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      codret = 0
c
c====
c 2. verifications
c====
c
      do 21 , iaux = 1 , nbsomm
c
c       examen du iaux-eme sommet local
c
c       arsoen(k,iaux) : numero local de la keme arete sur ce sommet
c       aretek : numero global de la keme arete sur ce sommet
        arete1 = listar(arsoen(1,iaux))
        arete2 = listar(arsoen(2,iaux))
        arete3 = listar(arsoen(3,iaux))
c
        kaux = 0
c
        do 211 , jaux = 1 , 2
c
c         s1 : numero global de la jaux-eme extremite de la 1ere arete
          s1 = somare(jaux,arete1)
c
c         s1 est-il un des sommets de la 2-eme arete ?
          if ( s1.eq.somare(1,arete2) .or. s1.eq.somare(2,arete2) ) then
            kaux = kaux + 1
          endif
c
c         s1 est-il un des sommets de la 3-eme arete ?
          if ( s1.eq.somare(1,arete3) .or. s1.eq.somare(2,arete3) ) then
            kaux = kaux + 1
          endif
c
  211   continue
c
c       Si ce sommet n'est pas une extremite pour les 3 aretes, kaux
c       est different de 2 : probleme.
        if ( kaux.ne.2 ) then
          write (ulsort,90002) 'Probleme avec le sommet local numero',
     > iaux
          write (ulsort,90006) '... arete 1 =', arete1,
     >    'de', somare(1,arete1), ' a', somare(2,arete1)
          write (ulsort,90006) '... arete 2 =', arete2,
     >    'de', somare(1,arete2), ' a', somare(2,arete2)
          write (ulsort,90006) '... arete 3 =', arete3,
     >    'de', somare(1,arete3), ' a', somare(2,arete3)
          codret = 12
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
