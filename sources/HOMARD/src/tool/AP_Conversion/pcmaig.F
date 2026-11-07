      subroutine pcmaig ( nbele0, nbelig,
     >                    coueig, noeeig,
     >                    elemen, typele, fameel, noeele,
     >                    nnosca, ancnoe, trav1a, deraff,
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
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbele0 . e   .   1    . estimation du nombre d'elements            .
c . nbelig . e   .   1    . nombre d'elements elimines                 .
c . noeeig .  s  .nbelig**. noeuds des elements                        .
c . coueig .  s  . nbelig . famille med des elements                   .
c . elemen . es  .   1    . numero de l'element en cours               .
c . noeele . es  . nbele0 . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . typele . es  . nbele0 . type des elements                          .
c . fameel . es  . nbele0 . famille med des elements                   .
c . nnosca . e   .   *    . numero des noeuds dans le calcul           .
c . ancnoe . e   . nbnoto . ancien numero de noeud si deraffinement    .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
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
      parameter ( nompro = 'PCMAIG' )
c
#include "nblang.h"
#include "referx.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "meddc0.h"
#include "nombno.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer nbele0, nbelig
      integer coueig(nbelig)
      integer noeeig(nbelig,*)
      integer elemen, typele(nbele0), fameel(nbele0)
      integer noeele(nbele0,nbmane)
      integer nnosca(*), ancnoe(*), trav1a(*)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer noeud, typeig
      integer nbnoel
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'deraff = ',deraff
      write (ulsort,*) 'nbele0, nbmane = ', nbele0,nbmane
#endif
c
c====
c 2. s'il y a eu du deraffinement, il faut construire la table qui faitc
c    passer de l'ancien au nouveau numero de noeud HOMARD. Cela permet
c    de trouver le bon numero pour la connectivite.
c    remarque : cela aurait pu etre fait dans cmdcno, mais on prefere
c    le mettre ici pour ne pas polluer la phase d'adaptation avec des
c    informations sur les elemenst exotiques.
c====
c
      if ( deraff ) then
c
        do 21 , noeud = 1 , nbnoto
          if ( ancnoe(noeud).gt.0 ) then
            trav1a(ancnoe(noeud)) = noeud
          endif
   21   continue
c
      endif
c
c====
c 3. on passe en revue chaque maille.
c    quand c'est un element qui doit etre ignore on memorise son
c    nombre de noeuds et on transfere sa description dans la structure
c    HOMARD
c====
c
      if ( degre.eq.1 ) then
        typeig = edpyr5
        nbnoel = 5
      else
        typeig = edpy13
        nbnoel = 13
      endif
c
      do 31 , iaux = 1 , nbelig
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,*) 'Element ',iaux
#endif
c
        elemen = elemen + 1
        typele(elemen) = typeig
        fameel(elemen) = coueig(iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '==> elemen = ',elemen
      write (ulsort,*) '    noeeig : ',
     >                 (noeeig(iaux,noeud),noeud=1,nbnoel)
#endif
c
        if ( deraff ) then
          do 311 , noeud = 1 , nbnoel
            noeele(elemen,noeud) = trav1a(nnosca(noeeig(iaux,noeud)))
  311     continue
        else
          do 312 , noeud = 1 , nbnoel
            noeele(elemen,noeud) = nnosca(noeeig(iaux,noeud))
  312     continue
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '    noeele : ',
     > (noeele(elemen,noeud),noeud=1,nbnoel)
#endif
c
   31 continue
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
