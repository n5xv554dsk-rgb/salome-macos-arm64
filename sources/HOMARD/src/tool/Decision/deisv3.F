      subroutine deisv3 ( laface, tyface,
     >                    hettri, filtri,
     >                    hetqua, filqua,
     >                    lgpile, tabent,
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
c    traitement des DEcisions - Initialisations - par Saut - Volumes - 1
c                   --          -                     -      -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . laface . e   .   1    . numero de la face a traiter                .
c . tyface . e   .   1    . type de la face a traiter                  .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . fils des quadrangles                       .
c . lgpile .  s  .   1    . longueur de la pile                        .
c . tabent .  s  .  (2,*) . tabent(1,i) = numero de la i-eme face      .
c .        .     .        . tabent(2,i) = type de la i-eme face        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : mauvais typenh                         .
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
      parameter ( nompro = 'DEISV3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer laface, tyface
c
      integer hettri(nbtrto), filtri(nbtrto)
      integer hetqua(nbquto), filqua(nbquto)
      integer lgpile
      integer tabent(2,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer etat, fils
      integer nupile
cgn      integer glop
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
c 1.1. ==> Les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > ' (''Reperage des faces actives liees a la face'',i10)'
c
      texte(2,4) =
     > '(''List of the active faces linked to the face #'',i10)'
c
 1000 format ( 'Faces :',10i10)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) laface
#endif
c
      codret = 0
c
c====
c 2. On stocke les numeros des faces, en descendant les parentes.
c    Au final, on stocke la premiere face mere active
c====
c
cgn      glop = 0
      lgpile = 1
      tabent(1,lgpile) = laface
      tabent(2,lgpile) = tyface
      nupile = 1
c
    2 continue
c
      laface = tabent(1,nupile)
      tyface = tabent(2,nupile)
c
cgn      if ( glop.eq.10) then
cgn        write(ulsort,*)'..laface = ',laface
cgn      endif
c
c 2.1. ==> reperage du fils selon la face
c
      fils = 0
      if ( tyface.eq.2 ) then
        etat = mod(hettri(laface),10)
        if ( etat.ne.0 ) then
          fils = filtri(laface)
        endif
      else
        etat = mod(hetqua(laface),100)
        if ( etat.ne.0 ) then
          fils = filqua(laface)
        endif
      endif
c
c 2.2. ==> complement dans la pile
c
      if ( fils.ne.0 ) then
c
cgn        if ( glop.eq.1) then
cgn          write(ulsort,*)'..  des fils'
cgn        endif
        do 22 , iaux = 0, 3
          lgpile = lgpile + 1
          tabent(1,lgpile) = fils + iaux
          tabent(2,lgpile) = tyface
cgn        if ( glop.eq.1) then
cgn          write(ulsort,*)'.... ajout de ',tabent(1,lgpile),
cgn     >         ' a la pile'
cgn        endif
   22   continue
c
      endif
c
c 2.3. ==> suite de l'exploration de la pile
c
      nupile = nupile + 1
      if ( nupile.le.lgpile ) then
        goto 2
      endif
#ifdef _DEBUG_HOMARD_
cgn        if ( glop.eq.1) then
cgn      write (ulsort,1000) (tabent(1,iaux),iaux=1,lgpile)
cgn        endif
#endif
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
