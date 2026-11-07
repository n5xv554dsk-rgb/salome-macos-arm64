      subroutine utacma ( nocmai, typnom, typcca,
     >                      sdim,   mdim,
     >                     degre, mailet, maconf, homolo, hierar,
     >                    nbnoto, nctfno, nbelem, nbmane, attrib,
     >                    ncinfo, ncnoeu, nccono, nccode,
     >                    nccoex, ncfami,
     >                    ncequi, ncfron, ncnomb,
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
c    UTilitaire - Allocation pour le Calcul - MAillage
c    --           -                  -        --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocmai . es  . char8  . nom de l'objet maillage homard             .
c . typnom . e   .    1   . type du nom de l'objet maillage            .
c .        .     .        . 0 : le nom est a creer automatiquement     .
c .        .     .        . 1 : le nom est impose par l'appel          .
c . typcca . e   .   1    . type du code de calcul                     .
c . sdim   . e   .    1   . dimension de l'espace                      .
c . mdim   . e   .    1   . dimension du maillage                      .
c . degre  . e   .    1   . degre du maillage                          .
c . mailet . e   .    1   . presence de mailles etendues               .
c .        .     .        .  1 : aucune                                .
c .        .     .        . 2x : TRIA7                                 .
c .        .     .        . 3x : QUAD9                                 .
c .        .     .        . 5x : HEXA27                                .
c . maconf . e   .    1   . conformite du maillage                     .
c .        .     .        .  0 : oui                                   .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2 par face           .
c .        .     .        .  2 : non-conforme avec 1 seul noeud pendant.
c .        .     .        .      par arete                             .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 et des boites pour les  .
c .        .     .        .       quadrangles, hexaedres et pentaedres .
c .        .     .        . 10 : non-conforme sans autre connaissance  .
c . homolo . e   .    1   . type de relations par homologues           .
c .        .     .        . 0 : pas d'homologues                       .
c .        .     .        . 1 : relations sur les noeuds               .
c .        .     .        . 2 : relations sur les noeuds et les aretes .
c .        .     .        . 3 : relations sur les noeuds, les aretes   .
c .        .     .        .     et les triangles                       .
c . hierar . e   .    1   . maillage hierarchique                      .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : oui                                    .
c . nbnoto . e   .    1   . nombre de noeuds total                     .
c . nctfno . e   .    1   . nombre de carac. des familles de noeuds    .
c . nbelem . e   .    1   . nombre d'elements                          .
c . nbmane . e   .    1   . nombre maximum de noeuds par element       .
c . attrib . e   .    1   . attribut auxiliaire                        .
c . ncinfo .   s . char8  . nom de la branche InfoGene                 .
c . ncnoeu .   s . char8  . nom de la branche Noeud                    .
c . nccono .   s . char8  . nom de la branche ConnNoeu                 .
c . nccode .   s . char8  . nom de la branche ConnDesc                 .
c . nccoex .   s . char8  . nom de la branche CodeExte                 .
c . ncfami .   s . char8  . nom de la branche Famille                  .
c . ncequi .   s . char8  . nom de la branche Equivalt                 .
c . ncfron .   s . char8  . nom de la branche Frontier                 .
c . ncnomb .   s . char8  . nom de la branche Nombres                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . -1 : mauvaise demande pour le type de nom  .
c .        .     .        . autre : probleme dans l'allocation         .
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
      parameter ( nompro = 'UTACMA' )
c
      integer nbnomb
      parameter ( nbnomb = 50 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nocmai
c
      integer typnom, typcca
      integer sdim, mdim
      integer degre, mailet, maconf, homolo, hierar
      integer nbnoto, nctfno, nbelem, nbmane, attrib
c
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8
      integer codre0
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(5x,''Allocation d''''un objet maillage de calcul'',/)'
      texte(1,5) = '(''Mauvaise demande de type de nom :'',i6)'
      texte(1,6) = '(''Probleme pour allouer l''''objet '',a8)'
      texte(1,7) = '(''Probleme pour allouer un objet temporaire.'')'
c
      texte(2,4) =
     > '(5x,''Allocation of an object calculation mesh'',/)'
      texte(2,5) = '(''Bad request for the type of name :'',i6)'
      texte(2,6) = '(''Problem while allocating object '',a8)'
      texte(2,7) = '(''Problem while allocating a temporary object.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. allocation de la structure du maillage de calcul
c    on n'alloue que les objets structures du graphe
c====
c
c 2.1. ==> allocation de la tete du maillage de calcul
c
      if ( typnom.eq.0 ) then
c
        call gmalot ( nocmai, 'Cal_Mail', 0, iaux, codre1 )
        codret = abs(codre1)
c
      elseif ( typnom.eq.1 ) then
c
        call gmaloj ( nocmai, 'Cal_Mail', 0, iaux, codre1 )
        codret = abs(codre1)
c
      else
c
        codret = -1
c
      endif
c
c 2.2. ==> Allocation des branches principales
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. branches ppales ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nocmai, 1, sdim, codre1 )
      call gmecat ( nocmai, 2, mdim, codre2 )
      call gmecat ( nocmai, 3, degre, codre3 )
      call gmecat ( nocmai, 4, maconf, codre4 )
      call gmecat ( nocmai, 5, homolo, codre5 )
      call gmecat ( nocmai, 6, hierar, codre6 )
      call gmecat ( nocmai, 7, nbnomb, codre7 )
      call gmecat ( nocmai, 8, mailet, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)'codes',codre1, codre2, codre3,
     >      codre4, codre5,codre6, codre7, codre8
      call gmprsx(nompro, nocmai)
#endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. avant nocmai 1 ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( nocmai//'.InfoGene', ' ', 0, iaux, codre1 )
      call gmaloj ( nocmai//'.Noeud'   , ' ', 0, iaux, codre2 )
      call gmaloj ( nocmai//'.ConnNoeu', ' ', 0, iaux, codre3 )
      call gmaloj ( nocmai//'.ConnDesc', ' ', 0, iaux, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. avant nocmai 2 ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( nocmai//'.CodeExte' , ' ', 0, iaux, codre1 )
      call gmaloj ( nocmai//'.Famille'  , ' ', 0, iaux, codre2 )
      call gmaloj ( nocmai//'.Equivalt' , ' ', 0, iaux, codre3 )
      call gmaloj ( nocmai//'.Nombres'  , ' ', nbnomb, iaux, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      call gmaloj ( nocmai//'.Frontier', ' ', iaux, jaux, codret )
c
      endif
c
c 2.3. ==> nom interne de ces branches
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. nom interne ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMC', nompro
#endif
      call utnomc ( nocmai,
     >                sdim,   mdim,
     >               degre, mailet, maconf, homolo, hierar,
     >              iaux,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90003) 'ncnoeu', ncnoeu
      write (ulsort,90003) 'nccono', nccono
#endif
c
      endif
c
c 2.4. ==> attributs
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. attributs ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( ncnoeu, 1, nbnoto, codre1 )
      call gmecat ( ncnoeu, 2, nctfno, codre2 )
      call gmecat ( ncnoeu, 3, 0     , codre2 )
c
      codre0 = min ( codre1, codre2, codre3  )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3  )
c
      call gmecat ( nccono, 1, nbelem, codre1 )
      call gmecat ( nccono, 2, nbmane, codre2 )
      call gmecat ( nccono, 3, attrib, codre3 )
c
      codre0 = min ( codre1, codre2, codre3  )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3  )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx(nompro, nocmai)
      call gmprsx(nompro, nocmai//'.Nombres')
      call gmprsx(nompro//' - ncnoeu', ncnoeu)
      call gmprsx(nompro//' - nccono', nccono)
      endif
#endif
c
c====
c 3. la fin
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. la fin ; codret', codret
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      if ( codret.eq.-1 ) then
        write (ulsort,texte(langue,5)) typnom
      else
        if ( typnom.eq.1 ) then
          write (ulsort,texte(langue,6)) nocmai
        else
          write (ulsort,texte(langue,7))
        endif
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
