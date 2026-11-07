      subroutine dehom1 ( pilraf, pilder,
     >                    hetare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    arehom, homtri, quahom,
     >                    decare, decfac,
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
c traitement des DEcisions - HOMologue - phase 1
c                --          ---               -
c     rmq : on ne peut pas utiliser les tables ho1are ... car elle ne
c           sont plus a jour apres suppression de la conformite
c
c     rmq : le raffinement est prioritaire sur le deraffinement
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . pilraf . e   .   1    . pilotage du raffinement                    .
c .        .     .        . -1 : raffinement uniforme                  .
c .        .     .        .  0 : pas de raffinement                    .
c .        .     .        .  1 : raffinement libre                     .
c .        .     .        .  2 : raff. libre homogene en type d'element.
c . pilder . e   .   1    . pilotage du deraffinement                  .
c .        .     .        . -1 : deraffinement uniforme                .
c .        .     .        .  0 : pas de deraffinement                  .
c .        .     .        .  1 : deraffinement libre                   .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . arehom . e   . nbarto . ensemble des aretes homologues             .
c . homtri . e   . nbtrto . ensemble des triangles homologues          .
c . quahom . e   . nbquto . ensemble des quadrangles homologues        .
c . decare . es  . nbarto . decisions des aretes                       .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'DEHOM1' )
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
#include "envada.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer pilraf, pilder
      integer hetare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer arehom(nbarto), homtri(nbtrto), quahom(nbquto)
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer arete1, arete2, face1, face2a, face2d, laface
      integer arete(4)
      integer etatar, etatfa
      integer areloc, letria
      integer nbarhd, nbarhg, nbarhr
      integer nbtrhd, nbtrhr
      integer nbquhd, nbquhr
      integer option, nbento, nbaret
c
      logical afaire
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) =
     >'(/,7x,''Nombre de '',a,''a garder par equivalence    :'',i10)'
      texte(1,5) =
     >'(/,7x,''Nombre de '',a,''a decouper par equivalence  :'',i10)'
      texte(1,6) =
     >'(/,7x,''Nombre de '',a,''a reactiver par equivalence :'',i10)'
c
      texte(2,4) =
     > '(/,7x,a,'' to keep due to equivalence       :'',i10)'
      texte(2,5) =
     > '(/,7x,a,'' to divide due to equivalence     :'',i10)'
      texte(2,6) =
     > '(/,7x,a,'' to reactivate due to equivalence :'',i10)'
c
      codret = 0
c
      nbarhg = 0
      nbarhr = 0
      nbarhd = 0
c
      nbtrhd = 0
      nbtrhr = 0
c
      nbquhd = 0
      nbquhr = 0
c
c====
c 2. dans le cas de deux aretes homologues, dont l'une est a reactiver
c    et l'autre doit etre maintenue parce elle borde une face a couper :
c    il faut empecher le deraffinement.
c    cela se produit apres une suppression de conformite
c
c     chiffres arabes  : decision sur les faces (decfac)
c     chiffres romains : decision sur les aretes (decare)
c     x : noeuds
c
c       maillage n : on derafine a gauche et on raffine a droite
c       apres l'initialisation des decisions on en est a :
c
c                x                             x
c               . .                           ...
c              .   .                         . . .
c             . -1  .         <-->          .  .  .
c         -I x.......x -I                I .   .   . I
c           . .     . .                   .    .    .
c          .   .-1 .   .                 .   1 . 0   .
c         . -1  . . -1  .               .      .      .
c        .       .       .             .       .       .
c       x--------x--------x           x--------x--------x
c               -I                             0
c
c
c       maillage n apres suppression de la conformite :
c
c                x                             x
c               . .                           . .
c              .   .                         .   .
c             . -1  .         <-->          .     .
c         -I x.......x -I                I .       . I
c           . .     . .                   .         .
c          .   .-1 .   .                 .     1     .
c         . -1  . . -1  .               .             .
c        .       .       .             .               .
c       x--------x--------x           x--------x--------x
c               -I                             0
c
c       Il faut donc inhiber le -I sur l'arete homologue de gauche :
c
c                x                             x
c               . .                           . .
c              .   .                         .   .
c             . -1  .         <-->          .     .
c         -I x.......x -I                I .       . I
c           . .     . .                   .         .
c          .   .-1 .   .                 .     1     .
c         . -1  . . -1  .               .             .
c        .       .       .             .               .
c       x--------x--------x           x--------x--------x
c                0                             0
c
c       pour obtenir :
c
c
c                x                             x
c               ...                           . .
c              . . .                         .   .
c             .  .  .         <-->          .     .
c            .   .   .                   I .       . I
c           .    .    .                   .         .
c          .     .     .                 .     1     .
c         .      .      .               .             .
c        .       .       .             .               .
c       x--------x--------x           x--------x--------x
c
c     il faut commencer par cette inhibition et ensuite seulement
c     transferer arete par arete
c===
c
      if ( homolo.ge.2 ) then
c
      if ( pilder.gt.0 .and. nbiter.ne.0 ) then
c
      do 21, letria = 1, nbtrto
c
        if ( decfac(letria).eq.4 ) then
c
          do 211 , areloc = 1, 3
            arete1 = aretri(letria,areloc)
            arete2 = abs(arehom(arete1))
            if ( arete2.ne.0 ) then
              if ( decare(arete2).eq.-1 ) then
                decare(arete2) = 0
                nbarhg = nbarhg + 1
#ifdef _DEBUG_HOMARD_
           write(ulsort,*) 'Gar. arete1 = ',arete1,' ==> arete2 ',arete2
#endif
              endif
            endif
  211     continue
c
        endif
c
   21 continue
c
      endif
c
      endif
c
c====
c 3. on complete les tables de decisions pour les faces en 3D
c    attention, il faut le faire avant les aretes pour pouvoir unifier
c    les decisions sur toutes les aretes
c====
c
      if ( homolo.ge.3 ) then
c
      do 3 , option = 2, 4, 2
c
        if ( option.eq.2 ) then
          nbento = nbtrto
          nbaret = 3
        else
          nbento = nbquto
          nbaret = 4
        endif
c
        do 30, face1 = 1 , nbento
c
          if ( option.eq.2) then
            laface = face1
            face2a = abs(homtri(face1))
            face2d = face2a
          else
            laface = -face1
            face2a = abs(quahom(face1))
            face2d = -face2a
          endif
c
          if ( face2a.ne.0 ) then
c
c 3.1. ==> unification du deraffinement
c
            if ( decfac(laface).eq.-1 .and. decfac(face2d).eq.0 ) then
c
c 3.1.1. ==> on controle si toutes les aretes de face2 sont a deraffiner
c            ou a garder
c
              afaire = .true.
              if ( option.eq.2) then
                do 311 , areloc = 1, nbaret
                  arete(areloc) = aretri(face2a,areloc)
  311           continue
              else
                do 312 , areloc = 1, nbaret
                  arete(areloc) = arequa(face2a,areloc)
  312           continue
              endif
c
              do 313 , areloc = 1, nbaret
                if ( decare(arete(areloc)).gt.0 ) then
                  afaire = .false.
                endif
  313         continue
c
c 3.1.2. ==> les aretes de face2 sont toutes a deraffiner ==> on
c            deraffine la face face2 et ses aretes
c
              if ( afaire ) then
#ifdef _DEBUG_HOMARD_
            write(ulsort,*) 'Der. face1 = ',laface,' ==> face2 ',face2d
#endif
                decfac(face2d) = -1
                if ( option.eq.2 ) then
                  nbtrhd = nbtrhd + 1
                else
                  nbquhd = nbquhd + 1
                endif
c
                do 314 , areloc = 1, nbaret
                  if ( decare(arete(areloc)).ne.-1 ) then
                    decare(arete(areloc)) = -1
                    nbarhg = nbarhg + 1
#ifdef _DEBUG_HOMARD_
                    write(ulsort,*) 'Der. arete1 = ',arete(areloc)
#endif
                  endif
  314           continue
              endif
c
            endif
c
c 3.2. ==> unification du raffinement
c
            if ( decfac(laface).eq.4 .and. decfac(face2d).ne.4 ) then
c
              if ( option.eq.2 ) then
                etatfa = mod(hettri(face2a),10)
              else
                etatfa = mod(hetqua(face2a),100)
              endif
              if ( etatfa.eq.0 ) then
                decfac(face2d) = 4
                if ( option.eq.2 ) then
                  nbtrhr = nbtrhr + 1
                else
                  nbquhr = nbquhr + 1
                endif
#ifdef _DEBUG_HOMARD_
            write(ulsort,*) 'Raf. face1 = ',laface,' ==> face2 ',face2d
#endif
              endif
c
              do 321 , areloc = 1, nbaret
                if ( option.eq.2 ) then
                  arete1 = aretri(face2a,areloc)
                else
                  arete1 = arequa(face2a,areloc)
                endif
                etatar = mod( hetare(arete1) , 10 )
                if ( decare(arete1).ne.2 .and. etatar.eq.0 ) then
                  decare(arete1) = 2
                  nbarhd = nbarhd + 1
#ifdef _DEBUG_HOMARD_
                  write(ulsort,*) '  ==> Raf. arete1 = ',arete1
#endif
                endif
  321         continue
c
            endif
c
          endif
c
   30   continue
c
    3 continue
c
      endif
c
c====
c 4. on complete les tables de decisions pour les aretes
c     pour chaque entite qui est "a decouper" et qui possede une entite
c     homologue, on declare "a decouper" l'entite homologue si elle ne
c     l'est pas deja (ce qui permet d'en faire le compte)
c====
c
      if ( homolo.ge.2 ) then
c
      do 41, arete1 = 1, nbarto
c
        arete2 = abs(arehom(arete1))
c
        if ( arete2.ne.0 ) then
c
c 4.1. ==> unification du deraffinement
c         A condition que l'arete homologue ne soit pas grand-mere !
c         Sinon, on inhibe le deraffinement sur la premiere
c
          if ( decare(arete1).eq.-1 .and. decare(arete2).eq.0 ) then
            etatar = mod( hetare(arete2) , 10 )
            if ( etatar.eq.9 ) then
              decare(arete1) = 0
              nbarhg = nbarhg + 1
            else
#ifdef _DEBUG_HOMARD_
           write(ulsort,*) 'Der. arete1 = ',arete1,' ==> arete2 ',arete2
#endif
              decare(arete2) = -1
              nbarhd = nbarhd + 1
            endif
          endif
c
c 4.2. ==> unification du raffinement
c
          if ( decare(arete1).eq.2 .and. decare(arete2).ne.2 ) then
            etatar = mod( hetare(arete2) , 10 )
            if ( etatar.eq.0 ) then
#ifdef _DEBUG_HOMARD_
           write(ulsort,*) 'Raf. arete1 = ',arete1,' ==> arete2 ',arete2
#endif
              decare(arete2) = 2
              nbarhr = nbarhr + 1
            endif
          endif
        endif
c
   41 continue
c
      endif
c
c====
c 5. messages
c====
c
      if ( homolo.ge.2 ) then
c
      if ( pilder.gt.0 ) then
        write(ulsort,texte(langue,6)) mess14(langue,3,1), nbarhd
        write(ulsort,texte(langue,4)) mess14(langue,3,1), nbarhg
      endif
      if ( pilraf.gt.0 ) then
        write(ulsort,texte(langue,5)) mess14(langue,3,1), nbarhr
      endif
c
      endif
c
      if ( homolo.ge.3 ) then
c
      if ( pilder.gt.0 ) then
        if ( nbtrto.gt.0 ) then
          write(ulsort,texte(langue,4)) mess14(langue,3,2), nbtrhd
        endif
        if ( nbquto.gt.0 ) then
          write(ulsort,texte(langue,4)) mess14(langue,3,4), nbquhd
        endif
      endif
      if ( pilraf.gt.0 ) then
        if ( nbtrto.gt.0 ) then
          write(ulsort,texte(langue,5)) mess14(langue,3,2), nbtrhr
        endif
        if ( nbquto.gt.0 ) then
          write(ulsort,texte(langue,5)) mess14(langue,3,4), nbquhr
        endif
      endif
c
      endif
c
c====
c 6. la fin
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
