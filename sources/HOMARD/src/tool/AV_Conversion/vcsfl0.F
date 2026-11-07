      subroutine vcsfl0 (sdimca, nbelem, nvosom, nbnoto, nbf,
     >                    coonca,
     >                    typele, fameel,
     >                    povoso, voisom,
     >                    numfam, nomfam, ligfam,
     >                    laligd, nbli00,
     >                    lalign, noelig, arelig,
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
c    aVant adaptation - Conversion
c     -                 -
c                     - Suivi de Frontiere - creation des Lignes
c                       -        -                        -
c                     - phase 0
c                             -
c remarque : vcsfl0 et vcsfli sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . sdimca . e   .    *   . dimension du maillage de calcul            .
c . coonca . e   . nbnoto . coordonnees des noeuds dans le calcul      .
c .        .     . *sdimca.                                            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . fameel . e   . nbelem . famille med des elements                   .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . numfam . e   .   nbf  . donne le vrai numero de famille med        .
c .        .     .        . associee a chaque famille classee selon    .
c .        .     .        . l'ordre d'arrivee                          .
c . nomfam . e   . 10*nbf . nom des familles MED                       .
c . ligfam . e   .  nbf   . numero de la ligne de la famille MED       .
c . nbli00 . e   .   1    . nombre estime de lignes                    .
c . lalign .  s  .   1    . 0, si aucune ligne n'est fermee            .
c .        .     .        . !=0 : numero d'une ligne fermee            .
c . noelig .  s  .   1    . un noeud de la ligne fermee                .
c . arelig .  s  .   1    . une arete liee au noeud noelig             .
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
      parameter ( nompro = 'VCSFL0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "refert.h"
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer sdimca
      integer nbelem, nvosom, nbnoto, nbf
      integer typele(nbelem), fameel(nbelem)
      integer voisom(nvosom), povoso(0:nbnoto)
      integer numfam(nbf), ligfam(nbf)
      integer laligd, nbli00
      integer lalign, noelig, arelig
c
      character*8 nomfam(10,nbf)
c
      double precision coonca(nbnoto,sdimca)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer el, elx, typhom
      integer nbnoex
      integer lig, jaux, kaux, compte
c
      integer nbnomx
      parameter ( nbnomx = 100 )
      integer tbiaux(nbnomx)
c
      character*3 saux03(3)
      character*64 saux64
c
      logical exista
c
      integer nbmess
      parameter ( nbmess = 10 )
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
      texte(1,4) = '(/,''Ligne numero '',i5,/,18(''=''))'
      texte(1,5) =
     > '(''.'',i5,''-eme famille, de numero MED '',i5,'', de nom '',a)'
      texte(1,6) = '(''Estimation du nombre total de lignes :'',i10)'
      texte(1,7) = '(''Premiere ligne a examiner :'',i10)'
      texte(1,8) = '(''Cette ligne a'',i10,'' extremites ?'')'
      texte(1,9) = '(''La ligne numero '',i5,'' est fermee.'')'
      texte(1,10) =
     > '(''.. Extremite'',i3,'' : noeud '',i10,3(a3,'' ='',g15.8))'
c
      texte(2,4) = '(/,''Line # '',i5,/,12(''=''))'
      texte(2,5) = '(''.'',i5,''-th family, MED # '',i5,'', name '',a)'
      texte(2,6) = '(''Estimation of total number of lines:'',i10)'
      texte(2,7) = '(''First line to be examined:'',i10)'
      texte(2,8) = '(''This line has got'',i10,'' ends?'')'
      texte(2,9) = '(''The line # '',i5,'' is closed.'')'
      texte(2,10) =
     > '(''.. End #'',i3,'' : noeud '',i10,3(a3,'' ='',g15.8))'
c
#include "impr03.h"
c
      codret = 0
c
      saux03(1) = ', X'
      saux03(2) = ', Y'
      saux03(3) = ', Z'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nbli00
      write (ulsort,texte(langue,7)) laligd
#endif
c
c====
c 2. analyse
c====
c
      lalign = 0
c
      do 20 , lig = laligd , nbli00
c
c 2.1 ==> recherche d'une extremite de la ligne
c         remarque : il est plus economique de boucler d'abord sur
c                    les familles qui decrivent la ligne courante, puis
c                    sur les noeuds.
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) lig
#endif
c
        exista = .false.
        nbnoex = 0
        noelig = 0
c
c ..... on parcourt les familles MED, pour ne retenir que celles qui
c ..... correspondent a la ligne courante
c
        do 21 , kaux = 1 , nbf
c
          if ( codret.eq.0 ) then
c
          if ( ligfam(kaux).eq.lig ) then
c
#ifdef _DEBUG_HOMARD_
            saux64( 1: 8) = nomfam(1,kaux)
            saux64( 9:16) = nomfam(2,kaux)
            saux64(17:24) = nomfam(3,kaux)
            saux64(25:32) = nomfam(4,kaux)
            saux64(33:40) = nomfam(5,kaux)
            saux64(41:48) = nomfam(6,kaux)
            saux64(49:56) = nomfam(7,kaux)
            saux64(57:64) = nomfam(8,kaux)
            call utlgut ( jaux, saux64, ulsort, langue, codret )
            write (ulsort,texte(langue,5))
     >                   kaux, numfam(kaux), saux64(1:jaux)
#endif
c
c ......... on parcourt tous les noeuds du maillage
c
            do 211 , iaux = 1 , nbnoto
c
              if ( codret.eq.0 ) then
c
              compte = 0
cgn      if ( lig.ge.0) then
cgn        write(ulsort,90002) 'noeud ',iaux
cgn        write(ulsort,90015) '. pointeur des voisins de',
cgn     >     povoso(iaux-1) + 1, ' a', povoso(iaux)
cgn      endif
c
c ........... on parcourt les aretes voisines du noeud
c ........... on compte combien appartiennent a la famille retenue
c
              do 2111, jaux = povoso(iaux-1) + 1, povoso(iaux)
c
                el = voisom(jaux)
cgn      if ( lig.ge.0) then
cgn        write(ulsort,90015) '.. voisin # ',jaux,
cgn     >                ' ; numero et type med',el, medtrf(typele(el))
cgn      endif
                if ( numfam(kaux).eq.fameel(el) ) then
c
                  typhom = medtrf(typele(el))
                  if ( typhom.eq.tyhse1 .or. typhom.eq.tyhse2 ) then
cgn      if ( lig.ge.0) then
cgn      write(ulsort,90002)'.. La frontiere contient l''arete', el
cgn      endif
                    elx = el
                    compte = compte + 1
                    exista = .true.
                  endif
c
                endif
c
 2111         continue
c
c .......... si le noeud n'a qu'une seule arete qui appartient
c .......... a la ligne, c'est une extremite
c
              if ( compte.eq.1 ) then
                nbnoex = nbnoex + 1
                if ( nbnoex.le.nbnomx ) then
                  tbiaux(nbnoex) = iaux
                else
                  write (ulsort,texte(langue,4)) lig
                  write (ulsort,texte(langue,8)) nbnoex
                  codret = codret + 1
                endif
c
              elseif ( compte.eq.2 .and. noelig.eq.0 ) then
c
c .......... si le noeud a 2 aretes qui appartient a la ligne, on
c .......... l'enregistre si c'est le premier
c
                noelig = iaux
                arelig = elx
c
              endif
c
              endif
c
  211       continue
c
          endif
c
          endif
c
   21   continue
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbnoex', nbnoex
        write (ulsort,90002) 'noelig, arelig', noelig, arelig
#endif
c
c 2.2. ==> controle :
c          . si une ligne est fermee, on sort pour l'ouvrir
c          . si une ligne a plus de deux extremites, c'est une erreur
c
        if ( codret.eq.0 ) then
c
        if ( exista ) then
c
          if ( nbnoex.eq.0 ) then
c
            lalign = lig
            write (ulsort,texte(langue,9)) lig
            goto 2999
c
          elseif ( nbnoex.ne.2 ) then
c
            write (ulsort,texte(langue,4)) lig
            write (ulsort,texte(langue,8)) nbnoex
c
            do 221 , kaux = 1 , nbf
              if ( ligfam(kaux).eq.lig ) then
                saux64( 1: 8) = nomfam(1,kaux)
                saux64( 9:16) = nomfam(2,kaux)
                saux64(17:24) = nomfam(3,kaux)
                saux64(25:32) = nomfam(4,kaux)
                saux64(33:40) = nomfam(5,kaux)
                saux64(41:48) = nomfam(6,kaux)
                saux64(49:56) = nomfam(7,kaux)
                saux64(57:64) = nomfam(8,kaux)
                call utlgut ( jaux, saux64, ulsort, langue, codret )
                write (ulsort,texte(langue,5))
     >                     kaux, numfam(kaux), saux64(1:jaux)
              endif
  221       continue
            do 222 , kaux = 1 , nbnoex
              jaux = tbiaux(kaux)
              write (ulsort,texte(langue,10)) kaux, jaux,
     >                 (saux03(iaux), coonca(jaux,iaux),iaux=1,sdimca)
  222       continue
c
            codret = 2
c
          endif
c
        endif
c
        endif
c
   20 continue
c
 2999 continue
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
