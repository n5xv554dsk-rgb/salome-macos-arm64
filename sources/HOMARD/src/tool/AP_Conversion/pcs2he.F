      subroutine pcs2he ( nbfop2, profho, vap2ho,
     >                    hethex, quahex, coquhe, arehex,
     >                    filhex, fhpyte,
     >                    somare, np2are,
     >                    aretri,
     >                    hetqua, arequa, filqua,
     >                    tritet, cotrte, aretet,
     >                    facpyr, cofapy, arepyr,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c    interpolation p2 sur les noeuds - decoupage des HExaedres
c                  -                                 --
c remarque : on devrait optimiser cela car si l'hexaedre etait dans
c            un etat de decoupage similaire, on recalcule une valeur
c            qui est deja presente
c remarque : pcs2he et pcsihe sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop2 . e   .    1   . nombre de fonctions P2                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vap2ho . es  . nbfop2*. variables p1 numerotation homard           .
c .        .     . nbnoto .                                            .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
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
      parameter ( nompro = 'PCS2HE' )
c
#include "nblang.h"
c
#include "fractc.h"
#include "fract0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
c
#include "hexcf0.h"
#include "hexcf3.h"
#include "ope002.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(*)
      integer hethex(nbheto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer filhex(nbheto)
      integer fhpyte(2,nbheco)
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      double precision vap2ho(nbfop2,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lehexa
      integer bindec, typdec, etanp1
      integer sm, nuv
      integer nbarcp, tbarcp(12), areint(20)
c
      integer listar(12), listso(8), listno(12)
c
      logical afaire
c
      double precision daux
c
      integer nbmess
      parameter ( nbmess = 100 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
#include "impr01.h"
#include "impr03.h"
c
      do 10 , lehexa = 1, nbheto
c
c====
c 1. recherche des caracteristiques des interpolations a faire
c====
c
        iaux = lehexa
#ifdef _DEBUG_HOMARD_
      if ( lehexa.eq.-158) then
      write (ulsort,90002) 'hexaedre', lehexa
      endif
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS0HE', nompro
#endif
        call pcs0he ( iaux, profho,
     >                hethex, quahex, coquhe, arehex,
     >                filhex, fhpyte,
     >                somare, np2are,
     >                aretri,
     >                arequa,
     >                tritet, cotrte, aretet,
     >                facpyr, cofapy, arepyr,
     >                afaire, listar, listso, listno,
     >                bindec, typdec, etanp1,
     >                nbarcp, tbarcp, areint, sm )
#ifdef _DEBUG_HOMARD_
      if ( lehexa.eq.-158) then
      write (ulsort,99001) 'afaire', afaire
      write (ulsort,90002) 'typdec', typdec
      write (ulsort,90002) 'listar 1- 6', (listar(iaux),iaux=1,6)
      write (ulsort,90002) 'listar 7-12', (listar(iaux),iaux=7,12)
      endif
#endif
c
        if ( afaire ) then
c
#include "hexcf4.h"
c
c====
c 2. L'eventuel noeud central
c====
c
        if ( ( mod(typdec,2).eq.0 ) .or.
     >       ( mod(typdec,17).eq.0 ) ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'noeud central', sm
#endif
c
          profho(sm) = 1
c
c         formule p2 :
c         interpolation = -1/4(u1+...+u8) +1/4(u9+...+u12)
c
          do 22 , nuv = 1, nbfop2
c
            daux = 0.d0
            do 221 , iaux = 1 , 8
              daux = daux - vap2ho(nuv,listso(iaux))
  221       continue
            do 222 , iaux = 1 , 12
              daux = daux + vap2ho(nuv,np2are(listar(iaux)))
  222       continue
            vap2ho(nuv,sm) = unsqu * daux
cgn        write(*,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
c
   22     continue
c
        endif
c
c====
c 3. Du noeud central au milieu des faces
c====
c
        if ( mod(typdec,3).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2H1', nompro
#endif
          call pcs2h1 ( nbfop2, profho, vap2ho,
     >                  somare, np2are,
     >                  hetqua, arequa, filqua,
     >                  quahex,
     >                  lehexa, listso, listno,
     >                  chnar(bindec), areint,
     >                  ulsort, langue, codret )
c
        endif
c
c====
c 4. Du noeud central aux milieux d'aretes
c====
c
        if ( mod(typdec,5).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2H2', nompro
#endif
          call pcs2h2 ( nbfop2, profho, vap2ho,
     >                  somare, np2are,
     >                  listso, listno,
     >                  tbarcp, chnar(bindec), areint,
     >                  ulsort, langue, codret )
c
        endif
c
c====
c 5. Du noeud central aux sommets
c====
c
        if ( mod(typdec,7).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2H3', nompro
#endif
          call pcs2h3 ( nbfop2, profho, vap2ho,
     >                  somare, np2are,
     >                  listso, listno,
     >                  chnar(bindec), areint,
     >                  ulsort, langue, codret )
c
        endif
c
c====
c 6. D'un milieu d'arete a un sommet (selon 1 arete)
c====
c
        if ( mod(typdec,11).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2H4', nompro
      write (ulsort,90002) 'chperm(bindec)', chperm(bindec)
#endif
          call pcs2h4 ( nbfop2, profho, vap2ho,
     >                  somare, np2are,
     >                  hepers(1,chperm(bindec)),
     >                  hepera(1,chperm(bindec)),
     >                  areint,
     >                  ulsort, langue, codret )
c
        endif
c
c====
c 7. D'un milieu de face a un sommet (par face)
c====
c
        if ( mod(typdec,13).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2H5', nompro
#endif
          call pcs2h5 ( nbfop2, profho, vap2ho,
     >                  somare, np2are,
     >                  hetqua,
     >                  quahex,
     >                  lehexa, listso, listno,
     >                  areint,
     >                  ulsort, langue, codret )
          if (codret.ne.0) then
      write (ulsort,90002) 'hexaedre', lehexa
      write (ulsort,90002) 'typdec', typdec
      write(ulsort,90002) 'listar 1- 6', (listar(iaux),iaux=1,6)
      write(ulsort,90002) 'listar 7-12', (listar(iaux),iaux=7,12)
      write (ulsort,90015)'profho(2037) =',profho(2037)
      endif
c
        endif
c
        endif
c
   10 continue
c
c====
c 8. La fin
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
