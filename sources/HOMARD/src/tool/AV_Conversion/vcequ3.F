      subroutine vcequ3 ( option,
     >                    nbento, nbeqen, ibenti,
     >                    nuenex, enthom, nensho, eqenti,
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
c    aVant adaptation Conversion - EQUivalence - phase 3
c     -               -            ---                 -
c
c    remarque : ce traitement suppose qu'une entite ne possede pas plus
c               d'un homologue. Si des cas plus compliques apparaissent,
c               il faudra modifier la structure des equivalences
c
c    on fait une traduction bete des donnees en entree.
c    pour chaque couple d'entite (e1,e2) donnees comme homologue, on
c    note entequ(e1)=+-e2 et entequ(e2)=+-e1
c    on fait evidemment les changements de numerotation appropries.
c
c   remarque importante : reperage des elements homologues
c     on prend la convention de reperage suivante : lorsque
c     l'on a deux faces periodiques 1 et 2, on attribue un signe a
c     chacune des faces. pour un noeud "i", noehom(i) est alors egal
c     a la valeur suivante :
c     - "le numero du noeud correspondant par periodicite
c        si i est sur la face 2"
c     - "l'oppose du numero du noeud correspondant par periodicite
c        si i est sur la face 1"
c
c     Donc, on etend cette convention a toutes les entites noeuds,
c     aretes, triangles et quadrangles :
c     enthom(i) = abs(homologue(i)) ssi i est sur la face 2
c     enthom(i) = -abs(homologue(i)) ssi i est sur la face 1
c
c     pour une entite situee sur l'axe, on prend la convention positive
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . variantes                                  .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   4 : quadrangles                          .
c . nbento . e   .    1   . nombre d'entites total                     .
c . nbeqen . e   .    1   . nombre d'equivalence pour cette entite     .
c . ibenti . e   .    1   . reperage dans la numerotation contigue     .
c .        .     .        . des entites                                .
c . nuenex . e   .    *   . numerotation des entites en exterieur      .
c . enthom .   s . nbento . liste etendue des entites homologues       .
c .        .     .        . enthom(i) = abs(hom(i)) ssi i sur face 2   .
c .        .     .        . enthom(i) = -abs(hom(i)) ssi i sur face 1  .
c . nensho . e   . rstrac . numero des entites dans HOMARD             .
c . eqenti . e   .2*nbeqen. ensemble des entites homologues ; leurs    .
c .        .     .        . numeros sont dans la numerotation du code  .
c .        .     .        . de calcul                                  .
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
      parameter ( nompro = 'VCEQU3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbento, nbeqen, ibenti
      integer nuenex(*)
      integer enthom(nbento), nensho(*), eqenti(2*nbeqen)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer entlo1, entlo2
      integer iaux
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
      texte(1,4) = '(''Il/Elle devrait l''''etre aussi de'',i10,'' ?'')'
      texte(1,5) = '(''Infos donnees en numerotation calcul'',/)'
      texte(1,6) = '(''Infos donnees en numerotation HOMARD :'')'
      texte(1,7) = '(a,i10,'' : est homologue de'',i10)'
      texte(1,8) = '(''Equivalence sur les '',a)'
      texte(1,9) =
     >'(''Raffinement impossible pour des equivalences multiples.'')'
c
      texte(2,4) = '(''It also should be with #'',i10)'
      texte(2,5) = '(''Infos given with calculation #'',/)'
      texte(2,6) = '(''Infos given with HOMARD # :'')'
      texte(2,7) = '(a,i10,'' : is homologous with'',i10)'
      texte(2,8) = '(''Equivalence for '',a)'
      texte(2,9) = '(''Refinement cannot be done.'')'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,8)) mess14(langue,3,option)
#endif
c
c====
c 2. prise en compte des donnees sur les entites homologues
c    on complete la liste, en verifiant que si il y a deja un
c    homologue, c'est le bon !
c====
c
c 2.1. ==> tableaux etendus des entites homologues
c          a priori aucun pour le moment
c          remarque : on n'initialise les tableaux a 0 que si ils seront
c                     utilises. comme cela, s'ils le sont sans etre
c                     passes par ici, il y aura carton. Youpi.
c
      if ( nbeqen.ne.0 ) then
        do 21 , iaux = 1 , nbento
          enthom(iaux) = 0
   21   continue
      endif
c
c 2.2. ==> prise en compte des donnees sur les entites homologues
c          on complete la liste, en verifiant que si il y a deja un
c          homologue, c'est le bon !
c          pour une entite situee sur l'axe, c'est-a-dire homologues
c          d'elle-meme, on prend la convention positive
c
      do 22 , iaux = 1 , 2*nbeqen , 2
c
        entlo1 = nensho(nuenex(ibenti+eqenti(iaux)))
        entlo2 = nensho(nuenex(ibenti+eqenti(iaux+1)))
c
        if ( enthom(entlo1).eq.0 ) then
          if ( entlo1.eq.entlo2 ) then
            enthom(entlo1) = entlo2
          else
            enthom(entlo1) = - entlo2
          endif
        else
          if ( abs(enthom(entlo1)).ne.entlo2 ) then
            write(ulsort,texte(langue,7)) mess14(langue,1,option),
     >                                    entlo1, abs(enthom(entlo1))
            write(ulsort,texte(langue,4)) entlo2
            write(ulsort,texte(langue,5))
            codret = 5
          endif
        endif
c
        if ( enthom(entlo2).eq.0 ) then
          enthom(entlo2) = entlo1
        else
          if ( abs(enthom(entlo2)).ne.entlo1 ) then
            write(ulsort,texte(langue,7)) mess14(langue,1,option),
     >                                    entlo2, enthom(entlo2)
            write(ulsort,texte(langue,4)) entlo1
            write(ulsort,texte(langue,5))
            codret = 5
          endif
        endif
c
   22 continue
c
c====
c 3. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      if ( nbeqen.ne.0 ) then
        write(ulsort,texte(langue,6))
        do 31 , iaux = 1 , nbento
          if ( enthom(iaux).ne.0 ) then
            write(ulsort,texte(langue,7)) mess14(langue,1,option),
     >                                    iaux, enthom(iaux)
          endif
   31   continue
      endif
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,9))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
