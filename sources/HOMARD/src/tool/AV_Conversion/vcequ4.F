      subroutine vcequ4 ( option,
     >                    arehom,
     >                    trihom, quahom,
     >                    aretri, arequa,
     >                    posifa, facare,
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
c    aVant adaptation Conversion - EQUivalence - phase 4
c     -               -            ---                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . variantes                                  .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   4 : quadrangles                          .
c . arehom . es  . nbarto . liste etendue des homologues par aretes    .
c . trihom . e   . nbtrto . ensemble des triangles homologues          .
c . quahom . e   . nbquto . ensemble des quadrangles homologues        .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
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
      parameter ( nompro = 'VCEQU4' )
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
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
      integer arehom(nbarto)
      integer trihom(nbtrto), quahom(nbquto)
      integer aretri(nbtrto,3), arequa(nbquto,4)
      integer posifa(0:nbarto), facare(nbfaar)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer entlo2, entlo1
      integer nbento, nbaret
      integer iaux, jaux, kaux, nbrhom
      integer iaux1, iaux2
      integer nombre(4)
c
      logical coin
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
      texte(1,4) = '(/,''. Analyse des '',a,i10,'' et'',i10)'
      texte(1,5) = '(a,i10,'' : est dans un coin.'')'
      texte(1,6) =
     > '(''.. Nombre de voisins des aretes de '',i10, '' :'',4i10)'
      texte(1,7) = '(a,i10,'' est homologue de'',i10)'
      texte(1,8) = '(''... ==> Arete homologue de'',i10,'' :'',i10)'
      texte(1,9) =
     > '(/,a,i10,'' : les homologues de ses aretes sont incorrectes'')'
      texte(1,10) =
     > '(''.. Nombre de '',a,''homologues enregistres :'',i2,''/'',i2)'
c
      texte(2,4) = '(/,''. Analysis of '',a,i10,'' and'',i10)'
      texte(2,5) = '(a,i10,'' : is in an angle.'')'
      texte(2,6) =
     > '(''.. Number of neighbours of edges of '',i10, '':'',4i10)'
      texte(2,7) =
     > '(a,''#'',i10,'' is homologous with '',a,''#'',i10)'
      texte(2,8) = '(''... ==> Homologous edge of'',i10,'':'',i10)'
      texte(2,9) =
     > '(/,a,i10,'' : homologous of its edges are uncorrect.'')'
      texte(2,10) =
     > '(''.. Number of known homologous '',a,'':'',i2,''/'',i2)'
c
      codret = 0
c
c====
c 2. enrichissement de la structure sur les aretes a partir de la
c    donnee des faces homologues
c    pour les faces qui sont dans un coin de maillage, on ne pourra
c    regler ici que le cas des aretes qui ne sont pas du coin.
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
          write (ulsort,texte(langue,4)) mess14(langue,3,option),
     >                                   entlo2, entlo1
#endif
c
c 2.1. ==> decompte du nombre de faces voisines pour chacune des
c          aretes de la face
c          si deux aretes ne possedent qu'un voisin, c'est que la face
c          est dans un coin. On le note pour ne traiter que les aretes
c          qui ne sont pas du bord.
c
          if ( codret.eq.0 ) then
c
          coin = .false.
c
          if ( option.eq.2 ) then
            iaux = entlo2
          else
            iaux = -entlo2
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNVAF', nompro
#endif
          call utnvaf ( nombre, iaux,
     >                  aretri, arequa, posifa,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6))entlo2,(nombre(iaux),iaux=1,nbaret)
#endif
          jaux = 0
          do 211 , iaux = 1 , nbaret
            if ( nombre(iaux).eq.1 ) then
              jaux = jaux + 1
            endif
  211     continue
          if ( jaux.ge.2 ) then
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,5)) mess14(langue,2,option),
     >                                     entlo2
#endif
            coin = .true.
          endif
c
          endif
c
c 2.2. ==> decompte du nombre d'aretes deja enregistrees comme
c          homologues
c
          if ( codret.eq.0 ) then
c
          nbrhom = 0
          do 221 , iaux = 1 , nbaret
            do 222 , jaux = 1 , nbaret
c
              if ( option.eq.2 ) then
                if ( arehom(aretri(entlo2,iaux)).eq.
     >               aretri(entlo1,jaux) ) then
                  nbrhom = nbrhom + 1
                endif
              else
                if ( arehom(arequa(entlo2,iaux)).eq.
     >               arequa(entlo1,jaux) ) then
                  nbrhom = nbrhom + 1
                endif
              endif
c
  222       continue
  221     continue
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,10)) mess14(langue,3,1),
     >                                    nbrhom, nbaret
#endif
c
          endif
c
c 2.3. ==> si aucune arete n'a d'homologue : on met en relation
c          la derniere des aretes qui a au moins deux faces voisines
c          avec celle qui lui correspond dans la face homologue.
c          pour les autres, on le fera apres.
c          si on ne peut pas en trouver une, c'est que la face est
c          toute seule, ce qui est impossible pour un maillage normal.
c          donc au cas ou iaux1 vaudrait 0, on arrete.
c
          if ( codret.eq.0 ) then
c
          if ( nbrhom.eq.0 ) then
c
            iaux1 = 0
            do 231 , iaux = 1 , nbaret
              if ( nombre(iaux).ge.2 ) then
                iaux1 = iaux
              endif
  231       continue
c
            if ( iaux1.ne.0 ) then
              if ( option.eq.2 ) then
                jaux = aretri(entlo2,iaux1)
              else
                jaux = arequa(entlo2,iaux1)
              endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQUA', nompro
#endif
              call vcequa ( option,
     >                      arehom,
     >                      jaux, entlo2, entlo1,
     >                      trihom, quahom,
     >                      aretri, arequa,
     >                      posifa, facare,
     >                      ulsort, langue, codret)
            else
              codret = 23
            endif
c
          endif
c
          endif
c
c 2.4. ==> si au plus une arete a une homologue : on met en relation
c          l'une des aretes restantes avec celle qui lui correspond
c          dans la face homologue, a condition qu'elle ait au moins
c          deux faces voisines.
c          si on ne peut pas en trouver une, c'est que la face est
c          toute seule, ce qui est impossible pour un maillage normal.
c          donc au cas ou iaux1 vaudrait 0, on arrete.
c
          if ( codret.eq.0 ) then
c
          if ( nbrhom.le.1 ) then
c
c          si c'est un triangle de coin, on ne peut plus rien faire ici.
c
            if ( option.eq.2 .and. coin ) then
              goto 21
            endif
c
            iaux1 = 0
            do 241 , iaux = 1 , nbaret
              if ( option.eq.2 ) then
                if ( arehom(aretri(entlo2,iaux)).eq.0 .and.
     >               nombre(iaux).ge.2 ) then
                  iaux1 = iaux
                  jaux = aretri(entlo2,iaux1)
                endif
              else
                if ( arehom(arequa(entlo2,iaux)).eq.0 .and.
     >               nombre(iaux).ge.2 ) then
                  iaux1 = iaux
                  jaux = arequa(entlo2,iaux1)
                endif
              endif
  241       continue
c
            if ( iaux1.ne.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQUA', nompro
#endif
              call vcequa ( option,
     >                      arehom,
     >                      jaux, entlo2, entlo1,
     >                      trihom, quahom,
     >                      aretri, arequa,
     >                      posifa, facare,
     >                      ulsort, langue, codret)
            else
              codret = 24
            endif
c
          endif
c
          endif
c
c 2.5. ==> cas particulier aux quadrangles. On rappelle qu'ils ont 4
c          aretes alors que les triangles n'en ont que 3 ;=)
c          s'il reste deux aretes sans homologue : on met en relation
c          l'une des aretes avec celle qui lui correspond dans le
c          quadrangle homologue, a condition qu'elle ait au moins deux
c          faces voisines. pour l'autre, on le fera apres.
c          on doit toujours en trouver une, sinon c'est que le test
c          du 2.1 a eu un probleme. donc au cas ou iaux1 vaudrait 0,
c          on arrete.
c
          if ( codret.eq.0 ) then
c
          if ( option.eq.4) then
c
            if ( nbrhom.le.2 ) then
c
c            si c'est un quadrangle de coin, on ne peut plus rien
c            faire ici.
c
            if ( coin ) then
              goto 21
            endif
c
              iaux1 = 0
              do 251 , iaux = 1 , nbaret
                if ( arehom(arequa(entlo2,iaux)).eq.0 .and.
     >               nombre(iaux).ge.2 ) then
                  iaux1 = iaux
                  jaux = arequa(entlo2,iaux1)
                endif
  251         continue
c
              if ( iaux1.ne.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQUA', nompro
#endif
                call vcequa ( option,
     >                        arehom,
     >                        jaux, entlo2, entlo1,
     >                        trihom, quahom,
     >                        aretri, arequa,
     >                        posifa, facare,
     >                        ulsort, langue, codret)
              else
                codret = 25
              endif
c
            endif
c
          endif
c
          endif
c
c 2.6. ==> s'il reste une seule arete sans homologue : on la met
c          en equivalence avec sa semblable sur l'autre face
c
          if ( codret.eq.0 ) then
c
          if ( nbrhom.le.nbaret-1 ) then
c
            iaux1 = 0
            iaux2 = 0
            do 261 , iaux = 1 , nbaret
              if ( option.eq.2 ) then
                if ( arehom(aretri(entlo2,iaux)).eq.0 ) then
                  iaux1 = iaux
                endif
                if ( arehom(aretri(entlo1,iaux)).eq.0 ) then
                  iaux2 = iaux
                endif
              else
                if ( arehom(arequa(entlo2,iaux)).eq.0 ) then
                  iaux1 = iaux
                endif
                if ( arehom(arequa(entlo1,iaux)).eq.0 ) then
                  iaux2 = iaux
                endif
              endif
  261       continue
c
c          par construction, entlo1 est sur la face 1 et entlo2 sur
c          la face 2 ; d'ou les signes dans arehom
c
            if ( iaux1.ne.0 .and. iaux2.ne.0 ) then
              if ( option.eq.2 ) then
                iaux = aretri(entlo2,iaux1)
                jaux = aretri(entlo1,iaux2)
              else
                iaux = arequa(entlo2,iaux1)
                jaux = arequa(entlo1,iaux2)
              endif
              arehom(iaux) =   jaux
              arehom(jaux) = - iaux
#ifdef _DEBUG_HOMARD_
             write (ulsort,texte(langue,8)) iaux, jaux
#endif
            else
              codret = 26
            endif
c
          endif
c
          endif
c
c 2.7. ==> on verifie que les homologues des aretes sont correctes
c
          if ( codret.eq.0 ) then
c
          if ( nbrhom.ne.nbaret ) then
c
            nbrhom = 0
            do 271 , iaux = 1 , nbaret
              do 272 , jaux = 1 , nbaret
c
                if ( option.eq.2 ) then
                  if ( arehom(aretri(entlo2,iaux)).eq.
     >                 aretri(entlo1,jaux) ) then
                    nbrhom = nbrhom + 1
                  endif
                else
                  if ( arehom(arequa(entlo2,iaux)).eq.
     >                 arequa(entlo1,jaux) ) then
                    nbrhom = nbrhom + 1
                  endif
                endif
c
  272         continue
  271       continue
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,10)) mess14(langue,3,1),
     >                                     nbrhom, nbaret
#endif
c
            if ( nbrhom.ne.nbaret ) then
c
              do 273 , kaux = 1 , 2
c
                if ( kaux.eq.1 ) then
                  iaux1 = entlo2
                else
                  iaux1 = entlo1
                endif
                write (ulsort,texte(langue,9)) mess14(langue,2,option),
     >                                         iaux1
                do 2731 , iaux = 1 , nbaret
                  if ( option.eq.2 ) then
                    jaux = aretri(iaux1,iaux)
                  else
                    jaux = arequa(iaux1,iaux)
                  endif
                  write (ulsort,texte(langue,7)) mess14(langue,1,1),
     >            jaux, arehom(jaux)
 2731           continue
c
  273         continue
c
              codret = 27
c
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
