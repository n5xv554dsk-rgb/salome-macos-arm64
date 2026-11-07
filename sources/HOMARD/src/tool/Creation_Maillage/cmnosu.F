      subroutine cmnosu ( nohman,
     >                    indnoe,
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
c    Creation du Maillage - les NOeuds SUpplementairs
c    -           -              --     --
c ______________________________________________________________________
c
c but : gestion de la creation des noeuds p2 et internes aux mailles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nohman . e   .  ch8   . nom de l'objet contenant le maillage       .
c . indnoe . es  . 1      . indice du dernier noeud cree               .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'CMNOSU' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
#include "nombar.h"
#include "nouvnb.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nohman
c
      integer indnoe
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
      integer nuard1, nuarf1, nuard2, nuarf2
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
      texte(1,4) = '(/,a6,'' CREATION DES NOEUDS SUPPLEMENTAIRES'')'
      texte(1,5) = '(42(''=''),/)'
      texte(1,6) =
     > '(5x,''On attendait un nombre total de noeuds de : '',i10)'
      texte(1,7) =
     > '(5x,''Mais on en a cree un nombre total de      : '',i10)'
c
      texte(2,4) = '(/,a6,'' CREATION OF ADDITIONAL NODES'')'
      texte(2,5) = '(35(''=''),/)'
      texte(2,6) = '(5x,i10,'' nodes were expected.'')'
      texte(2,7) = '(5x,i10,'' nodes were created.'')'
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      write ( ulsort,texte(langue,4)) saux
      write ( ulsort,texte(langue,5))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'indnoe', indnoe
      write (ulsort,90002) 'permar', permar
      write (ulsort,90002) 'nouvtr', nouvtr
#endif
c
c====
c 2. Prealables
c    Il faut trier pour creer d'abord les noeuds supplementaires
c    attaches aux entites permanentes, puis ceux attaches aux entites
c    provisoires. Cela est indispensable pour traiter correctement
c    la future suppression de la conformite.
c====
c
      if ( codret.eq.0 ) then
c
      nuard1 = nbarma + 1
c
      if ( mod(mailet,2).eq.0 .or.
     >     mod(mailet,3).eq.0 .or.
     >     mod(mailet,5).eq.0 ) then
        nuarf1 = permar
        nuard2 = nuarf1 + 1
        nuarf2 = nouvar
      else
        nuarf1 = nouvar
        nuard2 = nuarf1 + 1
        nuarf2 = -1
      endif
c
      endif
c
c====
c 2. Creation des noeuds P2 sur les aretes :
c    . permanentes tout le temps
c    . provisoires si pas de noeuds internes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. noeuds P2 permanents ; codret = ', codret
      write (ulsort,90002) 'nuard1, nuarf1', nuard1, nuarf1
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMNO22 permanent', nompro
#endif
      call cmno22 ( nohman,
     >              indnoe, nuard1, nuarf1,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. Creation des noeuds internes aux mailles permanentes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. internes permanents ; codret = ', codret
#endif
c
      if ( mod(mailet,2).eq.0 .or.
     >     mod(mailet,3).eq.0 .or.
     >     mod(mailet,5).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMNOIM permanent', nompro
#endif
        call cmnoim ( nohman,
     >                indnoe, iaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 4. Creation des noeuds P2 sur les aretes :
c    . provisoires s'il existe des noeuds internes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. noeuds P2 provisoires ; codret = ', codret
      write (ulsort,90002) 'nuard2, nuarf2', nuard2, nuarf2
#endif
c
      if ( nuarf2.ge.nuard2 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMNO22 provisoire', nompro
#endif
        call cmno22 ( nohman,
     >                indnoe, nuard2, nuarf2,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 5. Creation des noeuds internes aux mailles provisoires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. internes provisoires ; codret = ', codret
#endif
c
      if ( mod(mailet,2).eq.0 .or.
     >     mod(mailet,3).eq.0 .or.
     >     mod(mailet,5).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMNOIM provisoire', nompro
#endif
        call cmnoim ( nohman,
     >                indnoe, iaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif

c====
c 6. verifications et impressions
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'indnoe', indnoe
#endif
c
      if ( codret.eq.0 ) then
c
      if ( indnoe.ne.nouvno ) then
        write(ulsort,texte(langue,6)) nouvno
        write(ulsort,texte(langue,7)) indnoe
        codret = 4
      endif
c
      endif
c
c====
c 7. la fin
c====
c
c 7.1. ==> message si erreur
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
c 7.2. ==> fin des mesures de temps de la section
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
