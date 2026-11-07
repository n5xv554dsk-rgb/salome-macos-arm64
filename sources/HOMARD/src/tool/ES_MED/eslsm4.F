      subroutine eslsm4 ( idfmed,
     >                    nbcham, obcham,
     >                    nbfonc, defonc, nofonc,
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
c  Entree-Sortie - Lecture d'une Solution au format MED - phase 2
c  -      -        -             -                  -           -
c  remarque : on ne lit que les champs reels
c  remarque : on part du principe que les elements externes sont
c             numerotes ainsi : tetraedres, triangles, segments,
c             mailles-points, quadrangles, hexaedres, pyramides,
c             pentaedres.
c             C'est ce qui se passe a la lecture d'un maillage med par
c             le programme eslmm2, lors de la creation du tableau des
c             connectivite par noeuds.
c             C'est aussi le cas pour la conversion du maillage apres
c             adaptation (pcmav1).
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med en entree       .
c . nbcham . e   .   1    . nombre de champs dans le fichier           .
c . obcham . e   . nbcham . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . nbfonc . e   .   1    . nombre de fonctions                        .
c . defonc . e   . nbinec*. description des fonctions en entier        .
c .        .     . nbfonc . 1. type de support au sens MED             .
c .        .     .        . 2. nombre de points de Gauss               .
c .        .     .        . 3. nombre de valeurs                       .
c .        .     .        . 4. nombre de valeurs du profil eventuel    .
c .        .     .        . 5. nombre de supports associes             .
c .        .     .        . 6. 1, si aux noeuds par elements           .
c .        .     .        .    2, si aux points de Gauss, associe avec .
c .        .     .        .       un champ aux noeuds par elements     .
c .        .     .        .    3, si aux points de Gauss autonome      .
c .        .     .        .    0, sinon                                .
c .        .     .        . 7. nombre de tableaux de ce type           .
c .        .     .        . 8. numero du tableau dans la fonction      .
c .        .     .        . 9. numero de la fonction associee si champ .
c .        .     .        .    aux noeuds par element ou points de Gaus.
c .        .     .        . 10. numero HOMARD du champ associe         .
c .        .     .        . 11. type interpolation                     .
c .        .     .        .       0, si automatique                    .
c .        .     .        .       1 si degre 1, 2 si degre 2,          .
c .        .     .        .       3 si iso-P2                          .
c .        .     .        . 12. type de champ edfl64/edin64            .
c .        .     .        . 21-nbinec. type des supports associes      .
c . nofonc . e   .3*nbfonc. description des fonctions en caracteres    .
c .        .     .        . 1. nom de l'objet profil, blanc sinon      .
c .        .     .        . 2. nom de l'objet fonction                 .
c .        .     .        . 3. nom de l'objet localisation des points  .
c .        .     .        . de Gauss, blanc sinon                      .
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
      parameter ( nompro = 'ESLSM4' )
c
#include "nblang.h"
#include "consts.h"
c
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "esutil.h"
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer nbcham, nbfonc
      integer defonc(nbinec,nbfonc)
c
      character*8 obcham(nbcham)
      character*8 nofonc(3,nbfonc)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
      integer nrocha
c
      integer adnocp, adcaen, adcare, adcaca
      integer nbcomp, nbtvch, typcha
c
      character*64 nomcha
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
#include "impr03.h"
c
#include "esimpr.h"
c
c====
c 2. lecture des valeurs, champ par champ
c====
c
      if ( codret.eq.0 ) then
c
      do 20 , nrocha = 1 , nbcham
c
c 2.1. ==> informations sur la structure decrivant le champ
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '+++++++++++++++++++++++++++++++++++++++++++++'
        write (ulsort,texte(langue,37)) nompro, nrocha
        write (ulsort,texte(langue,51)) obcham(nrocha)
        call gmprsx (nompro, obcham(nrocha)//'.Cham_Ent' )
      write (ulsort,texte(langue,3)) 'UTCACH', nompro
#endif
c
        call utcach ( obcham(nrocha),
     >                nomcha,
     >                nbcomp, nbtvch, typcha,
     >                adnocp, adcaen, adcare, adcaca,
     >                ulsort, langue, codret )
cgn      call gmprsx (nompro, obcham(nrocha)//'.Cham_Ent' )
cgn      call gmprsx (nompro, obcham(nrocha)//'.Cham_Car' )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'Retour de utcach avec :'
        write (ulsort,texte(langue,32)) nomcha
        write (ulsort,texte(langue,111)) nbtvch
        write (ulsort,90002) 'nbcomp', nbcomp
        write (ulsort,90002) 'typcha', typcha
        write (ulsort,90002) 'codret', codret
#endif
c
        endif
c
c 2.2. ==> on passe en revue tous les tableaux du champ
c
        if ( nbtvch.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        do 2222 , iaux = 1 , nbfonc
          write (ulsort,*) '.. fonction numero', iaux,' /', nbfonc
          write (ulsort,2220) (defonc(jaux,iaux),jaux=1,nbinec)
          write (ulsort,2221) (nofonc(jaux,iaux),jaux=1,3)
 2222   continue
 2220 format(11i10)
 2221 format(5(a8,1x))
        endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLCH4', nompro
#endif
          iaux = nrocha
          call eslch4 ( idfmed,
     >                  iaux, nomcha, nbcomp, nbtvch,
     >                  obcham(nrocha), imem(adcaen), smem(adcaca),
     >                  nbfonc, defonc, nofonc,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        call gmprsx (nompro, obcham(nrocha) )
        call gmprsx (nompro, obcham(nrocha)//'.Nom_Comp' )
        call gmprsx (nompro, obcham(nrocha)//'.Cham_Ent' )
        call gmprsx (nompro, obcham(nrocha)//'.Cham_Ree' )
        call gmprsx (nompro, obcham(nrocha)//'.Cham_Car' )
        endif
#endif
c
   20 continue
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
