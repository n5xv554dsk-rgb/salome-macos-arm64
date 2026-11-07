      subroutine utench ( entier, cadrag, lgchac, chacar,
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
c   UTilitaire - convertit un ENtier en CHaine de caractere
c   --                        --        --
c
c   Si la chaine fournie est plus longue que le nombre de chiffres a
c   ecrire, on complete par des blancs a droite ou a gauche, ou des 0
c   a gauche selon le type de cadrage demande.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . entier . e   .    1   . entier a convertir                         .
c . cadrag . e   . char*1 . type de cadrage d'entier ecrit             .
c .        .     .        . g/G : le nombre est cadre a gauche : '83  '.
c .        .     .        . d/D : le nombre est cadre a droite : '  83'.
c .        .     .        .       et on complete par des blancs        .
c .        .     .        . 0   : le nombre est cadre a droite et on   .
c .        .     .        .       complete par des 0 : '0083'          .
c .        .     .        . _   : le nombre est cadre a droite et on   .
c .        .     .        .       complete par des _ : '__83'          .
c . lgchac .   s .    1   . longueur de la chaine obtenue              .
c . chacar .   s .char*(*). chaine de caractere                        .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : chaine trop courte                     .
c .        .     .        . 2 : le nombre est trop grand               .
c .        .     .        . 3 : type de cadrage inconnu                .
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
      parameter ( nompro = 'UTENCH' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer entier, lgchac
c
      character*1 cadrag
      character*(*) chacar
c
      integer ulsort, langue, codret
c
      integer nbmess
      parameter (nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, lgch00
c
      logical cadgau, negati
c
      character*1 saux01
      character*5 fmt
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
      texte(1,4) = '(''Cadrage voulu      : '',a1)'
      texte(1,5) = '(''La chaine est trop petite : longueur = '',i4)'
      texte(1,6) = '(''Il faudrait au moins '',i4,'' places.'')'
      texte(1,7) = '(''Le nombre est trop grand.'')'
      texte(1,8) = '(''Le type de cadrage est mauvais : '',a1)'
      texte(1,9) = '(''Longueur de la chaine obtenue : '',i8)'
      texte(1,10) = '(''Chaine obtenue : '',a,/)'
      texte(1,20) = '(''Entier a convertir : '',i8)'
c
      texte(2,4) = '(''Choice             : '',a1)'
      texte(2,5) = '(''The string is too short : length = '',i4)'
      texte(2,6) = '(''At less'',i4,'' places are needed.'')'
      texte(2,7) = '(''The integer is too big.'')'
      texte(2,8) = '(''Bad choice : '',a1)'
      texte(2,9) = '(''Lenght of chain : '',i8)'
      texte(2,10) = '(''Chain : '',a,/)'
      texte(2,20) = '(''Integer to convert : '',i8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,20)) entier
      write (ulsort,texte(langue,4)) cadrag
#endif
c
c====
c 2. decodage
c====
c
      codret = 0
c
c 2.1. ==> type de cadrage
c
      if ( cadrag.eq.'d' .or. cadrag.eq.'D' .or.
     >     cadrag.eq.'0' .or. cadrag.eq.'_' ) then
        cadgau = .false.
      elseif ( cadrag.eq.'g' .or. cadrag.eq.'G' ) then
        cadgau = .true.
      else
        codret = 3
      endif
c
c 2.2. ==> point de depart
c
      lgch00 = len(chacar)
      kaux = entier
c
c 2.3. ==> si le numero est strictement negatif, il faut inserer -
c
      if ( codret.eq.0 ) then
c
      if ( kaux.lt.0 ) then
        lgchac = 1
        if ( lgch00.le.1 ) then
          codret = 1
        endif
        if ( codret.eq.0 ) then
          negati = .true.
          kaux = - kaux
        endif
      else
        lgchac = 0
        negati = .false.
      endif
c
      endif
c
c 2.4. ==> nombre de chiffres de l'entier a convertir et ecriture
c
      if ( codret.eq.0 ) then
c
c 2.4.1. ==> si le numero est nul : on le traite tout de suite car cela
c            simplifie l'algorithme general
c
      if ( kaux.eq.0 ) then
c
        if ( lgch00.eq.0 ) then
          codret = 1
        endif
        if ( codret.eq.0 ) then
          if ( cadgau ) then
            chacar(1:1) = '0'
          else
            chacar(lgch00:lgch00) = '0'
          endif
          lgchac = 1
        endif
c
c 2.4.2. ==> pour un nombre non nul, le puissance de 10 immediatement
c            superieure equivaut au nombre de chiffres.
c
      else
c
        jaux = 0
        do 2421 , iaux = 1 , 99
          if ( kaux.lt.10**iaux ) then
            jaux = iaux
            goto 2422
          endif
 2421   continue
c
 2422   continue
c
        if ( jaux.eq.0 ) then
          codret = 2
        elseif ( lgchac+jaux.gt.lgch00 ) then
          codret = 1
          lgchac = lgchac+jaux
        else
          fmt = '(I   '
          if ( jaux.lt.10 ) then
            write(fmt(3:3),'(i1)') jaux
            fmt(4:4) = ')'
          else
            write(fmt(3:4),'(i2)') jaux
            fmt(5:5) = ')'
          endif
          if ( cadgau ) then
            write (chacar(lgchac+1:lgchac+jaux),fmt) kaux
            if ( negati ) then
              chacar(lgchac:lgchac) = '-'
            endif
          else
            write (chacar(lgch00-jaux+1:lgch00),fmt) kaux
            if ( negati ) then
              chacar(lgch00-jaux:lgch00-jaux) = '-'
            endif
          endif
          lgchac = lgchac+jaux
        endif
c
      endif
c
      endif
c
c 2.5. ==> complement avec des blancs ou des zeros
c
      if ( codret.eq.0 ) then
c
      if ( cadgau ) then
        saux01 = ' '
        jaux = lgchac+1
        kaux = lgch00
      else
        if ( cadrag.eq.'0' ) then
          saux01 = '0'
        elseif ( cadrag.eq.'_' ) then
          saux01 = '_'
        else
          saux01 = ' '
        endif
        jaux = 1
        kaux = lgch00-lgchac
        lgchac = lgch00
      endif
c
      do 25 , iaux = jaux, kaux
        chacar(iaux:iaux) = saux01
   25 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) lgchac
      write (ulsort,texte(langue,10)) chacar
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
      write (ulsort,texte(langue,20)) entier
      if ( codret.eq.1 ) then
        write (ulsort,texte(langue,5)) lgch00
        write (ulsort,texte(langue,6)) lgchac
      elseif ( codret.eq.2 ) then
        write (ulsort,texte(langue,7))
      elseif ( codret.eq.3 ) then
        write (ulsort,texte(langue,8)) cadrag
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      endif
c
      end
