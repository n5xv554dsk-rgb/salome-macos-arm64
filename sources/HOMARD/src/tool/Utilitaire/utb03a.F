      subroutine utb03a ( hetnoe, coonoe,
     >                    hetare, somare, posifa,
     >                    hettri, aretri, voltri,
     >                    hetqua, arequa, volqua,
     >                    tritet, cotrte, aretet, hettet,
     >                    quahex, coquhe, arehex, hethex,
     >                    facpyr, cofapy, arepyr, hetpyr,
     >                    facpen, cofape, arepen, hetpen,
     >                    np2are,
     >                    xyzmin, xyzmax, xyzeps,
     >                    ulbila, ulsort, langue, codret )
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
c    UTilitaire - Bilan - option 03
c    --           -              --
c ______________________________________________________________________
c
c but : controle la non coincidence des noeuds et l'interpenetration
c       des aretes, des mailles de surface ou de volume
c       en mode debug, on indique egalement les noeuds p2 qui sont sur
c       les bords des mailles auxquels ils appartiennent.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetnoe . e   . nbnoto . historique de l'etat des noeuds            .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . xyzmin . e   .  sdim  . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) minimales du domaine total      .
c . xyzmax . e   .  sdim  . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) maximales du domaine total      .
c . xyzeps . e   .  sdim  . -1 si min = max dans la direction,         .
c .        .     .        . ecart sinon.                               .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
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
      parameter ( nompro = 'UTB03A' )
c
#include "nblang.h"
c
      integer nbintx
      parameter ( nbintx = 15 )
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
      double precision xyzmin(sdim), xyzmax(sdim), xyzeps(sdim)
c
      integer hetnoe(nbnoto)
      integer hetare(nbarto), somare(2,nbarto), posifa(0:nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3), voltri(2,nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), volqua(2,nbquto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpyr(nbpyto)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto)
      integer np2are(nbarto)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nbpbco(-1:7)
      integer ptrav1, ptrav2, ptrav3, ptrav4, ptrav5
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
      integer nbbomx, lglibo
      integer nbboit(3)
      integer nsectl(-1:7)
c
      logical logaux
c
      double precision boimin(3,0:nbintx), boimax(3,0:nbintx)
c
      character*8 ntrav1, ntrav2, ntrav3, ntrav4, ntrav5
      character*54 saux54
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
      character*08 mess08(nblang,13)
      character*43 mess43(nblang,3)
      character*54 mess54(nblang,20)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      if ( sdim.eq.1 ) then
        write (ulsort,*) nompro
        write (ulsort,*) 'Ne pas oublier de programmer pour sdim = 1'
        codret = 0
        return
      endif
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
      texte(1,4) =
     > '(//,3x,''INTERPENETRATION DES MAILLES'',/,3x,28(''=''),/)'
      texte(1,6) =
     > '(3x,''Le maillage est non-conforme par construction.'')'
      texte(1,7) = '(3x,''On ne sait pas controler.'')'
c
      texte(2,4) = '(//,3x,''STAGGERED MESHES'',/,3x,16(''=''),/)'
      texte(2,6) =
     > '(3x,''The mesh contains hanging nodes at the beginning.'')'
      texte(2,7) = '(3x,''Control cannot be made.'')'
c
#include "impr03.h"
c
      mess54(1,1) =
     > '       Aucun probleme n''a ete rencontre.              '
      mess54(1,2) =
     > 'Probleme d''interpenetration pour les                  '
      mess54(1,3) =
     > 'Bizarre, c''est un des noeuds P2 de la maille.         '
      mess54(1,4) =
     > 'Les noeuds suivants sont coincidents :                '
      mess54(1,8) =
     > 'Nombre de coincidences :                              '
      mess54(1,13) =
     > 'Un noeud est a l''interieur de mailles                '
      mess54(1,14) =
     > 'Nombre de noeuds P2 a l''interieur d''une maille        '
      mess54(1,15) =
     > 'Ce n''est donc peut-etre pas tres grave.               '
      mess54(1,16) =
     > '       Recapitulatif sur les                          '
c       12345678901234567890123456789012345678901234567890
      mess54(1,20) =
     > 'Il faut revoir le maillage.                           '
c
      mess54(2,1) =
     > '               No problem was found.                  '
      mess54(2,2) =
     > 'Problems with staggered meshes for                    '
      mess54(2,3) =
     > 'Strange : it is a P2 node of the mesh.                '
      mess54(2,4) =
     > 'Following nodes are coincidents :                     '
      mess54(2,8) =
     > 'Number of coincidences :                              '
      mess54(2,13) =
     > 'One node is inside meshes  .                          '
      mess54(2,14) =
     > 'Number of P2 node inside a mesh                       '
      mess54(2,15) =
     > 'So, it is not serious may-be.                         '
      mess54(2,16) =
     > '               Summary about                          '
c       12345678901234567890123456789012345678901234567890
      mess54(2,20) =
     > 'Mesh must be reviewed.                                '
c
c                    1234567890123456789012345678901234567890123
      mess43(1,1) = 'noeuds sont a l''interieur de mailles.     '
      mess43(1,2) = 'auquel ils appartiennent :                 '
      mess43(1,3) = 'Nombre de noeuds P1 bizarres :             '
c
      mess43(2,1) = 'nodes are inside meshes.                   '
      mess43(2,2) = 'belong :                                   '
      mess43(2,3) = 'Number of strange P1 nodes :               '
c
      mess08(1,1) = '  Il est'
      mess08(1,2) = ' dans le'
      mess08(1,3) = 'de somme'
      mess08(1,4) = 'ts      '
c
      mess08(2,1) = '  It is '
      mess08(2,2) = 'into the'
      mess08(2,3) = 'with ver'
      mess08(2,4) = 'tices   '
c
c 1.2. ==> divers
c
      do 12 , iaux = 1 , 2
c
      if ( iaux.eq.1 ) then
        kaux = ulbila
      else
        if ( ulbila.eq.ulsort ) then
          goto 12
        else
          kaux = ulsort
        endif
      endif
c
      write (kaux,texte(langue,4))
c
   12 continue
c
c 1.3. ==> constantes
c
      codret = 0
c
      do 13 , iaux = -1 , 7
        nbpbco(iaux) = -1
        nsectl(iaux) = 142+iaux
        call gtnoms ( nsectl(iaux), 1 ,
     >  '.. int. 42 '//mess14(langue,3,iaux)(1:13) )
c        12345678901   2345678901234
   13 continue
      nsectl(-1) = 131
      call gtnoms ( nsectl(-1), 1 ,
     >     '.. int. 42 '//mess14(langue,3,-1)(1:13) )
      call gtnoms ( nsectl(-1)+1, 1 , '... dont boites' )
      call gtnoms ( nsectl(-1)+2, 1 , '... dont controle' )
c
c====
c 2. controle de la non coincidence des noeuds
c====
      call gtdems (nsectl(-1))
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. noeuds ; codret', codret
#endif
c
c 2.1. ==> tableaux memorisant les eventuelles coincidences
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', nbnoto, ptrav1, codre1 )
      iaux = 2 + nbnoto/2
      call gmalot ( ntrav2, 'entier  ',   iaux, ptrav2, codre2 )
      call gmalot ( ntrav3, 'entier  ', nbnoto, ptrav3, codre3 )
      if ( sdim.eq.1 ) then
        nbbomx = nbintx
      elseif ( sdim.eq.2 ) then
        nbbomx = nbintx**2
      elseif ( sdim.eq.3 ) then
        nbbomx = nbintx**3
      endif
      iaux = nbbomx + 1
      call gmalot ( ntrav4, 'entier  ',   iaux, ptrav4, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c 2.2. ==> creation des boites
      call gtdems (nsectl(-1)+1)
c 2.2.1. ==> tri des noeuds
c
      if ( codret.eq.0 ) then
c
      iaux = nbintx
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3N1', nompro
#endif
      call utb3n1 ( coonoe,
     >              iaux, nbbomx,
     >              lglibo, imem(ptrav4),
     >              xyzmin, xyzmax, xyzeps,
     >              nbboit, boimin, boimax,
     >              ulsort, langue, codret )
c
      endif
cgn      call gmprsx ( nompro, ntrav4 )
c
c 2.2.1. ==> mise sous forme PtTabEnt
c
cc      call gtdems (113)
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav5, 'entier  ', lglibo, ptrav5, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = nbintx
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3N2', nompro
#endif
      call utb3n2 ( coonoe,
     >              iaux, nbbomx,
     >              lglibo, imem(ptrav4), imem(ptrav5),
     >              nbboit, boimin, boimax,
     >              ulsort, langue, codret )
c
      endif
cc      call gtfims (113)
cgn      call gmprsx ( nompro, ntrav4 )
cgn      call gmprot ( nompro, ntrav5, 1, 100 )
      call gtfims (nsectl(-1)+1)
c
c 2.3. ==> controle des coincidences
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. ; codret', codret
#endif
c
      call gtdems (nsectl(-1)+2)
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3N0', nompro
#endif
      call utb3n0 ( coonoe,
     >              imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >              nbbomx, lglibo, imem(ptrav4), imem(ptrav5),
     >              nbpbco, mess54,
     >              ulbila, ulsort, langue, codret )
c
      endif
      call gtfims (nsectl(-1)+2)
cgn      call gmprot ( nompro, ntrav2,1, 60)
cgn      call gmprot ( nompro, ntrav3,1, 100)
      call gtfims (nsectl(-1))
c
c====
c 3. prealables
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. prealables ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      logaux = .true.
#else
      if ( ( maconf.eq.-2 ) .or. ( maconf.ge.1 ) ) then
        logaux = .true.
      else
        logaux = .false.
      endif
#endif
c
      if ( logaux ) then
c
        do 31 , iaux = 1 , 2
c
          if ( iaux.eq.1 ) then
            jaux = ulbila
          else
            if ( ulbila.eq.ulsort ) then
              goto 31
            else
              jaux = ulsort
            endif
          endif
c
          if ( ( maconf.eq.-2 ) .or. ( maconf.ge.1 ) ) then
            write (jaux,texte(langue,6))
            write (jaux,texte(langue,7))
          endif
c
   31   continue
c
      endif
c
      endif
c
      if ( ( maconf.eq.-2 ) .or. ( maconf.ge.1 ) ) then
        goto 70
      endif
c
c====
c 4. controle de la non-interpenetration des aretes
c    remarques :
c    1. on ne s'interesse qu'aux actives car les autres sont
c    censees avoir ete controlees aux iterations anterieures
c    2. on ne s'interesse qu'aux aretes de region 1D, car celles qui
c    bordent des triangles seront vues par la suite.
c    3. La verification est sujette a caution car le test sur la
c    colinearite est un test sur une egalite de reels ...
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbarac.ne.0 ) then
      call gtdems (nsectl(1))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3A0', nompro
#endif
        call utb3a0 ( hetnoe, coonoe,
     >                imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >                hetare, somare, posifa,
     >                np2are,
     >                nbpbco, mess08, mess54,
     >                ulbila, ulsort, langue, codret )
c
      call gtfims (nsectl(1))
      endif
c
      endif
c
c====
c 5. controle de la non-interpenetration des surfaces
c    remarques :
c    1. on ne s'interesse qu'aux actives car les autres sont
c    censes avoir ete controles aux iterations anterieures
c    2. on ne s'interesse qu'aux faces de region 2D, car celles qui
c    bordent des volumes seront vues par la suite.
c    3. La verification est sujette a caution car le test sur la
c    coplanarite est un test sur une egalite de reels ...
c====
c 5.1. ==> les triangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.1. triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrac.ne.0 ) then
      call gtdems (nsectl(2))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3B0', nompro
#endif
        call utb3b0 ( hetnoe, coonoe,
     >                imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >                somare,
     >                hettri, aretri, voltri,
     >                np2are,
     >                nbpbco, mess08, mess54,
     >                ulbila, ulsort, langue, codret )
      call gtfims (nsectl(2))
c
      endif
c
      endif
c
c 5.2. ==> les quadrangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.2. quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbquac.ne.0 ) then
      call gtdems (nsectl(4))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3C0', nompro
#endif
        call utb3c0 ( hetnoe, coonoe,
     >                imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >                somare,
     >                hetqua, arequa, volqua,
     >                np2are,
     >                nbpbco, mess08, mess54,
     >                ulbila, ulsort, langue, codret )
c
      call gtfims (nsectl(4))
      endif
c
      endif
c
c====
c 6. controle de la non-interpenetration des volumes
c    remarque : on ne s'interesse qu'aux actifs car les autres sont
c    censes avoir ete controles aux iterations anterieures
c====
c
c 6.1 ==> Noeuds dans les tetraedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.1 tetraedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbteac.ne.0 ) then
      call gtdems (nsectl(3))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3D0', nompro
#endif
        call utb3d0 ( hetnoe, coonoe,
     >                imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >                somare,
     >                aretri,
     >                hettet, tritet, cotrte, aretet, np2are,
     >                nbpbco, mess08, mess54,
     >                ulbila, ulsort, langue, codret )

      call gtfims (nsectl(3))
      endif
c
      endif
c
c 6.2 ==> Noeuds dans les hexaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.2. hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbheac', nbheac
#endif
c
      if ( nbheac.ne.0 ) then
      call gtdems (nsectl(6))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3E0', nompro
#endif
        call utb3e0 ( hetnoe, coonoe,
     >                imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >                somare,
     >                arequa,
     >                hethex, quahex, coquhe, arehex, np2are,
     >                nbpbco, mess08, mess54,
     >                ulbila, ulsort, langue, codret )

      call gtfims (nsectl(6))
      endif
c
      endif
c
c 6.3 ==> Noeuds dans les pyramides
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.3. pyramides ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpyac', nbpyac
#endif
c
      if ( nbpyac.ne.0 ) then
      call gtdems (nsectl(5))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3F0', nompro
#endif
        call utb3f0 ( hetnoe, coonoe,
     >                imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >                somare,
     >                aretri,
     >                hetpyr, facpyr, cofapy, arepyr, np2are,
     >                nbpbco, mess08, mess54,
     >                ulbila, ulsort, langue, codret )
c
      call gtfims (nsectl(5))
      endif
c
      endif
c
c 6.4 ==> Noeuds dans les pentaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.4. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpeac', nbpeac
#endif
c
      if ( nbpeac.ne.0 ) then
      call gtdems (nsectl(7))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3G0', nompro
#endif
        call utb3g0 ( hetnoe, coonoe,
     >                imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >                somare,
     >                arequa,
     >                hetpen, facpen, cofape, arepen, np2are,
     >                nbpbco, mess08, mess54,
     >                ulbila, ulsort, langue, codret )

      call gtfims (nsectl(7))
      endif
c
      endif
c
c====
c 7. bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. Bilan ; codret', codret
#endif
c
   70 continue
c
      do 71 , iaux = 1 , 2
c
      if ( iaux.eq.1 ) then
        kaux = ulbila
      else
        if ( ulbila.eq.ulsort ) then
          goto 71
        else
          kaux = ulsort
        endif
      endif
c
      do 72 , jaux = -1 , 7
c
        if ( nbpbco(jaux).ge.0 ) then
c
          write (kaux,10100)
          saux54 = mess54(langue,16)
          saux54(30:43) = mess14(langue,3,jaux)
          write (kaux,11100) saux54
          write (kaux,10300)
          if ( nbpbco(jaux).eq.0 ) then
            write (kaux,11100) mess54(langue,1)
          else
            if ( jaux.eq.-1 ) then
              write (kaux,12200) mess54(langue,8), nbpbco(jaux)
            else
              if ( nbpbco(jaux).eq.1 ) then
                write (kaux,11100) mess54(langue,13)
              else
                write (kaux,12100) nbpbco(jaux), mess43(langue,1)
              endif
            endif
          endif
          write (kaux,10200)
c
        endif
c
   72 continue
c
      if ( max(nbpbco(0),nbpbco(1),nbpbco(2),nbpbco(3),nbpbco(4),
     >         nbpbco(5),nbpbco(6),nbpbco(7)).gt.0 ) then
        write (kaux,10100)
        write (kaux,11100) mess54(langue,20)
        write (kaux,10200)
      endif
c
   71 continue
c
10100 format(/,5x,58('*'),
     /       /,5x,'*',56x,'*')
10200 format(  5x,'*',56x,'*',
     /       /,5x,58('*'),/)
10300 format(  5x,'*',56x,'*')
c
11100 format(  5x,'* ',a54,' *')
c
12100 format(  5x,'* ',i8,1x,a43,'   *')
12200 format(  5x,'* ',a43,1x,i8,'   *')
c
c====
c 8. menage
c====
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
      call gmlboj ( ntrav3, codre3 )
      call gmlboj ( ntrav4, codre4 )
      call gmlboj ( ntrav5, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
c====
c 9. on impose un code de retour toujours nul
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
#endif
c
      endif
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
