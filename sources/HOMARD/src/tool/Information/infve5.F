      subroutine infve5 ( typenh, nbfato, volfac, pypefa,
     >                    hetfac,
     >                    numniv, numblo, nubnvo,
     >                    tbaux2,
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
c   INformation : Fichier VEctoriel - 5eme partie
c   --            -       --          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   4 : quadrangles                          .
c . nbfato . e   .   1    .nombre de faces total                       .
c . volfac . e   .2*nbfato. numeros des 2 volumes par face             .
c .        .     .        . volfac(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre/tetraedre j                 .
c .        .     .        . j<0 : pyramide/pentaedre dans pypefa(1/2,j).
c . pypefa . e   .2*lgpype. pypefa(1,j) = numero de la pyramide voisine.
c .        .     .        . de la face k tel que volfac(1/2,k) = -j    .
c .        .     .        . pypefa(2,j) = numero du pentaedre voisin   .
c .        .     .        . de la face k tel que volfac(1/2,k) = -j    .
c . hetfac . e   . nbfato . historique de l'etat des faces             .
c . numniv . e   .   1    . numero du niveau a tracer                  .
c .        .     .        . -1 : tous les niveaux                      .
c . numblo . e   .   1    . numero du bloc a tracer                    .
c .        .     .        . 0 : trace du domaine global                .
c . nubnvo . e   .   *    . . si numblo>0 : numero de blocs des volumes.
c .        .     .        . . si numniv >=0 : niveau des volumes       .
c .        .     .        . Rangement :                                .
c .        .     .        . les tetraedres                             .
c .        .     .        . les hexaedres                              .
c .        .     .        . les pyramides                              .
c .        .     .        . les pentaedres                             .
c . tbaux2 . es  .-nbquto:. tableau de travail                         .
c .        .     .nbt/arto.                                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      character*6 nompro
      parameter ( nompro = 'INFVE5' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh, nbfato
      integer volfac(2,nbfato), pypefa(2,*)
      integer hetfac(nbfato)
      integer numniv, numblo, nubnvo(*)
      integer tbaux2(-nbquto:*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer maxtet, maxhex, maxpyr
      integer dectet, dechex, decpyr, decpen, decvol
      integer nument, etaent, numen2
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c_______________________________________________________________________
c
c====
c 1. prealables
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,''Trace du domaine global'')'
      texte(1,5) = '(/,''Examen du '',a,'' numero'',i6)'
      texte(1,6) = '(''Trace de tous les niveaux'')'
      texte(1,7) = '(''Trace du niveau numero'',i6)'
      texte(1,8) = '(''Recherche des '',a,'' a tracer'')'
c
      texte(2,4) = '(/,''Writings of the whole domain)'
      texte(2,5) = '(/,''Examination of '',a,'' #'',i6)'
      texte(2,6) = '(''Writings of all the levels'')'
      texte(2,7) = '(''Writings for the level #'',i6)'
      texte(2,8) = '(''Search of the '',a,'' for plotting'')'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      if ( numblo.eq.0 ) then
        write (ulsort,texte(langue,4))
      else
        write (ulsort,texte(langue,5)) numblo
      endif
      if ( numniv.eq.-1 ) then
        write (ulsort,texte(langue,6))
      else
        write (ulsort,texte(langue,7)) numniv
      endif
      write (ulsort,texte(langue,8)) mess14(langue,3,typenh)
#endif
c
c 1.2. ==> decalages
c
      dectet = 0
      maxtet = dectet + nbteto
      dechex = maxtet
      maxhex = dechex + nbheto
      decpyr = maxhex
      maxpyr = decpyr + nbpyto
      decpen = maxpyr
c
c 1.3. ==> Particularites selon le type de mailles tria/quad :
c          . Diviseur pour trouver l'etat actif
c          . Decalage dans la numerotation des volumes
c
      if ( typenh.eq.2 ) then
        etaent = 10
        decvol = dectet
      else
        etaent = 100
        decvol = dechex
      endif
c
c====
c 2. Recherche des faces a tracer :
c    On trace une face seulement si elle est active et
c    . si elle appartient a une region bidimensionnelle du maillage, et
c      si elle appartient au bloc ou au niveau retenu
c    . si elle est une face ayant un et un seul element volumique
c      voisin, et si ce volume appartient au bloc ou au niveau retenu
c    . si elle est une face ayant deux elements volumiques voisins,
c      et si un et un seul des volumes appartient au bloc ou au niveau
c      retenu
c
c    La convention est la suivante :
c    * tbaux2(iaux) vaut 0 si la face est d'une region 2D, du bloc ou
c      du niveau retenu
c    * tbaux2(iaux) vaut 1 si la face borde un domaine volumique, du
c      bloc ou du niveau retenu
c    * tbaux2(iaux) vaut 2 si la face est interne a un domaine
c      volumique, un et un seul des voisins appartenant au bloc ou au
c      niveau retenu
c    * tbaux2(iaux) vaut -1 sinon
c    On tracera donc pour tbaux2(iaux) >= 0
c====
c
c 2.1. ==> Cas du domaine global avec tous les niveaux
c          On examine les faces actives et on retient celles avec au
c          plus un voisin
c
      if ( numblo.eq.0 .and. numniv.eq.-1 ) then
c
        do 21 , iaux = 1, nbfato
#ifdef _DEBUG_HOMARD_
       write (ulsort,texte(langue,5)) mess14(langue,1,typenh), iaux
       write (ulsort,90002) 'voisins', volfac(1,iaux),volfac(2,iaux)
#endif
c
c         . La face est active
          if ( mod(hetfac(iaux),etaent).eq.0 ) then
c
c           . La face n'a pas deux voisins
            if ( volfac(2,iaux).eq.0 ) then
c
              if ( typenh.eq.2 ) then
                jaux = iaux
              else
                jaux = -iaux
              endif
c             . La face est 2D
              if ( volfac(1,iaux).eq.0 ) then
                tbaux2(jaux) = 0
c             . La face a un seul voisin
              else
                tbaux2(jaux) = 1
              endif
c
            endif
c
          endif
c
   21   continue
c
c 2.2. ==> Cas d'un filtrage par bloc volumique
c          On examine les faces actives et on retient celles avec au
c          plus un voisin, ce voisin etant du bon bloc
c          Remarque : avec deux voisins, le bloc est forcement le meme
c
      elseif ( numblo.gt.0 ) then
c
        do 22 , iaux = 1, nbfato
c
c         . La face est active
          if ( mod(hetfac(iaux),etaent).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
       if ( typenh.eq.2 ) then
         jaux = iaux
       else
         jaux = -iaux
       endif
       write (ulsort,90002) mess14(langue,2,typenh), iaux, tbaux2(jaux)
#endif
c
c           . La face n'a pas deux voisins
            if ( volfac(2,iaux).eq.0 ) then
#ifdef _DEBUG_HOMARD_
       write (ulsort,90002) '. voisins',volfac(1,iaux),volfac(2,iaux)
#endif
c
c           . La face a un seul voisin
              kaux = volfac(1,iaux)
              if ( kaux.ne.0 ) then
c
c 2.2.1. ==> reperage du numero d'entite de ce voisin, avec le decalage
c            pour le reperage des blocs
c
                if ( kaux.gt.0 ) then
                  nument = decvol + kaux
                else
                  if ( pypefa(1,-kaux).ne.0 ) then
                    nument = decpyr + pypefa(1,-kaux)
                  else
                    nument = decpen + pypefa(2,-kaux)
                  endif
                endif
cgn      write (ulsort,90002)
cgn     > '. '//mess14(langue,1,3),nument,nubnvo(nument)
c
c 2.2.2. ==> Choix en fonction du bloc du voisin
c
                if ( nubnvo(nument).eq.numblo ) then
                  if ( typenh.eq.2 ) then
                    jaux = iaux
                  else
                    jaux = -iaux
                  endif
                  tbaux2(jaux) = 1
                endif
c
              endif
c
            endif
c
          endif
#ifdef _DEBUG_HOMARD_
       if ( typenh.eq.2 ) then
         jaux = iaux
       else
         jaux = -iaux
       endif
       if ( tbaux2(jaux).ne.-1 ) then
       write (ulsort,90002) '==> On la trace', tbaux2(jaux)
       endif
#endif
c
   22   continue
c
c 2.3. ==> Cas d'un filtrage par niveau
c          On examine les faces actives et on retient celles :
c          . avec un seul voisin, ce voisin etant du bon niveau
c          . avec deux voisins, un et un seul des voisins etant
c            du bon niveau
c
      else
c
        do 23 , iaux = 1, nbfato
c
c         . La face est active
          if ( mod(hetfac(iaux),etaent).eq.0 ) then
c
c           . La face a au moins un voisin
            kaux = volfac(1,iaux)
            if ( kaux.ne.0 ) then
c
c 2.3.1. ==> reperage du numero d'entite de ce voisin, avec le decalage
c            pour le reperage des blocs
c
              if ( kaux.gt.0 ) then
                nument = decvol + kaux
              else
                if ( pypefa(1,-kaux).ne.0 ) then
                  nument = decpyr + pypefa(1,-kaux)
                else
                  nument = decpen + pypefa(2,-kaux)
                endif
              endif
c
c 2.3.2. ==> . La face a un seul voisin : choix en fonction du niveau
c
              laux = volfac(2,iaux)
              if ( laux.eq.0 ) then
c
                if ( nubnvo(nument).eq.numniv ) then
                  if ( typenh.eq.2 ) then
                    jaux = iaux
                  else
                    jaux = -iaux
                  endif
                  tbaux2(jaux) = 1
                endif
c
c 2.3.3. ==> . La face a 2 voisins : choix en fonction de leurs niveaux
c
              else
c
                if ( laux.gt.0 ) then
                  numen2 = decvol + laux
                else
                  if ( kaux.eq.laux ) then
                    numen2 = decpen + pypefa(2,-laux)
                  else
                    if ( pypefa(1,-laux).ne.0 ) then
                      numen2 = decpyr + pypefa(1,-laux)
                    else
                      numen2 = decpen + pypefa(2,-laux)
                    endif
                  endif
                endif
                if ( nubnvo(nument).eq.numniv .or.
     >               nubnvo(numen2).eq.numniv ) then
                  if ( nubnvo(nument).ne.nubnvo(numen2) ) then
                    if ( typenh.eq.2 ) then
                      jaux = iaux
                    else
                      jaux = -iaux
                    endif
                    tbaux2(jaux) = 2
                  endif
                endif
c
              endif
c
            endif
c
          endif
c
   23   continue
c
      endif
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
