      subroutine hoavlm ( lgopti, taopti, lgopts, taopts,
     >                    lgetco, taetco,
     >                    ulsort, langue, codret )
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
c       HOMARD : interface AVant adaptation : Lectures du Maillage
c       --                 --                 -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options entieres   .
c . taopti . e   . lgopti . tableau des options entieres               .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'HOAVLM' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c VERRUE CONFORME PENTAEDRE - DEBUT
#include "gmenti.h"
c VERRUE CONFORME PENTAEDRE - FIN
c
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
      integer nrosec, nrssse
      integer nretap, nrsset
      integer iaux
      integer typcca
c
c VERRUE CONFORME PENTAEDRE - DEBUT
      integer adnomb
      integer jaux
c VERRUE CONFORME PENTAEDRE - FIN
c
      character*6 saux
      character*8 nomail, nosvmn
      character*8 mcfich, mcmail
      character*8 typobs
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(/,a6,'' LECTURE DU MAILLAGE DE CALCUL'')'
      texte(1,5) = '(36(''=''),/)'
      texte(1,6) = '(''Mauvais code de calcul :'',i5)'
c
      texte(2,4) = '(/,a6,'' READINGS OF CALCULATION MESH'')'
      texte(2,5) = '(35(''=''),/)'
      texte(2,6) = '(''Bad related code:'',i5)'
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'taopti( 4) - modhom', taopti( 4)
      write (ulsort,90002) 'taopti(21) - cvmail', taopti(21)
#endif
c
c====
c 2. lecture du maillage au format med
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. lecture au format med ; codret', codret
#endif
c
      if ( taopti(21).ne.0 .or. taopti(4).eq.5 ) then
c
        if ( mod(taopti(11)-6,10).eq.0 ) then
c
          write (ulsort,texte(langue,4)) saux
          write (ulsort,texte(langue,5))
c
          nrsset = taetco(2) + 1
          taetco(2) = nrsset
c
          mcfich = mccman
          mcmail = mccnmn
          if ( taopti(4).eq.5 ) then
            iaux = 2
          else
            iaux = 1
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMD', nompro
#endif
          call eslmmd ( mcfich, mcmail,
     >                  taopti(11), taopts(1),
     >                  iaux, taopti(9),
     >                  ulsort, langue, codret )
c
c 2.3. ==> mauvais type
c
        else
c
          codret = 5
c
        endif
c
      endif
c
c====
c 3. lecture du maillage au format HOMARD
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. lecture au format HOMARD ; codret',
     & codret
#endif
c
c
      if ( taopti(21).eq.0 ) then
c
c 3.1. ==> lecture
c       iteration n+1 pour le mode homard interpolation (4)
c       iteration n pour les autres modes
c
        if ( taopti(4).eq.4 ) then
          typobs = mchmap
        else
          typobs = mchman
        endif
        nrssse = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMHO', nompro
#endif
        call eslmho ( typobs, nrssse, nretap, nrsset,
     >                taopts(3), typcca,
     >                taopti(29), taopts(16), taopts(17),
     >                ulsort, langue, codret )
c
c 3.2. ==> pour les modes homard pur (0, 1), et
c            s'il y a conversion de solution, on cree les tables de
c            memorisation du maillage n
c
        if ( ( taopti(4).eq.0 .or. taopti(4).eq.1 ) .and.
     >       taopti(28).eq.1 ) then
c
          if ( codret.eq.0 ) then
          iaux = 1
          call utosno ( typobs, nomail, iaux, ulsort, langue, codret )
          endif
c
          if ( codret.eq.0 ) then
          call utsvmn ( nomail, nosvmn,
     >                  ulsort, langue, codret )
          endif
c
          if ( codret.eq.0 ) then
          taopts(14) = nosvmn
          endif
C
        endif
c
c 3.3. ==> par defaut, le maillage est extrude en Z si c'est du
c            SATURNE ou du NEPTUNE 2D
c
        if ( codret.eq.0 ) then
c
        if ( typcca.eq.26 .or. typcca.eq.46 ) then
          taopti(39) = 3
        endif
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
      if ( codret.eq.5 ) then
        write (ulsort,texte(langue,6)) taopti(11)
      endif
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
