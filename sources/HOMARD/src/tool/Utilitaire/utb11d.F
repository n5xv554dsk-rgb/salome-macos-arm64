      subroutine utb11d ( nbbloc, option, tabau4,
     >                    hetare, somare,
     >                    povoso, voisom,
     >                    famare, cfaare,
     >                    lapile, tabau2,
     >                    nublar,
     >                    ulbila,
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
c    UTilitaire - Bilan sur le maillage - option 11 - phase d
c    --           -                              --         -
c ______________________________________________________________________
c
c    analyse de la connexite des aretes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbbloc .  s  .   1    . nombre de blocs                            .
c . option . e   .   1    . 0 : on prend toutes les aretes             .
c .        .     .        . 1 : on prend les aretes actives de HOMARD  .
c .        .     .        . 2 : on prend les aretes actives du calcul  .
c . tabau4 . e   . nbarto . indicateurs sur les aretes a examiner :    .
c .        .     .        .  0 : on ne traite pas l'arete              .
c .        .     .        . >0 : on traite l'arete                     .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . povoso . e   .0:nbnoto. pointeur des voisins par noeud             .
c . voisom . e   . nvosom . aretes voisines de chaque noeud            .
c . famare . e   . nbarto . famille des aretes                         .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . lapile .  a  .   *    . tableau de travail                         .
c . tabau2 .  a  . nbnoto . tableau de travail                         .
c . nublar .  s  . nbarto . numero du bloc pour chaque arete           .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c .        .     .        . si 0 : on n'ecrit rien                     .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB11D' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
c
#include "dicfen.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbbloc, option
      integer tabau4(nbarto)
      integer hetare(nbarto), somare(2,nbarto)
      integer povoso(0:nbnoto), voisom(*)
      integer famare(nbarto), cfaare(nctfar,nbfare)
c
      integer lapile(*)
      integer tabau2(nbnoto)
      integer nublar(nbarto)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux, maux, ldeb, lfin
      integer larete
      integer etat
      integer elem, lgpile
      integer tabau3(1)
      integer tbiaux(1)
c
      integer nbmess
      parameter (nbmess = 10 )
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
      texte(1,4) = '(/,3x,''. Connexite des '',a)'
      texte(1,10) = '(''.. Impression du bloc'',i8)'
c
      texte(2,4) = '(/,3x,''. Connexity of '',a)'
      texte(2,10) = '(''.. Printing of block #'',i8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1)
      write (ulsort,*) 'option =', option
#endif
c
c 1.3. ==> Aucun bloc au depart
c
      do 13 , iaux = 1 , nbarto
        nublar(iaux) = 0
   13 continue
c
      codret = 0
c
c====
c 2. blocs d'aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. blocs d''aretes ; codret =', codret
#endif
c
      nbbloc = 0
      lgpile = 0
c
      do 22 , larete = 1 , nbarto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Debut boucle 22, avant le bloc',nbbloc+1,
     >', larete =', larete, tabau4(larete)
#endif
c
c       On examine les aretes presentes dans la liste transmise
c
        if ( tabau4(larete).eq.1 ) then
c
c       On examine les faces qui ne sont pas deja dans un bloc
c
        if ( nublar(larete).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'larete =', larete,
     > ', etat =', hetare(larete),
     > ', type =',cfaare(cotyel,famare(larete))
#endif
c
        if ( option.gt.0 ) then
c
          etat = mod( hetare(larete) , 10 )
          if ( option.gt.1 ) then
            if ( cfaare(cotyel,famare(larete)).eq.0 ) then
              etat = -9999
            endif
          endif
c
        else
c
          etat = 0
c
        endif
c
        if ( etat.eq.0 ) then
c
c 2.1. ==> on commence un nouveau bloc :
c 2.1.1. ==> impression des caracteristiques du bloc precedent
c
          if ( ulbila.gt.0 .and. nbbloc.ge.1 ) then
c
c 2.1.1.1. ==> recherche des noeuds de ce bloc
c
            if ( codret.eq.0 ) then
c
            iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11E', nompro
#endif
            call utb11e ( iaux, nbbloc, nublar,
     >                    somare,
     >                    tbiaux, tbiaux,
     >                    tbiaux, tbiaux, tbiaux, tbiaux,
     >                      jaux,   jaux,   jaux,   jaux,
     >                    tabau2, tabau4,
     >                    ulsort, langue, codret )
c
            endif
c
c 2.1.1.2. ==> impression veritable
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) nbbloc
      write (ulsort,*) nublar
#endif
c
            jaux = 0
            kaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11F', nompro
#endif
            call utb11f ( nbbloc, jaux, kaux, kaux,
     >                    nublar, tabau2, tabau3, tabau4,
     >                    ulbila,
     >                    ulsort, langue, codret )
c
            endif
c
          endif
c
c 2.1.2. ==> initialisations
c
          nbbloc = nbbloc + 1
          elem = larete
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'debut du bloc ',nbbloc,' avec elem = ', elem
#endif
c
   21     continue
c
#ifdef _DEBUG_HOMARD_
cgn      write (ulsort,*) 'bloc ',nbbloc,' avec elem = ', elem
#endif
c
c 2.2. ==> memorisation du bloc pour l'element courant
c
          nublar(elem) = nbbloc
cgn          print *,'elem,nbbloc ',elem, nbbloc
c
c 2.3. ==> mise des voisins dans la pile
c
          do 222 , iaux = 1 , 2
c
c 2.3.1. ==> reperage des voisins de elem par son iaux-ieme sommet
c
            jaux = somare(iaux,elem)
            ldeb = povoso(jaux-1)+1
            lfin = povoso(jaux)
c
c 2.3.2. ==> examen des voisins
c
            do 2221 , laux = ldeb, lfin
c
              kaux = voisom(laux)
              if ( nublar(kaux).eq.0 ) then
c
                if ( tabau4(kaux).eq.1 ) then
                  if ( option.gt.0 ) then
                    etat = mod( hetare(kaux) , 10 )
cgn        write (ulsort,*) kaux,' : etat = ', etat,
cgn     > ',  type =',cfaare(cotyel,famare(kaux))
                    if ( option.gt.1 ) then
                      if ( cfaare(cotyel,famare(kaux)).eq.0 ) then
                        etat = -2221
                      endif
                    endif
                  else
                    etat = 0
                  endif
cgn                print *,'==> etat ',etat
                  if ( etat.eq.0 ) then
                    do 2222 , maux = 1 , lgpile
                    if ( lapile(maux).eq.kaux ) then
                      goto 2221
                    endif
 2222             continue
cgn        write (ulsort,*) '==> ajout de', kaux
                  lgpile = lgpile + 1
                  lapile(lgpile) = kaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,1789) (lapile(maux), maux = 1 , lgpile)
 1789 format(10i5)
#endif
                  endif
                endif
c
              endif
c
 2221       continue
c
  222     continue
c
c 2.4. ==> on passe a l'element suivant de la pile
c
          if ( lgpile.gt.0 ) then
c
            elem = lapile(lgpile)
            lgpile = lgpile - 1
            goto 21
c
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'fin du bloc', nbbloc
#endif
c
        endif
c
        endif
c
c 2.5. ==> on continue la liste des aretes en prevision d'un eventuel
c          nouveau bloc
c
        endif
c
   22 continue
c
c====
c 3. impression du dernier bloc
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) '3. impression dernier bloc ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( ulbila.gt.0 .and. nbbloc.gt.0 ) then
c
c 3.1. ==> recherche des noeuds de ce bloc
c
        if ( codret.eq.0 ) then
c
         iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11E', nompro
#endif
         call utb11e ( iaux, nbbloc, nublar,
     >                 somare,
     >                 tbiaux, tbiaux,
     >                 tbiaux, tbiaux, tbiaux, tbiaux,
     >                   jaux,   jaux,   jaux,   jaux,
     >                 tabau2, tabau4,
     >                 ulsort, langue, codret )
c
        endif
c
c 3.2. ==> impression veritable
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) nbbloc
cgn      write (ulsort,*) nublar
#endif
c
        endif
c
        if ( nbbloc.eq.1 ) then
          iaux = -nbbloc
        else
          iaux =  nbbloc
        endif
        jaux = 0
        kaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11F', nompro
#endif
        call utb11f ( iaux, jaux, kaux, kaux,
     >                nublar, tabau2, tabau3, tabau4,
     >                ulbila,
     >                ulsort, langue, codret )
c
        write (ulbila,3000)
 3000   format(5x,58('*'))
c
      endif
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
