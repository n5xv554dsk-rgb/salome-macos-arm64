      subroutine utvhex ( lehexa, volume,
     >                    coonoe, somare, arequa,
     >                    quahex, coquhe, arehex )
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
c     UTilitaire : Volume d'un HEXaedre
c     --           -           ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .  1     . numero de l'hexaedre a examiner            .
c . volume .  s  .  1     . volume                                     .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
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
#include "fractc.h"
#include "fractf.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      double precision volume
      double precision coonoe(nbnoto,3)
c
      integer lehexa
      integer somare(2,nbarto)
      integer arequa(nbquto,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer listar(12), listso(8)
      integer s1, s2, s3, s4, s5, s6, s7,s8
c
      double precision of1(3),of2(3),of3(3),of4(3),of5(3),of6(3)
      double precision centr(3), qual(24), volu(24)
c
c====
c 1. les aretes et les sommets
c====
c
      call utashe ( lehexa,
     >              nbquto, nbhecf, nbheca,
     >              somare, arequa,
     >              quahex, coquhe, arehex,
     >              listar, listso )
c
      s1 = listso(1)
      s2 = listso(2)
      s3 = listso(3)
      s4 = listso(4)
      s5 = listso(5)
      s6 = listso(6)
      s7 = listso(7)
      s8 = listso(8)
c
c====
c 2. les points caracteristiques
c====
c     Le centre de l'hexaedre
      centr(1) = unshu*(coonoe(s1,1)+coonoe(s2,1)
     >         + coonoe(s3,1)+coonoe(s4,1)+coonoe(s5,1)
     >         + coonoe(s6,1)+coonoe(s7,1)+coonoe(s8,1) )
      centr(2) = unshu*(coonoe(s1,2)+coonoe(s2,2)
     >         + coonoe(s3,2)+coonoe(s4,2)+coonoe(s5,2)
     >         + coonoe(s6,2)+coonoe(s7,2)+coonoe(s8,2) )
      centr(3) = unshu*(coonoe(s1,3)+coonoe(s2,3)
     >         + coonoe(s3,3)+coonoe(s4,3)+coonoe(s5,3)
     >         + coonoe(s6,3)+coonoe(s7,3)+coonoe(s8,3) )
c     Le centre de la face 1
      of1(1) = unsqu*(coonoe(s1,1)+coonoe(s2,1)
     >       +        coonoe(s3,1)+coonoe(s4,1))
      of1(2) = unsqu*(coonoe(s1,2)+coonoe(s2,2)
     >       +        coonoe(s3,2)+coonoe(s4,2))
      of1(3) = unsqu*(coonoe(s1,3)+coonoe(s2,3)
     >       +        coonoe(s3,3)+coonoe(s4,3))
c     Le centre de la face 2
      of2(1) = unsqu*(coonoe(s1,1)+coonoe(s2,1)
     >       +        coonoe(s5,1)+coonoe(s6,1))
      of2(2) = unsqu*(coonoe(s1,2)+coonoe(s2,2)
     >       +        coonoe(s5,2)+coonoe(s6,2))
      of2(3) = unsqu*(coonoe(s1,3)+coonoe(s2,3)
     >       +        coonoe(s5,3)+coonoe(s6,3))
c     Le centre de la face 3
      of3(1) = unsqu*(coonoe(s1,1)+coonoe(s4,1)
     >       +        coonoe(s6,1)+coonoe(s7,1))
      of3(2) = unsqu*(coonoe(s1,2)+coonoe(s4,2)
     >       +        coonoe(s6,2)+coonoe(s7,2))
      of3(3) = unsqu*(coonoe(s1,3)+coonoe(s4,3)
     >       +        coonoe(s6,3)+coonoe(s7,3))
c     Le centre de la face 4
      of4(1) = unsqu*(coonoe(s2,1)+coonoe(s3,1)
     >       +        coonoe(s5,1)+coonoe(s8,1))
      of4(2) = unsqu*(coonoe(s2,2)+coonoe(s3,2)
     >       +        coonoe(s5,2)+coonoe(s8,2))
      of4(3) = unsqu*(coonoe(s2,3)+coonoe(s3,3)
     >       +        coonoe(s5,3)+coonoe(s8,3))
c     Le centre de la face 5
      of5(1) = unsqu*(coonoe(s3,1)+coonoe(s4,1)
     >       +        coonoe(s7,1)+coonoe(s8,1))
      of5(2) = unsqu*(coonoe(s3,2)+coonoe(s4,2)
     >       +        coonoe(s7,2)+coonoe(s8,2))
      of5(3) = unsqu*(coonoe(s3,3)+coonoe(s4,3)
     >       +        coonoe(s7,3)+coonoe(s8,3))
c     Le centre de la face 6
      of6(1) = unsqu*(coonoe(s5,1)+coonoe(s6,1)
     >       +        coonoe(s7,1)+coonoe(s8,1))
      of6(2) = unsqu*(coonoe(s5,2)+coonoe(s6,2)
     >       +        coonoe(s7,2)+coonoe(s8,2))
      of6(3) = unsqu*(coonoe(s5,3)+coonoe(s6,3)
     >       +        coonoe(s7,3)+coonoe(s8,3))
c
c====
c 3. volume et qualite des tetraedres
c====
c
c     tetra touchant la face 1
      call utqte2 ( qual( 1), volu( 1), coonoe, s1, s2, centr, of1 )
      call utqte2 ( qual( 2), volu( 2), coonoe, s2, s3, centr, of1 )
      call utqte2 ( qual( 3), volu( 3), coonoe, s3, s4, centr, of1 )
      call utqte2 ( qual( 4), volu( 4), coonoe, s1, s4, centr, of1 )
c     tetra touchant la face 2
      call utqte2 ( qual( 5), volu( 5), coonoe, s1, s2, centr, of2 )
      call utqte2 ( qual( 6), volu( 6), coonoe, s2, s5, centr, of2 )
      call utqte2 ( qual( 7), volu( 7), coonoe, s5, s6, centr, of2 )
      call utqte2 ( qual( 8), volu( 8), coonoe, s1, s6, centr, of2 )
c     tetra touchant la face 3
      call utqte2 ( qual( 9), volu( 9), coonoe, s1, s4, centr, of3 )
      call utqte2 ( qual(10), volu(10), coonoe, s4, s7, centr, of3 )
      call utqte2 ( qual(11), volu(11), coonoe, s6, s7, centr, of3 )
      call utqte2 ( qual(12), volu(12), coonoe, s1, s6, centr, of3 )
c     tetra touchant la face 4
      call utqte2 ( qual(13), volu(13), coonoe, s2, s3, centr, of4 )
      call utqte2 ( qual(14), volu(14), coonoe, s3, s8, centr, of4 )
      call utqte2 ( qual(15), volu(15), coonoe, s5, s8, centr, of4 )
      call utqte2 ( qual(16), volu(16), coonoe, s2, s5, centr, of4 )
c     tetra touchant la face 5
      call utqte2 ( qual(17), volu(17), coonoe, s3, s4, centr, of5 )
      call utqte2 ( qual(18), volu(18), coonoe, s4, s7, centr, of5 )
      call utqte2 ( qual(19), volu(19), coonoe, s7, s8, centr, of5 )
      call utqte2 ( qual(20), volu(20), coonoe, s3, s8, centr, of5 )
c     tetra touchant la face 6
      call utqte2 ( qual(21), volu(21), coonoe, s5, s6, centr, of6 )
      call utqte2 ( qual(22), volu(22), coonoe, s6, s7, centr, of6 )
      call utqte2 ( qual(23), volu(23), coonoe, s7, s8, centr, of6 )
      call utqte2 ( qual(24), volu(24), coonoe, s5, s8, centr, of6 )
c
      volume = 0.d0
      do 10 , iaux = 1 , 24
        volume = volume + volu(iaux)
   10 continue
c
      end
