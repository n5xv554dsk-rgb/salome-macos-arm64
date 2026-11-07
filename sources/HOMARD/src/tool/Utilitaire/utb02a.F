      subroutine utb02a ( hetare,
     >                    hettri, pertri, voltri,
     >                    hetqua, volqua,
     >                    posifa, facare,
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
c    UTilitaire - Bilan sur le maillage - option 02
c    --           -                              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . pertri . e   . nbtrto . pere des triangles                         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
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
      parameter ( nompro = 'UTB02A' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "envada.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer hetare(nbarto)
      integer hettri(nbtrto), pertri(nbtrto)
      integer voltri(2,nbtrto)
      integer hetqua(nbquto)
      integer volqua(2,nbquto)
      integer posifa(0:nbarto), facare(nbfaar)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer larete, letria,lequad
      integer nbarba, nbarbt, nbaria, nbarit
      integer nbfaba, nbfabt, nbfava, nbfavt
      integer pos, fac1, fac2, vois1, vois2
      integer iaux, jaux
c
      logical arbord
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
      character*54 mess54(nblang,nbmess)
      character*43 saux43
      character*43 mess43(nblang,150)
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
      texte(1,4) =
     > '(//,3x,''NOMBRE D''''ENTITES HOMARD'',/,3x,23(''=''),/)'
c
      texte(2,4) =
     > '(//,3x,''NUMBER OF HOMARD ENTITIES'',/,3x,25(''=''),/)'
c
      mess54(1,5) =
     > '   Le maillage presente des homologues                '
c
c                     1234567890123456789012345678901234567890123
      mess43(1,1)  = 'Nombre total                               '
      mess43(1,2)  = '. dont sommets d''aretes (noeud P1)         '
      mess43(1,3)  = '. dont milieux d''aretes (noeud P2)         '
      mess43(1,4)  = '. dont noeuds internes aux mailles         '
      mess43(1,5)  = '. dont noeuds isoles                       '
      mess43(1,6)  = '. dont noeuds mailles ignorees uniquement  '
      mess43(1,7)  = '. dont noeuds mailles-points uniquement    '
      mess43(1,8)  = 'Nombre de noeuds du macro-maillage         '
c
      mess43(1,12) = 'Ces aretes sont reparties en N types :     '
      mess43(1,13) = '. des aretes du macro-maillage             '
      mess43(1,14) = '. des aretes crees par le decoupage        '
      mess43(1,15) = '. des aretes creees par le decoupage en    '
      mess43(1,16) = '  deux des triangles                       '
      mess43(1,17) = '  - trois triangles des quadrangles        '
      mess43(1,18) = '  - deux quadrangles des quadrangles       '
      mess43(1,19) = '  - trois quadrangles des quadrangles      '
      mess43(1,20) = '. des aretes internes pour le decoupage par'
      mess43(1,21) = '  conformite des                           '
      mess43(1,26) = '. dont aretes isolees                      '
      mess43(1,27) = '. dont aretes de bord de regions 2D        '
      mess43(1,28) = '. dont aretes internes aux faces/volumes   '
      mess43(1,29) = 'Nombre d''aretes actives                    '
c
c                     1234567890123456789012345678901234567890123
      mess43(1,31) = 'Ces triangles sont d''un seul type :        '
      mess43(1,32) = 'Ces triangles sont repartis en N types :   '
      mess43(1,33) = '. des triangles du macro-maillage          '
      mess43(1,34) = '. des triangles crees par le decoupage     '
      mess43(1,38) = '. des triangles crees par le decoupage en  '
      mess43(1,39) = '  deux des triangles                       '
      mess43(1,40) = '  trois des quadrangles                    '
      mess43(1,41) = '. des triangles internes aux tetraedres    '
      mess43(1,42) = '  decoupes en deux ou quatre               '
      mess43(1,43) = '. des triangles internes aux hexaedres     '
      mess43(1,44) = '. des triangles internes aux pentaedres    '
      mess43(1,45) = '  decoupes par conformite                  '
      mess43(1,46) = '. dont triangles de regions 2D             '
      mess43(1,47) = '. dont triangles de bord                   '
      mess43(1,48) = '. dont triangles internes aux volumes      '
      mess43(1,49) = 'Nombre de triangles actifs                 '
c
      mess43(1,51) = 'Ces quadrangles sont d''un seul type :      '
      mess43(1,52) = 'Ces quadrangles sont repartis en N types : '
      mess43(1,53) = '. des quadrangles du macro-maillage        '
      mess43(1,54) = '. des quadrangles crees par le decoupage   '
      mess43(1,58) = '. des quadrangles crees par le decoupage en'
      mess43(1,59) = '  - deux des quadrangles                   '
      mess43(1,60) = '  - trois des quadrangles                  '
      mess43(1,66) = '. dont quadrangles de regions 2D           '
      mess43(1,67) = '. dont quadrangles de bord                 '
      mess43(1,68) = '. dont quadrangles internes aux volumes    '
      mess43(1,69) = 'Nombre de quadrangles actifs               '
c
c                     1234567890123456789012345678901234567890123
      mess43(1,71) = 'Ces tetraedres sont d''un seul type :       '
      mess43(1,72) = 'Ces tetraedres sont repartis en            '
      mess43(1,73) = '. des tetraedres du macro-maillage         '
      mess43(1,74) = '. des tetraedres crees par le decoupage    '
      mess43(1,75) = '. des tetraedres crees par le decoupage    '
      mess43(1,76) = '  d''un tetra en quatre a partir d''une face '
      mess43(1,77) = '  d''un tetra en quatre a partir de 2 aretes'
      mess43(1,78) = '  d''un tetra en deux a partir d''une arete  '
      mess43(1,79) = 'Nombre de tetraedres actifs                '
c
      mess43(1,81) = 'Ces hexaedres sont d''un seul type :        '
      mess43(1,82) = 'Ces hexaedres sont repartis en N types :   '
      mess43(1,83) = '. des hexaedres du macro-maillage          '
      mess43(1,84) = '. des hexaedres crees par le decoupage     '
      mess43(1,85) = '  de conformite des hexaedres              '
      mess43(1,89) = 'Nombre d''hexaedres actifs                  '
c
c                     1234567890123456789012345678901234567890123
      mess43(1,91) = 'Ces pyramides sont d''un seul type :        '
      mess43(1,92) = 'Ces pyramides sont reparties en N types :  '
      mess43(1,93) = '. des pyramides du macro-maillage          '
      mess43(1,94) = '. des pyramides creees par le decoupage    '
      mess43(1,95) = '. des pyramides creees par le decoupage    '
      mess43(1,99) = 'Nombre de pyramides actives                '
c
      mess43(1,101) = 'Ces pentaedres sont repartis en N types :  '
      mess43(1,102) = '. des pentaedres du macro-maillage         '
      mess43(1,103) = '. des pentaedres crees par le decoupage    '
      mess43(1,109) = 'Nombre de pentaedres actifs                '
c
      mess43(1,111) = '  a partir d''une face d''hexaedre           '
      mess43(1,112) = '  a partir de trois aretes d''hexaedre      '
      mess43(1,113) = '  a partir de deux aretes d''hexaedre       '
      mess43(1,114) = '  a partir d''une arete d''hexaedre          '
c
      mess43(1,121) = '  a partir d''une arete tri de pentaedre    '
      mess43(1,122) = '  a partir d''une arete qua de pentaedre    '
      mess43(1,123) = '  a partir de 2 aretes tri/qua de pentaedre'
      mess43(1,124) = '  a partir de 2 aretes tri de pentaedre    '
      mess43(1,125) = '  a partir d''une face qua de pentaedre    '
      mess43(1,126) = '  a partir d''une face tri de pentaedre    '
c
      mess43(1,130) = 'Paires de                                  '
c                     1234567890123456789012345678901234567890123
c
      mess43(1,131) = '  standard du maillage                     '
c
      mess54(2,5) =
     > '   The mesh implies homologous condition.             '
c
c                     1234567890123456789012345678901234567890123
      mess43(2,1)  = 'Total number                               '
      mess43(2,2)  = '. included vertices of edges (P1 node)     '
      mess43(2,3)  = '. included centers of edges (P2 node)      '
      mess43(2,4)  = '. included internal nodes                  '
      mess43(2,5)  = '. included isolated nodes                  '
      mess43(2,6)  = '. included only ignored meshes nodes       '
      mess43(2,7)  = '. included only mesh-point nodes           '
      mess43(2,8)  = 'Nodes from the initial mesh                '
c
      mess43(2,12) = 'These edges compose N types:               '
      mess43(2,13) = '. edges from the initial mesh              '
      mess43(2,14) = '. edges created for the standard           '
      mess43(2,15) = '. edges created for the cutting into       '
      mess43(2,16) = '  two of triangles                         '
      mess43(2,17) = '  - three triangles of quadrangles         '
      mess43(2,18) = '  - two quadrangles of quadrangles         '
      mess43(2,19) = '  - three quadrangles of quadrangles       '
      mess43(2,20) = '. internal edges for the cutting by        '
      mess43(2,21) = '  conformity of the                        '
      mess43(2,26) = '. included isolated edges                  '
      mess43(2,27) = '. included boundaries of 2D areas          '
      mess43(2,28) = '. included internal in faces/volumes       '
      mess43(2,29) = 'Number of active edges                     '
c
c                     1234567890123456789012345678901234567890123
      mess43(2,31) = 'These triangles compose one single type:   '
      mess43(2,32) = 'These triangles compose N types:           '
      mess43(2,33) = '. triangles from the initial mesh          '
      mess43(2,34) = '. triangles created for the standard       '
      mess43(2,38) = '. triangles created for the cutting into   '
      mess43(2,39) = '  two of triangles                         '
      mess43(2,40) = '  three of quadrangles                     '
      mess43(2,41) = '. internal triangles for tetraedra cutting '
      mess43(2,42) = '  into two or four                         '
      mess43(2,43) = '. internal triangles for hexaedra cutting  '
      mess43(2,44) = '. internal triangles for prisms cutting    '
      mess43(2,45) = '  by conformity                            '
      mess43(2,46) = '. included triangles of 2D areas           '
      mess43(2,47) = '. included boundary triangles              '
      mess43(2,48) = '. included internal triangles              '
      mess43(2,49) = 'Number of active triangles                 '
c
      mess43(2,51) = 'These quadrangles compose one single type: '
      mess43(2,52) = 'These quadrangles compose N types:         '
      mess43(2,53) = '. quadrangles from the initial mesh        '
      mess43(2,54) = '. quadrangles created for the standard     '
      mess43(2,58) = '. quadrangles created for the cutting into '
      mess43(2,59) = '  - two of quadrangles                     '
      mess43(2,60) = '  - three of quadrangles                   '
      mess43(2,66) = '. included quadrangles of 2D areas         '
      mess43(2,67) = '. included boundary quadrangles            '
      mess43(2,68) = '. included internal quadrangles            '
      mess43(2,69) = 'Number of active quadrangles               '
c
c                     1234567890123456789012345678901234567890123
      mess43(2,71) = 'These tetrahedra compose one single type:  '
      mess43(2,72) = 'These tetrahedra compose                   '
      mess43(2,73) = '. tetrahedra from the initial mesh         '
      mess43(2,74) = '. tetrahedra created for the standard      '
      mess43(2,75) = '. tetrahedra created for the cutting       '
      mess43(2,76) = '  of a tetrahedron into four from a face   '
      mess43(2,77) = '  of a tetrahedron into four from 2 edges  '
      mess43(2,78) = '  of a tetrahedron into two from an edge   '
      mess43(2,79) = 'Number of active tetrahedra                '
c
c                     1234567890123456789012345678901234567890123
      mess43(2,81) = 'These hexahedra compose one single type:   '
      mess43(2,82) = 'These hexahedra compose N types:           '
      mess43(2,83) = '. hexahedra from the initial mesh          '
      mess43(2,84) = '. hexahedra created for the standard       '
      mess43(2,85) = '  of the hexahedra for the conformity      '
      mess43(2,89) = 'Number of active hexahedra                 '
c
c                     1234567890123456789012345678901234567890123
      mess43(2,91) = 'These pyramids compose one single type:    '
      mess43(2,92) = 'These pyramids compose N types:            '
      mess43(2,93) = '. pyramids from the initial mesh           '
      mess43(2,94) = '. pyramids created for the standard        '
      mess43(2,95) = '. pyramids created for the splitting       '
      mess43(2,99) = 'Number of active pyramids                  '
c
c                     1234567890123456789012345678901234567890123
      mess43(2,101) = 'These pentahedra compose N types:          '
      mess43(2,102) = '. pentahedra from the initial mesh         '
      mess43(2,103) = '. pentahedra created for the standard      '
      mess43(2,109) = 'Number of active pentahedra                '
c
      mess43(2,111) = '  from a face of an hexahedron             '
      mess43(2,112) = '  from three edges of an hexahedron        '
      mess43(2,113) = '  from two edges of an hexahedron          '
      mess43(2,114) = '  from one edge of an hexahedron           '
c
      mess43(2,121) = '  from one edge tri of a prism             '
      mess43(2,122) = '  from one edge qua of a prism             '
      mess43(2,123) = '  from two edges tri/qua of a prism        '
      mess43(2,124) = '  from two edges tri of a prism            '
      mess43(2,125) = '  from one face qua of a prism             '
      mess43(2,126) = '  from one face tri of a prism             '
c
      mess43(2,130) = 'Pairs of                                   '
c                     1234567890123456789012345678901234567890123
c
      mess43(2,131) = '  refinement of the mesh                   '
c
      write (ulbila,texte(langue,4))
c
#include "impr03.h"
c
10100 format(/,5x,60('*'))
10200 format(  5x,60('*'))
c
11100 format(  5x,'*  ',a54,'  *')
11200 format(  5x,'* ',21x,a14,21x,' *')
c
12100 format(  5x,'* ',a43,' *',   12x,'*')
12200 format(  5x,'* ',a43,' * ', i10,' *')
c
      codret = 0
c
c====
c 2. noeuds
c====
c
      write (ulbila,10100)
      write (ulbila,11200) mess14(langue,4,-1)
      write (ulbila,10200)
      write (ulbila,12200) mess43(langue,1), nbnoto
      if ( degre.eq.2 .or.
     >     nbnois.ne.0 .or. nbnoei.ne.0 .or. nbnomp.ne.0 ) then
        write (ulbila,12200) mess43(langue,2), nbnop1
      endif
      if ( degre.eq.2 ) then
        write (ulbila,12200) mess43(langue,3), nbnop2
      endif
      if ( mod(mailet,2).eq.0 .or.
     >     mod(mailet,3).eq.0 .or.
     >     mod(mailet,5).eq.0 ) then
        write (ulbila,12200) mess43(langue,4), nbnoim
      endif
      if ( nbnois.ne.0 ) then
        write (ulbila,12200) mess43(langue,5), nbnois
      endif
      if ( nbnoei.ne.0 ) then
        write (ulbila,12200) mess43(langue,6), nbnoei
      endif
      if ( nbnomp.ne.0 ) then
        write (ulbila,12200) mess43(langue,7), nbnomp
      endif
      write (ulbila,12200) mess43(langue,8), nbnoma
      write (ulbila,10200)
c
c====
c 3. mailles-points
c====
c
      if ( nbmpto.ne.0 ) then
c
        write (ulbila,10100)
        write (ulbila,11200) mess14(langue,4,0)
        write (ulbila,10200)
        write (ulbila,12200) mess43(langue,1), nbmpto
        write (ulbila,10200)
c
      endif
c
c====
c 4. aretes
c====
c
c on definit une arete de bord comme etant une arete ayant :
c   . une seule face voisine,
c   . deux faces voisines :
c     . deux triangles dont l'un est le pere de l'autre : cas du
c       decoupage de conformite provenant de l'arete de bord ; cela n'a
c       lieu qu'avec des homologues.
c     . un triangle et un quadrangle qui en est le pere des autres : cas
c       du decoupage non conforme d'un quadrangle de bord.
c
      nbarba = 0
      nbarbt = 0
      nbaria = 0
      nbarit = 0
c
      do 41 , larete = 1, nbarto
c
        arbord = .false.
c
        if ( posifa(larete-1)+2.eq.posifa(larete) ) then
          pos = posifa(larete)
          fac1 = facare(pos-1)
          fac2 = facare(pos)
          if ( fac1.gt.0 .and. fac2.gt.0 ) then
            vois1 = min(fac1,fac2)
            vois2 = max(fac1,fac2)
            if ( pertri(vois2).eq.vois1 ) then
              arbord = .true.
            endif
          elseif ( fac1.gt.0 .and. fac2.lt.0 ) then
            if ( pertri(fac1).eq.fac2 ) then
              arbord = .true.
            endif
          elseif ( fac1.lt.0 .and. fac2.gt.0 ) then
            if ( pertri(fac2).eq.fac1 ) then
              arbord = .true.
            endif
          endif
        elseif ( posifa(larete-1)+1.eq.posifa(larete) ) then
          arbord = .true.
        elseif ( posifa(larete-1)+1.gt.posifa(larete) ) then
          nbarit = nbarit +1
          if ( mod(hetare(larete),10).eq.0 ) then
            nbaria = nbaria + 1
          endif
        endif
c
        if ( arbord ) then
cgn        write(ulsort,*) 'larete = ',larete
cgn        write(ulsort,*) '... ',posifa(larete-1), posifa(larete),
cgn     >                   ' ==> face = ',facare(posifa(larete))
          nbarbt = nbarbt +1
          if ( mod(hetare(larete),10).eq.0 ) then
            nbarba = nbarba + 1
          endif
        endif
c
   41 continue
c
      write (ulbila,10100)
      write (ulbila,11200) mess14(langue,4,1)
      write (ulbila,10200)
      write (ulbila,12200) mess43(langue,1), nbarto
      if ( nbtrto.ne.0 .or. nbquto.ne.0 ) then
        write (ulbila,12200) mess43(langue,26), nbarit
        write (ulbila,12200) mess43(langue,27), nbarbt
        write (ulbila,12200) mess43(langue,28), nbarto-nbarit-nbarbt
      endif
      if ( nbiter.ge.1 ) then
        iaux = 2
        if ( ( maconf.eq.0 ) .or. ( maconf.eq.-1 ) ) then
          if ( nbtrma.ne.0 ) then
            iaux = iaux + 1
          endif
          if ( nbquma.ne.0 ) then
            iaux = iaux + 1
          endif
          if ( nbtema.ne.0 .or. nbhema.ne.0 .or.
     >         nbpema.ne.0 .or. nbpyma.ne.0 ) then
            iaux = iaux + 1
          endif
        endif
        if ( langue.eq.1 ) then
          jaux = 30
        else
          jaux = 21
        endif
        saux43 = mess43(langue,12)
        write(saux43(jaux:jaux),'(i1)') iaux
        write (ulbila,12100) saux43
        write (ulbila,12200) mess43(langue,13), nbarma
        write (ulbila,12100) mess43(langue,14)
        write (ulbila,12200) mess43(langue,131), nbarde
        if ( ( maconf.eq.0 ) .or. ( maconf.eq.-1 ) ) then
          if ( nbtrma.ne.0 ) then
            write (ulbila,12100) mess43(langue,15)
            write (ulbila,12200) mess43(langue,16), nbart2
          endif
          if ( nbquma.ne.0 ) then
            write (ulbila,12100) mess43(langue,15)
            write (ulbila,12200) mess43(langue,17), nbarq3
            write (ulbila,12200) mess43(langue,18), nbarq2
            write (ulbila,12200) mess43(langue,19), nbarq5
          endif
          if ( nbtema.ne.0 .or. nbhema.ne.0 .or.
     >         nbpema.ne.0 .or. nbpyma.ne.0 ) then
            write (ulbila,12100) mess43(langue,20)
            if ( nbtema.ne.0 .and.
     >          (       nbhema+nbpema+nbpyma).eq.0 ) then
              iaux = 3
            elseif ( nbhema.ne.0 .and.
     >              (nbtema       +nbpema+nbpyma).eq.0 ) then
              iaux = 6
             elseif ( nbpema.ne.0 .and.
     >              (nbtema+nbhema       +nbpyma).eq.0 ) then
              iaux = 7
             elseif ( nbpyma.ne.0 .and.
     >              (nbtema+nbhema+nbpema       ).eq.0 ) then
              iaux = 5
           else
              iaux = 9
            endif
            saux43 = mess43(langue,21)
            if ( langue.eq.1 ) then
              jaux = 18
            else
              jaux = 21
            endif
            saux43(jaux:jaux+13) = mess14(langue,3,iaux)
            write (ulbila,12200) saux43, nbarin
          endif
        endif
        write (ulbila,10200)
        write (ulbila,12200) mess43(langue,29), nbarac
        if ( nbtrma.ne.0 .or. nbquma.ne.0 ) then
          write (ulbila,12200) mess43(langue,26), nbaria
          write (ulbila,12200) mess43(langue,27), nbarba
          write (ulbila,12200) mess43(langue,28), nbarac-nbaria-nbarba
        endif
      endif
      write (ulbila,10200)
c
c====
c 5. triangles
c====
c
      if ( nbtrto.ne.0 ) then
c
c 5.1. ==> Les generalites
c
        write (ulbila,10100)
        write (ulbila,11200) mess14(langue,4,2)
        write (ulbila,10200)
        write (ulbila,12200) mess43(langue,1), nbtrto
c
c 5.2. ==> Les bords
c          Un triangle de bord est un triangle ayant un et un seul
c          volume voisin.
c          Le stockage etant different de la dimension deux, le tableau
c          voltri ne garde que le volume fils.
c
        if ( nbteto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
c
          nbfaba = 0
          nbfabt = 0
          nbfava = 0
          nbfavt = 0
          do 52 , letria = 1, nbtrto
            if ( voltri(1,letria).ne.0 ) then
              if ( voltri(2,letria).eq.0 ) then
                nbfabt = nbfabt + 1
                if ( mod(hettri(letria),10).eq.0 ) then
                  nbfaba = nbfaba + 1
                endif
              else
                nbfavt = nbfavt + 1
                if ( mod(hettri(letria),10).eq.0 ) then
                  nbfava = nbfava + 1
                endif
              endif
            endif
   52     continue
c
          write (ulbila,12200) mess43(langue,46), nbtrto-nbfabt-nbfavt
          write (ulbila,12200) mess43(langue,47), nbfabt
          write (ulbila,12200) mess43(langue,48), nbfavt
c
        endif
c
c 5.3. ==> Les historiques
c
        if ( nbiter.ge.1 ) then
c
          iaux = 0
          if ( nbtrma.ne.0 ) then
            iaux = iaux + 2
          endif
          if ( ( maconf.eq.0 ) .or. ( maconf.eq.-1 ) ) then
            if ( nbtrma.ne.0 ) then
              iaux = iaux + 1
            endif
            if ( nbquma.ne.0 ) then
              iaux = iaux + 1
            endif
            if ( nbtema.ne.0 ) then
              iaux = iaux + 1
            endif
            if ( nbhema.ne.0 ) then
              iaux = iaux + 1
            endif
            if ( nbpema.ne.0 ) then
              iaux = iaux + 1
            endif
          endif
          if ( iaux.eq.1 ) then
            saux43 = mess43(langue,31)
          else
            saux43 = mess43(langue,32)
            if ( langue.eq.1 ) then
              jaux = 32
            else
              jaux = 25
            endif
            write(saux43(jaux:jaux),'(i1)') iaux
          endif
          write (ulbila,12100) saux43
          if ( nbtrma.ne.0 ) then
            write (ulbila,12200) mess43(langue,33), nbtrma
            write (ulbila,12100) mess43(langue,34)
            write (ulbila,12200) mess43(langue,131), nbtrde
          endif
          if ( ( maconf.eq.0 ) .or. ( maconf.eq.-1 ) ) then
            if ( nbtrma.ne.0 ) then
              write (ulbila,12100) mess43(langue,38)
              write (ulbila,12200) mess43(langue,39), nbtrt2
            endif
            if ( nbquma.ne.0 ) then
              write (ulbila,12100) mess43(langue,38)
              write (ulbila,12200) mess43(langue,40), nbtrq3
            endif
            if ( nbtema.ne.0 ) then
              write (ulbila,12100) mess43(langue,41)
              write (ulbila,12200) mess43(langue,42), nbtrtc
            endif
            if ( nbhema.ne.0 ) then
              write (ulbila,12100) mess43(langue,43)
              write (ulbila,12200) mess43(langue,45), nbtrhc
              endif
            if ( nbpema.ne.0 ) then
              write (ulbila,12100) mess43(langue,44)
              write (ulbila,12200) mess43(langue,45), nbtrpc
            endif
          endif
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,49), nbtrac
          if ( nbteto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
            write (ulbila,12200) mess43(langue,46), nbtrac-nbfaba-nbfava
            write (ulbila,12200) mess43(langue,47), nbfaba
            write (ulbila,12200) mess43(langue,48), nbfava
          endif
        endif
c
        write (ulbila,10200)
c
      endif
c
c====
c 6. quadrangles
c====
c
      if ( nbquto.ne.0 ) then
c
c 6.1. ==> Les generalites
c
        write (ulbila,10100)
        write (ulbila,11200) mess14(langue,4,4)
        write (ulbila,10200)
        write (ulbila,12200) mess43(langue,1), nbquto
c
c 6.2. ==> Les bords
c          Un quadrangle de bord est un quadrangle ayant un et un seul
c          volume voisin.
c          Le stockage etant different de la dimension deux, le tableau
c          volqua ne garde que le volume fils.
c
        if ( nbheto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
c
          nbfaba = 0
          nbfabt = 0
          nbfava = 0
          nbfavt = 0
          do 62 , lequad = 1, nbquto
            if ( volqua(1,lequad).ne.0 ) then
              if ( volqua(2,lequad).eq.0 ) then
                nbfabt = nbfabt + 1
                if ( mod(hetqua(lequad),100).eq.0 ) then
                  nbfaba = nbfaba + 1
                endif
              else
                nbfavt = nbfavt + 1
                if ( mod(hetqua(lequad),100).eq.0 ) then
                  nbfava = nbfava + 1
                endif
              endif
            endif
   62     continue
c
          write (ulbila,12200) mess43(langue,66), nbquto-nbfabt-nbfavt
          write (ulbila,12200) mess43(langue,67), nbfabt
          write (ulbila,12200) mess43(langue,68), nbfavt
c
        endif
c
c 6.3. ==> Les historiques
c
        if ( nbiter.ge.1 ) then
c
          iaux = 0
          if ( nbquma.ne.0 ) then
            iaux = iaux + 2
          endif
          if ( iaux.eq.1 ) then
            saux43 = mess43(langue,51)
          else
            saux43 = mess43(langue,52)
            if ( langue.eq.1 ) then
              jaux = 34
            else
              jaux = 27
            endif
            write(saux43(jaux:jaux),'(i1)') iaux
          endif
          write (ulbila,12100) saux43
          write (ulbila,12200) mess43(langue,53), nbquma
          write (ulbila,12100) mess43(langue,54)
          write (ulbila,12200) mess43(langue,131), nbqude
          if ( ( maconf.eq.0 ) .or. ( maconf.eq.-1 ) ) then
            if ( nbquma.ne.0 ) then
              write (ulbila,12100) mess43(langue,58)
              write (ulbila,12200) mess43(langue,59), nbquq2
              write (ulbila,12200) mess43(langue,60), nbquq5
            endif
          endif
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,69), nbquac
          if ( nbheto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
            write (ulbila,12200) mess43(langue,66), nbquac-nbfaba-nbfava
            write (ulbila,12200) mess43(langue,67), nbfaba
            write (ulbila,12200) mess43(langue,68), nbfava
          endif
        endif
c
        write (ulbila,10200)
c
      endif
c
c====
c 7. tetraedres
c====
c
      if ( nbteto.ne.0 ) then
c
        write (ulbila,10100)
        write (ulbila,11200) mess14(langue,4,3)
        write (ulbila,10200)
        write (ulbila,12200) mess43(langue,1), nbteto
        if ( nbiter.ge.1 ) then
          iaux = 0
          if ( nbtema.ne.0 ) then
            iaux = iaux + 2
          endif
          if ( nbtef4.ne.0 .or. nbtea4.ne.0 .or. nbtea2.ne.0 ) then
            iaux = iaux + 3
          endif
          if ( nbheco.ne.0 ) then
            iaux = iaux + 3
          endif
          if ( nbpeco.ne.0 ) then
            iaux = iaux + 6
          endif
          if ( iaux.eq.1 ) then
            saux43 = mess43(langue,71)
          else
            if ( langue.eq.1 ) then
              jaux = 33
            else
              jaux = 26
            endif
            saux43 = mess43(langue,72)
            if ( iaux.le.9 ) then
              write(saux43(jaux:jaux),'(i1)') iaux
              jaux = jaux + 2
            else
              write(saux43(jaux:jaux+1),'(i2)') iaux
              jaux = jaux + 3
            endif
            saux43(jaux:jaux+4) = 'types'
            if ( langue.eq.1 ) then
              jaux = jaux + 6
            else
              jaux = jaux + 5
            endif
            saux43(jaux:jaux) = ':'
          endif
          write (ulbila,12100) saux43
          if ( nbtema.ne.0 ) then
            write (ulbila,12200) mess43(langue,73), nbtema
            write (ulbila,12100) mess43(langue,74)
            write (ulbila,12200) mess43(langue,131), nbtede
          endif
          if ( nbtef4.ne.0 .or. nbtea4.ne.0 .or. nbtea2.ne.0 ) then
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,76), nbtef4
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,77), nbtea4
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,78), nbtea2
          endif
          if ( nbheco.ne.0 ) then
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,111), nbteh1
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,112), nbteh2
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,113), nbteh3
          endif
          if ( nbpeco.ne.0 ) then
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,121), nbtep0
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,122), nbtep1
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,123), nbtep2
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,124), nbtep3
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,125), nbtep4
            write (ulbila,12100) mess43(langue,75)
            write (ulbila,12200) mess43(langue,126), nbtep5
          endif
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,79), nbteac
        endif
        write (ulbila,10200)
c
      endif
c
c====
c 8. hexaedres
c====
c
      if ( nbheto.ne.0 ) then
c
        write (ulbila,10100)
        write (ulbila,11200) mess14(langue,4,6)
        write (ulbila,10200)
        write (ulbila,12200) mess43(langue,1), nbheto
        if ( nbiter.ge.1 ) then
          iaux = 0
          if ( nbhema.ne.0 ) then
            iaux = iaux + 2
          endif
          if ( iaux.eq.1 ) then
            saux43 = mess43(langue,81)
          else
            if ( langue.eq.1 ) then
              jaux = 32
            else
              jaux = 25
            endif
            saux43 = mess43(langue,82)
            write(saux43(jaux:jaux),'(i1)') iaux
          endif
          write (ulbila,12100) saux43
          if ( nbhema.ne.0 ) then
            write (ulbila,12200) mess43(langue,83), nbhema
            write (ulbila,12100) mess43(langue,84)
            write (ulbila,12200) mess43(langue,131), nbhede
          endif
          if ( nbhedh.ne.0 ) then
            write (ulbila,12100) mess43(langue,84)
            write (ulbila,12200) mess43(langue,131), nbhedh
          endif
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,89), nbheac
        endif
        write (ulbila,10200)
c
      endif
c
c====
c 9. pyramides
c====
c
      if ( nbpyto.ne.0 ) then
c
        write (ulbila,10100)
        write (ulbila,11200) mess14(langue,4,5)
        write (ulbila,10200)
        write (ulbila,12200) mess43(langue,1), nbpyto
        if ( nbiter.ge.1 ) then
          iaux = 0
          if ( nbpyma.ne.0 ) then
            iaux = iaux + 1
          endif
          if ( nbheco.ne.0 ) then
            if ( maconf.eq.-1 ) then
              iaux = iaux + 3
            else
              iaux = iaux + 1
            endif
          endif
          if ( nbpeco.ne.0 ) then
            iaux = iaux + 6
          endif
          if ( iaux.eq.1 ) then
            saux43 = mess43(langue,91)
          else
            if ( langue.eq.1 ) then
              jaux = 33
            else
              jaux = 24
            endif
            saux43 = mess43(langue,92)
            write(saux43(jaux:jaux),'(i1)') iaux
          endif
          write (ulbila,12100) saux43
          if ( nbpyma.ne.0 ) then
            write (ulbila,12200) mess43(langue,93), nbpyma
          endif
          if ( nbheco.ne.0 ) then
            if ( maconf.eq.-1 ) then
              write (ulbila,12100) mess43(langue,94)
              write (ulbila,12200) mess43(langue,111), nbpyh1
              write (ulbila,12100) mess43(langue,94)
              write (ulbila,12200) mess43(langue,113), nbpyh3
              write (ulbila,12100) mess43(langue,94)
              write (ulbila,12200) mess43(langue,114), nbpyh4
            else
              write (ulbila,12100) mess43(langue,95)
              write (ulbila,12200) mess43(langue,85), nbpydh
            endif
          endif
          if ( nbpeco.ne.0 ) then
            write (ulbila,12100) mess43(langue,94)
            write (ulbila,12200) mess43(langue,121), nbpyp0
            write (ulbila,12100) mess43(langue,94)
            write (ulbila,12200) mess43(langue,122), nbpyp1
            write (ulbila,12100) mess43(langue,94)
            write (ulbila,12200) mess43(langue,123), nbpyp2
            write (ulbila,12100) mess43(langue,94)
            write (ulbila,12200) mess43(langue,124), nbpyp3
            write (ulbila,12100) mess43(langue,94)
            write (ulbila,12200) mess43(langue,125), nbpyp4
            write (ulbila,12100) mess43(langue,94)
            write (ulbila,12200) mess43(langue,126), nbpyp5
          endif
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,99), nbpyac
        endif
        write (ulbila,10200)
c
      endif
c
c====
c 10. pentaedres
c====
c
      if ( nbpeto.ne.0 ) then
c
        write (ulbila,10100)
        write (ulbila,11200) mess14(langue,4,7)
        write (ulbila,10200)
        write (ulbila,12200) mess43(langue,1), nbpeto
        if ( nbiter.ge.1 ) then
          iaux = 0
          if ( nbpema.ne.0 ) then
            iaux = iaux + 2
          endif
          if ( langue.eq.1 ) then
            jaux = 33
          else
            jaux = 26
          endif
          saux43 = mess43(langue,101)
          write(saux43(jaux:jaux),'(i1)') iaux
          write (ulbila,12100) saux43
          if ( nbpema.ne.0 ) then
            write (ulbila,12200) mess43(langue,102), nbpema
            write (ulbila,12100) mess43(langue,103)
            write (ulbila,12200) mess43(langue,131), nbpede
          endif
          write (ulbila,10200)
          write (ulbila,12200) mess43(langue,109), nbpeac
        endif
        write (ulbila,10200)
c
      endif
c
c====
c 11. reperage des homologues
c====
c
      if ( homolo.ne.0 ) then
c
        write (ulbila,10100)
        write (ulbila,11100) mess54(langue,5)
        write (ulbila,10200)
        saux43 = mess43(langue,130)
        saux43(11:24) = mess14(langue,3,-1)
        write (ulbila,12200) saux43, nbpnho
        if (nbppho.gt.0) then
          saux43(11:24) = mess14(langue,3,0)
          write (ulbila,12200) saux43, nbppho
        endif
        if (nbpaho.gt.0) then
          saux43(11:24) = mess14(langue,3,1)
          write (ulbila,12200) saux43, nbpaho
        endif
        if ( nbptho.gt.0 ) then
          saux43(11:24) = mess14(langue,3,2)
          write (ulbila,12200) saux43, nbptho
        endif
        if ( nbpqho.gt.0 ) then
          saux43(11:24) = mess14(langue,3,4)
          write (ulbila,12200) saux43, nbpqho
        endif
        write (ulbila,10200)
c
      endif
c
c====
c 12. la fin
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
