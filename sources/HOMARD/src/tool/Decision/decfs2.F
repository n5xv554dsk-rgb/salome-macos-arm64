      subroutine decfs2 ( disnoe, ancnoe, nounoe,
     >                    hetnoe, famnoe, arenoe,
     >                    noehom, coonoe,
     >                    np2are, somare,
     >                    aretri,
     >                    hetqua, arequa, filqua,
     >                    tritet, cotrte, aretet,
     >                    hethex, filhex, fhpyte,
     >                    facpyr, cofapy, arepyr,
     >                    hetpen, filpen, fppyte,
     >                    typind, iindno, rindno,
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
c traitement des DEcisions - mise en ConFormite - Suppression - 2
c                --                  -  -         -             -
c Renumerotation des tableaux lies aux noeuds
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . disnoe . aux . nancno . indicateurs de disparition des noeuds      .
c . ancnoe .   s . nbnoto . anciens numeros des noeuds conserves       .
c . nounoe .   s .0:nbnoto. nouveaux numeros des noeuds conserves      .
c . hetnoe . e/s  . nbnoto . historique de l'etat des noeuds           .
c . np2are . e   . nancar . numero des noeuds p2 milieux d'aretes      .
c . somare . e   .2*nancar. numeros des extremites d'arete             .
c . aretri . e   .nanctr*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nancqu . historique de l'etat des quadrangles       .
c . arequa . e   .nancqu*3. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nancqu . premier fils des quadrangles               .
c . tritet . e   .nancte*4. numeros des triangles des tetraedres       .
c . cotrte . e   .nancte*4. codes des triangles des tetraedres         .
c . aretet . e   .nancta*6. numeros des 6 aretes des tetraedres        .
c . hethex . e   . nanche . historique de l'etat des hexaedres         .
c . filhex . e   . nanche . premier fils des hexaedres                 .
c . fhpyte . e   .  2**   . fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . facpyr . e   .nancyf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nancyf*5. codes des faces des pyramides              .
c . arepyr . e   .nancya*8. numeros des 8 aretes des pyramides         .
c . hetpen . e   . nancpe . historique de l'etat des pentaedres        .
c . filpen . e   . nancpe . premier fils des pentaedres                .
c . fppyte . e   .  2**   . fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . typind . e   .   1    . type de valeurs pour l'indicateur          .
c .        .     .        . 0 : aucune                                 .
c .        .     .        . 2 : entieres                               .
c .        .     .        . 3 : reelles                                .
c . iindno . e   .   *    . indicateur entier sur les noeuds           .
c . rindno . e   .   *    . indicateur reel sur les noeuds             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'DECFS2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "envca1.h"
#include "nancnb.h"
#include "nombno.h"
#include "nombar.h"
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer disnoe(nancno)
      integer ancnoe(nbnoto), nounoe(0:nancno)
      integer hetnoe(nancno), famnoe(nancno)
      integer arenoe(nancno), noehom(nancno)
      integer np2are(nancar), somare(2,nancar)
      integer aretri(nanctr,3)
      integer hetqua(nancqu), arequa(nancqu,4), filqua(nancqu)
      integer tritet(nanctf,4), cotrte(nanctf,4), aretet(nancta,6)
      integer hethex(nanche), filhex(nanche)
      integer fhpyte(2,*)
      integer facpyr(nancyf,5), cofapy(nancyf,5), arepyr(nancya,8)
      integer hetpen(nancpe), filpen(nancpe)
      integer fppyte(2,*)
      integer typind, iindno(*)
c
      double precision coonoe(nancno,sdim)
      double precision rindno(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer letetr, lapyra, lequad, larete, lenoeu
      integer listar(8), listso(5)
      integer nbnore, nbp2re, nbimre
      integer bindec
c
      integer etat
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
      texte(1,4) = '(''Binaire du decoupage de conformite :'',i5)'
c
      texte(2,4) = '(''Cut for conformity; binary code:'',i5)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. Reperage des noeuds a faire disparaitre
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Reperage ; codret = ', codret
#endif
cgn      write (ulsort,90002) nompro//'nancno', nancno
c
c 2.1. ==> A priori, tout reste
c
      if ( codret.eq.0 ) then
c
      do 21 , iaux = 1 , nancno
        disnoe(iaux) = 0
        ancnoe(iaux) = iaux
   21 continue
c
      endif
c
c 2.2. ==> Les noeuds P2 sur les aretes de conformite
c
      if ( codret.eq.0 ) then
c
      do 22 , iaux = nbarpe+1 , nancar
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'noeud sur l''arete', iaux, ':', np2are(iaux)
#endif
        disnoe(np2are(iaux)) = 1
   22 continue
c
      endif
c
c 2.3. ==> Les noeuds centraux des quadrangles coupes en 3 quadrangles
c          . Le noeud central est le second sommet de la derniere arete
c            du fils aine (voir cmcdq5 pour les conventions)
c
      if ( codret.eq.0 ) then
c
      do 23 , iaux = 1 , nancqu
c
        etat = mod(hetqua(iaux),100)
c
        if ( ( etat.ge.41 .and. etat.le.44 ) ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,4), iaux
          write (ulsort,texte(langue,4)) etat
#endif
          lequad = filqua(iaux)
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,4), lequad
#endif
c
          lenoeu = somare(2,arequa(lequad,4))
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,-1), lenoeu
#endif
          disnoe(lenoeu) = 1
c
        endif
c
   23 continue
c
      endif
c
c 2.4. ==> Les noeuds centraux des hexaedres coupes
c          Selon l'etat, il y a ou non un sommet interne
c          . le noeud central est le sommet S1 de chacun des tetraedres
c          . le noeud central est le sommet S5 de chacune des pyramides
c
      if ( codret.eq.0 ) then
c
      do 24 , iaux = 1 , nanche
c
        etat = mod(hethex(iaux),1000)
c
        if ( etat.gt.10 ) then
c
        bindec = chbiet(etat)
        if ( chnp1(bindec).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,6), iaux
          write (ulsort,texte(langue,4)) bindec
#endif
          jaux = filhex(iaux)
c
c 2.4.1. ==> Au moins un tetraedre fils
c
          if ( chnte(bindec).gt.0 ) then
c
            letetr = fhpyte(2,-jaux)
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,3), letetr
#endif
c
            call utaste ( letetr,
     >                    nanctr, nanctf, nancta,
     >                    somare, aretri,
     >                    tritet, cotrte, aretet,
     >                    listar, listso )
c
            lenoeu = listso(1)
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,-1), lenoeu
#endif
            disnoe(lenoeu) = 1
c
c 2.4.2. ==> Au moins une pyramide fille
c
          elseif ( chnpy(bindec).gt.0 ) then
c
            lapyra = fhpyte(1,-jaux)
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,6), lapyra
#endif
c
            call utaspy ( lapyra,
     >                    nanctr, nancyf, nancya,
     >                    somare, aretri,
     >                    facpyr, cofapy, arepyr,
     >                    listar, listso )
c
            lenoeu = listso(5)
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,-1), lenoeu
#endif
            disnoe(lenoeu) = 1
c
          endif
c
        endif
c
        endif
c
   24 continue
c
      endif
c
c 2.5. ==> Les noeuds centraux des pentaedres coupes selon
c          le mode 3 ou 5
c          . Decoupage selon 2 aretes de triangle : le noeud central est
c            le sommet S1 de chacun des 10 tetraedres
c          . Decoupage selon 1 face de triangle : le noeud central est
c            le sommet S1 du 10eme tetraedre
c
      if ( codret.eq.0 ) then
c
      do 25 , iaux = 1 , nancpe
c
        etat = mod(hetpen(iaux),100)
c
        if ( ( etat.ge.31 .and. etat.le.36 ) .or.
     >       ( etat.ge.51 .and. etat.le.52 ) ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,7), iaux
          write (ulsort,texte(langue,4)) etat
#endif
          jaux = filpen(iaux)
          letetr = fppyte(2,-jaux) + 9
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,3), letetr
#endif
c
          call utaste ( letetr,
     >                  nanctr, nanctf, nancta,
     >                  somare, aretri,
     >                  tritet, cotrte, aretet,
     >                  listar, listso )
c
          lenoeu = listso(1)
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) mess14(langue,2,-1), lenoeu
#endif
          disnoe(lenoeu) = 1
c
        endif
c
   25 continue
c
      endif
c
c====
c 3. Suppression des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Suppression des noeuds ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSUNO', nompro
#endif
      call utsuno ( nancno, nbnoto, disnoe,
     >              hetnoe, ancnoe, nounoe,
     >              nbnore, nbp2re, nbimre )
c
      endif
c
c====
c 4. Compactage de la numerotation
c    Remarque : c'est un melange de utcnno et utcnar
c    sachant qu'ici les aretes ne changent pas de numero
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Compactage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 4.1. ==> Les tableaux du maillage
c
      do 41 , lenoeu = 1 , nbnore
c
        if ( ancnoe(lenoeu).ne.lenoeu ) then
          do 410, iaux = 1 , sdim
            coonoe(lenoeu,iaux) = coonoe(ancnoe(lenoeu),iaux)
  410     continue
          hetnoe(lenoeu) = hetnoe(ancnoe(lenoeu))
          famnoe(lenoeu) = famnoe(ancnoe(lenoeu))
          arenoe(lenoeu) = arenoe(ancnoe(lenoeu))
        endif
c
   41 continue
c
c 4.2. ==> Les eventuels noeuds homologues
c
      if ( homolo.ge.1 ) then
c
        do 42 , lenoeu = 1 , nbnore
          if ( noehom(ancnoe(lenoeu)).ge.0 ) then
            noehom(lenoeu) =   nounoe(noehom(ancnoe(lenoeu)))
          else
            noehom(lenoeu) = - nounoe(abs(noehom(ancnoe(lenoeu))))
          endif
   42   continue
c
      endif
c
c 4.3. ==> La description des aretes
c
      do 43 , larete = 1 , nancar
c
        somare(1,larete) = nounoe(somare(1,larete))
        somare(2,larete) = nounoe(somare(2,larete))
        np2are(larete) = nounoe(np2are(larete))
c
   43 continue
c
c 4.4. ==> Les eventuels indicateurs d'erreur
c
      if ( typind.eq.2 ) then
c
        do 441 , lenoeu = 1 , nbnore
          if ( ancnoe(lenoeu).ne.lenoeu ) then
            iindno(lenoeu) = iindno(ancnoe(lenoeu))
          endif
  441   continue
c
      elseif ( typind.eq.3 ) then
c
        do 442 , lenoeu = 1 , nbnore
          if ( ancnoe(lenoeu).ne.lenoeu ) then
            rindno(lenoeu) = rindno(ancnoe(lenoeu))
          endif
  442   continue
c
      endif
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
