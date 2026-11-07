      subroutine hoapem ( lgopti, taopti, lgopts, taopts,
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
c       HOMARD : interface APres adaptation : Ecritures du Maillage
c       --                 --                 -            -
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
      parameter ( nompro = 'HOAPEM' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
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
      integer nrosec
      integer nretap, nrsset
      integer iaux
c
      character*6 saux
      character*8 nocmai, mcfima, mcnoma
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
      texte(1,4) = '(/,a6,'' ECRITURE DU MAILLAGE DE CALCUL'')'
      texte(1,5) = '(37(''=''),/)'
      texte(1,6) = '(/,a6,'' ECRITURE DU MAILLAGE ANNEXE'')'
      texte(1,7) = '(34(''=''),/)'
      texte(1,8) = '(''Mauvais choix de type de maillage :'',i8)'
      texte(1,9) = '(''Il faut 1 ou 2.'')'
c
      texte(2,4) = '(/,a6,'' WRITINGS OF CALCULATION MESH'')'
      texte(2,5) = '(35(''=''),/)'
      texte(2,6) = '(/,a6,'' WRITINGS OF ADDITIONAL MESH'')'
      texte(2,7) = '(34(''=''),/)'
      texte(2,8) = '(''Bad choice for mesh type :'',i8)'
      texte(2,9) = '(''1 ou 2 is correct.'')'
c
c 1.3. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.4. ==> le titre
c
      iaux = 0
      if ( taopti(50).eq.1 ) then
        iaux = 4
      elseif ( taopti(50).eq.2 ) then
        iaux = 6
      endif
      if ( iaux.ne.0 ) then
      write (ulsort,texte(langue,iaux)) saux
      write (ulsort,texte(langue,iaux+1))
      endif
c
c====
c 2. choix du maillage a ecrire
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> maillage apres adaptation
c
      if ( taopti(50).eq.1 ) then
c
        nocmai = taopts(2)
        mcfima = mccmap
        mcnoma = mccnmp
c
c 2.2. ==> maillage annexe apres adaptation
c
      elseif ( taopti(50).eq.2 ) then
c
        nocmai = taopts(5)
        mcfima = mccmaa
        mcnoma = mccnma
c
c 2.3. ==> erreur
c
      else
c
        write (ulsort,texte(langue,8)) taopti(50)
        write (ulsort,texte(langue,9))
        codret = 2
c
      endif
c
      endif
c
c====
c 3. ecriture du maillage
c====
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> format med
c
      if ( mod(taopti(11)-6,10).eq.0 ) then
c
        if ( taopti(50).eq.1 ) then
          iaux = 0
        elseif ( taopti(50).eq.2 ) then
          iaux = 1
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMMD', nompro
#endif
        call esemmd ( nocmai, mcfima, mcnoma, iaux,
     >                ulsort, langue, codret)
c
c 3.2. ==> erreur
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
