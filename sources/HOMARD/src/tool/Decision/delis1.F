      subroutine delis1 ( option,
     >                    decare, decfac,
     >                    posifa, facare, hetare, merare,
     >                    hettri, nivtri,
     >                    hetqua, nivqua,
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
c traitement des DEcisions - LISte des decisions - 1
c                --          ---                   -
c     On utilise ce programme de debogage en modifiant le
c     contenu des tableaux lisare et listri.
c     Remarque : Les appels ont lieu seulement en mode DEBUG
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . x2 : affichage total                       .
c .        .     .        . x3 : les mailles a raffiner                .
c .        .     .        . x5 : les mailles a reactiver               .
c . decare . e   . nbarto . decisions des aretes                       .
c . decfac . e   . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . merare . e   . nbarto . mere des aretes                            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon, probleme                            .
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
      parameter ( nompro = 'DELIS1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer option
      integer decfac(-nbquto:nbtrto)
      integer decare(0:nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hetare(nbarto), merare(nbarto)
      integer hettri(nbtrto), nivtri(nbtrto)
      integer hetqua(nbquto), nivqua(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nbrqua, nbrtri, nbrare
c
      integer nbrq, nbrt, nbra
      parameter ( nbrq = 1 )
      parameter ( nbrt = 1 )
      parameter ( nbra = 1 )
c
      integer lisqua(nbrt)
      integer listri(nbrt)
      integer lisare(nbra)
c
      logical toutqu, touttr, toutar
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data lisqua /
     >  1
     >/
c
      data listri /
     >  1
     >/
c
      data lisare /
     >  1
     >/
c
      data toutqu / .true. /
      data touttr / .true. /
      data toutar / .true. /
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'option', option
#endif
c
      codret = 0
c
c 1.2. ==> On fait une fausse utilisation des variables pour
c     eviter des messages de ftnchek
c
      iaux = posifa(0)
      iaux = max(iaux,facare(1))
      iaux = max(iaux,hetare(1))
      iaux = max(iaux,abs(merare(1)))
c
c====
c 2. les triangles
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,99001) 'touttr', touttr
      write(ulsort,90002) 'nbtrto', nbtrto
      write(ulsort,90002) 'nbrt  ', nbrt
#endif
c
      if ( nbtrto.ne.0 ) then
c
      if ( touttr ) then
        nbrtri = nbtrto
      else
        nbrtri = min(nbrt,nbtrto)
      endif
c
      if ( mod(option,2).eq.0 ) then
c
20000 format (
     > //,'decisions sur les triangles',/,
     > '   Triangle! Dec ! Etat ! Niv.')
21000 format (i10,' ! ',i3,' ! ',i4,' ! ',i2)
c
      write (ulsort,20000)
c
cc      do 21 , iaux = 1 , nbrtri
cc        listri(iaux) = iaux
cc   21 continue
c
      do 221 , iaux = 1 , nbrtri
        if ( touttr ) then
          jaux = iaux
        else
          jaux = listri(iaux)
        endif
        write (ulsort,21000) jaux, decfac(jaux),
     >  hettri(jaux), nivtri(jaux)
  221 continue
c
      endif
c
      if ( mod(option,3).eq.0 ) then
c
      do 222 , iaux = 1 , nbrtri
        if ( touttr ) then
          jaux = iaux
        else
          jaux = listri(iaux)
        endif
        if ( decfac(jaux).eq.2 ) then
          write(ulsort,90015) 'Triangle', jaux, ' a decouper'
        endif
  222 continue
c
      endif
c
      if ( mod(option,5).eq.0 ) then
c
      do 223 , iaux = 1 , nbrtri
        if ( touttr ) then
          jaux = iaux
        else
          jaux = listri(iaux)
        endif
        if ( decfac(jaux).eq.-1 ) then
          write(ulsort,90015) 'Triangle', jaux, ' a reactiver'
        endif
  223 continue
c
      endif
c
      endif
c
c====
c 3. les quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,99001) 'toutqu', toutqu
      write(ulsort,90002) 'nbquto', nbquto
      write(ulsort,90002) 'nbrq  ', nbrq
#endif
c
      if ( nbquto.ne.0 ) then
c
      if ( toutqu ) then
        nbrqua = nbquto
      else
        nbrqua = min(nbrq,nbquto)
      endif
c
      if ( mod(option,2).eq.0 ) then
c
30000 format (
     > //,'decisions sur les quadrangles',/,
     > ' quadrangle! Dec ! Etat ! Niv.')
31000 format (i10,' ! ',i3,' ! ',i4,' ! ',i2)

      write (ulsort,30000)
c
cc      do 31 , iaux = 1 , nbrqua
cc        lisqua(iaux) = iaux
cc   31 continue
c
      do 321 , iaux = 1 , nbrqua
        if ( toutqu ) then
          jaux = iaux
        else
          jaux = lisqua(iaux)
        endif
        write (ulsort,31000) jaux, decfac(-jaux),
     >  hetqua(jaux), nivqua(jaux)
  321 continue
c
      endif
c
      if ( mod(option,3).eq.0 ) then
c
      do 322 , iaux = 1 , nbrqua
        if ( toutqu ) then
          jaux = iaux
        else
          jaux = lisqua(iaux)
        endif
        if ( decfac(-jaux).eq.2 ) then
          write(ulsort,90015) 'Quadrangle', jaux,
     >                        ' a decouper, de niveau', nivqua(jaux)
        endif
  322 continue
c
      endif
c
      if ( mod(option,5).eq.0 ) then
c
      do 323 , iaux = 1 , nbrqua
        if ( toutqu ) then
          jaux = iaux
        else
          jaux = lisqua(iaux)
        endif
        if ( decfac(-jaux).eq.-1 ) then
          write(ulsort,90015) 'Quadrangle', jaux,
     >                        ' a reactiver, de niveau', nivqua(jaux)
        endif
  323 continue
c
      endif
c
      endif
c
c====
c 4. Les aretes
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,99001) 'toutar', toutar
      write(ulsort,90002) 'nbarto', nbarto
      write(ulsort,90002) 'nbra  ', nbra
#endif
c
      if ( toutar ) then
        nbrare = nbarto
      else
        nbrare = min(nbra,nbarto)
      endif
c
      if ( mod(option,2).eq.0 ) then
c
40000 format (//,'decisions sur les aretes',/,
     > '  Arete  ! Dec ! Etat ')
41000 format (i8,' ! ',i3,' ! ',i4)
c
      write (ulsort,40000)
c
cc      do 41 , iaux = 1 , nbrare
cc        lisare(iaux) = iaux
cc   41 continue
c
      do 42 , iaux = 1 , nbrare
        if ( toutar ) then
          jaux = iaux
        else
          jaux = lisare(iaux)
        endif
        write (ulsort,41000) jaux, decare(jaux),
     >  hetare(jaux)
   42 continue
c
      endif
c
      if ( mod(option,3).eq.0 ) then
c
      do 422 , iaux = 1 , nbrare
        if ( toutar ) then
          jaux = iaux
        else
          jaux = lisare(iaux)
        endif
        if ( decare(jaux).eq.2 ) then
          write(ulsort,90015) 'Arete', jaux, ' a decouper'
        endif
  422 continue
c
      endif
c
      if ( mod(option,5).eq.0 ) then
c
      do 423 , iaux = 1 , nbrare
        if ( toutar ) then
          jaux = iaux
        else
          jaux = lisare(iaux)
        endif
        if ( decare(jaux).eq.-1 ) then
          write(ulsort,90015) 'Arete', jaux, ' a reactiver'
        endif
  423 continue
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
