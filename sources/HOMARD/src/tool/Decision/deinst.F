      subroutine deinst ( typenh,
     >                    seuihe, seuibe,
     >                    nbenti, suppor, indire, indien,
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
c traitement des DEcisions - INitialisation des Seuils - Tri
c                --          --                 -        -
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
c . seuihe . e   .   1    . borne superieure absolue de l'erreur entite.
c . seuibe . e   .   1    . borne inferieure absolue de l'erreur entite.
c . nbenti . e   .   1    . nombre d'entites pour les entites          .
c . suppor . e   . nbenti . support pour les entites                   .
c . indire . e   . nbenti . valeurs reelles pour les entites           .
c . indien .  s  . nbenti . valeurs entieres filtrees pour les entites .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEINST' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh
      integer nbenti
      integer suppor(nbenti), indien(nbenti)
c
      double precision seuibe, seuihe
      double precision indire(nbenti)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''Transfert de reel a entier pour les '',a))'
      texte(1,5) = '(''Seuil haut = '',g13.5)'
      texte(1,6) = '(''Seuil bas  = '',g13.5)'
c
      texte(2,4) = '(''Transfert de reel a entier pour les '',a))'
      texte(2,5) = '(''High threshold = '',g13.5)'
      texte(2,6) = '(''Low threshold  = '',g13.5)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,texte(langue,5)) seuihe
      write (ulsort,texte(langue,6)) seuibe
#endif
c
#include "impr03.h"
c
c====
c 2. transfert de reel a entier
c====
c
      do 21 , iaux = 1, nbenti
cgn      write (ulsort,90012) 'support pour', iaux, suppor(iaux)
c
        if ( suppor(iaux).ne.0 ) then
cgn      write (ulsort,90024) 'indire pour', iaux, indire(iaux)
c
          if ( indire(iaux).le.seuibe ) then
            indien(iaux) = -1
          elseif ( indire(iaux).ge.seuihe ) then
            indien(iaux) = 1
          else
            indien(iaux) = 0
          endif
cgn      write (ulsort,90012) '==> indien pour', iaux, indien(iaux)
c
        endif
c
   21  continue
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
