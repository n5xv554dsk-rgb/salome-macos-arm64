      subroutine utsuno ( nbnold, nbnnew, disnoe,
     >                    hetnoe, ancnoe, nounoe,
     >                    nbnore, nbp2re, nbimre )
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
c    UTilitaire - SUppression des NOeuds
c    --           --              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbnold . e   .   1    . ancien nombre de noeuds                    .
c . nbnnew . e   .   1    . nouveau nombre de noeuds                   .
c . disnoe . e   . nbnnew . indicateurs de disparition des aretes      .
c . hetnoe . es  . nbnold . historique de l'etat des noeuds           .
c . ancnoe .   s . nbnold . anciens numeros des noeuds conserves       .
c . nounoe .   s .0:nbnold. nouveaux numeros des noeuds conserves      .
c . nbnore .   s .   1    . nombre de noeuds restants                  .
c . nbp2re .   s .   1    . nombre de noeuds p2 restants               .
c . nbimre .   s .   1    . nombre de noeuds internes restants         .
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
cgn      character*6 nompro
cgn      parameter ( nompro = 'UTSUNO' )
c
c 0.2. ==> communs
c 0.3. ==> arguments
c
      integer nbnold, nbnnew
      integer disnoe(nbnnew), ancnoe(nbnold)
      integer nounoe(0:nbnold)
      integer hetnoe(nbnold)
      integer nbnore, nbp2re, nbimre
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lenoeu
      integer cmptr, cmptr1
c ______________________________________________________________________
c
#include "impr03.h"
c
c====
c 1. fabrication des tableaux ancnoe et nounoe
c====
c
cgn      write(1,90002) 'nbnold', nbnold
cgn      write(1,90002) 'nbnnew', nbnnew
      nbnore = 0
      nounoe(0) = 0
c
c 1.1. ==> generation des tableaux reciproques
c
      do 100 , lenoeu = 1 , nbnold
cgn      print 90001,'disnoe du noeud', lenoeu, disnoe(lenoeu)
c
c 1.1.1. ==> le noeud disparait :
c            . son etat anterieur, la dizaine, est conserve
c            . son etat courant devient 5, pour "inexistant"
c
        if ( disnoe(lenoeu).ne.0 ) then
c
          nounoe(lenoeu) = 0
          iaux = hetnoe(lenoeu) - mod(hetnoe(lenoeu),10)
          hetnoe(lenoeu) = 10*iaux + 5
c
c 1.1.2. ==> le noeud reste ; on le compte
c
        else
c
          nbnore = nbnore + 1
          ancnoe(nbnore) = ancnoe(lenoeu)
          nounoe(lenoeu) = nbnore
cgn        write(1,*) 'ancnoe(',lenoeu,')',ancnoe(lenoeu)
cgn        write(1,*) 'ecriture dans ancnoe(', nbnore,') =',ancnoe(nbnore)
c
        endif
cgn      print *,'ecriture dans nounoe(', lenoeu,')'
c
  100 continue
cgn      print 90002, '==> apres 100, nbnore', nbnore
c
c 1.2. ==> nombre de noeuds restants apres suppression
c     (pour la remise a jour du nombre d'entites du maillage)
c
      cmptr = 0
      cmptr1 = 0
      do 120 , lenoeu = 1 , nbnold
cgn      write(*,90002) 'hetnoe(lenoeu)', hetnoe(lenoeu)
        if ( mod (hetnoe(lenoeu),10).eq.2 ) then
          cmptr = cmptr + 1
        elseif ( mod (hetnoe(lenoeu),10).eq.4 ) then
          cmptr1 = cmptr1 + 1
        endif
  120 continue
      nbp2re = cmptr
      nbimre = cmptr1
c
cgn      write(*,90002) 'nbnore', nbnore
cgn      write(*,90002) 'nbp2re', nbp2re
cgn      write(*,90002) 'nbimre', nbimre
c
      end
