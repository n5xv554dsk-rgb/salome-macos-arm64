      subroutine utvgvq ( lequad,
     >                    volqua, pypequ,
     >                    nbhexa, nbpyra, nbpent,
     >                    livoqu,
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
c     UTilitaire : VoisinaGes Volumes / Quadrangles
c     --           -      -   -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   .   1    . quadrangle a traiter                       .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . nbhexa .  s  .   1    . nombre d'hexaedres voisins                 .
c . nbpyra .  s  .   1    . nombre de pyramides voisines               .
c . nbpent .  s  .   1    . nombre de pentaedres voisins               .
c . livoqu .  s  .   *    . liste des voisins                          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . non nul : probleme                         .
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
      parameter ( nompro = 'UTVGVQ' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "nombqu.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer lequad
      integer nbhexa, nbpyra, nbpent
      integer volqua(2,nbquto), pypequ(2,*)
c
      integer livoqu(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
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
#ifdef _DEBUG_HOMARD_
      texte(1,5) = '(''.. '',a,''numero'',i10)'
      texte(1,6) = '(''.. Nombre de voisins de type '',a,'':'',i10)'
c
      texte(2,5) = '(''.. '',a,''#'',i10)'
      texte(2,6) = '(''.. Number of neighbours '',a,''type :'',i10)'
#endif
c
c 1.2. ==> prealables
c
      codret = 0
c
      nbhexa = 0
      nbpyra = 0
      nbpent = 0
c
c====
c 2. decompte des elements de volumes voisins
c====
c
      if ( nbheto.gt.0 .or.
     >     nbpyto.gt.0 .or. nbpeto.gt.0 ) then
c
      do 2 , iaux = 1 , 8
        livoqu(iaux) = 0
    2 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,4), lequad
#endif
c
      do 20 , iaux = 1 , 2
c
        jaux = volqua(iaux,lequad)
c
c 2.1. ==> voisinage par un hexaedre
c
        if ( jaux.gt.0 ) then
c
          do 21 , kaux = 1 , nbhexa
            if ( livoqu(2+kaux).eq.jaux ) then
              goto 20
            endif
   21     continue
          nbhexa = nbhexa + 1
          livoqu(2+nbhexa) = jaux
c
        elseif ( jaux.lt.0 ) then
c
c 2.2. ==> voisinage par une pyramide
c
          if ( pypequ(1,-jaux).gt.0 ) then
            do 22 , kaux = 1 , nbpyra
              if ( livoqu(4+kaux).eq.pypequ(1,-jaux) ) then
                goto 20
              endif
   22       continue
            nbpyra = nbpyra + 1
            livoqu(4+nbpyra) = pypequ(1,-jaux)
          endif
c
c 2.3. ==> voisinage par un pentaedre
c
          if ( pypequ(2,-jaux).gt.0 ) then
            do 23 , kaux = 1 , nbpent
              if ( livoqu(6+kaux).eq.pypequ(2,-jaux) ) then
                goto 20
              endif
   23       continue
            nbpent = nbpent + 1
            livoqu(6+nbpent) = pypequ(2,-jaux)
          endif
c
        endif
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,6), nbhexa
      write (ulsort,texte(langue,6)) mess14(langue,1,5), nbpyra
      write (ulsort,texte(langue,6)) mess14(langue,1,7), nbpent
      write (ulsort,2000) (livoqu(iaux),iaux=1,8)
 2000 format(2i10)
#endif
c
      endif
c
c====
c 3. La fin
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
