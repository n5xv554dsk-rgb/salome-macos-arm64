      subroutine pcsar1 ( nbfonc, typint, deraff,
     >                    prfcan, prfcap,
     >                    hetare, ancare, filare,
     >                    nbanar, anfiar,
     >                    somare,
     >                    hettri, aretri, filtri,
     >                    nareca, narsca,
     >                    vafoen, vafott,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c                       ARetes - solution P0 - etape 1
c                       --                           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . typint . e   .   1    . type d'interpolation                       .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  elements : 0 si intensif, sans orientation.
c .        .     .        .             1 si extensif, sans orientation.
c .        .     .        .             2 si intensif, avec orientation.
c .        .     .        .             3 si extensif, avec orientation.
c .        .     .        .  noeuds : 1 si degre 1                     .
c .        .     .        .           2 si degre 2                     .
c .        .     .        .           3 si iso-P2                      .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . ancare . e   . nbarto . anciens numeros des aretes conservees      .
c . filare . e   . nbarto . fille ainee de chaque arete                .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . nareca . e   .   *    . nro des aretes dans le calcul en entree    .
c . narsca . e   . rsarto . numero des aretes du calcul                .
c . vafoen .   e . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'PCSAR1' )
c
#include "nblang.h"
#include "fracta.h"
#include "fractc.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombsr.h"
#include "nomber.h"
c
#include "demitr.h"
#include "ope1a3.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer typint
      integer prfcan(*), prfcap(*)
      integer hetare(nbarto), ancare(*)
      integer filare(nbarto)
      integer nbanar, anfiar(nbanar)
      integer somare(2,*)
      integer hettri(nbtrto), aretri(nbtrto,3), filtri(nbtrto)
      integer nareca(rearto), narsca(rsarto)
c
      double precision vafoen(nbfonc,*)
      double precision vafott(nbfonc,*)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
c     arcn = ARetes en numerotation Calcul a l'iteration N
c     arhnp1 = ARetes en numerotation HOMARD a l'iteration N+1
c     arcnp1 = ARetes en numerotation Calcul a l'iteration N+1
c
      integer arcn(4)
      integer arhnp1(3)
      integer arcnp1(3)
c
c     etan   = ETAt du triangle a l'iteration N
c
      integer etan
c
c     f1trhp = Fils 1er du triangle en numerotation Homard a l'it. N+1
c
      integer f1trhp
c
c     f1hn = Fille 1er de l'arete en numerotation Homard a l'it. N
c
      integer f1hn
c
      integer letria, letri0
c
      integer typdec
      integer nrofon
      integer lareth, laretc
      integer iaux, jaux
      integer oripei(3), orifii(3)
      integer nufilo(3,3), nuarfi(3,3), nuarff(3,4)
c
      double precision champ0(3), champ1(3,3), flux
      double precision oriped(3)
c
      logical afaire
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "pcimp0.h"
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(/,''Arete en cours : nro a l''''iteration '',a3,'' : '',i8)'
      texte(1,5) =
     > '(  ''                etat a l''''iteration '',a3,'' : '',i4)'
      texte(1,6) = '(  ''==> Aucune interpolation'')'
c
      texte(2,4) =
     > '(/,''Current edge : # at iteration '',a3,'' : '',i8)'
      texte(2,5) =
     > '(  ''          status at iteration '',a3,'' : '',i4)'
      texte(2,6) = '(  ''==> No interpolation'')'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfonc', nbfonc
#endif
cgn      write(ulsort,*) 'nareca'
cgn      write(ulsort,91020) nareca
cgn      write(ulsort,*) 'prfcan'
cgn      write(ulsort,91020)(prfcan(iaux),iaux=1,74)
c
c====
c 2. on boucle sur toutes les triangles du maillage HOMARD
c====
c
      do 20 , letri0 = 1, nbtrto
c
        letria = letri0
c
cgn        write (ulsort,*) ' '
cgn        write (ulsort,90002) 'Triangle', letria
cgn        write (ulsort,90012) '. aretes du triangle HOMARD', letria,
cgn     >      (aretri(letria,iaux),iaux=1,3)
cgn        if ( mod(hettri(letria),10).eq.0 ) then
cgn        write (ulsort,90012) '. aretes du triangle Calcul', letria,
cgn     >      (narsca(aretri(letria,iaux)),iaux=1,3)
cgn        endif
c
c 2.1. ==> Type de decoupage
c
        call pcs3tr ( letria, prfcan,
     >                somare, hettri, aretri,
     >                nbanar, anfiar,
     >                nareca,
     >                afaire, typdec, etan, oripei )
c
cgn        write (ulsort,90015) '. typdec', typdec,', etan', etan
cgn        write (ulsort,99001) 'afaire', afaire
c
        if ( afaire ) then
c
c 2.2. ==> Les caracteritiques du triangle
c
        arhnp1(1) = aretri(letria,1)
        arhnp1(2) = aretri(letria,2)
        arhnp1(3) = aretri(letria,3)
c
c 2.2.1. ==> Orientations relatives des aretes du triangle
c
cgn        write (ulsort,90002) '. orientations                       ',
cgn     >              oripei
        do 221 , iaux = 1 , 3
          oriped(iaux) = dble(oripei(iaux))
  221   continue
cgn        if ( typdec.eq.4 ) then
cgn        write (ulsort,90002) '. filles arete 1 du triangle H/C n+1',
cgn     >      filare(arhnp1(1)),filare(arhnp1(1))+1,
cgn     >      narsca(filare(arhnp1(1))),narsca(filare(arhnp1(1))+1)
cgn        write (ulsort,90002) '. filles arete 2 du triangle H/C n+1',
cgn     >      filare(arhnp1(2)),filare(arhnp1(2))+1,
cgn     >      narsca(filare(arhnp1(2))),narsca(filare(arhnp1(2))+1)
cgn        write (ulsort,90002) '. filles arete 3 du triangle H/C n+1',
cgn     >      filare(arhnp1(3)),filare(arhnp1(3))+1,
cgn     >      narsca(filare(arhnp1(3))),narsca(filare(arhnp1(3))+1)
cgn        else
cgn        write (ulsort,90015) '. filles arete', typdec,
cgn     >      ' du triangle HOMARD n+1',
cgn     >      filare(arhnp1(typdec)),filare(arhnp1(typdec))+1
cgn        write (ulsort,90015) '. filles arete', typdec,
cgn     >      ' du triangle Calcul n+1',
cgn     >      narsca(filare(arhnp1(typdec))),
cgn     >      narsca(filare(arhnp1(typdec))+1)
cgn        endif
c
c 2.2.2. ==> Le fils du triangle
c
cgn        write (ulsort,90015) '. typdec', typdec,', etan', etan
        f1trhp = filtri(letria)
cgn        write (ulsort,90015) '. aretes du fils', f1trhp,' HOMARD n+1',
cgn     >      (aretri(f1trhp,iaux),iaux=1,3)
cgn        write (ulsort,90015) '. aretes du fils', f1trhp,' Calcul n+1',
cgn     >      (narsca(aretri(f1trhp,iaux)),iaux=1,3)
c
c 2.2.3. ==> Orientations relatives des aretes du fils du triangle
c            s'il est coupe en 4
c
        if ( typdec.eq.4 ) then
c
        call utorat ( somare,
     >          aretri(f1trhp,1), aretri(f1trhp,2), aretri(f1trhp,3),
     >          orifii(1), orifii(2), orifii(3) )
cgn        write (ulsort,90002) '. orientations                    ',
cgn     >      orifii
c
        endif
c
c 2.2.4. ==> Les aretes du triangle
c 2.2.4.1. ==> S'il etait actif : arcn(1), (2), (3)
c
        if ( etan.eq.0 ) then
c
          arcn(1) = nareca(arhnp1(1))
          arcn(2) = nareca(arhnp1(2))
          arcn(3) = nareca(arhnp1(3))
cgn      write(ulsort,90012)'. arete avant H Cn arcn(1)',
cgn     >        arhnp1(1), arcn(1)
cgn      write(ulsort,90012)'. arete avant H Cn arcn(2)',
cgn     >        arhnp1(2), arcn(2)
cgn      write(ulsort,90012)'. arete avant H Cn arcn(3)',
cgn     >        arhnp1(3), arcn(3)
c
c 2.2.4.2. ==> S'il etait coupe en deux :
c            arcn(1) : l'arete non coupee, avant celle coupee
c            arcn(2) : l'arete non coupee, apres celle coupee
c            arcn(3), arcn(4) : les 2 filles de l'aretes coupee
c
        elseif ( etan.eq.1 .or. etan.eq.2 .or. etan.eq.3 ) then
c
          arcn(1) = nareca(aretri(letria,per1a3(-1,etan)))
cgn      write(ulsort,90012)'. arete avant H Cn arcn(1)',
cgn     >        aretri(letria,per1a3(-1,etan)), arcn(1)
          arcn(2) = nareca(aretri(letria,per1a3( 1,etan)))
cgn      write(ulsort,90012)'. arete apres H Cn arcn(2)',
cgn     >        aretri(letria,per1a3( 1,etan)), arcn(2)
          f1hn = anfiar(aretri(letria,etan))
cgn      write(ulsort,90012)
cgn     >      '. ancienne fille HOMARD de l''arete coupee',
cgn     >        aretri(letria,etan), f1hn
          arcn(3) = nareca(f1hn)
cgn      write(ulsort,90015)
cgn     >      '. 1ere fille arete coupee H',f1hn,
cgn     >      ', Cn arcn(3) =', arcn(3)
          arcn(4) = nareca(f1hn+1)
cgn      write(ulsort,90015)'. 2nde fille arete coupee H',f1hn+1,
cgn     >      ', Cn arcn(4) =',arcn(4)
c
c 2.2.4.3. ==> Decoupage en 4 avec bascule d'aretes
c
        elseif ( etan.eq.6 .or. etan.eq.7 .or. etan.eq.8 ) then
          codret = 2243
          goto 2000
        endif
c
c 2.3. ==> Decoupage en 4 standard
c
        if ( typdec.eq.4 ) then
c
c 2.3.1. ==> Quelles aretes tracees sur ce triangle ?
c
          do 231 , iaux = 1 , 3
            arcnp1(iaux) = narsca(aretri(f1trhp,iaux))
            if ( arcnp1(iaux).eq.0 ) then
              goto 20
            endif
  231     continue
c
c 2.3.2. ==> Enregistrement
c
          prfcap(arcnp1(1)) = 1
          prfcap(arcnp1(2)) = 1
          prfcap(arcnp1(3)) = 1
c
c 2.3.3. ==> Parcours des fonctions
c 2.3.3.1. ==> numero des filles
c           nufilo(i,j) = numero local de la fille de la j-eme arete
c                         du pere pour le calcul de la valeur
c                         sur la i-eme arete du fils
          if ( oripei(1).gt.0 ) then
            nufilo(2,1) = 0
            nufilo(3,1) = 1
          else
            nufilo(2,1) = 1
            nufilo(3,1) = 0
          endif
          if ( oripei(2).gt.0 ) then
            nufilo(1,2) = 1
            nufilo(3,2) = 0
          else
            nufilo(1,2) = 0
            nufilo(3,2) = 1
          endif
          if ( oripei(3).gt.0 ) then
            nufilo(1,3) = 0
            nufilo(2,3) = 1
          else
            nufilo(1,3) = 1
            nufilo(2,3) = 0
          endif
c
          iaux = filare(arhnp1(3)) + nufilo(1,3)
          nuarfi(1,3) = narsca(iaux)
          if ( nuarfi(1,3).eq.0 ) then
            nuarff(1,1) = narsca(filare(iaux))
            nuarff(1,2) = narsca(filare(iaux)+1)
          endif
c
          iaux = filare(arhnp1(2)) + nufilo(1,2)
          nuarfi(1,2) = narsca(iaux)
          if ( nuarfi(1,2).eq.0 ) then
            nuarff(1,3) = narsca(filare(iaux))
            nuarff(1,4) = narsca(filare(iaux)+1)
          endif
c
          iaux = filare(arhnp1(1)) + nufilo(2,1)
          nuarfi(2,1) = narsca(iaux)
          if ( nuarfi(2,1).eq.0 ) then
            nuarff(2,1) = narsca(filare(iaux))
            nuarff(2,2) = narsca(filare(iaux)+1)
          endif
c
          iaux = filare(arhnp1(3)) + nufilo(2,3)
          nuarfi(2,3) = narsca(iaux)
          if ( nuarfi(2,3).eq.0 ) then
            nuarff(2,3) = narsca(filare(iaux))
            nuarff(2,4) = narsca(filare(iaux)+1)
          endif
c
          iaux = filare(arhnp1(1)) + nufilo(3,1)
          nuarfi(3,1) = narsca(iaux)
          if ( nuarfi(3,1).eq.0 ) then
            nuarff(3,1) = narsca(filare(iaux))
            nuarff(3,2) = narsca(filare(iaux)+1)
          endif
c
          iaux = filare(arhnp1(2)) + nufilo(3,2)
          nuarfi(3,2) = narsca(iaux)
          if ( nuarfi(3,2).eq.0 ) then
            nuarff(3,3) = narsca(filare(iaux))
            nuarff(3,4) = narsca(filare(iaux)+1)
          endif
cgn      write (ulsort,90002) '. filles pour 1', nuarfi(1,3), nuarfi(1,2)
cgn      if ( nuarfi(1,3).eq.0 ) then
cgn      write (ulsort,90002) '. petites filles pour 1',
cgn     >                    nuarff(1,1), nuarff(1,2)
cgn      endif
cgn      if ( nuarfi(1,2).eq.0 ) then
cgn      write (ulsort,90002) '. petites filles pour 1',
cgn     >                    nuarff(1,3), nuarff(1,4)
cgn      endif
cgn      write (ulsort,90002) '. filles pour 2', nuarfi(2,1), nuarfi(2,3)
cgn      if ( nuarfi(2,1).eq.0 ) then
cgn      write (ulsort,90002) '. petites filles pour 2',
cgn     >                    nuarff(2,1), nuarff(2,2)
cgn      endif
cgn      if ( nuarfi(2,3).eq.0 ) then
cgn      write (ulsort,90002) '. petites filles pour 2',
cgn     >                    nuarff(2,3), nuarff(2,4)
cgn      endif
cgn      write (ulsort,90002) '. filles pour 3', nuarfi(3,2), nuarfi(3,1)
cgn      if ( nuarfi(3,2).eq.0 ) then
cgn      write (ulsort,90002) '. petites filles pour 3',
cgn     >                    nuarff(3,1), nuarff(3,2)
cgn      endif
cgn      if ( nuarfi(3,1).eq.0 ) then
cgn      write (ulsort,90002) '. petites filles pour 3',
cgn     >                    nuarff(3,3), nuarff(3,4)
cgn      endif
c
c 2.3.3.2. ==> Interpolation
c
          do 2321 , nrofon = 1 , nbfonc
c
            if ( etan.eq.0 ) then
              champ0(1) = vafoen(nrofon,prfcan(arcn(1)))
              champ0(2) = vafoen(nrofon,prfcan(arcn(2)))
              champ0(3) = vafoen(nrofon,prfcan(arcn(3)))
            elseif ( etan.eq.1 .or. etan.eq.2 .or. etan.eq.3 ) then
cgn              write (ulsort,*) 'le triangle etait coupe en 2'
              champ0(etan) = vafoen(nrofon,prfcan(arcn(3)))
     >                     - vafoen(nrofon,prfcan(arcn(4)))
              champ0(per1a3(-1,etan)) = vafoen(nrofon,prfcan(arcn(1)))
              champ0(per1a3( 1,etan)) = vafoen(nrofon,prfcan(arcn(2)))
            endif
cgn            write (ulsort,90004) '. champ0', champ0
c
            call utflt0 ( somare, arhnp1,
     >                    champ0, flux,
     >                    ulsort, langue, codret )
            flux = unsqu*flux
cgn         write (ulsort,90004) '. flux sur les 4 fils', flux
c
              if ( nuarfi(1,3).ne.0 ) then
                champ1(1,3) = vafott(nrofon,nuarfi(1,3))
              else
                champ1(1,3) = vafott(nrofon,nuarff(1,1))
     >                      - vafott(nrofon,nuarff(1,2))
              endif
              if ( nuarfi(1,2).ne.0 ) then
                champ1(1,2) = vafott(nrofon,nuarfi(1,2))
              else
                champ1(1,2) = vafott(nrofon,nuarff(1,3))
     >                      - vafott(nrofon,nuarff(1,4))
              endif
              if ( nuarfi(2,1).ne.0 ) then
                champ1(2,1) = vafott(nrofon,nuarfi(2,1))
              else
                champ1(2,1) = vafott(nrofon,nuarff(2,1))
     >                      - vafott(nrofon,nuarff(2,2))
              endif
              if ( nuarfi(2,3).ne.0 ) then
                champ1(2,3) = vafott(nrofon,nuarfi(2,3))
              else
                champ1(2,3) = vafott(nrofon,nuarff(2,3))
     >                      - vafott(nrofon,nuarff(2,4))
              endif
              if ( nuarfi(3,2).ne.0 ) then
                champ1(3,2) = vafott(nrofon,nuarfi(3,2))
              else
                champ1(3,2) = vafott(nrofon,nuarff(3,1))
     >                      - vafott(nrofon,nuarff(3,2))
              endif
              if ( nuarfi(3,1).ne.0 ) then
                champ1(3,1) = vafott(nrofon,nuarfi(3,1))
              else
                champ1(3,1) = vafott(nrofon,nuarff(3,3))
     >                      - vafott(nrofon,nuarff(3,4))
              endif
cgn      write (ulsort,90004) '. champ1 pour 1', champ1(1,3), champ1(1,2)
cgn      write (ulsort,90004) '. champ1 pour 2', champ1(2,1), champ1(2,3)
cgn      write (ulsort,90004) '. champ1 pour 3', champ1(3,2), champ1(3,1)
c
            vafott(nrofon,arcnp1(1)) =
     >      orifii(1) * ( champ1(1,3) - champ1(1,2) - flux )
            vafott(nrofon,arcnp1(2)) =
     >      orifii(2) * ( champ1(2,1) - champ1(2,3) - flux )
             vafott(nrofon,arcnp1(3)) =
     >      orifii(3) * ( champ1(3,2) - champ1(3,1) - flux )
cgn            do 2322 , iaux = 1 , 3
cgn              write (ulsort,90024) '. arete',aretri(f1trhp,iaux),
cgn     >        vafott(nrofon,arcnp1(iaux))
cgn 2322       continue
c
 2321     continue
c
c 2.4. ==> Decoupage en 2
c
        elseif ( typdec.eq.1 .or. typdec.eq.2 .or. typdec.eq.3 ) then
c
c 2.4.1. ==> Quelle arete tracee sur ce triangle ?
c            On base tout le raisonnement sur le triangle fils
c            au rang nutrde(i,i+1) dans la numerotation
c            Voir cmcdtr pour les conventions
c         le bon fils :
          iaux = f1trhp + nutrde(typdec, per1a3(1,typdec))
cgn          write (ulsort,90002) '. les 2 fils ', f1trhp, f1trhp+1
cgn          write (ulsort,90002) '. le bon fils', iaux
c         la bonne arete : celle a la place i-1
cgn          write (ulsort,90002) '. per1a3(-1,typdec)', per1a3(-1,typdec)
          lareth = aretri(iaux,per1a3(-1,typdec))
cgn          write (ulsort,90002) '. lareth', lareth, narsca(lareth)
          arcnp1(3) = narsca(lareth)
          if ( arcnp1(3).eq.0 ) then
            goto 20
          endif
cgn          write (ulsort,90015) '. arete centrale HOMARD', lareth,
cgn     >                         ', Calcul n+1', arcnp1(3)
c
c 2.4.2. ==> Les demi-aretes de la base du triangle
c            arcnp1(1) : la premiere fille de l'arete coupee
c            arcnp1(2) : la seconde fille de l'arete coupee
c
          arcnp1(1) = narsca(filare(aretri(letria,typdec)))
          arcnp1(2) = narsca(filare(aretri(letria,typdec))+1)
cgn          write (ulsort,90002) '. aretes filles', arcnp1(1),arcnp1(2)
c
c 2.4.3. ==> Enregistrement
c
          prfcap(arcnp1(3)) = 1
c
c 2.4.4. ==> Parcours des fonctions
c 2.4.4.1. ==> numero des filles
c           nufilo(i,j) = numero local de la fille de la j-eme arete
c                         pour le calcul de la i-eme valeur
          if ( oripei(typdec).gt.0 ) then
            jaux = 1
          else
            jaux = 0
          endif
cgn          write (ulsort,90002) '. jaux/arete du pere/fille HOMARD',
cgn     >       jaux,arhnp1(typdec),filare(arhnp1(typdec))+jaux
          laretc = narsca(filare(arhnp1(typdec))+jaux)
cgn            write (ulsort,90114) '. champ sur cette arete Cn+1',
cgn     >               laretc, vafott(1,laretc)
c
c 2.4.4.2. ==> Interpolation
c
cgn          write (ulsort,90002) '. arhnp1', arhnp1
cgn          write (ulsort,90002) '. arcn  ', arcn
c
          do 2422 , nrofon = 1 , nbfonc
c
            if ( etan.eq.0 ) then
              champ0(1) = vafoen(nrofon,prfcan(arcn(1)))
              champ0(2) = vafoen(nrofon,prfcan(arcn(2)))
              champ0(3) = vafoen(nrofon,prfcan(arcn(3)))
            elseif ( etan.eq.1 .or. etan.eq.2 .or. etan.eq.3 ) then
cgn              write (ulsort,*) 'le triangle etait coupe en 2'
              champ0(etan) = vafoen(nrofon,prfcan(arcn(3)))
     >                     - vafoen(nrofon,prfcan(arcn(4)))
              champ0(per1a3(-1,etan)) = vafoen(nrofon,prfcan(arcn(1)))
              champ0(per1a3( 1,etan)) = vafoen(nrofon,prfcan(arcn(2)))
            elseif ( etan.le.5 ) then
cgn              if ( etan.eq.4 ) then
cgn                write (ulsort,*) 'le triangle etait coupe en 4'
cgn              else
cgn                write (ulsort,*) 'le triangle n''existait pas'
cgn              endif
              champ0(typdec) = vafott(nrofon,arcnp1(1))
     >                       - vafott(nrofon,arcnp1(2))
              champ0(per1a3(-1,typdec)) =
     >         vafott(nrofon,narsca(arhnp1(per1a3(-1,typdec))))
              champ0(per1a3( 1,typdec)) =
     >         vafott(nrofon,narsca(arhnp1(per1a3( 1,typdec))))
            endif
cgn            write (ulsort,90004) '. champ0', champ0
c
            call utflt0 ( somare, arhnp1,
     >                    champ0, flux,
     >                    ulsort, langue, codret )
            flux = unsde*flux
cgn         write (ulsort,90004) '. flux sur les 2 fils', flux
cgn         write (ulsort,90114) '. champ sur l''arete fille n+1 laretc',
cgn     >               laretc,vafott(nrofon,laretc)
cgn         write (ulsort,90112) '. arcn  ', per1a3(1,typdec),
cgn     >arcn(per1a3(1,typdec)),prfcan(arcn(per1a3(1,typdec)))
cgn         write (ulsort,90114) '. arcn  ', per1a3(1,typdec),
cgn     >oriped(per1a3(1,typdec)),
cgn     >vafoen(nrofon,prfcan(arcn(per1a3(1,typdec))))
c
            vafott(nrofon,arcnp1(3)) =
     >      ( flux
     >      + vafott(nrofon,laretc)
     >      - oriped(per1a3(1,typdec))*champ0(per1a3( 1,typdec)) )
cgn          write (ulsort,90004) '. val', vafott(nrofon,arcnp1(3))
c
 2422     continue
c
        endif
c
        endif
c
   20 continue
c
 2000 continue
c
cgn      write(ulsort,91020)(prfcap(iaux),iaux=1,nbtrto)
cgn      print *,'nbfonc = ',nbfonc
cgn      etan   = 1
cgn      etanp1 = nbarto
cgn      do 30001 , iaux=etan,etanp1
cgn        if ( mod(hetare(iaux),10).eq.0 ) then
cgn          print 11790,
cgn     >    ntrsca(iaux),prfcap(narsca(iaux)),vafott(1,narsca(iaux))
cgn        endif
cgn30001 continue
cgn11790 format(i4,' : ',i2,' / ',g15.7)
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
