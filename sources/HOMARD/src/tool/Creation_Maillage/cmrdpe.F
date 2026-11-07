      subroutine cmrdpe ( somare, hetare, filare, merare,
     >                    aretri, hettri,
     >                    filtri, pertri, nivtri,
     >                    arequa, hetqua,
     >                    filqua, perqua, nivqua,
     >                    facpen, cofape, hetpen,
     >                    filpen, perpen,
     >                    famare, famtri, famqua, fampen,
     >                    indare, indtri, indqua, indpen,
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
c    Creation du Maillage - Raffinement - Decoupage des PEntaedres
c    -           -          -             -             --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nouvtr . historique de l'etat des triangles         .
c . filtri . e   . nouvtr . premier fils des triangles                 .
c . pertri . e   . nouvtr . pere des triangles                         .
c . nivtri . e   . nouvtr . niveau des triangles                       .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nouvqu . historique de l'etat des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . perqua . e   . nouvqu . pere des quadrangles                       .
c . nivqua . e   . nouvqu . niveau des quadrangles                     .
c . facpen . e   .nouvpf*5. numeros des faces des pentaedres           .
c . cofape . e   .nouvpf*5. code des faces des pentaedres              .
c . hetpen . es  . nouvpe . historique de l'etat des pentaedres        .
c . filpen . es  . nouvpe . premier fils des pentaedres                .
c . perpen . e   . nouvpe . pere des pentaedres                        .
c . famare . es  . nouvar . famille des aretes                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . famqua . es  . nouvqu . famille des quadrangles                    .
c . fampen . es  . nouvpe . famille des pentaedres                     .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indtri . es  . 1      . indice du dernier triangle cree            .
c . indqua . es  . 1      . indice du dernier quadrangle cree          .
c . indpen . es  . 1      . indice du dernier pentaedre cree           .
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
      parameter ( nompro = 'CMRDPE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "i1i2i3.h"
#include "cofpen.h"
#include "nombpe.h"
#include "nouvnb.h"
#include "defiqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer somare(2,nouvar), hetare(nouvar), filare(nouvar)
      integer merare(nouvar)
      integer aretri(nouvtr,3), hettri(nouvtr)
      integer filtri(nouvtr), pertri(nouvtr), nivtri(nouvtr)
      integer arequa(nouvqu,4), hetqua(nouvqu)
      integer filqua(nouvqu), perqua(nouvqu), nivqua(nouvqu)
      integer facpen(nouvpf,5), cofape(nouvpf,5)
      integer hetpen(nouvpe), filpen(nouvpe), perpen(nouvpe)
      integer famare(nouvar), famtri(nouvtr), famqua(nouvqu)
      integer fampen(nouvpe)
      integer indare, indtri, indqua, indpen
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer dt, etat, lepent, pere, nupent
      integer niveau, cf1, cf2, cf3, cf4, cf5, f1, f2, f3, f4, f5
      integer codefa
      integer a1ff1, a2ff1, a3ff1, a4ff2, a5ff2, a6ff2
      integer n1nf3, n9nf3, n4nf3, n7nf3
      integer n2nf4, n7nf4, n5nf4, n8nf4
      integer n3nf5, n8nf5, n6nf5, n9nf5
      integer ff1, ff2
      integer f1ff1, f2ff1, f3ff1, f4ff2, f5ff2, f6ff2
      integer f3s1, f3s3, f3s6, f3s4
      integer f4s2, f4s1, f4s4, f4s5
      integer f5s3, f5s2, f5s5, f5s6
      integer nf3, nf4, nf5
      integer nf3nf4, nf4nf5, nf5nf3
      integer pf1, pf1n7, pf1n8, pf1n9
      integer pf3f1, pf3f2, pf4f1, pf4f2, pf5f1, pf5f2
c
      integer iaux, jaux
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
      texte(1,4) = '(''Decoupage du '',a,i10)'
      texte(1,5) =
     > '(''.. Face :'',i10,'', d''''aretes'',4i10,'', code'',i2)'
      texte(1,6) = '(''.. Noeuds milieux des faces'',6i10)'
      texte(1,7) = '(''.. Noeud milieu'',i10,'', coor :'',3g15.7)'
      texte(1,9) = '(''.. Creation des '',a,'' internes'')'
      texte(1,10) = '(''.. Creation des 8 pentaedres'')'
c
      texte(2,4) = '(''Splitting of '',a,'' #'',i10)'
      texte(2,5) =
     > '(''.. Face :'',i10,'', with edges'',4i10,'', code'',i2)'
      texte(2,6) = '(''.. Center nodes for faces'',6i10)'
      texte(2,7) = '(''.. Central node'',i10,'', coor :'',3g15.7)'
      texte(2,9) = '(''.. Creation of internal '',a)'
      texte(2,10) = '(''.. Creation of 8 pentahedrons'')'
c
c====
c 2. decoupage en 8 des pentaedres dont les 5 faces sont coupees en 4
c====
c
      do 200 , lepent = 1 , nbpepe
c
       if ( mod(hetpen(lepent),100) .eq. 0 ) then
c
c 2.1. decoupage ?
c
        dt = 0
        do 211 , iaux = 1 , 2
          jaux = facpen(lepent,iaux)
          if ( mod(hettri(jaux),10).eq.4 .or.
     >         mod(hettri(jaux),10).eq.5 .or.
     >         mod(hettri(jaux),10).eq.6 .or.
     >         mod(hettri(jaux),10).eq.7 .or.
     >         mod(hettri(jaux),10).eq.9) then
            dt = dt + 1
          endif
  211   continue
        do 212 , iaux = 3 , 5
          jaux = facpen(lepent,iaux)
          if ( mod(hetqua(jaux),100).eq.4 .or.
     >         mod(hetqua(jaux),100).eq.99 ) then
            dt = dt + 1
          endif
  212   continue
c
        if ( dt.eq.5 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,7), lepent
#endif
c
c 2.2. ==> description des 5 faces du pentaedre
c
c 2.2.1. ==> description de la face 1
c
          f1 = facpen(lepent,1)
          cf1 = cofape(lepent,1)
c
c 2.2.1.1. ==> reperage des 4 triangles fils
c              fiff1 : face opposee a arete ai
c              ainsi f1ff1 contient le sommet s2
c
          ff1 = filtri(f1)
          f1ff1 = ff1 + i1(cf1)
          f2ff1 = ff1 + i2(cf1)
          f3ff1 = ff1 + i3(cf1)
c
c 2.2.1.2. ==> reperage des 3 aretes internes
c              aiff1 : arete de ff1 qui est // a ai
c
          a1ff1 = aretri(ff1,i1(cf1))
          a2ff1 = aretri(ff1,i2(cf1))
          a3ff1 = aretri(ff1,i3(cf1))
c
c 2.2.2. ==> description de la face 2
c
          f2 = facpen(lepent,2)
          cf2 = cofape(lepent,2)
c
c 2.2.2.1. ==> reperage des 4 triangles fils
c
          ff2 = filtri(f2)
          f4ff2 = ff2 + i1(cf2)
          f6ff2 = ff2 + i2(cf2)
          f5ff2 = ff2 + i3(cf2)
c
c 2.2.2.2. ==> reperage des 3 aretes internes
c
          a4ff2 = aretri(ff2,i1(cf2))
          a6ff2 = aretri(ff2,i2(cf2))
          a5ff2 = aretri(ff2,i3(cf2))
c
c 2.2.3. ==> description de la face 3
c
          f3 = facpen(lepent,3)
          cf3 = cofape(lepent,3)
c
c 2.2.3.1. ==> reperage des 4 quadrangles fils
c
          f3s1 = filqua(f3) + defiq1(cf3)
          f3s3 = filqua(f3) + defiq2(cf3)
          f3s6 = filqua(f3) + defiq3(cf3)
          f3s4 = filqua(f3) + defiq4(cf3)
c        write(ulsort,*) 'f3s1, f3s3, f3s6, f3s4 ',f3s1, f3s3, f3s6,f3s4
c
c 2.2.3.2. ==> reperage des 4 aretes internes
c
          if ( cf3.lt.5 ) then
           n1nf3 = arequa(f3s1,2)
           n9nf3 = arequa(f3s3,2)
           n4nf3 = arequa(f3s6,2)
           n7nf3 = arequa(f3s4,2)
          else
           n1nf3 = arequa(f3s3,2)
           n9nf3 = arequa(f3s6,2)
           n4nf3 = arequa(f3s4,2)
           n7nf3 = arequa(f3s1,2)
          endif
c
c 2.2.4. ==> description de la face 4
c
          f4 = facpen(lepent,4)
          cf4 = cofape(lepent,4)
c
c 2.2.4.1. ==> reperage des 4 quadrangles fils
c
          f4s2 = filqua(f4) + defiq1(cf4)
          f4s1 = filqua(f4) + defiq2(cf4)
          f4s4 = filqua(f4) + defiq3(cf4)
          f4s5 = filqua(f4) + defiq4(cf4)
c
c 2.2.4.2. ==> reperage des 4 aretes internes
c
          if ( cf4.lt.5 ) then
           n2nf4 = arequa(f4s2,2)
           n7nf4 = arequa(f4s1,2)
           n5nf4 = arequa(f4s4,2)
           n8nf4 = arequa(f4s5,2)
          else
           n2nf4 = arequa(f4s1,2)
           n7nf4 = arequa(f4s4,2)
           n5nf4 = arequa(f4s5,2)
           n8nf4 = arequa(f4s2,2)
          endif
c
c 2.2.5. ==> description de la face 5
c
          f5 = facpen(lepent,5)
          cf5 = cofape(lepent,5)
c
c 2.2.5.1. ==> reperage des 4 quadrangles fils
c
          f5s3 = filqua(f5) + defiq1(cf5)
          f5s2 = filqua(f5) + defiq2(cf5)
          f5s5 = filqua(f5) + defiq3(cf5)
          f5s6 = filqua(f5) + defiq4(cf5)
c
c 2.2.5.2. ==> reperage des 4 aretes internes
c
          if ( cf5.lt.5 ) then
           n3nf5 = arequa(f5s3,2)
           n8nf5 = arequa(f5s2,2)
           n6nf5 = arequa(f5s5,2)
           n9nf5 = arequa(f5s6,2)
          else
           n3nf5 = arequa(f5s2,2)
           n8nf5 = arequa(f5s5,2)
           n6nf5 = arequa(f5s6,2)
           n9nf5 = arequa(f5s3,2)
          endif
c
#ifdef _DEBUG_HOMARD_
          write(ulsort,texte(langue,5)) f1,aretri(f1,1),aretri(f1,2)
     >         ,aretri(f1,3),0,cf1
          write(ulsort,texte(langue,5)) f2,aretri(f2,1),aretri(f2,2)
     >         ,aretri(f2,3),0,cf2
          write(ulsort,texte(langue,5)) f3,arequa(f3,1),arequa(f3,2)
     >         ,arequa(f3,3),arequa(f3,4),cf3
          write(ulsort,texte(langue,5)) f4,arequa(f4,1),arequa(f4,2)
     >         ,arequa(f4,3),arequa(f4,4),cf4
          write(ulsort,texte(langue,5)) f5,arequa(f5,1),arequa(f5,2)
     >         ,arequa(f5,3),arequa(f5,4),cf5
#endif
c
c 2.3. ==> noeuds milieux des faces du pentaedre
c
          nf3 = somare(2,n1nf3)
          nf4 = somare(2,n2nf4)
          nf5 = somare(2,n3nf5)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nf3, nf4, nf5
#endif
c
c 2.4. ==> creation des aretes internes au pentaedre
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) mess14(langue,3,1)
#endif
c
c 2.4.1. ==> leurs numeros
c
          nf3nf4 = indare + 1
          nf4nf5 = indare + 2
          nf5nf3 = indare + 3
          indare = nf5nf3
c
c 2.4.2. ==> les numeros de leurs sommets avec la convention ad'hoc
c
          somare(1,nf3nf4) = min(nf3,nf4)
          somare(2,nf3nf4) = max(nf3,nf4)
          somare(1,nf4nf5) = min(nf4,nf5)
          somare(2,nf4nf5) = max(nf4,nf5)
          somare(1,nf5nf3) = min(nf3,nf5)
          somare(2,nf5nf3) = max(nf3,nf5)
c
c 2.4.3. ==> leur famille : libre
c
          famare(nf3nf4) = 1
          famare(nf4nf5) = 1
          famare(nf5nf3) = 1
c
c 2.4.4. ==> la parente
c
          hetare(nf3nf4) = 50
          hetare(nf4nf5) = 50
          hetare(nf5nf3) = 50
          merare(nf3nf4) = 0
          merare(nf4nf5) = 0
          merare(nf5nf3) = 0
          filare(nf3nf4) = 0
          filare(nf4nf5) = 0
          filare(nf5nf3) = 0
c
c 2.5. ==> creation des 4 triangles internes
c 2.5.1. ==> recuperation du niveau commun a tous les triangles fils
c            le code est 1 par defaut
c
          niveau = nivtri(ff1)
          codefa = 1
c
c 2.5.2. ==> creation
c
          pf1 = indtri + 1
          call cmctri ( aretri, famtri, hettri,
     >                  filtri, pertri, nivtri,
     >                  pf1, nf3nf4, nf4nf5, nf5nf3,
     >                  codefa, niveau )
c
          pf1n7 = indtri + 2
          call cmctri ( aretri, famtri, hettri,
     >                  filtri, pertri, nivtri,
     >                  pf1n7, nf3nf4, n7nf3, n7nf4,
     >                  codefa, niveau )
c
          pf1n8 = indtri + 3
          call cmctri ( aretri, famtri, hettri,
     >                  filtri, pertri, nivtri,
     >                  pf1n8, nf4nf5, n8nf4, n8nf5,
     >                  codefa, niveau )
c
          pf1n9 = indtri + 4
          call cmctri ( aretri, famtri, hettri,
     >                  filtri, pertri, nivtri,
     >                  pf1n9, nf5nf3, n9nf5, n9nf3,
     >                  codefa, niveau )
c
          indtri = pf1n9
c
c 2.6. ==> creation des 6 quadrangles internes
c         tous ces quadrangles sont crees avec le code arbitraire 1
c         et avec le meme niveau que les triangles
c
          pf3f1 = indqua + 1
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf3f1, a1ff1, n3nf5, nf4nf5, n2nf4,
     >                  codefa, niveau )
c
          pf3f2 = indqua + 2
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf3f2, nf4nf5, n6nf5, a4ff2, n5nf4,
     >                  codefa, niveau )
c
          pf4f1 = indqua + 3
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf4f1, a2ff1, n1nf3, nf5nf3, n3nf5,
     >                  codefa, niveau )
c
          pf4f2 = indqua + 4
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf4f2, nf5nf3, n4nf3, a5ff2, n6nf5,
     >                  codefa, niveau )
c
          pf5f1 = indqua + 5
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf5f1, a3ff1, n2nf4, nf3nf4, n1nf3,
     >                  codefa, niveau )
c
          pf5f2 = indqua + 6
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf5f2, nf3nf4, n5nf4, a6ff2, n4nf3,
     >                  codefa, niveau )
c
          indqua = pf5f2
c
c 2.7. ==> creation des 8 pentaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10))
#endif
c
          iaux = fampen(lepent)
c
          nupent = indpen + 1
          call cmcpen ( facpen, cofape, fampen,
     >                  hetpen, filpen, perpen,
     >                   f3ff1,  pf1n7,   f3s1,
     >                    f4s1,  pf5f1,
     >                     cf1,      6, cofp08(cf3,defiq1(cf3)),
     >                  cofp08(cf4,defiq2(cf4)), 1,
     >                  lepent,   iaux, nupent )
c
          nupent = indpen + 2
          call cmcpen ( facpen, cofape, fampen,
     >                  hetpen, filpen, perpen,
     >                   f1ff1,  pf1n8,  pf3f1,
     >                    f4s2,   f5s2,
     >                     cf1,      4,      1,
     >                  cofp08(cf4,defiq1(cf4)),
     >                  cofp08(cf5,defiq2(cf5)),
     >                  lepent,   iaux, nupent )
c
          nupent = indpen + 3
          call cmcpen ( facpen, cofape, fampen,
     >                  hetpen, filpen, perpen,
     >                   f2ff1,  pf1n9,   f3s3,
     >                   pf4f1,   f5s3,
     >                     cf1,      5, cofp08(cf3,defiq2(cf3)),
     >                       1, cofp08(cf5,defiq1(cf5)),
     >                  lepent,   iaux, nupent )
c
          nupent = indpen + 4
          call cmcpen ( facpen, cofape, fampen,
     >                  hetpen, filpen, perpen,
     >                   pf1n7,  f6ff2,   f3s4,
     >                    f4s4,  pf5f2,
     >                       3,    cf2, cofp08(cf3,defiq4(cf3)),
     >                  cofp08(cf4,defiq3(cf4)), 1,
     >                  lepent,   iaux, nupent )
c
          nupent = indpen + 5
          call cmcpen ( facpen, cofape, fampen,
     >                  hetpen, filpen, perpen,
     >                   pf1n8,  f4ff2,  pf3f2,
     >                    f4s5,   f5s5,
     >                       1,    cf2,      1,
     >                 cofp08(cf4,defiq4(cf4)), cofp08(cf5,defiq3(cf5)),
     >                  lepent,   iaux, nupent )
c
          nupent = indpen + 6
          call cmcpen ( facpen, cofape, fampen,
     >                  hetpen, filpen, perpen,
     >                   pf1n9,  f5ff2,   f3s6,
     >                   pf4f2,   f5s6,
     >                       2,    cf2, cofp08(cf3,defiq3(cf3)),
     >                       1, cofp08(cf5,defiq4(cf5)),
     >                  lepent,   iaux, nupent )
c
          nupent = indpen + 7
          call cmcpen ( facpen, cofape, fampen,
     >                  hetpen, filpen, perpen,
     >                     ff1,    pf1,  pf3f1,
     >                   pf4f1,  pf5f1,
     >                     cf1,      6,      5,
     >                       5,      5,
     >                  lepent,   iaux, nupent )
c
          nupent = indpen + 8
          call cmcpen ( facpen, cofape, fampen,
     >                  hetpen, filpen, perpen,
     >                     pf1,    ff2,  pf3f2,
     >                   pf4f2,  pf5f2,
     >                       3,    cf2,      5,
     >                       5,      5,
     >                  lepent,   iaux, nupent )
c
          indpen = nupent
c
c 2.7.3. ==> mise a jour du pentaedre courant et de son pere eventuel
c
          filpen(lepent) = indpen - 7
          hetpen(lepent) = hetpen(lepent) + 80
          pere = perpen(lepent)
          if ( pere .ne. 0 ) then
            etat = hetpen(pere)
            hetpen(pere) = etat - mod(etat,100) + 99
          endif
c
        endif
c
       endif
c
  200 continue
c
c====
c 3. la fin
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
