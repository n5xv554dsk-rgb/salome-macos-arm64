      subroutine cmcdte ( indare, indtri, indtet,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
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
c    Creation du Maillage - Conformite - Decoupage des TEtraedres
c    -           -          -            -             --
c ______________________________________________________________________
c
c but : decoupage en 2 et en 4 des tetraedres pour mise en conformite
c       remarque : on est forcement en 3d
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare .     . nouvar . famille des aretes                         .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nouvtf*4. code des 4 triangles des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
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
      parameter ( nompro = 'CMCDTE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "i1i2i3.h"
#include "demitr.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer indare, indtri, indtet
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer hettet(nouvte), tritet(nouvtf,4), cotrte(nouvtf,4)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer adiag, letetr
      integer nbfad2, nbfad4, fj
      integer etatfa(4)
      integer niveau, cf1, cf2, cf3, cf4, f1, f2, f3, f4
      integer codefa, codef1, codef2, codef3, codef4
      integer a1, a2, a3, a4, a5, a6
      integer a4ff1, a5ff1, a6ff1, a2ff2, a3ff2, a6ff2
      integer a1ff3, a3ff3, a5ff3, a1ff4, a2ff4, a4ff4
      integer as1n1, as1n2, as1n3, as1n4, as1n5, as1n6
      integer as2n1, as2n2, as2n3, as2n4, as2n5, as2n6
      integer as3n1, as3n2, as3n3, as3n4, as3n5, as3n6
      integer as4n1, as4n2, as4n3, as4n4, as4n5, as4n6
      integer ff1, ff2, ff3, ff4, n1, n2, n3, n4, n5, n6
      integer fa1n6, fa2n5, fa3n4, fa4n3, fa5n2, fa6n1
      integer fd16s1, fd16s2, fd16s3, fd16s4
      integer fd25s1, fd25s2, fd25s3, fd25s4
      integer fd34s1, fd34s2, fd34s3, fd34s4
      integer ff1d4, ff1d5, ff1d6, ff2d2, ff2d3, ff2d6
      integer ff3d1, ff3d3, ff3d5, ff4d1, ff4d2, ff4d4
      integer f4ff1, f5ff1, f6ff1, f2ff2, f3ff2, f6ff2
      integer f1ff3, f3ff3, f5ff3, f1ff4, f2ff4, f4ff4
      integer fpara1, fpara2, fpara3, fpara4, fpara5, fpara6
      integer ti0ff1, ti1ff1, ti2ff1, ti3ff1
      integer ti0ff2, ti1ff2, ti2ff2, ti3ff2
      integer ti0ff3, ti1ff3, ti2ff3, ti3ff3
      integer ti0ff4, ti1ff4, ti2ff4, ti3ff4
      integer ta1f1, ta1f2, ta2f1, ta2f3, ta3f1, ta3f4
      integer ta4f2, ta4f3, ta5f2, ta5f4, ta6f3, ta6f4
      integer td16a2, td16a3, td16a4, td16a5
      integer td25a1, td25a3, td25a4, td25a6
      integer td34a1, td34a2, td34a5, td34a6
c
      integer nbmess
      parameter ( nbmess = 10 )
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
      texte(1,4) ='(''Decoupage provisoire en '',a)'
      texte(1,5) ='(''Les decisions de decoupage des aretes du'')'
      texte(1,6) ='(''Les decisions de decoupage des faces du'')'
      texte(1,7) ='(''tetraedre numero'',i10,'' sont incoherentes.'')'
      texte(1,8) ='(''Arete'',i2,'' :'',i10,'' et historique :'',i10)'
      texte(1,9) =
     >'(42(''=''),/,''Arret premature, apres '',i9,'' problemes'')'
      texte(1,10) ='(i10,'' problemes ...'')'
c
      texte(2,4) ='(''Temporary splitting by '',a)'
      texte(2,5) ='(''Decisions for the edges of the'')'
      texte(2,6) ='(''Decisions for the faces of the'')'
      texte(2,7) ='(''tetrahedron #'',i10,S''do not match.'')'
      texte(2,8) ='(''Edge #'',i2,'' :'',i10,'' state :'',i10)'
      texte(2,9) =
     >'(42(''=''),/,''Anticipated stop, after '',i9,'' problems'')'
      texte(2,10) ='(i10,'' problems ...'')'
c
      codret = 0
c
c====
c 2. decoupage
c====
c
      do 200 , letetr = 1 , permte
c
       if ( mod(hettet(letetr),100).eq.0 ) then
c
c 2.1. ==> Recherche des etats des faces du tetraedre
c
cgn          write(ulsort,*) 'tetraedre ', letetr
          nbfad2 = 0
          nbfad4 = 0
          do 21 , jaux = 1 , 4
            fj = tritet(letetr,jaux)
            etatfa(jaux) = mod(hettri(fj),10)
cgn            write(ulsort,*) '. Etat de la ', jaux, '-ieme face :',
cgn     >                      etatfa(jaux), ' (face ', fj, ')'
            if ( etatfa(jaux).ge.1 .and. etatfa(jaux).le.3 ) then
              nbfad2 = nbfad2 + 1
            elseif ( etatfa(jaux).eq.4 ) then
              nbfad4 = nbfad4 + 1
            endif
   21     continue
c
c       reperage des 4 faces du tetraedre
c
        f1 = tritet(letetr,1)
        f2 = tritet(letetr,2)
        f3 = tritet(letetr,3)
        f4 = tritet(letetr,4)
c
c       recuperation des codes des 4 faces du tetraedre
c
        cf1 = cotrte(letetr,1)
        cf2 = cotrte(letetr,2)
        cf3 = cotrte(letetr,3)
        cf4 = cotrte(letetr,4)
c
c       famille du tetraedre
c
        iaux = famtet(letetr)
c
        if ( nbfad2.eq.3 .and. nbfad4.eq.1 ) then
c
c====
c 3. decoupage en 4 des tetraedres selon une face
c       . 1 face coupee en 4
c       . 3 autres faces coupees en 2
c====
c
          if ( etatfa(1).eq.4 ) then
c
c 3.1. decoupage a partir de la face 1
c
c 3.1.1. description des 4 faces du tetraedre
c
c 3.1.1.1. description de la face 1
c
c 3.1.1.1.1.reperage des 4 triangles fils
c
            ff1 = filtri(f1)
            f4ff1 = ff1 + i1(cf1)
            f5ff1 = ff1 + i2(cf1)
            f6ff1 = ff1 + i3(cf1)
c
c 3.1.1.1.2.reperage des 3 aretes internes
c
            a4ff1 = aretri(ff1,i1(cf1))
            a5ff1 = aretri(ff1,i2(cf1))
            a6ff1 = aretri(ff1,i3(cf1))
c
c 3.1.1.2. description de la face 2
c
c 3.1.1.2.1.reperage des 2 triangles fils
c
            ff2d2 = filtri(f2) + nutrde(i3(cf2),i1(cf2))
            ff2d3 = filtri(f2) + nutrde(i3(cf2),i2(cf2))
c
c 3.1.1.2.2.reperage de l'arete interne
c
            as1n6 = aretri(ff2d2,i2(cf2))
c
c 3.1.1.3. description de la face 3
c
c 3.1.1.3.1.reperage des 2 triangles fils
c
            ff3d1 = filtri(f3) + nutrde(i3(cf3),i1(cf3))
            ff3d3 = filtri(f3) + nutrde(i3(cf3),i2(cf3))
c
c 3.1.1.3.2.reperage de l'arete interne
c
            as1n5 = aretri(ff3d1,i2(cf3))
c
c 3.1.1.4. description de la face 4
c
c 3.1.1.4.1.reperage des 2 triangles fils
c
            ff4d1 = filtri(f4) + nutrde(i3(cf4),i1(cf4))
            ff4d2 = filtri(f4) + nutrde(i3(cf4),i2(cf4))
c
c 3.1.1.4.2.reperage de l'arete interne
c
            as1n4 = aretri(ff4d1,i2(cf4))
c
c 3.1.2. creation des 3 faces internes
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff1)
            codefa = 1
c
            fpara4 = indtri + 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara4, as1n6,  as1n5,  a4ff1,
     >                    codefa, niveau )
c
            fpara5 = indtri + 2
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara5, as1n6,  as1n4,  a5ff1,
     >                    codefa, niveau )
c
            fpara6 = indtri + 3
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara6, as1n5,  as1n4,  a6ff1,
     >                    codefa, niveau )
c
            indtri = fpara6
c
c 3.1.3. creation des tetraedres
c
            ti0ff1 = indtet + 1
            codef1 = cf1
            codef2 = 1
            codef3 = 1
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                       ff1, fpara6, fpara5, fpara4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti0ff1 )
c
            ti1ff1 = indtet + 2
            codef1 = cf1
            codef2 = cf2
            codef3 = cf3
            codef4 = 6
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     f4ff1,  ff2d3,  ff3d3, fpara4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti1ff1 )
c
            ti2ff1 = indtet + 3
            codef1 = cf1
            codef2 = cf2
            codef3 = 6
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     f5ff1,  ff2d2, fpara5,  ff4d2,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti2ff1 )
c
            ti3ff1 = indtet + 4
            codef1 = cf1
            codef2 = 6
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     f6ff1, fpara6,  ff3d1,  ff4d1,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti3ff1 )
c
            indtet = ti3ff1
c
c 3.1.4. mise a jour du tetredre courant
c
          filtet(letetr) = ti0ff1
          hettet(letetr) = hettet(letetr) + 41
c
c
          elseif ( etatfa(2).eq.4 ) then
c
c 3.2. decoupage a partir de la face 2
c
c 3.2.1. description des 4 faces du tetraedre
c
c 3.2.1.1. description de la face 1
c
c 3.2.1.1.1.reperage des 2 triangles fils
c
            ff1d4 = filtri(f1) + nutrde(i3(cf1),i1(cf1))
            ff1d5 = filtri(f1) + nutrde(i3(cf1),i2(cf1))
c
c 3.2.1.1.2.reperage de l'arete interne
c
            as2n6 = aretri(ff1d4,i2(cf1))
c
c 3.2.1.2. description de la face 2
c
c 3.2.1.2.1.reperage des 4 triangles fils
c
            ff2 = filtri(f2)
            f2ff2 = ff2 + i1(cf2)
            f3ff2 = ff2 + i2(cf2)
            f6ff2 = ff2 + i3(cf2)
c
c 3.2.1.2.2.reperage des 3 aretes internes
c
            a2ff2 = aretri(ff2,i1(cf2))
            a3ff2 = aretri(ff2,i2(cf2))
            a6ff2 = aretri(ff2,i3(cf2))
c
c 3.2.1.3. description de la face 3
c
c 3.2.1.3.1.reperage des 2 triangles fils
c
            ff3d1 = filtri(f3) + nutrde(i2(cf3),i1(cf3))
            ff3d5 = filtri(f3) + nutrde(i2(cf3),i3(cf3))
c
c 3.2.1.3.2.reperage de l'arete interne
c
            as2n3 = aretri(ff3d1,i3(cf3))
c
c 3.2.1.4. description de la face 4
c
c 3.2.1.4.1.reperage des 2 triangles fils
c
            ff4d1 = filtri(f4) + nutrde(i2(cf4),i1(cf4))
            ff4d4 = filtri(f4) + nutrde(i2(cf4),i3(cf4))
c
c 3.2.1.4.2.reperage de l'arete interne
c
            as2n2 = aretri(ff4d1,i3(cf4))
c
c 3.2.2. creation des 3 faces internes
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff2)
            codefa = 1
c
            fpara2 = indtri + 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara2, as2n6,  a2ff2,  as2n3,
     >                    codefa, niveau )
c
            fpara3 = indtri + 2
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara3, as2n6,  a3ff2,  as2n2,
     >                    codefa, niveau )
c
            fpara6 = indtri + 3
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara6, as2n3,  as2n2,  a6ff2,
     >                    codefa, niveau )
c
            indtri = fpara6
c
c 3.2.3. creation des tetraedres
c
            ti0ff2 = indtet + 1
            codef1 = 1
            codef2 = cf2
            codef3 = 1
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fpara6,    ff2, fpara3, fpara2,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti0ff2 )
c
            ti1ff2 = indtet + 2
            codef1 = cf1
            codef2 = cf2
            codef3 = cf3
            codef4 = 5
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d5,  f2ff2,  ff3d5, fpara2,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti1ff2 )
c
            ti2ff2 = indtet + 3
            codef1 = cf1
            codef2 = cf2
            codef3 = 5
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d4,  f3ff2, fpara3,  ff4d4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti2ff2 )
c
            ti3ff2 = indtet + 4
            codef1 = 6
            codef2 = cf2
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fpara6,  f6ff2,  ff3d1,  ff4d1,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti3ff2 )
c
            indtet = ti3ff2
c
c 3.2.4. mise a jour du tetredre courant
c
          filtet(letetr) = ti0ff2
          hettet(letetr) = hettet(letetr) + 42
c
c
          elseif ( etatfa(3).eq.4 ) then
c
c 3.3. decoupage a partir de la face 3
c
c 3.3.1. description des 4 faces du tetraedre
c
c 3.3.1.1. description de la face 1
c
c 3.3.1.1.1.reperage des 2 triangles fils
c
            ff1d4 = filtri(f1) + nutrde(i2(cf1),i1(cf1))
            ff1d6 = filtri(f1) + nutrde(i2(cf1),i3(cf1))
c
c 3.3.1.1.2.reperage de l'arete interne
c
            as3n5 = aretri(ff1d4,i3(cf1))
c
c 3.3.1.2. description de la face 2
c
c 3.3.1.2.1.reperage des 2 triangles fils
c
            ff2d2 = filtri(f2) + nutrde(i2(cf2),i1(cf2))
            ff2d6 = filtri(f2) + nutrde(i2(cf2),i3(cf2))
c
c 3.3.1.2.2.reperage de l'arete interne
c
            as3n3 = aretri(ff2d2,i3(cf2))
c
c 3.3.1.3. description de la face 3
c
c 3.3.1.3.1.reperage des 4 triangles fils
c
            ff3 = filtri(f3)
            f1ff3 = ff3 + i1(cf3)
            f3ff3 = ff3 + i2(cf3)
            f5ff3 = ff3 + i3(cf3)
c
c 3.3.1.3.2.reperage des 3 aretes internes
c
            a1ff3 = aretri(ff3,i1(cf3))
            a3ff3 = aretri(ff3,i2(cf3))
            a5ff3 = aretri(ff3,i3(cf3))
c
c 3.3.1.4. description de la face 4
c
c 3.3.1.4.1.reperage des 2 triangles fils
c
            ff4d2 = filtri(f4) + nutrde(i1(cf4),i2(cf4))
            ff4d4 = filtri(f4) + nutrde(i1(cf4),i3(cf4))
c
c 3.3.1.4.2.reperage de l'arete interne
c
            as3n1 = aretri(ff4d2,i3(cf4))
c
c 3.3.2. creation des 3 faces internes
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff3)
            codefa = 1
c
            fpara1 = indtri + 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara1, a1ff3,  as3n5,  as3n3,
     >                    codefa, niveau )
c
            fpara3 = indtri + 2
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara3, as3n5,  a3ff3,  as3n1,
     >                    codefa, niveau )
c
            fpara5 = indtri + 3
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara5, as3n3,  a5ff3,  as3n1,
     >                    codefa, niveau )
c
            indtri = fpara5
c
c 3.3.3. creation des tetraedres
c
            ti0ff3 = indtet + 1
            codef1 = 1
            codef2 = 1
            codef3 = cf3
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fpara5, fpara3,    ff3, fpara1,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti0ff3 )
c
            ti1ff3 = indtet + 2
            codef1 = cf1
            codef2 = cf2
            codef3 = cf3
            codef4 = 4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d6,  ff2d6,  f1ff3, fpara1,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti1ff3 )
c
            ti2ff3 = indtet + 3
            codef1 = cf1
            codef2 = 5
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d4, fpara3,  f3ff3,  ff4d4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti2ff3 )
c
            ti3ff3 = indtet + 4
            codef1 = 5
            codef2 = cf2
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fpara5,  ff2d2,  f5ff3,  ff4d2,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti3ff3 )
c
            indtet = ti3ff3
c
c 3.3.4. mise a jour du tetredre courant
c
          filtet(letetr) = ti0ff3
          hettet(letetr) = hettet(letetr) + 43
c
c
          elseif ( etatfa(4).eq.4 ) then
c
c 3.4. decoupage a partir de la face 4
c
c 3.4.1. description des 4 faces du tetraedre
c
c 3.4.1.1. description de la face 1
c
c 3.4.1.1.1.reperage des 2 triangles fils
c
            ff1d5 = filtri(f1) + nutrde(i1(cf1),i2(cf1))
            ff1d6 = filtri(f1) + nutrde(i1(cf1),i3(cf1))
c
c 3.4.1.1.2.reperage de l'arete interne
c
            as4n4 = aretri(ff1d5,i3(cf1))
c
c 3.4.1.2. description de la face 2
c
c 3.4.1.2.1.reperage des 2 triangles fils
c
            ff2d3 = filtri(f2) + nutrde(i1(cf2),i2(cf2))
            ff2d6 = filtri(f2) + nutrde(i1(cf2),i3(cf2))
c
c 3.4.1.2.2.reperage de l'arete interne
c
            as4n2 = aretri(ff2d3,i3(cf2))
c
c 3.4.1.3. description de la face 3
c
c 3.4.1.3.1.reperage des 2 triangles fils
c
            ff3d3 = filtri(f3) + nutrde(i1(cf3),i2(cf3))
            ff3d5 = filtri(f3) + nutrde(i1(cf3),i3(cf3))
c
c 3.4.1.3.2.reperage de l'arete interne
c
            as4n1 = aretri(ff3d3,i3(cf3))
c
c 3.4.1.4.  description de la face 4
c
c 3.4.1.4.1.reperage des 4 triangles fils
c
            ff4 = filtri(f4)
            f1ff4 = ff4 + i1(cf4)
            f2ff4 = ff4 + i2(cf4)
            f4ff4 = ff4 + i3(cf4)
c
c 3.4.1.4.2.reperage des 3 aretes internes
c
            a1ff4 = aretri(ff4,i1(cf4))
            a2ff4 = aretri(ff4,i2(cf4))
            a4ff4 = aretri(ff4,i3(cf4))
c
c 3.4.2. creation des 3 faces internes
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff4)
            codefa = 1
c
            fpara1 = indtri + 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara1, a1ff4,  as4n4,  as4n2,
     >                    codefa, niveau )
c
            fpara2 = indtri + 2
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara2, a2ff4,  as4n4,  as4n1,
     >                    codefa, niveau )
c
            fpara4 = indtri + 3
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fpara4, a4ff4,  as4n2,  as4n1,
     >                    codefa, niveau )
c
            indtri = fpara4
c
c 3.4.3. creation des tetraedres
c
            ti0ff4 = indtet + 1
            codef1 = 1
            codef2 = 1
            codef3 = 1
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fpara4, fpara2, fpara1,    ff4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti0ff4 )
c
            ti1ff4 = indtet + 2
            codef1 = cf1
            codef2 = cf2
            codef3 = 4
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d6,  ff2d6, fpara1,  f1ff4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti1ff4 )
c
            ti2ff4 = indtet + 3
            codef1 = cf1
            codef2 = 4
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d5, fpara2,  ff3d5,  f2ff4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti2ff4 )
c
            ti3ff4 = indtet + 4
            codef1 = 4
            codef2 = cf2
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fpara4,  ff2d3,  ff3d3,  f4ff4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ti3ff4 )
c
            indtet = ti3ff4
c
c 3.4.4. mise a jour du tetredre courant
c
            filtet(letetr) = ti0ff4
            hettet(letetr) = hettet(letetr) + 44
c
c
          else
c
            write (ulsort,texte(langue,4)) '4'
            write (ulsort,texte(langue,6))
            write (ulsort,texte(langue,7)) letetr
c
            codret = codret + 1
c
          endif
c
        elseif ( nbfad2.eq.4 .and. nbfad4.eq.0 ) then
c
c====
c 4. Decoupage en 4 des tetraedres selon 2 aretes en vis-a-vis
c       . 0 face coupee en 4
c       . 4 autres faces coupees en 2
c====
c
c 4.1. recuperation des 6 aretes du tetraedre
c
          a1  = aretri(f3,i1(cf3))
          a2  = aretri(f2,i1(cf2))
          a3  = aretri(f2,i2(cf2))
          a4  = aretri(f1,i1(cf1))
          a5  = aretri(f1,i2(cf1))
          a6  = aretri(f1,i3(cf1))
c
          if ( mod(hetare(a1),10).eq.2 .and.
     >         mod(hetare(a6),10).eq.2 ) then
c
c 4.2. decoupage a partir de la diagonale n1-n6
c
c 4.2.1. description des 4 faces decoupees
c
c 4.2.1.1. description de la face 1
c
c 4.2.1.1.1.reperage des 2 triangles fils
c
            ff1d4 = filtri(f1) + nutrde(i3(cf1),i1(cf1))
            ff1d5 = filtri(f1) + nutrde(i3(cf1),i2(cf1))
c
c 4.2.1.1.2.reperage de l'arete interne
c
            as2n6 = aretri(ff1d4,i2(cf1))
c
c 4.2.1.2. description de la face 2
c
c 4.2.1.2.1.reperage des 2 triangles fils
c
            ff2d2 = filtri(f2) + nutrde(i3(cf2),i1(cf2))
            ff2d3 = filtri(f2) + nutrde(i3(cf2),i2(cf2))
c
c 4.2.1.2.2.reperage de l'arete interne
c
            as1n6 = aretri(ff2d2,i2(cf2))
c
c 4.2.1.3. description de la face 3
c
c 4.2.1.3.1.reperage des 2 triangles fils
c
            ff3d3 = filtri(f3) + nutrde(i1(cf3),i2(cf3))
            ff3d5 = filtri(f3) + nutrde(i1(cf3),i3(cf3))
c
c 4.2.1.3.2.reperage de l'arete interne
c
            as4n1 = aretri(ff3d3,i3(cf3))
c
c 4.2.1.4. description de la face 4
c
c 4.2.1.4.1.reperage des 2 triangles fils
c
            ff4d2 = filtri(f4) + nutrde(i1(cf4),i2(cf4))
            ff4d4 = filtri(f4) + nutrde(i1(cf4),i3(cf4))
c
c 4.2.1.4.2.reperage de l'arete interne
c
            as3n1 = aretri(ff4d2,i3(cf4))
c
c 4.2.2. reperage des aretes filles
c
            as1n1 = aretri(ff3d3,i1(cf3))
            as2n1 = aretri(ff3d5,i1(cf3))
            as3n6 = aretri(ff1d4,i3(cf1))
            as4n6 = aretri(ff2d3,i3(cf2))
c
c 4.2.3. reperage des noeuds milieux des 2 aretes coupees
c
            n1 = somare(2,as1n1)
            n6 = somare(2,as3n6)
c
c 4.2.4. creation de l'arete diagonale
c
            adiag = indare + 1
            indare = adiag
c
            somare(1,adiag) = min ( n1 , n6 )
            somare(2,adiag) = max ( n1 , n6 )
c
            famare(adiag) = 1
c
            hetare(adiag) = 50
            merare(adiag) = 0
            filare(adiag) = 0
c
c 4.2.5. creation des 4 faces internes
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff1d4)
            codefa = 1
c
            fd16s1 = indtri + 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd16s1, as1n1,  as1n6,  adiag,
     >                    codefa, niveau )
c
            fd16s2 = indtri + 2
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd16s2, as2n1,  adiag,  as2n6,
     >                    codefa, niveau )
c
            fd16s3 = indtri + 3
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd16s3, as3n1,  adiag,  as3n6,
     >                    codefa, niveau )
c
            fd16s4 = indtri + 4
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd16s4, adiag,  as4n1,  as4n6,
     >                    codefa, niveau )
c
            indtri = fd16s4
c
c 4.2.6. creation des 4 tetraedres
c
            td16a2 = indtet + 1
            codef1 = 1
            codef2 = cf2
            codef3 = 1
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd16s3,  ff2d2, fd16s1,  ff4d2,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td16a2 )
c
            td16a3 = indtet + 2
            codef1 = 1
            codef2 = cf2
            codef3 = cf3
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd16s4,  ff2d3,  ff3d3, fd16s1,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td16a3 )
c
            td16a4 = indtet + 3
            codef1 = cf1
            codef2 = 1
            codef3 = 1
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d4, fd16s3, fd16s2,  ff4d4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td16a4 )
c
            td16a5 = indtet + 4
            codef1 = cf1
            codef2 = 1
            codef3 = cf3
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d5, fd16s4,  ff3d5, fd16s2,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td16a5 )
c
            indtet = td16a5
c
c 4.2.7. mise a jour du tetredre courant
c
            filtet(letetr) = td16a2
            hettet(letetr) = hettet(letetr) + 45
c
c
          elseif ( mod(hetare(a2),10).eq.2 .and.
     >             mod(hetare(a5),10).eq.2 ) then
c
c 4.3. decoupage a partir de la diagonale n2-n5
c
c 4.3.1. description des 4 faces decoupees
c
c 4.3.1.1. description de la face 1
c
c 4.3.1.1.1.reperage des 2 triangles fils
c
            ff1d4 = filtri(f1) + nutrde(i2(cf1),i1(cf1))
            ff1d6 = filtri(f1) + nutrde(i2(cf1),i3(cf1))
c
c 4.3.1.1.2.reperage de l'arete interne
c
            as3n5 = aretri(ff1d4,i3(cf1))
c
c 4.3.1.2. description de la face 2
c
c 4.3.1.2.1.reperage des 2 triangles fils
c
            ff2d3 = filtri(f2) + nutrde(i1(cf2),i2(cf2))
            ff2d6 = filtri(f2) + nutrde(i1(cf2),i3(cf2))
c
c 4.3.1.2.2.reperage de l'arete interne
c
            as4n2 = aretri(ff2d3,i3(cf2))
c
c 4.3.1.3. description de la face 3
c
c 4.3.1.3.1.reperage des 2 triangles fils
c
            ff3d1 = filtri(f3) + nutrde(i3(cf3),i1(cf3))
            ff3d3 = filtri(f3) + nutrde(i3(cf3),i2(cf3))
c
c 4.3.1.3.2.reperage de l'arete interne
c
            as1n5 = aretri(ff3d1,i2(cf3))
c
c 4.3.1.4. description de la face 4
c
c 4.3.1.4.1.reperage des 2 triangles fils
c
            ff4d1 = filtri(f4) + nutrde(i2(cf4),i1(cf4))
            ff4d4 = filtri(f4) + nutrde(i2(cf4),i3(cf4))
c
c 4.3.1.4.2.reperage de l'arete interne
c
            as2n2 = aretri(ff4d1,i3(cf4))
c
c 4.3.2. reperage des aretes filles
c
            as1n2 = aretri(ff2d3,i1(cf2))
            as2n5 = aretri(ff3d1,i3(cf3))
            as3n2 = aretri(ff2d6,i1(cf2))
            as4n5 = aretri(ff1d6,i2(cf1))
c
c 4.3.3. reperage des noeuds milieux des 2 aretes coupees
c
            n2 = somare(2,as1n2)
            n5 = somare(2,as2n5)
c
c 4.3.4. creation de l'arete diagonale
c
            adiag = indare + 1
            indare = adiag
c
            somare(1,adiag) = min ( n2 , n5 )
            somare(2,adiag) = max ( n2 , n5 )
c
            famare(adiag) = 1
c
            hetare(adiag) = 50
            merare(adiag) = 0
            filare(adiag) = 0
c
c 4.3.5. creation des 4 faces internes
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff1d4)
            codefa = 1
c
            fd25s1 = indtri + 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd25s1, as1n2,  as1n5,  adiag,
     >                    codefa, niveau )
c
            fd25s2 = indtri + 2
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd25s2, as2n2,  as2n5,  adiag,
     >                    codefa, niveau )
c
            fd25s3 = indtri + 3
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd25s3, as3n2,  adiag,  as3n5,
     >                    codefa, niveau )
c
            fd25s4 = indtri + 4
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd25s4, adiag,  as4n5,  as4n2,
     >                    codefa, niveau )
c
            indtri = fd25s4
c
c 4.3.6. creation des 4 tetraedres
c
            td25a1 = indtet + 1
            codef1 = 1
            codef2 = 1
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd25s2, fd25s1,  ff3d1,  ff4d1,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td25a1 )
c
            td25a3 = indtet + 2
            codef1 = 1
            codef2 = cf2
            codef3 = cf3
            codef4 = 6
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd25s4,  ff2d3,  ff3d3, fd25s1,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td25a3 )
c
            td25a4 = indtet + 3
            codef1 = cf1
            codef2 = 1
            codef3 = 4
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d4, fd25s3, fd25s2,  ff4d4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td25a4 )
c
            td25a6 = indtet + 4
            codef1 = cf1
            codef2 = cf2
            codef3 = 4
            codef4 = 6
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d6,  ff2d6, fd25s4, fd25s3,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td25a6 )
c
            indtet = td25a6
c
c 4.3.7. mise a jour du tetredre courant
c
            filtet(letetr) = td25a1
            hettet(letetr) = hettet(letetr) + 46
c
c
          elseif ( mod(hetare(a3),10).eq.2 .and.
     >             mod(hetare(a4),10).eq.2 ) then
c
c 4.4. decoupage a partir de la diagonale n3-n4
c
c
c 4.4.1. description des 4 faces decoupees
c
c 4.4.1.1. description de la face 1
c
c 4.4.1.1.1.reperage des 2 triangles fils
c
            ff1d5 = filtri(f1) + nutrde(i1(cf1),i2(cf1))
            ff1d6 = filtri(f1) + nutrde(i1(cf1),i3(cf1))
c
c 4.4.1.1.2.reperage de l'arete interne
c
            as4n4 = aretri(ff1d5,i3(cf1))
c
c 4.4.1.2. description de la face 2
c
c 4.4.1.2.1.reperage des 2 triangles fils
c
            ff2d2 = filtri(f2) + nutrde(i2(cf2),i1(cf2))
            ff2d6 = filtri(f2) + nutrde(i2(cf2),i3(cf2))
c
c 4.4.1.2.2.reperage de l'arete interne
c
            as3n3 = aretri(ff2d2,i3(cf2))
c
c 4.4.1.3. description de la face 3
c
c 4.4.1.3.1.reperage des 2 triangles fils
c
            ff3d1 = filtri(f3) + nutrde(i2(cf3),i1(cf3))
            ff3d5 = filtri(f3) + nutrde(i2(cf3),i3(cf3))
c
c 4.4.1.3.2.reperage de l'arete interne
c
            as2n3 = aretri(ff3d1,i3(cf3))
c
c 4.4.1.4. description de la face 4
c
c 4.4.1.4.1.reperage des 2 triangles fils
c
            ff4d1 = filtri(f4) + nutrde(i3(cf4),i1(cf4))
            ff4d2 = filtri(f4) + nutrde(i3(cf4),i2(cf4))
c
c 4.4.1.4.2.reperage de l'arete interne
c
            as1n4 = aretri(ff4d1,i2(cf4))
c
c 4.4.2. reperage des aretes filles
c
            as1n3 = aretri(ff3d1,i2(cf3))
            as2n4 = aretri(ff4d1,i3(cf4))
            as3n4 = aretri(ff4d2,i3(cf4))
            as4n3 = aretri(ff2d6,i2(cf2))
c
c 4.4.3. reperage des noeuds milieux des 2 aretes coupees
c
            n3 = somare(2,as1n3)
            n4 = somare(2,as2n4)
c
c 4.4.4. creation de l'arete diagonale
c
            adiag = indare + 1
            indare = adiag
c
            somare(1,adiag) = min ( n3 , n4 )
            somare(2,adiag) = max ( n3 , n4 )
c
            famare(adiag) = 1
c
            hetare(adiag) = 50
            merare(adiag) = 0
            filare(adiag) = 0
c
c 4.4.5. creation des 4 faces internes
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff1d5)
            codefa = 1
c
            fd34s1 = indtri + 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd34s1, as1n4,  as1n3,  adiag,
     >                    codefa, niveau )
c
            fd34s2 = indtri + 2
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd34s2, as2n4,  as2n3,  adiag,
     >                    codefa, niveau )
c
            fd34s3 = indtri + 3
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd34s3, as3n4,  adiag,  as3n3,
     >                    codefa, niveau )
c
            fd34s4 = indtri + 4
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fd34s4, adiag,  as4n3,  as4n4,
     >                    codefa, niveau )
c
            indtri = fd34s4
c
c 4.4.6. creation des 4 tetraedres
c
            td34a1 = indtet + 1
            codef1 = 1
            codef2 = 1
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd34s2, fd34s1,  ff3d1,  ff4d1,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td34a1 )
c
            td34a2 = indtet + 2
            codef1 = 1
            codef2 = cf2
            codef3 = 1
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    fd34s3,  ff2d2, fd34s1,  ff4d2,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td34a2 )
c
            td34a5 = indtet + 3
            codef1 = cf1
            codef2 = 1
            codef3 = cf3
            codef4 = 3
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d5, fd34s4,  ff3d5, fd34s2,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td34a5 )
c
            td34a6 = indtet + 4
            codef1 = cf1
            codef2 = cf2
            codef3 = 1
            codef4 = 3
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d6,  ff2d6, fd34s4, fd34s3,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, td34a6 )
c
            indtet = td34a6
c
c 4.4.7. mise a jour du tetredre courant
c
            filtet(letetr) = td34a1
            hettet(letetr) = hettet(letetr) + 47
c
c
          else
c
            write (ulsort,texte(langue,4)) '2 fois 2'
            write (ulsort,texte(langue,5))
            write (ulsort,texte(langue,7)) letetr
            write(ulsort,10210)
     >                nouvar, nouvtr, nouvno, nouvp2, nouvim, nouvte,
     >                permar, permtr, permno, permp2, permim, permte,
     >                provar, provtr,         provp2, provim, provte
            write(ulsort,10201) f1, f2, f3, f4
            write(ulsort,10202) (etatfa(jaux),jaux=1,4)
            write(ulsort,10203) a1, a2, a3, a4, a5, a6
            write(ulsort,10202) hetare(a1), hetare(a2), hetare(a3),
     >                          hetare(a4), hetare(a5), hetare(a6)
10201 format(1x,'faces  : ',4i10)
10202 format(1x,'etats  : ',6i10)
10203 format(1x,'aretes : ',6i10)
10210 format(1x,
     >         /1x,'  nouvar, nouvtr, nouvno, nouvp2, nouvim, nouvte,',
     >         /1x,'  permar, permtr, permno, permp2, permim, permte,',
     >         /1x,'  provar, provtr,       , provp2, provim, provte',
     >         /1x,6i8,
     >         /1x,6i8,
     >         /1x,2i8,8x,3i8)
c
            codret = codret + 1
c
          endif
c
        elseif ( nbfad2.eq.2 .and. nbfad4.eq.0 ) then
c
c====
c 5. decoupage en 2 des tetraedres selon 1 arete
c       . 0 face coupee en 4
c       . 2 faces coupees en 2
c====
c
          if ( etatfa(3).gt.0 .and. etatfa(4).gt.0 ) then
c
c 5.1. decoupage a partir de l'arete 1
c
c 5.1.1. description des 2 faces decoupees
c
c 5.1.1.1. description de la face 3
c
c 5.1.1.1.1.reperage des 2 triangles fils
c
            ff3d3 = filtri(f3) + nutrde(i1(cf3),i2(cf3))
            ff3d5 = filtri(f3) + nutrde(i1(cf3),i3(cf3))
c
c 5.1.1.1.2.reperage de l'arete interne
c
            as4n1 = aretri(ff3d3,i3(cf3))
c
c 5.1.1.2. description de la face 4
c
c 5.1.1.2.1.reperage des 2 triangles fils
c
            ff4d2 = filtri(f4) + nutrde(i1(cf4),i2(cf4))
            ff4d4 = filtri(f4) + nutrde(i1(cf4),i3(cf4))
c
c 5.1.1.2.2.reperage de l'arete interne
c
            as3n1 = aretri(ff4d2,i3(cf4))
c
c 5.1.2. reperage de l'arete du tetraedre commune au deux fils
c
            a6 = aretri(f1,i3(cf1))
c
c 5.1.3. creation de la face interne
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff3d3)
c
            fa6n1 = indtri + 1
            indtri = fa6n1
            codefa = 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fa6n1,  as3n1,  as4n1,  a6,
     >                    codefa, niveau )
c
c 5.1.4. creation des tetraedres
c
            ta1f1 = indtet + 1
            codef1 = cf1
            codef2 = 1
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                        f1,  fa6n1,  ff3d5,  ff4d4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta1f1 )
c
            ta1f2 = indtet + 2
            codef1 = 1
            codef2 = cf2
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     fa6n1,     f2,  ff3d3,  ff4d2,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta1f2 )
c
            indtet = ta1f2
c
c 5.1.5. mise a jour du tetredre courant
c
            filtet(letetr) = ta1f1
            hettet(letetr) = hettet(letetr) + 21
c
c
          elseif ( etatfa(2).gt.0 .and. etatfa(4).gt.0 ) then
c
c 5.2. decoupage a partir de l'arete 2
c
c 5.2.1. description des 2 faces decoupees
c
c 5.2.1.1. description de la face 2
c
c 5.2.1.1.1.reperage des 2 triangles fils
c
            ff2d3 = filtri(f2) + nutrde(i1(cf2),i2(cf2))
            ff2d6 = filtri(f2) + nutrde(i1(cf2),i3(cf2))
c
c 5.2.1.1.2.reperage de l'arete interne
c
            as4n2 = aretri(ff2d3,i3(cf2))
c
c 5.2.1.2. description de la face 4
c
c 5.2.1.2.1.reperage des 2 triangles fils
c
            ff4d1 = filtri(f4) + nutrde(i2(cf4),i1(cf4))
            ff4d4 = filtri(f4) + nutrde(i2(cf4),i3(cf4))
c
c 5.2.1.2.2.reperage de l'arete interne
c
            as2n2 = aretri(ff4d1,i3(cf4))
c
c 5.2.2. reperage de l'arete du tetraedre commune au deux fils
c
            a5  = aretri(f1,i2(cf1))
c
c 5.2.3. creation de la face interne
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff2d3)
c
            fa5n2 = indtri + 1
            indtri = fa5n2
            codefa = 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fa5n2,  as2n2,  as4n2,  a5,
     >                    codefa, niveau )
c
c 5.2.4. creation des tetraedres
c
            ta2f1 = indtet + 1
            codef1 = cf1
            codef2 = cf2
            codef3 = 1
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                        f1,  ff2d6,  fa5n2,  ff4d4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta2f1 )
c
            ta2f3 = indtet + 2
            codef1 = 4
            codef2 = cf2
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     fa5n2,  ff2d3,     f3,  ff4d1,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta2f3 )
c
            indtet = ta2f3
c
c 5.2.5. mise a jour du tetredre courant
c
            filtet(letetr) = ta2f1
            hettet(letetr) = hettet(letetr) + 22
c
c
          elseif ( etatfa(2).gt.0 .and. etatfa(3).gt.0 ) then
c
c 5.3. decoupage a partir de l'arete 3
c
c 5.3.1. description des 2 faces decoupees
c
c 5.3.1.1. description de la face 2
c
c 5.3.1.1.1.reperage des 2 triangles fils
c
            ff2d2 = filtri(f2) + nutrde(i2(cf2),i1(cf2))
            ff2d6 = filtri(f2) + nutrde(i2(cf2),i3(cf2))
c
c 5.3.1.1.2.reperage de l'arete interne
c
            as3n3 = aretri(ff2d2,i3(cf2))
c
c 5.3.1.2. description de la face 3
c
c 5.3.1.2.1.reperage des 2 triangles fils
c
            ff3d1 = filtri(f3) + nutrde(i2(cf3),i1(cf3))
            ff3d5 = filtri(f3) + nutrde(i2(cf3),i3(cf3))
c
c 5.3.1.2.2.reperage de l'arete interne
c
            as2n3 = aretri(ff3d1,i3(cf3))
c
c 5.3.2. reperage de l'arete du tetraedre commune au deux fils
c
            a4  = aretri(f1,i1(cf1))
c
c 5.3.3. creation de la face interne
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff2d2)
c
            fa4n3 = indtri + 1
            indtri = fa4n3
            codefa = 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fa4n3,  as2n3,  as3n3,  a4,
     >                    codefa, niveau )
c
c 5.3.4. creation des tetraedres
c
            ta3f1 = indtet + 1
            codef1 = cf1
            codef2 = cf2
            codef3 = cf3
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                        f1,  ff2d6,  ff3d5,  fa4n3,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta3f1 )
c
            ta3f4 = indtet + 2
            codef1 = 2
            codef2 = cf2
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     fa4n3,  ff2d2,  ff3d1,     f4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta3f4 )
c
            indtet = ta3f4
c
c 5.3.5. mise a jour du tetredre courant
c
            filtet(letetr) = ta3f1
            hettet(letetr) = hettet(letetr) + 23
c
c
          elseif ( etatfa(1).gt.0 .and. etatfa(4).gt.0 ) then
c
c 5.4. decoupage a partir de l'arete 4
c
c 5.4.1. description des 2 faces decoupees
c
c 5.4.1.1. description de la face 1
c
c 5.4.1.1.1.reperage des 2 triangles fils
c
            ff1d5 = filtri(f1) + nutrde(i1(cf1),i2(cf1))
            ff1d6 = filtri(f1) + nutrde(i1(cf1),i3(cf1))
c
c 5.4.1.1.2.reperage de l'arete interne
c
            as4n4 = aretri(ff1d5,i3(cf1))
c
c 5.4.1.2. description de la face 4
c
c 5.4.1.2.1.reperage des 2 triangles fils
c
            ff4d1 = filtri(f4) + nutrde(i3(cf4),i1(cf4))
            ff4d2 = filtri(f4) + nutrde(i3(cf4),i2(cf4))
c
c 5.4.1.2.2.reperage de l'arete interne
c
            as1n4 = aretri(ff4d1,i2(cf4))
c
c 5.4.2. reperage de l'arete du tetraedre commune au deux fils
c
            a3  = aretri(f2,i2(cf2))
c
c 5.4.3. creation de la face interne
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff1d5)
c
            fa3n4 = indtri + 1
            indtri = fa3n4
            codefa = 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fa3n4,  as1n4,  a3,     as4n4,
     >                    codefa, niveau )
c
c 5.4.4. creation des tetraedres
c
            ta4f2 = indtet + 1
            codef1 = cf1
            codef2 = cf2
            codef3 = 1
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d6,     f2,  fa3n4,  ff4d2,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta4f2 )
c
            ta4f3 = indtet + 2
            codef1 = cf1
            codef2 = 1
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d5,  fa3n4,     f3,  ff4d1,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta4f3 )
c
            indtet = ta4f3
c
c 5.4.5. mise a jour du tetredre courant
c
            filtet(letetr) = ta4f2
            hettet(letetr) = hettet(letetr) + 24
c
c
          elseif ( etatfa(1).gt.0 .and. etatfa(3).gt.0 ) then
c
c 5.5. decoupage a partir de l'arete 5
c
c 5.5.1. description des 2 faces decoupees
c
c 5.5.1.1. description de la face 1
c
c 5.5.1.1.1.reperage des 2 triangles fils
c
            ff1d4 = filtri(f1) + nutrde(i2(cf1),i1(cf1))
            ff1d6 = filtri(f1) + nutrde(i2(cf1),i3(cf1))
c
c 5.5.1.1.2.reperage de l'arete interne
c
            as3n5 = aretri(ff1d4,i3(cf1))
c
c 5.5.1.2. description de la face 3
c
c 5.5.1.2.1.reperage des 2 triangles fils
c
            ff3d1 = filtri(f3) + nutrde(i3(cf3),i1(cf3))
            ff3d3 = filtri(f3) + nutrde(i3(cf3),i2(cf3))
c
c 5.5.1.2.2.reperage de l'arete interne
c
            as1n5 = aretri(ff3d1,i2(cf3))
c
c 5.5.2. reperage de l'arete du tetraedre commune au deux fils
c
            a2  = aretri(f2,i1(cf2))
c
c 5.5.3. creation de la face interne
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff1d4)
c
            fa2n5 = indtri + 1
            indtri = fa2n5
            codefa = 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fa2n5,  as1n5,  a2,     as3n5,
     >                    codefa, niveau )
c
c 5.5.4. creation des tetraedres
c
            ta5f2 = indtet + 1
            codef1 = cf1
            codef2 = cf2
            codef3 = cf3
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d6,     f2,  ff3d3,  fa2n5,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta5f2 )
c
            ta5f4 = indtet + 2
            codef1 = cf1
            codef2 = 6
            codef3 = cf3
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d4,  fa2n5,  ff3d1,     f4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta5f4 )
c
            indtet = ta5f4
c
c 5.5.5. mise a jour du tetredre courant
c
            filtet(letetr) = ta5f2
            hettet(letetr) = hettet(letetr) + 25
c
c
          elseif ( etatfa(1).gt.0 .and. etatfa(2).gt.0 ) then
c
c 5.6. decoupage a partir de l'arete 6
c
c 5.6.1. description des 2 faces decoupees
c
c 5.6.1.1. description de la face 1
c
c 5.6.1.1.1.reperage des 2 triangles fils
c
            ff1d4 = filtri(f1) + nutrde(i3(cf1),i1(cf1))
            ff1d5 = filtri(f1) + nutrde(i3(cf1),i2(cf1))
c
c 5.6.1.1.2.reperage de l'arete interne
c
            as2n6 = aretri(ff1d4,i2(cf1))
c
c 5.6.1.2. description de la face 2
c
c 5.6.1.2.1.reperage des 2 triangles fils
c
            ff2d2 = filtri(f2) + nutrde(i3(cf2),i1(cf2))
            ff2d3 = filtri(f2) + nutrde(i3(cf2),i2(cf2))
c
c 5.6.1.2.2.reperage de l'arete interne
c
            as1n6 = aretri(ff2d2,i2(cf2))
c
c 5.6.2. reperage de l'arete du tetraedre commune au deux fils
c
            a1  = aretri(f3,i1(cf3))
c
c 5.6.3. creation de la face interne
c        le niveau est le meme que les triangles fils sur l'exterieur
c
            niveau = nivtri(ff2d2)
c
            fa1n6 = indtri + 1
            indtri = fa1n6
            codefa = 1
            call cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    fa1n6,  a1,     as1n6,  as2n6,
     >                    codefa, niveau )
c
c 5.6.4. creation des tetraedres
c
            ta6f3 = indtet + 1
            codef1 = cf1
            codef2 = cf2
            codef3 = cf3
            codef4 = 1
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d5,  ff2d3,     f3,   fa1n6,
     >                     codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta6f3 )
c
            ta6f4 = indtet + 2
            codef1 = cf1
            codef2 = cf2
            codef3 = 1
            codef4 = cf4
            call cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                     ff1d4,  ff2d2,  fa1n6,     f4,
     >                    codef1, codef2, codef3, codef4,
     >                    letetr,   iaux, ta6f4 )
c
            indtet = ta6f4
c
c 5.6.5. mise a jour du tetredre courant
c
            filtet(letetr) = ta6f3
            hettet(letetr) = hettet(letetr) + 26
c
          else
c
            write (ulsort,texte(langue,4)) '2'
            write (ulsort,texte(langue,6))
            write (ulsort,texte(langue,7)) letetr
c
            codret = codret + 1
c
          endif
c
        endif
c
       endif
c
#ifdef _DEBUG_HOMARD_
#else
        if ( codret.eq.10 ) then
          write (ulsort,texte(langue,9)) codret
          goto 60
        endif
#endif
c
  200 continue
c
c====
c 6. la fin
c====
#ifdef _DEBUG_HOMARD_
#else
   60 continue
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,10)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
