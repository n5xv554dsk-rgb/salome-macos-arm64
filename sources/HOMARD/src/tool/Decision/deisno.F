      subroutine deisno ( ncmpin, nosupp, noindi,
     >                    arsupp, arindi, nbval,
     >                    hetare, somare,
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
c    traitement des DEcisions - Initialisations - par Saut - NOeuds
c                   --          -                     -      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . nosupp . e   . nbnoto . support pour les noeuds                    .
c . noindi . e   . nbnoto . valeurs reelles pour les noeuds            .
c . arsupp .  s  . nbarto . support pour les aretes                    .
c . arindi .  s  . nbarto . valeurs reelles pour les aretes            .
c . nbval  .  s  .    1   . nombres de valeurs pour les aretes         .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEISNO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer ncmpin
      integer nosupp(nbnoto)
      integer arsupp(nbarto)
      integer nbval
      integer hetare(nbarto), somare(2,nbarto)
c
      integer ulsort, langue, codret
c
      double precision noindi(nbnoto,ncmpin)
      double precision arindi(nbarto,ncmpin)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer noeud1, noeud2
      integer typenh
      integer nrcomp
cgn      integer glop
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
c 1.1. ==> Les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =' (''. Saut entre '',a)'
c
      texte(2,4) = '(''. Jump between '',a)'
c
      codret = 0
c
      typenh = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
c
c====
c 2. On affecte a chaque arete l'ecart du champ entre ses deux noeuds
c    extremites. On ne tient pas compte du noeud milieu en degre 2.
c    Attention : il ne faut s'interesser qu'aux aretes actives, sinon
c    on cree des sauts artificiels !
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> A priori, aucune arete n'est concernee
c
      do 21 , iaux = 1 , nbarto
        arsupp(iaux) = 0
   21 continue
      nbval = 0
c
      do 20 , iaux = 1, nbarto
c
        if ( mod(hetare(iaux),10).eq.0 ) then
c
cgn        glop=0
cgn        if ( iaux.le.-42 ) then
cgn        glop = 1
cgn        endif
c
          noeud1 = somare(1,iaux)
          noeud2 = somare(2,iaux)
          if ( nosupp(noeud1).ne.0 .and. nosupp(noeud2).ne.0 ) then
c
          nbval = nbval + 1
          arsupp(iaux) = 1
          do 200 , nrcomp = 1 , ncmpin
            arindi(iaux,nrcomp) = abs ( noindi(noeud1,nrcomp) -
     >                                  noindi(noeud2,nrcomp) )
  200     continue
cgn        if ( glop.eq.1) then
cgn      write(ulsort,*)'==========================='
cgn      write(ulsort,*)'ARETE = ',iaux
cgn      write(ulsort,*)'  Noeud 1 = ',noeud1,', d''indic '
cgn      write(ulsort,*)(noindi(noeud1,nrcomp), nrcomp = 1 , ncmpin)
cgn      write(ulsort,*)'  Noeud 2 = ',noeud2,', d''indic '
cgn      write(ulsort,*)(noindi(noeud2,nrcomp), nrcomp = 1 , ncmpin)
cgn      write(ulsort,*)'  ==> champ ',
cgn     >               (arindi(iaux,nrcomp),nrcomp=1 , ncmpin)
cgn        endif
c
          endif
c
        endif
c
   20 continue
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
      write (ulsort,texte(langue,5)) typenh
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
