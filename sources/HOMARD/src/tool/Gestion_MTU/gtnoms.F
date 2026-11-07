      subroutine gtnoms ( numero, langue, titre )
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
c                                       premiere creation le 30.12.88 gn
c ______________________________________________________________________
c
c    'Gestion du Temps : NOM de Section'
c     -          -       ---    _
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numero . e   .    1   . numero de la section a mesurer             .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . titre  . e   . ch*24  . nom a donner a la section                  .
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
      parameter ( nompro = 'GTNOMS' )
c
#include "gtnbse.h"
#include "genbla.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer numero, langue
c
      character*(*) titre
c
c 0.4. ==> variables locales
c
#include "gtdita.h"
c
      integer code, iaux, ifin, lontit
      integer ulsort
c
      character*24 titr2
c
      integer nbmess
      parameter ( nbmess = 10 )
c
      character*80 texte(nblang,nbmess)
c
c====
c 1. initialisation des messages
c====
c
#include "impr01.h"
c
c====
c 2. recuperation de l'information
c====
c
      code = 1
      iaux = nbsep1
      call gttabl ( code, iaux, nbrapp, ouvert, titsec, tpscpu )
c
      ulsort = nbrapp(0)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 3. gestion de la section
c====
c
c 3.1. ==> verification du numero
c
      if ( numero.lt.1 .or. numero.gt.nbsect ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        lontit = min(24,len(titre))
        if (lontit.gt.0) then
          write (ulsort,31000) titre(1:lontit), numero, nbsect
        else
          write (ulsort,31000) '                        ',
     >                        numero, nbsect
        endif
        iaux = 1
        call gtstop ( nompro , ulsort , iaux )
      endif
c
31000 format(
     > 'On veut donner le nom ''',a24,''' a la section',i8,'.',
     >/'C''est impossible. Il faut un numero entre 1 et',i8,'.',/)
c
c 3.2. ==> verification du numero de la langue
c
      if ( langue.lt.1 .or. langue.gt.nblang ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        lontit = min(24,len(titre))
        if (lontit.gt.0) then
          write (ulsort,32000) titre(1:lontit), numero, langue, nblang
        else
          write (ulsort,32000) '                        ',
     >                        numero, langue, nblang
        endif
        iaux = 1
        call gtstop ( nompro , ulsort , iaux )
      endif
c
32000 format(
     > 'On veut donner le nom ''',a24,''' a la section',i8,'.',
     >/'Il est impossible de donner la langue',i8,'.',
     >/'Il faut un code de langue entre 1 et',i8,'.',/)
c
c 3.3. ==> determination de la longueur de la chaine de caracteres
c          de titre
c
      lontit = min(24,len(titre))
c
      if ( lontit.le.0 ) then
        ifin = 0
      else
        ifin = 0
        do 33 , iaux = lontit , 1 , -1
          if ( titre(iaux:iaux) .ne. ' ' ) then
            ifin = iaux
            goto 34
          endif
   33   continue
      endif
c
c 3.4. ==> affectation du titre a la section en cours
c
   34 continue
c
      if ( ifin.gt.0 ) then
        titr2 (1:ifin) = titre (1:ifin)
      endif
c
      do 341 , iaux = ifin+1 , 24
        titr2 (iaux:iaux) = ' '
  341 continue
c
      titsec (langue,numero) = titr2
c
c====
c 4. on archive l'information
c====
c
      code = 0
      iaux = nbsep1
      call gttabl ( code, iaux, nbrapp, ouvert, titsec, tpscpu )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
