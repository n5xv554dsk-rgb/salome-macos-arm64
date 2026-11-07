      subroutine inqure ( codret )
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
c   INformation : QUestions / REponses
c   --            --          --
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
      parameter ( nompro = 'INQURE' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envada.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
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
      integer adopts, lgopts
      integer adetco, lgetco
      integer nrsect, nrssse
      integer nretap, nrsset
      integer iaux, jaux
      integer adinch, adinpf, adinpr, adinlg
      integer typcca
      integer lnomfi
c
      integer ulfido, ulenst, ulsost
c
      logical exisol
c
      character*6 saux
      character*8 action
      character*8 nohman, nocsol, nochso
      character*8 typobs
      character*200 nomfic
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
c 1.1. ==> le numero d'unite logique de la liste standard
c
      call utulls ( ulsort, codret )
c
c 1.2. ==> la langue des messages
c
      call gmadoj ( nndoad//'.OptEnt', adopti, lgopti, codret )
      if ( codret.eq.0 ) then
        langue = imem(adopti)
      else
        langue = 1
        codret = 2
      endif
c
c 1.3. ==> l'etat courant
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
      texte(1,4) = '(/,a6,'' QUESTIONS / REPONSES'')'
      texte(1,5) = '(27(''=''),/)'
c
      texte(2,4) = '(/,a6,'' QUESTIONS / ANSWERS'')'
      texte(2,5) = '(26(''=''),/)'
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
c 1.8. ==> les numeros d'unite logique au terminal
c
      call dmunit ( ulenst, ulsost )
c
c 1.9. ==> l'action en cours
c
      action = smem(adopts+29)
c
c 1.10. ==> le numero d'unite logique du fichier de donnees correct
c
      call utulfd ( action, nbiter, ulfido, codret )
c
c====
c 2. le maillage d'entree
c====
c
      if ( codret.eq.0 ) then
c
      nohman = smem(adopts+2)
c
      endif
c
c====
c 3. Lecture de tous les champs presents dans le fichier
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Lecture des champs ; codret', codret
#endif
c
c 3.1. ==> Recherche du type de code de calcul associe
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nohman, 9, typcca, codret )
c
      endif
c
c 3.2. ==> Lecture de l'eventuelle solution
c          Attention, c'est obligatoirement du format MED
c
c 3.2.1. ==> La solution existe-t-elle ?
c
      if ( codret.eq.0 ) then
c
      if ( mod(typcca-6,10).eq.0 ) then
c
        typobs = mccson
        iaux = 0
        jaux = 0
        call utfino ( typobs, iaux, nomfic, lnomfi,
     >                jaux,
     >                ulsort, langue, codret )
c
        if ( codret.eq.0 ) then
          exisol = .true.
        else
          exisol = .false.
          codret = 0
        endif
c
      else
        exisol = .false.
      endif
c
      endif
c
c 3.2.2. ==> Une solution existe
c
      if ( exisol ) then
c
c 3.2.2.1. ==> Lecture du format MED
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSMD', nompro
#endif
        nochso = '        '
        iaux = 0
        call eslsmd ( nocsol, nochso,
     >                imem(adopti+8), iaux,
     >                ulsort, langue, codret )
c
        endif
c
c 3.2.2.2. ==> pour le cas extrude, passage du 3D au 2D
c
        if ( imem(adopti+38).ne.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSEXT', nompro
#endif
          iaux = 1
          call utsext ( nocsol, iaux, typcca,
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      else
c
c 3.2.3. ==> S'il n'y a pas de solution, on en alloue une vide.
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALSO', nompro
#endif
        iaux = 0
        call utalso ( nocsol,
     >                iaux, iaux, iaux, iaux,
     >                adinch, adinpf, adinpr, adinlg,
     >                ulsort, langue, codret )
c
        endif
c
      endif
cgn      call gmprsx (nompro,nocsol)
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Fin etape 4 avec codret = ', codret
#endif
c
c====
c 4. questions / reponses
c====
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INQUR1', nompro
#endif
      call inqur1 ( nohman, nocsol,
     >              ulfido, ulenst, ulsost,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. la fin
c====
c
c 5.1. ==> message si erreur
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
c 5.2. ==> fin des mesures de temps de la section
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
      jaux = 0
      end
