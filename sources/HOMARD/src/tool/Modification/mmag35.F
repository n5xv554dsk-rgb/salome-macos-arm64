      subroutine mmag35 ( indpen, nbfpe0,
     >                    nbpe09,
     >                    tbau52,
     >                    aretri, arequa,
     >                    facpen, cofape,
     >                    hetpen, filpen, perpen,
     >                    fampen,
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
c    Modification de Maillage - AGRegat - phase 3.5
c    -               -          --              - -
c    Creation des mailles pour les joints ponctuels :
c    . pentaedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indpen . es  .   1    . indice du dernier pentaedre cree           .
c . nbfpe0 . e   .   1    . nombre de familles de pentaedres creees    .
c . nbpe09 . e   .   1    . nombre de pent. des j. ponctuels d'ordre 9 .
c . tbau52 . e   .  11*   . Les pentaedres ponctuels entre les joints  .
c .        .     . nbpe09 . triples et quadruples :                    .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : triangle cote du 1er joint triple  .
c .        .     .        . (3,i) : triangle cote du 2eme joint triple .
c .        .     .        . (4,i) : quadrangle cote du 1er joint quad. .
c .        .     .        . (5,i) : quadrangle cote du 2eme joint quad..
c .        .     .        . (6,i) : quadrangle cote du 3eme joint quad..
c .        .     .        . (1+k) : pour la k-eme face, 1 si elle      .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . facpen . es  .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . es  .nbpecf*5. codes des faces des pentaedres             .
c . hetpen . es  . nbpeto . historique de l'etat des pentaedres        .
c . filpen . es  . nbpeto . premier fils des pentaedres                .
c . perpen . es  . nbpeto . pere des pentaedres                        .
c . fampen . es  . nbpeto . famille des pentaedres                     .
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
      parameter ( nompro = 'MMAG35' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombtr.h"
#include "nombqu.h"
#include "nombpe.h"
#include "impr02.h"
#include "i1i2i3.h"
#include "j1234j.h"
#include "op1234.h"
c
c 0.3. ==> arguments
c
      integer indpen, nbfpe0
      integer nbpe09
      integer tbau52(11,nbpe09)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5)
      integer hetpen(nbpeto), filpen(nbpeto), perpen(nbpeto)
      integer fampen(nbpeto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
c
      integer nulofa(5), nuloar(5,4), orient(5)
      integer arepen(9), letria(2), lequad(3)
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
     >       mess14(langue,3,7)//'d''ordre 9', nbpe09
#endif
c
      codret = 0
c
cgn      write(ulsort,90002) 'nbnoto, nbarto, nbtrto',nbnoto, nbarto,nbtrto
cgn      write(ulsort,90002) 'nbpe09',nbpe09
cgn      do 1102 , kaux = 1,nbpe09
cgn       write(ulsort,90001) 'penta',kaux,(tbau52(jaux,kaux),jaux=1,6)
cgn 1102  continue
c
c====
c 2. Parcours des pentaedres de joint ponctuel d'ordre 9
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,7)
#endif
c
c Sur ce croquis, semblable a la documentation sur les structures de
c donnees, la droite S2-S5 est a l'arriere-plan.
c
c           S3                 arepen(9)               S6
c           x------------------------------------------x
c          .                                          .
c         .  .                                       .  .
c     arepen(3)                                  arepen(6)
c       .     .                                    .     .
c      .                                          .
c     .        .arepen(1)                        .        . arepen(4)
c    .                                          .
c S2.           .             arepen(8)         S5.        .
c  x - - - - - - - - - - - - - - - - - - - - -x
c      .                                         .          .
c          .                                         .
c        arepen(2)                              arepen(5).   .
c                  x-----------------------------------------x
c                  S1                 arepen(7)              S4
c   La face f1 est le triangle (S1,S2,S3).
c   La face f2 est le triangle (S4,S6,S5).
c   L'arete a1 est relie les sommets S1 et S3.
c   Les aretes (a1,a2,a3) realisent une rotation entrante dans le
c   pentaedre. L'arete ai+3 est parallele a l'arete ai.
c   La face fi, 3<=i<=5, est le quadrangle s'appuyant sur l'arete ai-2.
c
c voir utarpe pour le croquis ci-dessus
c
      do 2 , iaux = 1 , nbpe09
c
        indpen = indpen + 1
c
c 2.1 ==> Recuperation des triangles et quadrangles
c
        do 211 , jaux = 1 , 2
          letria(jaux) = tbau52(jaux+1,iaux)
          orient(jaux) = tbau52(jaux+6,iaux)
cgn      write (ulsort,90015) 'triangle', letria(jaux),
cgn     >                     ', d''orientation', orient(jaux)
cgn      write (ulsort,90002) 'aretes ',
cgn     > (aretri(letria(jaux),kaux),kaux=1,3)
  211   continue
c
        do 212 , jaux = 3, 5
          lequad(jaux-2) = tbau52(jaux+1,iaux)
          orient(jaux) = tbau52(jaux+6,iaux)
cgn      write (ulsort,90015) 'quadrangle', lequad(jaux-2),
cgn     >                     ', d''orientation', orient(jaux)
cgn      write (ulsort,90002) 'aretes ',
cgn     > (arequa(lequad(jaux-2),kaux),kaux=1,4)
  212   continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,texte(langue,4)) ' ',
     >                     mess14(langue,1,1), tbau52(1,iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,16)) mess14(langue,1,7), indpen, 0
#endif
c
c 2.2 ==> Positionnement des triangles et quadrangles en tant que face
c         nulofa(i) = numero local du triangle (quadrangle) dans letria
c                     (lequad) qui correspond a la face Fi
c         nuloar(i,j) = pour la face Fi, numero local de sa i-eme arete
c                       dans la description de la face
c 2.2.1. ==>  La face F1 est le 1er triangle enregistre.
c   On impose :
c     la 1ere arete du pentaedre est la 1ere arete du triangle ;
c   --> le code sera donc 1 ou 4.
c   Si l'orientation est positive, le triangle entre dans le pentaedre.
c   On lui donnera donc le code 1.
C   Inversement, si l'orientation est negative, il va sortir
c   du pentaedre. On lui donnera alors le code 4.
c
        facpen(indpen,1) = letria(1)
        cofape(indpen,1) = 1
        if ( orient(1).gt.0 ) then
          cofape(indpen,1) = 1
        else
          cofape(indpen,1) = 4
        endif
c
c     Reperage des aretes de cette face
c
        arepen(1) = aretri(letria(1),1)
        if ( orient(1).gt.0 ) then
          arepen(2) = aretri(letria(1),2)
          arepen(3) = aretri(letria(1),3)
        else
          arepen(2) = aretri(letria(1),3)
          arepen(3) = aretri(letria(1),2)
        endif
#ifdef _DEBUG_HOMARD_
          if ( indpen.lt.0 ) then
      write (ulsort,90015) 'triangle pour F1', letria(1),
     >                     ', d''orientation', orient(1)
      write (ulsort,90002) 'aretes de pen 1-3',(arepen(jaux),jaux=1,3)
        endif
#endif
c
c 2.2.2. ==> La face F3 est le quadrangle qui contient l'arete 1
c            C'est son arete numero 1
c
#ifdef _DEBUG_HOMARD_
          if ( indpen.lt.0 ) then
      write (ulsort,90002) 'F3 bati sur arete 1',arepen(1)
        endif
#endif
c
        do 222 , jaux = 1 , 3
         if ( arepen(1).eq.arequa(lequad(jaux),1) ) then
            nulofa(3) = jaux
            nuloar(3,1) = 1
            goto 2221
          elseif ( arepen(1).eq.arequa(lequad(jaux),2) ) then
            nulofa(3) = jaux
            nuloar(3,1) = 2
            goto 2221
          elseif ( arepen(1).eq.arequa(lequad(jaux),3) ) then
            nulofa(3) = jaux
            nuloar(3,1) = 3
            goto 2221
          elseif ( arepen(1).eq.arequa(lequad(jaux),4) ) then
            nulofa(3) = jaux
            nuloar(3,1) = 4
            goto 2221
          endif
  222   continue
        codret = 222
        goto 3333
c
 2221   continue
#ifdef _DEBUG_HOMARD_
          if ( indpen.lt.0 ) then
      write (ulsort,90002) 'quadrangle pour F3', lequad(nulofa(3)),
     >                     ', d''orientation', orient(nulofa(3))
      write (ulsort,90002) 'aretes',
     >                     (arequa(lequad(nulofa(3)),jaux),jaux=1,4)
            endif
#endif
c
c 2.2.3. ==> La face F4 est le quadrangle qui contient l'arete 2
c            C'est son arete numero 1
c
#ifdef _DEBUG_HOMARD_
          if ( indpen.lt.0 ) then
      write (ulsort,90002) 'F4 bati sur arete 2',arepen(2)
        endif
#endif
c
        do 223 , jaux = 1, 3
          if ( arepen(2).eq.arequa(lequad(jaux),1) ) then
            nulofa(4) = jaux
            nuloar(4,1) = 1
            goto 2231
          elseif ( arepen(2).eq.arequa(lequad(jaux),2) ) then
            nulofa(4) = jaux
            nuloar(4,1) = 2
            goto 2231
          elseif ( arepen(2).eq.arequa(lequad(jaux),3) ) then
            nulofa(4) = jaux
            nuloar(4,1) = 3
            goto 2231
          elseif ( arepen(2).eq.arequa(lequad(jaux),4) ) then
            nulofa(4) = jaux
            nuloar(4,1) = 4
            goto 2231
          endif
  223   continue
        codret = 223
        goto 3333
c
 2231   continue
#ifdef _DEBUG_HOMARD_
          if ( indpen.lt.0 ) then
      write (ulsort,90002) 'quadrangle pour F4', lequad(nulofa(4))
      write (ulsort,90002) 'aretes',
     >                     (arequa(lequad(nulofa(4)),jaux),jaux=1,4)
            endif
#endif
c
c 2.2.4. ==> La face F5 est le quadrangle qui contient l'arete 3
c            C'est son arete numero 1
c
#ifdef _DEBUG_HOMARD_
          if ( indpen.lt.0 ) then
      write (ulsort,90002) 'F5 bati sur arete 3',arepen(3)
        endif
#endif
c
        do 224 , jaux = 1, 3
          if ( arepen(3).eq.arequa(lequad(jaux),1) ) then
            nulofa(5) = jaux
            nuloar(5,1) = 1
            goto 2241
          elseif ( arepen(3).eq.arequa(lequad(jaux),2) ) then
            nulofa(5) = jaux
            nuloar(5,1) = 2
            goto 2241
          elseif ( arepen(3).eq.arequa(lequad(jaux),3) ) then
            nulofa(5) = jaux
            nuloar(5,1) = 3
            goto 2241
          elseif ( arepen(3).eq.arequa(lequad(jaux),4) ) then
            nulofa(5) = jaux
            nuloar(5,1) = 4
            goto 2241
          endif
  224   continue
        codret = 224
        goto 3333
c
 2241   continue
#ifdef _DEBUG_HOMARD_
          if ( indpen.lt.0 ) then
      write (ulsort,90002) 'quadrangle pour F5', lequad(nulofa(5))
      write (ulsort,90002) 'aretes',
     >                     (arequa(lequad(nulofa(5)),jaux),jaux=1,4)
            endif
#endif
c
c 2.3. ==> Recherche des aretes 7, 8 et 9
c 2.3.1. ==> Recherche de l'arete 7, commune aux faces F3 et F4
c
        do 231 , jaux = 1 , 4
          laux = arequa(lequad(nulofa(3)),jaux)
          do 2311 , kaux = 1, 4
            if ( laux.eq.arequa(lequad(nulofa(4)),kaux) ) then
              nuloar(3,4) = jaux
              nuloar(4,2) = kaux
              arepen(7) = laux
              goto 2312
            endif
 2311     continue
  231   continue
        codret = 231
        goto 3333
c
 2312   continue
c
c 2.3.2. ==> Recherche de l'arete 8, commune aux faces F4 et F5
c
        do 232 , jaux = 1 , 4
          laux = arequa(lequad(nulofa(4)),jaux)
          do 2321 , kaux = 1, 4
            if ( laux.eq.arequa(lequad(nulofa(5)),kaux) ) then
              nuloar(4,4) = jaux
              nuloar(5,2) = kaux
              arepen(8) = laux
              goto 2322
            endif
 2321     continue
  232   continue
        codret = 232
        goto 3333
c
 2322   continue
c
c 2.3.3. ==> Recherche de l'arete 9, commune aux faces F5 et F3
c
        do 233 , jaux = 1 , 4
          laux = arequa(lequad(nulofa(5)),jaux)
          do 2331 , kaux = 1, 4
            if ( laux.eq.arequa(lequad(nulofa(3)),kaux) ) then
              nuloar(5,4) = jaux
              nuloar(3,2) = kaux
              arepen(9) = laux
              goto 2332
            endif
 2331     continue
  233   continue
        codret = 233
        goto 3333
c
 2332   continue
c
c 2.4. ==> Recherche des aretes 4, 5 et 6
c
        nuloar(3,3) = fp1234(nuloar(3,1),nuloar(3,2),nuloar(3,4))
        arepen(4) = arequa(lequad(nulofa(3)),nuloar(3,3))
c
        nuloar(4,3) = fp1234(nuloar(4,1),nuloar(4,2),nuloar(4,4))
        arepen(5) = arequa(lequad(nulofa(4)),nuloar(4,3))
c
        nuloar(5,3) = fp1234(nuloar(5,1),nuloar(5,2),nuloar(5,4))
        arepen(6) = arequa(lequad(nulofa(5)),nuloar(5,3))
#ifdef _DEBUG_HOMARD_
          if ( indpen.lt.0 ) then
      write (ulsort,90002) 'aretes de pen 1-3',(arepen(jaux),jaux=1,3)
      write (ulsort,90002) 'aretes de pen 3-6',(arepen(jaux),jaux=4,6)
      write (ulsort,90002) 'aretes de pen 7-9',(arepen(jaux),jaux=7,9)
            endif
#endif
c
        do 24 , jaux = 1 , 3
          if ( aretri(letria(2),jaux).eq.arepen(4) ) then
            nuloar(2,1) = jaux
          elseif ( aretri(letria(2),jaux).eq.arepen(6) ) then
            nuloar(2,2) = jaux
          elseif ( aretri(letria(2),jaux).eq.arepen(5) ) then
            nuloar(2,3) = jaux
          else
            codret = 24
            goto 3333
          endif
   24   continue
c
c 2.5.==> Mise en place de la face 2
c
        facpen(indpen,2) = letria(2)
c
        do 25 , jaux = 1 , 6
          if ( i1(jaux).eq.nuloar(2,1) .and.
     >         i2(jaux).eq.nuloar(2,2) .and.
     >         i3(jaux).eq.nuloar(2,3) ) then
            cofape(indpen,2) = jaux
            goto 2511
          endif
   25   continue
        codret = 25
        goto 3333
c
 2511   continue
#ifdef _DEBUG_HOMARD_
          if ( indpen.lt.0 ) then
      write (ulsort,90002) 'quadrangle pour F5', lequad(nulofa(5))
      write (ulsort,90002) 'aretes',
     >                     (arequa(lequad(nulofa(3)),jaux),jaux=1,4)
            endif
#endif
c
c 2.6.==> Mise en place de la face 3
c
        facpen(indpen,3) = lequad(nulofa(3))
c
        do 26 , jaux = 1 , 8
          if ( j1(jaux).eq.nuloar(3,1) .and.
     >         j2(jaux).eq.nuloar(3,2) .and.
     >         j3(jaux).eq.nuloar(3,3) .and.
     >         j4(jaux).eq.nuloar(3,4) ) then
            cofape(indpen,3) = jaux
            goto 2611
          endif
   26   continue
        codret = 26
        goto 3333
c
 2611   continue
c
c 2.7.==> Mise en place de la face 4
c
        facpen(indpen,4) = lequad(nulofa(4))
c
        do 27 , jaux = 1 , 8
          if ( j1(jaux).eq.nuloar(4,1) .and.
     >         j2(jaux).eq.nuloar(4,2) .and.
     >         j3(jaux).eq.nuloar(4,3) .and.
     >         j4(jaux).eq.nuloar(4,4) ) then
            cofape(indpen,4) = jaux
            goto 2711
          endif
   27   continue
        codret = 27
        goto 3333
c
 2711   continue
c
c 2.8.==> Mise en place de la face 5
c
        facpen(indpen,5) = lequad(nulofa(5))
c
        do 28 , jaux = 1 , 8
          if ( j1(jaux).eq.nuloar(5,1) .and.
     >         j2(jaux).eq.nuloar(5,2) .and.
     >         j3(jaux).eq.nuloar(5,3) .and.
     >         j4(jaux).eq.nuloar(5,4) ) then
            cofape(indpen,5) = jaux
            goto 2811
          endif
   28   continue
        codret = 28
        goto 3333
c
 2811   continue
c
c 2.9.==> Caracteristiques
c         iaux est le numero du joint ponctuel.
c         On decale pour tenir compte des familles HOMARD precedentes
c
        fampen(indpen) = nbfpe0 + iaux
c
        hetpen(indpen)  = 0
        filpen(indpen)  = 0
        perpen(indpen)  = 0
c
#ifdef _DEBUG_HOMARD_
        if ( indpen.lt.0 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,7), indpen, 0
      write (ulsort,90002)'faces ',(facpen(indpen,jaux),jaux=1,5)
      write (ulsort,90002)'cofape',(cofape(indpen,jaux),jaux=1,5)
      write (ulsort,90002) 'aretes 1-3',(arepen(jaux),jaux=1,3)
      write (ulsort,90002) 'aretes 3-6',(arepen(jaux),jaux=4,6)
      write (ulsort,90002) 'aretes 7-9',(arepen(jaux),jaux=7,9)
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
