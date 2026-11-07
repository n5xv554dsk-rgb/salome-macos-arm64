      subroutine deiucm ( nohind,
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
c traitement des DEcisions - Initialisations - Usage des CoMposantes
c                --          -                 -         - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
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
      parameter ( nompro = 'DEIUCM' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nohind
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
      integer usacmp
      integer typind, ncmpin
      integer nbvent(-1:7)
      integer adsupp(-1:7)
      integer advale(-1:7)
c
      character*6 saux
c
#ifdef _DEBUG_HOMARD_
      character*7 saux07(nblang,2)
#endif
c
      integer nbmess
      parameter ( nbmess = 15 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
     > '(/,a6,'' USAGE DES COMPOSANTES'')'
      texte(1,5) = '(28(''=''),/)'
      texte(1,6) = '(''Le champ d''''indicateur est '',a)'
      texte(1,7) = '(''Nombre de composantes :'',i3)'
      texte(1,8) = '(''Nombre de valeurs pour les '',a,'':'',i10)'
      texte(1,9) = '(''. Norme L2 des composantes.'')'
      texte(1,10) = '(''. Norme infinie des composantes.'')'
      texte(1,11) = '(''. Valeur relative de la composante.'')'
c
      texte(2,4) =
     > '(/,a6,'' USE OF THE COMPONENTS'')'
      texte(2,5) = '(28(''=''),/)'
      texte(2,6) = '(''The type of the indicator is '',a)'
      texte(2,7) = '(''Number of components:'',i3)'
      texte(2,8) = '(''Number of values for the '',a,'':'',i10)'
      texte(2,9) = '(''. L2 norm of components.'')'
      texte(2,10) = '(''. Infinite norm of components.'')'
      texte(2,11) = '(''. Relative value for the component.'')'
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
c 2.1. ==> structure generale de l'indicateur
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
      adsupp(-1) = adnosu
      adsupp(1)  = adarsu
      adsupp(2)  = adtrsu
      adsupp(4)  = adqusu
      adsupp(3)  = adtesu
      adsupp(5)  = adpysu
      adsupp(6)  = adhesu
      adsupp(7)  = adpesu
c
      advale(-1) = adnorn
      advale(1)  = adarrn
      advale(2)  = adtrrn
      advale(4)  = adqurn
      advale(3)  = adtern
      advale(5)  = adpyrn
      advale(6)  = adhern
      advale(7)  = adpern
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
c 3. Calcul par type d'entite
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Calcul par type entite ; codret = ', codret
#endif
c
c 3.1. ==> Si une seule composante et si valeur relative, rien n'est
c          a faire, sinon traitement
c
      usacmp = taopti(8)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9+usacmp))
#endif
      if ( usacmp.eq.2 .and. ncmpin.eq.1 ) then
        goto 39
      endif
c
c 3.2. ==> traitement
cgn      call gmprsx(nompro,nohind//'.Arete.ValeursR')
c
      do 30 , iaux = -1, 7
c
        if ( nbvent(iaux).gt.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIUC0', nompro
#endif
          call deiuc0 ( nbvent(iaux), ncmpin, usacmp,
     >                  imem(adsupp(iaux)), rmem(advale(iaux)),
     >                  ulsort, langue, codret)
c
          endif
c
        endif
c
   30 continue
c
   39 continue
cgn      call gmprsx(nompro,nohind//'.Arete.ValeursR')
c
c====
c 4. Bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Bilan ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIUC0', nompro
#endif
      call deinbi ( nbvent, ncmpin,
     >              imem(adnosu), rmem(adnorn),
     >              imem(adarsu), rmem(adarrn),
     >              imem(adtrsu), rmem(adtrrn),
     >              imem(adqusu), rmem(adqurn),
     >              imem(adtesu), rmem(adtern),
     >              imem(adhesu), rmem(adhern),
     >              imem(adpysu), rmem(adpyrn),
     >              imem(adpesu), rmem(adpern),
     >              ulsort, langue, codret)
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
