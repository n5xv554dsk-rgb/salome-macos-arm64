      subroutine uthcnb ( etdare,
     >                    nbreso, nbrear, nbrepy, nbrete, nbrehe,
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
c     UTilitaire : Hexaedre, Conformite - recuperation des NomBres
c     --           -         -                             -  -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . etdare . e   .    12  . etat/decision des aretes                   .
c . nbreso .  s  .   1    . nombre de sommets a creer                  .
c . nbrear .  s  .   1    . nombre d'arete a creer                     .
c . nbrepy .  s  .   1    . nombre de pyramides a creer                .
c . nbrete .  s  .   1    . nombre de tetraedres a creer               .
c . nbrehe .  s  .   1    . nombre d'hexaedres a creer                 .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'UTHCNB' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer etdare(12)
      integer nbreso, nbrear, nbrepy, nbrete, nbrehe
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
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
c 1.2. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
c====
c 2. les references
c====
c
      jaux = etdare(1)
      do 20 , iaux = 2, 12
cgn      write(ulsort,90015) 'etdare(', iaux, ') :', etdare
        if ( etdare(iaux).gt.0 ) then
          jaux = jaux + 2**(iaux-1)
        endif
   20 continue
cgn      write(ulsort,90002) '==> binaire', jaux
c
      nbreso = chnp1(jaux)
      nbrear = chnar(jaux)
      nbrepy = chnpy(jaux)
      nbrete = chnte(jaux)
      nbrehe = chnhe(jaux)
      if ( nbreso.eq.-1 ) then
      write(ulsort,90002) '==> binaire', jaux
      write(ulsort,*) 'etdare', etdare
      endif
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
      call dmflsh(iaux)
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
