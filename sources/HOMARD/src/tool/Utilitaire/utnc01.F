      subroutine utnc01 ( nbanci, nbgemx,
     >                    coonoe,
     >                    somare, merare,
     >                    aretri,
     >                    povoso, voisom,
     >                    ngenar,
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
c    UTilitaire - Non Conformite - phase 01
c    --           -   -                  --
c    Reperage des non conformites : on repere les aretes par des
c    filiations "adoptives" en notant negativement les numeros d'arete
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbanci .   s .    1   . nombre d'aretes de non conformite initiale .
c .        .     .        . egal au nombre d'aretes recouvrant 2 autres.
c . nbgemx .   s .    1   . nombre maximal de generations sous une     .
c .        .     .        . arete                                      .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . merare . es  . nbarto . mere des aretes                            .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . voisom . e   . nvosom . elements 1d, 2d ou 3d voisins par sommet   .
c . ngenar .  s  . nbarto . nombre de generations au-dessus des aretes .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'UTNC01' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "envca1.h"
#include "precis.h"
#include "ope1a3.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbanci, nbgemx
      integer somare(2,nbarto), merare(nbarto)
      integer aretri(nbtrto,3)
      integer povoso(0:nbnoto), voisom(*)
      integer ngenar(nbarto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer poind2, poinf2, point2
      integer poind3, poinf3, point3
      integer aret1, aretmi, aretmo, aretma
      integer sonnnn, sopppp, soqqqq
      integer somdep, somarr
      integer somde3, somar3
      integer larete(3), lenoeu(3,3)
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      double precision daux(3), vect(3,3)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Nombre de paires de '',a,'' non-conformes :'',i10))'
      texte(1,5) =
     > '(''Nombre maximal de generations de '',a,'' :'',i10))'
      texte(1,6) = '(/,''Examen du '',a,i10)'
      texte(1,7) = '(a,1x,a,i10,'', de'',i10,'' a'',i10)'
      texte(1,8) = '(a,3('' '',a,'' :'',i10))'
      texte(1,10) =
     > '(''Nombre de '',a,'' de generation'',i10,'' :'',i10)'
c
      texte(2,4) =
     > '(''Number of non-conformal situations for '',a,'':'',i10))'
      texte(2,5) =
     > '(''Maximal number of generations for '',a,'':'',i10))'
      texte(2,6) = '(/,''Examination of '',a,'' #'',i10)'
      texte(2,7) = '(a,1x,a,'' #'',i10,'', from'',i10,'' to'',i10)'
      texte(2,8) = '(a,3('' '',a,'' :'',i10))'
      texte(2,10) =
     > '(''Number of '',a,'' from generation #'',i10,'' :'',i10)'
c
      codret = 0
      nbanci = 0
c
c====
c 2. On cherche tous les triplets d'aretes (aret1,larete(2),larete(3))
c    qui sont concourrantes.
c    Si elles definissent un triangle, on ne fait rien.
c    Sinon, on repere laquelle chapeaute les 2 autres : ce sera la
c    non conformite.
c====
c
c 2.1. ==> initialisations
c
      do 21 , aret1 = 1 , nbarto
        merare(aret1) = 0
        ngenar(aret1) = 0
   21 continue
c
c 2.2. ==> traitement
c
      do 2 , aret1 = 1 , nbarto
c
        if ( codret.eq.0 ) then
c
        sonnnn = somare(1,aret1)
        sopppp = somare(2,aret1)
#ifdef _DEBUG_HOMARD_
          if ( aret1.eq.10)then
            glop = 1
           else
            glop = 0
           endif
          if ( glop.gt.0)then
      write (ulsort,texte(langue,6)) mess14(langue,1,1), aret1
      write (ulsort,texte(langue,8)) ' ', 'de', sonnnn, 'a', sopppp
cgn      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbanci
            endif
#endif
c
c 2.2.1. ==> pour chacune des autres aretes contenant 'sonnnn'
c
        poind2 = povoso(sonnnn-1) + 1
        poinf2 = povoso(sonnnn)
        do 22 , point2 = poind2, poinf2
c
          if ( aret1.ne.voisom(point2) ) then
c
            larete(2) = voisom(point2)
c
c           les deux sommets de cette arete : P et Q
c
            somdep = somare(1,larete(2))
            somarr = somare(2,larete(2))
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0)then
      write (ulsort,texte(langue,7)) '...', mess14(langue,1,1),
     >                               larete(2), somdep, somarr
            endif
#endif
c
c           celui des sommets qui n'est pas sommet de 'aret1'
c
            if ( somdep.eq.sonnnn ) then
              soqqqq = somarr
            else
              soqqqq = somdep
            endif
c
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0)then
      write (ulsort,texte(langue,8)) '   ', 'N', sonnnn, 'P', sopppp,
     >                               'Q', soqqqq
            endif
#endif
c
c           existe-t-il une arete joignant P et Q ?
c
            poind3 = povoso(sopppp-1) + 1
            poinf3 = povoso(sopppp)
            do 221 , point3 = poind3, poinf3
c
              larete(3) = voisom(point3)
c
c          les deux sommets de cette arete
c
              somde3 = somare(1,larete(3))
              somar3 = somare(2,larete(3))
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0)then
      write (ulsort,texte(langue,7)) '.....', mess14(langue,1,1),
     >                               larete(3), somde3, somar3
            endif
#endif
c
              if ( somde3.eq.soqqqq .or. somar3.eq.soqqqq ) then
c
              if ( ngenar(aret1).eq.0 .and.
     >             ngenar(larete(2)).eq.0 .and.
     >             ngenar(larete(3)).eq.0 ) then
c
                larete(1) = aret1
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0)then
      write (ulsort,texte(langue,7)) '====>', mess14(langue,1,1),
     >                               larete(3), somde3, somar3
      write (ulsort,texte(langue,8)) '   ', 'A1', larete(1),
     >                               'A2', larete(2), 'A3', larete(3)
            endif
#endif
c
c               existe-t-il un triangle defini par ces 3 aretes ?
c
                if ( nbtrto.ne.0 ) then
c
cgn      print *,'A1', larete(1),' A2', larete(2), ' A3', larete(3)
                  aretmi = min(larete(1), larete(2), larete(3))
                  aretma = max(larete(1), larete(2), larete(3))
                  if ( larete(1).ne.aretmi .and.
     >                 larete(1).ne.aretma ) then
                    aretmo = larete(1)
                  elseif ( larete(2).ne.aretmi .and.
     >                     larete(2).ne.aretma ) then
                    aretmo = larete(2)
                  else
                    aretmo = larete(3)
                  endif
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0)then
            write (ulsort,*)'aretmi/mo/ma',aretmi, aretmo, aretma
          endif
#endif
                  do 2211 , iaux = 1, nbtrto
cgn      print *,aretri(iaux,1),aretri(iaux,2),aretri(iaux,3)
                    if ( min(aretri(iaux,1),
     >                       aretri(iaux,2),
     >                       aretri(iaux,3)).eq.aretmi ) then
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0)then
            write (ulsort,*)'triangle ',iaux,' :',
     >                     aretri(iaux,1),aretri(iaux,2),aretri(iaux,3)
          endif
#endif
                      if ( max(aretri(iaux,1),
     >                         aretri(iaux,2),
     >                         aretri(iaux,3)).eq.aretma ) then
                        if ( aretri(iaux,1).eq.aretmo .or.
     >                       aretri(iaux,2).eq.aretmo .or.
     >                       aretri(iaux,3).eq.aretmo ) then
cgn      print *,'c''est un vrai triangle'
                           goto 22
                        endif
                      endif
                    endif
 2211             continue
c
                endif
c
c               recherche des dependances de ces 3 aretes
c               on cherche quel est l'alignement des noeuds
c
c               l'arete 1 va de N a P
c               l'arete 2 est entre N et Q
c               l'arete 3 est entre Q et P
c               l'arete i va de lenoeu(1,i) a lenoeu(2,i)
c
                lenoeu(1,1) = sonnnn
                lenoeu(2,1) = sopppp
                lenoeu(3,1) = soqqqq
c
                lenoeu(1,2) = min(sonnnn,soqqqq)
                lenoeu(2,2) = max(sonnnn,soqqqq)
                lenoeu(3,2) = sopppp
c
                lenoeu(1,3) = min(sopppp,soqqqq)
                lenoeu(2,3) = max(sopppp,soqqqq)
                lenoeu(3,3) = sonnnn
c
                do 2212 , iaux = 1, 3
cgn      print *,larete(iaux),lenoeu(1,iaux),lenoeu(2,iaux),lenoeu(3,iaux)
                  do 2213 , jaux = 1, sdim
                    vect(iaux,jaux) = coonoe(lenoeu(2,iaux),jaux)
     >                              - coonoe(lenoeu(1,iaux),jaux)
 2213             continue
cgn         print *,vect(iaux,1),vect(iaux,2),vect(iaux,3)
 2212           continue
c
c       on verifie que les 3 points sont alignes :
c
c                A--------C---------------------B
c       attention : contrairement a ce que nous pensions au depart,
c                   on peut tres bien avoir des situations avec 3 aretes
c                   concourrantes sans qu'elles ne forment un triangle
c                   au sens de face HOMARD.
c                   Exemple :
c
c                            A
c                          . . .
c                         .  .  .
c                        .   .   .
c                       .    .    .
c                      .    .R.    .
c                     .   .     .   .
c                    .  .         .  .
c                   . .             . .
c                  B...................C
c
c                Si des tetraedres sont batis sur les faces ACR, CRB et
c               BRA, le triangle ABC n'existe pas
c
                if ( sdim.eq.2 ) then
c
                  daux(1) =
     >   ( vect(1,1) * vect(2,2) ) - ( vect(1,2) * vect(2,1) )
cgn                  print *,daux(1)
                  if ( daux(1).gt.epsima ) then
#ifdef _DEBUG_HOMARD_
                  write(ulsort,*) 'bizarrerie : daux(1) =',daux(1)
                  write(ulsort,*) 'arete 1 =',sonnnn,' => ', sopppp
                  write(ulsort,*) 'arete 2 =',sopppp,' => ', soqqqq
                  write(ulsort,*) 'arete 3 =',soqqqq,' => ', sonnnn
#endif
                    goto 22
                  endif
c
                else
c
                  daux(1) =
     >   ( vect(1,2) * vect(2,3) ) - ( vect(1,3) * vect(2,2) )
                  daux(2) =
     >   ( vect(1,3) * vect(2,1) ) - ( vect(1,1) * vect(2,3) )
                  daux(3) =
     >   ( vect(1,1) * vect(2,2) ) - ( vect(1,2) * vect(2,1) )
c
                  daux(1) = abs(daux(1)) + abs(daux(2)) + abs(daux(3))
cgn                  print *,daux(1)
                  if ( daux(1).gt.epsima ) then
#ifdef _DEBUG_HOMARD_
                  write(ulsort,*) 'bizarrerie : daux(1) =',daux(1)
                  write(ulsort,6661) aret1,lenoeu(1,1), lenoeu(2,1)
                  write(ulsort,6661) larete(2),lenoeu(1,2), lenoeu(2,2)
                  write(ulsort,6661) larete(3),lenoeu(1,3), lenoeu(2,3)
                  write(ulsort,6662) sonnnn,
     >coonoe(sonnnn,1),coonoe(sonnnn,2),coonoe(sonnnn,3)
                  write(ulsort,6662) sopppp,
     >coonoe(sopppp,1),coonoe(sopppp,2),coonoe(sopppp,3)
                  write(ulsort,6662) soqqqq,
     >coonoe(soqqqq,1),coonoe(soqqqq,2),coonoe(soqqqq,3)
                  write(ulsort,6663) sonnnn,soqqqq,
     >coonoe(soqqqq,1)-coonoe(sonnnn,1),
     >coonoe(soqqqq,2)-coonoe(sonnnn,2),
     >coonoe(soqqqq,3)-coonoe(sonnnn,3)
                  write(ulsort,6663) sopppp,soqqqq,
     >coonoe(soqqqq,1)-coonoe(sopppp,1),
     >coonoe(soqqqq,2)-coonoe(sopppp,2),
     >coonoe(soqqqq,3)-coonoe(sopppp,3)
                  write(ulsort,6664)
     >(coonoe(soqqqq,1)-coonoe(sopppp,1))/
     >(coonoe(soqqqq,1)-coonoe(sonnnn,1)),
     >(coonoe(soqqqq,2)-coonoe(sopppp,2))/
     >(coonoe(soqqqq,2)-coonoe(sonnnn,2)),
     >(coonoe(soqqqq,3)-coonoe(sopppp,3))/
     >(coonoe(soqqqq,3)-coonoe(sonnnn,3))
 6661 format('arete',i10,' de',i10,' a',i10)
 6662 format('noeud',i10,' :',3(g15.8,1x))
 6663 format('de',i10,' a',i10,' :',3(g15.8,1x))
 6664 format('rapport :',3(g15.8,1x))
#endif
                    goto 22
                  endif
c
                endif
c
c  Calcul du produit scalaire entre le 3�me noeud et les 2 extremites
c  de chaque arete iaux :
c                           arete iaux
c                A--------C---------------------B
c
c     CA*CB = CA * CB * cos(CA,CB) = - CA * CB < 0
c     AB*AC = AB * AC * cos(AB,AC) = + AB * AC > 0
c     BC*BA = BC * BA * cos(BC,BA) = + BC * BA > 0
c
                do 2214 , iaux = 1, 3
c
                  daux(iaux) = 0.d0
                  do 2215 , jaux = 1, sdim
                    daux(iaux) = daux(iaux) +
     >   ( coonoe(lenoeu(1,iaux),jaux) - coonoe(lenoeu(3,iaux),jaux) ) *
     >   ( coonoe(lenoeu(2,iaux),jaux) - coonoe(lenoeu(3,iaux),jaux) )
 2215             continue
cgn                  print *,'daux(',iaux,') =',daux(iaux)
c
c  On repere celui qui est negatif (il y en a forcement un !)
c  On connait alors l'arete qui recouvre les deux autres : c'est iaux
c  Les deux autres sont obtenues par pemutation circulaire de iaux
c  On declare que :
c     - les deux "petites" aretes ont la grande comme mere adoptive
c       cela servira dans la suite de la conversion
c     - la "grande" arete a une fille ; il suffit de mettre un numero
c       positif strictement car c'est utilise uniquement ici pour ne
c       pas faire plusieurs fois la meme chose (cf test au debut de
c       la boucle 221). On choisit de mettre 1.
c
                  if ( daux(iaux).lt.epsima ) then
                    jaux = per1a3(-1,iaux)
                    kaux = per1a3( 1,iaux)
cgn      if ( aret1.eq.15931)then
cgn      print *,larete(iaux),larete(jaux),larete(kaux)
cgn      write (ulsort,texte(langue,6)) mess14(langue,1,1), 16334
cgn      write (ulsort,texte(langue,8)) ' ', 'de', somare(1,16334),
cgn     > 'a', somare(2,16334)
cgn      endif
                    merare(larete(jaux)) = -larete(iaux)
                    merare(larete(kaux)) = -larete(iaux)
                    ngenar(larete(iaux)) = 1
cgn                    ngenar(larete(iaux)) =
cgn     >                       - max(larete(jaux),larete(kaux))
                    nbanci = nbanci + 1
                    goto 22
                  endif
c
 2214           continue
c
c probleme si on arrive ici ...
c
                codret = codret + 1
c
              endif
c
              endif
c
  221       continue
c
          endif
c
   22   continue
c
      endif
#ifdef _DEBUG_HOMARD_
cgn          if ( aret1.eq.15931)then
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbanci
cgn            endif
#endif
c
    2 continue
c
c====
c 3. Determination du nombre de generations au-dessus de chaque arete
c
c      x---------------------------0---------------------------x
c      x-------------1-------------x-------------1-------------x
c      x------2------x------2------x------2------x------2------x
c                                  x---3--x---3--x
c
c    On part d'une arete quelconque. On compte le nombre d'aretes
c    au-dessus d'elle dans l'ascendance.
c====
c
      if ( codret.eq.0 ) then
c
      do 31 , iaux = 1 , nbarto
c
        jaux = iaux
        kaux = 0
  310   continue
cgn        write (ulsort,texte(langue,6)) mess14(langue,1,1), jaux
        if ( merare(jaux).ne.0 ) then
          jaux = -merare(jaux)
          kaux = kaux + 1
          goto 310
        endif
c
        ngenar(iaux) = kaux
c
   31 continue
c
      nbgemx = ngenar(1)
      do 32 , iaux = 2 , nbarto
        nbgemx = max(nbgemx,ngenar(iaux))
   32 continue
c
      endif
c
cgn       write (ulsort,*)'ngenar : ',ngenar
cgn       write (ulsort,*)'merare : ',merare
cgn       print *,'ngenar(190) : ',ngenar(190)
cgn       print *,'merare(190) : ',merare(190)
c
#ifdef _DEBUG_HOMARD_
c
c 3.3. ==> impression du nombre d'aretes par generation
c
        kaux = 0
c
  330 continue
c
        if ( codret.eq.0 ) then
c
        jaux = 0
        do 33 , iaux = 1 , nbarto
c
          if ( ngenar(iaux).eq.kaux ) then
            jaux = jaux + 1
          endif
c
   33 continue
c
        if ( jaux.ne.0 ) then
          write (ulsort,texte(langue,10)) mess14(langue,3,1),
     >                                    kaux, jaux
          kaux = kaux + 1
          goto 330
        endif
c
        endif
#endif
c
c====
c 4. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbanci
      write (ulsort,texte(langue,5)) mess14(langue,3,1), nbgemx
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
