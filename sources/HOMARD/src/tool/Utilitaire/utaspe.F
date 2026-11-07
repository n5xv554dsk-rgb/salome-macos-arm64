      subroutine utaspe ( lepent,
     >                    nbquto, nbpecf, nbpeca,
     >                    somare, arequa,
     >                    facpen, cofape, arepen,
     >                    listar, listso )
c
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
c     UTilitaire : Aretes et Sommets d'un PEntaedre
c     --           -         -            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .  1     . numero du pentaedre a examiner             .
c . nbquto . e   .  1     . nombre total de quadrangles                .
c . nbpecf . e   .  1     . nombre total de pentas decrits par faces   .
c . nbpeca . e   .  1     . nombre total de pentas decrits par aretes  .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. codes des 5 faces des pentaedres           .
c . arepen . e   .nbpeca*9. code des 9 aretes des pentaedres           .
c . listar .  s  .   9    . les 9 aretes du pentaedre                  .
c . listso .  s  .   6    . liste des sommets du pentaedre             .
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
      integer lepent
      integer nbquto, nbpecf, nbpeca
c
      integer somare(2,*)
      integer arequa(nbquto,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
c
      integer listar(9), listso(6)
c
c 0.4. ==> variables locales
c
      integer iaux
c ______________________________________________________________________
c
c====
c 1. Les aretes du pentaedre
c====
c
      if ( lepent.le.nbpecf ) then
c
        call utarpe ( lepent,
     >                nbquto, nbpecf,
     >                arequa, facpen, cofape,
     >                listar )
c
      else
c
        do 11 , iaux = 1 , 9
          listar(iaux) = arepen(lepent-nbpecf,iaux)
   11   continue
c
      endif
c
c====
c 2. les sommets du pentaedre
c====
c
      call utsope ( somare, listar, listso )
c
      end
