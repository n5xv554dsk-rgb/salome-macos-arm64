      subroutine utnitr ( coonoe,
     >                    hetnoe, arenoe, famnoe,
     >                    somare, np2are,
     >                    aretri, hettri, filtri,
     >                    nintri,
     >                    indnoe, nouvno, nouvar, nouvtr,
     >                    option,
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
c    UTilitaire - creation de Noeuds Internes
c    --                       -      -
c                 apres decoupages de TRiangles
c                                     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . famnoe . es  . nouvno . caracteristiques des noeuds                .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . np2are . e   . nouvar . numero des noeuds p2 milieux d'aretes      .
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nouvtr . historique de l'etat des triangles         .
c . filtri . e   . nouvtr . premier fils des triangles                 .
c . nintri . es  . nouvtr . noeud interne au triangle                  .
c . indnoe . es  . 1      . indice du dernier noeud cree               .
c . nouvno . e   . 1      . nombre total de noeuds a examiner          .
c . nouvar . e   . 1      . nombre total d'aretes a examiner           .
c . nouvtr . e   . 1      . nombre total de triangles a examiner       .
c . option . e   . 1      . 0 : decoupage standard                     .
c .        .     .        . 1 : decoupage de conformite                .
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
#include "fractb.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "ope1a3.h"
c
c 0.3. ==> arguments
c
      integer indnoe, nouvno, nouvar, nouvtr
      integer hetnoe(nouvno), arenoe(nouvno), famnoe(nouvno)
      integer somare(2,nouvar), np2are(nouvar)
      integer aretri(nouvtr,3), hettri(nouvtr), filtri(nouvtr)
      integer nintri(nouvtr)
      integer option
c
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer letria, lefils
      integer as2s3, as1s3, as1s2
      integer sa3a1, sa1a2, sa2a3
      integer an2n3, an1n3, an1n2
      integer n1, n2, n3
      integer somm(3)
      integer iaux1, iaux2, iaux3
      integer etan, etanp1
      integer lesomm
c
#include "impr03.h"
c ______________________________________________________________________
c
c====
c    creation des noeuds internes aux nouveaux triangles
c    on remarque que cette technique permet de garantir qu'un noeud
c    interne a toujours un numero superieur a ceux des autres noeuds
c    du triangle
c====
c
      do 11 , letria = 1, nouvtr
c
cgn        write (*,90015) 'Triangle', letria, ' d''etat',hettri(letria)
        etanp1 = mod(hettri(letria),10)
c
c====
c 1. Ce triangle vient d'etre coupe en 4 : raffinement standard
c====
c
        if ( option.eq.0 .and.
     >       ( ( etanp1.eq.4 ) .or.
     >         ( etanp1.ge.6 .and. etanp1.le.8 ) ) ) then
c
          etan = (hettri(letria)-etanp1)/10
c
          if ( etan.ge.0 .and. etan.le.3 ) then
cgn            write (*,90015) 'Triangle', letria, ' coupe en 4'
c
c 1.1. ==> on recupere ses sommets
c        voir cmrdtr pour la convention
c                           S1 = sa2a3
c                            *
c                           . .
c                          .   .
c                         .     .
c                     a3 .       . a2
c                       .         .
c                      .           .
c                     .             .
c          sa3a1 = S2*---------------*S3 = sa1a2
c                           a1
c
            as2s3 = aretri(letria,1)
            as1s3 = aretri(letria,2)
            as1s2 = aretri(letria,3)
c
            call utsotr ( somare, as2s3, as1s3, as1s2,
     >                    sa1a2, sa2a3, sa3a1 )
cgn         write (*,90002) 'sommets du pere',sa2a3,sa3a1,sa1a2
c
c 1.2. ==> le 1er triangle fils partage le meme noeud interne
c
            lefils = filtri(letria)
            nintri(lefils) = nintri(letria)
c
c 1.3. ==> Recuperation des sommets du fils
c
            an2n3 = aretri(lefils,1)
            an1n3 = aretri(lefils,2)
            an1n2 = aretri(lefils,3)
c
            call utsotr ( somare, an2n3, an1n3, an1n2,
     >                    n3, n1, n2 )
cgn         write (*,90002) 'sommets du fils',n1,n2,n3
c
c 1.4. ==> creation pour les fils suivants
c
            do 14 , iaux = 1, 3
c
              if ( iaux.eq.1 ) then
                iaux1 = sa2a3
                iaux2 = n2
                iaux3 = n3
              elseif ( iaux.eq.2 ) then
                iaux1 = sa3a1
                iaux2 = n3
                iaux3 = n1
              else
                iaux1 = sa1a2
                iaux2 = n1
                iaux3 = n2
              endif
c
              indnoe = indnoe + 1
cgn              write (*,90002) '==> Creation du noeud', indnoe
              nintri(lefils+iaux) = indnoe
c
              if ( sdim.eq.2 ) then
                coonoe(indnoe,1) = unstr *
     >          ( coonoe(iaux1,1) + coonoe(iaux2,1) + coonoe(iaux3,1) )
                coonoe(indnoe,2) = unstr *
     >          ( coonoe(iaux1,2) + coonoe(iaux2,2) + coonoe(iaux3,2) )
              else
                coonoe(indnoe,1) = unstr *
     >          ( coonoe(iaux1,1) + coonoe(iaux2,1) + coonoe(iaux3,1) )
                coonoe(indnoe,2) = unstr *
     >          ( coonoe(iaux1,2) + coonoe(iaux2,2) + coonoe(iaux3,2) )
                coonoe(indnoe,3) = unstr *
     >          ( coonoe(iaux1,3) + coonoe(iaux2,3) + coonoe(iaux3,3) )
              endif
              hetnoe(indnoe) = 54
              famnoe(indnoe) = 1
              arenoe(indnoe) = 0
c
   14       continue
c
          endif
c
c====
c 2. Ce triangle vient d'etre coupe en 2 : conformite
c====
c
        elseif ( option.eq.1 .and.
     >           ( etanp1.ge.1 .and. etanp1.le.3 ) ) then
cgn          write (*,90015) 'Triangle', letria, ' coupe en 2'
c
c 2.1. ==> on recupere ses sommets
c        voir cmcdtr pour la convention
c                           S1 = sa2a3
c                            *
c                           . .
c                          .   .
c                         .     .
c                     a3 .       . a2
c                       .         .
c                      .           .
c                     .             .
c          sa3a1 = S2*---------------*S3 = sa1a2
c                           a1
c
            as2s3 = aretri(letria,1)
            as1s3 = aretri(letria,2)
            as1s2 = aretri(letria,3)
c
            call utsotr ( somare, as2s3, as1s3, as1s2,
     >                    sa1a2, sa2a3, sa3a1 )
cgn         write (*,90002) 'sommets du pere', sa1a2, sa2a3, sa3a1
            somm(1) = sa2a3
            somm(2) = sa3a1
            somm(3) = sa1a2
c
c 2.2. ==> L'arete de decoupage
c
             lesomm = np2are(aretri(letria,etanp1))
cgn         write (*,90002) 'lesomm', lesomm
c
c 2.3. ==> creation pour les deux fils
c
            lefils = filtri(letria)
c
            do 23 , iaux = 0, 1
c
              iaux1 = somm(etanp1)
              if ( iaux.eq.0 ) then
                iaux2 = somm(per1a3(-1,etanp1))
              else
                iaux2 = somm(per1a3( 1,etanp1))
              endif
cgn              print *,'pere',iaux1,lesomm,iaux2
              indnoe = indnoe + 1
cgn              write (*,90002) '==> Creation du noeud', indnoe
              nintri(lefils+iaux) = indnoe
c
              if ( sdim.eq.2 ) then
                coonoe(indnoe,1) = unstr *
     >          ( coonoe(iaux1,1) + coonoe(iaux2,1) + coonoe(lesomm,1) )
                coonoe(indnoe,2) = unstr *
     >          ( coonoe(iaux1,2) + coonoe(iaux2,2) + coonoe(lesomm,2) )
              else
                coonoe(indnoe,1) = unstr *
     >          ( coonoe(iaux1,1) + coonoe(iaux2,1) + coonoe(lesomm,1) )
                coonoe(indnoe,2) = unstr *
     >          ( coonoe(iaux1,2) + coonoe(iaux2,2) + coonoe(lesomm,2) )
                coonoe(indnoe,3) = unstr *
     >          ( coonoe(iaux1,3) + coonoe(iaux2,3) + coonoe(lesomm,3) )
              endif
              hetnoe(indnoe) = 54
              famnoe(indnoe) = 1
              arenoe(indnoe) = 0
c
   23       continue
c
        endif
c
   11 continue
c
      end
