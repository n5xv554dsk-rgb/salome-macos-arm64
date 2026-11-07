      subroutine mmag12 ( muarmx, nbarmu, multax,
     >                    munomx, nbnomu, multnx,
     >                    nbduno, nbduar,
     >                    tbau30, tbau40,
     >                    tbaux5,
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
c    Modification de Maillage - AGregat - phase 1.2
c    -               -          --              - -
c    Connaissant le nombre et les caracteristiques des duplications
c    a effectuer pour les joints simples :
c    . Pour chaque duplication de noeuds :
c      - ordre de multiplicite de la duplication
c    . Pour chaque duplication d'aretes :
c      - ordre de multiplicite de la duplication
c    . Pour chaque duplication d'aretes :
c      - liste des joints simples pour lesquels l'arete initiale
c        est dupliquee
c    . Ordre de multiplicite maximal des aretes
c    . Nombre d'aretes pour chacun des ordres possibles
c    . Ordre de multiplicite maximal des noeuds
c    . Nombre d'aretes pour chacun des ordres possibles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . muarmx . e   .   1    . ordre de multiplicite des aretes maximal   .
c .        .     .        . possible                                   .
c . nbarmu .  s  . muarmx . nombre d'aretes par ordre de multiplicite  .
c . multax .  s  .   1    . ordre de multiplicite des aretes maximal   .
c . munomx . e   .   1    . ordre de multiplicite des noeuds maximal   .
c .        .     .        . possible                                   .
c . nbnomu .  s  . munomx . nombre de noeuds par ordre de multiplicite .
c . multnx .  s  .   1    . ordre de multiplicite des noeuds maximal   .
c . nbduno . e   .   1    . nombre de duplication de noeuds            .
c . nbduar . e   .   1    . nombre de duplications d'aretes            .
c . tbau30 . es  .8*nbduno. Pour la i-eme duplication de noeud :       .
c .        .     .        . (1,i) : noeud a dupliquer                  .
c .        .     .        . (2,i) : arete construite sur le noeud      .
c .        .     .        . (3,i) : noeud cree cote min(fammed)        .
c .        .     .        . (4,i) : noeud cree cote max(fammed)        .
c .        .     .        . (5,i) : numero du joint simple cree        .
c .        .     .        . (6,i) : arete entrant dans le cote 1       .
c .        .     .        . (7,i) : arete entrant dans le cote 2       .
c .        .     .        . (8,i) : ordre de multiplicite              .
c . tbau40 . es  .6*nbduar. Pour la i-eme duplication d'arete :        .
c .        .     .        . (1,i) : arete a dupliquer                  .
c .        .     .        . (2,i) : arete creee cote min(fammed)       .
c .        .     .        . (3,i) : arete creee cote max(fammed)       .
c .        .     .        . (4,i) : numero du joint simple cree        .
c .        .     .        . (5,i) : ordre de multiplicite              .
c .        .     .        . (6,i) : arete d'orientation de joint       .
c . tbaux5 . --- .   4**  . Pour la i-eme duplication d'arete :        .
c .        .     .        . (1,i), (2,i), (3,i), (4,i)                 .
c .        .     .        . numeros ordonnes des joints simples crees  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . -30 : muarmx est trop petit                .
c .        .     .        . -50 : munomx est trop petit                .
c .        .     .        . >0 : problemes de multipicites imprevues   .
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
      parameter ( nompro = 'MMAG12' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
cc
      integer muarmx, multax
      integer nbarmu(muarmx)
      integer munomx, multnx
      integer nbnomu(munomx)
c
      integer nbduno, nbduar
      integer tbau30(8,nbduno), tbau40(6,nbduar)
      integer tbaux5(4,nbduar)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer larete
      integer lenoeu
      integer multip
      integer nujois(4)
#ifdef _DEBUG_HOMARD_
      integer pbmult
#endif
c
      integer nbmess
      parameter ( nbmess = 40 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. prealables
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "mmag01.h"
c
      texte(1,31) = '(5x,''*   Ordre de   * Nombre de      *'')'
      texte(1,32) = '(5x,''* multiplicite * '',a,       '' *'')'
      texte(1,33) = '(''Multiplicite '',a,'' :'',i8)'
      texte(1,34) = '(''Gestion impossible au dela de'',i3)'
      texte(1,35) =
     >'(a,'': impossible de traiter une multiplicite d''''ordre'',i4,/)'
      texte(1,36) =
     >'(a,'': multiplicite d''''ordre'',i4,'' impossible.''/)'
      texte(1,37) =
     >'(i4,'' cas de multiplicite impossibles a resoudre.''/)'
c
      texte(2,31) = '(5x,''*   Order of   * Number of       *'')'
      texte(2,32) = '(5x,''* multiplicity * '',a,       '' *'')'
      texte(2,33) = '(''Order '',a,'' :'',i8)'
      texte(2,34) = '(''Impossible above'',i3)'
      texte(2,35) =
     >'(a,'': a'',i4,''-order multiplicity cannot be solved.''/)'
      texte(2,36) =
     >'(a,'': a'',i4,''-order multiplicity cannot exist.''/)'
      texte(2,37) =
     >'(i4,'' cases of multiplicity cannot be solved.''/)'
c
#include "impr03.h"
 1000 format(5x,33('*'))
 1001 format(5x,'*      ',i3,'   *       ',i6,'     *')
 1002 format(5x,33('*'),/)
 1003 format(/,5x,33('*'))
c
c 1.2. ==> Constantes
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      pbmult = 0
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), nbduno
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbduar
#endif
c
cgn      write(ulsort,90002) 'tbaux2',4,nbjois
cgn      do 1101 , kaux = 1,nbjois
cgn       write(ulsort,91010) (tbaux2(jaux,kaux),jaux=1,4)
cgn 1101 continue
cgn      write(ulsort,90002) 'tbau30',8,nbduno
cgn      do 1102 , kaux = 1,nbduno
cgn       write(ulsort,91010) (tbau30(jaux,kaux),jaux=1,8)
cgn 1102 continue
cgn      write(ulsort,90002) 'tbau40',6,nbduar
cgn      do 1103 , kaux = 1,nbduar
cgn       write(ulsort,91010) (tbau40(jaux,kaux),jaux=1,6)
cgn 1103 continue
cgn      write(ulsort,90002) 'tbau41',4,5
cgn      do 1104 , kaux = 1,5
cgn       write(ulsort,91010) (tbau41(jaux,kaux),jaux=1,4)
cgn 1104 continue
c
c====
c 2. Recherche de l'ordre de multiplicite des aretes a dupliquer
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Parcours des aretes ; codret = ', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,1)
#endif
c
c 2.1. ==> Initialisation sans joint simple au voisinage des
c          aretes dupliquees
c
      if ( codret.eq.0 ) then
c
      do 21 , iaux = 1 , nbduar
c
        tbaux5(1,iaux) = 0
        tbaux5(2,iaux) = 0
        tbaux5(3,iaux) = 0
        tbaux5(4,iaux) = 0
c
   21 continue
c
      endif
c
c 2.2. ==> Recherche de l'ordre de multiplicite des aretes a dupliquer
c          On memorise le ou les joints simples associes.
c
      multax = 0
c
      if ( codret.eq.0 ) then
c
      do 22 , iaux = 1 , nbduar
c
        larete = tbau40(1,iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
#endif
cgn          if ( larete.eq.2387 ) then
cgn      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
cgn      write(ulsort,91010) (tbau40(kaux,iaux),kaux=1,6)
cgn      endif
c
        multip = 0
c
        do 221 , jaux = 1 , nbduar
c
c         on tombe sur la meme arete (au moins quand jaux = iaux !)
c
          if ( larete.eq.tbau40(1,jaux) ) then
c
            multip = multip + 1
c           a la 1ere coincidence d'arete dupliquee, on garde le joint
            if ( multip.eq.1 ) then
              tbaux5(1,iaux) = tbau40(4,jaux)
c
c           a la 2eme coincidence d'arete dupliquee, on prend le min
c           et le max entre le joint deja vu et le joint courant
            elseif ( multip.eq.2 ) then
              nujois(1) = min(tbaux5(1,iaux),tbau40(4,jaux))
              nujois(2) = max(tbaux5(1,iaux),tbau40(4,jaux))
              tbaux5(1,iaux) = nujois(1)
              tbaux5(2,iaux) = nujois(2)
c
c           a la 3eme ou 4eme coincidence d'arete dupliquee, on
c           positionne le joint courant a sa place vis-a-vis des joints
c           deja enregistres
            elseif ( multip.eq.3 .or.multip.eq.4 ) then
cgn      write (ulsort,2222) tbau40(1,iaux),(tbaux5(kaux,iaux),kaux=1,2)
              do 2211 , kaux = 1 , multip-1
cgn      write (ulsort,2222) tbau40(4,jaux),tbaux5(kaux,iaux)
                if ( tbau40(4,jaux).lt.tbaux5(kaux,iaux) ) then
                  nujois(kaux) = tbau40(4,jaux)
                  do 2213 , laux = kaux , multip-1
                    nujois(laux+1) = tbaux5(laux,iaux)
 2213             continue
                  goto 2212
                else
                  nujois(kaux) = tbaux5(kaux,iaux)
                endif
 2211         continue
              nujois(multip) = tbau40(4,jaux)
 2212         continue
cgn      write (ulsort,2222)
cgn     >   tbau40(1,iaux),nujois(1),nujois(2),nujois(3)
              tbaux5(1,iaux) = nujois(1)
              tbaux5(2,iaux) = nujois(2)
              tbaux5(3,iaux) = nujois(3)
              if ( multip.eq.4 ) then
                tbaux5(4,iaux) = nujois(4)
              endif
cgn      write (ulsort,2222)
cgn     >   tbau40(1,iaux),(tbaux5(kaux,iaux),kaux=1,multip)
c
            endif
c
          endif
c
  221   continue
c
        tbau40(5,iaux) = multip
        multax = max(multax,multip)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,33)) ' ', multip
      write (ulsort,texte(langue,20)) (tbaux5(kaux,iaux),kaux=1,4)
#endif
cgn      write(ulsort,90001)
cgn     >  'tbau40 de',iaux,(tbau40(kaux,iaux),kaux=1,6)
c
   22 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,33)) 'max', multax
#endif
c
      endif
c
c====
c 3. Decompte des aretes multiples
c    Remarque : les doubles apparaissent quand deux joints simples se
c               rencontrent au bord du domaine. Il n'y a donc rien
c               de special a faire.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Decompte ar. multiples ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> Verification informatique
c
      if ( multax.gt.muarmx ) then
        write (ulsort,texte(langue,5)) mess14(langue,3,1)
        write (ulsort,texte(langue,33)) 'max', multax
        write (ulsort,texte(langue,34)) muarmx
        codret = -30
      endif
c
      endif
c
c 3.2. ==> Decompte
c
      if ( codret.eq.0 ) then
c
      do 321 , iaux = 1 , muarmx
        nbarmu(iaux) = 0
  321 continue
cgn                  write(ulsort,90002) 'quadruple'
c
      do 322 , iaux = 1 , nbduar
        nbarmu(tbau40(5,iaux)) = nbarmu(tbau40(5,iaux)) + 1
cgn        if ( tbau40(5,iaux).eq.2 ) then
cgn      print 91010, (tbau40(jaux,iaux),jaux=1,6)
cgn        endif
  322 continue
c
      do 323 , iaux = 2 , multax
        nbarmu(iaux) = nbarmu(iaux)/iaux
  323 continue
c
c 3.3. ==> Affichage
c
      write (ulsort,1003)
      write (ulsort,texte(langue,31))
      write (ulsort,texte(langue,32)) mess14(langue,3,1)
      write (ulsort,1000)
      do 33 , iaux = 1 , multax
        write (ulsort,1001) iaux, nbarmu(iaux)
   33 continue
      write (ulsort,1002)
c
c 3.4. ==> Controle
c
#ifdef _DEBUG_HOMARD_
      do 34 , iaux = 5 , multax
c
        if ( nbarmu(iaux).gt.0 ) then
          pbmult = pbmult + 1
          write (ulsort,texte(langue,35)) mess14(langue,4,1), iaux
        endif
c
   34 continue
#endif
c
      endif
c
c====
c 4. Recherche de l'ordre de multiplicite des noeuds a dupliquer
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Parcours des noeuds ; codret = ', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,-1)
#endif
c
c 4.1. ==> Recherche de l'ordre de multiplicite des noeuds a dupliquer
c
      multnx = 0
c
      if ( codret.eq.0 ) then
c
      do 4 , iaux = 1 , nbduno
c
        lenoeu = tbau30(1,iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,-1), lenoeu
#endif
c
        multip = 0
        do 41 , jaux = 1 , nbduno
          if ( lenoeu.eq.tbau30(1,jaux) ) then
            multip = multip + 1
          endif
   41   continue
        tbau30(8,iaux) = multip
        multnx = max(multnx,multip)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,33)) ' ', multip
#endif
c
    4 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,33)) 'max', multnx
#endif
c
      endif
c
c====
c 5. Decompte des noeuds multiples
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Decompte no. multiples ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 5.1. ==> Verification informatique
c
      if ( multnx.gt.munomx ) then
        write (ulsort,texte(langue,5)) mess14(langue,3,-1)
        write (ulsort,texte(langue,33)) 'max', multnx
        write (ulsort,texte(langue,34)) munomx
        codret = -50
      endif
c
      endif
c
c 5.2. ==> Decompte
c
      if ( codret.eq.0 ) then
c
      do 521 , iaux = 1 , munomx
        nbnomu(iaux) = 0
  521 continue
c
      do 522 , iaux = 1 , nbduno
        nbnomu(tbau30(8,iaux)) = nbnomu(tbau30(8,iaux)) + 1
  522 continue
c
      do 523 , iaux = 2 , multnx
        nbnomu(iaux) = nbnomu(iaux)/iaux
  523 continue
c
c 5.3. ==> Affichage
c
      write (ulsort,1000)
      write (ulsort,texte(langue,31))
      write (ulsort,texte(langue,32)) mess14(langue,3,-1)
      write (ulsort,1000)
      do 53 , iaux = 1 , multnx
        write (ulsort,1001) iaux, nbnomu(iaux)
   53 continue
      write (ulsort,1002)
c
c 5.4. ==> Controle
c
#ifdef _DEBUG_HOMARD_
      do 54 , iaux = 1 , multnx
c
        if ( nbnomu(iaux).gt.0 ) then
          if ( iaux.eq.2 .or.
     >         iaux.eq.5 ) then
            pbmult = pbmult + 1
            write (ulsort,texte(langue,36)) mess14(langue,4,-1), iaux
          elseif ( iaux.eq.7 .or.
     >             iaux.eq.8 .or.
     >             iaux.eq.10 .or.
     >             iaux.eq.11 ) then
            pbmult = pbmult + 1
            write (ulsort,texte(langue,35)) mess14(langue,4,-1), iaux
          endif
        endif
c
   54 continue
#endif
c
      endif
c
c====
c 6. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      if ( pbmult.ne.0 ) then
        write (ulsort,texte(langue,37)) pbmult
      endif
#endif
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
