      subroutine eslch6 ( nrocha, numcat, nbtvlu, caraen, nomcha,
     >                    nbtosv, caetal,
     >                    nbcham, tabaux,
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
c  Entree-Sortie - Lecture d'un CHamp au format MED - phase 6
c  -      -        -            --                          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nrocha . e   .    1   . numero du champ dans le rangement HOMARD   .
c . numcat . e   .    1   . caracteristique du champ a traiter         .
c .        .     .        .    1, si aux noeuds par elements           .
c .        .     .        .    2, si aux points de Gauss, associe avec .
c .        .     .        .       un champ aux noeuds par elements     .
c .        .     .        .    3, si aux points de Gauss autonome      .
c .        .     .        .    0, sinon                                .
c . nbtvlu . e   .    1   . nombre de tableaux effectivement lus       .
c . caraen . es  . nbinec*. caracteristiques entieres des tableaux du  .
c .        .     . nbtvch . champ en cours d'examen                    .
c .        .     .        . 1. type de support au sens MED             .
c .        .     .        .  -1, si on prend tous les supports         .
c .        .     .        . 2. numero du pas de temps                  .
c .        .     .        . 3. numero d'ordre                          .
c .        .     .        . 4. nombre de points de Gauss               .
c .        .     .        . 5. nombre d'entites support                .
c .        .     .        . 6. nombre de valeurs du profil eventuel    .
c .        .     .        . 7. nombre de supports associes             .
c .        .     .        . 8. 1, si aux noeuds par elements           .
c .        .     .        .    2, si aux points de Gauss, associe avec .
c .        .     .        .       un champ aux noeuds par elements     .
c .        .     .        .    3, si aux points de Gauss autonome      .
c .        .     .        .    0, sinon                                .
c .        .     .        . 9. numero du 1er tableau dans la fonction  .
c .        .     .        . 10. si champ elga, numero du champ elno    .
c .        .     .        .     si champ elno, numero du champ elga si .
c .        .     .        .     il existe, sinon -1                    .
c .        .     .        . 11. type interpolation                     .
c .        .     .        .       0, si automatique                    .
c .        .     .        .       1 si degre 1, 2 si degre 2,          .
c .        .     .        .       3 si iso-P2                          .
c .        .     .        . 12. type de champ edfl64/edin64            .
c .        .     .        . 21-nbinec. type des supports associes      .
c . nomcha . e   . char64 . nom du champ                               .
c . nbtosv . e   .    1   . nombre total de tableaux de valeurs        .
c . caetal . es  .  12 *  . caracteristiques entieres de chaque        .
c .        .     . nbtosv . tableau a lire                             .
c .        .     .        . 1. type de support au sens MED             .
c .        .     .        .  -1, si on prend tous les supports         .
c .        .     .        . 2. 2, on prend le dernier pas de temps     .
c .        .     .        .    1, le numero du pas de temps est fourni .
c .        .     .        .    0, sinon                                .
c .        .     .        . 3. numero du pas de temps                  .
c .        .     .        . 4. 2, on prend le dernier numero d'ordre   .
c .        .     .        .    1, le numero d'ordre est fourni         .
c .        .     .        .    0, sinon                                .
c .        .     .        . 5. numero d'ordre                          .
c .        .     .        . 6. 2, on prend le dernier instant          .
c .        .     .        .    1, l'instant est fourni                 .
c .        .     .        .    0, sinon                                .
c .        .     .        . 7. 1, si aux noeuds par elements, 0 sinon, .
c .        .     .        .   -1, si non precise                       .
c .        .     .        . 8. numero du champ noeuds/element associe  .
c .        .     .        . 9. numero du champ associe dans HOMARD     .
c .        .     .        . 10. type d'interpolation                   .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  1 si degre 1, 2 si degre 2, 3 si iso-P2   .
c .        .     .        . 11. 1, s'il fait partie du champ en cours  .
c .        .     .        .    d'examen, 0, sinon                      .
c .        .     .        . 12. type de champ edfl64/edin64            .
c . nbcham . e   .    1   . nombre de champs retenus                   .
c . tabaux . es  . nbcham . tableau auxiliaire contenant le numero du  .
c .        .     .        . champ associe, s'il existe                 .
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
      parameter ( nompro = 'ESLCH6' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "esutil.h"
c
c 0.3. ==> arguments
c
      integer nrocha, numcat, nbtvlu, nbtosv
      integer caraen(nbinec,nbtvlu)
      integer caetal(12,*)
      integer nbcham, tabaux(nbcham)
c
      character*64 nomcha
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer numtv, carsup
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "esimpr.h"
c
      texte(1,4) = '(''Numero du champ :'',i5)'
      texte(1,6) = '(''Recherche dans la categorie : '')'
      texte(1,7) = '(''Impossible de trouver le champ ELNO associe.'')'
      texte(1,8) = '(''Impossible de trouver le champ ELGA associe.'')'
c
      texte(2,4) = '(''Field # :'',i5)'
      texte(2,6) = '(''Search in : '')'
      texte(2,7) = '(''ELNO connected field cannot be found.'')'
      texte(2,8) = '(''ELGA connected field cannot be found.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,32)) nomcha
      write (ulsort,texte(langue,4)) nrocha
      write (ulsort,texte(langue,111)) nbtvlu
      write (ulsort,texte(langue,6))
      if ( numcat.eq.2 ) then
        iaux = 3
      else
        iaux = numcat
      endif
      write (ulsort,texte(langue,65+iaux))
      write (ulsort,90002) 'numcat', numcat
#endif
c
      codret = 0
c
c====
c 2. traitement des champs standard
c====
c
      if ( numcat.eq.0 ) then
c
        do 20 , numtv = 1 , nbtvlu
c
c 2.1. ==> caracteristiques generales du tableau
c
          carsup = caraen(8,numtv)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) '. Tableau numero', numtv
          write (ulsort,texte(langue,65+carsup))
#endif
c
          if ( carsup.eq.numcat ) then
            caraen(10,numtv) = 0
            tabaux(nrocha) = 0
          endif
cgn        print *, '===> caraen(10,',numtv,') = ',caraen(10,numtv)
c
   20   continue
c
c====
c 3. traitement des champs aux points de Gauss
c    on memorise le numero de l'eventuel champ aux noeuds par element
c    qui lui est associe
c    a. On cherche le numero dans le fichier de configuration du
c       champ correspondant : iaux, tel que caetal(9,iaux) = norcha
c    b. on en deduit le numero dans le fichier de configuration du
c       champ aux noeuds par element associe : jaux = caetal(8,iaux)
c    c. on en deduit le numero dans HOMARD du champ aux noeuds par
c       element associe : caetal(9,jaux)
c====
c
      elseif ( numcat.ge.2 ) then
c
        do 30 , numtv = 1 , nbtvlu
c
          carsup = caraen(8,numtv)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) '. Tableau numero', numtv
          write (ulsort,texte(langue,65+carsup))
#endif
c
          if ( carsup.eq.numcat ) then
c
            tabaux(nrocha) = -2
            do 311 , iaux = 1 , nbtosv
              if ( caetal(9,iaux).eq.nrocha ) then
                jaux = caetal(8,iaux)
                if ( jaux.gt.0 ) then
                  caraen(10,numtv) = caetal(9,jaux)
                  tabaux(nrocha) = caetal(9,jaux)
                  goto 30
                endif
              endif
  311       continue
c
c       Aucun champ associe n'a ete trouve : c'est que le traitement
c       des points de Gauss a lieu en solo
c
            do 312 , iaux = 1 , nbtosv
              if ( caetal(9,iaux).eq.nrocha ) then
                tabaux(nrocha) = iaux
              endif
  312       continue
            caraen(8,numtv) = 3
c
          endif
cgn        print *, '===> caraen(10,',numtv,') = ',caraen(10,numtv)
c
   30   continue
c
c====
c 4. traitement des champs aux noeuds par element
c    on memorise le numero de l'eventuel champ aux points de Gauss qui
c    lui est associe
c====
c
      else
c
        do 40 , numtv = 1 , nbtvlu
c
          carsup = caraen(8,numtv)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) '. Tableau numero', numtv
          write (ulsort,texte(langue,65+carsup))
#endif
c
          if ( carsup.eq.numcat ) then
c
            tabaux(nrocha) = -2
            do 411 , iaux = 1 , nbcham
              if ( tabaux(iaux).eq.nrocha ) then
                caraen(10,numtv) = iaux
                tabaux(nrocha) = iaux
                goto 40
              endif
  411       continue
            caraen(10,numtv) = 0
c
          endif
cgn          print *, '===> caraen(10,',numtv,') = ',caraen(10,numtv)
c
   40   continue
c
      endif
c
c====
c 5. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,32)) nomcha
      write (ulsort,texte(langue,65+numcat))
      write (ulsort,texte(langue,4)) nrocha
      if ( codret.ne.30 ) then
        write (ulsort,texte(langue,6+codret))
      endif
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
