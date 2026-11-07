      subroutine utnoad ( coonoe,
     >                    hetnoe, arenoe, famnoe,
     >                    somare, np2are,
     >                    indnoe, nouvno,
     >                    nuarde, nuarfi )
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
c    UTilitaire - creation de NOeuds sur les Aretes Droites
c    --                       --             -      -
c ______________________________________________________________________
c
c but : creation des noeuds p2 (milieux) sur les nouvelles aretes
c       lorsque tous les elements sont a bords droits
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . somare . e   .2*nuarfi. numeros des extremites d'arete             .
c . np2are . es  . nuarfi . numero des noeuds p2 milieux d'aretes      .
c . famnoe . es  . nouvno . caracteristiques des noeuds                .
c . indnoe . es  . 1      . indice du dernier noeud cree               .
c . nouvno . e   . 1      . nombre total de noeuds a examiner          .
c . nuarde . e   . 1      . debut des numeros d'aretes a traiter       .
c . nuarfi . e   . 1      . fin des numeros d'aretes a traiter         .
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
#include "fracta.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer indnoe, nouvno
      integer nuarde, nuarfi
      integer hetnoe(nouvno), arenoe(nouvno)
      integer somare(2,nuarfi), np2are(nuarfi)
      integer famnoe(nouvno)
c
      double precision coonoe(nouvno,sdim)
c
c 0.4. ==> variables locales
c
      integer larete, s1, s2
c
#include "impr03.h"
c ______________________________________________________________________
c
c    creation des noeuds p2 sur les nouvelles aretes
c    on remarque que cette technique permet de garantir qu'un noeud p2
c    a toujours un numero superieur a ceux des deux extremites de
c    l'arete qui le porte.
c
c====
c 1. En deux dimensions
c====
c
      if ( sdim.eq.2 ) then
c
        do 11 , larete = nuarde , nuarfi
c
cgn      write (*,90002) 'Arete', larete
          if ( np2are(larete).eq.0 ) then
c
c           c'est une nouvelle arete, il faut creer le noeud p2
c
            indnoe = indnoe + 1
cgn      write (*,90002) '==> Creation du noeud', indnoe
            arenoe(indnoe) = larete
            np2are(larete) = indnoe
            s1 = somare(1,larete)
            s2 = somare(2,larete)
            coonoe(indnoe,1) = ( coonoe(s1,1) + coonoe(s2,1) ) * unsde
            coonoe(indnoe,2) = ( coonoe(s1,2) + coonoe(s2,2) ) * unsde
            hetnoe(indnoe) = 52
            famnoe(indnoe) = 1
c
          endif
c
   11   continue
c
c====
c 2. En trois dimensions
c====
c
      else
c
        do 21 , larete = nuarde , nuarfi
cgn        write(1,*) 'np2are(',larete, ') = ', np2are(larete)
cgn        write(1,*) 'arenoe(',indnoe, ') = ', arenoe(indnoe)
c
          if ( np2are(larete).eq.0 ) then
c
c           c'est une nouvelle arete, il faut creer le noeud p2
c
            indnoe = indnoe + 1
            arenoe(indnoe) = larete
            np2are(larete) = indnoe
            s1 = somare(1,larete)
            s2 = somare(2,larete)
            coonoe(indnoe,1) = ( coonoe(s1,1) + coonoe(s2,1) ) * unsde
            coonoe(indnoe,2) = ( coonoe(s1,2) + coonoe(s2,2) ) * unsde
            coonoe(indnoe,3) = ( coonoe(s1,3) + coonoe(s2,3) ) * unsde
            hetnoe(indnoe) = 52
            famnoe(indnoe) = 1
c
          endif
c
   21   continue
c
      endif
c
      end
