      subroutine hodeci ( codret )
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
c   HOmard : traitement des DECIsions
c   --                      ----
c ______________________________________________________________________
c dans le cas ou on ne fait rien, il faut neanmoins basculer les etats
c sinon les interpolations se passent mal
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
c    Rappel des codes de pilotage du raffinement et deraffinement :
c  30 : type de conformite
c       0 : conforme
c       1 : non-conforme avec 1 arete decoupee unique par maille
c       2 : non-conforme avec 1 noeud pendant unique par arete
c       3 : non-conforme fidele a l'indicateur
c      -1 : conforme, avec des boites pour les quad, hexa et pent
c  31 : raffinement
c      -1 : raffinement uniforme
c       0 : pas de raffinement
c       1 : raffinement libre
c       2 : raffinement libre homogene en type de maille
c  32 : deraffinement
c      -1 : deraffinement uniforme
c       0 : pas de deraffinement
c       1 : deraffinement libre
c  49 : types de mailles acceptes
c       0 : tous
c       1 : uniquement ceux compatibles avec le mode d'utilisation
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
      parameter ( nompro = 'HODECI' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "cndoad.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "envada.h"
#include "infini.h"
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
      integer adoptr, lgoptr
      integer adetco, lgetco
      integer nrsect, nrssse
      integer nretap, nrsset
      integer iaux
      integer nbpass, nbpama
      integer codre0
c
      integer indnoe, indare, indtri, indqua
      integer indtet, indhex, indpyr, indpen
      integer indnp2, indnim
      integer nupaci, nbpacm, nbsoci, nbmaci
      integer nbsoav(6)
c
      double precision seuinf, seusup
c
      character*6 saux
      character*8 typobs, nohman, nohind
c
      integer nbmess
      parameter ( nbmess = 11 )
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
     > '(//,a6,'' T R A I T E M E N T    D E S    D E C I S I O N S'')'
      texte(1,5) = '(56(''=''),/)'
      texte(1,6) = '(''Non convergence de l''''algorithme.'')'
      texte(1,7) = '(''Contacter l''''assistance'')'
      texte(1,8) = '(/,''RECHERCHE D''''UNE CIBLE - PASSAGE '', i2)'
      texte(1,9) = '(34(''*''))'
      texte(1,10) =
     > '(/,''FIN DE LA RECHERCHE D''''UNE CIBLE'',/,31(''*''))'
      texte(1,11) = '(''Le maximum d''''iterations est atteint.'')'
c
      texte(2,4) =
     > '(//,a6,'' T R E A T M E N T    O F    D E C I S I O N S'')'
      texte(2,5) = '(52(''=''),/)'
      texte(2,6) = '(''Algorithm failed.'')'
      texte(2,7) = '(''Contact hot-line'')'
      texte(2,8) = '(/,''RESEARCH OF A TARGET - ROUND # '', i2)'
      texte(2,9) = '(33(''*''))'
      texte(2,10) = '(/,''END OF THE RESEARCH OF A TARGET'')'
      texte(2,11) = '(''The maximum of iterations is reached.'')'
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
c 1.8. ==> les options reelles
c
      if ( codret.eq.0 ) then
        call gmadoj ( nndoad//'.OptRee', adoptr, lgoptr, codret )
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
      typobs = mchman
      iaux = 0
      call utosno ( typobs, nohman, iaux, ulsort, langue, codret )
c
      endif
c
c 2.2. ==> les options pour la cible
c
      if ( codret.eq.0 ) then
c
      nbpacm = imem(adopti+42)
      nbsoci = imem(adopti+43)
      nbmaci = imem(adopti+44)
      nupaci = 1
c
      do 22 , iaux = 1 , 6
        nbsoav(iaux) = -1
   22 continue
      seuinf = vinfne
      seusup = vinfpo
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpacm', nbpacm
      write (ulsort,90002) 'nbsoci', nbsoci
      write (ulsort,90002) 'nbmaci', nbmaci
#endif
c
      endif
c
 2999 continue
c
c====
c 3. preparatifs a chaque passe
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. preparatifs ; codret', codret
#endif
c
      imem(adetco+3) = nrssse
c
c 3.1. ==> Affichage pour la recherche eventuelle de la cible
c
      if ( nbsoci.gt.0 .or. nbmaci.gt.0 ) then
c
        if ( nupaci.le.nbpacm ) then
          write (ulsort,texte(langue,8)) nupaci
          write (ulsort,texte(langue,9))
        endif
c
      endif
c
c 3.2. ==> menage de la memoire
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMENH', nompro
#endif
c
      iaux = -1
      call utmemh ( nohman, iaux,
     >              ulsort, langue, codret)
c
      endif
c
c 3.3. ==> l'indicateur d'erreur
c          uniquement quand le raffinement ou le deraffinement n'est ni
c          uniforme, ni inactif
c          il est donne par l'utilisateur ou il est construit
c          en tant qu'objet temporaire
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. indicateur ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( imem(adopti+30).gt.0 .or. imem(adopti+31).gt.0 ) then
c
        typobs = mchind
        iaux = 0
        call utosno ( typobs, nohind, iaux, ulsort, langue, codret )
c
        if ( codret.eq.2 ) then
          nohind = smem(adopts+7)
          codret = 0
        endif
c
      endif
c
      endif
c
c====
c 4. calcul des sauts entre mailles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. sauts entre mailles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( ( imem(adopti+30).gt.0 .or. imem(adopti+31).gt.0 ) .and.
     >       imem(adopti+26).eq.1 .and. imem(adopti+17).eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISAU', nompro
#endif
        call deisau ( nohman, nohind,
     >                lgopti, imem(adopti), lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. usage des composantes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. usage des composantes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( nupaci.le.1 ) then
c
      if ( ( imem(adopti+30).gt.0 .or. imem(adopti+31).gt.0 ) .and.
     >       imem(adopti+26).eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIUCM', nompro
#endif
        call deiucm ( nohind,
     >                lgopti, imem(adopti), lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      endif
c
c====
c 6. suppression des entites de mise en conformite, s'il y en a
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. suppression conformite ; codret', codret
#endif
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
        if ( nbtrto.ne.nbtrpe .or. nbquto.ne.nbqupe ) then
c
          if ( codret.eq.0 ) then
c
          if ( nupaci.le.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DECFSU', nompro
#endif
            call decfsu ( nohman, nohind,
     >                    lgopti, imem(adopti),
     >                    lgetco, imem(adetco),
     >                    ulsort, langue, codret )
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
c 7. mise a jour des historiques des entites
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. maj des historiques ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( nupaci.le.1 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEHIST', nompro
#endif
        call dehist ( nohman,
     >                lgopti, imem(adopti), lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 8. initialisation des decisions
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. init. des decisions ; codret', codret
#endif
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINIT', nompro
#endif
      call deinit ( nohman, nohind,
     >              lgopti, imem(adopti), lgoptr, rmem(adoptr),
     >              lgopts, smem(adopts), lgetco, imem(adetco),
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 9. prise en compte des homologues
c    le filtrage sur la presence des homologues se fait a l'interieur
c    du programme dehomo
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. homologues ; codret', codret
#endif
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEHOMO', nompro
#endif
      call dehomo ( nohman,
     >              lgopti, imem(adopti), lgopts, smem(adopts),
     >              lgetco, imem(adetco),
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 10. traitement de la conformite
c    Si le raffinement est conforme a l'indicateur, on ne fera rien
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. traitement conformite ; codret', codret
#endif
c
      if ( imem(adopti+29).ne.3 ) then
c
      if ( imem(adopti+30).ne.0 .or. imem(adopti+31).ne.0 ) then
c
c 10.0. ==> On va effectuer eventuellement plusieurs fois
c          le traitement pour capter tous les phenomenes mais on se met
c          quand meme une securite pour ne pas tourner indefiniment ...
c          On part avec un maximum de 10 passages mais dans le cas des
c          pentaedres, ce nombre peut etre trop petit.
c
        if ( imem(adopti+29).eq.0 .and. nbpeto.ne.0 ) then
          nbpama = 50
        else
          nbpama = 10
        endif
c
        nbpass = 0
c
  100   continue
c
        nbpass = nbpass + 1
c
c 10.1. ==> decisions de raffinement, quand il est libre ou uniforme
c           partiel ;
c
        if ( codret.eq.0 ) then
c
        if ( nbpass.eq.1 ) then
          imem(adetco+3) = imem(adetco+3) + 1
        endif
c
        if ( imem(adopti+30).gt.0 .or.
     >  ( ( imem(adopti+18).gt.0 .or. rmem(adoptr+2).ge.0.d0 ) .and.
     >      imem(adopti+30).eq.-1 ) ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '10.1. ==> decisions de raffinement'
        write (ulsort,90002) '         avec nbpass', nbpass
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DERAFF', nompro
#endif
          call deraff ( nohman,
     >                  lgopti, imem(adopti), lgopts, smem(adopts),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 10.2. ==> decisions de deraffinement ;
c           remarque : c'est inutile sur un macro-maillage.
c
        if ( codret.eq.0 ) then
c
        if ( nbpass.eq.1 ) then
          imem(adetco+3) = imem(adetco+3) + 1
        endif
c
        if ( nbiter.ne.0 ) then
c
          if ( imem(adopti+31).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,*) '10.2. ==> decisions de deraffinement'
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEDERA', nompro
#endif
            call dedera ( nohman,
     >                    lgopti, imem(adopti), lgopts, smem(adopts),
     >                    lgetco, imem(adetco),
     >                    ulsort, langue, codret )
c
          endif
c
        endif
c
        endif
c
c 10.3. ==> dans certains cas, il faut verifier que les changements de
c           decision effectues en deraffinement ou en propagation de
c           niveau n'ont pas modifie l'etat obtenu apres l'etape de
c           conformite du raffinement. si c'est le cas, on refait
c           une passe.
c          cas 1 : en mode conforme, deraffinement et raffinement libre,
c                  a partir de l'iteration 1
c          cas 2 : en mode non conforme, raffinement non-conforme avec
c                  1 arete decoupee unique par maille
c          cas 3 : en mode conforme libre en presence de pentaedres
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '10.3. ==> bilan'
        write (ulsort,90002) 'tyconf', imem(adopti+29)
        write (ulsort,90002) 'pilraf', imem(adopti+30)
        write (ulsort,90002) 'pilder', imem(adopti+31)
        write (ulsort,90002) 'nbiter', nbiter
        write (ulsort,90002) 'nbpeto', nbpeto
#endif
c
        if ( codret.eq.0 ) then
c
        if ( ( imem(adopti+29).le.0 .and.
     >         nbiter.ne.0 .and.
     >         ( imem(adopti+30).eq.1 .or. imem(adopti+30).eq.2 ) .and.
     >         imem(adopti+31).gt.0 ) .or.
     >       ( imem(adopti+29).eq.1 ) .or.
     >       ( imem(adopti+29).eq.0 .and. nbpeto.gt.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEBILA', nompro
#endif
          call debila ( nohman,
     >                  lgopti, imem(adopti), lgopts, smem(adopts),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
          if ( codret.eq.1 ) then
            if ( nbpass.ge.nbpama ) then
              codret = 10
            else
              codret = 0
              goto 100
            endif
          endif
c
        endif
c
        endif
c
c 10.4. ==> si on a introduit des contraintes sur le raffinement, il
c           faut verifier que les decisions ne conduisent pas a une
c           telle situation. si c'est le cas, on refait une passe.
c           on se met quand meme une securite pour ne pas tourner
c           indefiniment ...
c           attention a bien repercuter les modifications sur les
c           homologues s'il y en a
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'cont raff', imem(adopti+35)
#endif
c
        if ( imem(adopti+35).gt.1 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) '10.4. ==> contraintes sur le raffinement'
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DECORA', nompro
#endif
          call decora ( nohman,
     >                  lgopti, imem(adopti), lgopts, smem(adopts),
     >                  lgetco, imem(adetco),
     >                  iaux,
     >                  ulsort, langue, codret )
c
          if ( codret.eq.0 ) then
c
            if ( iaux.eq.1 ) then
              if ( nbpass.ge.nbpama ) then
                codret = 104
              else
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEHOMO', nompro
#endif
                call dehomo ( nohman,
     >                lgopti, imem(adopti), lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
                goto 100
              endif
            elseif ( iaux.eq.0 ) then
              codret = 0
            else
              codret = 104
            endif
c
          endif
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
c 11. on controle que les aretes des mailles a ignorer
c     n'ont pas ete touchees...
c====
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) '11. mailles ignorees ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( imem(adopti+48).eq.1 .and. imem(adopti+30).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEELIG', nompro
#endif
        call deelig ( nohman,
     >                lgopts, smem(adopts),
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,3)) 'DELIST fin de', nompro
      iaux = 2
      call delist ( nohman, nompro, iaux,
     >              lgopts, smem(adopts),
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 12. Cible eventuelle
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '12. Cible ; codret', codret
      write (ulsort,90002) 'nupaci', nupaci
      write (ulsort,90002) 'nbsoci', nbsoci
      write (ulsort,90002) 'nbmaci', nbmaci
#endif
c
      if ( nbsoci.gt.0 .or. nbmaci.gt.0 ) then
c
c 12.1. ==> les indices sont initialises a la valeur courante
c
        if ( codret.eq.0 ) then
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
c 12.2. ==> Evaluation de la cible
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nupaci', nupaci
#endif
c
        if ( codret.eq.0 ) then
c
        if ( nbpacm.lt.0 .or. ( nupaci.le.nbpacm ) ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'DECINE', nompro
#endif
          call decine ( nupaci, nbsoci, nbsoav,
     >                  rmem(adoptr), seuinf, seusup,
     >                  nohman,
     >                  indnoe, indnp2, indnim, indare, indtri, indqua,
     >                  indtet, indhex, indpen,
     >                  lgopts, smem(adopts), lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
        else
c
          nupaci = -1
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( nupaci.gt.nbpacm ) then
          write (ulsort,texte(langue,11))
        endif
#endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nupaci', nupaci
#endif
c
        endif
c
c 12.3. ==> On recommence eventuellement
c
        if ( codret.eq.0 ) then
c
        if ( nupaci.ge.0 ) then
          goto 2999
        endif
c
        write (ulsort,texte(langue,10))
c
        endif
c
      endif
c
c====
c 13. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '13. Menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( imem(adopti+36).eq.0 ) then
c
        if ( ( ( imem(adopti+30).gt.0 .or. imem(adopti+31).gt.0 ) .and.
     >           imem(adopti+9).gt.0 ) .or.
     >       (  imem(adopti+30).gt.0 .and. imem(adopti+9).eq.0 ) ) then
c
          call gmobal ( nohind , codre0 )
          if ( codre0.eq.1 ) then
            call gmsgoj ( nohind , codret )
          endif
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( imem(adopti+18).ne.0 ) then
        call gmsgoj ( smem(adopts+28), codret )
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( rmem(adoptr+2).gt.0 ) then
        call gmsgoj ( smem(adopts+27), codret )
      endif
c
      endif
c
      endif
c
c====
c 14. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '14. fin de '//nompro//' ; codret', codret
#endif
c
c 14.1. ==> message si erreur
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
        if ( codret.eq.8 ) then
          write (ulsort,texte(langue,6))
          write (ulsort,texte(langue,7))
        endif
c
      endif
c
c 14.2. ==> fin des mesures de temps de la section
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
