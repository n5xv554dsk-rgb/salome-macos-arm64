      subroutine pcs3tr ( letria, prfcan,
     >                    somare, hettri, aretri,
     >                    nbanar, anfiar,
     >                    nareca,
     >                    afaire, typdec, etan, orient )
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c    interpolation p0 sur les aretes - phase 3
c                                            -
c    decoupage des TRiangles
c                  --
c ______________________________________________________________________
c remarque : pcs0tr et pcs3tr sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letria . e   .    1   . triangle a examiner                        .
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . nareca . e   .   *    . nro des aretes dans le calcul en entree    .
c . afaire .  s  .    1   . vrai si l'interpolation est a faire        .
c . typdec .  s  .    1   . type de decoupage                          .
c . etan   .  s  .    1   . ETAt du triangle a l'iteration N           .
c . orient .  s  .    3   . orientation relative des aretes            .
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
c 0.2. ==> communs
c
#include "nombtr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer letria
      integer prfcan(*)
      integer somare(2,*)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer typdec, etan
      integer nareca(rearto)
      integer nbanar, anfiar(nbanar)
      integer orient(3)
c
      logical afaire
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer lafill, lapfil
      integer listar(12), nbaret
c
c     etanp1 = ETAt du triangle a l'iteration N+1
c
      integer etanp1
c
c 0.5. ==> initialisations
c
#include "impr03.h"
c ______________________________________________________________________
c
c====
c 1. Quel decoupage
c====
c
      etanp1 = mod(hettri(letria),10)
      etan   = (hettri(letria)-etanp1) / 10
c
cgn      write(1,90002) 'etan/etanp1', etan, etanp1
c
c     type de decoupage
c          4 : en 4 standard
c          6, 7, 8 : en 4 avec basculement de l'arete typdec-5
c          1, 2, 3 : en 2 selon l'arete typdec
c
      if ( ( etanp1.eq.4 ) .and.
     >     ( etan.eq.0 .or. etan.eq.1 .or.
     >       etan.eq.2 .or. etan.eq.3 ) ) then
        typdec = 4
c
      elseif (
     >     ( etanp1.eq.6 .or. etanp1.eq.7 .or. etanp1.eq.8 ) .and.
     >     ( etan.eq.0 .or. etan.eq.1 .or.
     >       etan.eq.2 .or. etan.eq.3 ) ) then
        typdec = etanp1
c
      elseif ( etanp1.eq.1 .or. etanp1.eq.2 .or. etanp1.eq.3 ) then
        typdec = etanp1
c
      else
        typdec = 0
c
      endif
cgn      write(1,*) 'typdec',typdec
c
c====
c 2. On verifie que le champ est present :
c    . sur toutes les aretes du triangle, s'il etait actif
c    . sur les aretes non coupee et sur les filles de l'arete coupee,
c      s'il etait coupe en 2
c====
c
      if ( typdec.ne.0 ) then
c
        afaire = .true.
cgn        write(1,*) 'etan',etan
c
        if ( etan.ne.5 ) then
c
        nbaret = 0
        do 311  , iaux = 1 , 3
c
cgn        write(1,*) aretri(letria,iaux),nareca(aretri(letria,iaux))
          if ( iaux.eq.etan .or. etan.eq.4 ) then
            do 3111  , jaux = 0 , 1
              lafill = anfiar(aretri(letria,iaux)) + jaux
cgn        write(1,*) '. lafill', lafill
              if ( anfiar(lafill).eq.0 ) then
                nbaret = nbaret + 1
                listar(nbaret) = nareca(lafill)
              else
                do 31111  , kaux = 0 , 1
                  lapfil = anfiar(lafill) + kaux
cgn        write(1,*) '.. lapfil', lapfil
                  nbaret = nbaret + 1
                  listar(nbaret) = nareca(lapfil)
31111           continue
              endif
 3111       continue
          else
            nbaret = nbaret + 1
            listar(nbaret) = nareca(aretri(letria,iaux))
          endif
c
  311   continue
c
cgn        write(1,*) 'listar :',(listar(iaux) , iaux = 1 , nbaret)
        do 312  , iaux = 1 , nbaret
c
          if ( listar(iaux).eq.0 ) then
            afaire = .false.
            goto 32
          elseif ( prfcan(listar(iaux)).eq.0 ) then
            afaire = .false.
            goto 32
          endif
c
  312   continue
c
   32   continue
c
        endif
c
      else
c
        afaire = .false.
c
      endif
cgn          write(1,*) 'afaire',afaire
c
c====
c 3. Si c'est a faire, on recupere l'orientation relative des aretes
c    dans le triangle
c====
c
      if ( afaire ) then
c
        call utorat ( somare,
     >            aretri(letria,1), aretri(letria,2), aretri(letria,3),
     >            orient(1), orient(2), orient(3) )
c
      endif
c
      end
