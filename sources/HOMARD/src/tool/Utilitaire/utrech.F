      subroutine utrech ( reel, cadrag, lgchac, chacar,
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
c   UTilitaire - convertit un REel en CHaine de caractere
c   --                        --      --
c
c   Si la chaine fournie est plus longue que le nombre de chiffres a
c   ecrire, on complete par des blancs a droite ou a gauche, ou des 0
c   a gauche selon le type de cadrage demande.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . reel   . e   .    1   . reel a convertir                           .
c . cadrag . e   . char*1 . type de cadrage d'entier ecrit             .
c .        .     .        . g/G : le nombre est cadre a gauche : '83  '.
c .        .     .        . d/D : le nombre est cadre a droite : '  83'.
c .        .     .        .       et on complete par des blancs        .
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
      double precision reel
c
      integer lgchac
c
      character*1 cadrag
      character*(*) chacar
c
      integer ulsort, langue, codret
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.4. ==> variables locales
c
      integer lgfmt
      parameter ( lgfmt = 14 )
c
      integer iaux, lgch00
c
      logical cadgau
c
      character*7 fmt
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
      texte(1,10) = '(''Reel a convertir : '',g14.5)'
      texte(1,4) = '(''La chaine est trop petite : longueur = '',i4)'
      texte(1,5) = '(''Il faudrait au moins '',i4,'' places.'')'
      texte(1,7) = '(''Le type de cadrage est mauvais : '',a1)'
c
      texte(2,10) = '(''Real to convert : '',g14.5)'
      texte(2,4) = '(''The string is too short : length = '',i4)'
      texte(2,5) = '(''At less'',i4,'' places are needed.'')'
      texte(2,7) = '(''Bad choice : '',a1)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) reel
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
      if ( cadrag.eq.'d' .or. cadrag.eq.'D' ) then
        cadgau = .false.
      elseif ( cadrag.eq.'g' .or. cadrag.eq.'G' ) then
        cadgau = .true.
      else
        codret = 3
      endif
c
c 2.2. ==> verification de la longueur
c
      lgch00 = len(chacar)
      if ( lgfmt.gt.lgch00 ) then
        codret = 1
      endif
c
c 2.3. ==> ecriture
c
      if ( codret.eq.0 ) then
c
      fmt = '(G  .5)'
      write(fmt(3:4),'(i2)') lgfmt
c
      do 23 , iaux = 1 , lgch00
        chacar(iaux:iaux) = ' '
   23 continue
c
      if ( cadgau ) then
        write (chacar(1:lgfmt),fmt) reel
        lgchac = lgfmt
      else
        write (chacar(lgch00-lgfmt+1:lgch00),fmt) reel
        lgchac = lgch00
      endif
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
      write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
        write (ulsort,texte(langue,10)) reel
        if ( codret.eq.1 ) then
          write (ulsort,texte(langue,4)) lgch00
          write (ulsort,texte(langue,5)) lgfmt
        elseif ( codret.eq.3 ) then
          write (ulsort,texte(langue,7)) cadrag
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      endif
c
      end
