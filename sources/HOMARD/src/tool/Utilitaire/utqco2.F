      subroutine utqco2 ( qual, coonoe,
     >                    are, somare, facare, posifa,
     >                    aretri, voltri,
     >                    tritet, cotrte, aretet, filtet, hettet )
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
c but : calcul de la qualite d'une coquille autour d'une arete qui vient
c     d'etre decoupee (on suppose donc que les tetraedres sont peres ou
c     grand-peres)
c ______________________________________________________________________
c
c   UTilitaire : Qualite d'une COquille (descendants d'ordre 2 au plus)
c   --           -             --                            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   .nbnoto*3. coordonnees des noeuds                     .
c .   are  . e   .   1    . numero de l'arete d'enroulement            .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . facare . es  . nbfaar . liste des faces contenant une arete        .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . aretri . es  .nbtrto*3. numeros des 3 aretes des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 tetraedres des faces         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . hettet . e   . nbtrto . historique de l'etat des tetraedres        .
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
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,3)
c
      integer are
      integer somare(2,nbarto), posifa(0:nbarto), facare(nbfaar)
      integer aretri(nbtrto,3), voltri(2,nbtrto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer filtet(nbteto), hettet(nbteto)
c
c 0.4. ==> variables locales
c
      integer etat
      integer ifa, fac
      integer nfils, ifils, nfil2, ifil2
      integer ite, tet, te2, tef
c
      double precision qual, qualte
      double precision daux, daux0
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      qual = 0.d0
c
c     boucle sur les faces de la coquille
c
      do 1 , ifa=posifa(are-1)+1,posifa(are)
c
         fac = facare(ifa)
c
c        recuperation des 2 tetraedres
c
         do 11 , ite=1,2
c
            tet = voltri(ite,fac)
c
            if (tet.gt.0) then
c
               if (filtet(tet).gt.0) then
c
c                 premier passage (sur 2)
c
                  etat = mod(hettet(tet),100)
                  if (etat.lt.30) then
                     nfils = 2
                  elseif (etat.lt.50) then
                     nfils = 4
                  elseif (etat.lt.60) then
                     nfils = 0
                  else
                     nfils = 8
                  endif
c
c                 qualite des descendants
c
                  do 111 , ifils=1,nfils
c
                     tef = filtet(tet)+ifils-1
c
                     if (filtet(tef).eq.0) then
c
c                       si le fils est actif : sa qualite
c
                        call utqtet ( tef, qualte, daux0, daux,
     >                                coonoe, somare, aretri,
     >                                tritet, cotrte, aretet )
                        qual = max ( qual, qualte )
                     else
c
c                       si le fils est inactif : petits-fils
c
                        etat = mod(hettet(tef),100)
                        if (etat.lt.30) then
                           nfil2 = 2
                        elseif (etat.lt.50) then
                           nfil2 = 4
                        elseif (etat.lt.60) then
                           nfil2 = 0
                        else
                           nfil2 = 8
                        endif
                        do 1111 , ifil2=1,nfil2
                          te2 = filtet(tef)+ifil2-1
                          call utqtet ( te2, qualte, daux0, daux,
     >                                  coonoe, somare, aretri,
     >                                  tritet, cotrte, aretet )
                        qual = max ( qual, qualte )
                          qual = max ( qual, qualte )
 1111                   continue
                     endif
c
  111             continue
c
               endif
c
               filtet(tet) = -filtet(tet)
c
            endif
c
   11    continue
c
    1 continue
c
      end
