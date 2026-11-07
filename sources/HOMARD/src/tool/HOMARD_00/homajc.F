      subroutine homajc ( codret )
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
c   HOmard : Mise A Jour des Coordonnees
c   --       -    - -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . en entree = celui du module d'avant        .
c .        .     .        . en sortie = celui du module en cours       .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 2x : probleme dans les memoires            .
c .        .     .        . 3x : probleme dans les fichiers            .
c .        .     .        . 5 : mauvaises options                      .
c .        .     .        . 6 : problemes dans les noms d'objet        .
c .        .     .        . 7 : non convergence de l'algorithme        .
c ______________________________________________________________________
c
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
      parameter ( nompro = 'HOMAJC' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
#include "cndoad.h"
#include "nombtr.h"
#include "nombqu.h"
#include "envada.h"
c
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer codret
c
c 0.4. ==> variables locales
c
      integer ulsort, langue, codava
      integer adopti, lgopti
      integer adopts, lgopts
      integer adetco, lgetco
      integer nrsect, nrssse
      integer nretap, nrsset
      integer iaux
      integer codre0
      integer codre1, codre2
      integer nbnhom, nbncal
c
      character*6 saux
      character*8 nohman, nocman
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les initialisations
c====
c
#include "impr03.h"
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nndoad )
      call gmprsx (nompro, nndoad//'.OptEnt' )
      call gmprsx (nompro, nndoad//'.OptRee' )
      call gmprsx (nompro, nndoad//'.OptCar' )
      call gmprsx (nompro, nndoad//'.EtatCour' )
#endif
c
c 1.2. ==> le numero d'unite logique de la liste standard
c
      call utulls ( ulsort, codret )
c
c 1.3. ==> la langue des messages
c
      call gmadoj ( nndoad//'.OptEnt', adopti, lgopti, codret )
      if ( codret.eq.0 ) then
        langue = imem(adopti)
      else
        langue = 1
        codret = 2
      endif
c
#include "impr01.h"
c
c 1.4. ==> l'etat courant
c
      call gmadoj ( nndoad//'.EtatCour', adetco, lgetco, codret )
      if ( codret.eq.0 ) then
        nretap = imem(adetco) + 1
        imem(adetco) = nretap
        nrsset = -1
        imem(adetco+1) = nrsset
        nrsect = imem(adetco+2) + 10
        imem(adetco+2) = nrsect
        nrssse = nrsect
        imem(adetco+3) = nrssse
      else
        nretap = -1
        nrsset = -1
        nrsect = 200
        nrssse = nrsect
        codret = 2
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.4. ==> le debut des mesures de temps
c
      call gtdems (nrsect)
c
c 1.5. ==> les messages
c
      texte(1,4) =
     > '(//,a6,'' M I S E    A    J O U R    C O O R D O N N E E S'')'
      texte(1,5) = '(55(''=''),/)'
      texte(1,6) = '(''Incoherence des nombres de noeuds'')'
c
      texte(2,4) =
     > '(//,a6,'' U P D A T I N G    O F    C O O R D I N A T E S'')'
      texte(2,5) = '(54(''=''),/)'
      texte(2,6) = '(''Non coherence for the number of nodes'')'
c
c 1.6. ==> le titre
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
      nrsset = 0
      imem(adetco+1) = nrsset
c
c 1.7. ==> les noms d'objets a conserver
c
      if ( codret.eq.0 ) then
        call gmadoj ( nndoad//'.OptCar', adopts, lgopts, codret )
        if ( codret.ne.0 ) then
          codret = 2
        endif
      endif
c
c====
c 2. les structures de base
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. les structures de base ; codret', codret
#endif
c
c 2.1. ==> le maillage homard
c
      if ( codret.eq.0 ) then
c
      nohman = smem(adopts+2)
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'nohman : ', nohman
#endif
c
      endif
c
c 2.2. ==> le maillage de calcul
c
      if ( codret.eq.0 ) then
c
      nocman = smem(adopts)
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'nocman : ', nocman
#endif
c
      endif
c
c====
c 3. mise a jour des coordonnees
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. maj des coordonnees ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro//' - HOMARD', nohman//'.Noeud')
      call gmprsx (nompro//' - Calcul', nocman//'.Noeud')
#endif
c
c 3.1. ==> verification de la coherence du nombre de noeuds
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nohman//'.Noeud', 1, nbnhom, codre1 )
      call gmliat ( nocman//'.Noeud', 1, nbncal, codre2 )
c
      codre0 = min ( codre1, codre2  )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2  )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbnhom', nbnhom
      write (ulsort,90002) 'nbncal', nbncal
#endif
c
      if ( nbnhom.ne.nbncal ) then
        write (ulsort,texte(langue,6))
        write (ulsort,90002) 'HOMARD', nbnhom
        write (ulsort,90002) 'Calcul', nbncal
        codret = 31
      endif
c
      endif
c
c 3.2. ==> Copie des coordonnees
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprot (nompro//' - Calcul', nocman//'.Noeud.Coor',
     >             3*nbnhom-9, 3*nbnhom)
      call gmprot (nompro//' - HOMARD avant', nohman//'.Noeud.Coor',
     >             3*nbnhom-9, 3*nbnhom)
#endif
c
      call gmcpoj ( nocman//'.Noeud.Coor',
     >              nohman//'.Noeud.Coor', codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprot (nompro//' - HOMARD apres', nohman//'.Noeud.Coor',
     >             3*nbnhom-9, 3*nbnhom)
#endif
c
      endif
c
c====
c 4. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. fin de '//nompro//' ; codret', codret
#endif
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
      call gtfims (nrsect)
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
