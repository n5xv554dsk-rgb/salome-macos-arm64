      subroutine utetri ( nbtrto, nbtral,
     >                    aretri, somare,
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
c    UTilitaire - Examen des TRIangles
c    --           -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbtrto . e   .   1    . nombre de triangles a examiner             .
c . nbtral . e   .   1    . nombre de triangles pour les allocations   .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . somare . e   . 2*nbar . numeros des extremites d'arete             .
c . nmprog . e   . char*  . nom du programme a pister                  .
c . avappr . e   .   1    . 1 : impression avant l'appel a "nmprog"    .
c .        .     .        . 2 : impression apres l'appel a "nmprog"    .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      parameter ( nompro = 'UTETRI' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbtrto, nbtral
      integer aretri(nbtral,3)
      integer somare(2,*)
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
      integer iaux, jaux, kaux
      integer a1, a2, a3
      integer sa1a2, sa2a3, sa3a1
      integer listar(3)
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
      texte(1,6) = '(5x,''Controle des '',i10,'' triangles.'')'
      texte(1,7) =
     > '(''Le triangle '',i10,'' a des aretes confondues :'',3i10)'
      texte(1,8) =
     > '(''Le triangle '',i10,'' a des noeuds confondus :'',3i10)'
      texte(1,16) =
     > '(5x,''Pas de probleme dans la definition des triangles'',/)'
      texte(1,17) = '(/,''Mauvais code pour '',a,'' : '',i10,/)'
      texte(1,18) = '(/,''.. A l''''entree de '',a,'' :'',/)'
      texte(1,19) = '(/,''.. Avant appel a '',a,'' :'',/)'
      texte(1,20) = '(/,''.. Apres appel a '',a,'' :'',/)'
c
      texte(2,6) = '(5x,''Control of '',i10,'' triangles.'')'
      texte(2,7) =
     > '(''Edges of triangle # '',i10,'' are similar :'',3i10)'
      texte(2,8) =
     > '(''Nodes of triangle # '',i10,'' are similar :'',3i10)'
      texte(2,16) = '(5x,''No problem with triangle definition'',/)'
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
      write (ulsort,texte(langue,6)) nbtrto
c
      codret = 0
c
c====
c 2. verification
c====
c
      do 20 , iaux = 1 , nbtrto
c
        codre0 = 0
c
c 2.1. ==> les aretes doivent etre differentes ...
c
        a1 = aretri(iaux,1)
        a2 = aretri(iaux,2)
        a3 = aretri(iaux,3)
c
        if ( a1.eq.a2 .or.
     >       a2.eq.a3 .or.
     >       a3.eq.a1 ) then
          codre0 = 1
          write (ulsort,texte(langue,7)) iaux, a1, a2, a3
          write (ulbila,texte(langue,7)) iaux, a1, a2, a3
        endif
c
c 2.2. ==> les aretes doivent se suivre ...
c
        if ( codre0.eq.0 ) then
c
        listar(1) = a1
        listar(2) = a2
        listar(3) = a3
        jaux = 2
        kaux = 3
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVAR0', nompro
#endif
        call utvar0 ( jaux, iaux, kaux, listar, somare,
     >                ulbila, ulsort, langue, codre0 )
c
        endif
c
c 2.3. ==> les sommets doivent etre differents ...
c
        if ( codre0.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSOTR', nompro
#endif
        call utsotr ( somare, a1, a2, a3,
     >                sa1a2, sa2a3, sa3a1 )
c
        if ( sa1a2.eq.sa2a3 .or.
     >       sa1a2.eq.sa3a1 .or.
     >       sa2a3.eq.sa3a1 ) then
          codre0 = 1
          write (ulsort,texte(langue,8)) iaux, sa1a2, sa2a3, sa3a1
          write (ulbila,texte(langue,8)) iaux, sa1a2, sa2a3, sa3a1
        endif
c
        endif
c
c 2.4. ==> cumul des erreurs
c
        codret = codret + codre0
c
   20 continue
c
c 2.4. ==> tout va bien
c
      if ( codret.eq.0 ) then
        write (ulsort,texte(langue,16))
        write (ulbila,texte(langue,16))
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
