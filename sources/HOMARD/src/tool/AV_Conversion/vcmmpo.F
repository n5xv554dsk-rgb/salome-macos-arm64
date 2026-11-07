      subroutine vcmmpo ( noempo, hetmpo, coexmp,
     >                    nnosca, nmpsho, nmpsca,
     >                    fameel, typele,
     >                    povoso, voisom,
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
c    aVant adaptation - Conversion de Maillage - Mailles-POints
c     -                 -             -          -       --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . noempo .  s  . nbmpto . numeros des noeuds associes aux mailles    .
c . hetmpo .  s  . rbar00 . historique de l'etat des mailles-points    .
c . coexmp .  s  . nbmpto*. codes externes sur les mailles-points      .
c .        .     . nctfmp .   1 : famille MED                          .
c .        .     .        .   2 : type de maille-point                 .
c . nnosca . e   . rsnoto . numero des noeuds dans le calcul           .
c . nmpsho .  s  . rsmpac . numero des mailles-points dans HOMARD      .
c . nmpsca .  s  . rsmpto . numero des mailles-points du calcul        .
c . fameel . e   . nbelem . famille med des elements                   .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . voisom . e   . nvosom . voisins des sommets en stockage morse      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'VCMMPO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbutil.h"
#include "nombno.h"
#include "refert.h"
#include "nombmp.h"
#include "nombsr.h"
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer noempo(nbmpto), hetmpo(nbmpto)
      integer nnosca(rsnoto)
      integer nmpsho(rsmpac), nmpsca(rsmpto)
      integer coexmp(nbmpto,nctfmp)
      integer fameel(nbelem), typele(nbelem)
      integer voisom(nvosom), povoso(0:nbnoto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer poinde, poinfi, point, nucode
      integer sommet
      integer lamapo, elem, typhom
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de mailles-points attendues : '',i10)'
      texte(1,5) = '(''Nombre de mailles-points trouvees  : '',i10)'
c
      texte(2,4) = '(''Expected point-meshes : '',i10)'
      texte(2,5) = '(''Found point-meshes    : '',i10)'
c
c 1.2. ==> mise a zero
c
      codret = 0
c
      do 11 , lamapo = 1 , rsmpac
        nmpsho(lamapo) = 0
   11 continue
c
      do 12 , nucode = 1 , nctfmp
        do 121 , lamapo = 1 , nbmpto
          coexmp(lamapo,nucode) = 0
  121   continue
   12 continue
c
      lamapo = 0
c
c====
c 2. on passe en revue chaque sommet
c     remarque : l'exploration se fait dans la numerotation HOMARD
c     ses elements voisins sont dans le tableau voisom, aux places
c     comprises entre povoso(somm-1)+1 et povoso(somm), somm etant le
c     numero dans le calcul correspondant au numero sommet dans
c     homard
c====
c
      do 21 , sommet = 1 , nbnoto
c
        poinde = povoso(nnosca(sommet)-1) + 1
        poinfi = povoso(nnosca(sommet))
c
        do 22 , point = poinde , poinfi
c
c 2.1. ==> caracterisation de l'element
c         elem : son numero global
c         typhom : son type dans HOMARD
c
          elem = voisom(point)
          typhom = medtrf(typele(elem))
c
c 2.2. ==> si l'element est une maille-point, il faut
c              se souvenir de son type et de sa famille MED.
c
          if ( typhom.eq.tyhmpo ) then
c
             lamapo = lamapo + 1
             noempo(lamapo) = sommet
             coexmp(lamapo,1) = fameel(elem)
             coexmp(lamapo,2) = typele(elem)
             nmpsho(elem) = lamapo
             nmpsca(lamapo) = elem
           endif
c
   22   continue
c
   21 continue
c
      if ( lamapo.ne.nbmpto ) then
        write(ulsort,texte(langue,4)) nbmpto
        write(ulsort,texte(langue,5)) lamapo
        codret = 3
      endif
c
c====
c 3. consequences
c====
c
      do 32 , lamapo = 1 , nbmpto
        hetmpo(lamapo) = 0
   32 continue
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
