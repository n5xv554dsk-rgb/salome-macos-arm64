      subroutine mmagr0 ( voltri,
     >                    famtet, cfatet,
     >                    tbaux1, tbaux2,
     >                    nbjois, nbpejs,
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
c    Modification de Maillage - AGRegat - phase 0
c    -               -          ---             -
c    Reperage des triangles a l'interface entre deux grains
c    . Memorisation des familles MED de part et d'autre d'un joint
c    . Decompte du nombre de pentaedres a creer
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . famtet . e   . nbteto . famille des tetraedres                     .
c . cfatet . e   . nctfte. codes des familles des tetraedres           .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
c . tbaux1 .   s .   4**  . Pour le i-eme pentaedre de joint simple :  .
c .        .     .        . (1,i) : numero du triangle a dupliquer     .
c .        .     .        . (2,i) : numero du joint simple cree        .
c .        .     .        . (3,i) : tetraedre du cote min(fammed)      .
c .        .     .        . (4,i) : tetraedre du cote max(fammed)      .
c . tbaux2 .  s  .   4**  . Pour le i-eme joint :                      .
c .        .     .        . Numeros des familles MED des volumes       .
c .        .     .        . jouxtant le pentaedre/hexaedre, classes du .
c .        .     .        . plus petit (1,i) au plus grand             .
c .        .     .        . 0, si pas de volume voisin                 .
c . nbjois .  s  .   1    . nombre de joints simples                   .
c . nbpejs .  s  .   1    . nombre de pentaedres de joints simples     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'MMAGR0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "coftex.h"
#include "nbfami.h"
#include "dicfen.h"
#include "nombtr.h"
#include "nombte.h"
c
c 0.3. ==> arguments
c
      integer voltri(2,nbtrto)
      integer famtet(nbteto), cfatet(nctfte,nbftet)
      integer tbaux1(4,nbtrto), tbaux2(4,*)
c
      integer nbjois, nbpejs
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer famhom(2), fammed(2)
      integer letet1, letet2
      integer nujoin
c
      integer nbmess
      parameter ( nbmess = 30 )
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
#include "impr03.h"
#include "mmag01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,19)) mess14(langue,3,3), nbftet
#endif
c
      codret = 0
c
c====
c 2. Parcours des triangles
c    Si les caracteristiques des deux tetraedres voisins sont les
c    memes, on ne fait rien.
c    Si le groupe des deux tetraedres voisins est different, on
c    memorise l'information : pentaedre a creer et famille
c    Remarque : on part du principe qu'une famille MED est identifiee
c               a un groupe, donc un grain
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,2)
#endif
c
      nbpejs = 0
      nbjois = 0
c
      do 21 , iaux = 1 , nbtrto
c
        if ( voltri(2,iaux).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,2), iaux
#endif
c
c 2.1. ==> Comparaison des familles HOMARD
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) mess14(langue,3,3),
     >                     voltri(1,iaux),voltri(2,iaux)
#endif
          famhom(1) = famtet(voltri(1,iaux))
          famhom(2) = famtet(voltri(2,iaux))
cgn          write(ulsort,*) famhom(1),famhom(2)
          if ( famhom(1).eq.famhom(2) ) then
            goto 21
          endif
c
c 2.2. ==> Comparaison des familles MED
c
          fammed(1) = cfatet(cofamd,famhom(1))
          fammed(2) = cfatet(cofamd,famhom(2))
cgn          write(ulsort,*) fammed(1),fammed(2)
          if ( fammed(1).eq.fammed(2) ) then
            goto 21
          endif
c
c 2.4. ==> Si on arrive ici, un pentaedre de joint simple est a creer.
c          Quel joint pour ce pentaedre ?
c
          do 24 , jaux = 1 , nbjois
cgn            write(ulsort,*) jaux,tbaux2(1,jaux),tbaux2(2,jaux)
            if ( ( tbaux2(1,jaux).eq.fammed(1) .and.
     >             tbaux2(2,jaux).eq.fammed(2) ) .or.
     >           ( tbaux2(1,jaux).eq.fammed(2) .and.
     >             tbaux2(2,jaux).eq.fammed(1) ) ) then
              nujoin = jaux
              goto 241
            endif
   24     continue
c
c         Il faut creer un nouveau joint
c
          nbjois = nbjois + 1
cgn      write (ulsort,texte(langue,6)) nbjois
cgn      write (ulsort,texte(langue,20)) fammed(1),fammed(2)
          tbaux2(1,nbjois) = min(fammed(1),fammed(2))
          tbaux2(2,nbjois) = max(fammed(1),fammed(2))
          nujoin = nbjois
c
  241     continue
c
c 2.5. ==> Reperage du positionnement du triangle pour le tetraedre
c          du cote 1
c
          if ( fammed(1).eq.tbaux2(1,nujoin) ) then
            letet1 = voltri(1,iaux)
            letet2 = voltri(2,iaux)
          else
            letet1 = voltri(2,iaux)
            letet2 = voltri(1,iaux)
          endif
cgn         if ( iaux.eq.33 .or. iaux.eq.56 ) then
cgn      write (ulsort,90001)'triangle', iaux,
cgn     >       fammed(1),fammed(2),tbaux2(1,nbjois)
cgn      write (ulsort,90002)'   voltri', voltri(1,iaux),voltri(2,iaux)
cgn      write (ulsort,90002)'=> letet1', letet1
cgn            endif
c
c 2.6. ==> Pour ce pentaedre :
c          1 : son triangle de base est le courant
c          2 : son joint simple
c          3 : le tetraedre du cote 1
c          4 : le tetraedre du cote 2
c
          nbpejs = nbpejs + 1
c
          tbaux1(1,nbpejs) = iaux
          tbaux1(2,nbpejs) = nujoin
          tbaux1(3,nbpejs) = letet1
          tbaux1(4,nbpejs) = letet2
c
        endif
c
   21 continue
c
c====
c 3. Messages
c====
c
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,12)) nbjois
      if ( nbjois.gt.0 ) then
        write (ulsort,texte(langue,11)) mess14(langue,3,7), nbpejs
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,1000)
      iaux = 1
      jaux = nbjois
      do 31 , nujoin = iaux, jaux
        write (ulsort,1001) nujoin, tbaux2(1,nujoin), tbaux2(2,nujoin)
   31 continue
      write (ulsort,1002)
c
 1000 format( /,5x,31('*'),
     >        /,5x,'*  Joint  *',2('   MED   *'),
     >        /,5x,31('*'))
 1001 format(4x,3(' *',i8),' *')
 1002 format(5x,31('*'),/)
#endif
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
