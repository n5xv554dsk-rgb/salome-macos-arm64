      subroutine hocmsa ( codret )
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
c   HOMARD : Creation d'un Maillage et d'une Solution Annexe
c   --       -             -                 -        -
c   Option(s) possible(s) : changement de degre
c
c remarque : on n'execute ce programme que si le precedent s'est
c            bien passe
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
      parameter ( nompro = 'HOCMSA' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
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
      integer codre0
      integer codre1, codre2
      integer lnomaa
c
      character*6 saux
      character*8 typobs, nocmaa, nohmap
      character*64 nommaa
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      if ( imem(adopti+40).eq.1 ) then
c
c 1.4. ==> l'etat courant
c
      call gmadoj ( nndoad//'.EtatCour', adetco, lgetco, codret )
c
      if ( codret.eq.0 ) then
        if ( imem(adopti+40).eq.1 ) then
          nretap = imem(adetco) + 1
          imem(adetco) = nretap
          nrsset = -1
          imem(adetco+1) = nrsset
        endif
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
c 1.5. ==> le debut des mesures de temps
c
      call gtdems (nrsect)
c
c 1.6. ==> les messages
c
      texte(1,4) =
     > '(//,a6,'' M A I L L A G E    E T    S O L U T I O N    A N N '',
     >''E X E S'')'
      texte(1,5) = '(65(''=''),/)'
      texte(1,7) = '(''Impossible pour Code_Saturne'')'
      texte(1,8) = '(''Le format'',i7,''est impossible.'')'
c
      texte(2,4) = '(//,a6,'' A D D I T I O N A L    M E S H    A N D'',
     >''    S O L U T I O N'')'
      texte(2,5) = '(65(''=''),/)'
      texte(2,7) = '(''Impossible for Code_Saturne'')'
      texte(2,8) = '(''Format #'',i7,''cannot be written.'')'
c
c 1.7. ==> le titre
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
      nrsset = 0
      imem(adetco+1) = nrsset
c
c 1.8. ==> les noms d'objets a conserver
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
c
c 2.1. ==> le maillage homard a l'iteration n+1
c
      typobs = mchmap
      iaux = 0
      call utosno ( typobs, nohmap, iaux, ulsort, langue, codre1 )
c
c 2.2. ==> le maillage med annexe
c
      if ( imem(adopti+10).eq.6 .or.
     >     imem(adopti+10).eq.16 .or.
     >     imem(adopti+10).eq.26 .or.
     >     imem(adopti+10).eq.36 .or.
     >     imem(adopti+10).eq.46 .or.
     >     imem(adopti+10).eq.56 ) then
c
        typobs = mccnma
        iaux = 0
        jaux = 1
        call utfino ( typobs, iaux, nommaa, lnomaa,
     >                jaux,
     >                ulsort, langue, codre2 )
c
      else
c
        lnomaa = 0
        codre2 = 0
c
      endif
c
c 2.3. ==> bilan
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
c====
c 3. modification du degre du maillage
c====
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+40).eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMDEGR', nompro
#endif
c
        call mmdegr ( lgopti, imem(adopti), lgetco, imem(adetco),
     >                nohmap,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 4. conversion du maillage
c====
c
c 4.1. ==> conversion vraie des connectivites
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      nrssse = imem(adetco+3)
      call gtdems (nrssse)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMACO', nompro
      call dmflsh(iaux)
#endif
      call pcmaco ( imem(adopti+3),
     >              nocmaa, nohmap, nommaa, lnomaa,
     >              smem(adopts+19),
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
        smem(adopts+4) = nocmaa
      endif
c
c 4.2. ==> les familles
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAFA', nompro
      call dmflsh(iaux)
#endif
      call pcmafa ( nocmaa, nohmap,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2. ==> verification pour le cas extrude
c
      if ( codret.eq.0 ) then
c
      if ( imem(adopti+38).ne.0 .or.
     >     imem(adopti+10).eq.26 .or.
     >     imem(adopti+10).eq.36 .or.
     >     imem(adopti+10).eq.46 .or.
     >     imem(adopti+10).eq.56 ) then
c
        write (ulsort,texte(langue,7))
        codret = 3
c
      endif
c
      call gtfims (nrssse)
c
      endif
c
c====
c 4. ecriture du maillage
c====
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+21).eq.1 ) then
c
        imem(adopti+49) = 2
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'HOAPEM', nompro
#endif
        call hoapem ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
      endif
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
      endif
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
