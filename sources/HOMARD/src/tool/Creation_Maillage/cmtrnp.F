      subroutine cmtrnp ( nohman, nohmap, typnom,
     >                    lgopti, taopti, lgetco, taetco,
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
c    Creation du Maillage - TRansfert du maillage N dans le maillage N+1
c    -           -          --                    -                   -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nohman . e   .  ch8   . nom de l'objet contenant le maillage n     .
c . nohmap . es  .  ch8   . nom de l'objet contenant le maillage n+1   .
c . typnom . e   .    1   . type du nom de l'objet maillage n+1        .
c .        .     .        . 0 : le nom est a creer automatiquement     .
c .        .     .        . 1 : le nom est impose par l'appel          .
c . lgopti . e   .   1    . longueur du tableau des options entieres   .
c . taopti . e   . lgopti . tableau des options                        .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'CMTRNP' )
c
#include "nblang.h"
#include "envca1.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nohman, nohmap
c
      integer typnom
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nretap, nrsset
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(/,a6,'' TRANSFERT DU MAILLAGE'')'
      texte(1,5) = '(28(''=''),/)'
      texte(1,6) ='(''De la structure '',a8,'' vers la structure '',a8)'
c
      texte(2,4) = '(/,a6,'' TRANSFER OF ADAPTED MESH'')'
      texte(2,5) = '(31(''=''),/)'
      texte(2,6) = '(''From structure '',a8,'' to structure '',a8)'
c
#include "impr03.h"
c
c 1.2. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.3. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nohman, nohmap
      call gmprsx (nompro, nohman )
#endif
c
c====
c 2. recuperation de la structure generale
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
c
      call utnomh ( nohman,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 3. transfert de la structure de l'iteration n vers n+1
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Transfert ; codret', codret
#endif
c
c 3.1. ==> allocation de la tete du maillage HOMARD
c
      if ( typnom.eq.0 ) then
c
        call gmalot ( nohmap, 'HOM_Mail', 0, iaux, codre1 )
        codret = abs(codre1)
c
      elseif ( typnom.eq.1 ) then
c
        call gmaloj ( nohmap, 'HOM_Mail', 0, iaux, codre1 )
        codret = abs(codre1)
c
      else
c
        codret = -1
c
      endif
c
c 3.2. ==> on recopie les attributs qui ne varient pas
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nohmap, 1,   sdim, codre1 )
      call gmecat ( nohmap, 2,   mdim, codre2 )
      call gmecat ( nohmap, 3,  degre, codre3 )
      call gmecat ( nohmap, 5, homolo, codre4 )
      call gmecat ( nohmap, 6, hierar, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      call gmecat ( nohmap, 8, nbmane, codre1 )
      call gmecat ( nohmap, 9, typcca, codre2 )
      call gmecat ( nohmap,10, typsfr, codre3 )
      call gmecat ( nohmap,11, maextr, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c 3.3. ==> nombre de mailles ignorees
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhelig, 1, iaux, codret )
c
      endif
c
c 3.4. ==> on etablit l'attribut qui precise comment on a obtenu
c          le maillage
c          0 : macro-maillage
c          1 : le maillage est inchange
c          2 : le maillage est issu du raffinement pur
c              d'un autre maillage
c          3 : le maillage est issu du deraffinement
c              pur d'un autre maillage
c          4 : le maillage est issu de raffinement et
c              de deraffinement d'un autre maillage
c         12 : le maillage est un maillage passe de degre 1 a 2
c         21 : le maillage est un maillage passe de degre 2 a 1
c         31 : le maillage est un maillage avec ajout des joints
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. Attribut rafdef ; codret', codret
      write (ulsort,90002) '.. taopti(4)', taopti(4)
      write (ulsort,90002) '.. taopti(31)', taopti(31)
      write (ulsort,90002) '.. taopti(31)', taopti(31)
      write (ulsort,90002) '.. taopti(41)', taopti(41)
      write (ulsort,90002) '.. taopti(42)', taopti(42)
      write (ulsort,90002) '.. degre', degre
#endif
      if ( codret.eq.0 ) then
c
      if ( taopti(4).ne.3 ) then
c
        if ( taopti(31).eq.0 ) then
          if ( taopti(32).eq.0 ) then
            rafdef = 1
          else
            rafdef = 3
          endif
        else
          if ( taopti(32).eq.0 ) then
            rafdef = 2
          else
            if ( rafdef.eq.0 ) then
              rafdef = 2
            else
              rafdef = 4
            endif
          endif
        endif
c
      else
c
        if ( taopti(41).eq.1 ) then
          if ( degre.eq.2 ) then
            rafdef = 12
          else
            rafdef = 21
          endif
        elseif ( taopti(42).eq.1 ) then
          rafdef = 31
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '==> rafdef', rafdef
#endif
c
      call gmecat ( nohmap, 7, rafdef, codret )
c
      endif
c
c 3.5. ==> conformite du maillage
c            . si dans cette etape de raffinement, on a demande du
c              non-conforme, alors on suppose que le maillage le sera.
c              La caracteristique est :
c       0 : conforme
c       1 : non-conforme avec au minimum 2 aretes non decoupees en 2
c           par face (triangle ou quadrangle)
c       2 : non-conforme avec 1 seul noeud pendant par arete
c       3 : non-conforme fidele a l'indicateur
c      -1 : conforme, avec des boites pour les quadrangles, hexaedres
c           et pentaedres
c      -2 : non-conforme avec au maximum 1 arete decoupee en 2 et des
c           boites pour les quadrangles, hexaedres et pentaedres
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'taopti(30)', taopti(30)
      write (ulsort,90002) 'maconf initial', maconf
#endif
c
      if ( taopti(30).eq.-2 ) then
        maconf = -2
      elseif ( taopti(30).eq.-1 ) then
        maconf = -1
      elseif ( taopti(30).eq.1 ) then
        maconf = 1
      elseif ( taopti(30).eq.2 ) then
        maconf = 2
      elseif ( taopti(30).eq.3 ) then
        maconf = 3
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'maconf nouveau', maconf
#endif
c
      call gmecat ( nohmap, 4, maconf, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
c 3.5. ==> on attache les champs du nouveau maillage
c          attention : pour les descriptions des aretes, des faces
c          et des volumes, la structure a un niveau inferieur. Il faut
c          dans ce cas donner le nom complet dans l'appel a gmatoj.
c          dans les autres cas (noeuds, voisins, ...), ce sont des
c          objets simples que l'on peut attacher par leur nom.
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.5. Attachement ; codret', codret
#endif
c
c 3.5.1. ==> les noeuds
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhnoeu, codre1 )
      if ( codre1.eq.1 ) then
        call gmatoj ( nohmap//'.Noeud', nhnoeu, codre0 )
        codret = max ( abs(codre0), codret )
      elseif ( codre1.ne.0 ) then
        codret = 2
      endif
c
      endif
c
c 3.5.2. ==> les mailles-points
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhmapo, codre1 )
      if ( codre1.eq.1 ) then
        call gmatoj ( nohmap//'.Ma_Point', nhmapo, codre0 )
        codret = max ( abs(codre0), codret )
      elseif ( codre1.ne.0 ) then
        codret = 2
      endif
c
      endif
c
c 3.5.3. ==> les aretes
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nharet, codre1 )
      if ( codre1.eq.1 ) then
        call gmatoj ( nohmap//'.Arete', nohman//'.Arete', codre0 )
        codret = max ( abs(codre0), codret )
      elseif ( codre1.ne.0 ) then
        codret = 2
      endif
c
      endif
c
c 3.5.4. ==> les faces
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhtria, codre1 )
      if ( codre1.eq.1 ) then
        call gmatoj ( nohmap//'.Face', nohman//'.Face', codre0 )
        codret = max ( abs(codre0), codret )
      elseif ( codre1.ne.0 ) then
        codret = 2
      endif
c
      endif
c
c 3.5.5. ==> les volumes
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhtetr, codre1 )
      if ( codre1.eq.1 ) then
        call gmatoj ( nohmap//'.Volume', nohman//'.Volume', codre0 )
        codret = max ( abs(codre0), codret )
      elseif ( codre1.ne.0 ) then
        codret = 2
      endif
c
      endif
c
c 3.5.6. ==> les voisinages
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhvois, codre1 )
      if ( codre1.eq.1 ) then
        call gmatoj ( nohmap//'.Voisins', nhvois, codre0 )
        codret = max ( abs(codre0), codret )
      elseif ( codre1.ne.0 ) then
        codret = 2
      endif
c
      endif
c
c 3.5.7. ==> les mailles eliminees
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhelig, codre1 )
      if ( codre1.eq.1 ) then
        call gmatoj ( nohmap//'.ElemIgno', nhelig, codre0 )
        codret = max ( abs(codre0), codret )
      elseif ( codre1.ne.0 ) then
        codret = 2
      endif
c
      endif
c
c 3.5.8. ==> les informations supplementaires
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhsupe, codre1 )
      if ( codre1.eq.1 ) then
        call gmatoj ( nohmap//'.InfoSupE', nhsupe, codre0 )
        codret = max ( abs(codre0), codret )
      elseif ( codre1.ne.0 ) then
        codret = 2
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhsups, codre1 )
      if ( codre1.eq.1 ) then
        call gmatoj ( nohmap//'.InfoSupS', nhsups, codre0 )
        codret = max ( abs(codre0), codret )
      elseif ( codre1.ne.0 ) then
        codret = 2
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nohmap )
      call gmprsx (nompro, nohmap//'.InfoSupS' )
      call gmprsx (nompro, nohmap//'.InfoSupS.Tab3' )
#endif
c
c====
c 4. la fin
c====
c
c 4.1. ==> message si erreur
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
c=======================================================================
      endif
c=======================================================================
c
      end
