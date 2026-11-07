      subroutine utnomc ( nocmai,
     >                      sdim,   mdim,
     >                     degre, mailet, maconf, homolo, hierar,
     >                    nbnomb,
     >                    ncinfo, ncnoeu, nccono, nccode,
     >                    nccoex, ncfami,
     >                    ncequi, ncfron, ncnomb,
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
c    UTilitaire - Nom des Objets du Maillage de Calcul
c    --           -       -         -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocmai . e   . char8  . nom de l'objet maillage de calcul          .
c . sdim   .   s .    1   . dimension de l'espace                      .
c . mdim   .   s .    1   . dimension du maillage                      .
c . degre  .   s .    1   . degre du maillage                          .
c . mailet .   s .    1   . presence de mailles etendues               .
c .        .     .        .  1 : aucune                                .
c .        .     .        . 2x : TRIA7                                 .
c .        .     .        . 3x : QUAD9                                 .
c .        .     .        . 5x : HEXA27                                .
c . maconf .   s .    1   . conformite du maillage                     .
c .        .     .        .  0 : oui                                   .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2 par face           .
c .        .     .        .  2 : non-conforme avec 1 seul noeud pendant.
c .        .     .        .      par arete                             .
c .        .     .        .  3 : non-conforme sans contrainte          .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 et des boites pour les  .
c .        .     .        .       quadrangles, hexaedres et pentaedres .
c .        .     .        . 10 : non-conforme sans autre connaissance  .
c . homolo .  s  .    1   . type de relations par homologues           .
c .        .     .        . 0 : pas d'homologues                       .
c .        .     .        . 1 : relations sur les noeuds               .
c .        .     .        . 2 : relations sur les noeuds et les aretes .
c .        .     .        . 3 : relations sur les noeuds, les aretes   .
c .        .     .        .     et les triangles                       .
c . hierar .  s  .    1   . maillage hierarchique                      .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : oui                                    .
c . nbnomb .   s .    1   . longueur du tableau de la branche Nombres  .
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
      parameter ( nompro = 'UTNOMC' )
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
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
c
      integer sdim, mdim
      integer degre, mailet, maconf, homolo, hierar
      integer nbnomb
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
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
      texte(1,10) = '(''Noms des objets du maillage de calcul.'')'
      texte(1,4) = '(''Au moins une branche est indefinie.'')'
c
      texte(2,10) = '(''Names of calculation mesh objects.'')'
      texte(2,4) = '(''At least one branch is undefined.'')'
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,10))
#endif
c
      codret = 0
c
c====
c 2. recuperation des donnees du maillage d'entree
c====
c
c 2.1. ==> caracteristiques de base
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nocmai, 1, sdim, codre1 )
      call gmliat ( nocmai, 2, mdim, codre2 )
      call gmliat ( nocmai, 3, degre, codre3 )
      call gmliat ( nocmai, 4, maconf, codre4 )
      call gmliat ( nocmai, 5, homolo, codre5 )
      call gmliat ( nocmai, 6, hierar, codre6 )
      call gmliat ( nocmai, 7, nbnomb, codre7 )
      call gmliat ( nocmai, 8, mailet, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      endif
c
c 2.2. ==> noms des branches
c
c    le code de retour de gmnomc est :
c      0 : tout va bien
c     -1 : l'objet n'est pas defini ; dans ce cas, le nom est "Indefini"
c     -3 : le nom etendu est invalide
c
c    Ici, on tolere le retour -1, car selon les endroits, les branches
c    ne sont pas toutes definies.
c    En revanche, le -3 est une vraie erreur car c'est que le nom
c    de l'objet maillage est mauvais.
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nocmai//'.InfoGene', ncinfo, codre1 )
      call gmnomc ( nocmai//'.Noeud'   , ncnoeu, codre2 )
      call gmnomc ( nocmai//'.ConnNoeu', nccono, codre3 )
      call gmnomc ( nocmai//'.ConnDesc', nccode, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nocmai//'.CodeExte', nccoex, codre1 )
      call gmnomc ( nocmai//'.Famille' , ncfami, codre2 )
      call gmnomc ( nocmai//'.Equivalt', ncequi, codre3 )
      call gmnomc ( nocmai//'.Frontier', ncfron, codre4 )
      call gmnomc ( nocmai//'.Nombres' , ncnomb, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      if ( codret.eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,4))
#endif
        codret = 0
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
