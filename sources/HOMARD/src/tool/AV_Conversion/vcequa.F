      subroutine vcequa ( option,
     >                    arehom,
     >                    laret2, face2, face1,
     >                    trihom, quahom,
     >                    aretri, arequa,
     >                    posifa, facare,
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
c    aVant adaptation Conversion - EQUivalence - Arete
c     -               -            ---           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . variantes                                  .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   4 : quadrangles                          .
c . arehom . es  . nbarto . liste etendue des homologues par aretes    .
c . laret2 . e   .    1   . numero global de l'arete de la face face2  .
c . face2  . e   .    1   . numero global de la face sur la face 2     .
c . face1  . e   .    1   . numero global de la face sur la face 1     .
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
      parameter ( nompro = 'VCEQUA' )
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
      integer laret2, face2, face1
      integer trihom(nbtrto), quahom(nbquto)
      integer aretri(nbtrto,3), arequa(nbquto,4)
      integer posifa(0:nbarto), facare(nbfaar) 
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer laface, laret1, araux
      integer letria, lequad
      integer ideb, ifin
      integer iaux, jaux, kaux
c
      logical afaire
c
      integer nbmess
      parameter ( nbmess = 20 )
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
      texte(1,4) = '(''.. Examen de l''''arete'',i10,'' du '',a,i10)'
      texte(1,5) =
     >'(''Impossible de trouver l''''homologue de l''''arete'',i10)'
      texte(1,6) =
     >'(''... Examen de la face '',i10,'', voisine de l''''arete'',i10)'
      texte(1,7) = '(''... ==> Arete homologue de'',i10,'' :'',i10)'
      texte(1,8) = '(''.. Aretes du '',a,i10,'' :'',4i10)'
      texte(1,9) = '(/,''. Analyse des '',a,i10,'' et'',i10)'
      texte(1,10) = '(''.. L''''arete'',i10,'' est sur l''''axe.'')'
      texte(1,11) = '(''..... Rien a faire.'')'
      texte(1,20) = '(a,i10,'' est homologue du '',a,i10)'
c
      texte(2,4) = '(''.. Examination of edge '',i10,'' of '',a,i10)'
      texte(2,5) =
     > '(''Homologous for edge #'',i10,''cannot be found.'')'
      texte(2,6) =
     > '(''... Examination of face '',i10,'', of edge '',i10)'
      texte(2,7) = '(''... ==> Homologous edge of'',i10,'' :'',i10)'
      texte(2,8) = '(''.. Edges of '',a,i10,'' :'',4i10)'
      texte(2,9) = '(/,''. Analysis of '',a,i10,'' and'',i10)'
      texte(2,10) = '(''.. Edge'',i10,'' is on the axis.'')'
      texte(2,11) = '(''..... No interest.'')'
      texte(2,20) =
     > '(a,''#'',i10,'' is homologous with '',a,''#'',i10)'
c
#ifdef _DEBUG_HOMARD_
cc      write (ulsort,texte(langue,9)) mess14(langue,3,option),
cc     >                               face2, face1
      write (ulsort,texte(langue,4)) laret2, mess14(langue,1,option),
     >                               face2
      if ( option.eq.2 ) then
        write (ulsort,texte(langue,8)) mess14(langue,1,option),
     >            face2, (aretri(face2,kaux), kaux = 1 , 3)
        write (ulsort,texte(langue,8)) mess14(langue,1,option),
     >            face1, (aretri(face1,kaux), kaux = 1 , 3)
      else
        write (ulsort,texte(langue,8)) mess14(langue,1,option),
     >            face2, (arequa(face2,kaux), kaux = 1 , 4)
        write (ulsort,texte(langue,8)) mess14(langue,1,option),
     >            face1, (arequa(face1,kaux), kaux = 1 , 4)
      endif
#endif
c
c 1.2. ==> on recherche l'arete laret1 de la face face1 qui est
c          homologue de l'arete numero laret2 dans la face face2
c          a priori, on n'a rien trouve
c
      laret1 = 0
c
c====
c 2. on commence par voir si l'arete laret2 n'appartiendrait pas
c    aux deux faces. Cela veut dire qu'elle est sur l'axe
c    si c'est le cas, on l'enregistre et c'est bon
c====
c
      if ( codret.eq.0 ) then
c
      if ( option.eq.2 ) then
        do 21 , kaux = 1 , 3
          if ( laret2.eq.aretri(face1,kaux) ) then
            laret1 = laret2
          endif
   21   continue
      else
        do 22 , kaux = 1 , 4
          if ( laret2.eq.arequa(face1,kaux) ) then
            laret1 = laret2
          endif
   22   continue
      endif
c
      if ( laret1.ne.0 ) then
        arehom(laret1) = laret1
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) laret2
        write (ulsort,texte(langue,7)) laret2, laret1
#endif
      endif
c
      endif
c
c====
c 3. quand l'arete laret2 n'est pas sur l'axe, on boucle sur toutes les
c    faces qui possedent l'arete laret2 et on s'interesse a celles qui :
c    . ne sont pas la face courante
c    . ont une homologue
c
c    on cherche alors l'arete commune entre cette homologue et la
c    face face1 : c'est celle a mettre en equivalence
c    cela part du principe que les voisinages sont obligatoirement les
c    memes sur les deux faces.
c
c====
c
      if ( codret.eq.0 ) then
c
      if ( laret1.eq.0 ) then
c
      ideb = posifa(laret2-1)+1
      ifin = posifa(laret2)
c
      do 30 , iaux = ideb , ifin
c
        laface = facare(iaux)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) laface, laret2
#endif
c
        afaire = .false.
c
        if ( laface.gt.0 ) then
c
c 3.1. ==> laface est un triangle
c          on poursuit s'il a un homologue et si ce n'est pas le
c          triangle courant
c
          letria = trihom(laface)
          if ( letria.ne.0 ) then
            if ( option.eq.4 ) then
              afaire = .true.
            else
              if ( laface.ne.face2 ) then
                afaire = .true.
              endif
            endif
          endif
c
          if ( afaire ) then
c
c           on cherche parmi les aretes de letria, situe sur la face 1,
c           celle qui est commune au triangle homologue face1.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,20)) '... '//mess14(langue,2,2),
     >          letria, mess14(langue,1,2), laface 
      write (ulsort,texte(langue,8)) mess14(langue,1,2),
     >          letria, (aretri(letria,kaux), kaux = 1 , 3)
#endif
            do 311 , jaux = 1 , 3
              araux = aretri(letria,jaux)
              if ( option.eq.2 ) then
                do 312 , kaux = 1 , 3
                  if ( araux.eq.aretri(face1,kaux) ) then
                    if ( laret1.eq.0 ) then
                      laret1 = aretri(face1,kaux)
                    else
                      codret = 312
                    endif
                  endif
  312           continue
              else
                do 313 , kaux = 1 , 4
                  if ( araux.eq.arequa(face1,kaux) ) then
                    if ( laret1.eq.0 ) then
                      laret1 = arequa(face1,kaux)
                    else
                      codret = 313
                    endif
                  endif
  313           continue
              endif
  311       continue
c
          endif
c
c 3.2. ==> laface est un quadrangle
c          on poursuit s'il a un homologue et si ce n'est pas le
c          quadrangle courant
c
        else
c
          lequad = abs(quahom(abs(laface)))
          if ( lequad.ne.0 ) then
            if ( option.eq.2 ) then
              afaire = .true.
            else
              if ( abs(laface).ne.face2 ) then
                afaire = .true.
              endif
            endif
          endif
c
          if ( afaire ) then
c
c           on cherche parmi les aretes de lequad, situe sur la face 1,
c           celle qui est commune au quadrangle homologue face1.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,20)) '... '//mess14(langue,2,4),
     >          lequad, mess14(langue,1,4), abs(laface)
      write (ulsort,texte(langue,8)) mess14(langue,1,4),
     >          lequad, (arequa(lequad,kaux), kaux = 1 , 4)
#endif
            do 321 , jaux = 1 , 4
              araux = arequa(lequad,jaux)
              if ( option.eq.2 ) then
                do 322 , kaux = 1 , 3
                  if ( araux.eq.aretri(face1,kaux) ) then
                    if ( laret1.eq.0 ) then
                      laret1 = aretri(face1,kaux)
                    else
                      codret = 322
                    endif
                  endif
  322           continue
              else
                do 323 , kaux = 1 , 4
                  if ( araux.eq.arequa(face1,kaux) ) then
                    if ( laret1.eq.0 ) then
                      laret1 = arequa(face1,kaux)
                    else
                      codret = 323
                    endif
                  endif
  323           continue
              endif
  321       continue
c
#ifdef _DEBUG_HOMARD_
          else
             write (ulsort,texte(langue,11))
#endif
          endif
c
        endif
c
   30 continue
c
c 3.3. ==> enregistrement
c          par construction, laret1 est sur la face 1 et laret2 sur
c          la face 2 ; d'ou les signes dans arehom
c
      if ( laret1.ne.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) laret2, laret1
#endif
        arehom(laret2) =   laret1
        arehom(laret1) = - laret2
      else
        codret = 5
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
      write (ulsort,texte(langue,20)) mess14(langue,2,option), face1,
     >                                mess14(langue,1,option), face2
      if ( option.eq.2 ) then
        write (ulsort,texte(langue,8)) mess14(langue,1,option),
     >            face2, (aretri(face2,kaux), kaux = 1 , 3)
        write (ulsort,texte(langue,8)) mess14(langue,1,option),
     >            face1, (aretri(face1,kaux), kaux = 1 , 3)
      else
        write (ulsort,texte(langue,8)) mess14(langue,1,option),
     >            face2, (arequa(face2,kaux), kaux = 1 , 4)
        write (ulsort,texte(langue,8)) mess14(langue,1,option),
     >            face1, (arequa(face1,kaux), kaux = 1 , 4)
      endif
      write (ulsort,texte(langue,5)) laret2
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
