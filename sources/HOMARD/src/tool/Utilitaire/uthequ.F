      subroutine uthequ ( decisi,
     >                    nbquto, nbheto, nbhecf, nbpyto, nbpycf,
     >                    quahex, hethex, filhex,
     >                    fhpyte,
     >                    facpyr,
     >                    volqua,
     >                    ulsort, langue, codret )
c
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
c    UTilitaire - HExaedres - QUadrangles
c    --           --          --
c ______________________________________________________________________
c
c but : etablit le tableau volqua a partir de son reciproque, quahex
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . decisi . e   .   1    . pilotage des voisins des quadrangles :     .
c .        .     .        . 1 : on construit la table.                 .
c .        .     .        . 2 : on construit la table et on controle   .
c .        .     .        . a. qu'il n'y a pas de hexaedre doubles     .
c .        .     .        . b. qu'un quadrangle n'appartient pas a plus.
c .        .     .        .    de 2 hexaedres                          .
c . nbquto . e   .   1    . nombre de quadrangles total                .
c . nbheto . e   .   1    . nombre d'hexaedres total                   .
c . nbhecf . e   .   1    . nombre d'hexaedres decrits par faces       .
c . nbpyto . e   .   1    . nombre de pyramides total                  .
c . nbpycf . e   .   1    . nombre de pyramides decrites par faces     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hethex . e   . nbheto . historique des etats des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbhedc. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . volqua .  s  .nbquto*2. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme dans le controle              .
c .        .     .        . 3 : probleme de hexaedres doubles          .
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
      parameter ( nompro = 'UTHEQU' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer nbquto, nbheto, nbhecf, nbpyto, nbpycf
      integer filhex(nbheto), hethex(nbheto), quahex(nbhecf,6)
      integer fhpyte(2,*)
      integer facpyr(nbpycf,5)
      integer volqua(2,nbquto)
      integer decisi
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer codre1, codre2
      integer etat, bindec, nbfipy
      integer fils
      integer lehexa
      integer lequad, quad(6), quabis(6), quadcl(6), quabcl(6)
#ifdef _DEBUG_HOMARD_
      integer glop
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
      texte(1,4) =
     > '(/,''Le quadrangle'',i10,'' a plus de deux voisins ?'')'
      texte(1,5) = '(''Hexaedres :'',3i10,/)'
      texte(1,6) =
     > '(/,''Les deux hexaedres suivants sont identiques.'')'
      texte(1,7) =
     > '(''Quadrangles du hexaedre numero :'',i10,'' : '',4i10)'
c
      texte(2,4) =
     > '(/,''Quadrangle'',i10,'' has more than 2 neighbours ?'')'
      texte(2,5) = '(''Tetraedra :'',3i10,/)'
      texte(2,6) = '(/,''The following two tetraedra are the same.'')'
      texte(2,7) ='(''Quadrangles of hexahedron #'',i10,'' : '',4i10)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbquto', nbquto
      write(ulsort,90002) 'nbheto', nbheto
      write(ulsort,90002) 'nbhecf', nbhecf
      write(ulsort,90002) 'nbpyto', nbpyto
      write(ulsort,90002) 'nbpycf', nbpycf
#endif
c
c====
c 2. liste des hexaedres s'appuyant sur chaque quadrangle
c    attention : a priori, un quadrangle borde 0, 1 ou 2 hexaedres
c====
c
c 2. ==> on regarde tous les hexaedres decrits par faces
c
      do 20 , lehexa = 1 , nbhecf
c
c 2.1. ==> les quadrangles du hexaedre en cours d'examen
c
        quad(1) = quahex(lehexa,1)
        quad(2) = quahex(lehexa,2)
        quad(3) = quahex(lehexa,3)
        quad(4) = quahex(lehexa,4)
        quad(5) = quahex(lehexa,5)
        quad(6) = quahex(lehexa,6)
#ifdef _DEBUG_HOMARD_
        if ( lehexa.eq.-437 .or. lehexa.le.-438 ) then
             write(ulsort,90015) 'quads de hexa', lehexa,' :', quad
             glop = 1
        else
          glop = 0
        endif
#endif
c
c 2.2. ==> quand un hexaedre est decoupe pour la mise en
c          conformite, certains de ses quadrangles sont des bords de
c          l'hexaedre et de ses fils.
c          La convention HOMARD veut que l'on ne memorise que le fils
c          dans les voisins du quadrangle.
c          on va alors annuler le numero du quadrangle pour ne rien
c          archiver maintenant.
c
        etat = mod(hethex(lehexa),1000)
#ifdef _DEBUG_HOMARD_
        if ( glop.gt.0 ) then
          write(ulsort,90015) 'etat de hexa', lehexa,' :',etat
        endif
#endif
c
        if ( etat.ge.11 ) then
C
          bindec = chbiet(etat)
          nbfipy = chnpy(bindec)
#ifdef _DEBUG_HOMARD_
        if ( glop.gt.0 ) then
          write(ulsort,90002) 'bindec, nbfipy', bindec, nbfipy
          write(ulsort,90015) 'fils de ', lehexa,' :', filhex(lehexa)
        endif
#endif
c
          if ( nbfipy.gt.0 ) then
c
            if ( filhex(lehexa).lt.0 ) then
c
              iaux = -filhex(lehexa)
              fils = fhpyte(1,iaux)
#ifdef _DEBUG_HOMARD_
        if ( glop.gt.0 ) then
       write(ulsort,90002) 'fils, nbpycf', fils, nbpycf
        endif
#endif
c
              if ( fils.le.nbpycf ) then
c
                do 22 , jaux = 1 , nbfipy
                  do 221 , lequad = 1 , 6
                    if ( quad(lequad).eq.facpyr(fils,5) ) then
                      quad(lequad) = 0
                    endif
  221             continue
                  fils = fils + 1
   22           continue
c
              endif
#ifdef _DEBUG_HOMARD_
        if ( glop.gt.0 ) then
           write(ulsort,90015) 'quads de hexa', lehexa,' :', quad
        endif
#endif
c
            endif
c
          endif
c
        endif
c
c 2.3. ==> pour chacun des 6 quadrangles encore a traiter
c
        do 23 , lequad = 1 , 6
c
          if ( quad(lequad).gt.0 ) then
c
c 2.3.1. ==> aucun voisin n'existe : on met l'hexaedre courant
c            comme premier voisin
c
          if ( volqua(1,quad(lequad)).eq.0 ) then
c
            volqua(1,quad(lequad)) = lehexa
c
          else
c
c 2.3.2. ==> il existe un premier voisin
c
c 2.3.2.1. ==> en cas de controle :
c
            if ( decisi.eq.2 ) then
c
c 2.3.2.1.1. ==> on verifie que le second hexaedre n'est pas identique
c                au premier. Pour cela, on trie les tableaux des
c                quadrangles par numero de quadrangles croissant et
c                on compare.
c
              if ( volqua(2,quad(lequad)).eq.0 ) then
c
                if ( volqua(1,quad(lequad)).gt.0 ) then
c
                  quabis(1) = quahex(volqua(1,quad(lequad)),1)
                  quabis(2) = quahex(volqua(1,quad(lequad)),2)
                  quabis(3) = quahex(volqua(1,quad(lequad)),3)
                  quabis(4) = quahex(volqua(1,quad(lequad)),4)
                  quabis(5) = quahex(volqua(1,quad(lequad)),5)
                  quabis(6) = quahex(volqua(1,quad(lequad)),6)
c
                  call uttrii ( quadcl, jaux, kaux,
     >                          6, quad,
     >                          ulsort, langue, codre1 )
c
                  call uttrii ( quabcl, jaux, kaux,
     >                          6, quabis,
     >                          ulsort, langue, codre2 )
c
                  if ( codre1.eq.0 .and. codre2.eq.0 ) then
                    if ( quad(quadcl(1)).eq.quabis(quabcl(1)) .and.
     >                   quad(quadcl(2)).eq.quabis(quabcl(2)) .and.
     >                   quad(quadcl(3)).eq.quabis(quabcl(3)) .and.
     >                   quad(quadcl(4)).eq.quabis(quabcl(4)) .and.
     >                   quad(quadcl(5)).eq.quabis(quabcl(5)) .and.
     >                   quad(quadcl(6)).eq.quabis(quabcl(6)) ) then
                      write(ulsort,texte(langue,6))
                      write(ulsort,texte(langue,7)) lehexa, quad
                      write(ulsort,texte(langue,7))
     >                                    volqua(1,quad(lequad)), quabis
                      codret = 3
                    endif
                  else
                    codret = 1
                  endif
c
                  endif
c
c 2.3.2.1.2. ==> il y a deja un second volume comme voisin de ce
c                quadrangle !
c
              else
c
                write(ulsort,texte(langue,4)) quad(lequad)
                write(ulsort,texte(langue,5)) volqua(1,quad(lequad)),
     >                                        volqua(2,quad(lequad)),
     >                                        lehexa
                codret = 3
c
              endif
c
            endif
c
c 2.3.2.2. ==> il existe un premier voisin : on met l'hexaedre
c              courant comme second voisin
c
            volqua(2,quad(lequad)) = lehexa
c
          endif
c
          endif
c
   23   continue
c
   20 continue
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
