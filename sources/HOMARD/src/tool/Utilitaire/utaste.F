      subroutine utaste ( letetr,
     >                    nbtrto, nbtecf, nbteca,
     >                    somare, aretri,
     >                    tritet, cotrte, aretet,
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
c     UTilitaire : Aretes et Sommets d'un TEtraedre
c     --           -         -            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letetr . e   .  1     . numero du tetraedre a examiner             .
c . nbtrto . e   .  1     . nombre total de triangles                  .
c . nbtecf . e   .  1     . nombre total de tetraedres decrits par face.
c . nbteca . e   .  1     . nombre total de tetras decrits par aretes  .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. codes des 4 triangles des tetraedres       .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . listar .  s  .   6    . les 6 aretes du tetraedre                  .
c . listso .  s  .   4    . liste des sommets du tetraedre             .
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
      integer letetr
      integer nbtrto, nbtecf, nbteca
c
      integer somare(2,*)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
c
      integer listar(6), listso(4)
c
c 0.4. ==> variables locales
c
      integer iaux
c ______________________________________________________________________
c
c====
c 1. Les aretes du tetraedre
c====
c
      if ( letetr.le.nbtecf ) then
c
        call utarte ( letetr,
     >                nbtrto, nbtecf,
     >                aretri, tritet, cotrte,
     >                listar )
c
      else
c
        do 11 , iaux = 1 , 6
          listar(iaux) = aretet(letetr-nbtecf,iaux)
   11   continue
c
      endif
c
c====
c 2. les sommets du tetraedre
c====
c
      call utsote ( somare, listar, listso )
c
      end
