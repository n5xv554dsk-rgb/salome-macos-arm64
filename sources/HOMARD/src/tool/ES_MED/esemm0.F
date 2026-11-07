      subroutine esemm0 ( idfmed, nomamd,
     >                      sdim,   mdim, descri,
     >                     nbpqt, inftbl,
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
c  Entree-Sortie - Ecriture d'un Maillage au format MED - phase 0
c  -      -        -             -                  -           -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage de sortie                         .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . sdim   . e   .   1    . dimension de l'espace                      .
c . mdim   . e   .   1    . dimension du maillage                      .
c . inftbl . e   .nbpqt*10. tables en caracteres des infos generales   .
c .        .     .        . regroupees par paquets de 80 caracteres    .
c .        .     .        . pour gerer la conversion en pseudo-groupe  .
c .        .     .        . paquet 1 : 1 : 'NomCo'                       .
c .        .     .        .            2/3, 4/5, 6/7 : nom coordonnees .
c .        .     .        .            8 : nom du repere utilise       .
c .        .     .        . paquet 2 : 1 : 'UniteCo'                     .
c .        .     .        .            2/3, 4/5, 6/7 : unite coord.    .
c .        .     .        . paquet 3 : titre (limite a 80 caracteres)  .
c .        .     .        . paquet 4 : 1 : 'NOMAMD'                    .
c .        .     .        .            2-7 :  nom du maillage          .
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
      parameter ( nompro = 'ESEMM0' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer sdim, mdim
      integer nbpqt
c
      character*8 inftbl(10*nbpqt)
c
      character*64 nomamd
      character*200 descri
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux, kaux
      integer typrep
      integer stype
c
      character*16 nomaxe(3), uniaxe(3)
      character*16 dtunit
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Ecriture complete.'')'
      texte(1,5) = '(''Ecriture uniquement de la renumerotation.'')'
c
      texte(2,4) = '(''Full writings.'')'
      texte(2,5) = '(''Writings of numbering only.'')'
c
#include "impr03.h"
c
#include "esimpr.h"
c
      codret = 0
c
c====
c 2. restauration des noms et unites des axes
c====
c
      do 21 , iaux = 1, nbpqt
c
        jaux = 10*(iaux-1) + 1
cgn        write (ulsort,90064) jaux, '%'//inftbl(jaux)//'%'
c
c 2.1. Repere et noms des coordonnees
c
        if ( inftbl(jaux).eq.'NomCo   ' ) then
c
          read ( inftbl(jaux+9), '(i8)' ) typrep
cgn          write (ulsort,90002)'typrep',typrep
          do 211 , kaux = 1 , sdim
            nomaxe(kaux) = inftbl(jaux+2*kaux-1)//inftbl(jaux+2*kaux)
cgn            write (ulsort,90064) kaux, '%'//nomaxe(kaux)//'%'
  211     continue
c
c 2.2. Unites des coordonnees
c
        elseif ( inftbl(jaux).eq.'UniteCo ' ) then
c
          do 212 , kaux = 1 , sdim
            uniaxe(kaux) = inftbl(jaux+2*kaux-1)//inftbl(jaux+2*kaux)
cgn            write (ulsort,90064) kaux, '%'//uniaxe(kaux)//'%'
  212     continue
c
        endif
c
   21 continue
c
c====
c 3. creation du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. creation du maillage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
c  a TRAITER mettre dtunit dans inftbl
      dtunit = blan16
      stype = edsodi
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'idfmed', idfmed
      write (ulsort,90003) 'nomamd', nomamd
      write (ulsort,90002) 'len(nomamd)', len(nomamd)
      write (ulsort,90002) 'sdim  ', sdim
      write (ulsort,90002) 'mdim  ', mdim
      write (ulsort,90002) 'ednost', ednost
      write (ulsort,90003) 'descri', descri
      write (ulsort,90003) 'dtunit', dtunit
      write (ulsort,90002) 'stype ', stype
      write (ulsort,90002) 'typrep', typrep
      write (ulsort,90003) 'nomaxe', nomaxe
      write (ulsort,90003) 'uniaxe', uniaxe
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHCRE', nompro
#endif
      call mmhcre ( idfmed, nomamd, sdim, mdim, ednost, descri,
     >              dtunit, stype, typrep, nomaxe, uniaxe, codret )
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,78)) 'mmhcre', codret
      endif
c
      endif
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
