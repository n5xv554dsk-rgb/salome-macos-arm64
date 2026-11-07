      subroutine sfgrou ( ncfami, ncafdg,
     >                    nblign, nbgrmx,
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
c   Suivi de Frontiere - GROUpes pour la frontiere
c   -        -           ----
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ncfami . e   . char*8 . nom de l'objet famille du maillage         .
c . ncafdg . es  . char*8 . nom de l'objet groupes frontiere           .
c . nblign .   s .    1   . nombre de lignes dans les donnees          .
c . nbgrmx .   s .    1   . nombre maximal de groupes de la frontiere  .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme avec la memoire               .
c .        .     .        . 3 : probleme avec le fichier               .
c .        .     .        . 5 : contenu incorrect                      .
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
      parameter ( nompro = 'SFGROU' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nblign, nbgrmx
c
      character*8 ncfami, ncafdg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
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
      texte(1,4) =
     > '(''Nombre de groupes demandes pour la frontiere :'',i8)'
      texte(1,5) =
     > '(''Pas de groupe dans le maillage de la frontiere.'')'
      texte(1,6) = '(''Impossible de la suivre.'')'
      texte(1,7) = '(''Nombre de groupes dans les familles  :'',i8)'
c
      texte(2,4) = '(''Number of groups requested for boundary:'',i8)'
      texte(2,5) = '(''No group in boundary mesh.'')'
      texte(2,6) = '(''It cannot be followed.'')'
      texte(2,7) = '(''Number of groups in families:'',i8)'
c
#include "impr03.h"
c
c====
c 2. Nombre de groupes designes dans le fichier de configuration
c====
c
      call gmliat ( ncafdg, 1, nblign, codret )
c
#ifdef _DEBUG_HOMARD_
cgn      call gmprsx ( nompro, ncafdg )
cgn      call gmprsx ( nompro, ncafdg//'.Table' )
      write (ulsort,texte(langue,4)) nblign
#endif
c
c====
c 3. Nombre de groupes presents dans les familles du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. On compte ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( ncfami//'.Groupe', 2, iaux, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) iaux/10
#endif
c
      if ( codret.eq.0 ) then
c
      nbgrmx = iaux/10
c
      if ( nbgrmx.eq.0 ) then
        write (ulsort,texte(langue,5))
        write (ulsort,texte(langue,6))
        codret = 3
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbgrmx', nbgrmx
#endif
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
