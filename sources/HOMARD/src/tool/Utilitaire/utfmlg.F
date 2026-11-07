      subroutine utfmlg ( nbfmed, ngrouc,
     >                    grfmpo, grfmtl, grfmtb,
     >                    nbgrfm, nomgro, lgnogr,
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
c     UTilitaire : Famille MED : Liste des Groupes
c     --           -       -     -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfmed .  e  .    1   . nombre de familles MED                     .
c . ngrouc .  e  .    1   . nombre cumule de groupes dans les familles .
c . grfmpo . e   .0:nbfmed. pointeur des groupes des familles          .
c . grfmtl . e   .   *    . taille des groupes des familles            .
c . grfmtb . e   .10nbgroc. table des groupes des familles             .
c . nbgrfm .   s .    1   . nombre de groupes                          .
c . nomgro .   s .char*(*). noms des groupes (paquets de 10char8)      .
c . lgnogr .   s .    *   . longueur des noms des groupes              .
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
      parameter ( nompro = 'UTFMLG' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbfmed, ngrouc
      integer grfmpo(0:nbfmed)
      integer grfmtl(*)
      integer nbgrfm, lgnogr(ngrouc)
c
      character*8 grfmtb(*)
      character*8 nomgro(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nfam, ngro, nbgrou
      integer lnogrf
c
      character*80 nomgrf, nomgrl
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. Explorations de toutes les familles, s'il y a des groupes
c====
c
      nbgrfm = 0
c
      if ( ngrouc.gt.0 ) then
c
      do 21 , nfam = 1 , nbfmed
c
        if ( codret.eq.0 ) then
c
        nbgrou = ( grfmpo(nfam) - grfmpo(nfam-1) ) / 10
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nfam', nfam
      write(ulsort,90002) 'nbgrou', nbgrou
#endif
c
c 2.1. ==> Explorations de tous les groupes associes a la famille
c
        do 211 , ngro = 1 , nbgrou
c
c 2.1.1. ==> Longueur du nom
c
          iaux = grfmpo(nfam-1) + 1 + 10*(ngro-1)
          lnogrf = 0
          do 2111 , jaux = 1 , 10
            lnogrf = lnogrf + grfmtl(iaux+jaux-1)
 2111     continue
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'ngro / lnogrf', ngro, lnogrf
#endif
c
c 2.1.2. ==> Le nom
c
          call uts8ch ( grfmtb(iaux), lnogrf, nomgrf,
     >                  ulsort, langue, codret )
cgn          write(ulsort,90003) 'Groupe ', nomgrf(1:lnogrf)
c
c 2.1.3. ==> Le nom est-il deja enregistre ?
c
          do 2113 , jaux = 1 , nbgrfm
            if ( lnogrf.eq.lgnogr(jaux) ) then
              kaux = 10*(jaux-1) + 1
              call uts8ch ( nomgro(kaux), lnogrf, nomgrl,
     >                      ulsort, langue, codret )
cgn          write(ulsort,90003) '. Groupe ', nomgrl(1:lnogrf)
              if ( nomgrf(1:lnogrf).eq.nomgrl(1:lnogrf) ) then
                goto 219
              endif
            endif
 2113     continue
c
c 2.1.4. ==> Enregistrement d'un nouveau nom
c
          nbgrfm = nbgrfm + 1
          lgnogr(nbgrfm) = lnogrf
          kaux = 10*(nbgrfm-1) + 1
          call utchs8 ( nomgrf, 80, nomgro(kaux),
     >                  ulsort, langue, codret )
c
  219   continue
c
  211   continue
c
        endif
c
   21 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbgrfm', nbgrfm
#endif
c
c====
c 3. la fin
c====
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
