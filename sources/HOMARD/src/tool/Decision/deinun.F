      subroutine deinun ( pilraf, pilder, nivmax, nivmin,
     >                    decfac, decare,
     >                    hetare,
     >                    hettri,
     >                    hetqua,
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
c traitement des DEcisions - INitialisation si UNiforme
c                --          --                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . pilraf . e   .   1    . pilotage du raffinement                    .
c .        .     .        . -1 : raffinement uniforme                  .
c .        .     .        .  0 : pas de raffinement                    .
c .        .     .        .  1 : raffinement libre                     .
c .        .     .        .  2 : raff. libre homogene en type d'element.
c . pilder . e   .   1    . pilotage du deraffinement                  .
c .        .     .        . 0 : pas de deraffinement                   .
c .        .     .        . 1 : deraffinement libre                    .
c .        .     .        . -1 : deraffinement uniforme                .
c . nivmax . e   .   1    . niveau max a ne pas depasser en raffinement.
c . nivmin . e   .   1    . niveau min a ne pas depasser en deraffinemt.
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : impossible de raffiner                 .
c .        .     .        . 5 : impossible de deraffiner               .
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
      parameter ( nompro = 'DEINUN' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envada.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer pilraf, pilder, nivmax, nivmin
      integer decfac(-nbquto:nbtrto)
      integer decare(0:nbarto)
      integer hetare(nbarto)
      integer hettri(nbtrto)
      integer hetqua(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer larete, letria, lequad
      integer etat
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(/,5x,''Niveau '',a7,'' dans le maillage :'',i6)'
      texte(1,5) = '(/,5x,''Niveau '',a7,'' voulu            :'',i6)'
      texte(1,6) = '(5x,''Raffinement uniforme'')'
      texte(1,7) = '(5x,''Deraffinement uniforme'')'
      texte(1,10) = '(/,5x,''--> Traitement impossible.'')'
c
      texte(2,4) = '(/,5x,a7,''level in the mesh :'',i6)'
      texte(2,5) = '(/,5x,a7,''level wanted      :'',i6)'
      texte(2,6) = '(5x,''Uniform refinement'')'
      texte(2,7) = '(5x,''Uniform unrefinement'')'
      texte(2,10) = '(/,5x,''--> Treatment cannot be done.'')'
c
c 1.2. ==> Controle des niveaux extremes du maillage courant
c
      if ( pilraf.eq.-1 .and. nivmax.ge.0 ) then
        if ( nivsup.ge.nivmax ) then
          write (ulsort,texte(langue,4)) 'maximum', nivsup
          write (ulsort,texte(langue,5)) 'maximum', nivmax
          write (ulsort,texte(langue,10))
          codret = 1
        endif
      endif
c
      if ( pilder.eq.-1 .and. nivmin.ge.0 ) then
        if ( nivinf.le.nivmin ) then
          write (ulsort,texte(langue,4)) 'minimum', nivinf
          write (ulsort,texte(langue,5)) 'minimum', nivmin
          write (ulsort,texte(langue,10))
          codret = 5
        endif
      endif
c
c====
c 2. Decisions de raffinement uniforme sur aretes et faces actives
c====
c
      if ( pilraf.eq.-1 ) then
c
        write(ulsort,texte(langue,6))
c
        do 21 , larete = 1, nbarto
          if ( mod(hetare(larete),10).eq.0 ) then
            decare (larete) = 2
          endif
   21   continue
c
        do 22 , letria = 1, nbtrto
          if ( mod(hettri(letria),10).eq.0 ) then
            decfac (letria) = 4
          endif
   22   continue
c
        do 23 , lequad = 1, nbquto
          if ( mod(hetqua(lequad),100).eq.0 ) then
            decfac (-lequad) = 4
          endif
   23   continue
c
      endif
c
c====
c 3. deraffinement uniforme
c====
c
      if ( pilder.eq.-1 ) then
c
        write(ulsort,texte(langue,7))
c
        do 31 , larete = 1, nbarto
          if ( mod(hetare(larete),10).eq.2 ) then
            decare (larete) = -1
          endif
   31   continue
c
        do 32 , letria = 1, nbtrto
          etat = mod(hettri(letria),10)
          if ( etat.eq.4 .or.
     >         etat.eq.6 .or. etat.eq.7 .or. etat.eq.8 ) then
            decfac (letria) = -1
          endif
   32   continue
c
        do 33 , lequad = 1, nbquto
          if ( mod(hetqua(lequad),100).eq.4 ) then
            decfac (-lequad) = -1
          endif
   33   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
cgn      letria = 824
cgn      write (ulsort,*) 'tri', letria, hettri(letria), decfac(letria)
cgn      larete = 17736
cgn      write (ulsort,*) 'are', larete, hetare(larete), decare(larete)
#endif
c
c====
c 4. La fin
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
