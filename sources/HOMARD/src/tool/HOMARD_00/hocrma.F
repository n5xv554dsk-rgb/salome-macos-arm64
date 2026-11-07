      subroutine hocrma ( codret )
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
c       HOMARD : CReation du MAillage
c       --       --          --
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
c    Rappel des codes de pilotage du raffinement et deraffinement :
c  30 : mode de conformite
c       0 : conforme (defaut)
c       1 : non-conforme avec 1 seule arete decoupee (en 2)
c           par face (triangle ou quadrangle)
c       2 : non-conforme avec 1 seul noeud pendant par arete
c       3 : non-conforme fidele a l'indicateur
c      -1 : conforme, avec des boites pour les quad, hexa et pent
c  31 : raffinement
c      -1 : raffinement uniforme
c       0 : pas de raffinement
c       1 : raffinement libre (defaut)
c       2 : raffinement libre homogene en type d'element
c  32 : deraffinement
c      -1 : deraffinement uniforme
c       0 : pas de deraffinement
c       1 : deraffinement libre (defaut)
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
      parameter ( nompro = 'HOCRMA' )
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
#include "nouvnb.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "cndoad.h"
#include "envada.h"
#include "envca1.h"
#include "envca2.h"
c
c 0.3. ==> arguments
c
      integer codret
c
c 0.4. ==> variables locales
c
      integer indnoe, indare, indtri, indqua
      integer indtet, indhex, indpyr, indpen
c
      integer ulsort, langue, codava
      integer adopti, lgopti
      integer adopts, lgopts
      integer indnp2, indnim
      integer nbprov
      integer adetco, lgetco
      integer nrsect, nrssse
      integer nretap, nrsset
      integer iaux
      integer codre0
      integer codre1, codre2
c
      character*6 saux
#ifdef _DEBUG_HOMARD_
      character*8 action
      parameter ( action = 'adap    ' )
      character*6 nompra
#endif
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
      if ( codret.eq.0 ) then
c
      call gmadoj ( nndoad//'.OptEnt', adopti, lgopti, codret )
      if ( codret.eq.0 ) then
        langue = imem(adopti)
      else
        langue = 1
        codret = 2
      endif
c
      endif
c
c 1.4. ==> l'etat courant
c
      if ( codret.eq.0 ) then
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
     > '(//,a6,'' C R E A T I O N   D U   M A I L L A G E'')'
      texte(1,5) = '(46(''=''),/)'
      texte(1,7) =
     > '(''==> Nombre total d''''entites provisoires :'',i10)'
c
      texte(2,4) = '(//,a6,'' M E S H   C R E A T I O N'')'
      texte(2,5) = '(32(''=''),/)'
      texte(2,7) = '(''==> Total number of temporary entities :'',i10)'
c
#include "impr03.h"
c
c 1.6. ==> le titre
c
      if ( codret.eq.0 ) then
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
      nrsset = 0
      imem(adetco+1) = nrsset
c
      endif
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. les structures de base ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
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
      iaux = 1
      call utosno ( typobs, nohmap, iaux, ulsort, langue, codre2 )
c
c 2.3. ==> bilan
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
      smem(adopts+3) = nohmap
#ifdef _DEBUG_HOMARD_
      iaux = 0
      call utveri ( action, nohman, nompro, iaux,
     >              ulsort, langue, codret )
#endif
      endif
c
c====
c 3. Initialisations pour le maillage
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Init pour le maillage ; codret', codret
#endif
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMINMA', nompro
#endif
      call cminma ( indnoe, indare, indtri, indqua,
     >              indtet, indhex, indpyr, indpen,
     >              lgopti, imem(adopti),
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      nompra = 'cminma'
      iaux = 2
      call utveri ( action, nohman, nompra, iaux,
     >              ulsort, langue, codret )
      endif
#endif
c
      endif
c
c====
c 4. deraffinement, sauf pour un macro-maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. deraffinement ; codret', codret
#endif
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+31).ne.0 .and. nbiter.ne.0 ) then
c
        nrssse = imem(adetco+3)
        call gtdems (nrssse)
c
c 4.1. ==> on deraffine, puis on ajuste les tableaux
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMDERA', nompro
#endif
        call cmdera ( nohman,
     >                indnoe, indnp2, indnim, indare,
     >                indtri, indqua,
     >                indtet, indhex, indpen,
     >                lgopts, smem(adopts), lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
cgn        nompra = 'cmdera'
cgn        iaux = 2
cgn        call utveri ( action, nohman, nompra, iaux,
cgn     >                ulsort, langue, codret )
        endif
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMALDE', nompro
#endif
        call cmalde ( nohman,
     >                indnoe, indnp2, indnim, indare,
     >                indtri, indqua, indtet, indhex, indpen,
     >                lgopts, smem(adopts), lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        nompra = 'cmalde'
        iaux = 2
        call utveri ( action, nohman, nompra, iaux,
     >                ulsort, langue, codret )
        endif
#endif
c
        call gtfims (nrssse)
c
      else
c
c 4.2. ==> sans deraffinement, les indices sont initialises a la valeur
c          courante
c
        indnoe = nbnoto
        indnp2 = nbnop2
        indnim = nbnoim
        indare = nbarto
        indtri = nbtrto
        indqua = nbquto
        indtet = nbteto
        indhex = nbheto
        indpyr = nbpyto
        indpen = nbpeto
c
      endif
c
      endif
c
c====
c 5. compactage des tableaux
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. compactage tableaux ; codret', codret
#endif
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
      nrssse = imem(adetco+3)
c
      call gtdems (nrssse)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCOMP', nompro
#endif
c
      call utcomp (ulsort, langue, codret)
c
      call gtfims (nrssse)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      nompra = 'utcomp'
      iaux = 2
      call utveri ( action, nohman, nompra, iaux,
     >              ulsort, langue, codret )
      endif
#endif
c
      endif
c
c====
c 6. raffinement standard du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. raffinement ; codret', codret
#endif
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+30).ne.0 ) then
c
        nrssse = imem(adetco+3)
        call gtdems (nrssse)
c
c 6.1. ==> allocation memoire pour le decoupage standard
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMALRA', nompro
#endif
        call cmalra ( nohman,
     >                indnoe, indnp2, indnim, indare, indtri, indqua,
     >                indtet, indhex, indpen,
     >                lgopts, smem(adopts), lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        nompra = 'cmalra'
        iaux = 2
        call utveri ( action, nohman, nompra, iaux,
     >                ulsort, langue, codret )
        endif
#endif
c
c 6.2. ==> raffinement proprement dit
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMRAFF', nompro
#endif
        call cmraff ( nohman,
     >                indnoe, indare, indtri, indqua,
     >                indtet, indhex, indpen,
     >                lgopts, smem(adopts), lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
c
        call gtfims (nrssse)
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        nompra = 'cmraff'
        iaux = 2
        call utveri ( action, nohman, nompra, iaux,
     >                ulsort, langue, codret )
        endif
#endif
c
      endif
c
      endif
c
c====
c 7. mise en conformite
c    On evite evidemment le cas du raffinement non conforme ...
c    Dans les autres cas :
c    . A l'iteration 0 : seulement en cas de raffinement libre, quel
c                        que soit le type de deraffinement car il a ete
c                        inhibe
c    . Aux iterations suivantes : toujours
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. mise en conformite ; codret', codret
#endif
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( ( imem(adopti+29).eq.0 ) .or.
     >     ( imem(adopti+29).eq.-1 ) ) then
c
        if ( ( nbiter.eq.0 .and. imem(adopti+30).ne.0 ) .or.
     >       nbiter.gt.0 ) then
c
          nrssse = imem(adetco+3)
          call gtdems (nrssse)
c
c 7.1. ==> nombre de mises en conformite
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMNBCO', nompro
#endif
          call cmnbco ( nohman,
     >                  lgopti, imem(adopti), lgopts, smem(adopts),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
          endif
c
c 7.2. ==> bilan
c
          if ( codret.eq.0 ) then
c
          nbprov = provp2 + provim +
     >             provar +
     >             provtr + provqu +
     >             provte + provpy + provpe + provhe
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nbprov
#endif
          endif
c
c 7.3. ==> initialisation memoire pour la mise en conformite
c
          if ( nbprov.ne.0 ) then
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMALCO', nompro
#endif
            call cmalco ( nohman,
     >                    lgetco, imem(adetco),
     >                    ulsort, langue, codret )
c
            endif
c
#ifdef _DEBUG_HOMARD_
            if ( codret.eq.0 ) then
            nompra = 'cmalco'
            iaux = 2
            call utveri ( action, nohman, nompra, iaux,
     >                    ulsort, langue, codret )
            endif
#endif
c
          endif
c
c 7.4. ==> mise en conformite proprement dite
c
          if ( nbprov.ne.0 ) then
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMCONF', nompro
#endif
            call cmconf ( nohman,
     >                    indnoe, indare, indtri, indqua,
     >                    indtet, indpyr, indhex,
     >                    lgopti, imem(adopti), lgopts, smem(adopts),
     >                    lgetco, imem(adetco),
     >                    ulsort, langue, codret )
c
            endif
c
#ifdef _DEBUG_HOMARD_
            if ( codret.eq.0 ) then
            nompra = 'cmconf'
            write (ulsort,texte(langue,3)) 'UTVERI'//nompra, nompro
            iaux = 2
            call utveri ( action, nohman, nompra, iaux,
     >                    ulsort, langue, codret )
            endif
#endif
c
          endif
c
          call gtfims (nrssse)
c
        endif
c
      endif
c
      endif
c
c====
c 8. creation des noeuds suplementaires :
c    . noeuds p2 sur les nouvelles aretes
c    . noeuds internes aux mailles
c    Remarque :
c    . A l'iteration 0 : seulement en cas de raffinement, quel que soit
c                        le type de deraffinement car il a ete inhibe
c    . Aux iterations suivantes : toujours
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. creation des noeuds supp ; codret',
     & codret
#endif
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( codret.eq.0 ) then
c
      if ( degre.eq.2 ) then
c
        if ( ( nbiter.eq.0 .and. imem(adopti+30).ne.0 ) .or.
     >       nbiter.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMNOSU', nompro
#endif
          call cmnosu ( nohman,
     >                  indnoe, lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          nompra = 'cmnosu'
          write (ulsort,texte(langue,3)) 'UTVERI'//nompra, nompro
          iaux = 2
          call utveri ( action, nohman, nompra, iaux,
     >                  ulsort, langue, codret )
          endif
#endif
c
        endif
c
      endif
c
      endif
c
      endif
c
c====
c 9. mise a jour
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. mise a jour ; codret', codret
#endif
c
c 9.1. ==> communs, voisinages ...
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMMISA', nompro
#endif
      call cmmisa ( nohman,
     >              lgetco, imem(adetco),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      nompra = 'cmmisa'
      write (ulsort,texte(langue,3)) 'UTVERI'//nompra, nompro
      iaux = 2
      call utveri ( action, nohman, nompra, iaux,
     >              ulsort, langue, codret )
      endif
#endif
c
      endif
c
      endif
c
c 9.2. ==> le numero d'iteration du maillage
c
      if ( codret.eq.0 ) then
c
      nbiter = nbiter + 1
c
      endif
c
c 9.3. ==> la date
c
      if ( codret.eq.0 ) then
c
      call utdhlg ( ladate, langue )
c
      endif
c
c====
c 10. transfert dans la structure de l'iteration n+1
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. transfert ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMTRNP', nompro
#endif
      iaux = 1
      call cmtrnp ( nohman, nohmap, iaux,
     >              lgopti, imem(adopti), lgetco, imem(adetco),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 11. Verifications du maillage final
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11. verif maillage final ; codret', codret
#endif
c
c 11.1. ==> controle de la conformite
c
      if ( codret.eq.0 ) then
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCOMA', nompro
#endif
      call utcoma ( nohmap,
     >              iaux,
     >              ulsort, langue, codret )
c
      endif
c
c 11.2. ==> Verifications
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,3)) 'UTVERI'//nompro, nompro
      iaux = 2
      call utveri ( action, nohman, nompro, iaux,
     >              ulsort, langue, codret )
      endif
#endif
c
c====
c 12. la fin
c====
c
c 12.1. ==> message si erreur
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
c 12.2. ==> fin des mesures de temps de la section
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
