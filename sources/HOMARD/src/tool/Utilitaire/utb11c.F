      subroutine utb11c ( nbbloc, option, tabau4,
     >                    hetare, somare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    povoso, voisom,
     >                    posifa, facare,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
     >                    lapile, tabau2, tabau3,
     >                    taba15, taba16,
     >                    nublfa,
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
c    UTilitaire - Bilan sur le maillage - option 11 - phase c
c    --           -                              --         -
c ______________________________________________________________________
c
c    analyse de la connexite des faces
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbbloc .  s  .   1    . nombre de blocs                            .
c . option . e   .   1    . 0 : on prend toutes les faces              .
c .        .     .        . 1 : on prend les faces actives de HOMARD   .
c .        .     .        . 2 : on prend les faces actives du calcul   .
c . tabau4 . e   .-nbquto . indicateurs sur les faces a examiner :     .
c .        .     . :nbtrto.  0 : on ne traite pas la face              .
c .        .     .        . >0 : on traite la face                     .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . povoso . e   .0:nbnoto. pointeur des voisins par noeud             .
c . voisom . e   . nvosom . aretes voisines de chaque noeud            .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
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
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . lapile .  a  .   *    . tableau de travail                         .
c . tabau2 .  a  . nbnoto . tableau de travail                         .
c . tabau3 .  a  . nbarto . tableau de travail                         .
c . taba15 .  a  . nbarto . tableau de travail                         .
c . taba16 .  a  .   *    . tableau de travail                         .
c . nublfa .  s  .-nbquto . numero du bloc pour chaque face            .
c .        .     . :nbtrto.                                            .
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
      parameter ( nompro = 'UTB11C' )
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
#include "nombtr.h"
#include "nombqu.h"
c
#include "dicfen.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbbloc, option
      integer tabau4(-nbquto:*)
      integer hetare(nbarto), somare(2,nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer povoso(0:nbnoto), voisom(*)
      integer posifa(0:nbarto), facare(nbfaar)
c
      integer famare(nbarto), cfaare(nctfar,nbfare)
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
      integer famqua(nbquto), cfaqua(nctfqu,nbfqua)
c
      integer lapile(*)
      integer tabau2(nbnoto)
      integer tabau3(nbarto)
      integer taba15(nbarto)
      integer taba16(*)
      integer nublfa(-nbquto:*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux, maux, ldeb, lfin
      integer tbiaux(1)
      integer laface, typfa0, typfac
      integer etat
      integer elem, lgpile, nbaret
      integer nbblar
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
      texte(1,5) = '(''.. Impression du bloc'',i8)'
c
      texte(2,4) = '(/,3x,''. Connexity of '',a)'
      texte(2,5) = '(''.. Printing of block #'',i8)'
c
#include "impr03.h"
c
      if ( nbtrac.eq.0 ) then
        typfa0 = 4
      elseif ( nbquac.eq.0 ) then
        typfa0 = 2
      else
        typfa0 = 8
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typfa0)
      write (ulsort,90002) 'option', option
#endif
c
c 1.3. ==> Aucun bloc au depart
c
cgn      write (ulsort,90002) 'nbquto', nbquto
cgn      write (ulsort,90002) 'nbtrto', nbtrto
      do 13 , iaux = -nbquto , nbtrto
        nublfa(iaux) = 0
   13 continue
      nublfa(0) = -1
c
      codret = 0
c
c====
c 2. blocs de faces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. blocs de faces ; codret =', codret
#endif
c
      nbbloc = 0
      lgpile = 0
c
      do 22 , laface = -nbquto , nbtrto
c
#ifdef _DEBUG_HOMARD_
        if ( laface.ne.0 ) then
      write (ulsort,90015) 'Debut boucle 22, avant le bloc',nbbloc+1,
     >', laface = ', laface, tabau4(laface)
      endif
#endif
c       On examine les faces presentes dans la liste transmise
c
        if ( tabau4(laface).eq.1 ) then
c
c       On examine les faces qui ne sont pas deja dans un bloc
c
        if ( nublfa(laface).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      if ( laface.gt.0 ) then
        write (ulsort,90015) 'etat = ', hettri(laface),
     > ',  type =',cfatri(cotyel,famtri(laface))
      elseif ( laface.lt.0 ) then
        write (ulsort,90015) 'etat = ', hetqua(-laface),
     > ',  type =',cfaqua(cotyel,famqua(-laface))
      endif
#endif
c
        if ( option.gt.0 ) then
c
          etat = -9999
          if ( laface.gt.0 ) then
            etat = mod( hettri(laface) , 10 )
#ifdef _DEBUG_HOMARD_
        write (ulsort,90015) 'etat = ', etat,
     > ',  type =',cfatri(cotyel,famtri(laface))
#endif
            if ( option.gt.1 ) then
              if ( cfatri(cotyel,famtri(laface)).eq.0 ) then
                etat = -9999
              endif
            endif
          elseif ( laface.lt.0 ) then
            etat = mod( hetqua(-laface) , 100 )
#ifdef _DEBUG_HOMARD_
        write (ulsort,90015) 'etat = ', etat,
     > ',  type =',cfaqua(cotyel,famqua(-laface))
#endif
            if ( option.gt.1 ) then
              if ( cfaqua(cotyel,famqua(-laface)).eq.0 ) then
                etat = -9999
              endif
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
c 2.1.1.1. ==> recherche des aretes actives de ce bloc
c
            if ( codret.eq.0 ) then
c
            iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11E', nompro
#endif
            call utb11e ( iaux, nbbloc, nublfa,
     >                    somare,
     >                    aretri, arequa,
     >                    tbiaux, tbiaux, tbiaux, tbiaux,
     >                      jaux,   jaux,   jaux,   jaux,
     >                    tabau3, tabau4,
     >                    ulsort, langue, codret )
c
            endif
c
c 2.1.1.2. ==> recherche des blocs d'aretes actives de ce bloc
c
            if ( codret.eq.0 ) then
c
            iaux = 1
            jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11D', nompro
#endif
            call utb11d ( nbblar, iaux, tabau3,
     >                    hetare, somare,
     >                    povoso, voisom,
     >                    famare, cfaare,
     >                    taba15, tabau2,
     >                    taba16,
     >                      jaux,
     >                    ulsort, langue, codret )
c
            endif
c
c 2.1.1.3. ==> impression veritable
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nbbloc
#endif
c
            jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11F', nompro
#endif
            call utb11f ( nbbloc, nbblar, typfa0, typfac,
     >                    nublfa, tabau2, tabau3, tabau4,
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
          elem = laface
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'debut du bloc',nbbloc,' avec elem = ', elem
#endif
c
          do 2121 , iaux = 1 , nbnoto
            tabau2(iaux) = 0
 2121     continue
          do 2122 , iaux = 1 , nbarto
            tabau3(iaux) = 0
 2122     continue
c
          typfac = 0
c
   21     continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'bloc ',nbbloc,' avec elem = ', elem
#endif
c
c 2.2. ==> memorisation du bloc pour l'element courant
c
          nublfa(elem) = nbbloc
cgn          print *,'elem,nbbloc ',elem, nbbloc
c
          if ( elem.lt.0 ) then
            if ( typfac.eq.0 ) then
              typfac = 4
            elseif ( typfac.ne.4 ) then
              typfac = 8
            endif
          else
            if ( typfac.eq.0 ) then
              typfac = 2
            elseif ( typfac.ne.2 ) then
              typfac = 8
            endif
          endif
c
c 2.3. ==> mise des voisins dans la pile
c
          if ( elem.gt.0 ) then
            nbaret = 3
          else
            nbaret = 4
          endif
c
          do 222 , iaux = 1 , nbaret
c
c 2.3.1. ==> reperage des voisins de elem par sa iaux-ieme arete
c
            if ( elem.gt.0 ) then
              jaux = aretri(elem,iaux)
            else
              jaux = arequa(-elem,iaux)
            endif
            tabau3(jaux) = tabau3(jaux) + 1
            kaux = somare(1,jaux)
            tabau2(kaux) = tabau2(kaux) + 1
            kaux = somare(2,jaux)
            tabau2(kaux) = tabau2(kaux) + 1
            ldeb = posifa(jaux-1)+1
            lfin = posifa(jaux)
c
c 2.3.2. ==> examen des voisins qui ne sont pas deja dans un bloc
c            et qui font partie de la liste
c
            do 2221 , laux = ldeb, lfin
c
              kaux = facare(laux)
              if ( nublfa(kaux).eq.0 ) then
c
                if ( tabau4(kaux).eq.1 ) then
                  if ( option.gt.0 ) then
                    etat = -2220
                    if ( kaux.gt.0 ) then
                      etat = mod( hettri(kaux) , 10 )
cgn        write (ulsort,*) kaux,' : etat = ', etat,
cgn     > ',  type =',cfatri(cotyel,famtri(kaux))
                      if ( option.gt.1 ) then
                        if ( cfatri(cotyel,famtri(kaux)).eq.0 ) then
                          etat = -2221
                        endif
                      endif
                    else
                      etat = mod( hetqua(-kaux) , 100 )
cgn        write (ulsort,*) kaux,' : etat = ', etat,
cgn     > ',  type =',cfaqua(cotyel,famqua(-kaux))
                      if ( option.gt.1 ) then
                        if ( cfaqua(cotyel,famqua(-kaux)).eq.0 ) then
                          etat = -2222
                        endif
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
 2222               continue
cgn        write (ulsort,*) '==> ajout de', kaux
                    lgpile = lgpile + 1
                    lapile(lgpile) = kaux
#ifdef _DEBUG_HOMARD_
cgn      write (ulsort,1789) (lapile(maux), maux = 1 , lgpile)
cgn 1789 format(10i5)
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
      write (ulsort,90002) 'fin du bloc', nbbloc
      write (ulsort,*) 'tabau2 (noeuds)'
      write (ulsort,91040) (tabau2(iaux), iaux=1,min(20,nbnoto))
      write (ulsort,*) 'tabau3 (aretes)'
      write (ulsort,91040) (tabau3(iaux), iaux=1,min(20,nbarto))
c      write (ulsort,91040) (tabau3(iaux), iaux=1,min(20000,nbarto))
#endif
c
        endif
c
c 2.5. ==> on continue la liste des faces en prevision d'un eventuel
c          nouveau bloc
c
        endif
c
        endif
c
   22 continue
c
c====
c 3. impression du dernier bloc
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '3. impression dernier bloc ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( ulbila.gt.0 .and. nbbloc.gt.0 ) then
c
c 3.1. ==> recherche des aretes actives de ce bloc
c
        if ( codret.eq.0 ) then
c
        iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11E', nompro
#endif
        call utb11e ( iaux, nbbloc, nublfa,
     >                somare,
     >                aretri, arequa,
     >                tbiaux, tbiaux, tbiaux, tbiaux,
     >                  jaux,   jaux,   jaux,   jaux,
     >                tabau3, tabau4,
     >                ulsort, langue, codret )
c
        endif
c
c 3.2. ==> recherche des blocs d'aretes actives de ce bloc
c
        if ( codret.eq.0 ) then
c
        iaux = 1
        jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11D', nompro
#endif
        call utb11d ( nbblar, iaux, tabau3,
     >                hetare, somare,
     >                povoso, voisom,
     >                famare, cfaare,
     >                taba15, tabau2,
     >                taba16,
     >                  jaux,
     >                ulsort, langue, codret )
c
        endif
c
c 3.3. ==> impression veritable
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nbbloc
#endif
c
        if ( nbbloc.eq.1 ) then
          iaux = -nbbloc
        else
          iaux =  nbbloc
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11F', nompro
#endif
        call utb11f ( iaux, nbblar, typfa0, typfac,
     >                nublfa, tabau2, tabau3, tabau4,
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
