      subroutine utb07a ( hetare,
     >                    hettri, nivtri, pertri,
     >                    voltri,
     >                    hetqua, nivqua,
     >                    volqua,
     >                    hettet, tritet, pertet, pthepe,
     >                    hethex, quahex, perhex,
     >                    hetpyr, facpyr, perpyr, pphepe,
     >                    hetpen, facpen, perpen,
     >                    posifa, facare,
     >                    famnoe, cfanoe,
     >                    fammpo, cfampo,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
     >                    famtet, cfatet,
     >                    famhex, cfahex,
     >                    fampyr, cfapyr,
     >                    fampen, cfapen,
     >                    tabaui,
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
c    UTilitaire - Bilan sur le maillage - option 07
c    --           -                              --
c ______________________________________________________________________
c
c    Nombre de mailles du calcul qui sont actives.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . pertri . e   . nbtrto . pere des triangles                         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . pertet . e   . nbteto . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . pthepe . e   .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . perhex . e   . nbheto . pere des hexaedres                         .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . perpyr . e   . nbpyto . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . pphepe . e   .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . perpen . e   . nbpeto . pere des pentaedres                        .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . cfanoe . e   . nctfno*. codes des familles des noeuds              .
c .        .     . nbnoto .   1 : famille MED                          .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famnoe . e   . nbnoto . famille des aretes                         .
c . cfampo . e   . nctfmp*. codes des familles des mailles-points      .
c .        .     . nbfmpo .   1 : famille MED                          .
c .        .     .        .   2 : type de maille-point                 .
c .        .     .        .   3 : famille des sommets                  .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . fammpo . e   . nbmpto . famille des mailles-points                 .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famtet . e   . nbteto . famille des tetraedres                     .
c . cfatet .     . nctfte. codes des familles des tetraedres          .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famhex . e   . nbheto . famille des hexaedres                      .
c . cfahex .     . nctfhe. codes des familles des hexaedres            .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . fampyr . e   . nbpyto . famille des pyramides                      .
c . cfapyr .     . nctfpy. codes des familles des pyramides            .
c .        .     . nbfpyr .   1 : famille MED                          .
c .        .     .        .   2 : type de pyramides                    .
c . fampen . e   . nbpeto . famille des pentaedres                     .
c . cfapen .     . nctfpe. codes des familles des pentaedres           .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . tabaui .  a  .-nivsu-1. tableau de travail                         .
c .        .     .:nivsu+1.                                            .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
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
      parameter ( nompro = 'UTB07A' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nbfami.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "envada.h"
#include "envca1.h"
c
#include "dicfen.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer hetare(nbarto)
      integer hettri(nbtrto), nivtri(nbtrto), pertri(nbtrto)
      integer voltri(2,nbtrto)
      integer hetqua(nbquto), nivqua(nbquto)
      integer volqua(2,nbquto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettet(nbteto), tritet(nbtecf,4)
      integer pertet(nbteto), pthepe(*)
      integer hethex(nbheto), quahex(nbhecf,6)
      integer perhex(nbheto)
      integer hetpyr(nbpyto), facpyr(nbpycf,5)
      integer perpyr(nbpyto), pphepe(*)
      integer hetpen(nbpeto), facpen(nbpecf,5)
      integer perpen(nbpeto)
c
      integer famnoe(nbnoto), cfanoe(nctfno,nbfnoe)
      integer fammpo(nbmpto), cfampo(nctfmp,nbfmpo)
      integer famare(nbarto), cfaare(nctfar,nbfare)
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
      integer famqua(nbquto), cfaqua(nctfqu,nbfqua)
      integer famtet(nbteto), cfatet(nctfte,nbftet)
      integer famhex(nbheto), cfahex(nctfhe,nbfhex)
      integer fampyr(nbpyto), cfapyr(nctfpy,nbfpyr)
      integer fampen(nbpeto), cfapen(nctfpe,nbfpen)
c
      integer tabaui(-nivsup-1:nivsup+1)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, ideb, ifin
      integer lenoeu, lamapo, larete, letria, lequad, letetr
      integer lehexa, lapyra, lepent
      integer etat
      integer nbmapo
      integer nbaret, nbarbt, nbarit
      integer nbfabt, nbfavt
      integer nbvolu
      integer pos, fac1, fac2, vois1, vois2
      integer nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
c
      double precision niveau
c
      logical arbord
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
      character*54 mess54(nblang,nbmess)
      character*43 saux43
      character*43 mess43(nblang,100)
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
      texte(1,4) =
     > '(//,3x,''NOMBRE D''''ENTITES DU CALCUL'',/,3x,26(''=''),/)'
c
      texte(2,4) =
     > '(//,3x,''NUMBER OF CALCULATION ENTITIES'',/,3x,30(''=''),/)'
cgn      ulbila = ulsort
c
      write (ulbila,texte(langue,4))
c
      mess54(1,1) =
     > '   Le maillage presente des homologues.               '
c
      mess43(1,1) = 'Nombre total                               '
      mess43(1,3) = '. dont sommets d''aretes                    '
      mess43(1,4) = '. dont milieux d''aretes                    '
      mess43(1,5) = '. dont noeuds internes aux mailles         '
      mess43(1,6) = '. dont noeuds isoles                       '
      mess43(1,7) = '. dont noeuds uniquement mailles ignorees  '
      mess43(1,8) = '. dont noeuds uniquement mailles-points    '
c
      mess43(1,10) = '. dont aretes isolees                      '
      mess43(1,11) = '. dont aretes de bord de regions 2D        '
      mess43(1,12) = '. dont aretes internes aux faces/volumes   '
c
      mess43(1,20) = '. dont triangles de regions 2D             '
      mess43(1,21) = '. dont triangles de bord                   '
      mess43(1,22) = '. dont triangles internes aux volumes      '
c
      mess43(1,30) = '. dont quadrangles de regions 2D           '
      mess43(1,31) = '. dont quadrangles de bord                 '
      mess43(1,32) = '. dont quadrangles internes aux volumes    '
c
      mess43(1,60) = 'Paires de                                  '
c                     1234567890123456789012345678901234567890123
c
      mess54(2,1) =
     > '   The mesh implies homologous condition.             '
c
      mess43(2,1) = 'Total number                               '
      mess43(2,3) = '. included vertices of edges               '
      mess43(2,4) = '. included centers of edges                '
      mess43(2,5) = '. included internal nodes                  '
      mess43(2,6) = '. included isolated nodes                  '
      mess43(2,7) = '. included only ignored meshes nodes       '
      mess43(2,8) = '. included only mesh-point nodes           '
c
      mess43(2,10) = '. included isolated edges                  '
      mess43(2,11) = '. included boundaries of 2D areas          '
      mess43(2,12) = '. included internal in faces/volumes       '
c
      mess43(2,20) = '. included triangles of 2D areas           '
      mess43(2,21) = '. included boundary triangles              '
      mess43(2,22) = '. included internal triangles              '
c
      mess43(2,30) = '. included quadrangles of 2D areas         '
      mess43(2,31) = '. included boundary quadrangles            '
      mess43(2,32) = '. included internal quadrangles            '
c
      mess43(2,60) = 'Pairs of                                   '
c                     1234567890123456789012345678901234567890123
c
10100 format(/,5x,60('*'))
10200 format(  5x,60('*'))
c
11100 format(  5x,'*  ',a54,'  *')
11200 format(  5x,'* ',21x,a14,21x,' *')
c
12200 format(  5x,'* ',a43,' * ', i10,' *')
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'lg de tabaui = nivsup', nivsup
#endif
c
c====
c 2. noeuds
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. nbnoto',nbnoto
#endif
c
      nbeqno = 0
      ideb = nctfno - ncefno + 1
      ifin = nctfno
c
      do 21 , lenoeu = 1, nbnoto
c
        do 211 , iaux = ideb , ifin
          if ( cfanoe(iaux,famnoe(lenoeu)).ne.0 ) then
             nbeqno = nbeqno + 1
          endif
  211   continue
c
   21 continue
c
      write (ulbila,10100)
      write (ulbila,11200) mess14(langue,4,-1)
      write (ulbila,10200)
      write (ulbila,12200) mess43(langue,1), nbnoto
      if ( degre.eq.2 .or.
     >     nbnois.ne.0 .or. nbnoei.ne.0 .or. nbnomp.ne.0 ) then
        write (ulbila,12200) mess43(langue,3), nbnop1
      endif
      if ( degre.eq.2 ) then
        write (ulbila,12200) mess43(langue,4), nbnop2
      endif
      if ( mod(mailet,2).eq.0 .or.
     >     mod(mailet,3).eq.0 .or.
     >     mod(mailet,5).eq.0 ) then
        write (ulbila,12200) mess43(langue,5), nbnoim
      endif
      if ( nbnois.ne.0 ) then
        write (ulbila,12200) mess43(langue,6), nbnois
      endif
      if ( nbnoei.ne.0 ) then
        write (ulbila,12200) mess43(langue,7), nbnoei
      endif
      if ( nbnomp.ne.0 ) then
        write (ulbila,12200) mess43(langue,8), nbnomp
      endif
      write (ulbila,10200)
c
c====
c 3. mailles-points
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. nbmpto',nbmpto
#endif
c
      if ( nbmpto.ne.0 ) then
c
        nbmapo = 0
        nbeqmp = 0
        ideb = nctfmp - ncefmp + 1
        ifin = nctfmp
c
        do 31 , lamapo = 1, nbmpto
c
          if ( cfampo(cotyel,fammpo(lamapo)).ne.0 ) then
c
          nbmapo = nbmapo + 1
c
          do 311 , iaux = ideb , ifin
            if ( cfampo(iaux,fammpo(lamapo)).ne.0 ) then
               nbeqmp = nbeqmp + 1
            endif
  311     continue
c
          endif
c
   31   continue
c
        if ( nbmapo.ne.0 ) then
c
          write (ulbila,10100)
          write (ulbila,11200) mess14(langue,4,0)
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,1), nbmapo
          write (ulbila,10200)
c
        endif
c
      endif
c
c====
c 4. aretes
c====
c    on rappelle que la caracteristique numero cotyel des aretes est
c    nulle si ce n'etait pas une maille du calcul.
c    si c'est une maille de calcul, la caracteristique vaut le type
c    correspondant a celui du code de calcul associe.
c
c on definit une arete de bord comme etant une arete ayant :
c   . une seule face voisine,
c   . deux faces voisines :
c     . deux triangles dont l'un est le pere de l'autre : cas du
c       decoupage de conformite provenant de l'arete de bord ; cela n'a
c       lieu qu'avec des homologues.
c     . un triangle et un quadrangle qui en est le pere des autres : cas
c       du decoupage non conforme d'un quadrangle de bord.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. nbarto',nbarto
#endif
c
      nbaret = 0
      nbarbt = 0
      nbarit = 0
      nbeqar = 0
      ideb = nctfar - ncefar + 1
      ifin = nctfar
c
      do 41 , larete = 1, nbarto
c
        if ( cfaare(cotyel,famare(larete)).ne.0 ) then
c
        etat = mod(hetare(larete) , 10 )
c
        if ( etat.eq.0 ) then
c
        nbaret = nbaret + 1
        arbord = .false.
c
        if ( posifa(larete-1)+2.eq.posifa(larete) ) then
          pos = posifa(larete)
          fac1 = facare(pos-1)
          fac2 = facare(pos)
          if ( fac1.gt.0 .and. fac2.gt.0 ) then
            vois1 = min(fac1,fac2)
            vois2 = max(fac1,fac2)
            if ( pertri(vois2).eq.vois1 ) then
              arbord = .true.
            endif
          elseif ( fac1.gt.0 .and. fac2.lt.0 ) then
            if ( pertri(fac1).eq.fac2 ) then
              arbord = .true.
            endif
          elseif ( fac1.lt.0 .and. fac2.gt.0 ) then
            if ( pertri(fac2).eq.fac1 ) then
              arbord = .true.
            endif
          endif
        elseif ( posifa(larete-1)+1.eq.posifa(larete) ) then
          arbord = .true.
        elseif ( posifa(larete-1)+1.gt.posifa(larete) ) then
          nbarit = nbarit +1
        endif
c
        if ( arbord ) then
          nbarbt = nbarbt +1
        endif
c
        do 411 , iaux = ideb , ifin
          if ( cfaare(iaux,famare(larete)).ne.0 ) then
             nbeqar = nbeqar + 1
          endif
  411   continue
c
        endif
c
        endif
c
   41 continue
c
      if ( nbaret.ne.0 ) then
c
        write (ulbila,10100)
        write (ulbila,11200) mess14(langue,4,1)
        write (ulbila,10200)
        write (ulbila,12200) mess43(langue,1), nbaret
        if ( nbtrto.ne.0 .or. nbquto.ne.0 ) then
          write (ulbila,12200) mess43(langue,10), nbarit
          write (ulbila,12200) mess43(langue,11), nbarbt
          write (ulbila,12200) mess43(langue,12), nbaret-nbarit-nbarbt
        endif
        write (ulbila,10200)
c
      endif
c
c====
c 5. triangles
c====
c    on rappelle que la caracteristique numero 2 des faces est nulle si
c    ce n'etait pas une maille du calcul.
c    si c'est une maille de calcul, la caracteristique vaut le type
c    correspondant a celui du code de calcul associe.
c    Un triangle de bord est un triangle ayant un et un seul
c    volume voisin.
c    Le stockage etant different de la dimension deux, le tableau
c    voltri ne garde que le volume fils.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. nbtrto',nbtrto
#endif
c
      if ( nbtrto.ne.0 ) then
c
        do 51 , iaux = -nivsup-1, nivsup+1
          tabaui(iaux) = 0
   51   continue
c
        nbvolu = nbteto + nbpyto + nbpeto
        jaux = 0
        nbfabt = 0
        nbfavt = 0
        nbeqtr = 0
        ideb = nctftr - nceftr + 1
        ifin = nctftr
c
        do 52 , letria = 1, nbtrto
c
          if ( cfatri(cotyel,famtri(letria)).ne.0 ) then
c
            etat = mod(hettri(letria) , 10 )
c
            if ( etat.eq.0 ) then
c
            jaux = jaux + 1
            iaux = nivtri(letria)
            if ( letria.gt.nbtrpe ) then
              iaux = -iaux
            endif
            tabaui(iaux) = tabaui(iaux) + 1
c
            if ( nbvolu.ne.0 ) then
c
              if ( voltri(1,letria).ne.0 ) then
                if ( voltri(2,letria).eq.0 ) then
                  nbfabt = nbfabt + 1
                else
                  nbfavt = nbfavt + 1
                endif
              endif
c
            endif
c
            do 521 , iaux = ideb , ifin
              if ( cfatri(iaux,famtri(letria)).ne.0 ) then
                 nbeqtr = nbeqtr + 1
              endif
  521       continue
c
            endif
c
          endif
c
   52   continue
c
        if ( jaux.ne.0 ) then
c
          write (ulbila,10100)
          write (ulbila,11200) mess14(langue,4,2)
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,1), jaux
          if ( nbvolu.ne.0 ) then
            write (ulbila,12200) mess43(langue,20), jaux-nbfabt-nbfavt
            write (ulbila,12200) mess43(langue,21), nbfabt
            write (ulbila,12200) mess43(langue,22), nbfavt
          endif
c
          if ( nbiter.ge.1 ) then
            call utb07b ( tabaui, ulbila,
     >                    ulsort, langue, codret )
          endif
c
          write (ulbila,10200)
c
        endif
c
      endif
c
c====
c 6. quadrangles
c====
c    on rappelle que la caracteristique numero 2 des faces est nulle si
c    ce n'etait pas une maille du calcul.
c    si c'est une maille de calcul, la caracteristique vaut le type
c    correspondant a celui du code de calcul associe.
c    Un quadrangle de bord est un quadrangle ayant un et un seul
c    volume voisin.
c    Le stockage etant different de la dimension deux, le tableau
c    volqua ne garde que le volume fils.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. nbquto',nbquto
#endif
c
      if ( nbquto.ne.0 ) then
c
        do 61 , iaux = -nivsup-1, nivsup+1
          tabaui(iaux) = 0
   61   continue
c
        nbvolu = nbheto + nbpyto + nbpeto
        jaux = 0
        nbfabt = 0
        nbfavt = 0
        nbeqqu = 0
        ideb = nctfqu - ncefqu + 1
        ifin = nctfqu
c
        do 62 , lequad = 1, nbquto
c
          if ( cfaqua(cotyel,famqua(lequad)).ne.0 ) then
c
            etat = mod(hetqua(lequad),100)
c
            if ( etat.eq.0 ) then
c
            jaux = jaux + 1
            iaux = nivqua(lequad)
            if ( lequad.gt.nbqupe ) then
              iaux = -iaux
            endif
            tabaui(iaux) = tabaui(iaux) + 1
c
            if ( nbvolu.ne.0 ) then
c
              if ( volqua(1,lequad).ne.0 ) then
                if ( volqua(2,lequad).eq.0 ) then
                  nbfabt = nbfabt + 1
                else
                  nbfavt = nbfavt + 1
                endif
              endif
c
            endif
c
            do 621 , iaux = ideb , ifin
              if ( cfaqua(iaux,famqua(lequad)).ne.0 ) then
                 nbeqqu = nbeqqu + 1
              endif
  621       continue
c
            endif
c
          endif
c
   62   continue
c
        if ( jaux.ne.0 ) then
c
          write (ulbila,10100)
          write (ulbila,11200) mess14(langue,4,4)
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,1), jaux
          if ( nbvolu.ne.0 ) then
            write (ulbila,12200) mess43(langue,30), jaux-nbfabt-nbfavt
            write (ulbila,12200) mess43(langue,31), nbfabt
            write (ulbila,12200) mess43(langue,32), nbfavt
          endif
c
          if ( nbiter.ge.1 ) then
            call utb07b ( tabaui, ulbila,
     >                    ulsort, langue, codret )
          endif
c
          write (ulbila,10200)
c
        endif
c
      endif
c
c====
c 7. tetraedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. nbteto, nbtepe, nbtecf, nbteca',
     >                     nbteto, nbtepe, nbtecf, nbteca
#endif
c
      if ( nbteto.ne.0 ) then
c
        do 70 , iaux = -nivsup-1, nivsup+1
          tabaui(iaux) = 0
   70   continue
c
        jaux = 0
c
c 7.1. ==> Les tetraedres de depart ou issus d'un decoupage en 8
c          Les faces sont toutes du meme niveau
c          Remarque : ils sont toujours decrits par faces
c
        do 71 , letetr = 1, nbtepe
c
          if ( cfatet(cotyel,famtet(letetr)).ne.0 ) then
c
          etat = mod(hettet(letetr),100)
c
          if ( etat.eq.0 ) then
c
          jaux = jaux + 1
          iaux = nivtri(tritet(letetr,1))
          tabaui(iaux) = tabaui(iaux) + 1
c
          endif
c
          endif
c
   71   continue
cgn      write (ulsort,90002) 'jaux', jaux
c
c 7.2. ==> Les tetraedres issus d'un decoupage de conformite
c          Remarque : ils sont toujours actifs
c
        do 72 , letetr = nbtepe+1 , nbteto
c
          call utntet ( letetr, niveau,
     >                  tritet, pertet, pthepe,
     >                  nivtri, nivqua,
     >                  quahex, facpen )
c
          jaux = jaux + 1
          iaux = -int(niveau) - 1
          tabaui(iaux) = tabaui(iaux) + 1
c
   72   continue
cgn      write (ulsort,90002) 'jaux', jaux
c
        if ( jaux.ne.0 ) then
c
          write (ulbila,10100)
          write (ulbila,11200) mess14(langue,4,3)
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,1), jaux
c
          if ( nbiter.ge.1 ) then
            call utb07b ( tabaui, ulbila,
     >                    ulsort, langue, codret )
          endif
c
          write (ulbila,10200)
c
        endif
c
      endif
c
c====
c 8. hexaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. nbheto, nbhecf',nbheto, nbhecf
#endif
c
      if ( nbheto.ne.0 ) then
c
        do 80 , iaux = -nivsup-1, nivsup+1
          tabaui(iaux) = 0
   80   continue
c
        jaux = 0
c
c 8.1. ==> Les hexaedres de depart ou issus d'un decoupage en 8
c          Les faces sont toutes du meme niveau
c          Remarque : ils sont toujours decrits par faces
c
        do 81 , lehexa = 1, nbhepe
c
          if ( cfahex(cotyel,famhex(lehexa)).ne.0 ) then
c
          etat = mod(hethex(lehexa),1000)
c
          if ( etat.eq.0 ) then
c
          jaux = jaux + 1
          iaux = nivqua(quahex(lehexa,1))
          tabaui(iaux) = tabaui(iaux) + 1
c
          endif
c
          endif
c
   81   continue
c
c 8.2. ==> Les hexaedres issus d'un decoupage de conformite
c          Remarque : ils sont toujours actifs
c
        do 82 , lehexa = nbhepe+1 , nbheto
c
          call utnhex ( lehexa, niveau,
     >                  quahex, perhex,
     >                  nivqua )
c
          jaux = jaux + 1
          iaux = -int(niveau) - 1
          tabaui(iaux) = tabaui(iaux) + 1
c
   82   continue
c
        jaux = jaux + nbheca
c
        if ( jaux.ne.0 ) then
c
          write (ulbila,10100)
          write (ulbila,11200) mess14(langue,4,6)
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,1), jaux
c
          if ( nbiter.ge.1 ) then
            call utb07b ( tabaui, ulbila,
     >                    ulsort, langue, codret )
          endif
c
          write (ulbila,10200)
c
        endif
c
      endif
c
c====
c 9. pyramides
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. nbpyto, nbpype, nbpycf, nbpyca',
     >                     nbpyto, nbpype, nbpycf, nbpyca
#endif
c
      if ( nbpyto.ne.0 ) then
c
        do 90 , iaux = -nivsup-1, nivsup+1
          tabaui(iaux) = 0
   90   continue
c
        jaux = 0
c
c 9.1. ==> Les pyramides de depart ou issues d'un decoupage en 8
c          Les faces sont toutes du meme niveau
c          Remarque : elles sont toujours decrites par faces
c
        do 91 , lapyra = 1, nbpype
cgn      write (ulsort,90002) 'pyramide',lapyra
c
          if ( cfapyr(cotyel,fampyr(lapyra)).ne.0 ) then
c
          etat = mod(hetpyr(lapyra),100)
c
          if ( etat.eq.0 ) then
c
          jaux = jaux + 1
          iaux = nivtri(facpyr(lapyra,1))
          tabaui(iaux) = tabaui(iaux) + 1
c
          endif
c
          endif
c
   91   continue
cgn      write (ulsort,90002) 'jaux', jaux
cgn      write (ulsort,*) '************************'
c
c 9.2. ==> Les pyramides issues d'un decoupage de conformite
c          Remarque : elles sont toujours actives
c
        do 92 , lapyra = nbpype+1 , nbpyto
cgn      write (ulsort,90002) 'pyramide',lapyra
cgn      write (ulsort,90002) 'jaux',jaux
c
          call utnpyr ( lapyra, niveau,
     >                  facpyr, perpyr, pphepe,
     >                  nivtri, nivqua,
     >                  quahex, facpen )
c
          jaux = jaux + 1
          iaux = -int(niveau) - 1
          tabaui(iaux) = tabaui(iaux) + 1
c
   92   continue
cgn      write (ulsort,90002) 'jaux', jaux
c
        if ( jaux.ne.0 ) then
c
          write (ulbila,10100)
          write (ulbila,11200) mess14(langue,4,5)
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,1), jaux
c
          if ( nbiter.ge.1 ) then
            call utb07b ( tabaui, ulbila,
     >                    ulsort, langue, codret )
          endif
c
          write (ulbila,10200)
c
        endif
c
      endif
c
c====
c 10. pentaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. nbpeto, nbpecf',nbpeto, nbpecf
#endif
c
      if ( nbpeto.ne.0 ) then
c
        do 100 , iaux = -nivsup-1, nivsup+1
          tabaui(iaux) = 0
  100   continue
c
        jaux = 0
c
c 10.1. ==> Les pentaedres de depart ou issus d'un decoupage en 8
c          Les faces sont toutes du meme niveau
c          Remarque : ils sont toujours decrits par faces
c
        do 101 , lepent = 1, nbpepe
c
          if ( cfapen(cotyel,fampen(lepent)).ne.0 ) then
c
          etat = mod(hetpen(lepent),100)
c
          if ( etat.eq.0 ) then
c
          jaux = jaux + 1
          iaux = nivtri(facpen(lepent,1))
          tabaui(iaux) = tabaui(iaux) + 1
c
          endif
c
          endif
c
  101   continue
c
c 10.2. ==> Les pentaedres issus d'un decoupage de conformite
c          Remarque : ils sont toujours actifs
c
        do 102 , lepent = nbpepe+1 , nbpeto
c
          call utnpen ( lepent, niveau,
     >                  facpen, perpen,
     >                  nivtri, nivqua )
c
          jaux = jaux + 1
          iaux = -int(niveau) - 1
          tabaui(iaux) = tabaui(iaux) + 1
c
  102   continue
c
        jaux = jaux + nbpeca
c
        if ( jaux.ne.0 ) then
c
          write (ulbila,10100)
          write (ulbila,11200) mess14(langue,4,7)
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,1), jaux
c
          if ( nbiter.ge.1 ) then
            call utb07b ( tabaui, ulbila,
     >                    ulsort, langue, codret )
          endif
c
          write (ulbila,10200)
c
        endif
c
      endif
c
c====
c 11. reperage des homologues
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11. homolo',homolo
#endif
c
      if ( homolo.ne.0 ) then
c
        write (ulbila,10100)
        write (ulbila,11100) mess54(langue,1)
        write (ulbila,10200)
        saux43 = mess43(langue,60)
        if (nbeqno.gt.0) then
          saux43(11:24) = mess14(langue,3,-1)
          write (ulbila,12200) saux43, nbeqno/2
        endif
        if (nbeqmp.gt.0) then
          saux43(11:24) = mess14(langue,3,0)
          write (ulbila,12200) saux43, nbeqmp/2
        endif
        if (nbeqar.gt.0) then
          saux43(11:24) = mess14(langue,3,1)
          write (ulbila,12200) saux43, nbeqar/2
        endif
        if ( nbeqtr.gt.0 ) then
          saux43(11:24) = mess14(langue,3,2)
          write (ulbila,12200) saux43, nbeqtr/2
        endif
        if ( nbeqqu.gt.0 ) then
          saux43(11:24) = mess14(langue,3,4)
          write (ulbila,12200) saux43, nbeqqu/2
        endif
        write (ulbila,10200)
c
      endif
c
c====
c 12. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '12. codret',codret
#endif
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
