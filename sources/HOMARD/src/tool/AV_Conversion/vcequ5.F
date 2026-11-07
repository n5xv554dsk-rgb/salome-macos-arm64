      subroutine vcequ5 ( entlo1, entlo2,
     >                    noehom, arehom,
     >                    somare, np2are,
     >                    povoso, voisom,
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
c    aVant adaptation Conversion - EQUivalence - phase 5
c     -               -            ---                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . entlo1 . e   .   1    . numero de l'arete sur la face 1            .
c . entlo2 . e   .   1    . numero de l'arete sur la face 2            .
c . noehom . es  . nbnoto . liste etendue des homologues par noeuds    .
c . arehom . es  . nbarto . liste etendue des homologues par aretes    .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud milieu de l'arete          .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . voisom . e   . nvosom . elements 1d, 2d ou 3d voisins par sommet   .
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
      parameter ( nompro = 'VCEQU5' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nbutil.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer entlo1, entlo2
      integer noehom(nbnoto), arehom(nbarto)
      integer somare(2,nbarto), np2are(nbarto)
      integer povoso(0:nbnoto), voisom(nvosom)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer entab2
      integer iaux, jaux, nbrhom, ndaux
      integer iaux1, iaux2
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
      texte(1,4) = '(''Il devrait l''''etre aussi de'',i10,'' ?'')'
      texte(1,5) = '(''Infos donnees en numerotation HOMARD :'')'
      texte(1,6) = '(a,i10,'' : est homologue de'',i10)'
      texte(1,7) =
     > '(''. Noeuds homologues de l''''arete'',i10,'' :'',i2,''/2'')'
c
      texte(2,4) = '(''It also should be with #'',i10)'
      texte(2,5) = '(''Infos given with HOMARD # :'')'
      texte(2,6) = '(a,i10,'' : is homologous with'',i10)'
      texte(2,7) =
     > '(''. Homologous nodes of edge'',i10,'' :'',i2,''/2'')'
c
      codret = 0
c
c====
c 2. definir ou completer les relations d'equivalence entre les noeuds
c    lies a une paire d'aretes
c====
c
      entab2 = abs(entlo2)
c
c 2.1. ==> decompte du nombre de noeuds homologues eventuels deja
c          enregistrees
c
      if ( codret.eq.0 ) then
c
      nbrhom = 0
      do 211 , iaux = 1 , 2
        ndaux = abs(noehom(somare(iaux,entlo1)))
        do 212 , jaux = 1 , 2
c
          if ( ndaux.eq.somare(jaux,entab2) ) then
            nbrhom = nbrhom + 1
          endif
c
  212   continue
  211 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) entlo1, nbrhom
#endif
c
      endif
c
c 2.2. ==> si aucun noeud n'a d'homologue : on met en relation celui qui
c          limite une autre arete homologue avec celui qui lui
c          correspond dans l'arete homologue.
c          le second noeud est traite en 2.3.
c
       if ( codret.eq.0 ) then
c
       if ( nbrhom.eq.0 ) then
c
         call vcequn ( entlo1, entlo2,
     >                 noehom, arehom,
     >                 somare, povoso, voisom,
     >                 ulsort, langue, codret)
c
         nbrhom = 1
c
       endif
c
       endif
c
c 2.3. ==> s'il reste un seul noeud sans homologue : on le met
c          en equivalence avec son semblable sur l'autre arete
c
      if ( codret.eq.0 ) then
c
      if ( nbrhom.le.1 ) then
c
        iaux1 = 0
        iaux2 = 0
        do 231 , iaux = 1 , 2
          if ( noehom(somare(iaux,entlo1)).eq.0 ) then
            iaux1 = iaux
          endif
          if ( noehom(somare(iaux,entab2)).eq.0 ) then
            iaux2 = iaux
          endif
  231   continue
c
        if ( iaux1.ne.0 .and. iaux2.ne.0 ) then
          noehom(somare(iaux1,entlo1)) = - somare(iaux2,entab2)
          noehom(somare(iaux2,entab2)) = somare(iaux1,entlo1)
        else
          codret = 3
        endif
c
      endif
c
      endif
c
c 2.4. ==> on verifie qu'il ne reste plus aucun noeud sans son
c          homologue
c
      if ( codret.eq.0 ) then
c
      if ( nbrhom.ne.2 ) then
c
        nbrhom = 0
        do 241 , iaux = 1 , 2
          ndaux = abs(noehom(somare(iaux,entlo1)))
          do 242 , jaux = 1 , 2
c
            if ( ndaux.eq.somare(jaux,entab2) ) then
              nbrhom = nbrhom + 1
            endif
c
  242     continue
  241   continue
c
        if ( nbrhom.ne.2 ) then
          codret = 3
        endif
c
      endif
c
      endif
c
c 2.5. ==> en degre 2, on associe les deux noeuds milieux si ce n'est
c          pas deja fait
c
      if ( codret.eq.0 ) then
c
      if ( degre.eq.2 ) then
c
        if ( noehom(np2are(entlo1)).eq.0 ) then
          noehom(np2are(entlo1)) = np2are(entab2)
        else
          if ( abs(noehom(np2are(entlo1))).ne.np2are(entab2) ) then
            write (ulsort,texte(langue,6)) mess14(langue,2,-1),
     >                   np2are(entlo1), noehom(np2are(entlo1))
            write (ulsort,texte(langue,4)) np2are(entab2)
            write (ulsort,texte(langue,5))
            codret = 5
          endif
        endif
c
        if ( noehom(np2are(entab2)).eq.0 ) then
          noehom(np2are(entab2)) = np2are(entlo1)
        else
          if ( abs(noehom(np2are(entab2))).ne.np2are(entlo1) ) then
            write (ulsort,texte(langue,6)) mess14(langue,2,-1),
     >                   np2are(entab2), noehom(np2are(entab2))
            write (ulsort,texte(langue,4)) np2are(entlo1)
            write (ulsort,texte(langue,5))
            codret = 5
          endif
        endif
c
      endif
c
      endif
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
