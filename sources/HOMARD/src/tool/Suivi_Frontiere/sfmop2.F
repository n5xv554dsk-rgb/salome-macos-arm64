      subroutine sfmop2 ( coonoe, hetnoe, arenoe,
     >                    somare,
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
c   Suivi de Frontiere - MOdification des noeuds P2
c   -        -           --                      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . es  . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . hetnoe . e   . nbnoto . historique de l'etat des noeuds            .
c . arenoe . e   . nbnoto . 0 pour un sommet, le numero de l'arete pour.
c .        .     .        . un noeud milieu                            .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
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
      parameter ( nompro = 'SFMOP2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
#include "nombno.h"
#include "nombar.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer hetnoe(nbnoto), arenoe(nbnoto)
      integer somare(2,nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
c
      integer lenoeu, lenoe1, lenoe2
      integer larete
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
      texte(1,4) = '(/5x,''Retouche des coordonnees des noeuds P2'')'
      texte(1,5) = '(7x,''Nombre de noeuds modifies : '',i10)'
      texte(1,6) = '(7x,''==> Arete '',i10)'
      texte(1,7) = '(7x,''==> Repositionnement du noeud '',i10)'
c
      texte(2,4) = '(/5x,''Updating of P2 node coordinates'')'
      texte(2,5) = '(7x,''Number of modified nodes : '',i10)'
      texte(2,6) = '(7x,''==> Edge # '',i10)'
      texte(2,7) = '(7x,''==> Relocalization of node # '',i10,)'
c
      codret = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
#endif
c
c====
c 2. retouche des coordonnees des noeuds P2
c    remarque : on repositionne tous les nouveaux noeuds P2
c              on pourrait faire plus malin en ne bougeant que ceux
c              qui doivent l'etre mais c'est assez complique. Il faut
c              tous ceux sur une arete dont l'extremite a bouge par
c              suite de raffinement, et tous ceux qui etaient des P1
c              et qui redeviennent P2 par deraffinement.
c              Au final, cela suppose de reperer des voisinages et
c             donc assez complique et pas forcement economique en CPU
c    remarque : on en fait pas assez. il faudrait faire les noeuds
c               au milieu des quadrangles.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. noeuds P2 ; codret = ', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      jaux = 0
#endif
c
      do 21 , lenoeu = 1 , nbnoto
c
        if ( mod(hetnoe(lenoeu),10).eq.2 ) then
c
c 2.1. ==> Reperage
c
          larete = arenoe(lenoeu)
          lenoe1 = somare(1,larete)
          lenoe2 = somare(2,larete)
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,6)) larete
      write(ulsort,texte(langue,7)) lenoeu
#endif
c
c 2.2. ==> Calcul des coordonnees milieu
c
         do 221 , iaux = 1 , sdim
           coonoe(lenoeu,iaux) =
     >           (coonoe(lenoe1,iaux)+coonoe(lenoe2,iaux))*0.5d0
  221 continue
#ifdef _DEBUG_HOMARD_
         jaux = jaux + 1
#endif
c
        endif
c
   21 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) jaux
      write (ulsort,*)
#endif
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
