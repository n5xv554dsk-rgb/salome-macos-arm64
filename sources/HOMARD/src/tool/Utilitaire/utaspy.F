      subroutine utaspy ( lapyra,
     >                    nbtrto, nbpycf, nbpyca,
     >                    somare, aretri,
     >                    facpyr, cofapy, arepyr,
     >                    listar, listso )

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
c     UTilitaire : Aretes et Sommets d'une PYramide
c     --           -         -             --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lapyra . e   .  1     . numero de la pyramide a examiner           .
c . nbtrto . e   .  1     . nombre total de triangles                  .
c . nbpycf . e   .  1     . nombre total de pyramides decrits par faces.
c . nbpyca . e   .  1     . nombre total de pyras decrits par aretes   .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . listar .  s  .   8    . les 8 aretes de la pyramide                .
c . listso .  s  .   5    . liste des sommets de la pyramide           .
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
c 0.3. ==> arguments
c
      integer lapyra
      integer nbtrto, nbpycf, nbpyca
c
      integer somare(2,*)
      integer aretri(nbtrto,3)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      integer listar(8), listso(5)
c
c 0.4. ==> variables locales
c
c
      integer iaux
c ______________________________________________________________________
c
c====
c 1. Les aretes de la pyramide
c====
c
      if ( lapyra.le.nbpycf ) then
c
        call utarpy ( lapyra,
     >                nbtrto, nbpycf,
     >                aretri, facpyr, cofapy,
     >                listar )
c
      else
c
        do 11 , iaux = 1 , 8
          listar(iaux) = arepyr(lapyra-nbpycf,iaux)
   11   continue
c
      endif
c
c====
c 2. les sommets de la pyramide
c====
c
      call utsopy ( somare, listar, listso )
c
      end
