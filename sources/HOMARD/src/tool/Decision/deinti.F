      subroutine deinti ( typenh,
     >                    usacmp, nbenti, suppor, indica,
     >                    indtab, tabind,
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
c traitement des DEcisions - INitialisation - Tableau des Indicateurs
c                --          --               -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . type d'entites concernees                  .
c .        .     .        . 0 : noeuds                                 .
c .        .     .        . 1 : aretes                                 .
c .        .     .        . 2 : triangles                              .
c .        .     .        . 3 : tetraedres                             .
c .        .     .        . 4 : quadrangles                            .
c .        .     .        . 5 : pyramides                              .
c .        .     .        . 6 : hexaedres                              .
c .        .     .        . 7 : pentaedres                             .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . nbenti . e   .   1    . nombre d'entites pour les entites          .
c . suppor . e   . nbenti . support pour les entites                   .
c . indica . e   . nbenti . valeurs pour les entites                   .
c . indtab . es  .   1    . dernier indice affecte dans tabind         .
c . tabind . es  .   *    . tableau de l'indicateur                    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
c .        .     .        . 3 : les seuils sont mal definis            .
c .        .     .        . 4 : nombres d'entites incoherents          .
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
      parameter ( nompro = 'DEINTI' )
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
      integer typenh
      integer usacmp
      integer nbenti
      integer suppor(nbenti)
      integer indtab
c
      double precision indica(nbenti)
      double precision tabind(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter (nbmess = 11 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
c 1.1. ==> Les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Prise en compte des valeurs pour les '',a))'
      texte(1,5) =
     >'(''. Nombre d''''entites designees par le support :'',i10)'
      texte(1,9) = '(''. Norme L2 des composantes.'')'
      texte(1,10) = '(''. Norme infinie des composantes.'')'
      texte(1,11) = '(''. Valeur relative de la composante.'')'
c
      texte(2,4) = '(''Values for the '',a))'
      texte(2,5) =
     >'(''. Number of entities declared by support of error :'',i10)'
      texte(2,9) = '(''. L2 norm of components.'')'
      texte(2,10) = '(''. Infinite norm of components.'')'
      texte(2,11) = '(''. Relative value for the component.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
c
c====
c 2. si on s'interesse a la valeur absolue de l'indicateur d'erreur,
c    on remplace sa valeur
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9+usacmp))
#endif
c
      if ( usacmp.ne.2 ) then
c
        do 21 , iaux = 1, nbenti
          if ( suppor(iaux).ne.0 ) then
            indica(iaux) = abs(indica(iaux))
          endif
   21   continue
c
      endif
c
c====
c 3. compactage
c          le tableau d'indicateur peut comporter des trous. Le tableau
c          suppor indique pour chaque entite si elle comporte un
c          indicateur d'erreur, 1, ou si c'est sans objet, 0.
c          on tasse alors le tableau d'indicateur de indica vers ntrav1
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. compactage, codret = ',codret
#endif
c
c        Exemple :
c          numero entite : 1    2    3    4    5    6  ==> nbenti = 6
c          indica        : NaN  3.8  4.2  NaN  NaN  2.3
c         apres compactage :
c          ntrav1        : 3.8  4.2  2.3  NaN  NaN  NaN
c          ntrav2        : 2    3    6    NaN  NaN  NaN ==> iaux = 3
c
      if ( codret.eq.0 ) then
c
      do 31 , iaux = 1, nbenti
        if ( suppor(iaux).ne.0 ) then
          indtab = indtab + 1
          tabind(indtab) = indica(iaux)
        endif
   31 continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) indtab
#endif
cgn    write (ulsort, * )'================== indica ========='
cgn    write (ulsort, 1401 )(iaux,indica(iaux),iaux=1,nbenti)
cgn    write (ulsort, * )'================== suppor ========='
cgn    write (ulsort, 1400 )(iaux,suppor(iaux),iaux=1,nbenti)
cgn    print * ,'================== ptrav1 ========='
cgn    print 1401 ,(iaux,tabind(iaux),iaux=1,indtab)
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
