      subroutine utb11f ( nubloc, nbbl00, typen0, typent,
     >                    nublen, tabau2, tabau3, tabau4,
     >                    ulbila,
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
c    UTilitaire - Bilan sur le maillage - option 11 - phase f
c    --           -                              --         -
c    Impressions
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nubloc . e   .   1    . numero du bloc s'il y en a plusieurs       .
c .        .     .        . -1 si un seul bloc                         .
c . nbbl00 . e   .   1    . si bloc volumique, nombre de blocs         .
c .        .     .        . surfaciques associes                       .
c .        .     .        . si bloc surfacique, nombre de blocs        .
c .        .     .        . lineiques associes                         .
c . typen0 . e   .   1    . type d'entites des blocs de meme type      .
c . typent . e   .   1    . type d'entites du bloc                     .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c .        .     .        .   8 : triangle et quadrangle               .
c .        .     .        .   9 : melange de volumes                   .
c . nublen . e   .-nbquto . numero du bloc pour chaque entite          .
c .        .     .   :*   .                                            .
c . tabau2 . e   . nbnoto . nombre de cas ou un noeud est dans le bloc .
c . tabau3 . e   . nbarto . nombre de cas ou une arete est dans le bloc.
c . tabau4 . e   .-nbquto . nombre de fois ou la face est dans le bloc .
c .        .     . :nbtrto. volumique :                                .
c .        .     .        . 0 : jamais                                 .
c .        .     .        . 1 : c'est une face du bord                 .
c .        .     .        . 2 : c'est une face interieure              .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c .        .     .        . si 0 : on n'ecrit rien                     .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB11F' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nubloc, nbbl00, typen0, typent
      integer nublen(-nbquto:*)
      integer tabau2(nbnoto)
      integer tabau3(nbarto)
      integer tabau4(-nbquto:*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nbnobl, nbarbl, nbfabl, nbvobl
      integer nbnomu
      integer nbenbl
      integer euler
      integer dimblo
c
      integer nbmess
      parameter (nbmess = 20 )
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
      texte(1,4) = '(/,a,'' : bloc numero'',i5)'
      texte(1,6) =
     >'(5x,''*'',19x,''Blocs de '',a,14x,''*'')'
      texte(1,7) =
     >'(5x,''* Les '',a,'' sont en un seul bloc.'',15x,''*'')'
      texte(1,8) =
     >'(5x,''* Bloc numero '',i8,5x,  '' *'',11x,''1 '',a,'' *'')'
      texte(1,9) =
     >'(5x,''* Bloc numero '',i8,5x,  '' * '',i11,1x,a,'' *'')'
      texte(1,10) =
     >'(5x,''*    Nombre de cavites internes :'',i5,19x,''*'')'
      texte(1,11) =
     >'(5x,''*    Nombre de trous traversant :'',i5,19x,''*'')'
      texte(1,12) =
     >'(5x,''*    Cette surface est fermee.'',27x,''*'')'
      texte(1,13) =
     >'(5x,''*    Cette surface a 1 bord.'',29x,''*'')'
      texte(1,14) =
     >'(5x,''*    Cette surface a'',i5,'' bords.'',25x,''*'')'
      texte(1,15) =
     >'(5x,''*    Cette ligne est fermee.'',29x,''*'')'
      texte(1,16) =
     >'(5x,''*    Cette ligne a deux extremites.'',22x,''*'')'
      texte(1,17) =
     >'(5x,''*    Cette ligne a'',i3,'' extremites.'',24x,''*'')'
      texte(1,18) =
     >'(5x,''*    Cette ligne a'',i5,'' noeuds multiples.'',16x,''*'')'
      texte(1,20) = '(''. Nombre de '',a,'':'',i11)'
c
      texte(2,4) = '(/,a,'' : block #'',i5)'
      texte(2,6) =
     >'(5x,''*'',19x,''Blocks of '',a,13x,''*'')'
      texte(2,7) =
     >'(5x,''* All the '',a,'' are connected.'',18x,''*'')'
      texte(2,8) =
     >'(5x,''* Block # '',i8,9x,      '' *'',11x,''1'',1x,a,'' *'')'
      texte(2,9) =
     >'(5x,''* Block # '',i8,9x,      '' * '',i11,1x,a,'' *'')'
      texte(2,10) =
     >'(5x,''*    Number of internal cavities :'',i5,18x,''*'')'
      texte(2,11) =
     >'(5x,''*    Number of crossing holes    :'',i5,18x,''*'')'
      texte(2,12) =
     >'(5x,''*    This surface does not have any boundary.'',12x,''*'')'
      texte(2,13) =
     >'(5x,''*    This surface has 1 boundary.'',24x,''*'')'
      texte(2,14) =
     >'(5x,''*    This surface has'',i5,'' boundaries.'',19x,''*'')'
      texte(2,15) =
     >'(5x,''*    This line is closed.'',32x,''*'')'
      texte(2,16) =
     >'(5x,''*    This line has 2 ends.'',31x,''*'')'
      texte(2,17) =
     >'(5x,''*    This line has'',i3,'' ends.'',32x,''*'')'
      texte(2,18) =
     >'(5x,''*    This line has'',i5,'' multiples nodes.'',17x,''*'')'
      texte(2,20) = '(''. Number of '',a,'':'',i11)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,4,typent),abs(nubloc)
#endif
c
#include "impr03.h"
c
10100 format(/,5x,58('*'))
10200 format(  5x,58('*'))
c
      codret = 0
c
      if ( typent.eq.1 ) then
        dimblo = 1
      elseif ( typent.eq.2 .or. typent.eq.4 .or. typent.eq.8 ) then
        dimblo = 2
      else
        dimblo = 3
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'dimblo =', dimblo
#endif
c
c====
c 2. Decompte des nombres d'entites
c====
c 2.1. ==> Volumes
c
      if ( dimblo.eq.3 ) then
c
        iaux = abs(nubloc)
        kaux = nbteto + nbpyto + nbheto + nbpeto - nbquto - 1
        nbvobl = 0
        do 21 , jaux = -nbquto , kaux
cgn        write(ulsort, *)jaux,nublen(jaux)
          if ( nublen(jaux).eq.iaux ) then
            nbvobl = nbvobl + 1
          endif
   21   continue
        nbenbl = nbvobl
c
      endif
c
c 2.2. ==> Faces
c
      if ( dimblo.eq.3 ) then
c
        nbfabl = 0
        do 221 , iaux = -nbquto , nbtrto
          if ( tabau4(iaux).gt.0 ) then
            nbfabl = nbfabl + 1
          endif
  221   continue
c
      elseif ( dimblo.eq.2 ) then
c
        iaux = abs(nubloc)
        nbfabl = 0
        do 222 , jaux = -nbquto , nbtrto
          if ( nublen(jaux).eq.iaux ) then
            nbfabl = nbfabl + 1
          endif
  222   continue
        nbenbl = nbfabl
c
      endif
c
c 2.3. ==> Aretes
c
      nbarbl = 0
c
      if ( dimblo.eq.1 ) then
c
        iaux = abs(nubloc)
        kaux = nbarto - nbquto - 1
        do 231 , jaux = -nbquto , kaux
cgn          write(ulsort, *)iaux,nublen(iaux)
          if ( nublen(jaux).eq.iaux ) then
            nbarbl = nbarbl + 1
          endif
  231   continue
        nbenbl = nbarbl
cgn       write(ulsort, *)nbarbl
c
      else
c
        do 232 , iaux = 1 , nbarto
cgn          write(ulsort, *)iaux,tabau3(iaux)
          if ( tabau3(iaux).gt.0 ) then
            nbarbl = nbarbl + 1
          endif
  232   continue
c
      endif
c
c 2.4. ==> Noeuds
c
      nbnobl = 0
      nbnomu = 0
c
      if ( dimblo.eq.1 ) then
c
        do 241 , iaux = 1 , nbnoto
cgn          write(ulsort, *)iaux,tabau2(iaux)
          if ( tabau2(iaux).eq.1 ) then
            nbnobl = nbnobl + 1
          elseif ( tabau2(iaux).ge.3 ) then
            nbnomu = nbnomu + 1
          endif
  241   continue
c
      else
c
        do 242 , iaux = 1 , nbnoto
cgn          write(ulsort, *)iaux,tabau2(iaux)
          if ( tabau2(iaux).gt.0 ) then
            nbnobl = nbnobl + 1
          endif
  242   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,20)) mess14(langue,3,-1), nbnobl
      write (ulsort,texte(langue,20)) mess14(langue,3,1), nbarbl
      if ( dimblo.eq.3 ) then
        write (ulsort,texte(langue,20)) mess14(langue,3,8), nbfabl
        write (ulsort,texte(langue,20))
     >        'blocs de '//mess14(langue,3,8), nbbl00
        write (ulsort,texte(langue,20)) mess14(langue,3,typent), nbvobl
      elseif ( dimblo.eq.2 ) then
        write (ulsort,texte(langue,20))
     >        'blocs de '//mess14(langue,3,1), nbbl00
        write (ulsort,texte(langue,20)) mess14(langue,3,typent), nbfabl
      endif
#endif
c
c====
c 3. Impression
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) '3. impression ; codret = ', codret
#endif
c 3.1. ==> En tete au premier passage
c
      if ( nubloc.eq.1 ) then
        write (ulbila,10100)
        write (ulbila,texte(langue,6)) mess14(langue,3,typen0)
        write (ulbila,10200)
      endif
c
c 3.2. ==> Texte
c
      if ( nubloc.lt.0 ) then
c
        write (ulbila,10100)
        write (ulbila,texte(langue,7)) mess14(langue,3,typent)
c
      else
c
        if ( nbenbl.eq.1 ) then
          write (ulbila,texte(langue,8)) nubloc, mess14(langue,1,typent)
        else
          write (ulbila,texte(langue,9)) nubloc, nbenbl,
     >                                   mess14(langue,3,typent)
        endif
c
      endif
c
c 3.3. ==> Trous ?
c          Remarques :
c          . on ne sait le faire que pour un maillage conforme
c          . en mode optimise, on n'imprime que s'il y a un trou.
c
c 3.3.1. ==> Examen d'un volume
c
      if ( dimblo.eq.3 ) then
c
        if ( ( maconf.eq.-1 ) .or. ( maconf.eq.0 ) ) then
c
          euler = nbbl00 + nbvobl - nbfabl + nbarbl - nbnobl
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) '  nbbl00', nbbl00
          write (ulsort,90002) '+ nbvobl', nbvobl
          write (ulsort,90002) '- nbfabl', -nbfabl
          write (ulsort,90002) '+ nbarbl', nbarbl
          write (ulsort,90002) '- nbnobl', - nbnobl
          write (ulsort,90002) '= euler', euler
#endif
c
#ifdef _DEBUG_HOMARD_
#else
          if ( euler.gt.0 .or. nbbl00.gt.1 ) then
#endif
c
            if ( nbbl00.gt.1 ) then
              write (ulbila,texte(langue,10)) nbbl00 - 1
            endif
            if ( euler.gt.0 ) then
              write (ulbila,texte(langue,11)) euler
            endif
c
#ifdef _DEBUG_HOMARD_
#else
          endif
#endif
c
        endif
c
c 3.3.2. ==> Examen d'une surface
c
      elseif ( dimblo.eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
#else
        if ( nbbl00.ne.1 ) then
#endif
          if ( nbbl00.eq.0 ) then
            write (ulbila,texte(langue,12))
          elseif ( nbbl00.eq.1 ) then
            write (ulbila,texte(langue,13))
          else
            write (ulbila,texte(langue,14)) nbbl00
          endif
c
#ifdef _DEBUG_HOMARD_
#else
        endif
#endif
c
c 3.3.3. ==> Examen d'une ligne
c
      else
c
#ifdef _DEBUG_HOMARD_
#else
        if ( nbnobl.ne.2 ) then
#endif
          if ( nbnobl.eq.0 ) then
            write (ulbila,texte(langue,15))
          elseif ( nbnobl.eq.2 ) then
            write (ulbila,texte(langue,16))
          else
            write (ulbila,texte(langue,17)) nbnobl
          endif
          if ( nbnomu.gt.0 ) then
            write (ulbila,texte(langue,18)) nbnomu
          endif
c
#ifdef _DEBUG_HOMARD_
#else
        endif
#endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
