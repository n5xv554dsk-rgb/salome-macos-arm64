      subroutine cmcact ( hetnoe,
     >                    filare,
     >                    filtri, nivtri,
     >                    filqua, nivqua,
     >                    filtet, filhex, filpyr, filpen,
     >                    nvacar, nvactr, nvacqu,
     >                    nvacte, nvache, nvacpy, nvacpe,
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
c    Creation du Maillage - Comptage des entites ACTives du maillage
c    -           -          -                    ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetnoe . e   . nouvno . historique de l'etat des noeuds            .
c . filare . e   . nouvar . premiere fille des aretes                  .
c . filtri . e   . nouvtr . premier fils des triangles                 .
c . nivtri . e   . nouvtr . niveau des triangles                       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . nivqua . e   . nouvqu . niveau des quadrangles                     .
c . filtet . e   . nouvte . premier fils des tetraedres                .
c . filhex . e   . nouvhe . premier fils des hexaedres                 .
c . filpyr . e   . nouvpy . premier fils des pyramides                 .
c . filpen . e   . nouvpe . premier fils des pentaedres                .
c . nvacar .  s  . 1      . nouveau nombre d'aretes actives            .
c . nvactr .  s  . 1      . nouveau nombre de triangles actifs         .
c . nvacqu .  s  . 1      . nouveau nombre de quadrangles actifs       .
c . nvacte .  s  . 1      . nouveau nombre de tetraedres actifs        .
c . nvache .  s  . 1      . nouveau nombre de hexaedres actifs         .
c . nvacpy .  s  . 1      . nouveau nombre de pyramides actives        .
c . nvacpe .  s  . 1      . nouveau nombre de pentaedres actifs        .
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
      parameter ( nompro = 'CMCACT' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envada.h"
#include "nombno.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer hetnoe(nouvno)
      integer filare(nouvar)
      integer filtri(nouvtr), nivtri(nouvtr)
      integer filqua(nouvqu), nivqua(nouvqu)
      integer filtet(nouvte), filhex(nouvhe)
      integer filpyr(nouvpy), filpen(nouvpe)
      integer nvacar, nvactr, nvacqu, nvacte, nvache, nvacpy, nvacpe
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, ideb, ifin
      integer nvmatr, nvmitr, niinct, nisuct
      integer nvmaqu, nvmiqu, niincq, nisucq
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
c====
c 2. numeros mini/maxi des noeuds p1
c====
c
      do 21 , iaux = 1 , nouvno
        if ( mod(hetnoe(iaux),10).eq.1 ) then
          numip1 = iaux
          goto 22
        endif
   21 continue
c
   22 continue
c
      do 23 , iaux = nouvno, 1, -1
        if ( mod(hetnoe(iaux),10).eq.1 ) then
          numap1 = iaux
          goto 24
        endif
   23 continue
c
   24 continue
c
c====
c 3. comptage des aretes actives
c====
c
      nvacar = provar
      do 30 , iaux = 1 , permar
        if ( filare(iaux).eq.0 ) then
          nvacar = nvacar + 1
        endif
   30 continue
c
c====
c 4. comptage des triangles actifs
c    recuperation de leurs niveaux minimum et maximum
c====
c
      if ( nouvtr.ne.0 ) then
c
cgn      write (ulsort,90002) 'permtr, provtr', permtr, provtr
c
c 4.1. ==> on initialise les niveaux extremes en cherchant le premier
c          triangle actif parmi les permanents et les provisoires.
c          cela permet d'englober les cas de maillages avec ou sans
c          triangles au depart.
c          remarque : ce triangle est revu par la suite et cela fait
c          gaspiller un appel a min/max mais l'algorithme est plus
c          lisible ainsi.
c
        do 41 , iaux = 1 , permtr
          if ( filtri(iaux).eq.0 ) then
            nvmitr = nivtri(iaux)
            nvmatr = nivtri(iaux)
            ideb = iaux
            goto 420
          endif
   41   continue
c
        nvmitr = nbiter+1
        nvmatr = 0
        ideb = 1
c
c 4.2. ==> examen des triangles permanents
c
  420   continue
c
        nvactr = 0
        do 42 , iaux = ideb , permtr
          if ( filtri(iaux).eq.0 ) then
            nvactr = nvactr + 1
          endif
          nvmitr = min( nvmitr, nivtri(iaux) )
          nvmatr = max( nvmatr, nivtri(iaux) )
   42   continue
c
        niinct = 10*nvmitr
        nisuct = 10*nvmatr
c
c 4.3. ==> examen des triangles temporaires
c
        ideb = permtr + 1
        ifin = permtr + provtr
        do 43 , iaux = ideb , ifin
          nvactr = nvactr + 1
          niinct = min( niinct, 10*nivtri(iaux) - 5 )
          nisuct = max( nisuct, 10*nivtri(iaux) - 5 )
   43   continue
c
      else
c
        nvactr = 0
c
      endif
c
c====
c 5. comptage des quadrangles actifs
c    recuperation de leurs niveaux minimum et maximum
c====
c
      if ( nouvqu.ne.0 ) then
c
cgn      write (ulsort,90002) 'permqu, provqu', permqu, provqu
c
c 5.1. ==> on initialise les niveaux extremes en cherchant le premier
c          quadrangle actif parmi les permanents.
c          remarque : ce quadrangle est revu par la suite et cela fait
c          gaspiller un appel a min/max mais l'algorithme est plus
c          lisible ainsi.
c
        do 51 , iaux = 1 , permqu
          if ( filqua(iaux).eq.0 ) then
            nvmiqu = nivqua(iaux)
            nvmaqu = nivqua(iaux)
            ideb = iaux
            goto 520
          endif
   51   continue
c
        nvmiqu = nbiter+1
        nvmaqu = 0
        ideb = 1
c
c 5.2. ==> examen des quadrangles permanents
c
  520   continue
c
        nvacqu = 0
        do 52 , iaux = ideb , permqu
          if ( filqua(iaux).eq.0 ) then
            nvacqu = nvacqu + 1
          endif
          nvmiqu = min( nvmiqu, nivqua(iaux) )
          nvmaqu = max( nvmaqu, nivqua(iaux) )
   52   continue
c
        niincq = 10*nvmiqu
        nisucq = 10*nvmaqu
c
c 5.3. ==> examen des quadrangles temporaires
c
        ideb = permqu + 1
        ifin = permqu + provqu
        do 53 , iaux = ideb , ifin
          nvacqu = nvacqu + 1
          niincq = min( niincq, 10*nivqua(iaux) - 5 )
          nisucq = max( nisucq, 10*nivqua(iaux) - 5 )
   53   continue
c
      else
c
        nvacqu = 0
c
      endif
c
c====
c 6. comptage des tetraedres actifs
c====
c
      if ( nouvte.ne.0 ) then
c
        nvacte = provte
        do 60 , iaux = 1 , permte
          if ( filtet(iaux).eq.0 ) then
            nvacte = nvacte + 1
          endif
   60   continue
c
      else
c
        nvacte = 0
c
      endif
c
c====
c 7. comptage des hexaedres actifs
c====
c
      if ( nouvhe.ne.0 ) then
c
        nvache = provhe
        do 70 , iaux = 1 , permhe
          if ( filhex(iaux).eq.0 ) then
            nvache = nvache + 1
          endif
   70   continue
c
      else
c
        nvache = 0
c
      endif
c
c====
c 8. comptage des pyramides actives
c====
c
      if ( nouvpy.ne.0 ) then
c
        nvacpy = provpy
        do 80 , iaux = 1 , permpy
          if ( filpyr(iaux).eq.0 ) then
            nvacpy = nvacpy + 1
          endif
   80   continue
c
      else
c
        nvacpy = 0
c
      endif
c
c====
c 9. comptage des pentaedres actifs
c====
c
      if ( nouvpe.ne.0 ) then
c
        nvacpe = provpe
        do 90 , iaux = 1 , permpe
          if ( filpen(iaux).eq.0 ) then
            nvacpe = nvacpe + 1
          endif
   90   continue
c
      else
c
        nvacpe = 0
c
      endif
c
c====
c 10. bilan sur les niveaux
c    remarque : il y a toujours ou des triangles ou des quadrangles
c               sinon la notion de niveau ne s'applique pas
c====
c
cgn      write (ulsort,90002) 'nvmatr, nvmitr, niinct, nisuct',
cgn     >                      nvmatr, nvmitr, niinct, nisuct
cgn      write (ulsort,90002) 'nvmaqu, nvmiqu, niincq, nisucq',
cgn     >                      nvmaqu, nvmiqu, niincq, nisucq
      if ( nouvqu.eq.0 ) then
        nivinf = nvmitr
        nivsup = nvmatr
        niincf = niinct
        nisucf = nisuct
      elseif ( nouvtr.eq.0 ) then
        nivinf = nvmiqu
        nivsup = nvmaqu
        niincf = niincq
        nisucf = nisucq
      else
        nivinf = min(nvmiqu,nvmitr)
        nivsup = max(nvmaqu,nvmatr)
        niincf = max(niinct,niincq)
        nisucf = max(nisuct,nisucq)
      endif
cgn      write (ulsort,90002) 'nivinf', nivinf
cgn      write (ulsort,90002) 'nivsup', nivsup
cgn      write (ulsort,90002) 'niincf', niincf
cgn      write (ulsort,90002) 'nisucf', nisucf
c
c====
c 11 la fin
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
