      subroutine mmag36 ( indhex, nbfhe0,
     >                    nbhe12,
     >                    tbau53,
     >                    arequa,
     >                    quahex, coquhe,
     >                    hethex, filhex, perhex,
     >                    famhex,
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
c    Modification de Maillage - AGRegat - phase 3.6
c    -               -          --              - -
c    Creation des mailles pour les joints ponctuels :
c    . hexaedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indhex . es  .   1    . indice du dernier hexaedre cree            .
c . nbfhe0 . e   .   1    . nombre de familles de hexaedres creees     .
c . nbhe12 . e   .   1    . nombre de hexa. des j. ponctuels d'ordre 12.
c . tbau53 . e   .  13*   . Les hexaedres ponctuels entre les joints   .
c .        .     . nbhe12 . quadruples (ordre 12) :                    .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : quadrangle cote du 1er joint quad. .
c .        .     .        . (3,i) : quadrangle cote du 2eme joint quad..
c .        .     .        . (4,i) : quadrangle cote du 3eme joint quad..
c .        .     .        . (5,i) : quadrangle cote du 4eme joint quad..
c .        .     .        . (6,i) : quadrangle cote du 5eme joint quad..
c .        .     .        . (7,i) : quadrangle cote du 6eme joint quad..
c .        .     .        . (1+k) : pour le k-eme quadrangle, 1 s'il   .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . quahex . es  .nbhecf*6. numeros des faces des hexaedres            .
c . coquhe . es  .nbhecf*6. codes des faces des hexaedres              .
c . hethex . es  . nbheto . historique de l'etat des hexaedres         .
c . filhex . es  . nbheto . premier fils des hexaedres                 .
c . perhex . es  . nbheto . pere des hexaedres                         .
c . famhex . es  . nbheto . famille des hexaedres                      .
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
      parameter ( nompro = 'MMAG36' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombqu.h"
#include "nombhe.h"
#include "impr02.h"
#include "j1234j.h"
#include "op1234.h"
#include "op1aa6.h"
c
c 0.3. ==> arguments
c
      integer indhex, nbfhe0
      integer nbhe12
      integer tbau53(13,nbhe12)
      integer arequa(nbquto,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
      integer hethex(nbheto), filhex(nbheto), perhex(nbheto)
      integer famhex(nbheto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
c
      integer nulofa(6), nuloar(6,4), orient(6)
      integer arehex(12), lequad(6)
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
     >       mess14(langue,3,6)//'d''ordre 12', nbhe12
#endif
c
      codret = 0
c
cgn      write(ulsort,90002) 'nbnoto, nbarto, nbtrto',nbnoto, nbarto,nbtrto
cgn      write(ulsort,90002) 'nbhe12',nbhe12
cgn      write(ulsort,90015) (iaux,iaux=1,20)
cgn      write(ulsort,90002) 'tbaux2',4,nbjoto
cgn      do 1101 , kaux = 1,nbjoto
cgn       write(ulsort,90015) (tbaux2(jaux,kaux),jaux=1,4)
cgn 1101 continue
cgn      write(ulsort,90002) 'tbau53',7,nbhe12
cgn      do 1102 , kaux = 1,nbhe12
cgn       write(ulsort,90015) (tbau53(jaux,kaux),jaux=1,7)
cgn 1102  continue
c
c====
c 2. Parcours des hexaedres de joint ponctuel d'ordre 12
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,6)
#endif
c
c                 S5            a9             S6
c                  ----------------------------
c                 /.                          /.
c                / .                         / .
c               /  .                        /  .
c              /   .                       /   .
c           a6/    .                      /a5  .
c            /     .                     /     .
c           /   a11.                    /      .a10
c          /       .    a1             /       .
c       S2----------------------------- S1     .
c         .        .                  .        .
c         .        .           a12    .        .
c         .     S8 -------------------.--------.S7
c         .       /                   .       /
c       a3.      /                    .a2    /
c         .     /                     .     /
c         .    /                      .    /
c         . a8/                       .   /a7
c         .  /                        .  /
c         . /                         . /
c         ./                          ./
c         -----------------------------
c        S3            a4             S4
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c     Avec le code 1, les faces sont :
c     Face 1 : aretes 1, 2, 4, 3
c     Face 2 : aretes 1, 6, 9, 5
c     Face 3 : aretes 2, 5, 10, 7
c     Face 4 : aretes 3, 8, 11, 6
c     Face 5 : aretes 4, 7, 12, 8
c     Face 6 : aretes 9, 11, 12, 10
c
c voir utarhe pour le croquis ci-dessus
c
      do 2 , iaux = 1 , nbhe12
c
        indhex = indhex + 1
c
c 2.1 ==> Recuperation des quadrangles et de leur orientation
c
        do 21 , jaux = 1 , 6
          lequad(jaux) = tbau53(jaux+1,iaux)
          orient(jaux) = tbau53(jaux+7,iaux)
cgn      write (ulsort,90015) 'quadrangle', lequad(jaux),
cgn     >                     ', d''orientation', orient(jaux)
cgn      write (ulsort,90002) 'aretes ',
cgn     > (arequa(lequad(jaux),kaux),kaux=1,4)
   21   continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,texte(langue,4)) ' ',
     >                     mess14(langue,1,1), tbau53(1,iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,16)) mess14(langue,1,6), indhex, 0
#endif
c
c 2.2 ==> Positionnement des quadrangles en tant que face
c         nulofa(i) = numero local dans lequad du quadrangle
c                     qui correspond a la face Fi
c         nuloar(i,j) = pour la face Fi, numero local de sa i-eme arete
c                       dans la description de la face
c 2.2.1. ==>  La face F1 est le 1er quadrangle enregistre.
c   On impose :
c     la 1ere arete de l'hexaedre est la 1ere arete du quadrangle ;
c   --> le code sera donc 1 ou 5.
c   Si l'orientation est positive, le quadrangle entre dans l'hexaedre.
c   On lui donnera donc le code 1.
C   Inversement, si l'orientation est negative, il va sortir
c   de l'hexaedre. On lui donnera alors le code 5.
c
        quahex(indhex,1) = lequad(1)
        if ( orient(1).gt.0 ) then
          coquhe(indhex,1) = 1
        else
          coquhe(indhex,1) = 5
        endif
c
c     Reperage des aretes de cette face
c
        arehex(1) = arequa(lequad(1),1)
        if ( orient(1).gt.0 ) then
          arehex(2) = arequa(lequad(1),2)
          arehex(3) = arequa(lequad(1),4)
        else
          arehex(2) = arequa(lequad(1),4)
          arehex(3) = arequa(lequad(1),2)
        endif
        arehex(4) = arequa(lequad(1),3)
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90015) 'quadrangle pour F1', lequad(1),
     >                     ', d''orientation', orient(1)
      write (ulsort,90002) 'aretes de hex 1-4',(arehex(jaux),jaux=1,4)
            endif
#endif
c
c 2.2.2. ==> La face F2 est le quadrangle qui contient l'arete 1
c            C'est son arete numero 1
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90002) 'F2 bati sur arete 1',arehex(1)
        endif
#endif
c
        do 222 , jaux = 2 , 6
          if ( arehex(1).eq.arequa(lequad(jaux),1) ) then
            nulofa(2) = jaux
            nuloar(2,1) = 1
            goto 2221
          elseif ( arehex(1).eq.arequa(lequad(jaux),2) ) then
            nulofa(2) = jaux
            nuloar(2,1) = 2
            goto 2221
          elseif ( arehex(1).eq.arequa(lequad(jaux),3) ) then
            nulofa(2) = jaux
            nuloar(2,1) = 3
            goto 2221
          elseif ( arehex(1).eq.arequa(lequad(jaux),4) ) then
            nulofa(2) = jaux
            nuloar(2,1) = 4
            goto 2221
          endif
  222   continue
        codret = 222
        goto 5555
c
 2221   continue
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90002) 'quadrangle pour F2', lequad(nulofa(2))
      write (ulsort,90002) 'aretes',
     >                     (arequa(lequad(nulofa(2)),jaux),jaux=1,4)
            endif
#endif
c
c 2.2.3. ==> La face F3 est le quadrangle qui contient l'arete 2
c            C'est son arete numero 1
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90002) 'F3 bati sur arete 2',arehex(2)
        endif
#endif
c
        do 223 , jaux = 2 , 6
          if ( arehex(2).eq.arequa(lequad(jaux),1) ) then
            nulofa(3) = jaux
            nuloar(3,1) = 1
            goto 2231
          elseif ( arehex(2).eq.arequa(lequad(jaux),2) ) then
            nulofa(3) = jaux
            nuloar(3,1) = 2
            goto 2231
          elseif ( arehex(2).eq.arequa(lequad(jaux),3) ) then
            nulofa(3) = jaux
            nuloar(3,1) = 3
            goto 2231
          elseif ( arehex(2).eq.arequa(lequad(jaux),4) ) then
            nulofa(3) = jaux
            nuloar(3,1) = 4
            goto 2231
          endif
  223   continue
        codret = 223
        goto 5555
c
 2231   continue
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90002) 'quadrangle pour F3', lequad(nulofa(3))
      write (ulsort,90002) 'aretes',
     >                     (arequa(lequad(nulofa(3)),jaux),jaux=1,4)
            endif
#endif
c
c 2.2.4. ==> La face F4 est le quadrangle qui contient l'arete 3
c            C'est son arete numero 1
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90002) 'F4 bati sur arete 3',arehex(3)
        endif
#endif
c
        do 224 , jaux = 2 , 6
          if ( arehex(3).eq.arequa(lequad(jaux),1) ) then
            nulofa(4) = jaux
            nuloar(4,1) = 1
            goto 2241
          elseif ( arehex(3).eq.arequa(lequad(jaux),2) ) then
            nulofa(4) = jaux
            nuloar(4,1) = 2
            goto 2241
          elseif ( arehex(3).eq.arequa(lequad(jaux),3) ) then
            nulofa(4) = jaux
            nuloar(4,1) = 3
            goto 2241
          elseif ( arehex(3).eq.arequa(lequad(jaux),4) ) then
            nulofa(4) = jaux
            nuloar(4,1) = 4
            goto 2241
          endif
  224   continue
        codret = 224
        goto 5555
c
 2241   continue
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90002) 'quadrangle pour F4', lequad(nulofa(4))
      write (ulsort,90002) 'aretes',
     >                     (arequa(lequad(nulofa(4)),jaux),jaux=1,4)
            endif
#endif
c
c 2.2.5. ==> La face F5 est le quadrangle qui contient l'arete 4
c            C'est son arete numero 1
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90002) 'F5 bati sur arete 4',arehex(4)
        endif
#endif
c
        do 225 , jaux = 2 , 6
          if ( arehex(4).eq.arequa(lequad(jaux),1) ) then
            nulofa(5) = jaux
            nuloar(5,1) = 1
            goto 2251
          elseif ( arehex(4).eq.arequa(lequad(jaux),2) ) then
            nulofa(5) = jaux
            nuloar(5,1) = 2
            goto 2251
          elseif ( arehex(4).eq.arequa(lequad(jaux),3) ) then
            nulofa(5) = jaux
            nuloar(5,1) = 3
            goto 2251
          elseif ( arehex(4).eq.arequa(lequad(jaux),4) ) then
            nulofa(5) = jaux
            nuloar(5,1) = 4
            goto 2251
          endif
  225   continue
        codret = 225
        goto 5555
c
 2251   continue
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90002) 'quadrangle pour F5', lequad(nulofa(5))
      write (ulsort,90002) 'aretes',
     >                     (arequa(lequad(nulofa(5)),jaux),jaux=1,4)
            endif
#endif
c
c 2.3. ==> Recherche des aretes 5, 6, 7, 8, 9, 10, 11 et 12
c 2.3.1. ==> Recherche de l'arete 5, commune aux faces F2 et F3
c
        do 231 , jaux = 1 , 4
          laux = arequa(lequad(nulofa(2)),jaux)
          do 2311 , kaux = 1, 4
            if ( laux.eq.arequa(lequad(nulofa(3)),kaux) ) then
              nuloar(2,4) = jaux
              nuloar(3,2) = kaux
              arehex(5) = laux
              goto 2312
            endif
 2311     continue
  231   continue
        codret = 231
        goto 5555
c
 2312   continue
c
c 2.3.2. ==> Recherche de l'arete 6, commune aux faces F4 et F2
c
        do 232 , jaux = 1 , 4
          laux = arequa(lequad(nulofa(4)),jaux)
          do 2321 , kaux = 1, 4
            if ( laux.eq.arequa(lequad(nulofa(2)),kaux) ) then
              nuloar(4,4) = jaux
              nuloar(2,2) = kaux
              arehex(6) = laux
              goto 2322
            endif
 2321     continue
  232   continue
        codret = 232
        goto 5555
c
 2322   continue
c
c 2.3.3. ==> Recherche de l'arete 7, commune aux faces F3 et F5
c
        do 233 , jaux = 1 , 4
          laux = arequa(lequad(nulofa(3)),jaux)
          do 2331 , kaux = 1, 4
            if ( laux.eq.arequa(lequad(nulofa(5)),kaux) ) then
              nuloar(3,4) = jaux
              nuloar(5,2) = kaux
              arehex(7) = laux
              goto 2332
            endif
 2331     continue
  233   continue
        codret = 233
        goto 5555
c
 2332   continue
c
c 2.3.4. ==> Recherche de l'arete 8, commune aux faces F5 et F4
c
        do 234 , jaux = 1 , 4
          laux = arequa(lequad(nulofa(5)),jaux)
          do 2341 , kaux = 1, 4
            if ( laux.eq.arequa(lequad(nulofa(4)),kaux) ) then
              nuloar(5,4) = jaux
              nuloar(4,2) = kaux
              arehex(8) = laux
              goto 2342
            endif
 2341     continue
  234   continue
        codret = 234
        goto 5555
c
 2342   continue
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90002) 'aretes de hex 5-8',(arehex(jaux),jaux=5,8)
            endif
#endif
c
c 2.4. ==> Recherche des aretes 9, 10, 11, 12
c
        nuloar(2,3) = fp1234(nuloar(2,1),nuloar(2,2),nuloar(2,4))
        arehex(9) = arequa(lequad(nulofa(2)),nuloar(2,3))
c
        nuloar(3,3) = fp1234(nuloar(3,1),nuloar(3,2),nuloar(3,4))
        arehex(10) = arequa(lequad(nulofa(3)),nuloar(3,3))
c
        nuloar(4,3) = fp1234(nuloar(4,1),nuloar(4,2),nuloar(4,4))
        arehex(11) = arequa(lequad(nulofa(4)),nuloar(4,3))
c
        nuloar(5,3) = fp1234(nuloar(5,1),nuloar(5,2),nuloar(5,4))
        arehex(12) = arequa(lequad(nulofa(5)),nuloar(5,3))
#ifdef _DEBUG_HOMARD_
          if ( indhex.lt.0 ) then
      write (ulsort,90002) 'aretes de hex 9-12',(arehex(jaux),jaux=9,12)
            endif
#endif
c
c 2.5.==> Mise en place de la face 2
c
        quahex(indhex,2) = lequad(nulofa(2))
c
        do 25 , jaux = 1 , 8
          if ( j1(jaux).eq.nuloar(2,1) .and.
     >         j2(jaux).eq.nuloar(2,2) .and.
     >         j3(jaux).eq.nuloar(2,3) .and.
     >         j4(jaux).eq.nuloar(2,4) ) then
            coquhe(indhex,2) = jaux
            goto 2511
          endif
   25   continue
        codret = 25
        goto 5555
 2511   continue
c
c 2.6.==> Mise en place de la face 3
c
        quahex(indhex,3) = lequad(nulofa(3))
c
        do 26 , jaux = 1 , 8
          if ( j1(jaux).eq.nuloar(3,1) .and.
     >         j2(jaux).eq.nuloar(3,2) .and.
     >         j3(jaux).eq.nuloar(3,3) .and.
     >         j4(jaux).eq.nuloar(3,4) ) then
            coquhe(indhex,3) = jaux
            goto 2611
          endif
   26   continue
        codret = 26
        goto 5555
 2611   continue
c
c 2.7.==> Mise en place de la face 4
c
        quahex(indhex,4) = lequad(nulofa(4))
c
        do 27 , jaux = 1 , 8
          if ( j1(jaux).eq.nuloar(4,1) .and.
     >         j2(jaux).eq.nuloar(4,2) .and.
     >         j3(jaux).eq.nuloar(4,3) .and.
     >         j4(jaux).eq.nuloar(4,4) ) then
            coquhe(indhex,4) = jaux
            goto 2711
          endif
   27   continue
        codret = 27
        goto 5555
 2711   continue
c
c 2.8.==> Mise en place de la face 5
c
        quahex(indhex,5) = lequad(nulofa(5))
c
        do 28 , jaux = 1 , 8
          if ( j1(jaux).eq.nuloar(5,1) .and.
     >         j2(jaux).eq.nuloar(5,2) .and.
     >         j3(jaux).eq.nuloar(5,3) .and.
     >         j4(jaux).eq.nuloar(5,4) ) then
            coquhe(indhex,5) = jaux
            goto 2811
          endif
   28   continue
        codret = 28
        goto 5555
 2811   continue
c
c 2.9.==> Mise en place de la face 6 : le dernier des quadrangles
c
        nulofa(6) = fp1aa6(        1, nulofa(2), nulofa(3),
     >                     nulofa(4), nulofa(5))
c
        do 291 , jaux = 1 , 4
          if ( arequa(lequad(nulofa(6)),jaux).eq.arehex(9) ) then
            nuloar(6,1) = jaux
          elseif ( arequa(lequad(nulofa(6)),jaux).eq.arehex(11) ) then
            nuloar(6,2) = jaux
          elseif ( arequa(lequad(nulofa(6)),jaux).eq.arehex(12) ) then
            nuloar(6,3) = jaux
          elseif ( arequa(lequad(nulofa(6)),jaux).eq.arehex(10) ) then
            nuloar(6,4) = jaux
          else
            codret = 291
            goto 5555
          endif
  291   continue
c
        quahex(indhex,6) = lequad(nulofa(6))
c
        do 292 , jaux = 1 , 8
          if ( j1(jaux).eq.nuloar(6,1) .and.
     >         j2(jaux).eq.nuloar(6,2) .and.
     >         j3(jaux).eq.nuloar(6,3) .and.
     >         j4(jaux).eq.nuloar(6,4) ) then
            coquhe(indhex,6) = jaux
            goto 2921
          endif
  292   continue
        codret = 292
        goto 5555
 2921   continue
c
c 2.10.==> Caracteristiques
c          iaux est le numero du joint ponctuel.
c          On decale pour tenir compte des familles HOMARD precedentes
c
        famhex(indhex) = nbfhe0 + iaux
c
        hethex(indhex)  = 0
        filhex(indhex)  = 0
        perhex(indhex)  = 0
c
#ifdef _DEBUG_HOMARD_
        if ( indhex.eq.-1 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,7), indhex, 0
      write (ulsort,90002)'faces ',(quahex(indhex,jaux),jaux=1,6)
      write (ulsort,90002)'coquhe',(coquhe(indhex,jaux),jaux=1,6)
      write (ulsort,90002)'aretes 1-4 ',(arehex(jaux),jaux=1,4)
      write (ulsort,90002)'aretes 5-8 ',(arehex(jaux),jaux=5,8)
      write (ulsort,90002)'aretes 9-12',(arehex(jaux),jaux=9,12)
        endif
#endif
c
    2 continue
c
c====
c 5. la fin
c====
c
 5555 continue
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
