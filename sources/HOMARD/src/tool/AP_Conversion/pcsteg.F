      subroutine pcsteg ( nbfonc, ngauss, nbnorf, typgeo, deraff,
     >                    prfcan, prfcap,
     >                    hettet, anctet,
     >                    filtet,
     >                    nbante, anfite,
     >                    nteeca, ntesca,
     >                    vafoen, vafott,
     >                    conorf, copgrf, wipg,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c                       TEtraedres a plusieurs points de Gauss
c                       --                               -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .    1   . nombre de fonctions aux points de Gauss    .
c . ngauss . e   .   1    . nbre de points de Gauss des fonctions pg   .
c . nbnorf . e   .   1    . nbre de noeuds de l'element de reference   .
c . typgeo . e   .   1    . type geometrique au sens MED               .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . nbante . e   .   1    . nombre de tetraedres decoupes par          .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfite . e   . nbante . tableau filtet du maillage de l'iteration n.
c . nteeca . e   .    *   . numero des tetraedres dans le calcul entree.
c . ntesca . e   . rsteto . numero des tetraedres dans le calcul sortie.
c . vafoen .   e . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
c . conorf . e   .  sdim* . coordonnees des noeuds de l'element de     .
c .        .     . nbnorf . reference                                  .
c . copgrf . e   .  sdim* . coordonnees des points de Gauss            .
c .        .     . ngauss . de l'element de reference                  .
c . wipg   .  a  . nbnorf*. fonctions de forme exprimees aux points de .
c .        .     . ngauss . Gauss                                      .
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
      parameter ( nompro = 'PCSTEG' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombte.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer ngauss, nbnorf, typgeo
      integer prfcan(*), prfcap(*)
      integer hettet(nbteto), anctet(*)
      integer filtet(nbteto)
      integer nbante, anfite(nbante)
      integer nteeca(reteto), ntesca(rsteto)
c
      double precision vafoen(nbfonc,ngauss,*)
      double precision vafott(nbfonc,ngauss,*)
      double precision conorf(sdim,nbnorf), copgrf(sdim,ngauss)
      double precision wipg(nbnorf,ngauss)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
c     tehn   = TEtraedre courant en numerotation Homard a l'it. N
c     tehnp1 = TEtraedre courant en numerotation Homard a l'it. N+1
c
      integer tehn, tehnp1
c
c     etan   = ETAt du tetraedre a l'iteration N
c     etanp1 = ETAt du tetraedre a l'iteration N+1
c
      integer etan, etanp1
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
#include "pcimp0.h"
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
#include "impr03.h"
cgn      write (ulsort,*) 'prfcan en entree de '//nompro
cgn      write (ulsort,91020) (prfcan(iaux),iaux=1,17)
cgn      write (ulsort,*) 'nteeca en entree de '//nompro
cgn      write (ulsort,91020) (nteeca(iaux),iaux=1,5)
cgn      write (ulsort,*) 'vafoen en entree de '//nompro
cgn      do 111 , etan = 1 , nbfonc
cgn      write (ulsort,90002) 'composante',etan
cgn      do 1111 , etanp1 = 1 , 8
cgn        write (ulsort,92010) (vafoen(etan,etanp1,iaux),iaux=1,5)
cgn 1111 continue
cgn  111 continue
c
      codret = 0
c
c====
c 2. on boucle sur tous les tetraedres du maillage HOMARD n+1
c    on trie en fonction de l'etat du tetraedre dans le maillage n
c    on numerote les paragraphes en fonction de la documentation, a
c    savoir : le paragraphe doc.n.p traite de la mise a jour de solution
c    pour un tetraedre dont l'etat est passe de n a p.
c    les autres paragraphes sont numerotes classiquement
c    remarque : on a scinde en plusieurs programmes pour pouvoir passer
c    les options de compilation optimisees.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Boucle ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbfonc.ne.0 ) then
c
      do 30 , tehnp1 = 1 , nbteto
c
c 2.1. ==> caracteristiques du tetraedre :
c 2.1.1. ==> son numero homard dans le maillage precedent
c
        if ( deraff ) then
          tehn = anctet(tehnp1)
        else
          tehn = tehnp1
        endif
c
c 2.1.2. ==> l'historique de son etat
c          On rappelle que l'etat vaut :
c      etan = 0 : le tetraedre etait actif.
c      etan = 21, ..., 26 : le tetraedre etait coupe en 2 selon
c                           l'arete 1, ..., 6 ; il y a eu deraffinement.
c      etan = 41, ..., 44 : le tetraedre etait coupe en 4 selon la
c                           face 1, ..., 4 ; il y a eu deraffinement.
c      etan = 45, 46, 47 : le tetraedre etait coupe en 4 selon la
c                          diagonale 1-6, 2-5, 3-4 ; il y a eu
c                          deraffinement.
c      etan = 55 : le tetraedre n'existait pas ; il a ete produit par
c                  un decoupage.
c      etan = 85, 86, 87 : le tetraedre etait coupe en 8 selon la
c                          diagonale 1-6, 2-5, 3-4 ; il y a eu
c                          deraffinement.
c
        etanp1 = mod(hettet(tehnp1),100)
        etan   = (hettet(tehnp1)-etanp1) / 100
c
cgn        write (ulsort,1792) 'Tetraedre', tehn, etan, tehnp1, etanp1
c
c=======================================================================
c doc.0.p. ==> etan = 0 : le tetraedre etait actif
c=======================================================================
c
        if ( etan.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSPT0', nompro
#endif
c
          call pcspt0 ( etan, etanp1, tehn, tehnp1,
     >                  prfcan, prfcap,
     >                  filtet,
     >                  nteeca, ntesca,
     >                  nbfonc, ngauss, vafoen, vafott,
     >                  ulsort, langue, codret )
c
c=======================================================================
c doc.21-26.p. ==> etan = 21, ..., 26 : le tetraedre etait coupe en 2
c=======================================================================
c
        elseif ( etan.ge.21 .and. etan.le.26 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSPT2', nompro
#endif
c
          call pcspt2 ( etan, etanp1, tehn, tehnp1,
     >                  prfcan, prfcap,
     >                  hettet, filtet, nbante, anfite,
     >                  nteeca, ntesca,
     >                  nbfonc, ngauss, vafoen, vafott,
     >                  ulsort, langue, codret )
c
c=======================================================================
c doc.41-44.p. ==> etan = 41, ..., 44 : le tetraedre etait coupe en 4
c                  selon la face 1, 2, 3, 4
c doc.45-47.p. ==> etan = 45, 46, 47 : le tetraedre etait coupe en 4
c                  selon une diagonale
c=======================================================================
c
        elseif ( etan.ge.41 .and. etan.le.47 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSPT4', nompro
#endif
c
          call pcspt4 ( etan, etanp1, tehn, tehnp1,
     >                  prfcan, prfcap,
     >                  hettet, filtet, nbante, anfite,
     >                  nteeca, ntesca,
     >                  nbfonc, ngauss, vafoen, vafott,
     >                  ulsort, langue, codret )
c
c=======================================================================
c doc.85-87.p. ==> etan = 85, 86, 87 : le tetraedre etait coupe en 8
c                  selon une diagonale
c=======================================================================
c
        elseif ( etan.ge.85 .and. etan.le.87 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSPT8', nompro
#endif
c
          call pcspt8 ( etanp1, tehn, tehnp1,
     >                  prfcan, prfcap,
     >                  filtet, nbante, anfite,
     >                  nteeca, ntesca,
     >                  nbfonc, ngauss, vafoen, vafott,
     >                  ulsort, langue, codret )
c
        endif
c
   30 continue
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
