      subroutine esech3 ( nrtafo,
     >                    nbtafo, nbpg, nbvalc, nbcomp,
     >                    vafonc, trav1,
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
c  Entree-Sortie - Ecriture d'un CHamp au format MED - phase 3
c  -      -        -             --                          -
c  Ce programme est le symetrique de ESLCH5
c  remarque : esech2 et esech3 sont des clones
c             2 : double precision
c             3 : entier
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nrtafo . es  .   1    . numero courant du tableau de la fonction   .
c . nbcomp . e   .   1    . nombre de composantes du champ             .
c . nbtafo . e   .   1    . nombre de tableaux de la fonction          .
c . renume . e   .   *    . renumerotation des entites                 .
c . nbvalc . e   .   1    . nombre de valeurs par composante           .
c . nbpg   . e   .   1    . nombre de points de Gauss, s'il y en a     .
c .        .     .        . si le champ est sans point de Gauss, nbpg  .
c .        .     .        . vaut 1 pour aider au traitement            .
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
      parameter ( nompro = 'ESECH3' )
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
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nrcomp, nugaus
c
      integer nbmess
      parameter ( nbmess = 150 )
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
      texte(1,5) = '(''. Premiere valeur : '',i10)'
      texte(1,6) = '(''. Derniere valeur : '',i10)'
c
      texte(2,5) = '(''. First value: '',i10)'
      texte(2,6) = '(''. Last value : '',i10)'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '============================================='
      write (ulsort,texte(langue,58)) nbvalc
      write (ulsort,90002) 'nbcomp', nbcomp
      write (ulsort,texte(langue,111)) nbtafo
      write (ulsort,texte(langue,57)) nbpg
      write (ulsort,90002) 'nrtafo', nrtafo
      write (ulsort,texte(langue,5)) vafonc(nrtafo,1,1)
      write (ulsort,texte(langue,6)) vafonc(nrtafo,nbpg,nbvalc)
#endif
c
c====
c    . Sans points de Gauss :
c    Dans la phase de transfert dans les tableaux HOMARD, le tableau
c    trav1 est declare ainsi : trav1(nbpg,nbensu,nbcomp), ce qui
c    corrrespond a trav1(nbensu,nbcomp) sans points de Gauss.
c
c    En fortran, cela correspond au stockage memoire suivant :
c    trav1(1,1), trav1(2,1), trav1(3,1), ..., trav1(nbensu,1),
c    trav1(1,2), trav1(2,2), trav1(3,2), ..., trav1(nbensu,2),
c    ...
c    trav1(1,nbcomp), trav1(2,nbcomp), ..., trav1(nbensu,nbcomp)
c    on a ainsi toutes les valeurs pour la premiere composante, puis
c    toutes les valeurs pour la seconde composante, etc.
c
c    . Avec nbpg points de Gauss :
c    Dans la phase de transfert dans les tableaux HOMARD, le tableau
c    trav1 sera declare ainsi : trav1(nbpg,nbensu,nbcomp).
c
c    En fortran, cela correspond au stockage memoire suivant :
c    trav1(1,1,1), trav1(2,1,1), ..., trav1(nbpg,1,1), trav1(1,2,1),
c    trav1(2,2,1), ..., trav1(nbpg,2,1), trav1(1,3,1), ...,
c    trav1(1,nbensu,1), trav1(2,nbensu,1), ..., trav1(nbpg,nbensu,1),
c    trav1(1,1,2), trav1(2,1,2), ..., trav1(nbpg,1,2), trav1(1,2,2),
c    trav1(2,2,2), ..., trav1(nbpg,2,2), trav1(1,3,2), ...,
c    trav1(1,nbensu,2), trav1(2,nbensu,2), ..., trav1(nbpg,nbensu,2),
c    ...
c    trav1(1,1,nrcomp), trav1(2,1,nrcomp), ..., trav1(nbpg,1,nrcomp),
c    trav1(1,2,nrcomp), trav1(2,2,nrcomp), ..., trav1(nbpg,2,nrcomp),
c    trav1(1,3,nrcomp), ..., trav1(nbpg,nbensu,nrcomp)
c    on a ainsi tous les points de Gauss de la premiere maille de la
c    premiere composante, puis tous les points de Gauss de la
c    deuxieme maille de la premiere composante, etc. jusqu'a la fin de
c    la premiere composante. Ensuite on recommence avec la deuxieme
c    composante.
c
c    . Remarque : C'est ce que MED appelle le mode non entrelace.
c====
c
      codret = 0
c
      do 20 , nrcomp = 1 , nbcomp
cgn            print *,'nrcomp,nrtafo,nbvalc = ',nrcomp,nrtafo,nbvalc
c
        if ( nbpg.eq.1 ) then
          do 21 , iaux = 1 , nbvalc
cgn      print *,'iaux = ',iaux
cgn      print *,'vafonc(',nrtafo,',1,',iaux,') = ',vafonc(nrtafo,1,iaux)
            trav1(1,iaux,nrcomp) = vafonc(nrtafo,1,iaux)
cgn            write(12,*) 'trav1 = ',trav1(1,iaux,nrcomp)
   21     continue
        else
          do 22 , iaux = 1 , nbvalc
            do 221 , nugaus = 1 , nbpg
              trav1(nugaus,iaux,nrcomp) = vafonc(nrtafo,nugaus,iaux)
  221       continue
   22     continue
        endif
c
        nrtafo = nrtafo + 1
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nrtafo', nrtafo
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
