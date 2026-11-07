      subroutine mmag34 ( indtet,
     >                    nbte06,
     >                    tbau51,
     >                    aretri,
     >                    tritet, cotrte,
     >                    hettet, filtet, pertet,
     >                    famtet,
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
c    Modification de Maillage - AGRegat - phase 3.4
c    -               -          --              - -
c    Creation des mailles pour les joints ponctuels :
c    . tetraedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . nbte06 . e   .   1    . nombre de tetr. des j. ponctuels d'ordre 6 .
c . tbau51 . e   .9*nbte06. Les tetraedres ponctuels entre les joints  .
c .        .     .        . triples :                                  .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : triangle cote du 1er joint triple  .
c .        .     .        . (3,i) : triangle cote du 2eme joint triple .
c .        .     .        . (4,i) : triangle cote du 3eme joint triple .
c .        .     .        . (5,i) : triangle cote du 4eme joint triple .
c .        .     .        . (1+k) : pour le k-eme triangle, 1 s'il     .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . es  .nbtecf*4. numeros des triangles des tetraedres       .
c . cotrte . es  .nbtecf*4. codes des triangles des tetraedres         .
c . hettet . es  . nbteto . historique de l'etat des tetraedres        .
c . filtet . es  . nbteto . premier fils des tetraedres                .
c . pertet . es  . nbteto . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nbteto . famille des tetraedres                     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'MMAG34' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nbfami.h"
#include "nombtr.h"
#include "nombte.h"
#include "impr02.h"
#include "i1i2i3.h"
#include "op0123.h"
c
c 0.3. ==> arguments
c
      integer indtet
      integer nbte06
      integer tbau51(9,nbte06)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer hettet(nbteto), filtet(nbteto), pertet(nbteto)
      integer famtet(nbteto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
c
      integer nulofa(4), nuloar(4,3), orient(4)
      integer aretet(6), letria(4)
c
      integer nbmess
      parameter ( nbmess = 40 )
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
#include "mmag01.h"
#include "mmag02.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7))
     >       mess14(langue,3,3)//'d''ordre 6', nbte06
#endif
c
      codret = 0
c
cgn      write(ulsort,90002) 'nbnoto, nbarto, nbtrto',nbnoto, nbarto,nbtrto
cgn      write(ulsort,90002) 'nbte06',nbte06
cgn      write(ulsort,90015) (iaux,iaux=1,20)
cgn      write(ulsort,90002) 'tbaux2',4,nbjoto
cgn      do 1101 , kaux = 1,nbjoto
cgn       write(ulsort,90015) (tbaux2(jaux,kaux),jaux=1,4)
cgn 1101 continue
cgn      write(ulsort,90002) 'tbau51',5,nbte06
cgn      do 1102 , kaux = 1,nbte06
cgn       write(ulsort,90015) (tbau51(jaux,kaux),jaux=1,5)
cgn 1102  continue
c
c====
c 2. Parcours des tetraedres de joint ponctuel d'ordre 6
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,3)
#endif
c
c                                    la face fi est opposee au sommet ni
c                     n1
c                     *
c                    .  ..
c                   .     . . a3
c                  .        .  .
c                 .           .   .
c             a1 .          a2  .    .  n4
c               .                 .    *
c              .                  . .   .
c             .        a5    .        .  . a6
c            .          .               . .
c           .      .                      ..
c          .  .                             .
c         *..................................*
c       n2               a4                  n3
c
c    . Les noeuds (1,2,3) definissent un triangle a orientation
c      vers l'exterieur
c     Avec le code 1, les faces sont :
c     Face 1 : aretes 4, 5, 6 (sortante)
c     Face 2 : aretes 2, 3, 6 (entrante)
c     Face 3 : aretes 1, 3, 5 (sortante)
c     Face 4 : aretes 1, 2, 4 (entrante)
c
c voir utarte pour le croquis ci-dessus
c
      do 2 , iaux = 1 , nbte06
c
        indtet = indtet + 1
c
c 2.1 ==> Recuperation des triangles et de leur orientation
c
        do 21 , jaux = 1 , 4
          letria(jaux) = tbau51(jaux+1,iaux)
          orient(jaux) = tbau51(jaux+5,iaux)
cgn      write (ulsort,90015) 'triangle', letria(jaux),
cgn     >                     ', d''orientation', orient(jaux)
cgn      write (ulsort,90002) 'aretes ',
cgn     > (aretri(letria(jaux),kaux),kaux=1,3)
   21   continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,texte(langue,4)) ' ',
     >                     mess14(langue,1,1), tbau51(1,iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,16)) mess14(langue,1,3), indtet, 0
#endif
c
c 2.2 ==> Positionnement des triangles en tant que face
c         nulofa(i) = numero local du triangle dans letria qui
c                     correspond a la face Fi
c         nuloar(i,j) = pour la face Fi, numero local de sa i-eme arete
c                       dans la description de la face
c 2.2.1. ==>  La face F1 est le 1er triangle enregistre.
c   On impose :
c     la 4eme arete du tetraedre est la 1ere arete du triangle ;
c   --> le code sera donc 1 ou 4.
c   Si l'orientation est positive, le triangle entre dans le tetraedre.
c   On lui donnera donc le code 4.
C   Inversement, si l'orientation est negative, il va sortir
c   du tetraedre. On lui donnera alors le code 1.
c
        tritet(indtet,1) = letria(1)
        if ( orient(1).gt.0 ) then
          cotrte(indtet,1) = 4
        else
          cotrte(indtet,1) = 1
        endif
c
c     Reperage des aretes de cette face
c
        aretet(4) = aretri(letria(1),1)
        if ( orient(1).gt.0 ) then
          aretet(5) = aretri(letria(1),3)
          aretet(6) = aretri(letria(1),2)
        else
          aretet(5) = aretri(letria(1),2)
          aretet(6) = aretri(letria(1),3)
        endif
#ifdef _DEBUG_HOMARD_
          if ( indtet.lt.0 ) then
      write (ulsort,90002) 'triangle pour F1', letria(1)
      write (ulsort,90002) 'aretes de tet 4-6',(aretet(jaux),jaux=4,6)
            endif
#endif
c
c 2.2.2. ==> La face F2 est l'autre triangle qui contient l'arete 6
c            C'est son arete numero 3
c
        do 222 , jaux = 2 , 4
          if ( aretet(6).eq.aretri(letria(jaux),1) ) then
            nulofa(2) = jaux
            nuloar(2,3) = 1
            goto 2221
          elseif ( aretet(6).eq.aretri(letria(jaux),2) ) then
            nulofa(2) = jaux
            nuloar(2,3) = 2
            goto 2221
          elseif ( aretet(6).eq.aretri(letria(jaux),3) ) then
            nulofa(2) = jaux
            nuloar(2,3) = 3
            goto 2221
          endif
  222   continue
        codret = 222
        goto 3333
c
 2221   continue
#ifdef _DEBUG_HOMARD_
          if ( indtet.lt.0 ) then
      write (ulsort,90002) 'triangle pour F2', letria(nulofa(2))
            endif
#endif
c
c 2.2.3. ==> La face F3 est l'autre triangle qui contient l'arete 5
c            C'est son arete numero 3
c
        do 223 , jaux = 2 , 4
          if ( aretet(5).eq.aretri(letria(jaux),1) ) then
            nulofa(3) = jaux
            nuloar(3,3) = 1
            goto 2231
          elseif ( aretet(5).eq.aretri(letria(jaux),2) ) then
            nulofa(3) = jaux
            nuloar(3,3) = 2
            goto 2231
          elseif ( aretet(5).eq.aretri(letria(jaux),3) ) then
            nulofa(3) = jaux
            nuloar(3,3) = 3
            goto 2231
          endif
  223   continue
        codret = 223
        goto 3333
c
 2231   continue
#ifdef _DEBUG_HOMARD_
          if ( indtet.lt.0 ) then
      write (ulsort,90002) 'triangle pour F3', letria(nulofa(3))
            endif
#endif
c
c 2.2.4. ==> La face F4 est l'autre triangle qui contient l'arete 4
c            C'est son arete numero 3
c
        do 224 , jaux = 2 , 4
          if ( aretet(4).eq.aretri(letria(jaux),1) ) then
            nulofa(4) = jaux
            nuloar(4,3) = 1
            goto 2241
          elseif ( aretet(4).eq.aretri(letria(jaux),2) ) then
            nulofa(4) = jaux
            nuloar(4,3) = 2
            goto 2241
          elseif ( aretet(4).eq.aretri(letria(jaux),3) ) then
            nulofa(4) = jaux
            nuloar(4,3) = 3
            goto 2241
          endif
  224   continue
        codret = 224
        goto 3333
c
 2241   continue
#ifdef _DEBUG_HOMARD_
          if ( indtet.lt.0 ) then
      write (ulsort,90002) 'triangle pour F4', letria(nulofa(4))
            endif
#endif
c
c 2.3. ==> Recherche de l'arete 1, commune aux faces F3 et F4
c
        do 23 , jaux = 1 , 3
          laux = aretri(letria(nulofa(3)),jaux)
          do 231 , kaux = 1, 3
            if ( laux.eq.aretri(letria(nulofa(4)),kaux) ) then
              nuloar(3,1) = jaux
              nuloar(4,1) = kaux
              aretet(1) = laux
              goto 2311
            endif
  231     continue
   23   continue
        codret = 23
        goto 3333
 2311   continue
c
c       On en deduit les aretes 2 et 3
c
        nuloar(3,2) = fp0123(nuloar(3,1),nuloar(3,3))
        aretet(3) = aretri(letria(nulofa(3)),nuloar(3,2))
c
        nuloar(4,2) = fp0123(nuloar(4,1),nuloar(4,3))
        aretet(2) = aretri(letria(nulofa(4)),nuloar(4,2))
c
c 2.4. ==> On termine les aretes de la face F2
c
        do 24 , jaux = 1 , 3
          if ( aretri(letria(nulofa(2)),jaux).eq.aretet(2) ) then
            nuloar(2,1) = jaux
            nuloar(2,2) = fp0123(nuloar(2,1),nuloar(2,3))
            goto 2411
          endif
   24   continue
        codret = 24
        goto 3333
 2411   continue
c
cgn      write (ulsort,90002) 'nuloar 2',(nuloar(2,jaux),jaux=1,3)
cgn      write (ulsort,90002) 'nuloar 3',(nuloar(3,jaux),jaux=1,3)
cgn      write (ulsort,90002) 'nuloar 4',(nuloar(4,jaux),jaux=1,3)
c
c 2.5.==> Mise en place de la face 2
c
        tritet(indtet,2) = letria(nulofa(2))
c
        do 25 , jaux = 1 , 6
          if ( i1(jaux).eq.nuloar(2,1) .and.
     >         i2(jaux).eq.nuloar(2,2) .and.
     >         i3(jaux).eq.nuloar(2,3) ) then
            cotrte(indtet,2) = jaux
            goto 2511
          endif
   25   continue
        codret = 25
        goto 3333
 2511   continue
c
c 2.6.==> Mise en place de la face 3
c
        tritet(indtet,3) = letria(nulofa(3))
c
        do 26 , jaux = 1 , 6
          if ( i1(jaux).eq.nuloar(3,1) .and.
     >         i2(jaux).eq.nuloar(3,2) .and.
     >         i3(jaux).eq.nuloar(3,3) ) then
            cotrte(indtet,3) = jaux
            goto 2611
          endif
   26   continue
        codret = 26
        goto 3333
 2611   continue
c
c 2.7.==> Mise en place de la face 4
c
        tritet(indtet,4) = letria(nulofa(4))
c
        do 27 , jaux = 1 , 6
          if ( i1(jaux).eq.nuloar(4,1) .and.
     >         i2(jaux).eq.nuloar(4,2) .and.
     >         i3(jaux).eq.nuloar(4,3) ) then
            cotrte(indtet,4) = jaux
            goto 2711
          endif
   27   continue
        codret = 27
        goto 3333
 2711   continue
c
c 2.8.==> Caracteristiques
c         iaux est le numero du joint ponctuel.
c         On decale pour tenir compte des familles HOMARD precedentes
c
        famtet(indtet) = nbftet + iaux
c
        hettet(indtet)  = 0
        filtet(indtet)  = 0
        pertet(indtet)  = 0
c
#ifdef _DEBUG_HOMARD_
      if ( indtet.ne.-1 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,3), indtet, 0
      write (ulsort,90002)'faces ',(tritet(indtet,jaux),jaux=1,4)
      write (ulsort,90002)'cotrte',(cotrte(indtet,jaux),jaux=1,4)
      write (ulsort,90002)'aretes 1-3',(aretet(jaux),jaux=1,3)
      write (ulsort,90002)'aretes 4-6',(aretet(jaux),jaux=4,6)
      endif
#endif
c
    2 continue
c
c====
c 3. la fin
c====
c
 3333 continue
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
