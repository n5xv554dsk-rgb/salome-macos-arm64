      subroutine utchre ( chaine, valeur,
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
c   UTilitaire - convertit une CHaine de caractere en REel
c   --                         --                     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . chaine . e   .char*(*). chaine de caractere                        .
c . valeur .  s  .    1   . reel associe                               .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : chaine trop courte                     .
c .        .     .        . 2 : probleme au decodage                   .
c .        .     .        . 3 : la chaine est blanche                  .
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
      parameter ( nompro = 'UTCHRE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      double precision valeur
c
      character*(*) chaine
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer exposa, decima, sigman, sigexp
      integer lgchai
c
      character*1 lettre
c
      logical chiffr, point, expo, moins
c
      double precision mantis
c
      integer nbmess
      parameter (nbmess = 10 )
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
      texte(1,4) = '(''Chaine a convertir : '',a)'
      texte(1,5) = '(''==> valeur : '',g15.8)'
      texte(1,6) = '(''La chaine est blanche.'')'
c
      texte(2,4) = '(''String to convert : '',a)'
      texte(2,5) = '(''==> value : '',g15.8)'
      texte(2,6) = '(''String is empty.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) chaine
#endif
c
c====
c 2. decodage
c====
c
      codret = 0
c
c 2.1. ==> longueur reelle de la chaine
c
      call utlgut ( lgchai, chaine,
     >              ulsort, langue, codret )
      if (codret.eq.0) then
        if ( lgchai.eq.0 ) then
          write (ulsort,texte(langue,6))
          codret = 3
        endif
      endif
c
c 2.2. ==> decodage
c
      if ( codret.eq.0 ) then
c
      chiffr = .false.
      point = .false.
      expo = .false.
      moins = .false.
c
      mantis = 0.D0
      exposa = 0
      decima = 0
      sigman = 1
      sigexp = 1
c
      do 22 , iaux = 1 , lgchai
c
        lettre = chaine(iaux:iaux)
c
        if ( lettre .eq. '0' .or. lettre .eq. '1' .or.
     >       lettre .eq. '2' .or. lettre .eq. '3' .or.
     >       lettre .eq. '4' .or. lettre .eq. '5' .or.
     >       lettre .eq. '6' .or. lettre .eq. '7' .or.
     >       lettre .eq. '8' .or. lettre .eq. '9' ) then
          chiffr = .true.
          read(lettre,'(i1)') jaux
        elseif ( lettre .eq. '.') then
          point = .true.
        elseif ( lettre .eq. 'e' .or. lettre .eq. 'E' .or.
     >           lettre .eq. 'd' .or. lettre .eq. 'D' ) then
          expo = .true.
        elseif ( lettre .eq. '-') then
          moins = .true.
        elseif ( lettre .eq. '+' ) then
          goto 22
        else
          codret = 2
        endif
c
        if ( chiffr ) then
          if ( .not.point .and. .not.expo) then
            mantis = 10.D0 * mantis + dble(jaux)
          elseif ( .not.expo ) then
            decima = decima - 1
            mantis = mantis + dble(jaux) * 10.D0**decima
          else
            exposa = 10*exposa + jaux
          endif
          chiffr = .false.
        elseif ( moins ) then
          if ( .not.expo ) then
            sigman = -1
          else
            sigexp = -1
          endif
          moins = .false.
        endif
c
   22 continue
c
      valeur = dble(sigman)*mantis * 10.d0**(sigexp*exposa)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) valeur
#endif
c
      endif
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
      write (ulsort,texte(langue,4)) chaine
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
