      subroutine utqure ( chaine,
     >                    nbsign, typsig, valcha, valent,
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
c   UTilitaire : QUestions / REponses
c   --           --          --
c ______________________________________________________________________
c
c   Decodage d'un texte composee de caracteres et d'entiers
c   On retourne pour chaque signe son type et sa valeur
c   Attention : on n'accepte que des caracteres*1 ou *2
c   Attention : la taille des tableaux de retour n'est pas controlee
c 
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . chaine . e   . char*  . chaine a decoder                           .
c . nbsign .   s .   1    . nombre de signes dans la chaine            .
c . typsig .   s .   3    . type des signes :                          .
c .        .     .        . -1 : rien                                  .
c .        .     .        .  0 : entier                                .
c .        .     .        .  1 : caractere*1                           .
c .        .     .        .  2 : caractere*2                           .
c . valcha .   s .   3    . valeur du signe s'il est caractere         .
c . valent .   s .   3    . valeur du signe s'il est entier            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme                               .
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
      parameter ( nompro = 'UTQURE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*(*) chaine
      character*2 valcha(3)
c
      integer nbsign
      integer typsig(3), valent(3)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer lgchai, lgsign
      integer iaux, ideb
      integer iaux1, iaux2
c
      character*5 fmt
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) =
     >  '(''Impossible de lire cette chaine en tant que nombre :'')'
c
      texte(2,10) = '(''This string cannot be read as a number :'')'
c
c 1.2. ==> valeurs par defaut
c
      do 12 , iaux = 1 , 3
        typsig(iaux) = -1
        valent(iaux) = 0
        valcha(iaux) = '  '
   12 continue
c
c====
c 2. longueur de la chaine
c====
c
      call utlgut ( lgchai, chaine,
     >              ulsort, langue, codret )
c
c====
c 2. Decodage
c====
c
      if ( codret.eq.0 ) then
c
      ideb = 1
      nbsign = 0
c
   20 continue
c
c 2.1. ==> iaux1 = premier caractere non-blanc
c
      iaux1 = 0
      do 211 , iaux = ideb , lgchai
        if ( chaine(iaux:iaux).ne.' ' ) then
          iaux1 = iaux
          goto 212
        endif
  211 continue
c
  212 continue
      if ( iaux1.eq.0 ) then
        goto 30
      endif
c
c 2.2. ==> iaux2 = premier caractere blanc suivant
c
      ideb = iaux1 + 1
      iaux2 = lgchai + 1
      do 221 , iaux = ideb , lgchai
        if ( chaine(iaux:iaux).eq.' ' ) then
          iaux2 = iaux
          goto 222
        endif
  221 continue
c
  222 continue
c
c 2.3. ==> quel type de signe ?
c
      nbsign = nbsign + 1
c
      lgsign = iaux2 - iaux1
c
      if ( lgsign.eq.1 ) then
c
        if ( chaine(iaux1:iaux1).eq.'0' .or.
     >       chaine(iaux1:iaux1).eq.'1' .or.
     >       chaine(iaux1:iaux1).eq.'2' .or.
     >       chaine(iaux1:iaux1).eq.'3' .or.
     >       chaine(iaux1:iaux1).eq.'4' .or.
     >       chaine(iaux1:iaux1).eq.'5' .or.
     >       chaine(iaux1:iaux1).eq.'6' .or.
     >       chaine(iaux1:iaux1).eq.'7' .or.
     >       chaine(iaux1:iaux1).eq.'8' .or.
     >       chaine(iaux1:iaux1).eq.'9' ) then
c
          typsig(nbsign) = 0
c
        else       
c
          typsig(nbsign) = 1
          valcha(nbsign)(1:2) = chaine(iaux1:iaux1)//' '
c
        endif
c
      elseif ( lgsign.eq.2 ) then
c
        iaux = iaux1+ 1
c
        if (
     > ( chaine(iaux1:iaux1).eq.'-' .or. chaine(iaux1:iaux1).eq.'0' .or.
     >   chaine(iaux1:iaux1).eq.'1' .or. chaine(iaux1:iaux1).eq.'2' .or.
     >   chaine(iaux1:iaux1).eq.'3' .or. chaine(iaux1:iaux1).eq.'4' .or.
     >   chaine(iaux1:iaux1).eq.'5' .or. chaine(iaux1:iaux1).eq.'6' .or.
     >   chaine(iaux1:iaux1).eq.'7' .or. chaine(iaux1:iaux1).eq.'8' .or.
     >   chaine(iaux1:iaux1).eq.'9' ) .and.
     > ( chaine(iaux:iaux).eq.'0' .or. chaine(iaux:iaux).eq.'1' .or.
     >   chaine(iaux:iaux).eq.'2' .or. chaine(iaux:iaux).eq.'3' .or.
     >   chaine(iaux:iaux).eq.'4' .or. chaine(iaux:iaux).eq.'5' .or.
     >   chaine(iaux:iaux).eq.'6' .or. chaine(iaux:iaux).eq.'7' .or.
     >   chaine(iaux:iaux).eq.'8' .or. chaine(iaux:iaux).eq.'9' ) ) then
c
          typsig(nbsign) = 0
c
        else       
c
          typsig(nbsign) = 2
          valcha(nbsign)(1:2) = chaine(iaux1:iaux)
c
        endif
c
      else
c
        typsig(nbsign) = 0
c
      endif
c
c 2.4. ==> decodage du numero eventuel
c
      if ( typsig(nbsign).eq.0 ) then
c
        fmt = '(I  )'
        if ( lgsign.lt.10 ) then
          write(fmt(3:3),'(i1)') lgsign
        else
          write(fmt(3:4),'(i2)') lgsign
        endif
        read (chaine(iaux1:iaux2-1),fmt,err=24,end=24) valent(nbsign)
        goto 25
   24   continue
        typsig(nbsign) = -1
        write (ulsort,texte(langue,10))
        write (ulsort,*) chaine(iaux1:iaux2)
        codret = 1
c
      endif
c
c 2.5. ==> on recommence
c
   25 continue
c
      ideb = iaux2
c
      goto 20
c
      endif
c====
c 3. la fin
c====
c
   30 continue
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
