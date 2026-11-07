      subroutine utad21 ( nhnoeu,
     >                    adcoor, adhist, adarno,
     >                    adhono, addera,
     >                    adcoco, adinfg,
     >                    adreco,
     >                    adfami, adcofa,
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
c    UTilitaire - ADresses - phase 21
c    --           --               --
c ______________________________________________________________________
c   Recuperation des adresses des tableaux pour les noeuds HOM_Noeu
c   Attention : Si le tableau est absent ou de longueur nulle, on
c               retourne une adresse valant 0. C'est une valeur
c               impossible car cela voudrait dire que malloc a reserve
c               une place exactement la ou est le common.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nhnoeu . e   . char8  . nom de l'objet decrivant l'entite          .
c . adhist .   s  .  1    . historique de l'etat                       .
c . adfami .   s  .  1    . famille des noeuds                         .
c . adcofa .   s  .  1    . codes des familles des noeuds              .
c . adcoor .   s  .  1    . coordonnees                                .
c . adarno .   s  .  1    . arete supportant le noeud                  .
c . adhono .   s  .  1    . homologue du noeud                         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'UTAD21' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nhnoeu
c
      integer adcoor, adhist, adarno
      integer adhono, addera
      integer adcoco, adinfg
      integer adreco
      integer adfami, adcofa
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer codre0
c
      character*16 saux16
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Adresses relatives aux noeuds'')'
c
      texte(2,4) = '(''Adresses for nodes'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
ccc      call gmprsx(nompro,nhnoeu)
#endif
c
      codret = 0
c
c====
c 2. Reperage des tableaux
c    On explore tous ceux possibles dans HOM_Noeu (cf. typobj.stu)
c====
c
      do 21 , iaux = 1 , 10
c
c 2.1. ==> Le nom de la iaux-ieme branche
c
        if ( codret.eq.0 ) then
c
c                   1234567890123456
        if ( iaux.eq.1 ) then
          saux16 = 'Coor            '
        elseif ( iaux.eq.2 ) then
          saux16 = 'HistEtat        '
        elseif ( iaux.eq.3 ) then
          saux16 = 'AretSupp        '
        elseif ( iaux.eq.4 ) then
          saux16 = 'Homologu        '
        elseif ( iaux.eq.5 ) then
          saux16 = 'Deraffin '
        elseif ( iaux.eq.6 ) then
          saux16 = 'CoorCons        '
        elseif ( iaux.eq.7 ) then
          saux16 = 'InfoGene        '
        elseif ( iaux.eq.8 ) then
          saux16 = 'Recollem        '
        elseif ( iaux.eq.9 ) then
          saux16 = 'Famille.EntiFamm'
        elseif ( iaux.eq.10 ) then
          saux16 = 'Famille.Codes   '
        endif
c
        endif
c
c 2.2. ==> Recherche du tableau
c
        if ( codret.eq.0 ) then
c
c 2.2.1. ==> Existence du tableau
c
        call gmobal ( nhnoeu//'.'//saux16, codre0 )
c
c 2.2.1. ==> Le tableau existe : quelles adresse et longueur ?
c
        if ( codre0.eq.2 ) then
c
          call gmadoj ( nhnoeu//'.'//saux16, jaux, kaux, codre0 )
c
          if ( codre0.eq.0 ) then
            if ( kaux.eq.0 ) then
              jaux = 0
            endif
          else
            codret = codret + 1
          endif
c
c 2.2.2. ==> Probleme
c
        elseif ( codre0.ne.0 ) then
          codret = codret + 1
c
c 2.2.3. ==> Le tableau n'existe pas
c
        else
          jaux = 0
        endif
c
        endif
c
c 2.3. ==> Stockage de l'adresse et eventuellement de la longueur
c
        if ( codret.eq.0 ) then
c
        if ( iaux.eq.1 ) then
          adcoor = jaux
        elseif ( iaux.eq.2 ) then
          adhist = jaux
        elseif ( iaux.eq.3 ) then
          adarno = jaux
        elseif ( iaux.eq.4 ) then
          adhono = jaux
        elseif ( iaux.eq.5 ) then
          addera = jaux
        elseif ( iaux.eq.6 ) then
          adcoco = jaux
        elseif ( iaux.eq.7 ) then
          adinfg = jaux
        elseif ( iaux.eq.8 ) then
          adreco = jaux
        elseif ( iaux.eq.9 ) then
          adfami = jaux
        elseif ( iaux.eq.10 ) then
          adcofa = jaux
        endif
c
        endif
c
   21 continue
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
