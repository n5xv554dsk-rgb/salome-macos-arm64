      subroutine utvars ( col1, col2, lgtabx, tabaux,
     >                    somare,
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
c    UTilitaire - Verification des ARetes Soeurs
c    --           -                --     -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . col1   . e   .    1   . choix de la premiere colonne a controler   .
c . col2   . e   .    1   . choix de la seconde colonne a controler    .
c . lgtabx . e   .    1   . nombre de paquets a controler              .
c . tabaux . a   .3*lgtabx. tableau auxiliaire                         .
c .        .     .        . 1 : une des aretes filles                  .
c .        .     .        . 2 : l'autre arete fille                    .
c .        .     .        . 3 : l'arete mere                           .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . nombre de problemes sinon                  .
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
      parameter ( nompro = 'UTVARS' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer col1, col2
      integer lgtabx
      integer somare(2,nbarto)
      integer tabaux(3,lgtabx)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer laret1, laret2
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
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
      texte(1,4) = '(''Mauvais choix de colonne :'',i10)'
      texte(1,5) = '(''Examen de l''''arete'',i10)'
      texte(1,6) = '(''  du noeud'',i10,'' au noeud'',i10)'
      texte(1,7) =
     >'(''Impossible de trouver un sommet commun a ces aretes :'')'
c
      texte(2,4) = '(''Bad choice for column :'',i10)'
      texte(2,5) = '(''Examination of edge #'',i10)'
      texte(2,6) = '(''  from node #'',i10,'' to node #'',i10)'
      texte(2,7) =
     >'(''A common node cannot be found for these edges :'')'
c
      codret = 0
c
c====
c 2. on verifie qu'il y a au moins un sommet commun aux deux aretes
c====
c
c 2.1. ==> controle des numeros de colonne
c
      if ( col1.lt.1 .or. col1.gt.3 ) then
        write (ulsort,texte(langue,4)) col1
        codret = -1
      elseif ( col2.lt.1 .or. col2.gt.3 ) then
        write (ulsort,texte(langue,4)) col1
        codret = -1
      endif
c
c 2.2. ==>
c
      if ( codret.eq.0 ) then
c
      do 22 , iaux = 1 , lgtabx
c
        laret1 = tabaux(col1,iaux)
        laret2 = tabaux(col2,iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) laret1
      write (ulsort,texte(langue,6)) somare(1,laret1), somare(2,laret1)
      write (ulsort,texte(langue,5)) laret2
      write (ulsort,texte(langue,6)) somare(1,laret2), somare(2,laret2)
#endif
c
        if ( ( somare(1,laret1).ne.somare(1,laret2) ) .and.
     >       ( somare(1,laret1).ne.somare(2,laret2) ) .and.
     >       ( somare(2,laret1).ne.somare(1,laret2) ) .and.
     >       ( somare(2,laret1).ne.somare(2,laret2) ) ) then
c
        write (ulsort,texte(langue,7))
        write (ulsort,texte(langue,5)) laret1
        write (ulsort,texte(langue,6)) somare(1,laret1),somare(2,laret1)
        write (ulsort,texte(langue,5)) laret2
        write (ulsort,texte(langue,6)) somare(1,laret2),somare(2,laret2)
          codret = codret + 1
c
        endif
c
   22 continue
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
