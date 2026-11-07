      subroutine desmaj ( nhnoeu, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    afaire,
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
c traitement des DEcisions - Suppression - Mise A Jour
c                --          -             -    - -
c ______________________________________________________________________
c
c but : mises a jour des communs apres suppression des entites de mise
c       en conformite
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nhnoeu . e   . char8  . nom de l'objet decrivant les noeuds        .
c . nharet . e   . char8  . nom de l'objet decrivant les aretes        .
c . nhtria . e   . char8  . nom de l'objet decrivant les triangles     .
c . nhquad . e   . char8  . nom de l'objet decrivant les quadrangles   .
c . nhtetr . e   . char8  . nom de l'objet decrivant les hexaedres     .
c . nhhexa . e   . char8  . nom de l'objet decrivant les tetraedres    .
c . nhpyra . e   . char8  . nom de l'objet decrivant les pyramides     .
c . nhpent . e   . char8  . nom de l'objet decrivant les pentaedres    .
c . afaire .  s  . logic  . vrai, si la numerotation des noeuds doit   .
c .        .     .        . etre revue                                 .
c .        .     .        . faux, si un raccourcissement suffit        .
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
      parameter ( nompro = 'DESMAJ' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nhnoeu, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
c
      logical afaire
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8
      integer codre0
c
      integer nbmess
      parameter ( nbmess = 10 )
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
      texte(1,4) = '(5x,''Nombre de '',a,''        : '',i10)'
      texte(1,5) = '(5x,''Nombre de '',a,'' actifs : '',i10)'
c
      texte(2,4) = '(5x,''Number of '',a,''        : '',i10)'
      texte(2,5) = '(5x,''Number of active '',a,'' : '',i10)'
c
#include "impr03.h"
c
c====
c 2. mise a jour des nombres d'entites du maillage
c====
c    remarques :
c  - lorsqu'on supprime des entites provisoires, leur mere reapparait.
c  - les nombres de paires d'homologues ne seront mis a jour qu'apres
c    raffinement du maillage. il faut veiller a ne pas utiliser les
c    tables ho1noe ... avant cela.
c
c 2.1. commun "nombno" --> noeuds
c     remarque : voir utplco pour la coherence des chiffres
c     Les noeuds a supprimer sont ceux qui sont :
c      - au centre des quadrangles coupes selon 2 aretes adjacentes.
c      - au centre des hexaedres coupes selon 2 ou 3 aretes.
c      - au centre des pentaedres coupes selon 2 aretes de triangles
c        ou 1 face triangulaire.
c     . En degre 1 :
c     Par construction, ces noeuds sont numerotes en dernier. Il suffit
c     donc de raccourcir les tableaux des noeuds du nombre de
c     quadrangles, d'hexaedres ou de pentaedres concernes.
c     . En degre 2, les aretes de mise en conformite disparaissant, les
c     noeuds P2 qu'elles portent doivent disparaitre. Par creation, ils
c     sont numerotes en dernier.
c      De plus, si on a supprime un noeud central, ce noeud a ete cree
c      avant les nouveaux noeuds P2, Il faut donc remanier la
c      numerotation des noeuds.
c
c     nbnois = non modifie
c     nbnoei = non modifie
c     nbpnho = mis a jour dans cmhomo/uthonh - non utilise avant
c     nbnoma = non modifie
c     nbnop1 = non modifie
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'mailet', mailet
      write (ulsort,90002) 'nbnoin', nbnoin
      write (ulsort,*) ' '
      write (ulsort,90002) 'nbart2', nbart2
      write (ulsort,90002) 'nbarq2', nbarq2
      write (ulsort,90002) 'nbarq3', nbarq3
      write (ulsort,90002) 'nbarq5', nbarq5
      write (ulsort,90002) 'nbarin', nbarin
      write (ulsort,*) ' '
      write (ulsort,90002) 'nbtrt2', nbtrt2
      write (ulsort,90002) 'nbtrq3', nbtrq3
      write (ulsort,*) ' '
      write (ulsort,90002) 'nbquq2', nbquq2
      write (ulsort,90002) 'nbquq5', nbquq5
      write (ulsort,*) ' '
      write (ulsort,90002) 'nbteh2', nbteh2
      write (ulsort,90002) 'nbteh3', nbteh3
      write (ulsort,90002) 'nbtedh', nbtedh
      write (ulsort,90002) 'nbtep3', nbtep3
      write (ulsort,90002) 'nbtep5', nbtep5
      write (ulsort,90002) 'nbtedp', nbtedp
      write (ulsort,90002) 'debut de '//nompro//' nbnoto', nbnoto
      write (ulsort,90002) 'debut de '//nompro//' nbnop2', nbnop2
      write (ulsort,90002) 'debut de '//nompro//' nbnoim', nbnoim
#endif
      afaire = .false.
      iaux = nbquq5/3
     >     + nbnoin
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nombre de noeuds P1 a supprimer', iaux
#endif
      nbnoto = nbnoto - iaux
      if ( degre.eq.2 ) then
        iaux = nbart2
     >       + nbarq2 + nbarq3 + nbarq5
     >       + nbarin
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nombre de noeuds P2 a supprimer', iaux
#endif
        nbnoto = nbnoto - iaux
        nbnop2 = nbnop2 - iaux
        if ( nbquq5.ne.0 .or. nbnoin.ne.0 ) then
          afaire = .true.
        endif
      endif
c
      if ( mod(mailet,2).eq.0 ) then
c
        nbnoto = nbnoto - nbtrt2
        nbnoim = nbnoim - nbtrt2
c
      endif
c
      if ( mod(mailet,3).eq.0 ) then
c
        nbnoto = nbnoto - nbtrq3
        nbnoim = nbnoim - nbtrq3
c
      endif
c
      if ( mod(mailet,5).eq.0 ) then
c
        codret = 31
c
      endif
c
      nbnoin = 0
c
cgn      write (ulsort,90002) '==> nouveau nbnoto', nbnoto
cgn      write (ulsort,90002) '==> nouveau nbnop2', nbnop2
cgn      write (ulsort,90002) '==> nouveau nbnoim', nbnoim
cgn      write (ulsort,99001) '==> afaire', afaire

c 2.2. commun "nombar" --> aretes
c
cgn      write(*,*) nbart2, nbarq3, nbarin
      iaux = nbart2
     >     + nbarq2 + nbarq3 + nbarq5 + nbarin
cgn      write (ulsort,90002) 'nombre d''aretes a supprimer', iaux
      nbarac = nbarac - iaux
c     nbarde = non modifie
      nbart2 = 0
      nbarq2 = 0
      nbarq3 = 0
      nbarq5 = 0
      nbarin = 0
c     nbarma = non modifie
c     nbarpe = non modifie
      nbarto = nbarpe
c     nbfaar = modifie plus tard par utfaa1
c     nbpaho = mis a jour dans cmhomo/uthonh - non utilise avant
c
c 2.3. commun "nombqu" --> quadrangles
c      remarque : a faire avant les triangles, sinon les nombres
c                 sont faux
c     . un triplet de triangles issus d'un decoupage en 3 d'un
c       quadrangle reactive 1 quadrangle et 0 triangle : nombre de
c       triangles actifs = -3, nombre de quadrangles actifs = +1
c     . un doublet de quadrangles issus d'un decoupage en 2 d'un
c       quadrangle reactive 1 quadrangle et en detruit 2 = -1
c     . un triplet de quadrangles issus d'un decoupage en 3 d'un
c       quadrangle reactive 1 quadrangle et en detruit 3 = -2/3
c
      iaux = nbtrq3/3 - nbquq2 - 2*nbquq5/3
cgn      write (ulsort,90002) 'bilan sur les quadrangles', iaux
      nbquac = nbquac + iaux
c     nbqude = non modifie
      nbquq2 = 0
      nbquq5 = 0
c     nbquma = non modifie
c     nbqupe = non modifie
      nbquto = nbqupe
c     nbpqho = mis a jour dans cmhomo/uthonh - non utilise avant
c
c 2.4. commun "nombtr" --> triangles
c     . une paire de triangles issus d'un decoupage en 2 d'un triangle
c       reactive 1 triangle : nombre de triangles actifs = -2 +1
c     . un triplet de triangles issus d'un decoupage en 3 d'un
c       quadrangle reactive 1 quadrangle et 0 triangle : nombre de
c       triangles actifs = -3, nombre de quadrangles actifs = +1
c     . un ensemble de triangles issus d'un decoupage interne a un
c       volume ne reactive aucun triangle : nombre de triangles
c       actifs = -n
c
      iaux = nbtrt2/2 + nbtrq3 + nbtrhc + nbtrpc + nbtrtc
cgn      write (ulsort,90002) 'nombre de triangles a supprimer', iaux
      nbtrac = nbtrac - iaux
c     nbtrde = non modifie
      nbtrt2 = 0
      nbtrq3 = 0
      nbtrhc = 0
      nbtrpc = 0
      nbtrtc = 0
c     nbtrma = non modifie
c     nbtrpe = non modifie
      nbtrto = nbtrpe
c     nbptho = mis a jour dans cmhomo/uthonh - non utilise avant
c
c 2.5. commun "nombhe" --> hexaedres
c     . chaque suppression de conformite des hexaedres supprime tous
c       les hexaedres concernes et reactive les peres
c
      iaux = nbhedh - nbheco
c
      nbheac = nbheac - iaux
      nbheco = 0
      nbhedh = 0
c     nbhede = non modifie
c     nbhema = non modifie
c     nbhepe = non modifie
      nbheto = nbhepe
      nbhecf = nbheto
      nbheca = 0
c
c 2.6. commun "nombte" --> tetraedres
c     . une paire de tetraedres issus d'un decoupage en 2 d'un tetraedre
c       reactive 1 tetraedre : nombre de tetraedres actifs = -2 +1
c     . un quadruplet de tetraedres issus d'un decoupage en 4 d'un
c       tetraedre reactive 1 tetraedre : nombre de tetraedres
c       actifs = -4 +1
c     . chaque suppression de conformite des hexaedres supprime tous
c       les tetraedres concernes
c     . chaque suppression de conformite des pentaedres supprime tous
c       les tetraedres concernes
c
      iaux = nbtea2/2 + 3*(nbtea4 + nbtef4)/4
     >     + nbteh1 + nbteh2 + nbteh3 + nbteh4
     >     + nbtep0 + nbtep1 + nbtep2 + nbtep3 + nbtep4 + nbtep5
     >     + nbtedh + nbtedp
cgn      write (ulsort,90002) 'nombre de tetraedres a supprimer', iaux
      nbteac = nbteac - iaux
      nbtea2 = 0
      nbtea4 = 0
      nbtef4 = 0
      nbteh1 = 0
      nbteh2 = 0
      nbteh3 = 0
      nbteh4 = 0
      nbtep0 = 0
      nbtep1 = 0
      nbtep2 = 0
      nbtep3 = 0
      nbtep4 = 0
      nbtep5 = 0
      nbtedh = 0
      nbtedp = 0
c     nbtede = non modifie
c     nbtema = non modifie
c     nbtepe = non modifie
      nbteto = nbtepe
      nbtecf = nbteto
      nbteca = 0
c
c 2.7. commun "nombpy" --> pyramides
c     . chaque suppression de conformite des hexaedres supprime toutes
c       les pyramides concernees
c     . chaque suppression de conformite des pentaedres supprime toutes
c       les pyramides concernees
c     Autrement dit, nbpyto = nbpyac = 0 en sortie
c
      iaux = nbpyh1 + nbpyh2 + nbpyh3 + nbpyh4
     >     + nbpyp0 + nbpyp1 + nbpyp2 + nbpyp3 + nbpyp4 + nbpyp5
     >     + nbpydh + nbpydp
cgn      write (ulsort,90002) 'nombre de pyramides a supprimer', iaux
      nbpyac = nbpyac - iaux
      nbpyh1 = 0
      nbpyh2 = 0
      nbpyh3 = 0
      nbpyh4 = 0
      nbpyp0 = 0
      nbpyp1 = 0
      nbpyp2 = 0
      nbpyp3 = 0
      nbpyp4 = 0
      nbpyp5 = 0
      nbpydh = 0
      nbpydp = 0
c     nbpyma = non modifie
c     nbpype = non modifie
      nbpyto = nbpype
      nbpycf = nbpyto
      nbpyca = 0
c
c 2.8. commun "nombpe" --> pentaedres
c
      iaux = nbpedp - nbpeco
c
      nbpeac = nbpeac - iaux
      nbpeco = 0
      nbpedp = 0
c     nbpede = non modifie
c     nbpema = non modifie
c     nbpepe = non modifie
      nbpeto = nbpepe
      nbpecf = nbpeto
      nbpeca = 0
c
c====
c 3. impressions
c====
c
      write(ulsort,texte(langue,4)) mess14(langue,3,-1), nbnoto
      write(ulsort,texte(langue,5)) mess14(langue,3,1), nbarac
      if ( nbtrto.ne.0 .or. nbquto.ne.0 ) then
        write(ulsort,texte(langue,5)) mess14(langue,3,2), nbtrac
      endif
      if ( nbquto.ne.0 ) then
        write(ulsort,texte(langue,5)) mess14(langue,3,4), nbquac
      endif
      if ( nbteto.ne.0 ) then
        write(ulsort,texte(langue,5)) mess14(langue,3,3), nbteac
      endif
      if ( nbheto.ne.0 ) then
        write(ulsort,texte(langue,5)) mess14(langue,3,6), nbheac
      endif
      if ( nbpeto.ne.0 ) then
        write(ulsort,texte(langue,5)) mess14(langue,3,7), nbpeac
      endif
      if ( nbpyto.ne.0 ) then
        write(ulsort,texte(langue,5)) mess14(langue,3,5), nbpyac
      endif
      write(ulsort,*) ' '
c
c====
c 4. stockage dans l'objet maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. stockage ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nhnoeu, 1, nbnoto, codre1 )
      call gmecat ( nharet, 1, nbarto, codre2 )
      call gmecat ( nhtria, 1, nbtrto, codre3 )
      call gmecat ( nhquad, 1, nbquto, codre4 )
      call gmecat ( nhtetr, 1, nbteto, codre5 )
      call gmecat ( nhhexa, 1, nbheto, codre6 )
      call gmecat ( nhpyra, 1, nbpyto, codre7 )
      call gmecat ( nhpent, 1, nbpeto, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      call gmecat ( nhtetr, 2, nbteca, codre1 )
      call gmecat ( nhhexa, 2, nbheca, codre2 )
      call gmecat ( nhpyra, 2, nbpyca, codre3 )
      call gmecat ( nhpent, 2, nbpeca, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
c
      endif
c
c====
c 5. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
