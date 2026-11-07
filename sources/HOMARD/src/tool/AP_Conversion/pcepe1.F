      subroutine pcepe1 ( nbfonc, ngauss, deraff,
     >                    prfcan, prfcap,
     >                    hethex, anchex, filhex, fhpyte,
     >                    nbanhe, anfihe, anhehe, anpthe,
     >                    nheeca, nhesca,
     >                    nteeca, ntesca,
     >                    npyeca, npysca,
     >                    vafoen, vafott,
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
c    aPres adaptation - Conversion de solution - aux noeuds par Element
c     -                 -                                       -
c                       PEntaedres - degre 1
c                       --                -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .    1   . nombre de fonctions aux points de Gauss    .
c . ngauss . e   .   1    . nbre de points de Gauss des fonctions pg   .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . hethex . e   . nbheto . historique de l'etat des pentaedres         .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . nbanhe . e   .   1    . nombre de pentaedres decoupes par           .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfihe . e   . nbanhe . tableau filhex du maillage de l'iteration n.
c . anhehe . e   . nbanhe . tableau hethex du maillage de l'iteration n.
c . anpthe . e   .  2**   . tableau fhpyte du maillage de l'iteration n.
c . nheeca . e   .    *   . pentaedres en entree dans le calcul         .
c . nhesca . e   . rsheto . numero des pentaedres dans le calcul        .
c . nteeca . e   .    *   . tetraedres en entree dans le calcul        .
c . ntesca . e   . rsteto . tetraedres en sortie dans le calcul        .
c . npyeca . e   .    *   . pyramides en entree dans le calcul         .
c . npysca . e   . rspyto . numero des pyramides dans le calcul sortie .
c . vafoen .   e . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
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
      parameter ( nompro = 'PCEPE1' )
c
#include "nblang.h"
#include "fracti.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombsr.h"
#include "nomber.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer ngauss
      integer prfcan(*), prfcap(*)
      integer hethex(nbheto), anchex(*)
      integer filhex(nbheto), fhpyte(2,nbheco)
      integer nbanhe, anfihe(nbanhe), anhehe(nbanhe), anpthe(2,*)
      integer nheeca(reheto), nhesca(rsheto)
      integer nteeca(reteto), ntesca(rsteto)
      integer npyeca(repyto), npysca(rspyto)
c
      double precision vafoen(*)
      double precision vafott(*)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
c     pehn   = Pentaedre courant en numerotation Homard a l'it. N
c     pehnp1 = Pentaedre courant en numerotation Homard a l'it. N+1
c
      integer pehn, pehnp1
c
c     etan   = ETAt du pentaedre a l'iteration N
c     etanp1 = ETAt du pentaedre a l'iteration N+1
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
c
      codret = 0
c ______________________________________________________________________
c
c====
c 2. on boucle sur tous les pentaedres du maillage HOMARD n+1
c    on trie en fonction de l'etat de l'pentaedre dans le maillage n
c    remarque : on a scinde en plusieurs programmes pour pouvoir passer
c    les options de compilation optimisees.
c====
c
      if ( nbfonc.ne.0 ) then
c
      do 20 , pehnp1 = 1 , nbheto
c
c 2.1. ==> caracteristiques de l'pentaedre :
c 2.1.1. ==> son numero homard dans le maillage precedent
c
        if ( deraff ) then
          pehn = anchex(pehnp1)
        else
          pehn = pehnp1
        endif
c
c 2.1.2. ==> l'historique de son etat
c          On rappelle que l'etat vaut :
c      etat = 0 : le pentaedre est actif.
c      etat =  1, ..., 24 : l'pentaedre est coupe en 2 pyramides et
c                           12 tetraedres ; il y a eu deraffinement.
c      etat = 31, ..., 35 : l'pentaedre est coupe en 2 pyramides et
c                           12 tetraedres ; il y a eu deraffinement.
c      etat = 41, ..., 46 : l'pentaedre est coupe en 5 pyramides et
c                           4 tetraedres selon la face 1, ..., 6 ; il y
c                           a eu deraffinement.
c      etat = 61, ..., 72 : l'pentaedre est coupe en 4 pyramides selon
c                           l'arete 1, .., 12 ; il y a eu deraffinement.
c      etat = 55 : l'pentaedre n'existait pas ; il a ete produit par
c                  un decoupage.
c      etat = 80 : l'pentaedre est coupe en 8.
c      etat = 81, ..., 88 : l'pentaedre est coupe en 18 tetraedres ; il
c                           y a eu deraffinement.
c
        etanp1 = mod(hethex(pehnp1),1000)
        etan   = (hethex(pehnp1)-etanp1) / 1000
c
cgn        write (ulsort,1792) 'Hexaedre', pehn, etan, pehnp1, etanp1
c
c=======================================================================
c 2.1. ==> etan = 0 : le pentaedre etait actif
c=======================================================================
        codret = 20
c
   20 continue
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
