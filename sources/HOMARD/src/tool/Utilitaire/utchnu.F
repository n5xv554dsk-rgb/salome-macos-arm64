      subroutine utchnu ( option, nbenti, nounum,
     >                    dim1, dim2, table,
     >                    tabaux,
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
c    UTilitaire - CHangement de NUmerotation d'une table
c    --           --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . type de renumerotation                     .
c .        .     .        . 1 : changement de l'indice de la table     .
c .        .     .        . 2 : changement du contenu de la table      .
c .        .     .        . 3 : changement de l'indice et du contenu   .
c . nbenti . e   .    1   . nombre d'entites                           .
c . nounum . e   . nbenti . nouveau numero des entites                 .
c . dim1   . e   .    1   . 1ere dimension de la table a renumeroter   .
c . dim2   . e   .    1   . 2nde dimension de la table a renumeroter   .
c . table  . es  .dim1dim2. table a renumeroter                        .
c . tabaux . a   .dim1dim2. tableau auxiliaire pour les options 1 et 3 .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : mauvais choix d'option                 .
c .        .     .        . 2 : mauvaises dimensions                   .
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
      parameter ( nompro = 'UTCHNU' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbenti
      integer dim1, dim2
      integer table(dim1,dim2)
      integer nounum(0:nbenti)
      integer tabaux(dim1,dim2)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer diment
c
      integer nbmess
      parameter ( nbmess = 10 )
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
      texte(1,4) = '(''Nombre d''''entites :'',i10)'
      texte(1,5) = '(''Option'',i10,'' impossible.'')'
      texte(1,6) = '(''Dimension'',i2,'' :'',i10)'
      texte(1,7) =
     > '(''Une dimension doit etre egale au nombre d''''entites.'')'
      texte(1,8) = '(''Changement de l''''indice de la table'')'
      texte(1,9) = '(''Changement du contenu de la table'')'
      texte(1,10) = '(''Changement de l''''indice et du contenu'')'
c
      texte(2,4) = '(''Number of entities :'',i10)'
      texte(2,5) = '(''Option'',i10,'' impossible.'')'
      texte(2,6) = '(''Dimension #'',i2,'' :'',i10)'
      texte(2,7) =
     > '(''One should be equal to the number of entities.'')'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbenti
        write (ulsort,texte(langue,6)) 1, dim1
        write (ulsort,texte(langue,6)) 2, dim2
#endif
c
c====
c 2. Controles
c====
c 2.1. ==> Option
c
      if ( option.le.0 .or. option.ge.4 ) then
c
        write (ulsort,texte(langue,5)) option
        codret = 1
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
        write (ulsort,texte(langue,7+option))
      endif
#endif
c
c 2.2. ==> Les dimensions
c
      if ( codret.eq.0 ) then
c
      if ( option.eq.1 .or. option.eq.3 ) then
c
        if ( dim1.eq.nbenti ) then
          diment = 1
        elseif ( dim2.eq.nbenti ) then
          diment = 2
        else
          write (ulsort,texte(langue,4)) nbenti
          write (ulsort,texte(langue,6)) 1, dim1
          write (ulsort,texte(langue,6)) 2, dim2
          write (ulsort,texte(langue,7))
          codret = 2
        endif
c
      endif
c
      endif
c
c====
c 3. Renumerotation
c====
c
      if ( codret.eq.0 ) then
c
cgn      write (ulsort,*) '==> diment = ', diment
c
c 3.1. ==> Stockage de la table au depart
c
      if ( option.eq.1 .or. option.eq.3 ) then
c
        if ( diment.eq.1 ) then
c
          do 311 , jaux = 1 , dim2
            do 312 , iaux = 1 , nbenti
              tabaux(iaux,jaux) = table(iaux,jaux)
  312       continue
  311     continue
c
        else
c
          do 313 , iaux = 1 , dim1
            do 314 , jaux = 1 , nbenti
              tabaux(iaux,jaux) = table(iaux,jaux)
  314       continue
  313     continue
cgn      if ( dim1.eq.2 ) then
cgn      write (ulsort,*) table(1,108482), table(2,108482)
cgn      write (ulsort,*) table(1,109114), table(2,109114)
cgn      write (ulsort,*) table(1,109215), table(2,109215)
cgn      endif
c
        endif
c
      endif
c
c 3.2. ==> Bascule
c
c 3.2.1. ==> Changement de l'indice
c
      if ( option.eq.1 ) then
c
        if ( diment.eq.1 ) then
cgn        write (ulsort,*) '3211'
c
          do 3211 , jaux = 1 , dim2
cgn        write (ulsort,*) '. jaux =', jaux
            do 3212 , iaux = 1 , nbenti
cgn      write (ulsort,*) '.. taux(',iaux,',',jaux,')',tabaux(iaux,jaux)
              table(nounum(iaux),jaux) = tabaux(iaux,jaux)
 3212       continue
 3211     continue
c
        else
c
cgn        write (ulsort,*) '3211'
          do 3213 , iaux = 1 , dim1
cgn        write (ulsort,*) '. iaux =', iaux
            do 3214 , jaux = 1 , nbenti
cgn      write (ulsort,*) '.. taux(',iaux,',',jaux,')',tabaux(iaux,jaux)
            table(iaux,nounum(jaux)) = tabaux(iaux,jaux)
 3214       continue
 3213     continue
c
        endif
c
c 3.2.2. ==> Changement du contenu
c
      elseif ( option.eq.2 ) then
c
        do 3221 , iaux = 1 , dim1
cgn        write (ulsort,*) '. iaux =', iaux
          do 3222 , jaux = 1 , dim2
cgn      write (ulsort,*) '.. table(',iaux,',',jaux,')',table(iaux,jaux)
            table(iaux,jaux) = nounum(table(iaux,jaux))
 3222     continue
 3221   continue
c
c 3.2.3. ==> Changement de l'indice et du contenu
c
      elseif ( option.eq.3 ) then
c
        if ( diment.eq.1 ) then
c
          do 3231 , jaux = 1 , dim2
            do 3232 , iaux = 1 , nbenti
              table(nounum(iaux),jaux) = nounum(tabaux(iaux,jaux))
 3232       continue
 3231     continue
c
        else
c
          do 3233 , iaux = 1 , dim1
            do 3234 , jaux = 1 , nbenti
              table(iaux,nounum(jaux)) = nounum(tabaux(iaux,jaux))
 3234       continue
 3233     continue
c
        endif
c
      endif
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
