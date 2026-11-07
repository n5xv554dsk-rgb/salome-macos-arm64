      subroutine hoavec ( codret )
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
c       HOMARD : interface AVant adaptation : ECritures
c       --                 --                 --
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
      parameter ( nompro = 'HOAVEC' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmstri.h"
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
      integer iaux
c
      character*8 typobs
c
      character*6 saux
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
c 1.4. ==> Va-t-on ecrire ?
c
      iaux = 0
      if ( codret.eq.0 ) then
cgn      print *,imem(adopti+20),imem(adopti+4)
      if ( imem(adopti+20).eq.1 ) then
        if ( mod(imem(adopti+4),2).eq.0 ) then
          iaux = 1
        endif
      endif
cgn      print *,imem(adopti+3),imem(adopti+4)
      if ( imem(adopti+3) .eq.-3 .and.
     >     mod(imem(adopti+4),2).eq.0 .and.
     >     imem(adopti+26).eq.1 ) then
        iaux = 1
      endif
      if ( imem(adopti+3) .eq.5 ) then
        iaux = 1
      endif
      endif
c
c-----------------------------------------------------------------------
      if ( iaux.eq.1 ) then
c-----------------------------------------------------------------------
c
c 1.5. ==> l'etat courant
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
c 1.6. ==> le debut des mesures de temps
c
      call gtdems (nrsect)
c
c 1.7. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(//,a6,'' E C R I T U R E   D E S   F I C H I E R S'')'
      texte(1,5) = '(48(''=''),/)'
c
      texte(2,4) = '(//,a6,'' W R I T I N G   O F   F I L E S'')'
      texte(2,5) = '(38(''=''),/)'
c
c 1.8. ==> le titre
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
      nrsset = 0
      imem(adetco+1) = nrsset
c
c 1.9. ==> les noms d'objets a conserver
c
      if ( codret.eq.0 ) then
        call gmadoj ( nndoad//'.OptCar', adopts, lgopts, codret )
        if ( codret.ne.0 ) then
          codret = 2
        endif
      endif
c
c====
c 2. ecriture eventuelle du maillage
c====
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( codret.eq.0 ) then
c
      if ( imem(adopti+20).eq.1 .or. imem(adopti+3).eq.5 ) then
c
        if ( mod(imem(adopti+4),2).eq.0 ) then
c
          typobs = mchman
          nrssse = imem(adetco+3)
          nrsset = imem(adetco+1) + 1
          imem(adetco+1) = nrsset
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMHO', nompro
#endif
          call esemho ( typobs, nrssse, nretap, nrsset,
     >                  imem(adopti+4),
     >                  imem(adopti+28), smem(adopts+15),
     >                  ulsort, langue, codret)
c
        endif
c
      endif
c
      endif

c
c====
c 3. la fin
c====
c
c 3.1. ==> message si erreur
c
      if ( codret.ne.0 ) then
c
         write (ulsort,texte(langue,1)) 'Sortie', nompro
         write (ulsort,texte(langue,2)) codret
c
      endif
c
c 3.2. ==> fin des mesures de temps de la section
c
      call gtfims (nrsect)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
c-----------------------------------------------------------------------
      else
c-----------------------------------------------------------------------
c
c====
c 4. Mise a jour du compteur des sections temporelles
c    si rien n'a ete fait
c====
c
      call gmadoj ( nndoad//'.EtatCour', adetco, lgetco, codret )
      if ( codret.eq.0 ) then
        nrsect = imem(adetco+2) + 10
        imem(adetco+2) = nrsect
      endif
c-----------------------------------------------------------------------
      endif
c-----------------------------------------------------------------------
c=======================================================================
      endif
c=======================================================================
c
      end
