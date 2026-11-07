      subroutine eslch8 ( nrtafo,
     >                    nbtafo, nbpg, nbvalc, nbcomp,
     >                    vafonc, trav1,
     >                    obcham, objech,
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
c  Entree-Sortie - Lecture d'un CHamp au format MED - phase 8
c  -      -        -            --                          -
c  Ce programme est le symetrique de ESECH2
c  Remarque : eslch5 et eslch8 sont des clones
c             5 : double precision
c             8 : entier
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nrtafo . es  .   1    . numero courant du tableau de la fonction   .
c . nbtafo . e   .   1    . nombre de tableaux de la fonction          .
c . nbpg   . e   .   1    . nombre de points de Gauss, s'il y en a     .
c .        .     .        . si le champ est sans point de Gauss, nbpg  .
c .        .     .        . vaut 1 pour aider au traitement            .
c . nbvalc . e   .   1    . nombre de valeurs par composante           .
c . nbcomp . e   .   1    . nombre de composantes du champ             .
c . vafonc . es  .   *    . valeurs de la fonction                     .
c . trav1  . e   .   *    . valeurs lues                               .
c . obcham . e   . char8  . nom de l'objet de type 'InfoCham' associe  .
c . objech . es  . nbtafo . nom de l'objet de type 'InfoCham' associe  .
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
      parameter ( nompro = 'ESLCH8' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nrtafo
      integer nbtafo
      integer nbpg, nbvalc, nbcomp
c
      integer trav1(nbpg,nbvalc,nbcomp)
      integer vafonc(nbtafo,nbpg,*)
c
      character*8 obcham
      character*8 objech(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nrcomp, nUGaus
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. '',a,'' = '',i8)'
      texte(1,5) = '(''. Premiere valeur : '',i10)'
      texte(1,6) = '(''. Derniere valeur : '',i10)'
      texte(1,7) = '(''... Composante numero '',i8)'
c
      texte(2,4) = '(''. '',a,'' = '',i8)'
      texte(2,5) = '(''. First value : '',i10)'
      texte(2,6) = '(''. Last value  : '',i10)'
      texte(2,7) = '(''... Composante # '',i8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 'nbtafo', nbtafo
      write (ulsort,texte(langue,4)) 'nbpg  ', nbpg
      write (ulsort,texte(langue,4)) 'nbvalc', nbvalc
      write (ulsort,texte(langue,4)) 'nbcomp', nbcomp
      write (ulsort,texte(langue,4)) 'nrtafo au depart', nrtafo
#endif
c
c====
c 2. Transfert
c====
c
      codret = 0
c
      do 20 , nrcomp = 1 , nbcomp
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nrcomp
      write (ulsort,texte(langue,4)) '==> nrtafo', nrtafo
#endif
c
cgn             print *,'nrcomp,nrtafo, nbvalc = ',nrcomp,nrtafo, nbvalc
c
c 2.1. ==> les valeurs numeriques
c
        if ( nbpg.eq.1 ) then
c
          do 21 , iaux = 1 , nbvalc
cgn            write(11,*) 'trav1 = ',trav1(1,iaux,nrcomp)
            vafonc(nrtafo,1,iaux) = trav1(1,iaux,nrcomp)
 21       continue
c
        else
c
          do 22 , iaux = 1 , nbvalc
cgn            print *,'trav1(...,',iaux,',',nrcomp,') = ',
cgn     >             (trav1(nUGaus,iaux,nrcomp),nUGaus=1,nbpg)
            do 221 , nUGaus = 1 , nbpg
              vafonc(nrtafo,nUGaus,iaux) = trav1(nUGaus,iaux,nrcomp)
  221       continue
   22     continue
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) vafonc(nrtafo,1,1)
      write (ulsort,texte(langue,6)) vafonc(nrtafo,nbpg,nbvalc)
#endif
c
c 2.2. ==> les caracteristiques du champ associe
c
        objech(nrtafo) = obcham
c
c 2.3. ==> tableau suivant dans la fonction
c
        nrtafo = nrtafo + 1
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 'nrtafo a la fin ', nrtafo
#endif
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
