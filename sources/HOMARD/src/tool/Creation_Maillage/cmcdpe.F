      subroutine cmcdpe ( indnoe, indare, indtri, indtet, indpyr,
     >                    coonoe, hetnoe, arenoe,
     >                    famnoe,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    hetqua, arequa,
     >                    filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    pthepe,
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
     >                    pphepe,
     >                    facpen, cofape, hetpen,
     >                    filpen, fppyte,
     >                    fampen, cfapen,
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
c    Creation du Maillage - Conformite - Decoupage des PEntaedres
c    -           -          -            -             --
c ______________________________________________________________________
c
c but : decoupage des pentaedres pour mise en conformite
c       remarque : on est forcement en 3d
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . famnoe . es  . nouvno . famille des noeuds                         .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare .     . nouvar . famille des aretes                         .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . hetqua . e   . nouvqu . historique de l'etat des quadrangles       .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . es  .nouvtf*4. code des 4 triangles des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . pthepe . es  .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . hetpyr . es  . nouvpy . historique de l'etat des pyramides         .
c . facpyr . es  .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . es  .nouvyf*5. codes des faces des pyramides              .
c . filpyr . es  . nouvpy . premier fils des pyramides                 .
c . perpyr . es  . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . es  . nouvpy . famille des pyramides                      .
c . pphepe . es  .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . facpen . e   .nouvpf*5. numeros des faces des pentaedres           .
c . cofape . e   .nouvpf*5. codes des faces des pentaedres             .
c . hetpen . e   . nouvpe . historique de l'etat des pentaedres        .
c . filpen . e   . nouvpe . premier fils des pentaedres                .
c . fppyte . e   .  2**   . fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . fampen . e   . nouvpe . famille des penaedres                      .
c . cfapen . e   . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'CMCDPE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nouvnb.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer indnoe, indare, indtri, indtet, indpyr
      integer hetnoe(nouvno), arenoe(nouvno)
      integer famnoe(nouvno)
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer hetqua(nouvqu), arequa(nouvqu,4)
      integer filqua(nouvqu)
      integer hettet(nouvte), tritet(nouvtf,4), cotrte(nouvtf,4)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer pthepe(*)
      integer hetpyr(nouvpy), facpyr(nouvyf,5), cofapy(nouvyf,5)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
      integer pphepe(*)
      integer facpen(nouvpf,5), cofape(nouvpf,5)
      integer hetpen(nouvpe)
      integer filpen(nouvpe), fppyte(2,*)
      integer fampen(nouvpe), cfapen(nctfpe,nbfpen)
c
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer fj
      integer nbfad2, nbfad3, nbfat4, nbfaq4
      integer etatfa(5)
      integer lepent
      integer nbfipe, etapen
      integer indptp
#ifdef _DEBUG_HOMARD_
      integer listar(9)
#endif
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
      texte(1,4) ='(''Decoupage provisoire en '',a)'
      texte(1,5) ='(''Les decisions de decoupage des aretes du'')'
      texte(1,6) ='(''Les decisions de decoupage des faces du'')'
      texte(1,7) ='(''pentaedre numero'',i10,'' sont incoherentes.'')'
      texte(1,8) ='(''Arete'',i2,'' :'',i10,'' et historique :'',i10)'
      texte(1,10) ='(i10,'' problemes ...'')'
c
      texte(2,4) ='(''Temporary splitting by '',a)'
      texte(2,5) ='(''Decisions for the edges of the'')'
      texte(2,6) ='(''Decisions for the faces of the'')'
      texte(2,7) ='(''pentahedron #'',i10,S''do not match.'')'
      texte(2,8) ='(''Edge #'',i2,'' :'',i10,'' state :'',i10)'
      texte(2,10) ='(i10,'' problems ...'')'
c
#include "impr03.h"
#include "impr04.h"
c
      codret = 0
c
      nbfipe = 0
c
c====
c 2. decoupage
c====
c
      do 200 , iaux = 1 , permpe
c
        if ( codret.eq.0 ) then
c
cgn        write(ulsort,90015) 'penta', iaux,' avec l''etat ',hetpen(iaux)
c
        if ( mod(hetpen(iaux),100).eq.0 ) then
c
c 2.1. ==> Recherche des etats des faces du pentaedre
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARPE', nompro
      call utarpe ( iaux,
     >              nouvqu, nouvpe,
     >              arequa, facpen, cofape,
     >              listar )
      do 2121 , jaux = 1 , 9
      write (ulsort,91002) jaux,listar(jaux), somare(1,listar(jaux)),
     >          somare(2,listar(jaux)),hetare(listar(jaux))
 2121 continue
#endif
c
          etapen = 0
          lepent = iaux
cgn        write(ulsort,90015) 'penta', lepent,' avec les faces',
cgn     >        (facpen(lepent,jaux),jaux=1,5)
c
          nbfad2 = 0
          nbfad3 = 0
          nbfat4 = 0
          nbfaq4 = 0
          do 211 , jaux = 1 , 2
            fj = facpen(lepent,jaux)
            etatfa(jaux) = mod(hettri(fj),10)
cgn            write(ulsort,*) '. Etat de la ', jaux, '-ieme face :',
cgn     >                      etatfa(jaux), ' (face ', fj, ')'
            if ( etatfa(jaux).ge.1 .and. etatfa(jaux).le.3 ) then
              nbfad2 = nbfad2 + 1
            elseif ( etatfa(jaux).eq.4 ) then
              nbfat4 = nbfat4 + 1
            endif
  211     continue
          do 212 , jaux = 3 , 5
            fj = facpen(lepent,jaux)
            etatfa(jaux) = mod(hetqua(fj),100)
cgn            write(ulsort,*) '. Etat de la ', jaux, '-ieme face :',
cgn     >                      etatfa(jaux), ' (face ', fj, ')'
            if ( etatfa(jaux).ge.31 .and. etatfa(jaux).le.34 ) then
              nbfad3 = nbfad3 + 1
            elseif ( etatfa(jaux).eq.4 ) then
              nbfaq4 = nbfaq4 + 1
            endif
  212     continue
cgn          write(ulsort,90002) 'nbfad2', nbfad2
cgn          write(ulsort,90002) 'nbfad3', nbfad3
cgn          write(ulsort,90002) 'nbfat4', nbfat4
cgn          write(ulsort,90002) 'nbfaq4', nbfaq4
c
c 2.2. ==> Decoupage de conformite
c 2.2.1. ==> decoupage a partir d'1 arete de triangle
c            ----------------------------------------
c
          if ( nbfad2.eq.1 .and. nbfad3.eq.1 .and.
     >         nbfaq4.eq.0 .and. nbfat4.eq.0 ) then
c
            nbfipe = nbfipe + 1
            indptp = nbheco + nbfipe
            fppyte(1,nbfipe) = indpyr + 1
            fppyte(2,nbfipe) = indtet + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP0A', nompro
#endif
            call cmcp0a ( lepent, etapen,
     >                    indare, indtri, indtet, indpyr,
     >                    indptp,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
     >                    facpen, cofape,
     >                    fampen, cfapen,
     >                    ulsort, langue, codret )
c
c 2.2.2 ==> decoupage a partir d'1 arete de quadrangle
c           ------------------------------------------
c
          elseif ( nbfad2.eq.0 .and. nbfad3.eq.2 .and.
     >             nbfaq4.eq.0 .and. nbfat4.eq.0 ) then
c
            nbfipe = nbfipe + 1
            indptp = nbheco + nbfipe
            fppyte(1,nbfipe) = indpyr + 1
            fppyte(2,nbfipe) = indtet + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP1A', nompro
#endif
            call cmcp1a ( lepent, etapen,
     >                    indtri, indtet, indpyr,
     >                    indptp,
     >                    hetare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
     >                    facpen, cofape,
     >                    fampen, cfapen,
     >                    ulsort, langue, codret )
c
c 2.2.3 ==> decoupage a partir de 1 arete de tria et
c                                 1 arete de quad
c            -----------------------------------------
c
          elseif ( nbfad2.eq.1 .and. nbfad3.eq.3 .and.
     >             nbfaq4.eq.0 .and. nbfat4.eq.0 ) then
c
            nbfipe = nbfipe + 1
            indptp = nbheco + nbfipe
            fppyte(1,nbfipe) = 0
            fppyte(2,nbfipe) = indtet + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP2A', nompro
#endif
           call cmcp2a ( lepent, etapen,
     >                    indare, indtri, indtet,
     >                    indptp,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    facpen, cofape,
     >                    fampen, cfapen,
     >                    ulsort, langue, codret )
c
c 2.2.4 ==> decoupage a partir de 2 aretes de tria
c            -------------------------------------
c
          elseif ( nbfad2.eq.2 .and. nbfad3.eq.2 .and.
     >             nbfaq4.eq.0 .and. nbfat4.eq.0 ) then
c
            nbfipe = nbfipe + 1
            indptp = nbheco + nbfipe
            fppyte(1,nbfipe) = indpyr + 1
            fppyte(2,nbfipe) = indtet + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP3A', nompro
#endif
            call cmcp3a ( lepent, etapen,
     >                    indnoe, indare, indtri, indtet, indpyr,
     >                    indptp,
     >                    coonoe, hetnoe, arenoe,
     >                    famnoe,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
     >                    facpen, cofape,
     >                    fampen, cfapen,
     >                    ulsort, langue, codret )
c
c 2.2.5 ==> decoupage a partir de 1 face quad
c            --------------------------------
c
          elseif ( nbfad2.eq.2 .and. nbfad3.eq.2 .and.
     >             nbfaq4.eq.1 .and. nbfat4.eq.0 ) then
c
            nbfipe = nbfipe + 1
            indptp = nbheco + nbfipe
            fppyte(1,nbfipe) = indpyr + 1
            fppyte(2,nbfipe) = indtet + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP4A', nompro
#endif
            call cmcp4a ( lepent, etapen,
     >                    indare, indtri, indtet, indpyr,
     >                    indptp,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
     >                    facpen, cofape,
     >                    fampen, cfapen,
     >                    ulsort, langue, codret )
c
c 2.2.6 ==> decoupage a partir de 1 face tria
c            --------------------------------
c
          elseif ( nbfad2.eq.0 .and. nbfad3.eq.3 .and.
     >             nbfaq4.eq.0 .and. nbfat4.eq.1 ) then
c
            nbfipe = nbfipe + 1
            indptp = nbheco + nbfipe
            fppyte(1,nbfipe) = 0
            fppyte(2,nbfipe) = indtet + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP5A', nompro
#endif
            call cmcp5a ( lepent, etapen,
     >                    indnoe, indare, indtri, indtet,
     >                    indptp,
     >                    coonoe, hetnoe, arenoe,
     >                    famnoe,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    facpen, cofape,
     >                    fampen, cfapen,
     >                    ulsort, langue, codret )
c
          endif
c
c 2.3. ==> Mise a jour de l'historique
c
cgn          print *, 'etapen = ', etapen
          if ( codret.eq.0 ) then
c
          hetpen(lepent) = hetpen(lepent) + etapen
c
          endif
c
c 2.4. ==> Mise a jour de la parente
c
          if ( etapen.ne.0 ) then
c
            if ( codret.eq.0 ) then
c
            filpen(lepent) = -nbfipe
            pphepe(indptp) = lepent
            pthepe(indptp) = lepent
c
            endif
c
          endif
c
        endif
c
        endif
c
  200 continue
cgn      do 3 , iaux = 1 , nouvtr
cgn      print 167,iaux,aretri(iaux,1),aretri(iaux,2),aretri(iaux,3)
cgn  3   continue
c
c====
c 3. la fin
c====
cgn      write(ulsort,90002) 'famtet',(famtet(iaux),iaux= 1,10)
cgn      write(ulsort,90002) 'famtet',(famtet(iaux),iaux=11,20)
cgn      write(ulsort,90002) 'famtet',(famtet(iaux),iaux=21,29)
cgn      write(ulsort,90002) 'fampyr',(fampyr(iaux),iaux= 1,10)
cgn      write(ulsort,90002) 'fampyr',(fampyr(iaux),iaux=11,17)
cgn      write(ulsort,90002) 'pertet',(pertet(iaux),iaux=1,min(10,nbteto))
cgn      write(ulsort,90002) 'perpyr',(perpyr(iaux),iaux=1,min(10,nbpyto))
cgn      write(ulsort,90002) 'hetpen',(hetpen(iaux),iaux=1,min(10,permpe))
cgn      write(ulsort,90002) 'filpen',(filpen(iaux),iaux=1,min(10,permpe))
cgn      write(ulsort,90002) 'fppyte',fppyte(1,1),fppyte(2,1)
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,10)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
