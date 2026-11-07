      subroutine utarhe ( lehexa,
     >                    nbquto, nbhecf,
     >                    arequa, quahex, coquhe,
     >                    listar )
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
c     UTilitaire : ARetes d'un HExaedre
c     --           --          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .  1     . numero de l'hexaedre a examiner            .
c . nbquto . e   .  1     . nombre total de quadrangles                .
c . nbhecf . e   .  1     . nombre d'hexaedres decrits par faces       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . listar .  s  .  12    . les 12 aretes de l'hexaedre                .
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
c 0.2. ==> communs
c
#include "j1234j.h"
c
c 0.3. ==> arguments
c
      integer lehexa
      integer nbquto, nbhecf
      integer listar(12)
      integer arequa(nbquto,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
c
c 0.4. ==> variables locales
c
      integer lafac1, lafac2, lafac5, lafac6
      integer codfa1, codfa2, codfa5, codfa6
c
#include "impr03.h"
c
c====
c 1. traitement
c====
c                 S5            a9             S6
c                  ----------------------------
c                 /|                          /|
c                / |                         / |
c               /  |                        /  |
c              /   |                       /   |
c           a6/    |                      /a5  |
c            /     |                     /     |
c           /   a11|                    /      |a10
c          /       |    a1             /       |
c       S2----------------------------- S1     |
c         |        |                  |        |
c         |        |           a12    |        |
c         |     S8 -------------------|--------|S7
c         |       /                   |       /
c       a3|      /                    |a2    /
c         |     /                     |     /
c         |    /                      |    /
c         | a8/                       |   /a7
c         |  /                        |  /
c         | /                         | /
c         |/                          |/
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
      lafac1 = quahex(lehexa,1)
      lafac2 = quahex(lehexa,2)
      lafac5 = quahex(lehexa,5)
      lafac6 = quahex(lehexa,6)
cgn      if ( lehexa.ge.210803 ) then
cgn      write(*,90002) 'nbquto, nbhecf',nbquto, nbhecf
cgn      write(*,90002) 'lafac1, lafac2, lafac5, lafac6',
cgn     >                lafac1, lafac2, lafac5, lafac6
cgn      endif
c
      codfa1 = coquhe(lehexa,1)
      codfa2 = coquhe(lehexa,2)
      codfa5 = coquhe(lehexa,5)
      codfa6 = coquhe(lehexa,6)
cgn      if ( lehexa.ge.210803 ) then
cgn      write(*,90002) 'codfa1, codfa2, codfa5, codfa6',
cgn     >                codfa1, codfa2, codfa5, codfa6
cgn      endif
c
      listar(1)  = arequa(lafac1,j1(codfa1))
      listar(2)  = arequa(lafac1,j2(codfa1))
      listar(3)  = arequa(lafac1,j4(codfa1))
      listar(4)  = arequa(lafac1,j3(codfa1))
      listar(5)  = arequa(lafac2,j4(codfa2))
      listar(6)  = arequa(lafac2,j2(codfa2))
      listar(7)  = arequa(lafac5,j2(codfa5))
      listar(8)  = arequa(lafac5,j4(codfa5))
      listar(9)  = arequa(lafac2,j3(codfa2))
      listar(10) = arequa(lafac6,j4(codfa6))
      listar(11) = arequa(lafac6,j2(codfa6))
      listar(12) = arequa(lafac6,j3(codfa6))
cgn      if ( lehexa.ge.210803 ) then
cgn      write(*,*) 'listar en sortie de utarhe'
cgn      write(*,91010) listar
cgn      endif
c
      end
