      subroutine cmrdte ( coonoe, somare, hetare, filare,
     >                    merare, aretri, hettri,
     >                    filtri, pertri, nivtri,
     >                    tritet, cotrte, hettet, filtet,
     >                    pertet,
     >                    famare, famtri, famtet,
     >                    indare, indtri, indtet,
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
c    Creation du Maillage - Raffinement - Decoupage des TEtraedres
c    -           -          -             -             --
c ______________________________________________________________________
c       remarque : on est forcement en 3d
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   .nouvno*3. coordonnees des noeuds                     .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nouvtr . historique de l'etat des triangles         .
c . filtri . e   . nouvtr . premier fils des triangles                 .
c . pertri . e   . nouvtr . pere des triangles                         .
c . nivtri . e   . nouvtr . niveau des triangles                       .
c . tritet . e   .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nouvtf*4. code des 4 triangles des tetraedres        .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . e   . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famare . es  . nouvar . famille des aretes                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . famtet . e   . nouvte . famille des tetraedres                     .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indtri . es  . 1      . indice du dernier triangle cree            .
c . indtet . es  . 1      . indice du dernier tetraedre cree           .
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
      parameter ( nompro = 'CMRDTE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "i1i2i3.h"
#include "nombte.h"
#include "nouvnb.h"
#include "permut.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nouvno,sdim)
c
      integer somare(2,nouvar), hetare(nouvar), filare(nouvar)
      integer merare(nouvar), aretri(nouvtr,3)
      integer hettri(nouvtr), filtri(nouvtr), pertri(nouvtr)
      integer nivtri(nouvtr)
      integer tritet(nouvtf,4), cotrte(nouvtf,4)
      integer hettet(nouvte), filtet(nouvte), pertet(nouvte)
      integer famare(nouvar), famtri(nouvtr), famtet(nouvte)
      integer indare, indtri, indtet
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer adiag, dt, etat, letetr, nudiag, pere, typdia
      integer niveau, cf1, cf2, cf3, cf4, f1, f2, f3, f4
      integer codefa, codef1, codef2, codef3, codef4
      integer a4ff1, a5ff1, a6ff1, a2ff2, a3ff2, a6ff2
      integer a1ff3, a3ff3, a5ff3, a1ff4, a2ff4, a4ff4
      integer as1n1, as1n2, as1n3, as2n4, as2n5, as3n6
      integer ff1, ff2, ff3, ff4, n1, n2, n3, n4, n5, n6
      integer f4ff1, f5ff1, f6ff1, f2ff2, f3ff2, f6ff2
      integer f1ff3, f3ff3, f5ff3, f1ff4, f2ff4, f4ff4
      integer fparf1, fparf2, fparf3, fparf4
      integer fd16n2, fd16n3, fd16n4, fd16n5
      integer fd25n1, fd25n3, fd25n4, fd25n6
      integer fd34n1, fd34n2, fd34n5, fd34n6
      integer tparf1, tparf2, tparf3, tparf4
      integer t16ff1, t16ff2, t16ff3, t16ff4
      integer t25ff1, t25ff2, t25ff3, t25ff4
      integer t34ff1, t34ff2, t34ff3, t34ff4
c
      integer iaux, jaux
c
      double precision long16, long25, long34, xdiag, ydiag, zdiag
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
c
      texte(2,4) = '(''Splitting of '',a,'' #'',i10)'
c
c====
c 2. decoupage en 8 des tetraedres dont les 4 faces sont coupees en 4
c====
c
      do 200 , letetr = 1 , nbtepe
c
       if ( mod( hettet(letetr) , 100 ) .eq. 0 ) then
c
c 2.1. decoupage ?
c
        dt = 0
        do 21 , iaux = 1 , 4
          jaux = tritet(letetr,iaux)
          if ( mod(hettri(jaux),10).eq.4 .or.
     >         mod(hettri(jaux),10).eq.5 .or.
     >         mod(hettri(jaux),10).eq.6 .or.
     >         mod(hettri(jaux),10).eq.7 .or.
     >         mod(hettri(jaux),10).eq.9) then
            dt = dt + 1
          endif
   21   continue
c
        if ( dt.eq.4 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,3), letetr
#endif
c
c 2.2. ==> description des 4 faces du tetraedre
c
c 2.2.1. ==> description de la face 1
c
          f1 = tritet(letetr,1)
          cf1 = cotrte(letetr,1)
c
c 2.2.1.1. ==> reperage des 4 triangles fils
c
          ff1 = filtri(f1)
          f4ff1 = ff1 + i1(cf1)
          f5ff1 = ff1 + i2(cf1)
          f6ff1 = ff1 + i3(cf1)
c
c 2.2.1.2. ==> reperage des 3 aretes internes
c
          a4ff1 = aretri(ff1,i1(cf1))
          a5ff1 = aretri(ff1,i2(cf1))
          a6ff1 = aretri(ff1,i3(cf1))
c
c 2.2.2. ==> description de la face 2
c
          f2 = tritet(letetr,2)
          cf2 = cotrte(letetr,2)
c
c 2.2.2.1. ==> reperage des 4 triangles fils
c
          ff2 = filtri(f2)
          f2ff2 = ff2 + i1(cf2)
          f3ff2 = ff2 + i2(cf2)
          f6ff2 = ff2 + i3(cf2)
c
c 2.2.2.2. ==> reperage des 3 aretes internes
c
          a2ff2 = aretri(ff2,i1(cf2))
          a3ff2 = aretri(ff2,i2(cf2))
          a6ff2 = aretri(ff2,i3(cf2))
c
c 2.2.3. ==> description de la face 3
c
          f3 = tritet(letetr,3)
          cf3 = cotrte(letetr,3)
c
c 2.2.3.1. ==> reperage des 4 triangles fils
c
          ff3 = filtri(f3)
          f1ff3 = ff3 + i1(cf3)
          f3ff3 = ff3 + i2(cf3)
          f5ff3 = ff3 + i3(cf3)
c
c 2.2.3.2. ==> reperage des 3 aretes internes
c
          a1ff3 = aretri(ff3,i1(cf3))
          a3ff3 = aretri(ff3,i2(cf3))
          a5ff3 = aretri(ff3,i3(cf3))
c
c 2.2.4. ==> description de la face 4
c
          f4 = tritet(letetr,4)
          cf4 = cotrte(letetr,4)
c
c 2.2.4.1. ==> reperage des 4 triangles fils
c
          ff4 = filtri(f4)
          f1ff4 = ff4 + i1(cf4)
          f2ff4 = ff4 + i2(cf4)
          f4ff4 = ff4 + i3(cf4)
c
c 2.2.4.2. ==> reperage des 3 aretes internes
c
          a1ff4 = aretri(ff4,i1(cf4))
          a2ff4 = aretri(ff4,i2(cf4))
          a4ff4 = aretri(ff4,i3(cf4))
c
c 2.3. ==> reperage des noeuds milieux des aretes
c
          as1n1 = aretri(f5ff3,i1(cf3))
          as1n2 = aretri(f6ff2,i1(cf2))
          as1n3 = aretri(f6ff2,i2(cf2))
          as2n4 = aretri(f6ff1,i1(cf1))
          as2n5 = aretri(f6ff1,i2(cf1))
          as3n6 = aretri(f5ff1,i3(cf1))
c
          n1 = somare(2,as1n1)
          n2 = somare(2,as1n2)
          n3 = somare(2,as1n3)
          n4 = somare(2,as2n4)
          n5 = somare(2,as2n5)
          n6 = somare(2,as3n6)
c
c 2.4. ==> calcul des longueurs des diagonales et choix
c          de la plus petite
c
          xdiag = coonoe(n1,1) - coonoe(n6,1)
          ydiag = coonoe(n1,2) - coonoe(n6,2)
          zdiag = coonoe(n1,3) - coonoe(n6,3)
          long16 = xdiag * xdiag + ydiag * ydiag + zdiag * zdiag
          xdiag = coonoe(n2,1) - coonoe(n5,1)
          ydiag = coonoe(n2,2) - coonoe(n5,2)
          zdiag = coonoe(n2,3) - coonoe(n5,3)
          long25 = xdiag * xdiag + ydiag * ydiag + zdiag * zdiag
          xdiag = coonoe(n3,1) - coonoe(n4,1)
          ydiag = coonoe(n3,2) - coonoe(n4,2)
          zdiag = coonoe(n3,3) - coonoe(n4,3)
          long34 = xdiag * xdiag + ydiag * ydiag + zdiag * zdiag
c
          if ( long16 .le. long25 ) then
            if ( long16 .le. long34 ) then
              nudiag = 16
              typdia = 5
            else
              nudiag = 34
              typdia = 7
            endif
          else
            if ( long25 .le. long34 ) then
              nudiag = 25
              typdia = 6
            else
              nudiag = 34
              typdia = 7
            endif
          endif
c
c 2.5. ==> creation de l'arete diagonale
c
          adiag = indare + 1
          indare = adiag
c
          if ( nudiag .eq. 16 ) then
            somare(1,adiag) = min ( n1 , n6 )
            somare(2,adiag) = max ( n1 , n6 )
          elseif ( nudiag .eq. 25 ) then
            somare(1,adiag) = min ( n2 , n5 )
            somare(2,adiag) = max ( n2 , n5 )
          else
            somare(1,adiag) = min ( n3 , n4 )
            somare(2,adiag) = max ( n3 , n4 )
          endif
c
          famare(adiag) = 1
c
          hetare(adiag) = 50
          merare(adiag) = 0
          filare(adiag) = 0
c
c 2.6. ==> creation des faces
c
c 2.6.1. ==> recuperation du niveau commun a tous les triangles fils
c
          niveau = nivtri(ff1)
c
c 2.6.2. ==> creation des 4 faces d'angle
c
          fparf1 = indtri + 1
          call cmctri ( aretri, famtri, hettri,
     >                  filtri, pertri, nivtri,
     >                  fparf1, a4ff4, a5ff3, a6ff2,
     >                  cf1, niveau )
c
          fparf2 = indtri + 2
          call cmctri ( aretri, famtri, hettri,
     >                  filtri, pertri, nivtri,
     >                  fparf2, a2ff4, a3ff3, a6ff1,
     >                  cf2, niveau )
c
          fparf3 = indtri + 3
          call cmctri ( aretri, famtri, hettri,
     >                  filtri, pertri, nivtri,
     >                  fparf3, a1ff4, a3ff2, a5ff1,
     >                  cf3, niveau )
c
          fparf4 = indtri + 4
          call cmctri ( aretri, famtri, hettri,
     >                  filtri, pertri, nivtri,
     >                  fparf4, a1ff3, a2ff2, a4ff1,
     >                  cf4, niveau )
c
c 2.6.3 ==> creation des 4 faces internes en fonction de la diagonale
c
c         tous ces triangles sont crees avec le code arbitraire 1
c         et avec le meme niveau que les nouvelles 4 faces d'angle
c
          codefa = 1
c
          if ( nudiag .eq. 16 ) then
c
            fd16n2 = indtri + 5
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd16n2, adiag, a3ff2, a4ff4,
     >                    codefa, niveau )
c
            fd16n3 = indtri + 6
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd16n3, adiag, a2ff2, a5ff3,
     >                    codefa, niveau )
c
            fd16n4 = indtri + 7
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd16n4, adiag, a2ff4, a5ff1,
     >                    codefa, niveau )
c
            fd16n5 = indtri + 8
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd16n5, adiag, a3ff3, a4ff1,
     >                    codefa, niveau )
c
            indtri = fd16n5
c
          elseif ( nudiag .eq. 25 ) then
c
            fd25n1 = indtri + 5
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd25n1, adiag, a3ff3, a4ff4,
     >                    codefa, niveau )
c
            fd25n3 = indtri + 6
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd25n3, a1ff3, adiag, a6ff2,
     >                    codefa, niveau )
c
            fd25n4 = indtri + 7
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd25n4, adiag, a1ff4, a6ff1,
     >                    codefa, niveau )
c
            fd25n6 = indtri + 8
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd25n6, a3ff2, adiag, a4ff1,
     >                    codefa, niveau )
c
            indtri = fd25n6
c
          else
c
            fd34n1 = indtri + 5
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd34n1, adiag, a5ff3, a2ff4,
     >                    codefa, niveau )
c
            fd34n2 = indtri + 6
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd34n2, adiag, a1ff4, a6ff2,
     >                    codefa, niveau )
c
            fd34n5 = indtri + 7
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd34n5, a1ff3, adiag, a6ff1,
     >                    codefa, niveau )
c
            fd34n6 = indtri + 8
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd34n6, a2ff2, adiag, a5ff1,
     >                    codefa, niveau )
c
            indtri = fd34n6
c
          endif
c
c 2.7. ==> creation des tetraedres
c
          iaux = famtet(letetr)
c
c 2.7.1. ==> creation des 4 tetraedres d'angle
c
          tparf1 = indtet + 1
          call cmctet ( tritet, cotrte, famtet,
     >                  hettet, filtet, pertet,
     >                  fparf1, f6ff2,  f5ff3,  f4ff4,
     >                  cf1,    cf2,    cf3,    cf4,
     >                  letetr, iaux, tparf1 )
c
          tparf2 = indtet + 2
          call cmctet ( tritet, cotrte, famtet,
     >                  hettet, filtet, pertet,
     >                  f6ff1,  fparf2, f3ff3,  f2ff4,
     >                  cf1,    cf2,    cf3,    cf4,
     >                  letetr, iaux, tparf2 )
c
          tparf3 = indtet + 3
          call cmctet ( tritet, cotrte, famtet,
     >                  hettet, filtet, pertet,
     >                  f5ff1,  f3ff2,  fparf3, f1ff4,
     >                  cf1,    cf2,    cf3,    cf4,
     >                  letetr, iaux, tparf3 )
c
          tparf4 = indtet + 4
          call cmctet ( tritet, cotrte, famtet,
     >                  hettet, filtet, pertet,
     >                  f4ff1,  f2ff2,  f1ff3,  fparf4,
     >                  cf1,    cf2,    cf3,    cf4,
     >                  letetr, iaux, tparf4 )
c
c 2.7.2. ==> creation des 4 tetraedres internes en fonction
c            de la diagonale
c
          if ( nudiag .eq. 16 ) then
c ancien 1
            t16ff1 = indtet + 5
            codef1 = cf1
            codef2 = perm3(cf2)
            codef3 = 1
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    ff1,    fparf2, fd16n4, fd16n5,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t16ff1 )
c ancien 3
            t16ff3 = indtet + 7
            codef1 = 3
            codef2 = 5
            codef3 = cf3
            codef4 = perm1(cf4)
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd16n3, fd16n5, ff3,    fparf4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t16ff3 )
c ancien 2
            t16ff2 = indtet + 6
            codef1 = perm3(cf1)
            codef2 = cf2
            codef3 = 1
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fparf1, ff2,    fd16n2, fd16n3,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t16ff2 )
c ancien 4
            t16ff4 = indtet + 8
            codef1 = 5
            codef2 = 3
            codef3 = perm1(cf3)
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd16n2, fd16n4, fparf3, ff4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t16ff4 )
c
            indtet = t16ff4
c
          elseif ( nudiag .eq. 25 ) then
c
            t25ff1 = indtet + 5
            codef1 = cf1
            codef2 = 1
            codef3 = perm3(cf3)
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    ff1,    fd25n4, fparf3, fd25n6,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t25ff1 )
c
            t25ff2 = indtet + 6
            codef1 = 1
            codef2 = cf2
            codef3 = 2
            codef4 = perm2(cf4)
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd25n3, ff2,    fd25n6, fparf4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t25ff2 )
c
            t25ff3 = indtet + 7
            codef1 = perm2(cf1)
            codef2 = 1
            codef3 = cf3
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fparf1, fd25n1, ff3,    fd25n3,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t25ff3 )
c
            t25ff4 = indtet + 8
            codef1 = 2
            codef2 = perm1(cf2)
            codef3 = 3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd25n1, fparf2, fd25n4, ff4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t25ff4 )
c
            indtet = t25ff4
c
          else
c ancien 1
            t34ff1 = indtet + 5
            codef1 = cf1
            codef2 = 1
            codef3 = 1
            codef4 = perm3(cf4)
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    ff1,    fd34n5, fd34n6, fparf4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t34ff1 )
c ancien 2
            t34ff2 = indtet + 6
            codef1 = 1
            codef2 = cf2
            codef3 = perm2(cf3)
            codef4 = 2
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd34n2, ff2,    fparf3, fd34n6,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t34ff2 )
c ancien 4
            t34ff4 = indtet + 8
            codef1 = perm1(cf1)
            codef2 = 2
            codef3 = 6
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fparf1, fd34n1, fd34n2, ff4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t34ff4 )
c ancien 3
            t34ff3 = indtet + 7
            codef1 = 1
            codef2 = perm2(cf2)
            codef3 = cf3
            codef4 = 4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd34n1, fparf2, ff3,    fd34n5,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr, iaux, t34ff3 )
c
            indtet = t34ff4
c
          endif
c
c 2.7.3. ==> mise a jour du tetredre courant et de son pere eventuel
c
          filtet(letetr) = tparf1
          hettet(letetr) = hettet(letetr) + 80 + typdia
          pere = pertet(letetr)
          if ( pere .ne. 0 ) then
            etat = hettet(pere)
            hettet(pere) = etat - mod(etat,100) + 99
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
