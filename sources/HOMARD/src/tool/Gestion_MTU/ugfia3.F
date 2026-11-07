      subroutine ugfia3 ( ligne,
     >                    ideb1, ifin1, ideb2, ifin2,
     >                    ideb3, ifin3, ideb4, ifin4,
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
c retourne les indices de debut et de fin de chacun des 4 mots possibles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ligne  . e   .    1   . ligne a decoder                            .
c . ulsort . e   .    1   . unite logique d'impression                 .
c . idebi  .  s  .    1   . debut du mot numero i                      .
c . ifini  .  s  .    1   . fin du mot numero i                        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme de decodage des noms          .
c .        .     .        . 7 : impossible de decoder le $HOME         .
c .        .     .        .   : (ou une autre variable d'environnement).
c .        .     .        . 9 : probleme avec le fichier               .
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
      parameter ( nompro = 'UGFIA3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      character*(*) ligne
c
      integer ideb1, ideb2, ideb3, ideb4
      integer ifin1, ifin2, ifin3, ifin4
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer lemot2, lemot3
c
      integer lgmax
c
      logical ouverd, quotd2, quotd3
      logical ouvers, quots2, quots3
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      parameter ( lgmax = 400 )
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr03.h"
c
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de quotes dans la ligne :'',i4)'
      texte(1,5) = '(''Il en faut 0, 2 ou 4.'')'
c
      texte(2,4) = '(''Number of quotes in line :'',i4)'
      texte(2,5) = '(''0, 2 or 4 is required.'')'
c
      codret = 0
c
c====
c 2. recherche de la position du premier mot
c====
c
c 2.1. ==> recherche de la position du debut du premier mot : ideb1
c
      ideb1 = lgmax+1
      do 21 , jaux = 1 , lgmax
        if ( ligne(jaux:jaux).ne.' ' ) then
          ideb1 = jaux
          goto 22
        endif
   21 continue
c
   22 continue
cgn      write (ulsort,90002) 'ideb1',ideb1
c
c 2.2. ==> recherche de la position de la fin du premier mot : ifin1
c
      ifin1 = lgmax
      iaux = ideb1 + 1
      do 23 , jaux = iaux , lgmax
        if ( ligne(jaux:jaux).eq.' ' ) then
          ifin1 = jaux - 1
          goto 24
        endif
   23 continue
c
   24 continue
cgn      write (ulsort,90002) 'ifin1',ifin1
c
c====
c 3. reperage des debuts et fin des mots 2 et 3
c    on en profite pour reperer s'ils sont encadres par des quotes,
c    en distinguant les simples et les doubles
c====
c
      lemot2 = 0
      ideb2 = -1
      ideb3 = -1
      lemot3 = 0
      ouvers = .false.
      quots2 = .false.
      quots3 = .false.
      ouverd = .false.
      quotd2 = .false.
      quotd3 = .false.
      kaux = 0
      iaux = ifin1 + 1
      do 31 , jaux = iaux , lgmax
c
c 3.1. ==> c'est une quote double
c
        if ( ligne(jaux:jaux).eq.'"' ) then
          if ( ouverd ) then
            ouverd = .false.
            if ( lemot2.eq.1 ) then
              quotd2 = .true.
              lemot2 = 2
              ifin2 = jaux-1
            elseif ( lemot3.eq.1 ) then
              quotd3 = .true.
              lemot3 = 2
              ifin3 = jaux-1
            endif
          else
            ouverd = .true.
          endif
          kaux = kaux + 1
c
c 3.2. ==> c'est une quote simple
c          . si une quote double est ouverte, c'est un caractere comme
c          un autre, donc on ne fait rien de special
c          . sinon, c'est une ouverture
c
        elseif ( ligne(jaux:jaux).eq.'''' ) then
c
          if ( ouverd ) then
            goto 31
          elseif ( ouvers ) then
            ouvers = .false.
            if ( lemot2.eq.1 ) then
              quots2 = .true.
              lemot2 = 2
              ifin2 = jaux-1
            elseif ( lemot3.eq.1 ) then
              quots3 = .true.
              lemot3 = 2
              ifin3 = jaux-1
            endif
          else
            ouvers = .true.
          endif
          kaux = kaux + 1
c
c 3.3. ==> c'est un caractere non blanc : debut de mot
c
        elseif ( ligne(jaux:jaux).ne.' ' ) then
          if ( lemot2.le.1 ) then
            lemot2 = 1
            if ( ideb2.eq.-1 ) then
              ideb2 = jaux
            endif
          else
            lemot3 = 1
            if ( ideb3.eq.-1 ) then
              ideb3 = jaux
            endif
          endif
c
c 3.4. ==> c'est un caractere blanc : fin de mot si pas entre quotes
c
        elseif ( ligne(jaux:jaux).eq.' ' .and. .not.ouverd ) then
          if ( lemot2.eq.1 ) then
            lemot2 = 2
            ifin2 = jaux-1
          elseif ( lemot3.eq.1 ) then
            lemot3 = 2
            ifin3 = jaux-1
          endif
c
        endif
c
cgn        if ( ideb1.eq.1 .and. jaux.le.80) then
cgn 3499     format(      i8,              a2,    l2,    l2,    i2,    i2)
cgn          write (ulsort,3499)jaux,ligne(jaux:jaux),ouverd,ouvers,lemot2,lemot3
cgn        endif
   31 continue
c
c 3.n. ==> controle des quotes
c
cgn      write (ulsort,*) kaux, quotd2, quotd3
cgn      write (ulsort,*) kaux, quots2, quots3
cgn      write (ulsort,*) ideb2, ifin2, ideb3,ifin3
      if ( kaux.eq.0 .or.
     >     ( kaux.eq.2 .and. quotd2 .and. .not.quotd3 ) .or.
     >     ( kaux.eq.2 .and. quotd3 .and. .not.quotd2 ) .or.
     >     ( kaux.eq.4 .and. quotd2 .and. quotd3 ) .or.
     >     ( kaux.eq.2 .and. quots2 .and. .not.quots3 ) .or.
     >     ( kaux.eq.2 .and. quots3 .and. .not.quots2 ) .or.
     >     ( kaux.eq.4 .and. quots2 .and. quots3 ) ) then
        goto 40
      else
c
        write (ulsort,*) ligne
        write (ulsort,texte(langue,4)) kaux
        write (ulsort,texte(langue,5))
        codret = 3
c
      endif
c
c====
c 4. recherche de la position du quatrieme nom
c    s'il n'y en n'a pas, on passe directement au decodage.
c====
c
   40 continue
c
      ideb4 = -1
c
      if ( codret.eq.0 ) then
c
      if ( ideb3.gt.0 ) then
c
c 3.4.1. ==> recherche du debut du quatrieme nom : ideb4
c
        if ( quotd3 ) then
          iaux = ifin3 + 2
        else
          iaux = ifin3 + 1
        endif
        do 41 , jaux = iaux , lgmax
          if ( ligne(jaux:jaux).ne.' ' ) then
            ideb4 = jaux
            goto 42
          endif
  41   continue
c
        goto 50
c
  42   continue
c
c 3.4.2. ==> recherche de la fin du quatrieme nom : ifin4
c
        ifin4 = lgmax
        iaux = ideb4 + 1
        do 43 , jaux = iaux , lgmax
          if ( ligne(jaux:jaux).eq.' ' ) then
            ifin4 = jaux - 1
            goto 44
          endif
  43    continue
c
  44    continue
c
      endif
c
      endif
c
c====
c 5. fin
c====
c
   50   continue
cgn      write (ulsort,90002) 'ideb4, ifin4',ideb4, ifin4
c
      end
