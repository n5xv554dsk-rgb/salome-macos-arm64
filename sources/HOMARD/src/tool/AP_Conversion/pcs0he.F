      subroutine pcs0he ( lehexa, profho,
     >                    hethex, quahex, coquhe, arehex,
     >                    filhex, fhpyte,
     >                    somare, np2are,
     >                    aretri,
     >                    arequa,
     >                    tritet, cotrte, aretet,
     >                    facpyr, cofapy, arepyr,
     >                    afaire, listar, listso, listno,
     >                    bindec, typdec, etanp1,
     >                    nbarcp, tbarcp, areint, noeumi )
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
c    interpolation p2 sur les noeuds - phase 0
c                                            -
c    decoupage des HExaedres
c                  --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .    1   . hexaedre a examiner                        .
c . profho . e   .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . afaire .  s  .    1   . vrai si l'interpolation est a faire        .
c . listar .  s  .   12   . liste des aretes de l'hexaedre             .
c . listso .  s  .    8   . liste des sommets de l'hexaedre            .
c . listno .  s  .   12   . liste des noeuds de l'hexaedre             .
c . bindec .  s  .    1   . code binaire du decoupage                  .
c . typdec .  s  .    1   . type de decoupage                          .
c . etanp1 .  s  . 1      . etat de l'hexaedre a l'iteration N+1       .
c . noeumi .  s  . 1      . numero du noeud milieu                     .
c . nbarcp .  s  .  1     . nombre d'aretes coupees                    .
c . tbarcp .  s  .  12    . 1/0 pour chaque arete coupee ou non        .
c . areint .  s  .   *    . numeros globaux des aretes internes        .
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
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer lehexa
      integer profho(nbnoto)
      integer hethex(nbheto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer filhex(nbheto)
      integer fhpyte(2,nbheco)
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer listar(12), listso(8), listno(12)
      integer bindec, typdec, etanp1
      integer nbarcp, tbarcp(12), areint(*)
      integer noeumi
c
      logical afaire
c
c 0.4. ==> variables locales
c
      integer iaux
c
c     etan   = ETAt de l'hexaedre a l'iteration N
c
      integer etan
c ______________________________________________________________________
c
#include "impr03.h"
c
c====
c 1. les seuls cas interessants sont ceux ou un noeud est cree a
c    l'interieur de l'hexaedre, donc quand il y a une arete interne
c====
c
      etanp1 = mod(hethex(lehexa),1000)
      etan   = (hethex(lehexa)-etanp1) / 1000
      bindec = chbiet(etanp1)
c
c     type de decoupage
c
      typdec = chtn2i(bindec)
#ifdef _DEBUG_HOMARD_
      write(*,90001) 'etats de l''hexa', lehexa,etan,etanp1
      write(*,90002) 'bindec', bindec
      write(*,90002) 'nb sommet', chnp1(bindec)
      write(*,90015) 'typdec', chtn2i(bindec), ' ==> ', typdec
#endif
c
c    . cas du decoupage en 8 :
c      on elimine le cas de l'hexaedre qui etait coupe en 8 et
c      qui le reste : rien ne change
c
      if ( ( etanp1.eq.8 ) .and. ( etanp1.eq.etan ) ) then
        typdec = 1
      endif
c
c====
c 2. Caracteristiques de l'hexaedre
c====
c
      if ( typdec.gt.1 ) then
c
c 2.1. ==> reperage des 6 aretes de l'hexaedre
c
        call utarhe ( lehexa,
     >                nbquto, nbhecf,
     >                arequa, quahex, coquhe,
     >                listar )
cgn        write(*,90002) 'listar 1- 6', (listar(iaux),iaux=1,6)
cgn        write(*,90002) 'listar 7-12', (listar(iaux),iaux=7,12)
c
c 2.2. ==> recuperation des 8 noeuds sommets
c
        call utsohe ( somare, listar, listso )
cgn        write(*,90002) 'listso sommets', (listso(iaux),iaux=1,8)
c
c 2.3. ==> recuperation des 12 noeuds
c
        do 23 , iaux = 1 , 12
          listno(iaux) = np2are(listar(iaux))
  23    continue
cgn        write(*,90002) 'listno 1- 6', (listno(iaux),iaux=1,6)
cgn        write(*,90002) 'listno 7-12', (listno(iaux),iaux=7,12)
c
      endif
c
c====
c 3. on verifie que le champ est present sur tous les noeuds
c    de l'hexaedre
c====
c
      if ( typdec.gt.1 ) then
c
        afaire = .true.
        do 311  , iaux = 1 , 8
cgn      write (*,90015)'profho(',listso(iaux),') =',profho(listso(iaux))
          if ( profho(listso(iaux)).eq.0 ) then
            afaire = .false.
            goto 32
          endif
  311   continue
        do 312  , iaux = 1 , 12
cgn      write (*,90015)'profho(',listno(iaux),') =',profho(listno(iaux))
          if ( profho(listno(iaux)).eq.0 ) then
            afaire = .false.
            goto 32
          endif
  312   continue
c
   32   continue
c
      else
c
        afaire = .false.
c
      endif
cgn      write (*,99001) 'afaire', afaire
c
c====
c 4. Recuperation des numeros locaux des aretes coupees
c====
c
      if ( afaire ) then
c
      call utbide ( bindec, nbarcp, tbarcp )
c
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'nb d''aretes coupees', nbarcp
      write (*,91010) (tbarcp(iaux),iaux=1,nbarcp)
#endif
c
      endif
c
c====
c 5. Recuperation des numeros globaux des aretes internes
c====
c
      if ( afaire ) then
c
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Appel de UTHCAI par PCS0HE'
#endif
      call uthcai ( lehexa, bindec,
     >              aretri,
     >              arequa,
     >              quahex, coquhe, arehex,
     >              filhex, fhpyte,
     >              tritet, cotrte, aretet,
     >              facpyr, cofapy, arepyr,
     >              areint )
c
#ifdef _DEBUG_HOMARD_
      write (*,*) 'aretes internes',
     >                (areint(iaux),iaux=1,chnar(bindec))
#endif
c
      endif
c
c====
c 6. Recuperation du noeud milieu
c====
c
      if ( afaire ) then
c
c 6.1. ==> Cas ou un noeud est cree au centre de l'hexaedre
c
        if ( mod(typdec,2).eq.0 ) then
c
          iaux = lehexa
          call utnmhe ( iaux, noeumi,
     >                  somare, aretri, arequa,
     >                  tritet, cotrte, aretet,
     >                  quahex, coquhe, filhex, fhpyte,
     >                  facpyr, cofapy, arepyr )
c
c 6.2. ==> Cas ou un noeud est cree sur l'arete qui joint les milieux
c          de deux faces opposees
c
        elseif ( mod(typdec,17).eq.0 ) then
c
cgn      write (*,90002) 'Arete interne', areint(1)
          noeumi = np2are(areint(1))
c
        endif
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'noeud central', noeumi
#endif
c
      endif
cgn        write(*,*) 'on sort de pcs0he'
c
      end
