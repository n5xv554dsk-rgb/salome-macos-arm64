      subroutine utfmgr ( nomgro, nbfmgr, nrofam,
     >                    nbfmed, numfam,
     >                    grfmpo, grfmtl, grfmtb,
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
c     UTilitaire : quelle Famille MED pour un GRoupe ?
c     --                  -       -           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomgro .  e  . char*  . nom du groupe a chercher                   .
c . nbfmgr .   s .    1   . nombre de familles MED trouvees            .
c . nrofam .   s . nbfmgr . numeros des familles MED trouvees          .
c . nbfmed .  e  .    1   . nombre de familles MED                     .
c . numfam .  e  . nbfmed . numeros des familles MED                   .
c . grfmpo . e   .0:nbfmed. pointeur des groupes des familles          .
c . grfmtl . e   .   *    . taille des groupes des familles            .
c . grfmtb . e   .10ngrouc. table des groupes des familles             .
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
      parameter ( nompro = 'UTFMGR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*(*) nomgro
c
      integer nbfmgr, nrofam(*)
      integer nbfmed
      integer numfam(nbfmed)
      integer grfmpo(0:nbfmed)
      integer grfmtl(*)
c
      character*8 grfmtb(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nfam, ngro, nbgrou
      integer lnogro, lnogrf
c
      character*80 nomgrf
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
      texte(1,4) = '(''Recherche du groupe : '',a)'
c
      texte(2,5) = '(''Looking for group: '',a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomgro
#endif
c
      codret = 0
c
c====
c 2. longueur du nom du groupe
c====
c
      call utlgut ( lnogro, nomgro,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'lnogro', lnogro
#endif
c
c====
c 3. Explorations de toutes les familles
c====
c
      nbfmgr = 0
c
      do 31 , nfam = 1 , nbfmed
c
        if ( codret.eq.0 ) then
c
        nbgrou = ( grfmpo(nfam) - grfmpo(nfam-1) ) / 10
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90001) 'famille', nfam, numfam(nfam)
      write(ulsort,90002) 'nbgrou', nbgrou
#endif
c
c 3.1. ==> Explorations de tous les groupes associes a la famille
c
        do 311 , ngro = 1 , nbgrou
c
          iaux = grfmpo(nfam-1) + 1 + 10*(ngro-1)
          lnogrf = 0
          do 3111 , jaux = 1 , 10
            lnogrf = lnogrf + grfmtl(iaux+jaux-1)
 3111     continue
cgn          write(ulsort,90002) 'lnogrf', lnogrf
c
          if ( lnogrf.eq.lnogro ) then
c
            call uts8ch ( grfmtb(iaux), lnogrf, nomgrf,
     >                    ulsort, langue, codret )
cgn            write(ulsort,90003) 'Groupe ', nomgrf(1:lnogrf)
c
            if ( nomgrf(1:lnogrf).eq.nomgro(1:lnogro) ) then
              nbfmgr = nbfmgr + 1
              nrofam(nbfmgr) = numfam(nfam)
              goto 31
            endif
c
          endif
c
  311   continue
c
        endif
c
   31 continue
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'numeros des familles MED trouvees'
      write(ulsort,91020) (nrofam(iaux), iaux = 1 , nbfmgr)
#endif
c
c====
c 4. la fin
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
