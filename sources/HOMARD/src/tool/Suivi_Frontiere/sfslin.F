      subroutine sfslin ( lenoeu, noeud1, noeud2,
     >                    numlig, unst2x, epsid2,
     >                    geocoo, abscur,
     >                    numnoe, lignoe, abscno,
     >                    typlig, somseg, seglig,
     >                    coop,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
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
c   Suivi de Frontiere - Suivi des LIgnes - placement d'un Noeud
c   -        -           -         --                      -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lenoeu . e   .   1    . noeud a bouger                             .
c . noeud1 . e   .   1    . noeud voisin 1 de lenoeu sur l'arete       .
c . noeud2 . e   .   1    . noeud voisin 2 de lenoeu sur l'arete       .
c . numlig . e   .   1    . numero de la ligne de la frontiere         .
c . unst2x . e   .   1    . inverse de la taille maximale au carre     .
c . epsid2 . e   .   1    . precision relative pour carre de distance  .
c . geocoo . e   .sfnbso**. coordonnees des sommets de la frontiere    .
c . abscur . e   . sfnbse . abscisse curviligne des somm des segments  .
c . numnoe . e   . mcnvnf . liste des noeuds de calcul sur le bord     .
c . lignoe . e   . mcnvnf . liste lignes pour ces noeuds               .
c . abscno . e   . mcnvnf . abscisse curviligne de ces noeuds          .
c . typlig . e   . sfnbli . type de la ligne                           .
c .        .     .        . 0 : ligne ouverte, a 2 extremites          .
c .        .     .        . 1 : ligne fermee                           .
c . somseg . e   . sfnbse . liste des sommets des lignes separees par  .
c                           des 0                                      .
c . seglig . e   .0:sfnbli. pointeur dans le tableau somseg : les      .
c .        .     .        . segments de la ligne i sont aux places de  .
c .        .     .        . seglig(i-1)+1 a seglig(i)-1 inclus         .
c . coop   . es  .  sdim  . nouvelles coordonnees de lenoeu            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : impossible de retrouver les noeuds     .
c .        .     .        .     voisins                                .
c .        .     .        . 2 : impossible de trouver le segment       .
c .        .     .        .     contenant le noeud                     .
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
      parameter ( nompro = 'SFSLIN' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
#include "front1.h"
#include "front2.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer lenoeu, noeud1, noeud2
      integer numlig
      integer numnoe(mcnvnf), lignoe(mcnvnf)
      integer typlig(sfnbli), somseg(sfnbse), seglig(0:sfnbli)
c
      double precision unst2x, epsid2
      double precision geocoo(sfnbso,sdim)
      double precision abscur(sfnbse)
      double precision abscno(mcnvnf)
      double precision coop(sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer seg, seg1, seg2
      integer nupass, nbpass
c
      double precision abscnn(2), abscn1, abscn2, abscnm
      double precision daux, lgdeb, lgfin
      double precision cooa(3)
      double precision cooini(3), coopst(3), dist
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
cgn      ulsort = lenoeu
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''.. '',a,i10,'' a deplacer'')'
      texte(1,5) = '(''... Coordonnees :'',3g17.9)'
      texte(1,6) = '(''.. Il est entre les '',a,i10,'' et'',i10)'
      texte(1,7) =
     > '(''.... Abscisse curviligne du noeud'',i10,'' :'',g17.9)'
      texte(1,8) = '(''.... Abscisse curviligne '',a,'' :'',g17.9)'
      texte(1,9) =
     >'(''.. Impossible de trouver le '',a,i10,'' sur la frontiere.'')'
      texte(1,10) = '(''.. Impossible de trouver le segment associe.'')'
c
      texte(2,4) = '(''... '',a,'' # '',i10,'' to move'')'
      texte(2,5) = '(''... Coordinates :'',3g17.9)'
      texte(2,6) =
     > '(''... It is between '',a,'' # '',i10,'' and #'',i10)'
      texte(2,7) =
     > '(''.... Current absciss of the node'',i10,'' :'',g17.9)'
      texte(2,8) = '(''.... Current absciss '',a,'' :'',g17.9)'
      texte(2,9) =
     > '(''.. The '',a,i10,'' cannot be found on boundary.'')'
      texte(2,10) = '(''.. The edge of boundary cannot be found.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,2,-1), lenoeu
      write (ulsort,texte(langue,5)) (coop(iaux),iaux=1,sdim)
      write (ulsort,texte(langue,6)) mess14(langue,3,-1),
     >                               noeud1, noeud2
#endif
c
      codret = 0
c
c====
c 2. Recherche des abscisses curvilignes associes aux noeuds voisins
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Recherche abscisse ; codret', codret
#endif
c
      do 21 , iaux = 1 , 2
c
        if ( codret.eq.0 ) then
c
        if ( iaux.eq.1 ) then
          kaux = noeud1
        else
          kaux = noeud2
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '.... '//mess14(langue,2,-1), kaux
#endif
c
        do 211 , jaux = 1 , mcnvnf
c
          if ( numnoe(jaux).eq.kaux ) then
            if ( lignoe(jaux).eq.numlig ) then
              daux = abs(abscno(jaux))
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) jaux, daux
#endif
              goto 212
            endif
          endif
c
  211   continue
c
        codret = 1
c
        endif
c
  212  continue
c
        if ( codret.eq.0 ) then
c
        abscnn(iaux) = daux
c
        endif
c
   21 continue
c
c====
c 3. Positionnement du noeud a bouger
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Positionnement ; codret', codret
#endif
c
c 3.1. ==> Caracteristique de la ligne
c
      if ( codret.eq.0 ) then
c
      if ( typlig(numlig).eq.0 ) then
        nbpass = 1
      else
        nbpass = 2
      endif
c
      seg1 = seglig(numlig-1)+1
      seg2 = seglig(numlig  )-2
#ifdef _DEBUG_HOMARD_
      write (ulsort,90006) 'Pointeurs ligne', numlig,
     >              ' de', seg1,' a ', seg2
      write (ulsort,90012) '==> Sommets extremites de la ligne',
     >                     numlig, somseg(seg1), somseg(seg2+1)
      write (ulsort,90004) 'abscisse debut', abscur(seg1)
      write (ulsort,90004) 'abscisse fin  ', abscur(seg2+1)
      write (ulsort,90002) 'nbpass', nbpass
#endif
c
      if ( nbpass.gt.0 ) then
c
        do 31 , iaux = 1 , sdim
          cooini(iaux) = coop(iaux)
   31   continue
c
      endif
c
      endif
c
      abscn1 = abscnn(1)
      abscn2 = abscnn(2)
c
      do 30 , nupass = 1 , nbpass
cgn        write (ulsort,*) ' '
cgn        write (ulsort,90002) 'Passage numero', nupass
c
c 3.2. ==> La nouvelle abscisse curviligne
c          . Au premier passage, on calcule entre les deux noeuds
c          . A l'eventuel second, c'est que l'on a une extremite ; on
c          doit tester le chemin reciproque pour les cas ou la ligne
c          serait fermee.
c
        if ( codret.eq.0 ) then
c
c
        if ( nupass.eq.1 ) then
c
          abscnm = 0.5d0 * (abscn1+abscn2)
c
        else
c
          if ( abscn2.gt.abscn1 ) then
            lgfin = abscur(seg2+1) - abscn2
            lgdeb = abscn1 - abscur(seg1)
cgn      write (ulsort,90004) 'de n2 a la fin', lgfin
cgn      write (ulsort,90004) 'du debut a n1 ', lgdeb
          else
            lgfin = abscur(seg2+1) - abscn1
            lgdeb = abscn2 - abscur(seg1)
cgn      write (ulsort,90004) 'de n1 a la fin', lgfin
cgn      write (ulsort,90004) 'du debut a n2 ', lgdeb
            daux = (abscn2-abscur(seg1)) - (abscur(seg2+1)-abscn1)
          endif
          if ( lgfin.gt.lgdeb ) then
            abscnm = abscur(seg2+1) - 0.5d0*(lgfin-lgdeb)
          else
            abscnm = abscur(seg1) + 0.5d0*(lgdeb-lgfin)
          endif
c
          do 32 , iaux = 1 , sdim
            coopst(iaux) = coop(iaux)
   32     continue
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) mess14(langue,2,-1), lenoeu
        write (ulsort,texte(langue,8)) 'noeud', abscnm
#endif
c
        endif
c
c 3.3. ==> Recherche du segment
c          Remarque : le noeud a bouger ne peut pas etre une des
c                     extremites de la ligne car il est situe entre
c                     noeud1 et noeud2, eux-memes sur cette ligne
c
      if ( codret.eq.0 ) then
c
      seg = 0
c
      do 33 , kaux = seg1 , seg2
c
        if ( abscnm.ge.abscur(kaux) .and.
     >       abscnm.le.abscur(kaux+1) ) then
c
          seg = kaux
#ifdef _DEBUG_HOMARD_
          write (ulsort,90006) '.... Appartiendra au segment', seg
          write (ulsort,texte(langue,8)) 'debut', abscur(seg)
          write (ulsort,texte(langue,8)) 'fin  ', abscur(seg+1)
#endif
c
c 3.3.2. ==> Le noeud est-il le premier point du segment ?
c
          daux = 0.d0
          do 332 , iaux = 1 , sdim
            cooa(iaux) = geocoo(somseg(kaux),iaux)
            daux = daux + (cooa(iaux)-coop(iaux))**2
  332     continue
c
c 3.3.3. ==> Si non, on doit bouger le noeud
c            Si oui, c'est parfait : le noeud est deja sur la frontiere
c
          if ( daux*unst2x.gt.epsid2 ) then
c
c         A                          M            B
c         x--------------------------o------------x
c
c         On procede par proportionnalite :
c          AM = AB *(d(A,M)/d(A,B))
c
            daux = ( abscnm - abscur(kaux) ) /
     >             ( abscur(kaux+1) - abscur(kaux) )
c
            do 333 , iaux = 1 , sdim
              coop(iaux) = cooa(iaux) +
     >                 daux * ( geocoo(somseg(kaux+1),iaux)-cooa(iaux))
  333       continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) (coop(iaux),iaux=1,sdim)
#endif
c
#ifdef _DEBUG_HOMARD_
          else
      write (ulsort,90006) '.. Le noeud est extremite du segment', kaux
#endif
c
          endif
c
          goto 30
c
        endif
c
   33 continue
c
      if ( seg.eq.0 ) then
        codret = 2
      endif
c
      endif
c
   30 continue
c
c 3.4. ==> Si l'arete est sur une ligne fermee, on compare les deux
c          solutions. L'idee est que la bonne est celle ou on va
c          le moins loin !
c
      if ( codret.eq.0 ) then
c
      if ( nbpass.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) ' '
        write (ulsort,90004) 'cooini', (cooini(iaux),iaux=1,sdim)
        write (ulsort,90004) 'coopst', (coopst(iaux),iaux=1,sdim)
        write (ulsort,90004) 'coop  ', (coop(iaux),iaux=1,sdim)
#endif
c
        dist = 0.d0
        daux = 0.d0
        do 341 , iaux = 1 , sdim
          dist = dist + (cooini(iaux) - coopst(iaux))**2
          daux = daux + (cooini(iaux) - coop(iaux))**2
  341   continue
#ifdef _DEBUG_HOMARD_
        write (ulsort,90004) 'dist', dist
        write (ulsort,90004) 'daux', daux
#endif
c
        if ( dist.lt.daux ) then
          do 342 , iaux = 1 , sdim
            coop(iaux) = coopst(iaux)
  342     continue
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'On reprend la premiere projection :'
        write (ulsort,90004) 'coop  ', (coop(iaux),iaux=1,sdim)
#endif
        endif
c
      endif
c
      endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4)) mess14(langue,2,-1), lenoeu
      write (ulsort,texte(langue,6)) mess14(langue,3,-1),
     >                               noeud1, noeud2
      if ( codret.eq.1 ) then
        write (ulsort,texte(langue,9)) mess14(langue,1,-1), kaux
      elseif ( codret.eq.2 ) then
        write (ulsort,texte(langue,10))
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
cgn      ulsort=1
c
      end
