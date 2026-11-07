      subroutine initer ( ulsort, langue, codret )
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
c   INformation : ITERation
c   --            ----
c   Cette ecriture sert au programme d'analyse.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans les memoires             .
c .        .     .        . 3 : probleme dans les fichiers             .
c .        .     .        . 5 : probleme autre                         .
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
      parameter ( nompro = 'INITER' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envada.h"
c
c 0.3. ==> arguments
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nuroul, lnomfl
c
      character*8 saux08
      character*200 nomflo
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
      texte(1,4) = '(''Numero d''''iteration :'',i5)'
c
      texte(2,4) = '(''Iteration number :'',i5)'
c
c====
c 2. recherche du numero d'unite logique lie au fichier
c====
c
      saux08 = blan08
      iaux = 9
      jaux = -1
      call utulbi ( nuroul, nomflo, lnomfl,
     >                iaux, saux08, jaux, jaux,
     >              ulsort, langue, codret )
c
c====
c 2. ecriture du numero d'iteration dans un fichier, si ce n'est
c     pas le standard
c====
c
      if ( codret.eq.0 ) then
c
      if ( nuroul.ne.ulsort ) then
c
c 2.1. ==> ecriture
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbiter
#endif
c
        write (nuroul,*) nbiter
c
c 2.2. ==> fermeture du fichier
c
        call gufeul ( nuroul, codret )
c
      endif
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
