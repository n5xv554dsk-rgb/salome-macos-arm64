      subroutine deinod ( nivmin,
     >                    decare, decfac,
     >                    somare, hetare, filare,
     >                    np2are, posifa, facare,
     >                    aretri, hettri, nivtri,
     >                    arequa, hetqua, nivqua,
     >                    nosupp, noindi,
     >                    ulsort, langue, codret)
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
c traitement des DEcisions - Initialisation de l'indicateur entier
c                --          -
c                          - cas des NOeuds - Deraffinement
c                                    --       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nivmin . e   .   1    . niveau min a ne pas depasser en deraffinemt.
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . nosupp . e   . nbnoto . support pour les noeuds                    .
c . noindi . e   . nbnoto . valeurs entieres pour les noeuds           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEINOD' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nivmin
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer somare(2,nbarto), hetare(nbarto), filare(nbarto)
      integer aretri(nbtrto,3), hettri(nbtrto), nivtri(nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto), nivqua(nbquto)
      integer np2are(nbarto), posifa(0:nbarto), facare(nbfaar)
      integer nosupp(nbnoto), noindi(nbnoto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer somdec, etat
      integer larete, letria, lequad
      integer fille1, fille2
      integer iaux, jaux, kaux, ideb, ifin
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr05.h"
c
      codret = 0
cgn      print *,decare
cgn      print *,decfac
cgn         do 1999 , iaux = 1, nbnoto
cgn           if ( nosupp(iaux).ne.0 ) then
cgn           write (ulsort,*) iaux,noindi(iaux)
cgn           endif
cgn 1999    continue
c
c====
c 3. traitement des indicateurs portant sur les noeuds
c====
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,4)) mess14(langue,3,-1)
#endif
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,6))
#endif
c
        iaux = 0
c
        if ( degre.eq.1 ) then
c
          do 311 , larete = 1, nbarto
cgn        write(ulsort,*) 'Arete', larete, ', etat',hetare(larete)
            etat = mod(hetare(larete),10)
            if ( etat.ge.2 ) then
              fille1 = filare(larete)
              fille2 = fille1 + 1
              if ( nosupp(somare(1,fille1)).ne.0 .and.
     >             nosupp(somare(2,fille1)).ne.0 .and.
     >             nosupp(somare(1,fille2)).ne.0 ) then
                if ( noindi(somare(1,fille1)).eq.-1 .and.
     >               noindi(somare(2,fille1)).eq.-1 .and.
     >               noindi(somare(1,fille2)).eq.-1 ) then
                   ideb = posifa(larete-1)+1
                   ifin = posifa(larete)
                   jaux = 0
                   if ( ifin.ge.ideb ) then
                     if ( facare(ideb).gt.0 ) then
                       kaux = nivtri(facare(ideb))
                     else
                       kaux = nivqua(-facare(ideb))
                     endif
                     if ( kaux.lt.nivmin ) then
                       jaux = 1
                     endif
                   endif
                   if ( jaux.eq.0 ) then
cgn        write(ulsort,*) 'Arete', larete, ' a reactiver'
cgn     >, somare(1,fille1),somare(2,fille1),somare(1,fille2)
                     decare(larete) = -1
                   else
                     iaux = iaux + 1
                  endif
                endif
              endif
            endif
  311     continue
c
        else
c
          do 312 , larete = 1, nbarto
            etat = mod(hetare(larete),10)
            if ( etat.ge.2 ) then
              fille1 = filare(larete)
              fille2 = fille1 + 1
              if ( nosupp(somare(1,fille1)).ne.0 .and.
     >             nosupp(somare(2,fille1)).ne.0 .and.
     >             nosupp(somare(1,fille2)).ne.0 .and.
     >             nosupp(np2are(fille1))  .ne.0 .and.
     >             nosupp(np2are(fille2))  .ne.0 ) then
                if ( noindi(somare(1,fille1)).eq.-1 .and.
     >               noindi(somare(2,fille1)).eq.-1 .and.
     >               noindi(somare(1,fille2)).eq.-1 .and.
     >               noindi(np2are(fille1))  .eq.-1 .and.
     >               noindi(np2are(fille2))  .eq.-1 ) then
                  ideb = posifa(larete-1)+1
                  ifin = posifa(larete)
                  jaux = 0
                  if ( ifin.ge.ideb ) then
                    if ( facare(ideb).gt.0 ) then
                      kaux = nivtri(facare(ideb))
                    else
                      kaux = nivqua(-facare(ideb))
                    endif
                    if ( kaux.lt.nivmin ) then
                      jaux = 1
                    endif
                  endif
                  if ( jaux.eq.0 ) then
cgn        write(ulsort,*) 'Arete', larete, ' a reactiver'
cgn     >, somare(1,fille1),somare(2,fille1),somare(1,fille2)
                    decare(larete) = -1
                  else
                    iaux = iaux + 1
                  endif
                endif
              endif
            endif
  312     continue
c
        endif
c
        if ( iaux.ne.0 ) then
          write(ulsort,texte(langue,10))
          write(ulsort,texte(langue,4)) mess14(langue,3,-1)
          write(ulsort,texte(langue,8)) nivmin
          write(ulsort,texte(langue,9)) iaux
        endif
c
        do 313 , letria = 1, nbtrto
          etat = mod(hettri(letria),10)
          if ( etat.eq.4 .or.
     >         etat.eq.6 .or. etat.eq.7 .or. etat.eq.8 .or.
     >         etat.eq.9  ) then
            somdec = decare(aretri(letria,1))
     >             + decare(aretri(letria,2))
     >             + decare(aretri(letria,3))
            if (somdec.eq.-3) then
cgn        write(ulsort,*) 'Triangle', letria, ' a reactiver'
              decfac(letria) = -1
            endif
          endif
  313   continue
c
        do 314 , lequad = 1, nbquto
          etat = mod(hetqua(lequad),100)
          if ( etat.eq.4 .or.
     >         etat.eq.99  ) then
            somdec = decare(arequa(lequad,1))
     >             + decare(arequa(lequad,2))
     >             + decare(arequa(lequad,3))
     >             + decare(arequa(lequad,4))
            if (somdec.eq.-4) then
cgn        write(ulsort,*) 'Quadrangle', lequad, ' a reactiver'
              decfac(-lequad) = -1
            endif
          endif
  314   continue
c
c====
c 4. la fin
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
