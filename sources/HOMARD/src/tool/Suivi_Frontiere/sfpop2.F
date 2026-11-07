      subroutine sfpop2 ( typsfr,
     >                    coonoe,
     >                    somare, np2are,
     >                    cfaare, famare,
     >                    lgetco, taetco,
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
c   Suivi de Frontiere - POsition des noeuds P2
c   -        -           --                  --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typsfr .   s .   1    . type du suivi de frontiere                 .
c .        .     .        . 0 : aucun                                  .
c .        .     .        . 1 : maillage de degre 1, avec projection   .
c .        .     .        .     des nouveaux sommets                   .
c .        .     .        . 2 : maillage de degre 2, seuls les noeuds  .
c .        .     .        .     P1 sont sur la frontiere ; les noeuds  .
c .        .     .        .     P2 restent au milieu des P1            .
c .        .     .        . 3 : maillage de degre 2, les noeuds P2     .
c .        .     .        .     etant sur la frontiere                 .
c . coonoe . es  . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
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
      parameter ( nompro = 'SFPOP2' )
c
#include "nblang.h"
#include "cofaar.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "fracta.h"
c
c 0.3. ==> arguments
c
      integer typsfr
      integer somare(2,nbarto), np2are(nbarto)
      integer cfaare(nctfar,nbfare), famare(nbarto)
c
      double precision coonoe(nbnoto,2)
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
      integer larete, noeud1, noeud2
      integer numlig
c
      character*6 saux
c
      double precision daux, daux1, daux2
      double precision xmil, ymil
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
      codret = 0
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
      texte(1,4) = '(/,a6,'' REPERAGE DES POSITIONS DE NOEUDS P2'')'
      texte(1,5) = '(42(''=''),/)'
      texte(1,6) =
     >'(''. Examen de l''''arete '',i10,'' (ligne '',i8,'')'')'
      texte(1,7) ='(''Ecart au carre     :'',g12.5)'
      texte(1,8) ='(''1/2 arete au carre :'',g12.5)'
      texte(1,9) ='(''Ecart maximal :'',g12.5)'
      texte(1,10) ='(''1/2 arete maximale :'',g12.5)'
      texte(1,11) ='(''Millieme de la 1/2 arete maximale :'',g12.5)'
      texte(1,12) ='(''Les noeuds P2 sont au milieu des aretes.'')'
      texte(1,13) ='(''Les noeuds P2 sont sur la frontiere.'')'
c
      texte(2,4) = '(/,a6,'' LOCALIZATION OF P2 NODES'')'
      texte(2,5) = '(31(''=''),/)'
      texte(2,6) =
     >'(''. Examination of edge #'',i10,'' (line #'',i8,'')'')'
      texte(2,7) ='(''Squared distance  :'',g12.5)'
      texte(2,8) ='(''Squared half edge :'',g12.5)'
      texte(2,9) ='(''Maximum distance :'',g12.5)'
      texte(2,10) ='(''Maximum half edge :'',g12.5)'
      texte(2,11) ='(''1.e-3 maximum half edge :'',g12.5)'
      texte(2,12) ='(''P2 nodes are centers of edges.'')'
      texte(2,13) ='(''P2 nodes are located over border.'')'
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
c====
c 2. On ne s'interesse qu'aux aretes qui font partie d'une frontiere
c    reconnue
c    Il suffit de le faire sur les aretes du macro-maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. ; codret = ', codret
#endif
c
c 2.1. ==> Recherche de l'ecart maximum entre le noeud central et le
c          milieu des 2 extremites, pour chacune des aretes de frontiere
c
      daux1 = 0.d0
      daux2 = 0.d0
c
      do 21 , larete = 1 , nbarma
c
        if ( codret.eq.0 ) then
c
          numlig = cfaare(cosfli,famare(larete))
c
          if ( numlig.gt.0 ) then
#ifdef _DEBUG_HOMARD_
            write(ulsort,texte(langue,6)) larete, numlig
#endif
            noeud1 = somare(1,larete)
            noeud2 = somare(2,larete)
c
            xmil = unsde * ( coonoe(noeud1,1) + coonoe(noeud2,1) )
            ymil = unsde * ( coonoe(noeud1,2) + coonoe(noeud2,2) )
c
            daux = ( coonoe(np2are(larete),1) - xmil ) **2 +
     >             ( coonoe(np2are(larete),2) - ymil ) **2
            daux1 = max(daux1, daux)
#ifdef _DEBUG_HOMARD_
            write(ulsort,texte(langue,7)) daux
#endif
c
            daux = ( coonoe(noeud1,1) - xmil ) **2 +
     >             ( coonoe(noeud1,2) - ymil ) **2
            daux2 = max(daux2, daux)
#ifdef _DEBUG_HOMARD_
            write(ulsort,texte(langue,8)) daux
#endif
c
        endif
c
        endif
c
   21 continue
c
c 2.2. ==> diagnostic : si l'ecart est superieur au millieme de la
c          demi-arete, on considere que les noeuds P2 ont ete mis sur
c          la frontiere
c          C'est un pari ...
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,9)) sqrt(daux1)
      write(ulsort,texte(langue,10)) sqrt(daux2)
      write(ulsort,texte(langue,11)) 1.d-3*sqrt(daux2)
#endif
      if ( daux1.gt.1.d-6*daux2 ) then
        typsfr = 3
      else
        typsfr = 2
      endif
c
      write(ulsort,texte(langue,10+typsfr))
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
