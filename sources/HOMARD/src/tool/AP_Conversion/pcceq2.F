      subroutine pcceq2 ( option,
     >                    nbento, nctfen, nbfent,
     >                    ncefen, nbeqen, tyhen1, tyhen2, nbenca,
     >                    cfaent, fament, nensho,
     >                    typele,
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
c    aPres adaptation - Conversion - Creation des EQuivalences - phase 2
c     -                 -            -            --                   -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . variantes                                  .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   4 : quadrangles                          .
c . nbento . e   .    1   . nombre d'entites total                     .
c . nctfen . e   .    1   . nombre total de caracteristiques           .
c . nbfent . e   .    1   . nombre de familles de l'entite             .
c . ncefen . e   .    1   . nombre de caracteristiques d'equivalence   .
c .        .     .        . dans les familles de l'entite              .
c . nbeqen .   s .    1   . estimation du nombre de paires d'entites   .
c . tyhen1 . e   .    1   . 1er type homard representant cette entite  .
c . tyhen2 . e   .    1   . 2nd type homard representant cette entite  .
c . nbenca . e   .    1   . nombre d'entites du calcul                 .
c . cfaent . e   . nctfen*. codes des familles des entites             .
c .        .     . nbfent .                                            .
c . fament . e   . nbento . famille des entites                        .
c . nensho . e   . rsenac . numero des entites dans HOMARD             .
c . typele . e   . nbelem . type des elements                          .
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
      parameter ( nompro = 'PCCEQ2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "rftmed.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbento, nctfen, nbfent
      integer ncefen, nbeqen, tyhen1, tyhen2, nbenca
      integer nensho(*)
      integer typele(*)
c
      integer cfaent(nctfen,nbfent), fament(nbento)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nucode
      integer iaux, jaux, ideb, ifin
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,''Decompte des equivalences sur les '',a)'
      texte(1,5) = '(''--> Ce nombre doit etre pair !'')'
      texte(1,8) =
     > '(8x,''. Nombre a apparier                           :'',i10)'
c
      texte(2,4) = '(/,''Description of equivalences over '',a)'
      texte(2,5) = '(''--> This number should be even !'')'
      texte(2,8) =
     > '(8x,''. Number of entities                          :'',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,option)
#endif
c
      codret = 0
c
c====
c 2. on compte combien d'elements appartiennent a des equivalences.
c    on trie les entites qui sont vraiment des elements : cela se
c    reconnait en utilisant les codes lies au type des elements.
c
c    remarque : il vaut mieux que la boucle sur les entites soit a
c               l'interieur car elle sera toujours plus longue que
c               celle sur les equivalences, d'ou une meilleure
c               vectorisation
c====
c
      nbeqen = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbento', nbento
#endif
c
      if ( nbento.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbenca', nbenca
      if ( option.ge.0 ) then
        write (ulsort,90002) 'tyhen1', tyhen1
        write (ulsort,90002) 'tyhen2', tyhen2
      endif
      write (ulsort,90002) 'ncefen', ncefen
#endif
c
      iaux = 0
      ideb = nctfen - ncefen + 1
      ifin = nctfen
c
      do 21 , nucode = ideb , ifin
c
c 2.1. ==> cas particulier des noeuds
c
        if ( option.lt.0 ) then
c
          do 211 , jaux = 1, nbenca
            if ( cfaent(nucode,fament(nensho(jaux))).ne.0 ) then
              nbeqen = nbeqen + 1
            endif
  211     continue
c
c 2.2. ==> les elements
c
        else
c
          do 212 , jaux = 1, nbenca
            if ( medtrf(typele(jaux)).eq.tyhen1 .or.
     >           medtrf(typele(jaux)).eq.tyhen2 ) then
              if ( cfaent(nucode,fament(nensho(jaux))).ne.0 ) then
                 nbeqen = nbeqen + 1
              endif
            endif
  212     continue
c
        endif
c
        if ( iaux.ne.nbeqen ) then
          iaux = nbeqen
        endif
c
   21 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'ncefen', ncefen
#endif
c
      endif
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
