      subroutine eslee1 ( typenh, nbencf, nbenca, nbrfma, nbrama,
     >                    codeen, coaren, tbiaux,
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
c  Entree-Sortie : LEcture d'une Entite - 1
c  -      -        --            -        -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites                           .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nbencf . e   .   1    . nombre d'entites decrites par faces        .
c . nbenca . e   .   1    . nombre d'entites decrites par aretes       .
c . nbrfma . e   .   1    . nbre faces par maille si connectivite desce.
c . nbrama . e   .   1    . nbre aretes par maille si volume           .
c . codeen .  s  .nbencf**. connectivite descendante des mailles       .
c . coaren .  s  .nbenca**. connectivite des mailles par aretes        .
c . tbiaux . e   .    *   . tableau tampon entier                      .
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
      parameter ( nompro = 'ESLEE1' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "fahmed.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh
      integer nbencf, nbenca, nbrfma, nbrama
      integer codeen(nbencf,nbrfma), coaren(nbenca,nbrama)
      integer tbiaux(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux, kaux,laux
c
      integer nbmess
      parameter ( nbmess = 100 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''... Connectivite pour les '',i10,1x,a)'
c
      texte(2,4) = '(''... Connectivity for the '',i10,1x,a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbencf, mess14(langue,3,typenh)
#endif
c
c====
c 2. Mise en place de la connectivite descendante
c====
c
      if ( codret.eq.0 ) then
c
      kaux = 0
c
      do 21 , iaux = 1, nbencf
        do 211, jaux = 1, nbrfma
          laux = nofmed(typenh,jaux,1)
cgn               write(ulsort,*) jaux,laux
          kaux = kaux + 1
          codeen(iaux,laux) = abs(tbiaux(kaux))
  211   continue
   21 continue
c
      endif
c
c====
c 3. Mise en place de l'eventuelle connectivite par arete
c    En coherence avec l'ecriture par esece2
c====
c
      if ( nbenca.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        do 31 , iaux = 1, nbenca
          do 311, jaux = 1, nbrfma
            kaux = kaux + 1
            coaren(iaux,jaux) = tbiaux(kaux)
  311     continue
   31   continue
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
