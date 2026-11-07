      subroutine sflgeo ( lgopti, taopti, lgopts, taopts,
     >                    lgetco, taetco,
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
c   Suivi de Frontiere - Lecture de la GEOmetrie
c   -        -           -             ---
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      parameter ( nompro = 'SFLGEO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "motcle.h"
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nrosec
      integer nretap, nrsset
      integer iaux
c
      character*6 saux
      character*8 nofich, nomail
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
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.1. ==> le debut des mesures de temps
c
      nrosec = taetco(4)
      call gtdems (nrosec)
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
      texte(1,4) = '(/,a6,'' LECTURE DE LA FRONTIERE DISCRETE'')'
      texte(1,5) = '(39(''=''),/)'
      texte(1,6) = '(''Le maillage fourni est de degre'',i3)'
      texte(1,7) = '(''Il doit etre de degre 1.'')'
c
      texte(2,4) = '(/,a6,'' READINGS OF DISCRETE BOUNDARY'')'
      texte(2,5) = '(36(''=''),/)'
      texte(2,6) = '(''Degree of the mesh is :'',i3)'
      texte(2,7) = '(''It should be linear.'')'
c
#include "impr03.h"
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. lecture de la frontiere discrete depuis le fichier MED
c====
c
      if ( codret.eq.0 ) then
c
      nofich = mccdfr
      nomail = mccnmf
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMD', nompro
#endif
      call eslmmd ( nofich, nomail,
     >              taopti(11), taopts(16),
     >              iaux, taopti(9),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. Controle du degre
c====
c
      if ( codret.eq.0 ) then
c
      call gmliat ( taopts(16), 3, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( iaux.ne.1 ) then
c
        write (ulsort,texte(langue,6)) iaux
        write (ulsort,texte(langue,7))
        codret = 1
c
      endif
c
      endif
c
c====
c 4. la fin
c====
c
c 4.1. ==> message si erreur
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
c 4.2. ==> fin des mesures de temps de la section
c
      call gtfims (nrosec)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
c=======================================================================
      endif
c=======================================================================
c
      end
