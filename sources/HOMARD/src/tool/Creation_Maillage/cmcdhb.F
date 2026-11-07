      subroutine cmcdhb ( indnoe, indare, indtri, indtet, indpyr,
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
     >                    quahex, coquhe, hethex,
     >                    filhex, fhpyte,
     >                    famhex, cfahex,
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
c    Creation du Maillage - Conformite - Decoupage des Hexaedres
c    -           -          -            -             -
c                         - selon des Boites
c                                     -
c ______________________________________________________________________
c
c but : decoupage des hexaedres pour mise en conformite
c       remarque : description des fils par leurs faces
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
c . cotrte . e   .nouvtf*4. code des 4 triangles des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . pthepe . es  .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . hetpyr . e   . nouvpy . historique de l'etat des pyramides         .
c . facpyr . e   .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nouvyf*5. codes des faces des pyramides              .
c . filpyr . e   . nouvpy . premier fils des pyramides                 .
c . perpyr . e   . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . e   . nouvpy . famille des pyramides                      .
c . pphepe . es  .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . quahex . e   .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nouvhf*6. codes des 6 quadrangles des hexaedres      .
c . hethex . e   . nouvhe . historique de l'etat des hexaedres         .
c . filhex . e   . nouvhe . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . famhex . e   . nouvhe . famille des hexaedres                      .
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
      parameter ( nompro = 'CMCDHB' )
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
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer hethex(nouvhe)
      integer filhex(nouvhe), fhpyte(2,nbheco)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
c
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer fj
      integer nbfad3, nbfad4
      integer etatfa(6)
      integer lehexa
      integer nbfihe, etahex
#ifdef _DEBUG_HOMARD_
      integer listar(12)
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
      texte(1,7) ='(''hexaedre numero'',i10,'' sont incoherentes.'')'
      texte(1,8) ='(''Arete'',i2,'' :'',i10,'' et historique :'',i10)'
      texte(1,10) ='(i10,'' problemes ...'')'
c
      texte(2,4) ='(''Temporary splitting by '',a)'
      texte(2,5) ='(''Decisions for the edges of the'')'
      texte(2,6) ='(''Decisions for the faces of the'')'
      texte(2,7) ='(''hexahedron #'',i10,S''do not match.'')'
      texte(2,8) ='(''Edge #'',i2,'' :'',i10,'' state :'',i10)'
      texte(2,10) ='(i10,'' problems ...'')'
c
#include "impr03.h"
#include "impr04.h"
c
      codret = 0
c
      nbfihe = 0
c
c====
c 2. decoupage
c====
c
cgn      write(ulsort,90002) 'permhe',permhe
      do 200 , iaux = 1 , permhe
c
        if ( codret.eq.0 ) then
c
cgn          write(ulsort,*) 'hexa', iaux,' avec l''etat =',hethex(iaux)
c
        if ( mod(hethex(iaux),1000).eq.0 ) then
c
c 2.1. ==> Recherche des etats des faces de l'hexaedre
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARHE', nompro
      call utarhe ( iaux,
     >              nouvqu, nouvhe,
     >              arequa, quahex, coquhe,
     >              listar )
      do 2121 , jaux = 1 , 12
      write (ulsort,91002) jaux,listar(jaux), somare(1,listar(jaux)),
     >          somare(2,listar(jaux)),hetare(listar(jaux))
 2121 continue
#endif
c
          etahex = 0
          lehexa = iaux
c
          nbfad3 = 0
          nbfad4 = 0
          do 21 , jaux = 1 , 6
            fj = quahex(lehexa,jaux)
            etatfa(jaux) = mod(hetqua(fj),100)
cgn            write(ulsort,*) '. Etat de la ', jaux, '-ieme face :',
cgn     >                      etatfa(jaux), ' (face ', fj, ')'
            if ( etatfa(jaux).ge.31 .and. etatfa(jaux).le.34 ) then
              nbfad3 = nbfad3 + 1
            elseif ( etatfa(jaux).eq.4 ) then
              nbfad4 = nbfad4 + 1
            endif
   21     continue
cgn          write(ulsort,*) nbfad3, nbfad4
c
c 2.2. ==> Decoupage de conformite
c 2.2.1. ==> decoupage en 18 a partir de 3 aretes
c            ------------------------------------
c
          if ( nbfad3.eq.6 .and. nbfad4.eq.0 ) then
c
            nbfihe = nbfihe + 1
            fhpyte(1,nbfihe) = 0
            fhpyte(2,nbfihe) = indtet + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHA3', nompro
#endif
c
            call cmcha3 ( lehexa, etahex,
     >                    indnoe, indare, indtri, indtet,
     >                    nbfihe,
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
     >                    quahex, coquhe,
     >                    famhex, cfahex,
     >                    ulsort, langue, codret )
c
c 2.2.2. ==> decoupage en 14 a partir de 2 aretes
c            ------------------------------------
c
          elseif ( nbfad3.eq.4 .and. nbfad4.eq.0 ) then
c
            nbfihe = nbfihe + 1
            fhpyte(1,nbfihe) = indpyr + 1
            fhpyte(2,nbfihe) = indtet + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHA2', nompro
#endif
c
            call cmcha2 ( lehexa, etahex,
     >                    indnoe, indare, indtri, indtet, indpyr,
     >                    nbfihe,
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
     >                    quahex, coquhe,
     >                    famhex, cfahex,
     >                    ulsort, langue, codret )
c
c 2.2.3. ==> decoupage en 4 a partir d'1 arete
c            ---------------------------------
c
          elseif ( nbfad3.eq.2 ) then
c
            nbfihe = nbfihe + 1
            fhpyte(1,nbfihe) = indpyr + 1
            fhpyte(2,nbfihe) = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHA1', nompro
#endif
c
            call cmcha1 ( lehexa, etahex,
     >                    indare, indtri, indpyr,
     >                    nbfihe,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
     >                    quahex, coquhe,
     >                    famhex, cfahex,
     >                    ulsort, langue, codret )
c
c 2.2.4. ==> decoupage a partir d'une face
c            -----------------------------
c
          elseif ( nbfad3.eq.4 .and. nbfad4.eq.1 ) then
c
            nbfihe = nbfihe + 1
            fhpyte(1,nbfihe) = indpyr + 1
            fhpyte(2,nbfihe) = indtet + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHF0', nompro
#endif
c
            call cmchf0 ( lehexa, etahex, etatfa,
     >                    indare, indtri, indtet, indpyr,
     >                    nbfihe,
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
     >                    quahex, coquhe,
     >                    famhex, cfahex,
     >                    ulsort, langue, codret )
c
          endif
c
c 2.3. ==> Mise a jour de l'historique
c
cgn          print *, 'etahex = ', etahex
          if ( codret.eq.0 ) then
c
          hethex(lehexa) = hethex(lehexa) + etahex
c
          endif
c
c 2.4. ==> Mise a jour de la parente
c
          if ( etahex.ne.0 ) then
c
            if ( codret.eq.0 ) then
c
            filhex(lehexa) = -nbfihe
            pphepe(nbfihe) = lehexa
            pthepe(nbfihe) = lehexa
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
cgn      write(ulsort,90002) 'pertet',(pertet(iaux),iaux=1,min(10,nbteto))
cgn      write(ulsort,90002) 'perpyr',(perpyr(iaux),iaux=1,min(10,nbpyto))
cgn      write(ulsort,90002) 'hethex',(hethex(iaux),iaux=1,min(10,permhe))
cgn      write(ulsort,90002) 'filhex',(filhex(iaux),iaux=1,min(10,permhe))
cgn      write(ulsort,90002) 'fhpyte',fhpyte(1,1),fhpyte(2,1)
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
