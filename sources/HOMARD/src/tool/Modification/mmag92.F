      subroutine mmag92 ( larete, ordre, nujois,
     >                    nbduar, tbau40,
     >                    arejoi, quajoi,
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
c    Modification de Maillage - AGRegat - phase 9.2
c    -               -          --              - -
c    Reperage des aretes liees aux joints simples formant
c    le joint multiple
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . larete . e   .   1    . arete support du joint multiple            .
c . ordre  . e   .   1    . ordre du joint a explorer                  .
c . nujois . e   . ordre  . numeros des joints simples associes        .
c . nbduar . e   .   1    . nombre de duplications d'aretes            .
c . tbau40 . e   .6*nbduar. Pour la i-eme duplication d'arete :        .
c .        .     .        . (1,i) : arete a dupliquer                  .
c .        .     .        . (2,i) : arete creee cote min(fammed)       .
c .        .     .        . (3,i) : arete creee cote max(fammed)       .
c .        .     .        . (4,i) : numero du joint simple cree        .
c .        .     .        . (5,i) : ordre de multiplicite              .
c .        .     .        . (6,i) : arete d'orientation de joint       .
c . arejoi .  s  . ordre  . aretes bordant le i-eme joint              .
c . quajoi .  s  . ordre  . quadrangles bordant le i-eme joint         .
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
      parameter ( nompro = 'MMAG92' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer larete
      integer ordre, nujois(ordre)
      integer nbduar, tbau40(6,nbduar)
      integer arejoi(ordre), quajoi(ordre)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nbqulo
c
      integer nbmess
      parameter ( nbmess = 40 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
#include "impr03.h"
#include "mmag01.h"
#include "mmag02.h"
c
      codret = 0
c
c====
c 2. On explore toutes les aretes qui ont ete dupliquees
c    On est bon quand :
c    . l'arete dupliquee est l'arete multiple
c    On stocke le quadrangle construit sur l'arete en cours
c    dedoublee ; attention a les mettre dans l'ordre des joints
c    On rappelle que les quadrangles sont numerotes en suivant le
c    dedoublement des aretes (cf. mmag31).
c====
c
      nbqulo = 0
c
      do 21 , iaux = 1 , nbduar
c
        if ( tbau40(1,iaux).eq.larete ) then
c
          do 211 , jaux = 1 , ordre
            if ( nujois(jaux).eq.tbau40(4,iaux) ) then
              nbqulo = nbqulo + 1
              quajoi(jaux) = iaux
              arejoi(jaux) = tbau40(6,iaux)
              if ( nbqulo.eq.ordre ) then
                goto 210
              endif
            endif
  211     continue
c
        endif
c
   21 continue
c
c     Si on arrive ici, c'est que les quadrangles n'ont pas ete trouves
c
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
      write (ulsort,texte(langue,38)) mess14(langue,3,1)
      codret = 21
c
  210 continue
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
