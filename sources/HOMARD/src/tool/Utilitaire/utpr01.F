      subroutine utpr01 ( option, decala,
     >                    nbento, profil, nensca,
     >                    nbvapr, obprof,
     >                    nbprof, liprof,
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
c    UTilitaire - PRofil - operation 01
c    --           --                 --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . 1 : on traite la liste brutalement         .
c .        .     .        . 2 : on doit utiliser une renumerotation    .
c . decala . e   .   1    . decalage eventuel dans la numerotation     .
c .        .     .        . (cf. pcmac1), 0 si pas de decalage         .
c . nbento . e   .   1    . nombre total d'entites                     .
c . profil . e   . nbento . pour chaque entite :                       .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . nensca . e   .   *    . numero des entites dans le calcul          .
c .        .     .        . utile si et seulement si option=2          .
c . nbvapr .   s .   1    . nombre de valeurs du profil en sortie      .
c .        .     .        . -1, si pas de profil                       .
c . obprof .   s . char*8 . nom de l'objet de type 'Profil' equivalent .
c . nbprof . es  .   1    . nombre de profils enregistres              .
c . liprof . es  . char*8 . nom des objet de type 'Profil' enregistres .
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
      parameter ( nompro = 'UTPR01' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer option, decala
      integer nbento, nbvapr, nbprof
      integer profil(nbento)
      integer nensca(nbento)
c
      character*8 obprof
      character*8 liprof(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de profils connus : '',i8)'
      texte(1,5) = '(''Nombre d''''entites         : '',i10)'
      texte(1,6) = '(''Decalage                 : '',i10)'
      texte(1,7) = '(''Objet profil retenu : '',a)'
c
      texte(2,4) = '(''Number of known profiles : '',i8)'
      texte(2,5) = '(''Number of entities       : '',i10)'
      texte(2,6) = '(''Shift                    : '',i10)'
      texte(2,7) = '(''Profil object which is kept : '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbprof
      write (ulsort,texte(langue,5)) nbento
      write (ulsort,texte(langue,6)) decala
#endif
c
c====
c 2. prise en compte d'un eventuel decalage
c====
c
      if ( decala.gt.0 ) then
c
        jaux = nbento - decala
        do 21 , iaux = 1 , jaux
          profil(iaux) = profil(iaux+decala)
   21   continue
c
        do 22 , iaux = jaux+1 , nbento
          profil(iaux) = 0
   22   continue
c
      endif
c
c====
c 3. creation de l'objet obprof de type 'Profil' a partir de la
c    liste profil
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR03', nompro
#endif
      call utpr03 ( option,
     >              nbento, profil, nensca,
     >              nbvapr, obprof,
     >              ulsort, langue, codret )
c
c====
c 4. comparaison avec les profils existant
c    . si on trouve un qui differe au plus par le nom, on
c      fait le remplacement
c    . si aucun profil connu n'est comparable, on l'enregistre
c====
c
      if ( codret.eq.0 ) then
c
      do 41 , iaux = 1 , nbprof
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR04', nompro
#endif
        call utpr04 ( liprof(nbprof), obprof,
     >                jaux,
     >                ulsort, langue, codret )
c
        if ( jaux.le.1 ) then
          call gmlboj (obprof, codret)
          obprof = liprof(nbprof)
          goto 42
        endif
c
        endif
c
   41 continue
c
      nbprof = nbprof + 1
      liprof(nbprof) = obprof
c
   42 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) obprof
      write (ulsort,texte(langue,4)) nbprof
#endif
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
