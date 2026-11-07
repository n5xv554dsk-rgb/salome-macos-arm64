      subroutine deini4 ( tyconf,
     >                    decare, decfac,
     >                    hetare, filare,
     >                    aretri, hettri, filtri,
     >                    voltri, pypetr,
     >                    arequa, hetqua,
     >                    volqua,
     >                    tritet, quahex, facpen, facpyr,
     >                    tabaux,
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
c traitement des DEcisions - INitialisation de l'indicateur entier
c                --          --
c ______________________________________________________________________
c
c but : correction des decisions
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tyconf . e   .   1    .  0 : conforme (defaut)                     .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2                    .
c .        .     .        .  2 : non-conforme avec 1 seul noeud        .
c .        .     .        .      pendant par arete                     .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c . decare . es  .0:nbarto. decisions des aretes                       .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . tabaux . a   . -nbquto. tableau auxiliaire sur les faces           .
c .        .     . :nbtrto.  (quad. + tri.)                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . s   .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'DEINI4' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
c
c 0.3. ==> arguments
c
      integer tyconf
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer hetare(nbarto), filare(nbarto)
      integer aretri(nbtrto,3), hettri(nbtrto), filtri(nbtrto)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer arequa(nbquto,4), hetqua(nbquto)
      integer volqua(2,nbquto)
      integer tritet(nbtecf,4)
      integer quahex(nbhecf,6)
      integer facpen(nbpecf,5)
      integer facpyr(nbpycf,5)
      integer tabaux(-nbquto:nbtrto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer lehexa, letetr, lapyra, lepent, letria, lequad, lequa0
      integer etat
      integer nbquad, iquad, liquad(11)
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
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
     > '(5x,''Correction pour le mode conforme - phase'',i2)'
      texte(1,5) = '(5x,''Correction pour le mode non conforme'')'
c
      texte(2,4) = '(5x,''Correction for conformal mode - phase #'',i1)'
      texte(2,5) = '(5x,''Correction for non conformal mode'')'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'entree de ',nompro
      do 1111 , iaux = 1 , nbarto
        if ( iaux.eq.-50 .or. iaux.eq.-51 .or.
     >       iaux.eq.-53 .or. iaux.eq.-57 ) then
          write (ulsort,90001) '.. arete e/d', iaux,
     >    hetare(iaux), decare(iaux)
        endif
cgn        if ( decare(iaux).ne.0 ) then
cgn          write (ulsort,90001) '.. arete e/d', iaux,
cgn     >    hetare(iaux), decare(iaux)
cgn        endif
 1111 continue
#endif
c
c====
c 2. Correction pour le mode conforme - phase 1
c    A. Il est possible que l'on demande une reactivation de
c       triangles ou de quadrangles alors que leurs aretes
c       sont deja decoupees a 2 niveaux.
c       Il faut alors annuler la demande de deraffinement.
c    B. Du fait de filtrages, il est possible qu'une demande de
c       raffinement sur une face soit liee a une restriction sur une
c       arete.
c       Il faut alors imposer le raffinement de l'arete
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. correction conforme 1 ; codret', codret
#endif
c
      if ( ( tyconf.eq.0 ) .or. ( tyconf.eq.-1 ) ) then
c
        write(ulsort,texte(langue,4)) 1
c
c 2.1. ==> Aucune correction de deraffinement au depart
c
        do 21 , iaux = -nbquto, nbtrto
          tabaux(iaux) = 0
   21   continue
c
c 2.2. ==> Corrections pour les triangles
c
cgn        write(ulsort,90002) 'nbtrto', nbtrto
        do 22 , iaux = 1, nbtrto
c
c 2.2.1. ==> Le triangle est a deraffiner
c
          if ( decfac(iaux).eq.-1 ) then
c
c 2.2.1.1. ==> On voudrait reactiver le triangle, mais au moins une
c              de ses aretes est coupee deux fois ==> impossible
c
cgn      write(ulsort,90015) 'Triangle',iaux,', etat',hettri(iaux)
            if ( mod(hetare(aretri(iaux,1)),10).gt.2 .or.
     >           mod(hetare(aretri(iaux,2)),10).gt.2 .or.
     >           mod(hetare(aretri(iaux,3)),10).gt.2 ) then
              tabaux(iaux) = 1
cgn      write(ulsort,90002) 'Annulation reactivation du triangle',iaux
            endif
c
c 2.2.1.2. ==> Prise en compte du voisinage quand le fils central
c              du triangle a une de ses aretes deja coupee : il faut
c              traiter les faces des volumes qui s'appuient sur
c              ce triangle fils
c
cgn      write(ulsort,*) 'filtri(',iaux,') :',filtri(iaux)
cgn      write(ulsort,90002) 'hetare(aretri(filtri(iaux),1))',
cgn     > hetare(aretri(filtri(iaux),1))
cgn      write(ulsort,90002) 'hetare(aretri(filtri(iaux),1))',
cgn     > hetare(aretri(filtri(iaux),1))
cgn      write(ulsort,90002) 'hetare(aretri(filtri(iaux),2))',
cgn     > hetare(aretri(filtri(iaux),2))
cgn      write(ulsort,90002) 'hetare(aretri(filtri(iaux),3))',
cgn     > hetare(aretri(filtri(iaux),3))
            if ( nbteto.gt.0 .or. nbpeto.gt.0 .or. nbpyto.gt.0 ) then
c
            if ( mod(hettri(iaux),10).eq.9 .or.
     >           mod(hetare(aretri(filtri(iaux),1)),10).gt.0 .or.
     >           mod(hetare(aretri(filtri(iaux),2)),10).gt.0 .or.
     >           mod(hetare(aretri(filtri(iaux),3)),10).gt.0 ) then
c
              do 2212 , jaux = 1, 2
c
                letetr = voltri(jaux,iaux)
                if ( letetr.gt.0 ) then
cgn      write(ulsort,90002) 'Tetraedre', letetr
                  do 22121 , kaux = 1, 4
                    letria = tritet(letetr,kaux)
                    tabaux(letria) = 1
22121             continue
                elseif ( letetr.lt.0 ) then
                  lapyra = pypetr(1,-letetr)
                  if ( lapyra.ne.0 ) then
cgn      write(ulsort,90002) 'Pyramide', lapyra
                    do 22122 , kaux = 1, 4
                      letria = facpyr(lapyra,kaux)
                      tabaux(letria) = 1
22122               continue
                    tabaux(-facpyr(lapyra,5)) = 1
                  endif
                  lepent = pypetr(2,-letetr)
                  if ( lepent.ne.0 ) then
cgn      write(ulsort,90002) 'Pentaedre', lepent
                    do 22123 , kaux = 1, 2
                      letria = facpen(lepent,kaux)
                      tabaux(letria) = 1
22123               continue
                    do 22124 , kaux = 3, 5
                      lequad = facpen(lepent,kaux)
                      tabaux(-lequad) = 1
22124               continue
                  endif
                endif
c
 2212         continue
c
            endif
c
            endif
c
c 2.2.2. ==> Le triangle est a raffiner : toutes ses aretes
c            doivent l'etre
c
          elseif ( decfac(iaux).eq.4 ) then
c
            do 222 , jaux = 1, 3
              if ( mod(hetare(aretri(iaux,jaux)),10).eq.0 ) then
                decare(aretri(iaux,jaux)) = 2
              endif
  222       continue
c
          endif
c
   22   continue
c
c 2.3. ==> Corrections pour les quadrangles
c
cgn        write(ulsort,90002) 'nbquto', nbquto
        do 23 , iaux = 1, nbquto
c
c 2.3.1. ==> Le quadrangle est a deraffiner
c
          if ( decfac(-iaux).eq.-1 ) then
c
c 2.3.1.1. ==> On voudrait reactiver le quadrangle, mais au moins une
c              de ses aretes est coupee deux fois ==> impossible
c
            if ( mod(hetare(arequa(iaux,1)),10).gt.2 .or.
     >           mod(hetare(arequa(iaux,2)),10).gt.2 .or.
     >           mod(hetare(arequa(iaux,3)),10).gt.2 .or.
     >           mod(hetare(arequa(iaux,4)),10).gt.2 ) then
              tabaux(-iaux) = 1
cgn      write(ulsort,90002) 'Annulation reactivation du quadrangle',iaux
            endif
c
c 2.3.2. ==> Le quadrangle est a raffiner : toutes ses aretes
c            doivent l'etre
c
          elseif ( decfac(-iaux).eq.4 ) then
c
            do 232 , jaux = 1, 4
              if ( mod(hetare(arequa(iaux,jaux)),10).eq.0 ) then
                decare(arequa(iaux,jaux)) = 2
              endif
 232       continue
c
          endif
c
  23   continue
c
c 2.4. ==> Mise en place des corrections de deraffinement
c
        do 241 , iaux = 1, nbquto
          if ( tabaux(-iaux).gt.0 ) then
cgn      write(ulsort,90002) 'Annulation reactivation du quadrangle',iaux
cgn      write(ulsort,90002) 'decare(arequa(iaux,1))',
cgn     > decare(arequa(iaux,1))
cgn      write(ulsort,90002) 'decare(arequa(iaux,2))',
cgn     > decare(arequa(iaux,2))
cgn      write(ulsort,90002) 'decare(arequa(iaux,3))',
cgn     > decare(arequa(iaux,3))
cgn      write(ulsort,90002) 'decare(arequa(iaux,4))',
cgn     > decare(arequa(iaux,4))
            decfac (-iaux) = 0
            do 2411 , jaux = 1, 4
              decare(arequa(iaux,jaux)) =
     >                             max(0,decare(arequa(iaux,jaux)))
 2411       continue
          endif
  241   continue
c
        do 242 , iaux = 1, nbtrto
          if ( tabaux(iaux).gt.0 ) then
cgn      write(ulsort,90002) 'Annulation reactivation du triangle',iaux
cgn      write(ulsort,90002) 'decare(aretri(iaux,1))',
cgn     > decare(aretri(iaux,1))
cgn      write(ulsort,90002) 'decare(aretri(iaux,2))',
cgn     > decare(aretri(iaux,2))
cgn      write(ulsort,90002) 'decare(aretri(iaux,3))',
cgn     > decare(aretri(iaux,3))
            decfac (iaux) = 0
            do 2421 , jaux = 1, 3
              decare(aretri(iaux,jaux)) =
     >                             max(0,decare(aretri(iaux,jaux)))
 2421       continue
          endif
  242   continue
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'apres 2 de ',nompro
      do 22222 , iaux = 1 , nbarto
        if ( iaux.eq.-50 .or. iaux.eq.-51 .or.
     >       iaux.eq.-53 .or. iaux.eq.-57 ) then
          write (ulsort,90001) '.. arete e/d', iaux,
     >    hetare(iaux), decare(iaux)
        endif
22222 continue
#endif
c
c====
c 3. Correction pour le mode conforme - phase 2
c    Dans le cas particulier de raffinement par des indicateurs
c    aux noeuds ou aux aretes, on peut se trouver ainsi :
c       Mail 1                    Mail 1
c avec dec de conformite        apres suppr
c sur l'arete horizontale     de la conformite
c decare=2 en X
c         o                        o
c       . | .                    .   .
c      .  |  .                  .    .
c     .   |   .                .       .
c    o..X.o....o              o..X.o....o
c     .   |   .                .       .
c      .  |  .                  .     .
c       . | .                    .   .
c         o                        o
c
c Si on ne fait rien, le triangle du haut ne sera jamais coupe car la
c gestion des ecarts de niveau passe par les faces coupees. Il faut
c donc s'en occuper ici. Il faut declarer a couper toutes les faces
c qui contiennent cette arete.
c                    o
c                  .   .
c                 T  T  T
c                .       .
c               o..X.o....o
c                .       .
c                 T  T  T
c                  .   .
c                    o
c
c Le traitement est similaire pour les quadrangles.
c Remarque : cette configuration ne peut pas reapparaitre ensuite
c
c En mode "conforme par boites", tout volume contenant une arete
c coupee deux fois sera decoupe en standard car les deux faces
c qui contiennent l'arete l'auront ete. L'algorithme de contamination
c gere cela.
c En mode conforme pur, le meme raisonnement s'applique aux volumes
c borde par un triangle : tetraedre ou pentaedre. En revanche, pour un
c hexaedre, le decoupage des deux quadrangles partageant l'arete ne
c suffira pas a enclencher le decoupage standard de l'hexaedre. Il faut
c le forcer ici.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. correction conforme 2 ; codret', codret
      write (ulsort,90002) 'tyconf', tyconf
#endif
c
      if ( ( tyconf.eq.0 ) .or. ( tyconf.eq.-1 ) ) then
c
        write(ulsort,texte(langue,4)) 2
c
c 3.1. ==> Triangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1 Triangles ; codret', codret
#endif
c
        do 31 , iaux = 1, nbtrto
c
          if ( decfac(iaux).eq.0 .and.
     >         mod(hettri(iaux),10).eq.0 ) then
cgn        write(ulsort,90002) 'Triangle', iaux
c
            do 311 , jaux = 1, 3
              kaux = aretri(iaux,jaux)
              if ( mod(hetare(kaux),10).ge.2 ) then
                if ( decare(filare(kaux)).ge.2 ) then
cgn        write(ulsort,90002) '. Arete', kaux
                  goto 312
                elseif ( decare(filare(kaux)+1).ge.2 ) then
cgn        write(ulsort,90002) '. Arete', kaux
                  goto 312
                endif
              endif
  311       continue
c
            goto 31
c
  312       continue
c
            do 313 , jaux = 1, 3
              kaux = aretri(iaux,jaux)
              if ( mod(hetare(kaux),10).eq.0 ) then
cgn        write(ulsort,90002) '==> Triangle', iaux
cgn        write(ulsort,90002) '==> Decoupage de l''arete', kaux
                decare(kaux) = 2
              elseif ( mod(hetare(kaux),10).ge.2 ) then
cgn        write(ulsort,90002) '==> Triangle', iaux
cgn        write(ulsort,90002) '==> Decoupage de l''arete', kaux
                decare(kaux) = max(0,decare(kaux))
              endif
  313       continue
cgn        write(ulsort,90002) '.==> Decoupage du triangle', iaux
            decfac(iaux) = 4
c
          endif
c
   31   continue
c
c 3.2. ==> Quadrangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. Quadrangles ; codret', codret
#endif
c
        do 32 , lequad = 1, nbquto
c
cgn        if ( lequad.eq.38 ) then
cgn        write(ulsort,90002) 'Quadrangle',
cgn     >  lequad,decfac(-lequad),hetqua(lequad)
cgn        endif
          if ( decfac(-lequad).eq.0 ) then
cgn            write(ulsort,90002) 'Quadrangle', lequad
c
            do 321 , jaux = 1, 4
              kaux = arequa(lequad,jaux)
              if ( mod(hetare(kaux),10).ge.2 ) then
                if ( decare(filare(kaux)).ge.2 ) then
cgn        write(ulsort,90002) '. Arete', kaux
                  goto 33
                elseif ( decare(filare(kaux)+1).ge.2 ) then
cgn        write(ulsort,90002) '. Arete', kaux
                  goto 33
                endif
              endif
  321       continue
c
            goto 32
c
c 3.2.2. ==> Le quadrangle lequad est a traiter
c            On lui ajoute tous les quadrangles des hexaedres voisins
c
  33        continue
c
            nbquad = 1
            liquad(1) = lequad
cgn        if ( lequad.eq.-417 ) then
cgn            write(ulsort,90002) 'Quadrangle', lequad
cgn        endif
c
            if ( nbheto.gt.0 ) then
c
            do 322 , jaux = 1 , 2
c
              lehexa = volqua(jaux,lequad)
c
              if ( lehexa.gt.0 ) then
c
                do 3221 , kaux = 1 , 6
                  if ( quahex(lehexa,kaux).ne.lequad ) then
                    nbquad = nbquad + 1
                    liquad(nbquad) = quahex(lehexa,kaux)
                  endif
 3221           continue
c
              endif
c
  322       continue
c
            endif
cgn        if ( lequad.eq.-417 ) then
cgn            write(ulsort,90002) 'nbquad', nbquad
cgn        endif
c
c 3.2.3. ==> Traitement des quadrangles enregistres
c
            do 323 , iquad = 1, nbquad
c
              lequa0 = liquad(iquad)
        if ( lequad.eq.-417 ) then
            write(ulsort,90002) '.. lequa0', lequa0,decfac(-lequa0)
        endif
c
              do 3231 , jaux = 1, 4
                kaux = arequa(lequa0,jaux)
cgn        if ( lequad.eq.-417 ) then
cgn      write(ulsort,90002) '.... arete', kaux,hetare(kaux),decare(kaux)
cgn        endif
                if ( mod(hetare(kaux),10).eq.0 ) then
cgn        if ( kaux.eq.50 .or. kaux.eq.51 .or.
cgn     >       kaux.eq.53 .or. kaux.eq.57 ) then
cgn        write(ulsort,90002) '==> Quadrangle', lequa0
cgn        write(ulsort,90002) '==> Decoupage de l''arete', kaux
cgn        endif
                  decare(kaux) = 2
                elseif ( mod(hetare(kaux),10).ge.2 ) then
cgn        write(ulsort,90002) '==> Quadrangle', lequa0
cgn        write(ulsort,90002) '==> Decoupage de l''arete', kaux
                  decare(kaux) = max(0,decare(kaux))
                endif
 3231         continue
c
  323       continue
            if ( mod(hetqua(lequad),100).eq.0 ) then
cgn        write(ulsort,90002) '==> Decoupage du quadrangle', lequad
              decfac(-lequad) = 4
            endif
c
          endif
c
   32   continue
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'apres 3 de ',nompro
      do 33333 , iaux = 1 , nbarto
        if ( iaux.eq.-50 .or. iaux.eq.-51 .or.
     >       iaux.eq.-53 .or. iaux.eq.-57 ) then
          write (ulsort,90001) '.. arete e/d', iaux,
     >    hetare(iaux), decare(iaux)
        endif
33333 continue
#endif
c
c====
c 4. Correction pour le mode non conforme
c    Il est possible que l'on demande du decoupage d'aretes ou de
c    triangles ou de quadrangles alors qu'ils le sont deja.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. correction non conforme ; codret', codret
#endif
c
      if ( ( tyconf.gt.0 ) .or. ( tyconf.eq.-2 ) ) then
c
        write(ulsort,texte(langue,5))
c
        do 41 , iaux = 1, nbtrto
          if ( decfac (iaux).eq.4 ) then
            etat = mod(hettri(iaux),10)
            if ( etat.eq.4 .or.
     >           etat.eq.5 .or. etat.eq.6 .or. etat.eq.7 .or.
     >           etat.eq.9 ) then
              decfac (iaux) = 0
            endif
          endif
   41   continue
c
        do 42 , iaux = 1, nbquto
          if ( decfac (-iaux).eq.4 ) then
            etat = mod(hetqua(iaux),100)
            if ( etat.eq.4 .or. etat.eq.99) then
              decfac (-iaux) = 0
            endif
          endif
   42   continue
c
        do 43 , iaux = 1, nbarto
          if ( decare (iaux).eq.2 ) then
            etat = mod(hetare(iaux),10)
            if (etat.eq.2 .or. etat.eq.9 ) then
              decare (iaux) = 0
            endif
          endif
   43   continue
c
      endif
c
cgn        do 444 , iaux = -nbquto, nbtrto
cgn          if ( decfac(iaux).eq.-1 ) then
cgn        write(ulsort,90002) '.Reactivation de la face', iaux
cgn        endif
cgn  444   continue
c
c====
c 5. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'sortie de ',nompro
      do  5555 , iaux = 1 , nbarto
        if ( iaux.eq.-50 .or. iaux.eq.-51 .or.
     >       iaux.eq.-53 .or. iaux.eq.-57 ) then
          write (ulsort,90001) '.. arete e/d', iaux,
     >    hetare(iaux), decare(iaux)
        endif
 5555 continue
#endif
c
cgn      iaux = 8384
cgn      write (ulsort,90015) 'decision triangle', iaux, ' :', decfac(iaux)
cgn      write (ulsort,90015) 'decision arete', aretri(iaux,1), ' :',
cgn     >                      decare(aretri(iaux,1))
cgn      write (ulsort,90015) 'decision arete', aretri(iaux,2), ' :',
cgn     >                      decare(aretri(iaux,2))
cgn      write (ulsort,90015) 'decision arete', aretri(iaux,3), ' :',
cgn     >                      decare(aretri(iaux,3))
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
