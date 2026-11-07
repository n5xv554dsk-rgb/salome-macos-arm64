      subroutine sfcoaq ( nomail, option,
     >                    nbarfr, nbqufr,
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
c   Suivi de Frontiere : COntrole - Aretes et Quadrangles concernes
c   --                   --         -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard             .
c . otpion . e   .   1    . type de recherche :                        .
c .        .     .        . 0 : toutes les entites actives             .
c .        .     .        . 1 : les actives qui viennent d'etre coupees.
c . nbarfr .   s .   1    . nombre d'aretes concernees                 .
c . nbqufr .   s .   1    . nombre de quadrangles concernes            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . en entree = celui du module d'avant        .
c .        .     .        . en sortie = celui du module en cours       .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 2x : probleme dans les memoires            .
c .        .     .        . 3x : probleme dans les fichiers            .
c .        .     .        . 5 : mauvaises options                      .
c .        .     .        . 6 : problemes dans les noms d'objet        .
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
      parameter ( nompro = 'SFCOAQ' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
#include "envca1.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer option
      integer nbarfr, nbqufr
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer psomar, phetar
      integer pcfaar, pfamar
      integer parequ, phetqu
      integer pcfaqu, pfamqu
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
c 1.1. ==> Les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Examen de toutes les entites.'')'
      texte(1,5) = '(''Examen des entites decoupees.'')'
      texte(1,6) = '(''Option incorrecte :'',i10)'
      texte(1,7) = '(''Aucun '',a,''n''''est concerne.'')'
      texte(1,8) = '(''Nombre de '',a,''concernes :'',i10)'
c
      texte(2,4) = '(''Examination of all the entities.'')'
      texte(2,5) = '(''Examination of cut entities.'')'
      texte(2,6) = '(''Non valid option :'',i10)'
      texte(2,7) = '(''No '',a,''is involved'')'
      texte(2,8) = '(''Number of involved '',a,'':'',i10)'
c
#include "impr03.h"
c
c 1.2. ==> Controle
c
      if ( option.lt.0 .and. option.gt.1 ) then
        write (ulsort,texte(langue,6)) option
        codret = 1
      else
        codret = 0
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4+option))
#endif
      endif
c
c====
c 2. recuperation des pointeurs
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
c 2.2.==> tableaux
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 518
      call utad02 ( iaux, nharet,
     >              phetar, psomar, jaux, jaux,
     >              pfamar, pcfaar,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( nbquto.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 518
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, jaux, jaux,
     >                pfamqu, pcfaqu,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 3. Decompte des aretes concernees par la frontiere
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Decompte aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCONA', nompro
#endif
      call sfcona ( option, nbarfr, imem(iaux),
     >              imem(phetar), imem(pcfaar), imem(pfamar),
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbarfr
#endif
c
      if ( nbarfr.eq.0 ) then
c
      write (ulsort,texte(langue,7)) mess14(langue,1,1)
c
      endif
c
      endif
c
c====
c 4. Decompte des quadrangles concernes par la frontiere
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Decompte quad ; codret', codret
#endif
c
      if ( nbquto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCONQ', nompro
#endif
        call sfconq ( option, nbqufr, imem(iaux),
     >                imem(phetqu), imem(pcfaqu), imem(pfamqu),
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,4), nbqufr
#endif
c
        if ( nbqufr.eq.0 ) then
c
        write (ulsort,texte(langue,7)) mess14(langue,1,4)
c
        endif
c
        endif
c
      endif
c
c====
c 5. la fin
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
