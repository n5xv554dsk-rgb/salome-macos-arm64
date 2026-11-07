      subroutine infopf ( nbpafo, nopafo,
     >                    typg, numcal,
     >                    ulecr,
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
c   INFOrmation : Paquet de Fonctions
c   ----          -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbpafo . e   .   1    . nombre de paquets de fonctions             .
c . nopafo . e   . nbpafo . nom des objets qui contiennent la          .
c .        .     .        . description de chaque paquet de fonctions  .
c . typg   . e   .   1    . type de l'entite a examiner                .
c . numcal . e   .   1    . numero du calcul de l'entite a examiner    .
c . ulecr  . e   .   1    . unite logique pour l'ecriture              .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans les memoires             .
c .        .     .        . 3 : probleme dans les fichiers             .
c .        .     .        . 5 : probleme autre                         .
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
      parameter ( nompro = 'INFOPF' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer nbpafo
      integer typg, numcal
c
      integer ulecr
      integer ulsort, langue, codret
c
      character*8 nopafo(*)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nrpafo
      integer nbfopa, nbtyas, ngauss, carsup, typint
      integer adobfo, adtyge
c
      character*8 obpafo
c
      logical afaire
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''Type de l''''entite a examiner   :'',i5)'
      texte(1,5) = '(''Numero de l''''entite a examiner :'',i5)'
      texte(1,6) = '(/,''Paquet de fonction numero '',i5)'
c
      texte(2,4) = '(''Type of entity     :'',i5)'
      texte(2,5) = '(''Number of entity   :'',i5)'
      texte(2,6) = '(/,''Pack of functions # '',i5)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) typg
      write (ulsort,texte(langue,5)) numcal
#endif
c
      codret = 0
c
c====
c 2. on parcourt tous les paquets de fonctions
c====
c
      codret = 0
c
      do 20 , nrpafo = 1 , nbpafo
c
c 2.1. ==> caracterisation du paquet courant
c
        if ( codret.eq.0 ) then
c
        obpafo = nopafo(nrpafo)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) nrpafo
        call gmprsx (nompro, obpafo )
        call gmprsx (nompro, obpafo//'.Fonction' )
        call gmprsx (nompro, obpafo//'.TypeSuAs' )
#endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
        call utcapf ( obpafo,
     >                nbfopa, nbtyas, ngauss, carsup, typint,
     >                adobfo, adtyge,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbfopa', nbfopa
        write (ulsort,90002) 'nbtyas', nbtyas
        write (ulsort,90002) 'ngauss', ngauss
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,90002) 'typint', typint
#endif
c
c 2.2. ==> si le type de support est inclus dans ceux du paquet, on
c          examine toutes ses fonctions
c
        if ( codret.eq.0 ) then
c
        afaire = .false.
c
c       cas du support unique
c
        if ( nbtyas.ge.0 ) then
          if ( nbtyas.eq.typg ) then
            afaire = .true.
          endif
c
c       cas de support multiple
c
        else
c
          do 22 , iaux = 0, abs(nbtyas)-1
            if ( imem(adtyge+iaux).eq.typg ) then
              afaire = .true.
            endif
   22     continue
c
        endif
c
        if ( afaire ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'INFOFO', nompro
#endif
          call infofo ( nbfopa, smem(adobfo),
     >                    typg, numcal,
     >                   ulecr,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
   20 continue
c
c====
c 3. La fin
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
