      subroutine sflise ( numlig, seg, seglig,
     >                    ulsort, langue, codret)
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
c   Suivi de Frontiere - LIgne d'appartenance d'un SEgment
c   -        -           --                        --
c ______________________________________________________________________
c
c     but : retourner le numero de la ligne d'apres le numero du segment
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numlig .  s  .   1    . numero de la ligne du segment              .
c . seg    . e   .   1    . numero du segment                          .
c . seglig . e   .0:sfnbli. pointeur dans le tableau somseg : les      .
c .        .     .        . segments de la ligne i sont aux places de  .
c .        .     .        . seglig(i-1)+1 a seglig(i)-1 inclus         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : le numero de segment est negatif ou nul.
c .        .     .        . 2 : le numero de segment est trop grand    .
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
      parameter ( nompro = 'SFLISE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "front1.h"
c
c 0.3. ==> arguments
c
      integer numlig, seg, seglig(0:sfnbli)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de lignes :'',i5)'
      texte(1,5) = '(''Premier segment  :'',i5)'
      texte(1,6) = '(''Dernier segment  :'',i5)'
      texte(1,7) = '(''Segment recherche :'',i5)'
      texte(1,8) =
     > '(''Le numero du segment recherche est negatif ou nul.'')'
      texte(1,9) =
     > '(''Le numero du segment recherche est trop grand.'')'
c
      texte(2,4) = '(''Number of lines :'',i5)'
      texte(2,5) = '(''First segment   :'',i5)'
      texte(2,6) = '(''Last segment    :'',i5)'
      texte(2,7) = '(''Requested segment :'',i5)'
      texte(2,8) = '(''Requested segment # is negative or null.'')'
      texte(2,9) = '(''Requested segment # is too high.'')'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) sfnbli
      write (ulsort,texte(langue,5)) seglig(0)
      write (ulsort,texte(langue,6)) seglig(sfnbli)
      write (ulsort,texte(langue,7)) seg
      write (ulsort,1789) ( seglig(iaux) , iaux = 1 , sfnbli)
 1789 format(10i8)
#endif
c
c====
c 2. recherche
c====
c
c 2.1. ==> controle preliminaire
c
      if ( seg.le.0 ) then
c
        codret = 1
c
      elseif ( seg.gt.seglig(sfnbli) ) then
c
        codret = 2
c
      else
c
c 2.2. ==> recherche
c
        do 22 , iaux = 1 , sfnbli
c
          if ( seg.le.seglig(iaux) ) then
            numlig = iaux
            goto 221
          endif
c
  22    continue
c
 221    continue
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
      write (ulsort,texte(langue,4)) sfnbli
      write (ulsort,texte(langue,5)) seglig(0)+1
      write (ulsort,texte(langue,6)) seglig(sfnbli)
      write (ulsort,texte(langue,7)) seg
      write (ulsort,texte(langue,7+codret))
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
