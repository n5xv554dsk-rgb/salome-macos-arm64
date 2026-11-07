      subroutine hoapls ( lgopti, taopti, lgopts, taopts,
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
c   interface APres adaptation : Lectures de la SOLution
c             --                 -              ---
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
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 3 : probleme a la lecture                  .
c .        .     .        . 5 : mauvais type de code de calcul associe .
c .        .     .        . 6 : impossible de connaitre le code associe.
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
      parameter ( nompro = 'HOAPLS' )
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
      integer nbcham, nbfonc, nbprof, nblopg
      integer adinch, adinpf, adinpr, adinlg
c
      character*6 saux
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
      texte(1,4) = '(/,a6,'' LECTURE DE LA SOLUTION'')'
      texte(1,5) = '(29(''=''),/)'
      texte(1,6) = '(''Mauvais code de calcul :'',i5)'
      texte(1,7) = '(''Solution : '',a)'
      texte(1,8) = '(''Aucune fonction n''''est a interpoler.'')'
c
      texte(2,4) = '(/,a6,'' READINGS OF SOLUTION'')'
      texte(2,5) = '(27(''=''),/)'
      texte(2,6) = '(''Bad related code:'',i5)'
      texte(2,7) = '(''Solution: '',a)'
      texte(2,8) = '(''No fonction is to be interpolated.'')'
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
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. lecture de la solution
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> format med
c
      if ( mod(taopti(11)-6,10).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSMD', nompro
      call dmflsh(iaux)
#endif
c
        iaux = 1
        call eslsmd ( taopts(9), taopts(18),
     >                taopti(9), iaux,
     >                ulsort, langue, codret )
c
c 2.2. ==> autres formats : probleme
c
      else
c
        write (ulsort,texte(langue,6))  taopti(11)
        codret = 5
c
      endif
c
      endif
c
c====
c 3. la solution est-elle bien non vide ?
c    Si aucune fonction n'est presente, on annule la conversion.
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCASO', nompro
      call dmflsh (iaux)
#endif
      call utcaso ( taopts(9),
     >              nbcham, nbfonc, nbprof, nblopg,
     >              adinch, adinpf, adinpr, adinlg,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) taopts(9)
      write (ulsort,90002) 'nbcham', nbcham
      write (ulsort,90002) 'nbfonc', nbfonc
      write (ulsort,90002) 'nbprof', nbprof
      write (ulsort,90002) 'nblopg', nblopg
      call gmprsx (nompro,taopts(9))
      call gmprsx (nompro,taopts(9)//'.InfoCham')
      call gmprsx (nompro,taopts(9)//'.InfoPaFo')
      call gmprsx (nompro,taopts(9)//'.InfoLoPG')
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbfonc.eq.0 ) then
c
        write (ulsort,texte(langue,8))
        taopti(28) = 0
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
