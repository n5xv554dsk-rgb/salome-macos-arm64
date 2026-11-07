      subroutine esecs5 ( idfmed,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : ECriture des informations Supplementaires - 5
c  -      -        --                        -                 -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
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
      parameter ( nompro = 'ESECS5' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
#include "impr02.h"
#include "enti01.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
c
      character*8 nhtetr, nhhexa, nhpyra, nhpent
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer typenh
      integer nbencf, nbenca, nbrfac, nbrare
      integer codre0
      integer adcoar
      integer indmin
c
      character*2 saux02
      character*8 nhenti
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''... Ecriture des connectivites par aretes'')'
      texte(1,5) = '(/,''..... pour les '',a)'
      texte(1,7) = '(''Premieres valeurs : '',10i6)'
c
      texte(2,4) = '(''... Writings of connectivities by edges'')'
      texte(2,5) = '(/,''..... for '',a)'
      texte(2,7) = '(''First values : '',10i6)'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. Ecriture par type des connectivites par aretes sous forme de profil
c====
c
      do 20 , typenh = 3 , 7
c
c 2.1. ==> decodage des caracteristiques
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.3 ) then
          nbencf = nbtecf
          nbenca = nbteca
          nbrfac = 4
          nbrare = 6
          nhenti = nhtetr
        elseif ( typenh.eq.4 ) then
          nbencf = 0
          nbenca = 0
        elseif ( typenh.eq.5 ) then
          nbencf = nbpycf
          nbenca = nbpyca
          nbrfac = 5
          nbrare = 8
          nhenti = nhpyra
        elseif ( typenh.eq.6 ) then
          nbencf = nbhecf
          nbenca = nbheca
          nbrfac = 6
          nbrare = 12
          nhenti = nhhexa
        else
          nbencf = nbpecf
          nbenca = nbpeca
          nbrfac = 5
          nbrare = 9
          nhenti = nhpent
        endif
c
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) mess14(langue,3,typenh)//' nbenca', nbenca
#endif
c
        if ( nbenca.eq.0 ) then
          goto 20
        endif
c
c 2.3. ==> decodage
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) mess14(langue,3,typenh)
#endif
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.ConnAret', adcoar, iaux, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
c 2.4. ==> Ecriture pour chaque numero d'aretes
c          Quand il peut y avoir une description par arete, on complete
c          le tableau avec les premieres valeurs de la connectivite
c          pour optimiser le remplissage et utiliser le dimensionnement
c          habituel des entites, nbento
c          Une entite possede nbrfac faces et nbrare aretes.
c          La connectivite descendante ecrite dans le fichier med
c          est dimensionnee a nbento*nbrfac.
c          Dans esece2, on remplit donc le tableau avec deux parties :
c          . La connectivite descendante proprement dite, soit
c            nbencf*nbrfac variables.
c          . La connectivite par aretes des nbenca entites decrites, en
c            se limitant aux nbrfac premieres, soit nbenca*nbrfac
c            variables.
c          Cela fait bien en tout nbento*nbrfac = (nbencf+nbenca)*nbrfac
c          On ecrit dans esecs5 la fin des descriptions par aretes,
c          donc au dela de la nbrfac-ieme.
c
        if ( nbencf.eq.0 ) then
          indmin = 0
        else
          indmin = nbrfac
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbrfac', nbrfac
      write (ulsort,90002) 'nbrare', nbrare
#endif
c
        do 24 , iaux = indmin + 1, nbrare
c
          if ( codret.eq.0 ) then
c
          if ( iaux.le.9 ) then
            saux02 = '00'
            write(saux02(2:2),'(i1)') iaux
          else
            write(saux02,'(i2)') iaux
          endif

          noprof = blan64
          noprof(1:2) = suffix(3,typenh)(1:2)
c                         3456789012   34
          noprof(3:14) = '_ConnAret_'//saux02
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
      write (ulsort,texte(langue,62)) nbenca
      write (ulsort,texte(langue,7))
     >   (imem(adcoar+jaux),
     >  jaux=nbenca*(iaux-1),nbenca*(iaux-1)+min(nbenca-1,5))
#endif
c
          jaux = adcoar + nbenca*(iaux-1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW '//noprof(1:13), nompro
#endif
          call mpfprw ( idfmed, noprof,
     >                  nbenca, imem(jaux), codret )
c
          endif
c
   24   continue
c
   20 continue
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
