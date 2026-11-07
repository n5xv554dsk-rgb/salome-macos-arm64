      subroutine deraff ( nomail,
     >                    lgopti, taopti, lgopts, taopts,
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
c traitement des DEcisions - RAFFinement
c                --          ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
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
      parameter ( nompro = 'DERAFF' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "envca1.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
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
      integer phetar, psomar, pfilar, pmerar
      integer phettr, paretr, pfiltr, ppertr, pnivtr
      integer phetqu, parequ, pfilqu, pperqu, pnivqu
      integer phette, ptrite
      integer phethe, pquahe, pcoquh
      integer phetpy, pfacpy, pcofay
      integer phetpe, pfacpe, pcofap
      integer pposif, pfacar
      integer advotr, advoqu, adpptr, adppqu
      integer pdecfa, pdecar
      integer adhoar, adhotr, adhoqu
      integer ptrav3
c
      character*6 saux
      character*8 ntrav3
c
      logical prem
c
#ifdef _DEBUG_HOMARD_
      character*6 nompra
#endif
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data prem / .true. /
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
      if ( prem ) then
        nrosec = taetco(4)
      endif
      call gtdems (nrosec)
c
c 1.3. ==> les messages
c
      texte(1,4) = '(/,a6,'' DECISIONS POUR LE RAFFINEMENT'')'
      texte(1,5) = '(36(''=''),/)'
c
      texte(2,4) = '(/,a6,'' REFINEMENT DECISIONS'')'
      texte(2,5) = '(27(''=''),/)'
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
c 2. recuperation des pointeurs, initialisations
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEARD0', nompro
#endif
      call deard0 ( nomail, taopts(11), taopts(12), ntrav3,
     >              phetar, psomar, pfilar, pmerar,
     >              phettr, paretr, pfiltr, ppertr, pnivtr,
     >              phetqu, parequ, pfilqu, pperqu, pnivqu,
     >              phette, ptrite,
     >              phethe, pquahe, pcoquh,
     >              phetpy, pfacpy, pcofay,
     >              phetpe, pfacpe, pcofap,
     >              pposif, pfacar,
     >              advotr, advoqu, adpptr, adppqu,
     >              pdecfa, pdecar,
     >              adhoar, adhotr, adhoqu,
     >              ptrav3,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. contamination des decisions pour le raffinement
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. contamination ; codret', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,3)) 'DELIST dercon', nompro
      nompra = 'dercon'
      iaux = 1
      call delist ( nomail, nompra, iaux,
     >              lgopts, taopts,
     >              ulsort, langue, codret )
c
      endif
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DERCON', nompro
#endif
      call dercon
     >        ( taopti(30), homolo, maconf,
     >          imem(pdecar), imem(pdecfa),
     >          imem(phetar), imem(pfilar), imem(pmerar), imem(adhoar),
     >          imem(pposif), imem(pfacar),
     >          imem(phettr), imem(paretr),
     >          imem(pfiltr), imem(ppertr), imem(pnivtr), imem(adhotr),
     >          imem(advotr), imem(adpptr),
     >          imem(phetqu), imem(parequ),
     >          imem(pfilqu), imem(pperqu), imem(pnivqu), imem(adhoqu),
     >          imem(advoqu), imem(adppqu),
     >          imem(phette), imem(ptrite),
     >          imem(phethe), imem(pquahe), imem(pcoquh),
     >          imem(phetpy), imem(pfacpy), imem(pcofay),
     >          imem(phetpe), imem(pfacpe), imem(pcofap),
     >          imem(ptrav3),
     >          ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,3)) 'DELIST apres dercon', nompro
      nompra = 'dercon'
      iaux = 2
      call delist ( nomail, nompra, iaux,
     >              lgopts, taopts,
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 4. decompte des decisions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. decompte decisions ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DECPTE', nompro
#endif
      call decpte ( taopti(31), taopti(32),
     >              imem(pdecar), imem(pdecfa),
     >              imem(phettr), imem(phetqu),
     >              imem(ptrite), imem(phette),
     >              imem(pquahe), imem(phethe),
     >              imem(pfacpy), imem(phetpy),
     >              imem(pfacpe), imem(phetpe),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. desallocations des tableaux de travail
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. desallocations ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav3 , codret )
c
      endif
c
c====
c 6. verification des decisions s'il existe des homologues
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. verif. homologue ; codret', codret
#endif
c
c 6.1. ==> sur les aretes
c
      if ( homolo.ge.2 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEHOVA', nompro
#endif
      call dehova ( imem(adhoar), imem(pdecar),
     >              nompro, 1,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c 6.2. ==> sur les triangles
c
      if ( homolo.ge.3 .and. nbtrto.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEHOVF', nompro
#endif
      iaux = 2
      call dehovf ( iaux,
     >              nbtrto, imem(adhotr), imem(pdecfa),
     >              nompro, 1,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c 6.3. ==> sur les quadrangles
c
      if ( homolo.ge.3 .and. nbquto.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEHOVF', nompro
#endif
      iaux = 4
      call dehovf ( iaux,
     >              nbquto, imem(adhoqu), imem(pdecfa),
     >              nompro, 1,
     >              ulsort, langue, codret )
c
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
      prem = .false.
c
c=======================================================================
      endif
c=======================================================================
c
      end
