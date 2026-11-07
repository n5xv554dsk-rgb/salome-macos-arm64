      subroutine sfindr ( seglig, cfaare, famare,
     >                    lgetco, taetco,
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
c   Suivi de Frontiere - INhibition du suivi sur les lignes DRoites
c   -        -           --                                 --
c ______________________________________________________________________
c
c but : inhiber le suivi de frontiere pour les aretes pour des
c       aretes pointant vers des droites
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . seglig . e   .0:sfnbli. pointeur dans le tableau somseg : les      .
c .        .     .        . segments de la ligne i sont aux places de  .
c .        .     .        . seglig(i-1)+1 a seglig(i)-1 inclus         .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famare . es  . nbarto . famille des aretes                         .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'SFINDR' )
c
#include "nblang.h"
#include "cofina.h"
#include "cofaar.h"
c
c 0.2. ==> communs
c
#include "front1.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nombar.h"
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer seglig(0:sfnbli)
      integer cfaare(nctfar,nbfare), famare(nbarto)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nretap, nrsset
      integer iaux
c
      integer are
      logical yadroi
c
      character*6 saux
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c                           789012345678901234567890123
      texte(1,4) = '(/,a6,'' INHIBITION SUR LES DROITES'')'
      texte(1,5) = '(33(''=''),/)'
      texte(1,6) = '(''La ligne '',i4,'' est une droite.'')'
c
c                           7890123456789012345678901234567
      texte(2,4) = '(/,a6,'' CANCELLATION ON STRAIGHT LINES'')'
      texte(2,5) = '(37(''=''),/)'
      texte(2,6) = '(''Line # '',i4,'' is a straight line.'')'
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
c===
c 2. Impression des numeros des lignes qui sont droites (2 points)
c    On le memorise temporairement en negativant le numero du premier
c    segment decrivant cette ligne
c===
c
cgn      write (ulsort,90002) 'seglig', (seglig(iaux), iaux = 0, sfnbli)
      yadroi = .false.
c
      do 21 , iaux = 1, sfnbli
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90012) 'Nombre de segments de la ligne', iaux,
     >                      abs(seglig(iaux))-abs(seglig(iaux-1))-2
#endif
        if ( abs(seglig(iaux))-abs(seglig(iaux-1)).eq.3 ) then
c
          write (ulsort,texte(langue,6)) iaux
          seglig(iaux) = -seglig(iaux)
          yadroi = .true.
c
        endif
c
   21 continue
c
c===
c 3. S'il y a des droites : les aretes qui sont situees sur de telles
c    lignes doivent etre retirees du suivi de frontiere : inutile de
c    faire des calculs pour rien !
c===
c
      if ( yadroi ) then
c
c 3.1 ==>  Pour cela, il suffit de changer leur famille : on remplace
c          leur famille actuelle par celle qui a toutes les memes
c          caracteristiques, sauf celle du suivi de frontiere, stockee
c          dans cosfin (cf. vccfam)
c
        do 31 , are = 1, nbarto
c
          iaux = cfaare(cosfli,famare(are))
c
c 3.1 ==> l'arete est active pour le SF : elle est sur la ligne iaux
c
          if ( iaux.gt.0 ) then
c
c 3.1.1 ==> la ligne iaux est une droite
c
            if ( seglig(iaux).lt.0 ) then
c
              famare(are) = cfaare(cosfin,famare(are))
c
            endif
c
          endif
c
   31   continue
c
c 3.2. ==> On remet les numeros positifs
c
        do 32 , iaux = 1, sfnbli
c
          seglig(iaux) = abs(seglig(iaux))
c
   32   continue
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
