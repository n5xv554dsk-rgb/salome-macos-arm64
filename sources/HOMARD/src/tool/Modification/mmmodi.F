      subroutine mmmodi ( codret )
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
c  Modification de Maillage - Modification
c  -               -          ----
c
c remarque : on n'execute ce programme que si le precedent s'est
c            bien passe
c
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
      parameter ( nompro = 'MMMODI' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "cndoad.h"
c
c 0.3. ==> arguments
c
      integer codret
c
c 0.4. ==> variables locales
c
      integer ulsort, langue, codava
      integer adopti, lgopti
      integer adetco, lgetco
      integer nrsect, nrssse
      integer nretap, nrsset
      integer iaux
      integer codre0
      integer codre1, codre2
c
      integer ulenst, ulsost
c
      character*6 saux
      character*8 typobs, nohman, nohmap
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
c 1.4. ==> l'etat courant
c
      call gmadoj ( nndoad//'.EtatCour', adetco, lgetco, codret )
c
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
c 1.4. ==> le debut des mesures de temps
c
      call gtdems (nrsect)
c
c 1.5. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(//,a6,'//
     >''' M O D I F I C A T I O N    D E    M A I L L A G E'')'
      texte(1,5) = '(56(''=''),/)'
      texte(1,7) = '(''Changement de degre :'',i4)'
      texte(1,8) = '(''Creation de joints  :'',i4)'
c
      texte(2,4) = '(//,a6,'' M E S H    M O D I F I C A T I O N'')'
      texte(2,5) = '(50(''=''),/)'
      texte(2,7) = '(''Modification of degree :'',i4)'
      texte(2,8) = '(''Creation of junctions  :'',i4)'
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
c 1.7. ==> les numeros d'unite logique au terminal
c
      call dmunit ( ulenst, ulsost )
c
c====
c 2. les structures de base
c====
c
c 2.1. ==> le maillage homard a l'iteration n
c
      typobs = mchman
      iaux = 0
      call utosno ( typobs, nohman, iaux, ulsort, langue, codre1 )
c
c 2.2. ==> le maillage homard a l'iteration n+1
c
      typobs = mchmap
      iaux = 0
      call utosno ( typobs, nohmap, iaux, ulsort, langue, codre2 )
c
c 2.3. ==> bilan
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
c====
c 3. Compactage de la memoire
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Compactage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCOMP', nompro
#endif
c
      call utcomp (ulsort, langue, codret)
c
      endif
c
c====
c 4. Modifications du maillage
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) imem(adopti+40)
      write (ulsort,texte(langue,8)) imem(adopti+41)
#endif
c
c 4.1. ==> Modification du degre du maillage
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+40).eq.1 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMDEGR', nompro
#endif
c
        call mmdegr ( lgopti, imem(adopti), lgetco, imem(adetco),
     >                nohman,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 4.2. ==> Creation de joints
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+41).eq.1 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGRE', nompro
#endif
c
        call mmagre ( lgopti, imem(adopti), lgetco, imem(adetco),
     >                nohman,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      endif
c
c====
c 5. transfert du maillage dans la structure de l'iteration n+1
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMTRNP', nompro
#endif
c
      iaux = 1
      call cmtrnp ( nohman, nohmap, iaux,
     >              lgopti, imem(adopti), lgetco, imem(adetco),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 6. la fin
c====
c
c 6.1. ==> message si erreur
c
      if ( codret.ne.0 ) then
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
c
      endif
c
c 6.2. ==> fin des mesures de temps de la section
c
      call gtfims (nrsect)
c
      imem(adetco+2) = imem(adetco+2) + 20
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
