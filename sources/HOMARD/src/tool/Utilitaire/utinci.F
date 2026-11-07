      subroutine utinci ( ulsort, langue, codret )
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
c    UTilitaire - INitialisation des Communs des Interfaces
c    --           --                 -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'UTINCI' )
c
#include "referx.h"
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "refere.h"
#include "refert.h"
c
#include "rfamed.h"
c
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      character*6 saux06
c
      integer iindef
      double precision rindef
      character*8 sindef
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
      texte(1,4) = '(''Le type maximum pour HOMARD vaut :'',i6)'
      texte(1,5) = '(''mais la variable '',a6,'' vaut :'',i6)'
c
      texte(2,4) = '(''Maximum type for HOMARD is :'',i6)'
      texte(2,5) = '(''but variable '',a6,'' is :'',i6)'
c
      codret = 0
c
c====
c 2. communs pour les interfaces
c====
c
c 2.1. ==> prealable : les valeurs indefinies
c
      call dmindf ( iindef, rindef, sindef )
c
c====
c 3. generalites sur les elements de reference
c====
c
c 3.1. ==> type HOMARD des differents elements
c          on a interet a les prendre continus de 0 a themax, pour
c          minimiser l'occupation en memoire.
c          mais pour deboguer, il est interessant de varier ces chiffres
c          il faut alors verifier qu'on ne depasse pas le maximum
c          qui est defini par un parameter.
c          attention, il faut utiliser en debug toutes les bibliotheques
c          ou apparait tehmax
c
      tyhnoe = -1
      tyhmpo = 0
      tyhse1 = 1
      tyhse2 = 2
      tyhtr1 = 3
      tyhtr2 = 4
      tyhte1 = 5
      tyhte2 = 6
      tyhqu1 = 7
      tyhqu2 = 8
      tyhpy1 = 9
      tyhpy2 = 10
      tyhhe1 = 11
      tyhhe2 = 12
      tyhpe1 = 13
      tyhpe2 = 14
      tyhtr3 = 15
      tyhqu3 = 16
      tyhhe3 = 17
c
#ifdef _DEBUG_HOMARD_
      tyhmpo = 7
      tyhse1 = 14
      tyhse2 = 17
      tyhtr1 = 28
      tyhtr2 = 21
      tyhte1 = 33
      tyhte2 = 30
c
      tyhmpo = 6
      tyhse1 = 1
      tyhse2 = 4
      tyhtr1 = 2
      tyhtr2 = 5
      tyhte1 = 3
      tyhte2 = 0
      tyhqu1 = 7
      tyhqu2 = 8
c
      tyhmpo = 0
      tyhse1 = 1
      tyhse2 = 2
      tyhtr1 = 3
      tyhtr2 = 4
      tyhte1 = 5
      tyhte2 = 6
      tyhqu1 = 7
      tyhqu2 = 8
#endif
c
      jaux = 0
      if ( tyhmpo.gt.tehmax ) then
        jaux = 2
        iaux = tyhmpo
        saux06 = 'tyhmpo'
      endif
      if ( tyhse1.gt.tehmax ) then
        jaux = 2
        iaux = tyhse1
        saux06 = 'tyhse1'
      endif
      if ( tyhse2.gt.tehmax ) then
        jaux = 2
        iaux = tyhse2
        saux06 = 'tyhse2'
      endif
      if ( tyhtr1.gt.tehmax ) then
        jaux = 2
        iaux = tyhtr1
        saux06 = 'tyhtr1'
      endif
      if ( tyhtr2.gt.tehmax ) then
        jaux = 2
        iaux = tyhtr2
        saux06 = 'tyhtr2'
      endif
      if ( tyhtr3.gt.tehmax ) then
        jaux = 2
        iaux = tyhtr3
        saux06 = 'tyhtr3'
      endif
      if ( tyhte1.gt.tehmax ) then
        jaux = 2
        iaux = tyhte1
        saux06 = 'tyhte1'
      endif
      if ( tyhte2.gt.tehmax ) then
        jaux = 2
        iaux = tyhte2
        saux06 = 'tyhte2'
      endif
      if ( tyhqu1.gt.tehmax ) then
        jaux = 2
        iaux = tyhqu1
        saux06 = 'tyhqu1'
      endif
      if ( tyhqu2.gt.tehmax ) then
        jaux = 2
        iaux = tyhqu2
        saux06 = 'tyhqu2'
      endif
      if ( tyhqu3.gt.tehmax ) then
        jaux = 2
        iaux = tyhqu3
        saux06 = 'tyhqu3'
      endif
      if ( tyhpy1.gt.tehmax ) then
        jaux = 2
        iaux = tyhpy1
        saux06 = 'tyhpy1'
      endif
      if ( tyhpy2.gt.tehmax ) then
        jaux = 2
        iaux = tyhpy2
        saux06 = 'tyhpy2'
      endif
      if ( tyhpe1.gt.tehmax ) then
        jaux = 2
        iaux = tyhpe1
        saux06 = 'tyhpe1'
      endif
      if ( tyhpe2.gt.tehmax ) then
        jaux = 2
        iaux = tyhpe2
        saux06 = 'tyhpe2'
      endif
      if ( tyhhe1.gt.tehmax ) then
        jaux = 2
        iaux = tyhhe1
        saux06 = 'tyhhe1'
      endif
      if ( tyhhe2.gt.tehmax ) then
        jaux = 2
        iaux = tyhhe2
        saux06 = 'tyhhe2'
      endif
      if ( tyhhe3.gt.tehmax ) then
        jaux = 2
        iaux = tyhhe3
        saux06 = 'tyhhe3'
      endif
      if ( jaux.ne.0 ) then
        write (ulsort,texte(langue,4)) tehmax
        write (ulsort,texte(langue,5)) saux06, iaux
        codret = 1
      endif
c
c 3.2. ==> prealable
c tyeref : precise le type d'element en fonction du type de reference
c          0 : standard HOMARD,
c          1 : possible en fonction du type de travail
c          2 : toujours interdit
c nbnref : donne le nombre de noeuds en fonction du type de reference ;
c          1er champ : type HOMARD de l'element de reference
c          2eme champ : 1 : sommets
c                       2 : sommets + milieux d'aretes
c                       3 : total (sommets+milieux+internes)
c nbaref : donne le nombre d'aretes en fonction du type de reference
c nasref : donne le nombre d'aretes reliees a chaque sommet, sans
c          se preoccuper d'orientation, en fonction du type
c nfaref : donne le nombre de faces qui s'appuient sur chaque arete
c          sans se preoccuper d'orientation
c nafref : donne le nombre d'aretes de chaque face
c          1er champ : type HOMARD de l'element de reference
c          2eme champ : numero local de la face envisagee
c defref : pour chaque arete de chaque face, donne le numero local
c          de l'arete dans la description de l'element, sans se
c          preoccuper d'orientation
c          1er champ : type HOMARD de l'element de reference
c          2eme champ : numero local de la face envisagee
c          3eme champ : 1, 2, 3 et 4 pour chaque arete
c faaref : donne le numero local de la face s'appuyant sur une arete
c          1er champ : type HOMARD de l'element de reference
c          2eme champ : numero local de l'arete concernee
c          3eme champ : rang de la face envisagee
c
      do 32 , iaux = 0 , tehmax
        tyeref(iaux) = iindef
        nbnref(iaux,1) = iindef
        nbnref(iaux,2) = iindef
        nbnref(iaux,3) = iindef
        nbaref(iaux) = iindef
        nasref(iaux) = iindef
        nfaref(iaux) = iindef
        do 321 , jaux = 1 , 6
          nafref(iaux,jaux) = iindef
          defref(iaux,jaux,1) = iindef
          defref(iaux,jaux,2) = iindef
          defref(iaux,jaux,3) = iindef
          defref(iaux,jaux,4) = iindef
  321   continue
        do 322 , jaux = 1, 12
          faaref(iaux,jaux,1) = iindef
          faaref(iaux,jaux,2) = iindef
  322   continue
   32 continue
c
c 3.3. ==> description d'une maille-point
c
      tyeref(tyhmpo) = 0
      nbnref(tyhmpo,1) = 1
      nbnref(tyhmpo,2) = nbnref(tyhmpo,1)
      nbnref(tyhmpo,3) = nbnref(tyhmpo,2)
      nbaref(tyhmpo) = 0
      nasref(tyhmpo) = 0
      nfaref(tyhmpo) = 0
c
c 3.4. ==> description d'un segment
c
c 3.4.1. ==> lineaire
c
      tyeref(tyhse1) = 0
      nbnref(tyhse1,1) = 2
      nbnref(tyhse1,2) = nbnref(tyhse1,1)
      nbnref(tyhse1,3) = nbnref(tyhse1,2)
      nbaref(tyhse1) = 1
      nasref(tyhse1) = 1
      nfaref(tyhse1) = 0
c
c 3.4.2. ==> quadratique
c
      tyeref(tyhse2) = tyeref(tyhse1)
      nbnref(tyhse2,1) = nbnref(tyhse1,1)
      nbnref(tyhse2,2) = 3
      nbnref(tyhse2,3) = nbnref(tyhse2,2)
      nbaref(tyhse2) = nbaref(tyhse1)
      nasref(tyhse2) = nasref(tyhse1)
      nfaref(tyhse2) = nfaref(tyhse1)
c
c 3.5. ==> description d'un triangle
c
c 3.5.1. ==> lineaire
c
      tyeref(tyhtr1) = 0
      nbnref(tyhtr1,1) = 3
      nbnref(tyhtr1,2) = nbnref(tyhtr1,1)
      nbnref(tyhtr1,3) = nbnref(tyhtr1,2)
      nbaref(tyhtr1) = 3
      nasref(tyhtr1) = 2
      nfaref(tyhtr1) = 1
c
      nafref(tyhtr1,1) = 3
      defref(tyhtr1,1,1) = 1
      defref(tyhtr1,1,2) = 2
      defref(tyhtr1,1,3) = 3
c
      faaref(tyhtr1,1,1) = 1
      faaref(tyhtr1,2,1) = 1
      faaref(tyhtr1,3,1) = 1
c
c 3.5.2. ==> complements pour le quadratique
c
      tyeref(tyhtr2) = tyeref(tyhtr1)
      nbnref(tyhtr2,1) = nbnref(tyhtr1,1)
      nbnref(tyhtr2,2) = 6
      nbnref(tyhtr2,3) = nbnref(tyhtr2,2)
      nbaref(tyhtr2) = nbaref(tyhtr1)
      nasref(tyhtr2) = nasref(tyhtr1)
      nfaref(tyhtr2) = nfaref(tyhtr1)
c
c 3.5.3. ==> complements pour le quadratique etendu
c
      tyeref(tyhtr3) = tyeref(tyhtr1)
      nbnref(tyhtr3,1) = nbnref(tyhtr2,1)
      nbnref(tyhtr3,2) = nbnref(tyhtr2,2)
      nbnref(tyhtr3,3) = 7
      nbaref(tyhtr3) = nbaref(tyhtr1)
      nasref(tyhtr3) = nasref(tyhtr1)
      nfaref(tyhtr3) = nfaref(tyhtr1)
c
c 3.6. ==> description d'un quadrangle
c
c 3.6.1. ==> lineaire
c
      tyeref(tyhqu1) = 0
      nbnref(tyhqu1,1) = 4
      nbnref(tyhqu1,2) = nbnref(tyhqu1,1)
      nbnref(tyhqu1,3) = nbnref(tyhqu1,2)
      nbaref(tyhqu1) = 4
      nasref(tyhqu1) = 2
      nfaref(tyhqu1) = 1
c
      nafref(tyhqu1,1) = 4
      defref(tyhqu1,1,1) = 1
      defref(tyhqu1,1,2) = 2
      defref(tyhqu1,1,3) = 3
      defref(tyhqu1,1,4) = 4
c
      faaref(tyhqu1,1,1) = 1
      faaref(tyhqu1,2,1) = 1
      faaref(tyhqu1,3,1) = 1
      faaref(tyhqu1,4,1) = 1
c
c 3.6.2. ==> complements pour le quadratique
c
      tyeref(tyhqu2) = tyeref(tyhqu1)
      nbnref(tyhqu2,1) = nbnref(tyhqu1,1)
      nbnref(tyhqu2,2) = 8
      nbnref(tyhqu2,3) = nbnref(tyhqu2,2)
      nbaref(tyhqu2) = nbaref(tyhqu1)
      nasref(tyhqu2) = nasref(tyhqu1)
      nfaref(tyhqu2) = nfaref(tyhqu1)
c
c 3.6.3. ==> complements pour le quadratique etendu
c
      tyeref(tyhqu3) = tyeref(tyhqu1)
      nbnref(tyhqu3,1) = nbnref(tyhqu2,1)
      nbnref(tyhqu3,2) = nbnref(tyhqu2,2)
      nbnref(tyhqu3,3) = 9
      nbaref(tyhqu3) = nbaref(tyhqu1)
      nasref(tyhqu3) = nasref(tyhqu1)
      nfaref(tyhqu3) = nfaref(tyhqu1)
c
c 3.7. ==> description d'un tetraedre
c
c 3.7.1. ==> lineaire
c
      tyeref(tyhte1) = 0
      nbnref(tyhte1,1) = 4
      nbnref(tyhte1,2) = nbnref(tyhte1,1)
      nbnref(tyhte1,2) = nbnref(tyhte1,1)
      nbnref(tyhte1,3) = nbnref(tyhte1,2)
      nbaref(tyhte1) = 6
      nasref(tyhte1) = 3
      nfaref(tyhte1) = 2
c
      nafref(tyhte1,1) = 3
      defref(tyhte1,1,1) = 4
      defref(tyhte1,1,2) = 5
      defref(tyhte1,1,3) = 6
      nafref(tyhte1,2) = 3
      defref(tyhte1,2,1) = 2
      defref(tyhte1,2,2) = 3
      defref(tyhte1,2,3) = 6
      nafref(tyhte1,3) = 3
      defref(tyhte1,3,1) = 1
      defref(tyhte1,3,2) = 3
      defref(tyhte1,3,3) = 5
      nafref(tyhte1,4) = 3
      defref(tyhte1,4,1) = 1
      defref(tyhte1,4,2) = 2
      defref(tyhte1,4,3) = 4
c
      faaref(tyhte1,1,1) = 3
      faaref(tyhte1,1,2) = 4
      faaref(tyhte1,2,1) = 2
      faaref(tyhte1,2,2) = 4
      faaref(tyhte1,3,1) = 2
      faaref(tyhte1,3,2) = 3
      faaref(tyhte1,4,1) = 1
      faaref(tyhte1,4,2) = 4
      faaref(tyhte1,5,1) = 1
      faaref(tyhte1,5,2) = 3
      faaref(tyhte1,6,1) = 1
      faaref(tyhte1,6,2) = 2
c
c 3.7.2. ==> complements pour le quadratique
c
      tyeref(tyhte2) = tyeref(tyhte1)
      nbnref(tyhte2,1) = nbnref(tyhte1,1)
      nbnref(tyhte2,2) = 10
      nbnref(tyhte2,3) = nbnref(tyhte2,2)
      nbaref(tyhte2) = nbaref(tyhte1)
      nasref(tyhte2) = nasref(tyhte1)
      nfaref(tyhte2) = nfaref(tyhte1)
c
c 3.8. ==> description d'une pyramide
c
c 3.8.1. ==> lineaire
c
      tyeref(tyhpy1) = 1
      nbnref(tyhpy1,1) = 5
      nbnref(tyhpy1,2) = nbnref(tyhpy1,1)
      nbnref(tyhpy1,3) = nbnref(tyhpy1,2)
      nbaref(tyhpy1) = 8
      nasref(tyhpy1) = 3
      nfaref(tyhpy1) = 2
c
      nafref(tyhpy1,1) = 3
      defref(tyhpy1,1,1) = 1
      defref(tyhpy1,1,2) = 2
      defref(tyhpy1,1,3) = 5
      nafref(tyhpy1,2) = 3
      defref(tyhpy1,2,1) = 2
      defref(tyhpy1,2,2) = 3
      defref(tyhpy1,2,3) = 6
      nafref(tyhpy1,3) = 3
      defref(tyhpy1,3,1) = 3
      defref(tyhpy1,3,2) = 4
      defref(tyhpy1,3,3) = 7
      nafref(tyhpy1,4) = 3
      defref(tyhpy1,4,1) = 1
      defref(tyhpy1,4,2) = 8
      defref(tyhpy1,4,3) = 4
      nafref(tyhpy1,5) = 4
      defref(tyhpy1,5,1) = 5
      defref(tyhpy1,5,2) = 6
      defref(tyhpy1,5,3) = 7
      defref(tyhpy1,5,4) = 8
c
      faaref(tyhpy1,1,1) = 4
      faaref(tyhpy1,1,2) = 1
      faaref(tyhpy1,2,1) = 1
      faaref(tyhpy1,2,2) = 2
      faaref(tyhpy1,3,1) = 2
      faaref(tyhpy1,3,2) = 3
      faaref(tyhpy1,4,1) = 3
      faaref(tyhpy1,4,2) = 4
      faaref(tyhpy1,5,1) = 1
      faaref(tyhpy1,5,2) = 5
      faaref(tyhpy1,6,1) = 2
      faaref(tyhpy1,6,2) = 5
      faaref(tyhpy1,7,1) = 3
      faaref(tyhpy1,7,2) = 5
      faaref(tyhpy1,8,1) = 4
      faaref(tyhpy1,8,2) = 5
c
c 3.8.2. ==> complements pour le quadratique
c
      tyeref(tyhpy2) = tyeref(tyhpy1)
      nbnref(tyhpy2,1) = nbnref(tyhpy1,1)
      nbnref(tyhpy2,2) = 13
      nbnref(tyhpy2,3) = nbnref(tyhpy2,2)
      nbaref(tyhpy2) = nbaref(tyhpy1)
      nasref(tyhpy2) = nasref(tyhpy1)
      nfaref(tyhpy2) = nfaref(tyhpy1)
c
c 3.9. ==> description d'un hexaedre
c
c 3.9.1. ==> lineaire
c
      tyeref(tyhhe1) = 0
      nbnref(tyhhe1,1) = 8
      nbnref(tyhhe1,2) = nbnref(tyhhe1,1)
      nbnref(tyhhe1,3) = nbnref(tyhhe1,2)
      nbaref(tyhhe1) = 12
      nasref(tyhhe1) = 3
      nfaref(tyhhe1) = 2
c
      nafref(tyhhe1,1) = 4
      defref(tyhhe1,1,1) = 1
      defref(tyhhe1,1,2) = 2
      defref(tyhhe1,1,3) = 4
      defref(tyhhe1,1,4) = 3
      nafref(tyhhe1,2) = 4
      defref(tyhhe1,2,1) = 1
      defref(tyhhe1,2,2) = 6
      defref(tyhhe1,2,3) = 9
      defref(tyhhe1,2,4) = 5
      nafref(tyhhe1,3) = 4
      defref(tyhhe1,3,1) = 2
      defref(tyhhe1,3,2) = 5
      defref(tyhhe1,3,3) = 10
      defref(tyhhe1,3,4) = 7
      nafref(tyhhe1,4) = 4
      defref(tyhhe1,4,1) = 3
      defref(tyhhe1,4,2) = 8
      defref(tyhhe1,4,3) = 11
      defref(tyhhe1,4,4) = 6
      nafref(tyhhe1,5) = 4
      defref(tyhhe1,5,1) = 4
      defref(tyhhe1,5,2) = 7
      defref(tyhhe1,5,3) = 12
      defref(tyhhe1,5,4) = 8
      nafref(tyhhe1,6) = 4
      defref(tyhhe1,6,1) = 9
      defref(tyhhe1,6,2) = 11
      defref(tyhhe1,6,3) = 12
      defref(tyhhe1,6,4) = 10
c
      faaref(tyhhe1,1,1) = 1
      faaref(tyhhe1,1,2) = 2
      faaref(tyhhe1,2,1) = 1
      faaref(tyhhe1,2,2) = 3
      faaref(tyhhe1,3,1) = 1
      faaref(tyhhe1,3,2) = 4
      faaref(tyhhe1,4,1) = 1
      faaref(tyhhe1,4,2) = 5
      faaref(tyhhe1,5,1) = 2
      faaref(tyhhe1,5,2) = 3
      faaref(tyhhe1,6,1) = 2
      faaref(tyhhe1,6,2) = 4
      faaref(tyhhe1,7,1) = 3
      faaref(tyhhe1,7,2) = 5
      faaref(tyhhe1,8,1) = 4
      faaref(tyhhe1,8,2) = 5
      faaref(tyhhe1,9,1) = 2
      faaref(tyhhe1,9,2) = 6
      faaref(tyhhe1,10,1) = 3
      faaref(tyhhe1,10,2) = 6
      faaref(tyhhe1,11,1) = 4
      faaref(tyhhe1,11,2) = 6
      faaref(tyhhe1,12,1) = 5
      faaref(tyhhe1,12,2) = 6
c
c 3.9.2. ==> complements pour le quadratique
c
      tyeref(tyhhe2) = tyeref(tyhhe1)
      nbnref(tyhhe2,1) = nbnref(tyhhe1,1)
      nbnref(tyhhe2,2) = 20
      nbnref(tyhhe2,3) = nbnref(tyhhe2,2)
      nbaref(tyhhe2) = nbaref(tyhhe1)
      nasref(tyhhe2) = nasref(tyhhe1)
      nfaref(tyhhe2) = nfaref(tyhhe1)
c
c 3.9.3. ==> complements pour le quadratique etendu
c
      tyeref(tyhhe3) = tyeref(tyhhe1)
      nbnref(tyhhe3,1) = nbnref(tyhhe2,1)
      nbnref(tyhhe3,2) = nbnref(tyhhe2,2)
      nbnref(tyhhe3,3) = 27
      nbaref(tyhhe3) = nbaref(tyhhe1)
      nasref(tyhhe3) = nasref(tyhhe1)
      nfaref(tyhhe3) = nfaref(tyhhe1)
c
c 3.10. ==> description d'un pentaedre
c 3.10.1. ==> lineaire
c
      tyeref(tyhpe1) = 0
      nbnref(tyhpe1,1) = 6
      nbnref(tyhpe1,2) = nbnref(tyhpe1,1)
      nbnref(tyhpe1,3) = nbnref(tyhpe1,2)
      nbaref(tyhpe1) = 9
      nasref(tyhpe1) = 3
      nfaref(tyhpe1) = 2
c
      nafref(tyhpe1,1) = 3
      defref(tyhpe1,1,1) = 1
      defref(tyhpe1,1,2) = 2
      defref(tyhpe1,1,3) = 3
      nafref(tyhpe1,2) = 3
      defref(tyhpe1,2,1) = 4
      defref(tyhpe1,2,2) = 6
      defref(tyhpe1,2,3) = 5
      nafref(tyhpe1,3) = 4
      defref(tyhpe1,3,1) = 1
      defref(tyhpe1,3,2) = 9
      defref(tyhpe1,3,3) = 4
      defref(tyhpe1,3,4) = 7
      nafref(tyhpe1,4) = 4
      defref(tyhpe1,4,1) = 2
      defref(tyhpe1,4,2) = 7
      defref(tyhpe1,4,3) = 5
      defref(tyhpe1,4,4) = 8
      nafref(tyhpe1,5) = 4
      defref(tyhpe1,5,1) = 3
      defref(tyhpe1,5,2) = 8
      defref(tyhpe1,5,3) = 6
      defref(tyhpe1,5,4) = 9
c
      faaref(tyhpe1,1,1) = 1
      faaref(tyhpe1,1,2) = 3
      faaref(tyhpe1,2,1) = 1
      faaref(tyhpe1,2,2) = 4
      faaref(tyhpe1,3,1) = 1
      faaref(tyhpe1,3,2) = 5
      faaref(tyhpe1,4,1) = 2
      faaref(tyhpe1,4,2) = 3
      faaref(tyhpe1,5,1) = 2
      faaref(tyhpe1,5,2) = 4
      faaref(tyhpe1,6,1) = 2
      faaref(tyhpe1,6,2) = 5
      faaref(tyhpe1,7,1) = 3
      faaref(tyhpe1,7,2) = 4
      faaref(tyhpe1,8,1) = 4
      faaref(tyhpe1,8,2) = 5
      faaref(tyhpe1,9,1) = 5
      faaref(tyhpe1,9,2) = 3
c
c 3.10.2. ==> complements pour le quadratique
c
      tyeref(tyhpe2) = tyeref(tyhpe1)
      nbnref(tyhpe2,1) = nbnref(tyhpe1,1)
      nbnref(tyhpe2,2) = 15
      nbnref(tyhpe2,3) = nbnref(tyhpe2,2)
      nbaref(tyhpe2) = nbaref(tyhpe1)
      nasref(tyhpe2) = nasref(tyhpe1)
      nfaref(tyhpe2) = nfaref(tyhpe1)
c
c 3.11. ==> En quadratique
c           On en fait trop mais cela simpilife l'ecriture
c
      do 3111 , iaux = 1, 6
c
        nafref(tyhtr2,iaux) = nafref(tyhtr1,iaux)
        defref(tyhtr2,iaux,1) = defref(tyhtr1,iaux,1)
        defref(tyhtr2,iaux,2) = defref(tyhtr1,iaux,2)
        defref(tyhtr2,iaux,3) = defref(tyhtr1,iaux,3)
c
        nafref(tyhtr3,iaux) = nafref(tyhtr1,iaux)
        defref(tyhtr3,iaux,1) = defref(tyhtr1,iaux,1)
        defref(tyhtr3,iaux,2) = defref(tyhtr1,iaux,2)
        defref(tyhtr3,iaux,3) = defref(tyhtr1,iaux,3)
c
        nafref(tyhqu2,iaux) = nafref(tyhqu1,iaux)
        defref(tyhqu2,iaux,1) = defref(tyhqu1,iaux,1)
        defref(tyhqu2,iaux,2) = defref(tyhqu1,iaux,2)
        defref(tyhqu2,iaux,3) = defref(tyhqu1,iaux,3)
        defref(tyhqu2,iaux,4) = defref(tyhqu1,iaux,4)
c
        nafref(tyhqu3,iaux) = nafref(tyhqu1,iaux)
        defref(tyhqu3,iaux,1) = defref(tyhqu1,iaux,1)
        defref(tyhqu3,iaux,2) = defref(tyhqu1,iaux,2)
        defref(tyhqu3,iaux,3) = defref(tyhqu1,iaux,3)
        defref(tyhqu3,iaux,4) = defref(tyhqu1,iaux,4)
c
        nafref(tyhte2,iaux) = nafref(tyhte1,iaux)
        defref(tyhte2,iaux,1) = defref(tyhte1,iaux,1)
        defref(tyhte2,iaux,2) = defref(tyhte1,iaux,2)
        defref(tyhte2,iaux,3) = defref(tyhte1,iaux,3)
c
        nafref(tyhpy2,iaux) = nafref(tyhpy1,iaux)
        defref(tyhpy2,iaux,1) = defref(tyhpy1,iaux,1)
        defref(tyhpy2,iaux,2) = defref(tyhpy1,iaux,2)
        defref(tyhpy2,iaux,3) = defref(tyhpy1,iaux,3)
        defref(tyhpy2,iaux,4) = defref(tyhpy1,iaux,4)
c
        nafref(tyhhe2,iaux) = nafref(tyhhe1,iaux)
        defref(tyhhe2,iaux,1) = defref(tyhhe1,iaux,1)
        defref(tyhhe2,iaux,2) = defref(tyhhe1,iaux,2)
        defref(tyhhe2,iaux,3) = defref(tyhhe1,iaux,3)
        defref(tyhhe2,iaux,4) = defref(tyhhe1,iaux,4)
c
        nafref(tyhhe3,iaux) = nafref(tyhhe1,iaux)
        defref(tyhhe3,iaux,1) = defref(tyhhe1,iaux,1)
        defref(tyhhe3,iaux,2) = defref(tyhhe1,iaux,2)
        defref(tyhhe3,iaux,3) = defref(tyhhe1,iaux,3)
        defref(tyhhe3,iaux,4) = defref(tyhhe1,iaux,4)
c
        nafref(tyhpe2,iaux) = nafref(tyhpe1,iaux)
        defref(tyhpe2,iaux,1) = defref(tyhpe1,iaux,1)
        defref(tyhpe2,iaux,2) = defref(tyhpe1,iaux,2)
        defref(tyhpe2,iaux,3) = defref(tyhpe1,iaux,3)
        defref(tyhpe2,iaux,4) = defref(tyhpe1,iaux,4)
c
 3111 continue
c
      do 3112 , iaux = 1, 12
c
        faaref(tyhtr2,iaux,1) = faaref(tyhtr1,iaux,1)
        faaref(tyhtr2,iaux,2) = faaref(tyhtr1,iaux,2)
c
        faaref(tyhtr3,iaux,1) = faaref(tyhtr1,iaux,1)
        faaref(tyhtr3,iaux,2) = faaref(tyhtr1,iaux,2)
c
        faaref(tyhqu2,iaux,1) = faaref(tyhqu1,iaux,1)
        faaref(tyhqu2,iaux,2) = faaref(tyhqu1,iaux,2)
c
        faaref(tyhqu3,iaux,1) = faaref(tyhqu1,iaux,1)
        faaref(tyhqu3,iaux,2) = faaref(tyhqu1,iaux,2)
c
        faaref(tyhte2,iaux,1) = faaref(tyhte1,iaux,1)
        faaref(tyhte2,iaux,2) = faaref(tyhte1,iaux,2)
c
        faaref(tyhpy2,iaux,1) = faaref(tyhpy1,iaux,1)
        faaref(tyhpy2,iaux,2) = faaref(tyhpy1,iaux,2)
c
        faaref(tyhhe2,iaux,1) = faaref(tyhhe1,iaux,1)
        faaref(tyhhe2,iaux,2) = faaref(tyhhe1,iaux,2)
c
        faaref(tyhhe3,iaux,1) = faaref(tyhhe1,iaux,1)
        faaref(tyhhe3,iaux,2) = faaref(tyhhe1,iaux,2)
c
        faaref(tyhpe2,iaux,1) = faaref(tyhpe1,iaux,1)
        faaref(tyhpe2,iaux,2) = faaref(tyhpe1,iaux,2)
c
 3112 continue
c
c====
c 4. types HOMARD associe au format commun MED
c====
c
c 4.0. ==> initialisation des types generaux
c
      do 40 , iaux = 0 , nbtmed
        mednnm(iaux) = iindef
        medtrf(iaux) = iindef
        medt12(iaux) = iindef
   40 continue
c
c 4.1. ==> description du sommet
c
      medtrf(0) = tyhnoe
      medt12(0) = 0
c
c 4.2. ==> description de la maille-point
c
      mednnm(edpoi1) = 1
      medtrf(edpoi1) = tyhmpo
      medt12(edpoi1) = edpoi1
c
c 4.3. ==> description du segment
c
c 4.3.1. ==> lineaire
c
      mednnm(edseg2) = 2
      medtrf(edseg2) = tyhse1
      medt12(edseg2) = edseg3
c
c 4.3.2. ==> quadratique
c
      mednnm(edseg3) = 3
      medtrf(edseg3) = tyhse2
      medt12(edseg3) = edseg2
c
c 4.4. ==> description du triangle
c
c 4.4.1. ==> lineaire
c
      mednnm(edtri3) = 3
      medtrf(edtri3) = tyhtr1
      medt12(edtri3) = edtri6
c
c 4.4.2. ==> quadratique
c
      mednnm(edtri6) = 6
      medtrf(edtri6) = tyhtr2
      medt12(edtri6) = edtri3
c
c 4.4.3. ==> quadratique etendu
c
      mednnm(edtri7) = 7
      medtrf(edtri7) = tyhtr3
      medt12(edtri7) = edtri3
c
c 4.5. ==> description du quadrangle
c
c 4.5.1. ==> lineaire
c
      mednnm(edqua4) = 4
      medtrf(edqua4) = tyhqu1
      medt12(edqua4) = edqua8
c
c 4.5.2. ==> quadratique
c
      mednnm(edqua8) = 8
      medtrf(edqua8) = tyhqu2
      medt12(edqua8) = edqua4
c
c 4.5.3. ==> quadratique etendu
c
      mednnm(edqua9) = 9
      medtrf(edqua9) = tyhqu3
      medt12(edqua9) = edqua4
c
c 4.6. ==> description du tetraedre
c
c 4.6.1. ==> lineaire
c
      mednnm(edtet4) = 4
      medtrf(edtet4) = tyhte1
      medt12(edtet4) = edte10
c
c 4.6.2. ==> quadratique
c
      mednnm(edte10) = 10
      medtrf(edte10) = tyhte2
      medt12(edte10) = edtet4
c
c 4.7. ==> description de la pyramide
c
c 4.7.1. ==> lineaire
c
      mednnm(edpyr5) = 5
      medtrf(edpyr5) = tyhpy1
      medt12(edpyr5) = edpy13
c
c 4.7.2. ==> quadratique
c
      mednnm(edpy13) = 13
      medtrf(edpy13) = tyhpy2
      medt12(edpy13) = edpyr5
c
c 4.8. ==> description de l'hexaedre
c
c 4.8.1. ==> lineaire
c
      mednnm(edhex8) = 8
      medtrf(edhex8) = tyhhe1
      medt12(edhex8) = edhe20
c
c 4.8.2. ==> quadratique
c
      mednnm(edhe20) = 20
      medtrf(edhe20) = tyhhe2
      medt12(edhe20) = edhex8
c
c 4.8.2. ==> quadratique etendu
c
      mednnm(edhe27) = 27
      medtrf(edhe27) = tyhhe3
      medt12(edhe27) = edhex8
c
c 4.9. ==> description du pentaedre
c
c 4.9.1. ==> lineaire
c
      mednnm(edpen6) = 6
      medtrf(edpen6) = tyhpe1
      medt12(edpen6) = edpe15
c
c 4.9.2. ==> quadratique
c
      mednnm(edpe15) = 15
      medtrf(edpe15) = tyhpe2
      medt12(edpe15) = edpen6
c
c====
c 5. description pour une connectivite a la med
c====
c
c 5.1. ==> prealable
c
      do 51 , iaux = 0 , tehmax
        do 511 , jaux = 1 , 10
          arsmed(iaux,jaux,1) = iindef
          arsmed(iaux,jaux,2) = iindef
          arsmed(iaux,jaux,3) = iindef
          arsmed(iaux,jaux,4) = iindef
  511   continue
        do 512 , jaux = 1 , 12
          deamed(iaux,jaux,1) = iindef
          deamed(iaux,jaux,2) = iindef
          deamed(iaux,jaux,3) = iindef
  512   continue
   51 continue
c
c 5.2. ==> description de la poutre
c
c 5.2.1. ==> lineaire
c                           a1
c                  n1*-------------*n2
c
      arsmed(tyhse1,1,1) = 1
      arsmed(tyhse1,2,1) = 1
c
      deamed(tyhse1,1,1) = 1
      deamed(tyhse1,1,2) = 2
c
c 5.2.2. ==> complements pour le quadratique
c                           a1
c                  n1*------*------*n2
c                          n3
      deamed(tyhse2,1,3) = 3
c
c 5.3. ==> description du triangle
c
c 5.3.1. ==> lineaire
c                           a1
c                  n1*---------------*n2
c                     .             .
c                      .           .
c                       .         .
c                     a2 .       .  a3
c                         .     .
c                          .   .
c                           . .
c                            *
c                           n3
c
      arsmed(tyhtr1,1,1) = 1
      arsmed(tyhtr1,1,2) = 2
      arsmed(tyhtr1,2,1) = 1
      arsmed(tyhtr1,2,2) = 3
      arsmed(tyhtr1,3,1) = 2
      arsmed(tyhtr1,3,2) = 3
c
      deamed(tyhtr1,1,1) = 1
      deamed(tyhtr1,1,2) = 2
      deamed(tyhtr1,2,1) = 1
      deamed(tyhtr1,2,2) = 3
      deamed(tyhtr1,3,1) = 2
      deamed(tyhtr1,3,2) = 3
c
c 5.3.2. ==> complements pour le quadratique
c                           a1
c                  n1*-------*-------*n2
c                     .    n4       .
c                      .           .
c                       .         .
c                     a2 *n6     *n5 a3
c                         .     .
c                          .   .
c                           . .
c                            *
c                           n3
c
      deamed(tyhtr2,1,3) = 4
      deamed(tyhtr2,2,3) = 6
      deamed(tyhtr2,3,3) = 5
c
      do 532 , iaux = 1, 3
        deamed(tyhtr3,iaux,3) = deamed(tyhtr2,iaux,3)
  532 continue
c
c 5.4. ==> description du quadrangle
c
c 5.4.1. ==> lineaire
c                           a1
c                  n1*---------------*n2
c                    .               .
c                    .               .
c                    .               .
c                 a4 .               . a2
c                    .               .
c                    .               .
c                    .               .
c                  n4*---------------*n3
c                           a3
c
      arsmed(tyhqu1,1,1) = 1
      arsmed(tyhqu1,1,2) = 4
      arsmed(tyhqu1,2,1) = 2
      arsmed(tyhqu1,2,2) = 1
      arsmed(tyhqu1,3,1) = 3
      arsmed(tyhqu1,3,2) = 2
      arsmed(tyhqu1,4,1) = 4
      arsmed(tyhqu1,4,2) = 3
c
      deamed(tyhqu1,1,1) = 1
      deamed(tyhqu1,1,2) = 2
      deamed(tyhqu1,2,1) = 2
      deamed(tyhqu1,2,2) = 3
      deamed(tyhqu1,3,1) = 3
      deamed(tyhqu1,3,2) = 4
      deamed(tyhqu1,4,1) = 4
      deamed(tyhqu1,4,2) = 1
c
c 5.4.2. ==> complements pour le quadratique
c                           a1/n5
c                  n1*---------------*n2
c                    .               .
c                    .               .
c                    .               .
c              a4/n8 .               . a2/n6
c                    .               .
c                    .               .
c                    .               .
c                  n4*---------------*n3
c                           a3/n7
c
      deamed(tyhqu2,1,3) = 5
      deamed(tyhqu2,2,3) = 6
      deamed(tyhqu2,3,3) = 7
      deamed(tyhqu2,4,3) = 8
c
      do 542 , iaux = 1, 4
        deamed(tyhqu3,iaux,3) = deamed(tyhqu2,iaux,3)
  542 continue
c
c 5.5. ==> description du tetraedre
c
c 5.5.1. ==> lineaire
c                                    la face fi est opposee au sommet ni
c
c                     n1
c                     *
c                    .  ..
c                   .     . . a2
c                  .        .  .
c                 .           .   .
c             a1 .          a3  .    .  n3
c               .                 .    *
c              .                  . .   .
c             .        a4    .        .  . a6
c            .          .               . .
c           .      .                      ..
c          .  .                             .
c         *..................................*
c       n2               a5                  n4
c
      arsmed(tyhte1,1,1) = 1
      arsmed(tyhte1,1,2) = 2
      arsmed(tyhte1,1,3) = 3
      arsmed(tyhte1,2,1) = 1
      arsmed(tyhte1,2,2) = 4
      arsmed(tyhte1,2,3) = 5
      arsmed(tyhte1,3,1) = 2
      arsmed(tyhte1,3,2) = 4
      arsmed(tyhte1,3,3) = 6
      arsmed(tyhte1,4,1) = 3
      arsmed(tyhte1,4,2) = 5
      arsmed(tyhte1,4,3) = 6
c
      deamed(tyhte1,1,1) = 1
      deamed(tyhte1,1,2) = 2
      deamed(tyhte1,2,1) = 1
      deamed(tyhte1,2,2) = 3
      deamed(tyhte1,3,1) = 1
      deamed(tyhte1,3,2) = 4
      deamed(tyhte1,4,1) = 2
      deamed(tyhte1,4,2) = 3
      deamed(tyhte1,5,1) = 2
      deamed(tyhte1,5,2) = 4
      deamed(tyhte1,6,1) = 3
      deamed(tyhte1,6,2) = 4
c
c 5.5.2. ==> complements pour le quadratique
c                                    la face fi est opposee au sommet ni
c                     n1
c                     *
c                    .  ..
c                   .     . . a2
c                  .        .  *n7
c                 .           .   .
c             a1 .          a3  *    .  n3
c             n5*               n8.    *
c              .                  . .   .
c             .        a4    .        .  . a6
c            .          *n6             . *n10
c           .      .                      ..
c          .  .                             .
c         *................*.................*
c       n2              a5 n9                n4
c
c
      deamed(tyhte2,1,3) = 5
      deamed(tyhte2,2,3) = 7
      deamed(tyhte2,3,3) = 8
      deamed(tyhte2,4,3) = 6
      deamed(tyhte2,5,3) = 9
      deamed(tyhte2,6,3) = 10
c
c 5.6. ==> description de l'hexaedre
c
c 5.6.1. ==> lineaire
c
c             1                   4
c             --------------------
c            /                   /.
c           /                   / .
c          /                   /  .
c         /                   /   .
c       2 -------------------- 3  .
c         .                  .    .
c         .                  .    .
c         .    5             .    . 8
c         .                  .   /
c         .                  .  /
c         .                  . /
c         .                  ./
c         --------------------
c         6                  7
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c    . Les noeuds (5,6,7,8) sont translates de (1,2,3,4)
c    . Le triedre (1-->2,1-->5,1-->4) est direct
c
      arsmed(tyhhe1,1,1) = 1
      arsmed(tyhhe1,1,2) = 2
      arsmed(tyhhe1,1,3) = 5
      arsmed(tyhhe1,2,1) = 1
      arsmed(tyhhe1,2,2) = 3
      arsmed(tyhhe1,2,3) = 6
      arsmed(tyhhe1,3,1) = 3
      arsmed(tyhhe1,3,2) = 4
      arsmed(tyhhe1,3,3) = 8
      arsmed(tyhhe1,4,1) = 2
      arsmed(tyhhe1,4,2) = 4
      arsmed(tyhhe1,4,3) = 7
      arsmed(tyhhe1,5,1) = 5
      arsmed(tyhhe1,5,2) = 9
      arsmed(tyhhe1,5,3) = 10
      arsmed(tyhhe1,6,1) = 6
      arsmed(tyhhe1,6,2) = 9
      arsmed(tyhhe1,6,3) = 11
      arsmed(tyhhe1,7,1) = 8
      arsmed(tyhhe1,7,2) = 11
      arsmed(tyhhe1,7,3) = 12
      arsmed(tyhhe1,8,1) = 7
      arsmed(tyhhe1,8,2) = 10
      arsmed(tyhhe1,8,3) = 12
c
      deamed(tyhhe1,1,1) = 1
      deamed(tyhhe1,1,2) = 2
      deamed(tyhhe1,2,1) = 1
      deamed(tyhhe1,2,2) = 4
      deamed(tyhhe1,3,1) = 2
      deamed(tyhhe1,3,2) = 3
      deamed(tyhhe1,4,1) = 3
      deamed(tyhhe1,4,2) = 4
      deamed(tyhhe1,5,1) = 1
      deamed(tyhhe1,5,2) = 5
      deamed(tyhhe1,6,1) = 2
      deamed(tyhhe1,6,2) = 6
      deamed(tyhhe1,7,1) = 4
      deamed(tyhhe1,7,2) = 8
      deamed(tyhhe1,8,1) = 3
      deamed(tyhhe1,8,2) = 7
      deamed(tyhhe1,9,1) = 5
      deamed(tyhhe1,9,2) = 6
      deamed(tyhhe1,10,1) = 5
      deamed(tyhhe1,10,2) = 8
      deamed(tyhhe1,11,1) = 6
      deamed(tyhhe1,11,2) = 7
      deamed(tyhhe1,12,1) = 7
      deamed(tyhhe1,12,2) = 8
c
c 5.6.2. ==> complements pour le quadratique
c
c             1                   4
c             ---------12---------
c            /                   /.
c          9/                   11.
c          /                   /  .
c         /   17              /   .
c       2 ---------10---------3   20
c         .                  .    .
c         .                  .    .
c         .    5       16    .    . 8
c       18.                  .19 /
c         .  13              .  /15
c         .                  . /
c         .                  ./
c         ---------14---------
c         6                  7
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c    . Les noeuds (5,6,7,8) sont translates de (1,2,3,4)
c    . Le triedre (1-->2,1-->5,1-->4) est direct
c
      deamed(tyhhe2,1,3) = 9
      deamed(tyhhe2,2,3) = 12
      deamed(tyhhe2,3,3) = 10
      deamed(tyhhe2,4,3) = 11
      deamed(tyhhe2,5,3) = 17
      deamed(tyhhe2,6,3) = 18
      deamed(tyhhe2,7,3) = 20
      deamed(tyhhe2,8,3) = 19
      deamed(tyhhe2,9,3) = 13
      deamed(tyhhe2,10,3) = 16
      deamed(tyhhe2,11,3) = 14
      deamed(tyhhe2,12,3) = 15
c
      do 562 , iaux = 1, 12
        deamed(tyhhe3,iaux,3) = deamed(tyhhe2,iaux,3)
  562 continue
c
c 5.7. ==> Les pentaedres
c
c    . Les noeuds (1,2,3) definissent un triangle a orientation
c      vers l'exterieur
c    . Les noeuds (4,5,6,) sont translates de (1,2,3)
c
c 5.7.1. ==> Les lineaires
c      la face (n1,n2,n3) tourne vers l'exterieur
c      la face (n4,n5,n6) est translatee, donc tourne vers l'interieur
c          n3                                          n6
c           x------------------------------------------x
c          .                                          .
c         .  .                                       .  .
c        .                                          .
c       .     .                                    .     .
c      .                                          .
c     .        .                                 .        .
c    .                                          .
c n2.           .                            n5.           .
c  x------------------------------------------x
c     .          .                               .          .
c          .                                          .
c              .  .                                       .  .
c                  x------------------------------------------x
c                 n1                                          n4
c
      arsmed(tyhpe1,1,1) = 1
      arsmed(tyhpe1,1,2) = 2
      arsmed(tyhpe1,1,3) = 7
      arsmed(tyhpe1,2,1) = 1
      arsmed(tyhpe1,2,2) = 3
      arsmed(tyhpe1,2,3) = 9
      arsmed(tyhpe1,3,1) = 2
      arsmed(tyhpe1,3,2) = 3
      arsmed(tyhpe1,3,3) = 8
      arsmed(tyhpe1,4,1) = 4
      arsmed(tyhpe1,4,2) = 5
      arsmed(tyhpe1,4,3) = 7
      arsmed(tyhpe1,5,1) = 4
      arsmed(tyhpe1,5,2) = 6
      arsmed(tyhpe1,5,3) = 9
      arsmed(tyhpe1,6,1) = 5
      arsmed(tyhpe1,6,2) = 6
      arsmed(tyhpe1,6,3) = 8
c
      deamed(tyhpe1,1,1) = 1
      deamed(tyhpe1,1,2) = 2
      deamed(tyhpe1,2,1) = 1
      deamed(tyhpe1,2,2) = 3
      deamed(tyhpe1,3,1) = 2
      deamed(tyhpe1,3,2) = 3
      deamed(tyhpe1,4,1) = 4
      deamed(tyhpe1,4,2) = 5
      deamed(tyhpe1,5,1) = 4
      deamed(tyhpe1,5,2) = 6
      deamed(tyhpe1,6,1) = 5
      deamed(tyhpe1,6,2) = 6
      deamed(tyhpe1,7,1) = 1
      deamed(tyhpe1,7,2) = 4
      deamed(tyhpe1,8,1) = 3
      deamed(tyhpe1,8,2) = 6
      deamed(tyhpe1,9,1) = 2
      deamed(tyhpe1,9,2) = 5
c
c 5.7.2  Les quadratiques
c      la face (n1,n2,n3) tourne vers l'exterieur
c      la face (n4,n5,n6) est translatee, donc tourne vers l'interieur
c          n3                      n15                 n6
c           x------------------------------------------x
c          .                                          .
c         .  .                                       .  .
c        .                                          .
c     n8.     .                                 n11.     .
c      .                                          .
c     .        .                                 .        .
c    .          n9                              .           n12
c n2.           .          n14               n5.           .
c  x------------------------------------------x
c     .          .                               .          .
c          .                                      n10 .
c              .  .                                       .  .
c        n7        x------------------------------------------x
c                 n1                      n13                 n4
c
      deamed(tyhpe2,1,3) = 7
      deamed(tyhpe2,2,3) = 9
      deamed(tyhpe2,3,3) = 8
      deamed(tyhpe2,4,3) = 10
      deamed(tyhpe2,5,3) = 12
      deamed(tyhpe2,6,3) = 11
      deamed(tyhpe2,7,3) = 13
      deamed(tyhpe2,8,3) = 15
      deamed(tyhpe2,9,3) = 14
c
c 5.8. ==> description de la pyramide
c
c 5.8.1. ==> lineaire
c
c       1 ----------------- 2
c         . .           . .
c         .   .       .   .
c         .     .   .     .
c         .       . 5     .  Ici le noeud 5 est au-dessus
c         .     .   .     .
c         .   .       .   .
c         . .           . .
c         -----------------
c         4                3
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c    . Le triedre (1-->2,1-->4,1-->5) est direct
c
      arsmed(tyhpy1,1,1) = 1
      arsmed(tyhpy1,1,2) = 5
      arsmed(tyhpy1,1,3) = 8
      arsmed(tyhpy1,2,1) = 4
      arsmed(tyhpy1,2,2) = 7
      arsmed(tyhpy1,2,3) = 8
      arsmed(tyhpy1,3,1) = 3
      arsmed(tyhpy1,3,2) = 6
      arsmed(tyhpy1,3,3) = 7
      arsmed(tyhpy1,4,1) = 2
      arsmed(tyhpy1,4,2) = 5
      arsmed(tyhpy1,4,3) = 6
      arsmed(tyhpy1,5,1) = 1
      arsmed(tyhpy1,5,2) = 2
      arsmed(tyhpy1,5,3) = 3
      arsmed(tyhpy1,5,4) = 4
c
      deamed(tyhpy1,1,1) = 1
      deamed(tyhpy1,1,2) = 5
      deamed(tyhpy1,2,1) = 4
      deamed(tyhpy1,2,2) = 5
      deamed(tyhpy1,3,1) = 3
      deamed(tyhpy1,3,2) = 5
      deamed(tyhpy1,4,1) = 2
      deamed(tyhpy1,4,2) = 5
      deamed(tyhpy1,5,1) = 1
      deamed(tyhpy1,5,2) = 4
      deamed(tyhpy1,6,1) = 3
      deamed(tyhpy1,6,2) = 4
      deamed(tyhpy1,7,1) = 2
      deamed(tyhpy1,7,2) = 3
      deamed(tyhpy1,8,1) = 1
      deamed(tyhpy1,8,2) = 2
c
c 5.8.2. ==> complements pour le quadratique
c
c       1 ----------------- 2
c         . .           . .
c         .   .       .   .
c         .     .   .     .
c         .       . 5     .  Ici le noeud 5 est au-dessus
c         .     .   .     .
c         .   .       .   .
c         . .           . .
c         -----------------
c         4                3
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c    . Le triedre (1-->2,1-->4,1-->5) est direct
c
      deamed(tyhpy2,1,3) = 10
      deamed(tyhpy2,2,3) = 13
      deamed(tyhpy2,3,3) = 12
      deamed(tyhpy2,4,3) = 11
      deamed(tyhpy2,5,3) = 9
      deamed(tyhpy2,6,3) = 8
      deamed(tyhpy2,7,3) = 7
      deamed(tyhpy2,8,3) = 6
c
c 5.9 ==> En quadratique
c
      do 591 , jaux = 1 , 10
c
        arsmed(tyhse2,jaux,1) = arsmed(tyhse1,jaux,1)
        arsmed(tyhse2,jaux,2) = arsmed(tyhse1,jaux,2)
        arsmed(tyhse2,jaux,3) = arsmed(tyhse1,jaux,3)
c
        arsmed(tyhtr2,jaux,1) = arsmed(tyhtr1,jaux,1)
        arsmed(tyhtr2,jaux,2) = arsmed(tyhtr1,jaux,2)
        arsmed(tyhtr2,jaux,3) = arsmed(tyhtr1,jaux,3)
c
        arsmed(tyhtr3,jaux,1) = arsmed(tyhtr1,jaux,1)
        arsmed(tyhtr3,jaux,2) = arsmed(tyhtr1,jaux,2)
        arsmed(tyhtr3,jaux,3) = arsmed(tyhtr1,jaux,3)
c
        arsmed(tyhte2,jaux,1) = arsmed(tyhte1,jaux,1)
        arsmed(tyhte2,jaux,2) = arsmed(tyhte1,jaux,2)
        arsmed(tyhte2,jaux,3) = arsmed(tyhte1,jaux,3)
c
        arsmed(tyhqu2,jaux,1) = arsmed(tyhqu1,jaux,1)
        arsmed(tyhqu2,jaux,2) = arsmed(tyhqu1,jaux,2)
        arsmed(tyhqu2,jaux,3) = arsmed(tyhqu1,jaux,3)
c
        arsmed(tyhqu3,jaux,1) = arsmed(tyhqu1,jaux,1)
        arsmed(tyhqu3,jaux,2) = arsmed(tyhqu1,jaux,2)
        arsmed(tyhqu3,jaux,3) = arsmed(tyhqu1,jaux,3)
c
        arsmed(tyhpy2,jaux,1) = arsmed(tyhpy1,jaux,1)
        arsmed(tyhpy2,jaux,2) = arsmed(tyhpy1,jaux,2)
        arsmed(tyhpy2,jaux,3) = arsmed(tyhpy1,jaux,3)
        arsmed(tyhpy2,jaux,4) = arsmed(tyhpy1,jaux,4)
c
        arsmed(tyhhe2,jaux,1) = arsmed(tyhhe1,jaux,1)
        arsmed(tyhhe2,jaux,2) = arsmed(tyhhe1,jaux,2)
        arsmed(tyhhe2,jaux,3) = arsmed(tyhhe1,jaux,3)
c
        arsmed(tyhhe3,jaux,1) = arsmed(tyhhe1,jaux,1)
        arsmed(tyhhe3,jaux,2) = arsmed(tyhhe1,jaux,2)
        arsmed(tyhhe3,jaux,3) = arsmed(tyhhe1,jaux,3)
c
        arsmed(tyhpe2,jaux,1) = arsmed(tyhpe1,jaux,1)
        arsmed(tyhpe2,jaux,2) = arsmed(tyhpe1,jaux,2)
        arsmed(tyhpe2,jaux,3) = arsmed(tyhpe1,jaux,3)
c
  591 continue
c
      do 592 , jaux = 1 , 12
c
        deamed(tyhse2,jaux,1) = deamed(tyhse1,jaux,1)
        deamed(tyhse2,jaux,2) = deamed(tyhse1,jaux,2)
c
        deamed(tyhtr2,jaux,1) = deamed(tyhtr1,jaux,1)
        deamed(tyhtr2,jaux,2) = deamed(tyhtr1,jaux,2)
c
        deamed(tyhtr3,jaux,1) = deamed(tyhtr1,jaux,1)
        deamed(tyhtr3,jaux,2) = deamed(tyhtr1,jaux,2)
c
        deamed(tyhqu2,jaux,1) = deamed(tyhqu1,jaux,1)
        deamed(tyhqu2,jaux,2) = deamed(tyhqu1,jaux,2)
c
        deamed(tyhqu3,jaux,1) = deamed(tyhqu1,jaux,1)
        deamed(tyhqu3,jaux,2) = deamed(tyhqu1,jaux,2)
c
        deamed(tyhte2,jaux,1) = deamed(tyhte1,jaux,1)
        deamed(tyhte2,jaux,2) = deamed(tyhte1,jaux,2)
c
        deamed(tyhpy2,jaux,1) = deamed(tyhpy1,jaux,1)
        deamed(tyhpy2,jaux,2) = deamed(tyhpy1,jaux,2)
c
        deamed(tyhhe2,jaux,1) = deamed(tyhhe1,jaux,1)
        deamed(tyhhe2,jaux,2) = deamed(tyhhe1,jaux,2)
c
        deamed(tyhhe3,jaux,1) = deamed(tyhhe1,jaux,1)
        deamed(tyhhe3,jaux,2) = deamed(tyhhe1,jaux,2)
c
        deamed(tyhpe2,jaux,1) = deamed(tyhpe1,jaux,1)
        deamed(tyhpe2,jaux,2) = deamed(tyhpe1,jaux,2)
c
  592 continue
c
c====
c 6. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
