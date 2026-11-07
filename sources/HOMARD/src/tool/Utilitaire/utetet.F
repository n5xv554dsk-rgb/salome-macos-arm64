      subroutine utetet ( nbteto, nbtfal, nbtaal, nbtral,
     >                    somare, aretri,
     >                    tritet, cotrte, aretet,
     >                    nmprog, avappr, ulbila,
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
c    UTilitaire - Examen des TETraedres
c    --           -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbteto . e   .   1    . nombre de tetraedres a examiner            .
c . nbtfal . e   .   1    . nombre de tetrs par faces pour les allocs  .
c . nbtaal . e   .   1    . nbre de tetrs par aretes pour les allocs   .
c . nbtral . e   .   1    . nombre de triangles pour les allocations   .
c . somare . e   . 2*nbar . numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . nmprog . e   . char*  . nom du programme a pister                  .
c . avappr . e   .   1    . 1 : impression avant l'appel a "nmprog"    .
c .        .     .        . 2 : impression apres l'appel a "nmprog"    .
c . ulbila . e   .   1    . unite logitee d'ecriture du bilan          .
c . ulsort . e   .   1    . numero d'unite logitee de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . >0 : probleme dans le controle             .
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
      parameter ( nompro = 'UTETET' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbteto, nbtfal, nbtaal, nbtral
      integer somare(2,*)
      integer aretri(nbtral,3)
      integer tritet(nbtfal,4), cotrte(nbtfal,4), aretet(nbtaal,6)
c
      character*(*) nmprog
c
      integer avappr
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre0
      integer iaux, jaux
c
      integer nbmess
      parameter ( nbmess = 20 )
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
      texte(1,6) = '(5x,''Controle des '',i10,'' tetraedres.'')'
      texte(1,16) =
     > '(5x,''Pas de probleme dans la definition des tetraedres'',/)'
      texte(1,17) = '(/,''Mauvais code pour '',a,'' : '',i10,/)'
      texte(1,18) = '(/,''.. A l''''entree de '',a,'' :'',/)'
      texte(1,19) = '(/,''.. Avant appel a '',a,'' :'',/)'
      texte(1,20) = '(/,''.. Apres appel a '',a,'' :'',/)'
c
      texte(2,6) = '(5x,''Control of '',i10,'' tetraedres.'')'
      texte(2,16) = '(5x,''No problem with tetraedra definition'',/)'
      texte(2,17) = '(/,''Bad code for '',a,'' : '',i10,/)'
      texte(2,18) = '(/,''.. At the beginning of '',a,'' :'',/)'
      texte(2,19) = '(/,''.. Before calling '',a,'' :'',/)'
      texte(2,20) = '(/,''.. After calling '',a,'' :'',/)'
c
#ifdef _DEBUG_HOMARD_
      if ( avappr.ge.0 .and. avappr.le.2 ) then
        write (ulsort,texte(langue,18+avappr)) nmprog
      else
        write (ulsort,texte(langue,17)) nmprog, avappr
      endif
#endif
      write (ulsort,texte(langue,6)) nbteto
c
c====
c 2. verification
c====
c
      codre0 = 0
c
      do 20 , iaux = 1 , nbteto
c
c 2.1. ==> analyse du tetraedre courant
c
        jaux = iaux
        call utvte0 ( jaux, nbtfal, nbtaal, nbtral,
     >                somare, aretri,
     >                tritet, cotrte, aretet,
     >                ulbila,
     >                ulsort, langue, codret )
c
c 2.2. ==> cumul des erreurs
c
        codre0 = codre0 + codret
c
   20 continue
c
c 2.6. ==> Bilan
c
      if ( codre0.eq.0 ) then
        write (ulsort,texte(langue,16))
        write (ulbila,texte(langue,16))
      endif
c
      codret = codre0
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
