      subroutine debil1 ( tyconf,
     >                    decfac, decare,
     >                    hetare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    hethex, quahex,
     >                    hetpen, facpen,
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
c traitement des DEcisions - BILan de la conformite - 1
c                --          ---                      -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tyconf . e   .   1    .  0 : conforme                              .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2                    .
c .        .     .        .  2 : non-conforme avec 1 seul noeud        .
c .        .     .        .      pendant par arete                     .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . decare . es  . nbarto . decisions des aretes                       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : il existe encore des non conformites   .
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
      parameter ( nompro = 'DEBIL1' )
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
#include "nombhe.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer tyconf
      integer decfac(-nbquto:nbtrto), decare(0:nbarto)
      integer hetare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer hethex(nbheto), quahex(nbhecf,6)
      integer hetpen(nbpeto), facpen(nbpecf,5)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer laface, faced, etatfa
      integer larelo, larete, etatar
      integer typenh, nbento, nbaret
      integer nbarpb, nbarp0, nbarp1, nbarp2, aret01
      integer lepent
      integer lehexa
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
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Probleme avec un '',a)'
      texte(1,5) =
     > '(a,''numero '',i10,'' : decision ='',i2,'', etat ='',i5)'
      texte(1,6) = '(''Examen du '',a,'' numero'',i10)'
c
      texte(2,4) = '(''Problem with a '',a)'
      texte(2,5) =
     > '(a,''#'',i10,'' : decision='',i2,'', status='',i5)'
      texte(2,6) = '(''Examination of the '',a,'' #'',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'tyconf', tyconf
#endif
c
c====
c 2. on explore tous les faces actives a garder
c    on verifie que les seules situations autorisees sont :
c    pilraf = 1 ou 2 : libre
c    pilraf = 3 : non-conforme avec 1 arete decoupee unique par element
c                 .                      ---------------
c                . .                     .             .
c               .   .                    .             .
c              .     .                   .             .
c             .       .                  .             .
c            .         .                 .             .
c           .           .                .             .
c           -------------                ---------------
c                 .                      ---------------
c                . .                     .             .
c               .   .                    .             .
c              .     .                   .             .
c             .       .                  .             .
c            .         .                 .             .
c           .           .                .             .
c           ------X------                --------X------
c          ---------------               --------X------
c          .             .               .             .
c          .             .               .             .
c          X             .               .             .
c          .             .               .             .
c          .             .               .             .
c          .             .               .             .
c           ------X------                --------X------
c    ==> il reste au moins deux aretes non coupees
c   <==> le nombre d'aretes active ou a reactiver vaut :
c        . 2 ou 3 pour un triangle
c        . 2, 3 ou 4 pour un quadrangle
c
c    pilraf = 4 : non-conforme avec 1 noeud pendant unique par arete
c                 .                      ---------------
c                . .                     .             .
c               .   .                    .             .
c              .     .                   .             .
c             .       .                  .             .
c            .         .                 .             .
c           .           .                .             .
c           -------------                ---------------
c                 .                      ---------------
c                . .                     .             .
c               .   .                    .             .
c              .     .                   .             .
c             .       .                  .             .
c            .         .                 .             .
c           .           .                .             .
c           ------X------                --------X------
c
c                 .                      ---------------
c                . .                     .             .
c               .   .                    .             .
c              X     .                   X             .
c             .       .                  .             .
c            .         .                 .             .
c           .           .                .             .
c           ------X------                --------X------
c
c          -------X-------               -------X-------
c          .             .               .             .
c          .             .               .             .
c          .             .               X             .
c          .             .               .             .
c          .             .               .             .
c          .             .               .             .
c          --------X------               --------X------
c    ==> tout est possible, sauf toutes les aretes coupees
c   <==> le nombre d'aretes active ou a reactiver vaut :
c        . 1, 2 ou 3 pour un triangle
c        . 1, 2, 3 ou 4 pour un quadrangle
c====
c
      codret = 0
      nbarp0 = 0
      nbarp1 = 1
c
      do 2 , typenh = 2, 4, 2
cgn        write (ulsort,*) mess14(langue,2,typenh)
c
        if ( typenh.eq.2 ) then
          nbento = nbtrto
          nbaret = 3
          nbarp2 = 1
        else
          nbento = nbquto
          nbaret = 4
          if ( tyconf.lt.0 ) then
            nbarp2 = 2
          else
            nbarp2 = 1
          endif
       endif
c
        do 20, laface = 1 , nbento
c
          if ( typenh.eq.2 ) then
            etatfa = mod( hettri(laface) , 10 )
            faced = laface
          else
            etatfa = mod( hetqua(laface) , 100 )
            faced = -laface
          endif
cgn          write (ulsort,1789)mess14(langue,1,typenh),
cgn     > laface,etatfa,decfac(faced)
cgn 1789 format(a,i6,' etat=',i4,' decision=',i2)
c
          if ( etatfa.eq.0 ) then
c
            if ( decfac(faced).eq.0 ) then
c
c 2.1. ==> on compte les aretes actives a garder et les aretes
c          inactives a reactiver
c
              nbarpb = 0
              aret01 = 0
c
              do 200 , larelo = 1 , nbaret
                if ( typenh.eq.2 ) then
                  larete = aretri(laface,larelo)
                else
                  larete = arequa(laface,larelo)
                endif
cgn      write (ulsort,1789)'arete',larete,hetare(larete),decare(larete)
                if ( decare(larete).eq.0 ) then
                  etatar = mod( hetare(larete) , 10 )
                  if ( etatar.eq.0 ) then
                    nbarpb = nbarpb + 1
                    if ( aret01.eq.0 ) then
                      aret01 = larete
                    endif
                  endif
                elseif ( decare(larete).eq.-1 ) then
                  nbarpb = nbarpb + 1
                  if ( aret01.eq.0 ) then
                    aret01 = larete
                  endif
                endif
  200         continue
cgn      write (ulsort,*)'==> nbarpb = ',nbarpb
c
c 2.2. ==> probleme : les decisions sur les aretes sont incoherentes
c                     avec les decisions sur les faces
c
              if ( nbarpb.eq.nbarp0 .or. nbarpb.eq.nbarp1 .or.
     >             nbarpb.eq.nbarp2 ) then
#ifdef _DEBUG_HOMARD_
                write (ulsort,texte(langue,4)) mess14(langue,1,typenh)
                if ( typenh.eq.2 ) then
                  iaux = hettri(laface)
                else
                  iaux = hetqua(laface)
                endif
                write (ulsort,texte(langue,5)) mess14(langue,2,typenh),
     >                         laface, decfac(faced), iaux
                do 220 , larelo = 1 , nbaret
                  if ( typenh.eq.2 ) then
                    larete = aretri(laface,larelo)
                  else
                    larete = arequa(laface,larelo)
                  endif
                  write (ulsort,texte(langue,5)) mess14(langue,2,1),
     >                         larete, decare(larete), hetare(larete)
  220           continue
#endif
                codret = 1
                goto 21
              endif
c
            endif
c
          endif
c
   20   continue
c
    2 continue
c
   21 continue
c
c====
c 3. Cas des pentaedres et du raffinement libre : tant que le
c    raffinement par conformite des pentaedres ne sait pas gerer les
c    escaliers, il faut forcer un raffinement local par boites de
c    ces pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Cas des pentaedres ; codret', codret
      write(ulsort,90002) 'nbpeto', nbpeto
#endif
c
      if ( ( tyconf.eq.0 ) .and. ( nbpeto.ne.0 ) ) then
c
      do 30 , lepent = 1 , nbpeto
c
        if ( mod(hetpen(lepent),100).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,7), lepent
#endif
          do 31 , iaux = 3, 5
c
            laface = facpen(lepent,iaux)
c
            if ( decfac(-laface).eq.0 ) then
              nbarpb = 0
              do 311 , larelo = 1 , 4
                larete = arequa(laface,larelo)
                if ( decare(larete).eq.0 ) then
                  etatar = mod( hetare(larete) , 10 )
                  if ( etatar.eq.2 ) then
                    nbarpb = nbarpb + 1
                  endif
                elseif ( decare(larete).eq.2 ) then
                  nbarpb = nbarpb + 1
                endif
  311         continue
cgn              if ( nbarpb.ne.0 ) then
cgn      write (ulsort,texte(langue,6)) mess14(langue,1,7), lepent
cgn      write(ulsort,90002) '.. nbarpb', nbarpb
cgn                endif
              if ( nbarpb.eq.2 ) then
                do 312 , larelo = 1 , 4
                  larete = arequa(laface,larelo)
                  if ( decare(larete).eq.0 ) then
                    etatar = mod( hetare(larete) , 10 )
                    if ( etatar.eq.0 ) then
                      decare(larete) = 2
                    endif
                  endif
  312           continue
                decfac(-laface) = 4
                codret = 1
              endif
c
            endif
c
   31     continue
c
        endif
c
   30 continue
c
      endif
c
c====
c 4. On ne peut pas deraffiner sur deux niveaux d'un coup en presence
c    de quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. deraffinement 2 coups ; codret', codret
#endif
c
c 4.1. Cas des hexaedres
c      Vu avec test_5
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1. Cas des hexaedres ; codret', codret
      write (ulsort,90002) 'nbhecf', nbhecf
#endif
c
      if ( nbhecf.ne.0 ) then
c
      do 410 , lehexa = 1 , nbhecf
c
        if ( mod(hethex(lehexa),100).eq.9 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,6), lehexa
#endif
cgn        if  ( lehexa.eq.244 .or. lehexa.eq.344 .or.
cgn     >      (lehexa.ge.1017 .and. lehexa.le.1024))then
cgn        write(ulsort,90112)'hethex', lehexa, hethex(lehexa)
cgn      do 241 , iaux=1,6
cgn        write(ulsort,90112)' decfac', quahex(lehexa,iaux),
cgn     >               decfac(-quahex(lehexa,iaux))
cgn  241 continue
cgn      endif
          do 411 , iaux = 1, 6
c
            laface = quahex(lehexa,iaux)
c
            if ( decfac(-laface).eq.-1 ) then
              do 4111 , larelo = 1 , 4
                larete = arequa(laface,larelo)
                if ( decare(larete).eq. -1 ) then
                  decare(larete) = 0
                endif
 4111         continue
              decfac(-laface) = 0
              codret = 1
c
            endif
c
  411     continue
c
        endif
c
  410 continue
c
      endif
c
c 4.2. Cas des pentaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. Cas des pentaedres ; codret', codret
      write (ulsort,90002) 'nbpecf', nbpecf
#endif
c
      if ( nbpecf.ne.0 ) then
c
      do 420 , lepent = 1 , nbpecf
c
        if ( mod(hetpen(lepent),100).eq.9 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,7), lepent
#endif
          do 421 , iaux = 3, 5
c
            laface = facpen(lepent,iaux)
c
            if ( decfac(-laface).eq.-1 ) then
              do 4211 , larelo = 1 , 4
                larete = arequa(laface,larelo)
                if ( decare(larete).eq. -1 ) then
                  decare(larete) = 0
                endif
 4211         continue
              decfac(-laface) = 0
              codret = 1
c
            endif
c
  421     continue
c
        endif
c
  420 continue
c
      endif
c
c====
c 5. la fin
c    en mode normal, on imprime seulement s'il y a un pb de memoire
c====
c
#ifdef _DEBUG_HOMARD_
      if ( codret.ne.0 ) then
#else
      if ( codret.ne.0 .and. codret.ne.1 ) then
#endif
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
