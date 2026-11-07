      subroutine decr03 ( decfac, decare,
     >                    hetare, posifa, facare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    listef,
     >                    afaire,
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
c traitement des DEcisions - Contraintes de Raffinement - 03
c                --          -              -             --
c    Bande de raffinement interdite
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . decare . es  . nbarto . decisions des aretes                       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . listef . aux . nbquto/. auxiliaire sur les faces (quad. + tri.)    .
c .        .     . nbtrto .                                            .
c . afaire . es  .    1   . que faire a la sortie                      .
c .        .     .        . 0 : aucune action                          .
c .        .     .        . 1 : refaire une iteration de l'algorithme  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon : probleme                           .
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
      parameter ( nompro = 'DECR03' )
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
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer decfac(-nbquto:nbtrto), decare(0:nbarto)
      integer hetare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer listef(*)
      integer afaire
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer ipos
      integer iaux, ideb, ifin
      integer laface, faced, etatfa
      integer larelo, larete, iface
      integer option, nbento, nbaret
      integer nbface, nbarpb
      integer infare(4), listar(4)
c
      integer nbmess
      parameter ( nbmess = 30 )
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
      texte(1,4) = '(5x,''Bande interdite.'')'
      texte(1,5) = '(7x,''Nombre de faces a reconsiderer :'',i6,/)'
      texte(1,6) = '(''. Probleme avec le '',a,i6)'
      texte(1,7) =
     > '(a,''numero '',i6,'' : decision ='',i2,'', etat ='',i5)'
c
      texte(2,4) = '(5x,''No band.'')'
      texte(2,5) = '(7x,''Number of faces to deal with :'',i6,/)'
      texte(2,6) = '(''. Problem with '',a,''#'',i6)'
      texte(2,7) =
     > '(a,''#'',i6,'' : decision ='',i2,'', status ='',i5)'
c
#include "impr03.h"
c
#include "derco1.h"
c
      codret = 0
c
      write (ulsort,texte(langue,4))
c
c====
c 2. on interdit les situations ou on aurait apparition d'une bande :
c    En triangle :
c    . un triangle coupe dont aucun voisin ne serait decoupe
c                 .                         .-------------.
c                . .                        .             .
c               .   .                       .             .
c              .     .                      .             .
c             .       .                     .             .
c            .         .                    .             .
c           .           .                   .             .
c          .-------------.                  .-------------.
c         . .     ..    . .                . .     ..    . .
c        .   .   .  .  .   .              .   .   .  .  .   .
c       .     . .    ..     .            .     . .    ..     .
c      .       .-----.       .          .       .-----.       .
c     .         .   .         .        .         .   .         .
c    .           . .           .      .           . .           .
c    -------------.-------------      -------------.-------------
c
c    . un triangle coupe dont un seul voisin est decoupe
c                        .
c                       . .
c                      .   .
c                     .     .
c                    .       .
c                   .         .
c                  .           .
c                 .-------------.
c                . .     ..    . .
c               .   .   .  .  .   .
c              .     . .    ..     .
c             .       .-----. ------.
c            .         .   .  .   .  .
c           .           . .    . .    .
c           -------------.------.------
c
c    En quadrangle :
c    . un quadrangle coupe dont aucun voisin ne serait decoupe
c
c            -------------------------------------------
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            -------------------------------------------
c            .             .      .      .             .
c            .             .      .      .             .
c            .             .-------------.             .
c            .             .      .      .             .
c            .             .      .      .             .
c            -------------------------------------------
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            -------------------------------------------
c
c    . un quadrangle coupe dont aucun voisin ne serait decoupe
c      dans une direction
c
c            -------------------------------------------
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            -------------------------------------------
c            .             .      .      .      .      .
c            .             .      .      .      .      .
c            .             .-------------.-------------.
c            .             .      .      .      .      .
c            .             .      .      .      .      .
c            -------------------------------------------
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            -------------------------------------------
c
c            -------------------------------------------
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            -------------------------------------------
c            .      .      .      .      .      .      .
c            .      .      .      .      .      .      .
c            .-------------.-------------.-------------.
c            .      .      .      .      .      .      .
c            .      .      .      .      .      .      .
c            -------------------------------------------
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            .             .             .             .
c            -------------------------------------------
c
c     Dans ces cas-la, il faut imposer le decoupage sur 1 ou 2 voisins
c
c     On parcourt les faces coupees ou a couper. On compte combien elles
c     possedent de faces voisines coupees ou a couper
c====
c
      nbface = 0
c
      do 2 , option = 2, 4, 2
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) mess14(langue,2,option)
#endif
c
        if ( option.eq.2 ) then
          nbento = nbtrto
          nbaret = 3
        else
          nbento = nbquto
          nbaret = 4
       endif
c
        do 20 , laface = 1 , nbento
c
          if ( option.eq.2 ) then
            etatfa = mod( hettri(laface) , 10 )
            faced = laface
          else
            etatfa = mod( hetqua(laface) , 100 )
            faced = -laface
          endif
c
          if ( ( etatfa.eq.0 .and. decfac(faced).eq.4 ) .or.
     >           etatfa.eq.4 .and. decfac(faced).ne.-1 ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,*)' '
          write (ulsort,texte(langue,7))mess14(langue,1,option),
     > laface,decfac(faced),etatfa
#endif
c
c 2.1. ==> on parcourt chacune des aretes ; on remplit le tableau infare
c          infare(ar) =  0 : une au moins des faces s'appuyant sur
c                            l'arete restera non decoupee
c          infare(ar) =  2 : toutes les faces s'appuyant sur l'arete
c                            sont coupees ou a couper
c          infare(ar) = -1 : l'arete est au bord
c
            do 21 , larelo = 1 , nbaret
c
              if ( option.eq.2 ) then
                larete = aretri(laface,larelo)
              else
                larete = arequa(laface,larelo)
              endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,7))'.. '//mess14(langue,1,1),
     > larete,decare(larete),hetare(larete)
#endif
              ideb = posifa(larete-1)+1
              ifin = posifa(larete)
c
              if ( ideb.eq.ifin ) then
                infare(larelo) = -1
              else
c
                infare(larelo) = 2
                do 211 , ipos = ideb , ifin
                  iface = facare(ipos)
                  if ( iface.ne.faced) then
                    if ( iface.gt.0 ) then
                      etatfa = mod( hettri(iface) , 10 )
                    else
                      etatfa = mod( hetqua(-iface) , 100 )
                    endif
#ifdef _DEBUG_HOMARD_
       write (ulsort,texte(langue,7))'.... '//mess14(langue,1,option),
     > abs(iface),decfac(iface),etatfa
#endif
                    if ( etatfa.ne.0 .and. decfac(iface).ne.-1 ) then
                      goto 21
                    else if ( decfac(iface).eq.4 ) then
                      goto 21
                    else
                      infare(larelo) = 0
                    endif
                  endif
  211           continue
c
              endif
c
   21       continue
c
c 2.2. ==> analyse
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,*) '==> infare : ',infare
#endif
            nbarpb = 0
c
c 2.2.1. ==> liste des aretes a traiter dans le cas du triangle
c
            if ( option.eq.2 ) then
c
              write (ulsort,*) 'pas glop'
              codret = 12
c
c 2.2.2. ==> liste des aretes a traiter dans le cas cas du quadrangle
c            on explore les aretes par paire : on intervient quand
c            deux aretes en vis-a-vis sont a garder ou qu'une arete a
c            garder est en face d'une arete de bord.
c
            else
c
              do 222 , iaux = 1 , 2
c
                larelo = 0
                if ( infare(iaux).eq.0 .and.
     >               infare(iaux+2).eq.-1 ) then
                  larelo = iaux
                elseif ( infare(iaux).eq.-1 .and.
     >                   infare(iaux+2).eq.0 ) then
                  larelo = iaux+2
                elseif ( infare(iaux).eq.0 .and.
     >                   infare(iaux+2).eq.0 ) then
                  larelo = iaux
                endif
c
                if ( larelo.ne.0 ) then
                  nbarpb = nbarpb + 1
                  listar(nbarpb) = arequa(laface,larelo)
                endif
c
  222         continue
c
            endif
c
c 2.2.3. ==> liste des faces voisines de ces aretes a traiter
c
            if ( nbarpb.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,6)) mess14(langue,1,option),laface
          write (ulsort,*)(listar(iaux),iaux=1,nbarpb)
#endif
c
              do 223 , iaux = 1 , nbarpb
c
                larete = listar(iaux)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,7))'.. '//mess14(langue,1,1),
     > larete,decare(larete),hetare(larete)
#endif
                ideb = posifa(larete-1)+1
                ifin = posifa(larete)
c
                do 2231 , ipos = ideb , ifin
                  iface = facare(ipos)
                  if ( iface.ne.faced) then
                    if ( iface.gt.0 ) then
                      etatfa = mod( hettri(iface) , 10 )
                    else
                      etatfa = mod( hetqua(-iface) , 100 )
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,7))'.... '//mess14(langue,1,4),
     > -iface,decfac(iface),hetqua(-iface)
#endif
                    endif
                    if ( etatfa.ne.0 .and. decfac(iface).ne.-1 ) then
                      goto 223
                    else if ( decfac(iface).eq.4 ) then
                      goto 223
                    else
                      nbface = nbface + 1
                      listef(nbface) = iface
                    endif
                  endif
 2231           continue
c
  223         continue
c
            endif
c
          endif
c
   20   continue
c
    2 continue
c
c====
c 3. modification des decisions
c    attention : il faut le faire seulement a la toute fin, sinon on
c    risque de propager le raffinement
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. modifications decfac ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbface.ne.0 ) then
c
        write (ulsort,texte(langue,5)) nbface
        afaire = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*)(listef(iaux),iaux=1,nbface)
#endif
c
        do 31 , iaux = 1 , nbface
c
          laface = listef(iaux)
          if ( decfac(laface).eq.0 ) then
            decfac(laface) = 4
          else
            decfac(laface) = 0
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*)' '
      write (ulsort,texte(langue,30))'decfac', laface,decfac(laface),' '
#endif
          nbaret = 0
          if ( laface.gt.0 ) then
            do 311 , larelo = 1 , 3
              larete = aretri(laface,larelo)
              if ( decare(larete).eq.0 .or. decare(larete).eq.-1 ) then
                nbaret = nbaret + 1
                infare(nbaret) = larete
              endif
  311       continue
          else
            do 312 , larelo = 1 , 4
              larete = arequa(-laface,larelo)
              if ( decare(larete).eq.0 .or. decare(larete).eq.-1 ) then
                nbaret = nbaret + 1
                infare(nbaret) = larete
              endif
  312       continue
          endif
c
          do 313 , larelo = 1 , nbaret
            larete = infare(larelo)
            if ( decare(larete).eq.0 ) then
              if ( mod(hetare(larete),10).eq.0 ) then
                decare(larete) = 2
              endif
            elseif ( decare(larete).eq.-1 ) then
              decare(larete) = 0
            endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare', larete,decare(larete),' '
#endif
  313     continue
c
   31   continue
c
      endif
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
