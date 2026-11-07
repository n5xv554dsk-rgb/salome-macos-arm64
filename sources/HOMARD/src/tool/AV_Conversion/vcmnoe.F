      subroutine vcmnoe ( eleinc, fameno, noeele, typele,
     >                    dimcst, coonca,
     >                    nnosho, nnosca,
     >                    coonoe, hetnoe, coexno,
     >                    trav1a, trav2a,
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
c    aVant adaptation - Conversion de Maillage - NOEuds
c     -                 -             -          ---
c ______________________________________________________________________
c
c but : construction de la table des noeuds pour une connectivite de
c       type med
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . eleinc . e   .   1    . elements incompatibles                     .
c .        .     .        . 0 : on bloque s'il y en a                  .
c .        .     .        . 1 : on les ignore s'il y en a              .
c . fameno . e   . nbnoto . famille med des noeuds                     .
c . noeele . e   . nbelem*. table de connectivite des elements         .
c .        .     . nbmane .                                            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . dimcst . e   .    1   . dimension de la coordonnee constante       .
c . coonca . e   . nbnoto . coordonnees des noeuds dans le calcul      .
c .        .     . *sdimca.                                            .
c . nnosho .  s  . rsnoac . numero des noeuds dans HOMARD              .
c . nnosca .  s  . rsnoto . numero des noeuds dans le calcul           .
c . coonoe .  s  . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hetnoe .  s  . nbnoto . historique de l'etat des noeuds            .
c .        .     .        . 0 pour les noeuds isoles                   .
c .        .     .        . 1 pour les sommets                         .
c .        .     .        . 2 pour les noeuds milieux                  .
c .        .     .        . 3 pour les noeuds support de maille-point  .
c .        .     .        . 4 pour les noeuds internes aux mailles     .
c .        .     .        . 7 pour les noeuds n'appartenant qu'a des   .
c .        .     .        .   elements ignores                         .
c . coexno .  s  . nbnoto*. codes externes sur les noeuds              .
c .        .     . nctfno .   1 : famille MED                          .
c .        .     . nctfno . sur les noeuds                             .
c . trav1a . a   . nbnoto . tableau de travail numero 1                .
c .        .     .        . Il ne sert qu'ici                          .
c . trav2a .  s  . nbnoto . tableau de travail numero 2                .
c .        .     .        . 1, pour un noeud appartenant a au moins un .
c .        .     .        .    element ignore
c .        .     .        . 0, sinon
c .        .     .        . Il servira dans vcmare                     .
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
      parameter ( nompro = 'VCMNOE' )
c
#include "nblang.h"
#include "referx.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "refere.h"
#include "refert.h"
#include "dicfen.h"
#include "nbutil.h"
#include "nombno.h"
#include "nombsr.h"
#include "envca1.h"
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer eleinc
      integer dimcst
      integer fameno(nbnoto), noeele(nbelem,nbmane), typele(nbelem)
      integer nnosho(rsnoac), nnosca(rsnoto)
      integer hetnoe(nbnoto)
      integer coexno(nbnoto,nctfno)
      integer trav1a(nbnoto), trav2a(nbnoto)
c
      integer ulsort, langue, codret
c
      double precision coonoe(nbnoto,sdim), coonca(nbnoto,sdimca)
c
c 0.4. ==> variables locales
c
      integer el, noeud, typhom, numero, nunoca
      integer iaux, jaux
      integer nbsoma, nbnsma, nbndma
c
      integer nbmess
      parameter ( nbmess = 17 )
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
      texte(1,4) = '(''Nombre de noeuds incorrect :'')'
      texte(1,5) = '(''. On denombre :'',i10,'' noeuds,'')'
      texte(1,6) = '(''  au lieu de '',i10,'' prevus ...'')'
      texte(1,7) = '(''Coordonnee constante incorrecte :'',i7)'
      texte(1,5) = '(''Nombre de noeuds incorrect :'')'
      texte(1,11) =
     > '(''Nombre total de noeuds                    :'',i10)'
      texte(1,12) =
     > '(''. dont sommets d''''aretes (noeud P1)        :'',i10)'
      texte(1,13) =
     > '(''. dont milieux d''''aretes (noeud P2)        :'',i10)'
      texte(1,14) =
     > '(''. dont noeuds internes aux mailles        :'',i10)'
      texte(1,15) =
     > '(''. dont noeuds isoles                      :'',i10)'
      texte(1,16) =
     > '(''. dont noeuds elements ignores uniquement :'',i10)'
      texte(1,17) =
     > '(''. dont noeuds mailles-points uniquement   :'',i10)'
c
      texte(2,4) = '(''Number of nodes is wrong:'')'
      texte(2,5) = '(i0,'' nodes are counted,'')'
      texte(2,6) = '(''instead of '',i10)'
      texte(2,7) = '(''Constant coordinate is wrong:'',i7)'
      texte(2,11) =
     > '(''Total number of nodes                 :'',i10)'
      texte(2,12) =
     > '(''. included vertices of edges (P1 node):'',i10)'
      texte(2,13) =
     > '(''. included centers of edges (P2 node) :'',i10)'
      texte(2,14) =
     > '(''. included mesh internal nodes        :'',i10)'
      texte(2,15) =
     > '(''. included isolated nodes             :'',i10)'
      texte(2,16) =
     > '(''. included only ignored element nodes :'',i10)'
      texte(2,17) =
     > '(''. included only mesh-point nodes      :'',i10)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) nbnoto
      write (ulsort,90002) 'nbelem', nbelem
      write (ulsort,90002) 'nbmane', nbmane
      write (ulsort,90002) 'eleinc', eleinc
#endif
c
c====
c 2.  trav1a vaudra :
c      0, pour un noeud isole
c     -1, pour un noeud p2, c'est-a-dire au milieu d'une arete
c     -2, pour un noeud qui est uniquement support d'une maille-point
c     -3, pour un noeud n'appartenant qu'a un element ignore
c     -4, pour un noeud interne a la face d'une maille
c     -5, pour un noeud interne a une maille
c      n, pour un noeud p1, c'est-a-dire un sommet d'arete, qui
c        appartient a n elements
c
c     trav2a vaudra :
c      1, pour un noeud appartenant a au moins un element ignore
c      0, sinon
c
c      elem : le numero global de l'element
c      typhom : le type dans homard de l'element
c====
c
c 2.1. ==> initialisation : a priori tous les noeuds sont isoles
c
      do 21 , noeud = 1 , nbnoto
        trav1a(noeud) = 0
        trav2a(noeud) = 0
   21 continue
c
c 2.2. ==> pour chaque element soumis au traitement :
c          . on incremente de 1 le nombre de voisins de ses sommets
c          . on marque a -1 chacun des noeuds milieux d'aretes
c          . on marque a -4 son noeud interne
c
c    nbsoma = nombre de sommets de la maille
c    nbnsma = nombre de noeuds sommets et milieux d'aretes de la maille
c    nbndma = nombre total de noeuds de la maille
c
      do 22 , el = 1 , nbelem
c
#ifdef _DEBUG_HOMARD_
      if ( el.lt.1 ) then
        write (ulsort,90015) 'typele(',el,') = ',typele(el)
        do 22221 , iaux = 1 , nbmane
          write (ulsort,90007) 'noeele',el,iaux,noeele(el,iaux)
22221   continue
      endif
#endif
        typhom = medtrf(typele(el))
        nbsoma = nbnref(typhom,1)
        nbnsma = nbnref(typhom,2)
        nbndma = nbnref(typhom,3)
#ifdef _DEBUG_HOMARD_
      if ( el.lt.1 ) then
      write (ulsort,90002) 'typhom',typhom
      write (ulsort,90002) 'nbsoma, nbnsma, nbndma',nbsoma,nbnsma,nbndma
      endif
#endif
        if ( eleinc.ne.0 ) then
          if ( tyeref(typhom).ne.0 ) then
            nbsoma = 0
            nbnsma = 0
            nbndma = 0
          endif
        endif
c
        do 221 , iaux = 1 , nbsoma
cgn          if ( el.eq.644 .or. el.ge.988 ) then
cgn          write (ulsort,90007) 'noeele',el,iaux,noeele(el,iaux)
cgn          endif
          trav1a(noeele(el,iaux)) = trav1a(noeele(el,iaux)) + 1
  221   continue
c
        do 222 , iaux = nbsoma+1 , nbnsma
cgn          write (ulsort,90007) 'noeele',el,iaux,noeele(el,iaux)
          trav1a(noeele(el,iaux)) = -1
  222   continue
c
        do 223 , iaux = nbnsma+1 , nbndma
cgn          write (ulsort,90007) 'noeele',el,iaux,noeele(el,iaux)
          trav1a(noeele(el,iaux)) = -4
  223   continue
c
   22 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '. fin de 2.2.'
      write (ulsort,91040) (trav1a(noeud), noeud = 1 , nbnoto)
      write (ulsort,91040) (trav2a(noeud), noeud = 1 , nbnoto)
#endif
c
c 2.3. ==> On parcourt les autres elements, non soumis au traitement
c          . On regarde toutes les mailles-points. Si son noeud n'a
c            toujours pas ete repere (trav1a=0) ou s'il a ete vu comme
c            sommet d'un element ignore (trav1a=-3), c'est qu'il ne fait
c            partie d'aucun element soumis a l'adaptation. On le
c            considere donc comme un noeud support de maille-point.
c          . On regarde tous les elements ignores. Pour chacun de leurs
c            noeuds, s'il n'a toujours pas ete repere (trav1a=0), on le
c            repere par -3.
c
c    nbnsma = nombre de noeuds sommets et milieux d'aretes de la maille
c
      do 23 , el = 1 , nbelem
c
        typhom = medtrf(typele(el))
c
        if ( typhom.eq.tyhmpo ) then
c
          if ( trav1a(noeele(el,1)).eq.0 .or.
     >         trav1a(noeele(el,1)).eq.-3 ) then
            trav1a(noeele(el,1)) = -2
          endif
c
        else
c
          if ( eleinc.eq.0 ) then
            nbnsma = 0
          else
            if ( tyeref(typhom).eq.0 ) then
              nbnsma = 0
            else
              nbnsma = nbnref(typhom,2)
            endif
          endif
c
          do 231 , iaux = 1 , nbnsma
            if ( trav1a(noeele(el,iaux)).eq.0 ) then
              trav1a(noeele(el,iaux)) = -3
            endif
            trav2a(noeele(el,iaux)) = 1
  231     continue
c
        endif
c
   23 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '. fin de 2.3.'
      write (ulsort,91040) (trav1a(noeud), noeud = 1 , nbnoto)
      write (ulsort,91040) (trav2a(noeud), noeud = 1 , nbnoto)
#endif
c
c====
c 3. reperage des numerotations des noeuds entre calcul et
c    homard
c    on les classe dans l'ordre suivant : les eventuels isoles, les
c    supports de maille-points, les p1, et enfin les p2
c    cela va permettre de respecter la convention qui veut que le
c    numero du noeud p2 soit superieur aux numeros des deux
c    extremites de l'arete qui le porte.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. reperage ; codret', codret
#endif
c
c 3.1. ==> initialisation
c
      numero = 0
      do 31 , noeud = 1 , rsnoac
        nnosho(noeud) = 0
   31 continue
c
c 3.2. ==> les noeuds isoles
c
      do 32 , noeud = 1 , nbnoto
        if ( trav1a(noeud).eq.0 ) then
          numero = numero + 1
          nnosho(noeud) = numero
          nnosca(numero) = noeud
cgn          write (ulsort,90015) 'numero', numero, ' noeud', noeud
        endif
   32 continue
c
      nbnois = numero
c
c 3.3. ==> les noeuds d'elements ignores
c
      do 33 , noeud = 1 , nbnoto
        if ( trav1a(noeud).eq.-3 ) then
          numero = numero + 1
          nnosho(noeud) = numero
          nnosca(numero) = noeud
        endif
   33 continue
c
      nbnoei = numero - nbnois
c
c 3.4. ==> les noeuds supports de maille-point
c
      do 34 , noeud = 1 , nbnoto
        if ( trav1a(noeud).eq.-2 ) then
          numero = numero + 1
          nnosho(noeud) = numero
          nnosca(numero) = noeud
        endif
   34 continue
c
      nbnomp = numero - nbnoei - nbnois
c
c 3.5. ==> les noeuds p1
c
      do 35 , noeud = 1 , nbnoto
        if ( trav1a(noeud).ge.1 ) then
          numero = numero + 1
          nnosho(noeud) = numero
          nnosca(numero) = noeud
        endif
   35 continue
c
      nbnop1 = numero - nbnomp - nbnoei - nbnois
c
c 3.6. ==> les noeuds p2 milieu d'aretes, le cas echeant
c
      if ( degre.eq.2 ) then
c
        do 36 , noeud = 1 , nbnoto
          if ( trav1a(noeud).eq.-1 ) then
            numero = numero + 1
            nnosho(noeud) = numero
            nnosca(numero) = noeud
          endif
   36   continue
c
        nbnop2 = numero - nbnop1 - nbnomp - nbnoei - nbnois
c
      else
c
        nbnop2 = 0
c
      endif
c
c 3.7. ==> les noeuds internes, le cas echeant
c
      if ( degre.eq.2 ) then
c
        do 37 , noeud = 1 , nbnoto
cgn      write (ulsort,90015) 'trav1a(',noeud,')', trav1a(noeud)
          if ( trav1a(noeud).eq.-4 ) then
            numero = numero + 1
            nnosho(noeud) = numero
            nnosca(numero) = noeud
          endif
   37   continue
c
        nbnoim = numero - nbnop2 - nbnop1 - nbnomp - nbnoei - nbnois
c
      else
c
        nbnoim = 0
c
      endif
c
c 3.8. ==> pas de noeuds internes aux volumes coupes par conformite
c
      nbnoin = 0
c
c 3.9. ==> verification
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) nbnoto
      write (ulsort,texte(langue,12)) nbnop1
      write (ulsort,texte(langue,13)) nbnop2
      write (ulsort,texte(langue,14)) nbnoim
      write (ulsort,texte(langue,15)) nbnois
      write (ulsort,texte(langue,16)) nbnoei
      write (ulsort,texte(langue,17)) nbnomp
#endif
c
      if ( numero.ne.nbnoto ) then
c
        write(ulsort,texte(langue,4))
        write(ulsort,texte(langue,5)) numero
        write(ulsort,texte(langue,6)) nbnoto
        codret = 1
c
      endif
c
c 3.9. ==> numeros mini/maxi des noeuds p1
c
      numip1 = nbnois + nbnoei + nbnomp + 1
c
      numap1 = numip1 + nbnop1 - 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '. fin de 3.'
#endif
c
c
c====
c 4. caracterisations :
c    . l'etat vaut : 0 pour les noeuds isoles,
c                    1 pour les sommets,
c                    2 pour les noeuds milieux.
c                    3 pour les noeuds support de maille-point.
c                    4 pour les noeuds internes aux mailles
c                    7 pour les noeuds n'appartenant qu'a des
c                      elements ignores
c    . les coordonnees sont les memes
c    . la caracteristique est la famille MED du noeud
c    . on suppose que l'on part d'un macro-maillage
c    . les autres caracteristiques sont mises a 0
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. caracterisations ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
c 4.1. ==> caracteristiques
c
        do 41 , noeud = 1 , nbnoto
          nunoca = nnosca(noeud)
          if ( trav1a(nunoca).eq.-4 ) then
            hetnoe(noeud) = 4
          elseif ( trav1a(nunoca).eq.-3 ) then
            hetnoe(noeud) = 7
          elseif ( trav1a(nunoca).eq.-2 ) then
            hetnoe(noeud) = 3
          elseif ( trav1a(nunoca).eq.-1 ) then
            hetnoe(noeud) = 2
          elseif ( trav1a(nunoca).eq.0 ) then
            hetnoe(noeud) = 0
          else
            hetnoe(noeud) = 1
          endif
          coexno(noeud,cofamd) = fameno(nunoca)
cgn      write (ulsort,90015) 'hetnoe(',noeud,')', hetnoe(noeud)
cgn      write (ulsort,90015) 'nnosca(',noeud,')', nnosca(noeud)
   41   continue
c
c 4.2. ==> coordonnees
c
      if ( sdim.eq.2 ) then
c
        if ( dimcst.eq.0 .or. dimcst.eq.3 ) then
          iaux = 1
          jaux = 2
        elseif ( dimcst.eq.1 ) then
          iaux = 2
          jaux = 3
        elseif ( dimcst.eq.2 ) then
          iaux = 1
          jaux = 3
        else
          write (ulsort,texte(langue,7)) dimcst
          codret = 1
        endif
c
        if ( codret.eq.0 ) then
c
        do 411 , noeud = 1 , nbnoto
          nunoca = nnosca(noeud)
          coonoe(noeud,1) = coonca(nunoca,iaux)
          coonoe(noeud,2) = coonca(nunoca,jaux)
  411   continue
c
        endif
c
      else
c
        do 412 , noeud = 1 , nbnoto
          nunoca = nnosca(noeud)
          coonoe(noeud,1) = coonca(nunoca,1)
          coonoe(noeud,2) = coonca(nunoca,2)
          coonoe(noeud,3) = coonca(nunoca,3)
  412   continue
c
      endif
c
      nbnoma = nbnoto
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '. fin de 4.'
#endif
c
c====
c 5. la fin
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
