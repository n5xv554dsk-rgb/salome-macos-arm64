      subroutine vcequ6 ( option,
     >                    noehom, arehom,
     >                    trihom, quahom,
     >                    somare, aretri, arequa,
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
c    aVant adaptation Conversion - EQUivalence - phase 6
c     -               -            ---                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . variantes                                  .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   4 : quadrangles                          .
c . noehom . es  . nbnoto . liste etendue des homologues par noeuds    .
c . arehom . es  . nbarto . liste etendue des homologues par aretes    .
c . trihom . e   . nbtrto . ensemble des triangles homologues          .
c . quahom . e   . nbquto . ensemble des quadrangles homologues        .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'VCEQU6' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
      integer noehom(nbnoto), arehom(nbarto)
      integer trihom(nbtrto), quahom(nbquto)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3), arequa(nbquto,4)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer entlo2, entlo1
      integer aretea(2), areteb(2)
      integer na(2), nb(2), nc(2)
      integer nbento, nbaret
      integer iaux, jaux, kaux
      integer iaux1, iaux2, iaux3, iaux4
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Cote'',i2,'' : aretes'',i10,'' et'',i10)'
      texte(1,5) = '(''Arete'',i10,'' de'',i10,'' a'',i10)'
      texte(1,6) = '(''Noeud'',i10,'' sans homologue ?'')'
      texte(1,7) = '(a,i10,'' : est homologue de'',i10)'
      texte(1,8) =
     > '(''Les noeuds'',i10,'' et'',i10,'' devraient etre homologues'')'
      texte(1,9) = '(''.. Aretes du '',a,i10,'' :'',4i10)'
      texte(1,10) = '(/,''. Analyse des '',a,i10,'' et'',i10)'
c
      texte(2,4) = '(''Face'',i2,'' : edges'',i10,'' and'',i10)'
      texte(2,5) = '(''Edge'',i10,'' from'',i10,'' to'',i10)'
      texte(2,6) = '(''Node'',i10,'' without any homologous ?'')'
      texte(2,7) = '(a,i10,'' : is homologous with'',i10)'
      texte(2,8) =
     > '(''Nodes'',i10,'' and'',i10,'' should be homologous'')'
      texte(2,9) = '(''.. Edges of '',a,i10,'' :'',4i10)'
      texte(2,10) = '(/,''. Analysis of '',a,i10,'' and'',i10)'
c
      codret = 0
c
c====
c 2. enrichissement de la structure sur les aretes a partir de la
c    donnee des faces homologues
c    ici, on traite les faces qui sont dans un coin de maillage.
c    Autrement dit, il doit leur rester deux aretes sans homologues et
c    qui se suivent :
c
c                X                     X----------------O
c                ..                    .                .
c                . .                   .                .
c                .  .                  .                .
c                .   .        ou       .                . OK
c                .    .                .                .
c                .     .               .                .
c                .      .              .                .
c                O-------O             O----------------O
c                   OK                          OK
c    on va rapprocher les aretes en comparant les noeuds homologues O.
c    on en profitera pour enregistrer le dernier noeud X.
c====
c
      if ( option.eq.2 ) then
        nbento = nbtrto
        nbaret = 3
      else
        nbento = nbquto
        nbaret = 4
      endif
c
      do 21 , entlo2 = 1 , nbento
c
        if ( codret.eq.0 ) then
c
        if ( option.eq.2 ) then
          entlo1 = trihom(entlo2)
        else
          entlo1 = quahom(entlo2)
        endif
c
c      on boucle uniquement sur les faces de la face periodique 2
c
        if ( entlo1.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,10)) mess14(langue,3,option),
     >                                    entlo2, entlo1
#endif
c
c 2.1. ==> reperage des deux aretes non encore enregistrees, sur
c          chacun des cotes.
c
          if ( codret.eq.0 ) then
c
          do 211 , iaux = 1 , 2
c
            aretea(iaux) = 0
            areteb(iaux) = 0
            if ( iaux.eq.1 ) then
              kaux = entlo1
            else
              kaux = entlo2
            endif
#ifdef _DEBUG_HOMARD_
            if ( option.eq.2 ) then
              write (ulsort,texte(langue,9)) mess14(langue,1,option),
     >        kaux, (aretri(kaux,jaux), jaux = 1 , nbaret)
            else
              write (ulsort,texte(langue,9)) mess14(langue,1,option),
     >        kaux, (arequa(kaux,jaux), jaux = 1 , nbaret)
            endif
#endif
c
            do 212 , jaux = 1 , nbaret
c
              iaux2 = 0
              if ( option.eq.2 ) then
                if ( arehom(aretri(kaux,jaux)).eq.0 ) then
                  iaux2 = aretri(kaux,jaux)
                endif
              else
                if ( arehom(arequa(kaux,jaux)).eq.0 ) then
                  iaux2 = arequa(kaux,jaux)
                endif
              endif
              if ( iaux2.ne.0 ) then
                if ( aretea(iaux).eq.0 ) then
                  aretea(iaux) = iaux2
                else
                  areteb(iaux) = iaux2
                endif
              endif
c
  212       continue
c
  211     continue
c
          if ( areteb(1).eq.0 .and. areteb(2).eq.0 ) then
            goto 21
          endif
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,4)) 1, aretea(1), areteb(1)
          write (ulsort,texte(langue,4)) 2, aretea(2), areteb(2)
#endif
c
          endif
c
c 2.2. ==> pour chaque cote, on repere les deux noeuds extremites
c          et le noeud central
c
c              0----------------------X----------------------0
c            NA(i)    aretea(i)     NB(i)    areteb(i)     NC(i)
c
          if ( codret.eq.0 ) then
c
          do 221 , iaux = 1 , 2
c
            iaux1 = somare(1,aretea(iaux))
            iaux2 = somare(2,aretea(iaux))
            iaux3 = somare(1,areteb(iaux))
            iaux4 = somare(2,areteb(iaux))
c
            if ( iaux1.eq.iaux3 ) then
              na(iaux) = iaux2
              nb(iaux) = iaux1
              nc(iaux) = iaux4
            elseif ( iaux1.eq.iaux4 ) then
              na(iaux) = iaux2
              nb(iaux) = iaux1
              nc(iaux) = iaux3
            elseif ( iaux2.eq.iaux3 ) then
              na(iaux) = iaux1
              nb(iaux) = iaux2
              nc(iaux) = iaux4
            elseif ( iaux2.eq.iaux4 ) then
              na(iaux) = iaux1
              nb(iaux) = iaux2
              nc(iaux) = iaux3
            else
              write (ulsort,texte(langue,5)) aretea(iaux), iaux1, iaux2
              write (ulsort,texte(langue,5)) areteb(iaux), iaux3, iaux4
              codret = 3
            endif
c
  221     continue
c
          endif
c
c 2.3. ==> on repere les homologues
c
c              0----------------------X----------------------0
c            NA(i)    aretea(i)     NB(i)    areteb(i)     NC(i)
c
          if ( codret.eq.0 ) then
c
c 2.3.1. ==> mise en equivalence des aretes
c
          if ( abs(noehom(na(1))).eq.na(2) ) then
c
            if ( abs(noehom(nc(1))).eq.nc(2) ) then
              iaux1 = aretea(2)
              iaux2 = areteb(2)
            else
              write (ulsort,texte(langue,7)) mess14(langue,2,-1),
     >                                       na(1), na(2)
              write (ulsort,texte(langue,8)) nc(1), nc(2)
              codret = 5
            endif
c
          elseif ( abs(noehom(na(1))).eq.nc(2) ) then
c
            if ( abs(noehom(nc(1))).eq.na(2) ) then
              iaux1 = areteb(2)
              iaux2 = aretea(2)
            else
              write (ulsort,texte(langue,7)) mess14(langue,2,-1),
     >                                       na(1), nc(2)
              write (ulsort,texte(langue,8)) nc(1), na(2)
              codret = 5
            endif
c
          else
c
            write (ulsort,texte(langue,6)) na(1)
            codret = 5
c
          endif
c
          endif
c
          if ( codret.eq.0 ) then
c
          arehom(aretea(1)) = -iaux1
          arehom(areteb(1)) = -iaux2
          arehom(iaux1) = aretea(1)
          arehom(iaux2) = areteb(1)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,7)) mess14(langue,2,1),
     >                                   iaux1, aretea(1)
          write (ulsort,texte(langue,7)) mess14(langue,2,1),
     >                                   iaux2, areteb(1)
#endif
c
          endif
c
c 2.3.2. ==> mise en equivalence du noeud central
c
          if ( codret.eq.0 ) then
c
          if ( noehom(nb(1)).eq.0 .and. noehom(nb(2)).eq.0 ) then
c
            noehom(nb(1)) = -nb(2)
            noehom(nb(2)) = nb(1)
c
          else
c
            if ( noehom(nb(1)).ne.-nb(2) ) then
              write (ulsort,texte(langue,7)) mess14(langue,2,-1),
     >                                       nb(1), noehom(nb(1))
              write (ulsort,texte(langue,8)) nb(1), nb(2)
              codret = 5
            endif
c
          endif
c
          endif
c
        endif
c
        endif
c       
   21 continue
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
