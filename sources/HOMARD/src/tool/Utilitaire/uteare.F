      subroutine uteare ( nbarto, nbnoto, somare,
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
c    UTilitaire - Examen des AREtes
c    --           -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbarto . e   .   1    . nombre d'aretes a examiner                 .
c . nbnoto . e   .   1    . nombre de sommets enregistres              .
c . somare . e   .nbarto*2. numeros des extremites d'arete             .
c . nmprog . e   . char*  . nom du programme a pister                  .
c . avappr . e   .   1    . 1 : impression avant l'appel a "nmprog"    .
c .        .     .        . 2 : impression apres l'appel a "nmprog"    .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . >0 : nombre de problemes rencontres        .
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
      parameter ( nompro = 'UTEARE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbarto, nbnoto
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
      integer iaux, jaux
      integer codre0
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
      texte(1,5) = '(5x,''Controle des '',i10,'' aretes.'')'
      texte(1,6) = '(''Arete :'',i10)'
      texte(1,7) = '(''Sommets :'',2i10,/)'
      texte(1,8) = '(''Les deux sommets sont confondus.'')'
      texte(1,9) = '(''Le numero du sommet'',i2,'' est mauvais.'')'
      texte(1,16) =
     > '(5x,''Pas de probleme dans la definition des aretes'',/)'
      texte(1,17) = '(/,''Mauvais code pour '',a,'' : '',i10,/)'
      texte(1,18) = '(/,''.. A l''''entree de '',a,'' :'',/)'
      texte(1,19) = '(/,''.. Avant appel a '',a,'' :'',/)'
      texte(1,20) = '(/,''.. Apres appel a '',a,'' :'',/)'
c
      texte(2,5) = '(5x,''Control of '',i10,'' edges.'')'
      texte(2,6) = '(''Edge :'',i10)'
      texte(2,7) = '(''Vertices :'',2i10,/)'
      texte(2,8) = '(''Nodes are similar.'')'
      texte(2,9) = '(''Wrong number for vertice #'',i2)'
      texte(2,16) = '(5x,''No problem with edge definition'',/)'
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
      write (ulsort,texte(langue,5)) nbarto
c
c====
c 2. verification
c====
c
      codret = 0
      jaux = 3*nbnoto
c
      do 21 , iaux = 1 , nbarto
c
        codre0 = 0
c
c 2.1. ==> les deux sommets doivent etre differents
c
        if ( somare(1,iaux).eq.somare(2,iaux) ) then
          codre0 = 1
          write (ulsort,texte(langue,8))
          write (ulbila,texte(langue,8))
c
c 2.2. ==> le numero de noeud est forcement positif
c
        elseif ( somare(1,iaux).le.0 ) then
          codre0 = 2
          write (ulsort,texte(langue,9)) 1
          write (ulbila,texte(langue,9)) 1
       elseif ( somare(2,iaux).le.0 ) then
          codre0 = 3
          write (ulsort,texte(langue,9)) 2
          write (ulbila,texte(langue,9)) 2
c
c 2.3. ==> le numero est borne : on ne connait pas toujours precisement
c          le maximum, mais on est sur que c'est inferieur a 3 fois le
c          nombre de noeuds actuel. Cela permet de pieger les
c          debordements de tableau
c
        elseif ( somare(1,iaux).gt.jaux ) then
          codre0 = 4
          write (ulsort,texte(langue,9)) 1
          write (ulbila,texte(langue,9)) 1
        elseif ( somare(2,iaux).gt.jaux ) then
          codre0 = 5
          write (ulsort,texte(langue,9)) 2
          write (ulbila,texte(langue,9)) 2
        endif
c
        if ( codre0.ne.0 ) then
          codret = codret + 1
          write (ulsort,texte(langue,6)) iaux
          write (ulbila,texte(langue,6)) iaux
          write (ulsort,texte(langue,7)) somare(1,iaux), somare(2,iaux)
          write (ulbila,texte(langue,7)) somare(1,iaux), somare(2,iaux)
        endif
c
   21 continue
c
c 2.2. ==> tout va bien
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
