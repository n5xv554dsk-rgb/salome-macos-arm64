      subroutine vcsfli ( sdimca, nbelem, nbmane, nvosom, nbnoto, nbf,
     >                    coonca,
     >                    noeele, typele, fameel,
     >                    povoso, voisom,
     >                    numfam, nomfam, ligfam,
     >                    nbli00, nblign, nsomli,
     >                    numlig, seglig, somseg,
     >                    abscur, tabaux,
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
c                     - Suivi de Frontiere - creation des LIgnes
c                       -        -                        --
c remarque : vcsfl0 et vcsfli sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . sdimca . e   .    *   . dimension du maillage de calcul            .
c . coonca . e   . nbnoto . coordonnees des noeuds dans le calcul      .
c .        .     . *sdimca.                                            .
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . fameel . e   . nbelem . famille med des elements                   .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . numfam . e   .   nbf  . donne le vrai numero de famille med        .
c .        .     .        . associee a chaque famille classee selon    .
c .        .     .        . l'ordre d'arrivee                          .
c . nomfam . e   . 10*nbf . nom des familles MED                       .
c . ligfam . e   .  nbf   . numero de la ligne de la famille MED       .
c . nbli00 . e   .   1    . nombre estime de lignes                    .
c . nblign .   s .   1    . nombre reel de lignes                      .
c . nsomli .   s .   1    . nombre de sommets pour decrire les lignes  .
c . seglig .   s .0:nblign. pointeur dans les tableaux somseg et abscur.
c .        .     .        . les segments de la ligne i sont aux places .
c .        .     .        . de seglig(i-1)+1 a seglig(i)-1 inclus      .
c . somseg .   s . nsomli . liste des sommets des lignes separees par  .
c                           des 0                                      .
c . abscur .   s . nsomli . longueur des segments des lignes           .
c . tabaux .  a  . nbarto . tableau auxiliaire                         .
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
      parameter ( nompro = 'VCSFLI' )
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
      integer nbelem, nbmane, nvosom, nbnoto, nbf
      integer noeele(nbelem,nbmane), typele(nbelem), fameel(nbelem)
      integer voisom(nvosom), povoso(0:nbnoto)
      integer numfam(nbf), ligfam(nbf)
      integer nbli00, nblign, nsomli
      integer numlig(nbli00), seglig(0:nbli00), somseg(*)
      integer tabaux(nbelem)
c
      double precision coonca(nbnoto,sdimca)
      double precision abscur(*)
c
      character*8 nomfam(10,nbf)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer el, elx, areext, arete, nrsom, nrsom1, typhom
      integer noeext
      integer lig, jaux, kaux, compte
c
      double precision daux
c
#ifdef _DEBUG_HOMARD_
      character*64 saux64
#endif
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
      texte(1,6) =
     > '(''.. Extremite '',i1,'' : noeud '',i10,'', arete '',i10)'
      texte(1,7) = '(''.. Nombre d''''aretes :'',i10)'
      texte(1,8) = '(''Estimation du nombre total de lignes :'',i10)'
      texte(1,9) = '(/,''Nombre total de lignes :'',i10)'
      texte(1,10) =
     > '(''Nombre de sommets pour decrire les lignes :'',i10)'
c
      texte(2,4) = '(/,''Line # '',i5,/,12(''=''))'
      texte(2,5) = '(''.'',i5,''-th family, MED # '',i5,'', name '',a)'
      texte(2,6) = '(''.. End # '',i1,'' : node '',i10,'', edge '',i10)'
      texte(2,7) = '(''.. Number of edges :'',i10)'
      texte(2,8) = '(''Estimation of total number of lines :'',i10)'
      texte(2,9) = '(/,''Total number of lines :'',i10)'
      texte(2,10) = '(''Number of vertices to describe lines :'',i10)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) nbli00
#endif
c
c====
c 2. Conversion
c====
c 2.0. ==> aucune maille ne fait partie d'une ligne
c
      do 200 , iaux = 1 , nbelem
        tabaux(iaux) = 0
  200 continue
c
      nblign = 0
      seglig(0) = 0
      nsomli = 0
c
      do 20 , lig = 1 , nbli00
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
                areext = elx
                noeext = iaux
                goto 2199

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
 2199  continue
c
        endif
c
c 2.2. ==> Liste ordonnee des sommets constituant la ligne
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) 1, noeext, areext
#endif
c
        if ( codret.eq.0 ) then
c
c 2.2.1. ==> on enregistre le point de depart : la derniere extremite
c            trouvee precedemment
c
        nblign = nblign + 1
c
        numlig(nblign) = lig
c
        nsomli = nsomli + 1
        somseg(nsomli) = noeext
        abscur(nsomli) = 0.d0
#ifdef _DEBUG_HOMARD_
        write(ulsort,90024) 'Debut noeud', noeext, abscur(nsomli)
#endif
        nrsom1 = noeext
c
        arete = areext
        nrsom = noeext
        tabaux(arete) = lig
c
c 2.2.2. ==> on va parcourir les aretes de proche en proche
c
   22   continue
c
c ..... recherche de l'autre extremite de l'arete courante
#ifdef _DEBUG_HOMARD_
        write (ulsort,90012) 'noeuds de l''arete', arete,
     >                        noeele(arete,1), noeele(arete,2)
#endif
        if ( noeele(arete,1).ne.nrsom ) then
          nrsom = noeele(arete,1)
        else
          nrsom = noeele(arete,2)
        endif
c
c ..... incrementation du nombre de sommets
c       . stockage du nouveau sommet
c       . memorisation de la longueur du brin
c
        nsomli = nsomli + 1
        somseg(nsomli) = nrsom
        daux = 0.d0
        do 220 , jaux = 1 , sdimca
          daux = daux + (coonca(nrsom1,jaux)-coonca(nrsom,jaux))**2
  220   continue
        abscur(nsomli) = abscur(nsomli-1) + sqrt(daux)
#ifdef _DEBUG_HOMARD_
        write(ulsort,90024) 'Suite noeud', nrsom, abscur(nsomli)
#endif
        nrsom1 = nrsom
c
c ..... boucle sur les aretes voisines de ce noeud
        do 221 , jaux = povoso(nrsom-1) + 1, povoso(nrsom)
c
          el = voisom(jaux)
          typhom = medtrf(typele(el))
cgn      write (ulsort,90015) 'Maille voisine' , el,' typhom :',typhom
c
          if ( typhom.eq.tyhse1 .or. typhom.eq.tyhse2 ) then
c
            areext = el
c
c ......... si c'est une nouvelle arete
            if ( areext.ne.arete ) then
c
c ........... et si cette arete appartient a la ligne, c'est-a-dire si
c ........... sa famille MED fait partie de la description de la ligne
              do 2211 , kaux = 1 , nbf
                if ( numfam(kaux).eq.fameel(areext) ) then
                  if ( ligfam(kaux).eq.lig ) then
cgn      write (ulsort,90002) 'on poursuit le trajet avec l''arete', el
c ............... alors on poursuit le trajet
                    arete = areext
                    tabaux(arete) = lig
                    goto 22
                  endif
                endif
 2211         continue
c
            endif
c
          endif
c
  221   continue
c
c 2.2.3. ==> la ligne est finie
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,90024) '  Fin noeud', nrsom, abscur(nsomli)
        write (ulsort,texte(langue,6)) 2, nrsom, arete
        write (ulsort,texte(langue,7)) nsomli - seglig(nblign-1) - 1
#endif
c
        nsomli = nsomli + 1
c
        somseg(nsomli) = 0
c
        seglig(nblign) = nsomli
c
        endif
c
   20 continue
cgn      write (ulsort,*) somseg(nsomli-1)
cgn      write (ulsort,*) (seglig(iaux),iaux=0,nblign)
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,9)) nblign
      write (ulsort,texte(langue,10)) nsomli
      endif
#endif
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
