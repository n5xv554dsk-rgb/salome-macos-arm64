      subroutine utniqu ( coonoe,
     >                    hetnoe, arenoe, famnoe,
     >                    hetare, somare, filare,
     >                    np2are,
     >                    nintri,
     >                    arequa, hetqua, filqua,
     >                    ninqua,
     >                    indnoe, nouvno, nouvar, nouvtr, nouvqu,
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
c                 apres decoupages de QUadrangles
c                                     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . famnoe . es  . nouvno . caracteristiques des noeuds                .
c . hetare . e   . nouvar . historique de l'etat des aretes            .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . filare . e   . nouvar . premiere fille des aretes                  .
c . np2are . e   . nouvar . numero des noeuds p2 milieux d'aretes      .
c . nintri . es  . nouvtr . noeud interne au triangle                  .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nouvqu . historique de l'etat des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . ninqua . es  . nouvqu . noeud interne au quadrangle                .
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
#include "fractc.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer indnoe, nouvno, nouvar, nouvtr, nouvqu
      integer hetnoe(nouvno), arenoe(nouvno), famnoe(nouvno)
      integer hetare(nouvar), somare(2,nouvar), filare(nouvar)
      integer np2are(nouvar)
      integer nintri(nouvtr)
      integer arequa(nouvqu,4), hetqua(nouvqu), filqua(nouvqu)
      integer ninqua(nouvqu)
      integer option
c
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lequad, lefils
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
      integer n1, n2, n3, n4
      integer iaux1, iaux2, iaux3
      integer etan, etanp1
      integer lesomm
      integer numdec
      integer ai, aj, ak, al
      integer afij, afil
      integer saiaj, sajak, sakal, salai
      integer ni
c
#include "impr03.h"
c ______________________________________________________________________
c
c====
c    creation des noeuds internes aux nouveaux quadrangles
c    on remarque que cette technique permet de garantir qu'un noeud
c    interne a toujours un numero superieur a ceux des autres noeuds
c    du quadrangle
c====
c
      do 11 , lequad = 1, nouvqu
c
cgn      write (ulsort,90015) 'Quad', lequad, ' d''etat',hetqua(lequad)
        etanp1 = mod(hetqua(lequad),100)
c
c====
c 1. Ce quadrangle vient d'etre coupe en 4 : raffinement standard
c====
c
        if ( option.eq.0 .and. etanp1.eq.4 ) then
c
          etan = (hetqua(lequad)-etanp1)/100
cgn        write (ulsort,90002) 'etan', etan
c
          if ( etan.ne.4 .and. etan.ne.99 ) then
cgn        write (ulsort,90015) 'Quadrangle', lequad, ' coupe en 4'
c
c 1.1. ==> on recupere ses sommets
c        voir cmrdqu pour la convention
c                      sa4a1   a4   sa3a4
c                          ._________.
c                          .         .
c                          .         .
c                        a1.         .a3
c                          .         .
c                          ._________.
c                      sa1a2   a2   sa2a3
c
            a1 = arequa(lequad,1)
            a2 = arequa(lequad,2)
            a3 = arequa(lequad,3)
            a4 = arequa(lequad,4)
c
            call utsoqu ( somare, a1, a2, a3, a4,
     >                    sa1a2, sa2a3, sa3a4, sa4a1 )
cgn      write (ulsort,90002) 'sommets du pere',sa1a2, sa2a3, sa3a4, sa4a1
c
c 1.2. ==> Le noeud central
c
             lesomm = ninqua(lequad)
cgn      write (ulsort,90002) 'lesomm',lesomm
c
c 1.3. ==> les noeuds milieux des aretes
c
            n1 = np2are(a1)
            n2 = np2are(a2)
            n3 = np2are(a3)
            n4 = np2are(a4)
cgn      write (ulsort,90002) 'noeuds milieux ',n1, n2, n3, n4
c
c 1.2. ==> creation pour les fils
c
            lefils = filqua(lequad)
c
            do 12 , iaux = 0, 3
c
              if ( iaux.eq.0 ) then
                iaux1 = sa4a1
                iaux2 = n4
                iaux3 = n1
              elseif ( iaux.eq.1 ) then
                iaux1 = sa1a2
                iaux2 = n1
                iaux3 = n2
              elseif ( iaux.eq.2 ) then
                iaux1 = sa2a3
                iaux2 = n2
                iaux3 = n3
              else
                iaux1 = sa3a4
                iaux2 = n3
                iaux3 = n4
              endif
c
              indnoe = indnoe + 1
cgn        write (ulsort,90002) '==> Creation du noeud', indnoe
cgn        write (ulsort,90002) '    base sur', iaux1, iaux2, iaux3, lesomm
              ninqua(lefils+iaux) = indnoe
c
              if ( sdim.eq.2 ) then
                coonoe(indnoe,1) = unsqu *
     >          ( coonoe(iaux1,1) + coonoe(iaux2,1) +
     >            coonoe(iaux3,1) + coonoe(lesomm,1) )
                coonoe(indnoe,2) = unsqu *
     >          ( coonoe(iaux1,2) + coonoe(iaux2,2) +
     >            coonoe(iaux3,2) + coonoe(lesomm,2) )
              else
                coonoe(indnoe,1) = unsqu *
     >          ( coonoe(iaux1,1) + coonoe(iaux2,1) +
     >            coonoe(iaux3,1) + coonoe(lesomm,1) )
                coonoe(indnoe,2) = unsqu *
     >          ( coonoe(iaux1,2) + coonoe(iaux2,2) +
     >            coonoe(iaux3,2) + coonoe(lesomm,2) )
                coonoe(indnoe,3) = unsqu *
     >          ( coonoe(iaux1,3) + coonoe(iaux2,3) +
     >            coonoe(iaux3,3) + coonoe(lesomm,3) )
              endif
              hetnoe(indnoe) = 54
              famnoe(indnoe) = 1
              arenoe(indnoe) = 0
c
   12       continue
c
          endif
c
c====
c 2. Ce quadrangle vient d'etre coupe en 3 triangles : conformite
c====
c
        elseif ( option.eq.1 .and.
     >           ( etanp1.ge.31 .and. etanp1.le.34 ) ) then
c
cgn      write (ulsort,90015) 'Quadrangle', lequad, ' coupe en 3'
c
c 2.1. ==> determination des aretes et des sommets, relativement
c          au decoupage de l'arete
c        voir cmcdqu pour la convention
c                   S4=sa4a1   a4   sa3a4=S3
c                          ._________.
c                          .         .
c                          .         .
c                        a1.         .a3
c                          .         .
c                          ._________.
c                   S1=sa1a2   a2   sa2a3=S2
c
            a1 = arequa(lequad,1)
            a2 = arequa(lequad,2)
            a3 = arequa(lequad,3)
            a4 = arequa(lequad,4)
c
            call utcoq3 ( hetare, somare, filare, a1, a2, a3, a4,
     >                    numdec, ai, aj, ak, al, afij, afil,
     >                    saiaj, sajak, sakal, salai, ni,
     >                    ulsort, langue, codret )
cgn      write (ulsort,90002) 'numdec', numdec,etanp1
cgn      write (ulsort,90002) 'ni', ni
c
            call utsoqu ( somare, a1, a2, a3, a4,
     >                    sa1a2, sa2a3, sa3a4, sa4a1 )
cgn      write (ulsort,90002) 'sommets du pere',sa1a2, sa2a3, sa3a4, sa4a1
c
c 2.3. ==> creation pour les trois fils
c
            lefils = filqua(lequad)
cgn      write (ulsort,90002) 'lefils', lefils
c
            do 23 , iaux = 0, 2
c
              if ( iaux.eq.0 ) then
                iaux1 = sajak
                iaux2 = sakal
              elseif ( iaux.eq.1 ) then
                iaux1 = saiaj
                iaux2 = sajak
              else
                iaux1 = salai
                iaux2 = sakal
              endif
              indnoe = indnoe + 1
cgn        write (ulsort,90002) '==> Creation du noeud', indnoe
cgn        write (ulsort,90002) '    base sur', iaux1, iaux2, ni
              nintri(-lefils+iaux) = indnoe
c
              if ( sdim.eq.2 ) then
                coonoe(indnoe,1) = unstr *
     >          ( coonoe(iaux1,1) + coonoe(iaux2,1) + coonoe(ni,1) )
                coonoe(indnoe,2) = unstr *
     >          ( coonoe(iaux1,2) + coonoe(iaux2,2) + coonoe(ni,2) )
              else
                coonoe(indnoe,1) = unstr *
     >          ( coonoe(iaux1,1) + coonoe(iaux2,1) + coonoe(ni,1) )
                coonoe(indnoe,2) = unstr *
     >          ( coonoe(iaux1,2) + coonoe(iaux2,2) + coonoe(ni,2) )
                coonoe(indnoe,3) = unstr *
     >          ( coonoe(iaux1,3) + coonoe(iaux2,3) + coonoe(ni,3) )
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
