      subroutine deisau ( nomail, nohind,
     >                    lgopti, taopti, lgetco, taetco,
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
c traitement des DEcisions - Initialisations - SAUt
c                --          -                 ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . nohind . e   .  ch8   . nom de l'objet contenant l'indicateur      .
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
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
      parameter ( nompro = 'DEISAU' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "enti01.h"
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "nombar.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail, nohind
c
      integer lgopti
      integer taopti(lgopti)
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
      integer adnoin, adnorn, adnosu
      integer adarin, adarrn, adarsu
      integer adtrin, adtrrn, adtrsu
      integer adquin, adqurn, adqusu
      integer adtein, adtern, adtesu
      integer adhein, adhern, adhesu
      integer adpyin, adpyrn, adpysu
      integer adpein, adpern, adpesu
      integer nbvnoe, nbvare
      integer nbvtri, nbvqua
      integer nbvtet, nbvhex, nbvpyr, nbvpen
c
      integer typind, ncmpin
      integer nbvent(-1:7)
c
      character*6 saux
      character*8 motaux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*14 saux14
c
#ifdef _DEBUG_HOMARD_
      character*7 saux07(nblang,2)
#endif
c
      logical afaire
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data motaux / 'ValeursR' /
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
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
      texte(1,4) =
     > '(/,a6,'' CALCUL DES SAUTS'')'
      texte(1,5) = '(23(''=''),/)'
      texte(1,6) = '(''Le champ d''''indicateur est '',a)'
      texte(1,7) = '(''Nombre de composantes :'',i3)'
      texte(1,8) = '(''Nombre de valeurs pour les '',a,'':'',i10)'
c
      texte(2,4) =
     > '(/,a6,'' CALCULATIONS OF THE JUMPS'')'
      texte(2,5) = '(32(''=''),/)'
      texte(2,6) = '(''The type of the indicator is '',a)'
      texte(2,7) = '(''Number of components:'',i3)'
      texte(2,8) = '(''Number of values for the '',a,'':'',i10)'
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
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. gestion des tableaux
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c 2.2. ==> structure generale de l'indicateur
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINI0', nompro
#endif
      call deini0 ( nohind, typind, ncmpin,
     >              nbvnoe, nbvare,
     >              nbvtri, nbvqua,
     >              nbvtet, nbvhex, nbvpyr, nbvpen,
     >              adnoin, adnorn, adnosu,
     >              adarin, adarrn, adarsu,
     >              adtrin, adtrrn, adtrsu,
     >              adquin, adqurn, adqusu,
     >              adtein, adtern, adtesu,
     >              adhein, adhern, adhesu,
     >              adpyin, adpyrn, adpysu,
     >              adpein, adpern, adpesu,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      nbvent(-1) = nbvnoe
      nbvent(0)  = 0
      nbvent(1)  = nbvare
      nbvent(2)  = nbvtri
      nbvent(4)  = nbvqua
      nbvent(3)  = nbvtet
      nbvent(5)  = nbvpyr
      nbvent(6)  = nbvhex
      nbvent(7)  = nbvpen
c
      afaire = .false.
      do 21 , iaux= -1, 7
       if ( nbvent(iaux).gt.0 ) then
         afaire = .true.
        endif
   21 continue
c
#ifdef _DEBUG_HOMARD_
      saux07(1,1) = 'entier '
      saux07(1,2) = 'reel   '
      saux07(2,1) = 'integer'
      saux07(2,2) = 'real   '
      write (ulsort,texte(langue,6)) saux07(langue,typind-1)
      write (ulsort,texte(langue,7)) ncmpin
      do 222 , iaux= -1, 7
      write (ulsort,texte(langue,8)) mess14(langue,3,iaux), nbvent(iaux)
  222 continue
#endif
c
      endif
c
c====
c 3. Si l'indicateur est fourni par noeud, on alloue la branche
c    par arete ... sauf si elle existe, ce qui ne devrait pas arriver !
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. allocation ; codret', codret
#endif
c
      if ( nbvent(-1).gt.0 ) then
c
      if ( codret.eq.0 ) then
c
        if ( nbvent(1).gt.0 ) then
c
          codret = 31
c
        else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_ar', nompro
#endif
          iaux = 1
          call utalih ( nohind, iaux, nbarto, ncmpin, motaux,
     >                  adarrn, adarsu,
     >                  ulsort, langue, codret)
          nbvent(iaux) = nbarac
c
        endif
c
      endif
c
      endif
c
c====
c 4. calcul des sauts
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. calcul des sauts ; codret', codret
#endif
c
      if ( afaire ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEISA1', nompro
#endif
        call deisa1 ( nbvent, ncmpin, taopti( 8),
     >                imem(adnosu), rmem(adnorn),
     >                imem(adarsu), rmem(adarrn),
     >                imem(adtrsu), rmem(adtrrn),
     >                imem(adqusu), rmem(adqurn),
     >                imem(adtesu), rmem(adtern),
     >                imem(adhesu), rmem(adhern),
     >                imem(adpysu), rmem(adpyrn),
     >                imem(adpesu), rmem(adpern),
     >                nharet, nhtria, nhquad,
     >                nhtetr, nhhexa, nhpyra, nhpent,
     >                nomail, nhvois,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c====
c 5. Si l'indicateur est fourni par noeud, menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvent(-1).gt.0 ) then
c
        saux14 = nohind//'.'//suffix(1,-1)(1:5)
        call gmsgoj ( saux14 , codret )
        nbvent(-1) = 0
c
      endif
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
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
c 6.2. ==> fin des mesures de temps de la section
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
