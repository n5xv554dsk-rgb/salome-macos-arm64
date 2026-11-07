      subroutine deisfa ( ncmpin, usacmp,
     >                    trsupp, trindi, qusupp, quindi,
     >                    hetare, filare, merare,
     >                    posifa, facare,
     >                    hettri, aretri, hetqua, arequa,
     >                    tabent, tabree,
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
c    traitement des DEcisions - Initialisations - par Saut - FAces
c                   --          -                     -      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . trsupp . e   . nbtrto . support pour les triangles                 .
c . trindi . es  . nbtrto . valeurs reelles pour les triangles         .
c . qusupp . e   . nbquto . support pour les quadrangles               .
c . quindi . es  . nbquto . valeurs reelles pour les quadrangles       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . fils des aretes                            .
c . merare . e   . nbarto . pere des aretes                            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tabent . aux .   *    . tableau auxiliaire entier                  .
c . tabree . aux .   *    . tableau auxiliaire reel                    .
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
      parameter ( nompro = 'DEISFA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "infini.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer ncmpin
      integer usacmp
      integer trsupp(nbtrto), qusupp(nbquto)
      integer hetare(nbarto), filare(nbarto), merare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer tabent(*)
c
      integer ulsort, langue, codret
c
      double precision trindi(nbtrto,ncmpin), quindi(nbquto,ncmpin)
      double precision tabree(-nbquto:nbtrto,ncmpin)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer jdeb, jfin
      integer lgpile, nupile
      integer laface, larefa, larete
      integer merear
      integer nbarfa
      integer nrcomp
cgn      integer glop
c
      double precision daux1, daux2
      integer lgdaux
      parameter( lgdaux = 100 )
      double precision daux(lgdaux), vect(lgdaux)
c
      logical afaire
      logical calcul
c
      integer nbmess
      parameter (nbmess = 11 )
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
      texte(1,4) = '(''. Saut a la traversee des '',a)'
      texte(1,5) =
     > '(''On veut'',i6,'' composantes, mais taille de daux ='',i6)'
      texte(1,9) = '(''. Norme L2 des composantes.'')'
      texte(1,10) = '(''. Norme infinie des composantes.'')'
      texte(1,11) = '(''. Valeur relative de la composante.'')'
c
      texte(2,4) = '(''. Jump through the '',a)'
      texte(2,5) =
     > '(i6,''components are requested, but size of daux equals'',i6)'
      texte(2,9) = '(''. L2 norm of components.'')'
      texte(2,10) = '(''. Infinite norm of components.'')'
      texte(2,11) = '(''. Relative value for the component.'')'
cgn      print *, hettri
cgn      print *,  aretri
cgn      print *, hetqua
cgn      print *, arequa
c
#include "impr03.h"
c
      codret = 0
c
c 1.2. ==> controle
c
      if ( ncmpin.gt.lgdaux ) then
        write (ulsort,texte(langue,5)) ncmpin, lgdaux
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9+usacmp))
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1)
#endif
c
c====
c 2. sauvegarde de l'indicateur
c====
c
      if ( codret.eq.0 ) then
c
      do 211 , iaux = 1 , nbtrto
        if ( trsupp(iaux).ne.0 ) then
          do 2110 , nrcomp = 1 , ncmpin
            tabree(iaux,nrcomp) = trindi(iaux,nrcomp)
 2110     continue
        endif
  211 continue
c
      do 212 , iaux = 1 , nbquto
        if ( qusupp(iaux).ne.0 ) then
          do 2120 , nrcomp = 1 , ncmpin
            tabree(-iaux,nrcomp) = quindi(iaux,nrcomp)
 2120     continue
        endif
  212 continue
c
c====
c 3. traitement des indicateurs portant sur les faces
c====
c
      do 3 , laface = -nbquto , nbtrto
c
cgn        glop=0
c
c 3.0. ==> On y va ?
c
        afaire = .false.
        if ( laface.lt.0 ) then
          if ( qusupp(-laface).ne.0 ) then
            afaire = .true.
            nbarfa = 4
          endif
        elseif ( laface.gt.0 ) then
          if ( trsupp(laface).ne.0 ) then
            afaire = .true.
            nbarfa = 3
          endif
        endif
c
        if ( afaire ) then
c
cgn        if ( laface.ge.-42 .and. laface.le.49 ) then
cgn        glop = 1
cgn        endif
cgn        if ( glop.eq.1) then
cgn        print *,'==========================='
cgn        print *,'FACE = ',laface,', d''indic ',
cgn     > (tabree(laface,nrcomp),nrcomp=1,ncmpin)
cgn        endif
c
          daux1 = vinfne
c
          do 31 , iaux = 1 , nbarfa
c
c 3.1. ==> pour une des aretes de la face, on stocke les numeros
c            des faces voisines, en descendant les parentes.
c            ensuite, on stocke la premiere arete mere dont une des
c            faces voisines est active
c
c
            if ( laface.gt.0 ) then
              larefa = aretri(laface,iaux)
            else
              larefa = arequa(-laface,iaux)
            endif
cgn        if ( glop.eq.1) then
cgn          print *,'.', iaux,'-ieme arete de la face : ',larefa
cgn        endif
            lgpile = 1
            tabent(lgpile) = larefa
            nupile = 1
c
  310       continue
c
            larete = tabent(nupile)
            if ( mod(hetare(larete),10).ne.0 ) then
cgn        if ( glop.eq.1) then
cgn          print *,'..  des filles'
cgn        endif
              lgpile = lgpile + 1
              tabent(lgpile) = filare(larete)
              lgpile = lgpile + 1
              tabent(lgpile) = filare(larete) + 1
cgn        if ( glop.eq.1) then
cgn          print *,'.... ajout de ',tabent(lgpile), ' a la pile'
cgn        endif
            endif
c
            nupile = nupile + 1
            if ( nupile.le.lgpile ) then
              goto 310
            endif
c
c 3.2. ==> pour chaque arete de la pile : si elle est active, on
c            cherche le max de l'ecart entre la valeur de l'indicateur
c            sur la face voisine et celle sur la face courante
c
            do 32 , nupile = 1 , lgpile
              larete = tabent(nupile)
              if ( mod(hetare(larete),10).eq.0 ) then
cgn        if ( glop.eq.1) then
cgn       print *,'...... Examen de la pile, arete : ',larete
cgn        endif
                jdeb = posifa(larete-1)+1
                jfin = posifa(larete)
                do 321 , jaux = jdeb, jfin
                  kaux = facare(jaux)
                  if ( kaux.ne.laface ) then
cgn        if ( glop.eq.1) then
cgn          print *,'........ ==> face ', kaux,' : ',
cgn     > (tabree(kaux,nrcomp),nrcomp=1,ncmpin)
cgn        endif
                    calcul = .false.
                    if ( kaux.gt.0 ) then
                      if ( trsupp(kaux).ne.0 ) then
                        calcul = .true.
                        do 3211 , nrcomp = 1 , ncmpin
                          daux(nrcomp) = tabree(kaux,nrcomp)
     >                                 - tabree(laface,nrcomp)
 3211                   continue
                      endif
                    elseif ( kaux.lt.0 ) then
                      if ( qusupp(-kaux).ne.0 ) then
                        calcul = .true.
                        do 3212 , nrcomp = 1 , ncmpin
                          daux(nrcomp) = tabree(kaux,nrcomp)
     >                                 - tabree(laface,nrcomp)
 3212                   continue
                      endif
                    endif
                    if ( calcul ) then
c            calcul de la norme de l'ecart
c            si on a passe le max, on stocke
                      if ( usacmp.eq.0 ) then
                        daux2 = daux(1)**2
                        do 32111 , nrcomp = 2 , ncmpin
                          daux2 = daux2 + daux(nrcomp)**2
32111                   continue
                      elseif ( usacmp.eq.1 ) then
                        daux2 = abs(daux(1))
                        do 32112 , nrcomp = 2 , ncmpin
                          daux2 = max(daux2,abs(daux(nrcomp)))
32112                   continue
                      else
                        daux2 = daux(1)
                      endif
                      if ( daux2.gt.daux1 ) then
                        daux1 = daux2
                        do 3213 , nrcomp = 1 , ncmpin
                          vect(nrcomp) = daux(nrcomp)
 3213                   continue
                      endif
                    endif
cgn        if ( glop.eq.1) then
cgn          print *,'........ daux1 ', daux1
cgn        endif
                  endif
  321           continue
cgn         if ( glop.eq.1) then
cgn          print *,'...... ==> valeur finale =', daux1
cgn        endif
             endif
   32      continue
c
c 3.3. ==> on remonte la parente pour pieger les non-conformites
c
            larete = larefa
c
   33       continue
c
            merear = merare(larete)
            if ( merear.gt.0 ) then
cgn        if ( glop.eq.1) then
cgn          print *,'......', larete,' a une mere : ',merear
cgn        endif
              jdeb = posifa(merear-1)+1
              jfin = posifa(merear)
              if ( jdeb.gt.jfin ) then
                larete = merear
                goto 33
              else
                do 331 , jaux = jdeb, jfin
                  kaux = facare(jaux)
                  if ( kaux.ne.laface ) then
cgn        if ( glop.eq.1) then
cgn          print *,'.......... ==> face ', kaux,' : ',
cgn     > (tabree(kaux,nrcomp),nrcomp=1,ncmpin)
cgn        endif
                    calcul = .false.
                    if ( kaux.gt.0 ) then
                      if ( mod(hettri(kaux),10).eq.0 ) then
                        if ( trsupp(kaux).ne.0 ) then
                          calcul = .true.
                          do 3311 , nrcomp = 1 , ncmpin
                            daux(nrcomp) = tabree(kaux,nrcomp)
     >                                   - tabree(laface,nrcomp)
 3311                     continue
                        endif
                      endif
                    elseif ( kaux.lt.0 ) then
                      if ( mod(hetqua(-kaux),100).eq.0 ) then
                        if ( qusupp(-kaux).ne.0 ) then
                          calcul = .true.
                          do 3312 , nrcomp = 1 , ncmpin
                            daux(nrcomp) = tabree(kaux,nrcomp)
     >                                   - tabree(laface,nrcomp)
 3312                     continue
                        endif
                      endif
                    endif
                    if ( calcul ) then
                      if ( usacmp.eq.0 ) then
                        daux2 = daux(1)**2
                        do 33111 , nrcomp = 2 , ncmpin
                          daux2 = daux2 + daux(nrcomp)**2
33111                   continue
                      elseif ( usacmp.eq.1 ) then
                        daux2 = abs(daux(1))
                        do 33112 , nrcomp = 2 , ncmpin
                          daux2 = max(daux2,abs(daux(nrcomp)))
33112                   continue
                      else
                        daux2 = daux(1)
                      endif
                      if ( daux2.gt.daux1 ) then
                        daux1 = daux2
                        do 3313 , nrcomp = 1 , ncmpin
                          vect(nrcomp) = daux(nrcomp)
 3313                   continue
                      endif
                    endif
cgn        if ( glop.eq.1) then
cgn          print *,'.......... daux1 ', daux1
cgn        endif
                  endif
  331           continue
cgn         if ( glop.eq.1) then
cgn          print *,'........ ==> valeur finale =', daux1
cgn        endif
              endif
            endif
c
   31     continue
c
c 3.4. ==> stockage
c
cgn      if ( glop.eq.1) then
cgn       write(ulsort,20000) 'Final    '//
cgn     > 'face', laface,' : ',
cgn     > mess14(langue,1,typenh), laface,' : ',
cgn     > (vect(nrcomp),nrcomp=1,ncmpin)
cgn      endif
          if ( laface.gt.0 ) then
            do 341 , nrcomp = 1 , ncmpin
              trindi(laface,nrcomp) = vect(nrcomp)
  341       continue
          else
            do 342 , nrcomp = 1 , ncmpin
              quindi(-laface,nrcomp) = vect(nrcomp)
  342       continue
          endif
c
        endif
c
    3 continue
c
      endif
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
      write (ulsort,texte(langue,4)) mess14(langue,3,1)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
