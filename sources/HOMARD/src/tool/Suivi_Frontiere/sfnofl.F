      subroutine sfnofl ( ntrav1, ntrav2, ntrav3,
     >                    adnuno, adlino, adacno,
     >                    unst2x, epsid2,
     >                    coonoe,
     >                    somare, hetare, filare, np2are,
     >                    cfaare, famare,
     >                    geocoo, abscur,
     >                    somseg, seglig,
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
c   Suivi de Frontiere - NOeuds du maillage de calcul
c   -        -           --
c                        sur la Frontiere - Lignes
c                               -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ntrav1 .  s  .   1    . tableau de numnoe = imem(adnuno)           .
c . ntra2v .  s  .   1    . tableau de lignoe = imem(adlino)           .
c . ntrav3 .  s  .   1    . tableau de abscno = rmem(adacno)           .
c . adnuno .  s  .   1    . liste des noeuds de calcul sur le bord     .
c . adlino .  s  .   1    . liste lignes pour ces noeuds               .
c . adacno .  s  .   1    . abscisse curviligne de ces noeuds          .
c . unst2x . e   .   1    . inverse de la taille maximale au carre     .
c . epsid2 . e   .   1    . precision relative pour carre de distance  .
c . coonoe . es  . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
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
c . famare . e   . nbarto . famille des aretes                         .
c . geocoo . e   .sfnbso**. coordonnees des sommets de la frontiere    .
c . abscur . e   . sfnbse . abscisse curviligne des somm des segments  .
c . somseg . e   . sfnbse . liste des sommets des lignes separees par  .
c                           des 0                                      .
c . seglig . e   .0:sfnbli. pointeur dans le tableau somseg : les      .
c .        .     .        . segments de la ligne i sont aux places de  .
c .        .     .        . seglig(i-1)+1 a seglig(i)-1 inclus         .
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
      parameter ( nompro = 'SFNOFL' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "envca1.h"
#include "front1.h"
#include "front2.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision unst2x, epsid2
      double precision coonoe(nbnoto,sdim), geocoo(sfnbso,sdim)
      double precision abscur(sfnbse)
c
      integer adnuno, adlino, adacno
      integer seglig(0:sfnbli), somseg(sfnbse)
      integer famare(nbarto), cfaare(nctfar,nbfare)
      integer somare(2,nbarto), hetare(nbarto), filare(nbarto)
      integer np2are(nbarto)
c
      character*8 ntrav1, ntrav2, ntrav3
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
      integer adsegn
      integer codre0
      integer codre1, codre2, codre3, codre4
c
      character*6 saux
      character*8 ntrava
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
      texte(1,4) = '(/,a6,'' NOEUDS INITIAUX SUR LA FRONTIERE'')'
      texte(1,5) = '(39(''=''),/)'
      texte(1,6) = '(''. Nombre de '',a,''   :'',i10)'
      texte(1,7) = '(''. Inverse du carre de la taille :'',g15.7)'
      texte(1,8) = '(''. Precision relative            :'',g15.7)'
c
      texte(2,4) = '(/,a6,'' INITIAL NODES AND BOUNDARY'')'
      texte(2,5) = '(33(''=''),/)'
      texte(2,6) = '(''. Number of '',a,''    :'',i10)'
      texte(2,7) = '(''. 1./max distance ** 2            :'',g15.7)'
      texte(2,8) = '(''. Relative precision for equality :'',g15.7)'
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,-1), nbnoto
      write (ulsort,texte(langue,6)) mess14(langue,3,1), nbarto
      write (ulsort,texte(langue,7)) unst2x
      write (ulsort,texte(langue,8)) epsid2
#endif
c
c====
c 2. Estimation du nombre de noeuds du maillage de calcul qui sont
c    sur une ligne de frontiere
c====
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '2. Estimation ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFNNFL', nompro
#endif
      call sfnnfl ( hetare,
     >              cfaare, famare,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 3. Allocations
c====
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '3. Allocations ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', mcnxnf, adnuno, codre1 )
      call gmalot ( ntrav2, 'entier  ', mcnxnf, adlino, codre2 )
      call gmalot ( ntrav3, 'reel    ', mcnxnf, adacno, codre3 )
      call gmalot ( ntrava, 'entier  ', nbnoto, adsegn, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 4. Etablissement du lien des sommets
c====
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '4. Liens sommets/lignes ; codret = ', codret
#endif
cgn 1001 format(a,' :',i10,', ',3g13.5)
cgn      do 41 ,codre0=1,nbnoto
cgn      write (ulsort,1001) 'n', codre0,
cgn     >(coonoe(codre0,iaux),iaux = 1 , sdim)
cgn   41 continue
c
      if ( codret.eq.0 ) then
c
cgn 1001 format('Noeud ',i8,' :',3g16.9)
cgn      codre1=115
cgn      write (ulsort,1001)
cgn     >    codre1,(coonoe(codre1,iaux),iaux=1,sdim)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFLISO', nompro
#endif
      call sfliso ( imem(adnuno), imem(adlino), rmem(adacno),
     >              unst2x, epsid2,
     >              coonoe,
     >              somare, hetare, filare, np2are,
     >              cfaare, famare,
     >              geocoo, abscur,
     >              somseg, seglig, imem(adsegn),
     >              ulsort, langue, codret )
c
      endif
cgn      codre1=115
cgn      write (ulsort,1001)
cgn     >    codre1,(coonoe(codre1,iaux),iaux=1,sdim)
cgn      do 42 ,codre0=1,nbnoto
cgn      write (ulsort,1001) 'n', codre0,
cgn     >(coonoe(codre0,iaux),iaux = 1 , sdim)
cgn   42 continue
c
cgn      call gmprot ( nompro//' apres SFLISO', ntrav1, 1, mcnvnf )
cgn      call gmprot ( nompro//' apres SFLISO', ntrav2, 1, mcnvnf )
cgn      call gmprot ( nompro//' apres SFLISO', ntrav3, 1, mcnvnf )
c
c====
c 5. Menage
c====
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '5. Menage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrava, codret )
c
      endif
c
c====
c 6. la fin
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


