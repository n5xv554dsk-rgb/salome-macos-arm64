      subroutine derco5 ( tyconf, niveau,
     >                    decare, decfac,
     >                    hetare, filare, arehom,
     >                    hettri, aretri, filtri, nivtri, homtri,
     >                    voltri, pypetr,
     >                    hetqua, arequa, filqua, nivqua, quahom,
     >                    volqua, pypequ,
     >                    tritet,
     >                    quahex, coquhe,
     >                    facpyr, cofapy,
     >                    facpen, cofape,
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
c traitement des DEcisions - Raffinement : COntamination - option 2
c                --          -             --                     -
c Application de la regle des ecarts de niveau, tout type de raffinement
c en presence d'aretes et/ou de faces homologues
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
c . niveau . e   .    1   . niveau en cours d'examen                   .
c . decare . es  . nbarto . decisions des aretes                       .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . arehom . e   . nbarto . ensemble des aretes homologues             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   . nbtrto . numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . homtri . e   . nbtrto . ensemble des triangles homologues          .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   . nbquto . numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . quahom . e   . nbquto . ensemble des quadrangles homologues        .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      parameter ( nompro = 'DERCO5' )
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
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer tyconf
      integer niveau
      integer decare(0:nbarto)
      integer decfac(-nbquto:nbtrto)
      integer hetare(nbarto), filare(nbarto)
      integer arehom(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3), filtri(nbtrto)
      integer nivtri(nbtrto), homtri(nbtrto)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
      integer nivqua(nbquto), quahom(nbquto)
      integer volqua(2,nbquto), pypequ(2,*)
      integer tritet(nbtecf,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5)
      integer facpen(nbpecf,5), cofape(nbpecf,5)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer iarelo
      integer laface, lafac2
      integer larete
      integer etat
      integer nbaret, listar(12), nbface, listfa(12)
cgn      integer nbareh, listah(4)
      integer nbvolu, listvo(2), typevo(2)
      integer nbvotr, nbvoqu, nbvoto
c
      integer afaire
c
      integer nbmess
      parameter ( nbmess = 30 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'tyconf', tyconf
#endif
c
#include "derco1.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) niveau
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'entree de ',nompro
      do 1105 , iaux = 1 , -nbquto
        write (ulsort,90001) 'decision quadrangle', iaux,decfac(-iaux)
cgn        write (ulsort,90001) 'quadrangle', iaux,
cgn     >  arequa(iaux,1), arequa(iaux,2),
cgn     >  arequa(iaux,3), arequa(iaux,4)
 1105 continue
      if ( nbquto.gt.0 ) then
        iaux = min(nbquto,12)
        write (ulsort,90001) 'quadrangle', iaux,
     >  arequa(iaux,1), arequa(iaux,2),
     >  arequa(iaux,3), arequa(iaux,4)
        write (ulsort,90001) 'quadrangle', iaux,
     >  decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >  decare(arequa(iaux,3)), decare(arequa(iaux,4)), decfac(-iaux)
        iaux = min(nbquto,10)
        write (ulsort,90001) 'quadrangle', iaux,
     >  arequa(iaux,1), arequa(iaux,2),
     >  arequa(iaux,3), arequa(iaux,4)
        write (ulsort,90001) 'quadrangle', iaux,
     >  decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >  decare(arequa(iaux,3)), decare(arequa(iaux,4)), decfac(-iaux)
        iaux = min(nbquto,19)
        write (ulsort,90001) 'quadrangle', iaux,
     >  arequa(iaux,1), arequa(iaux,2),
     >  arequa(iaux,3), arequa(iaux,4)
        write (ulsort,90001) 'quadrangle', iaux,
     >  decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >  decare(arequa(iaux,3)), decare(arequa(iaux,4)), decfac(-iaux)
      endif
#endif
c
      codret = 0
c
      nbvoto = nbteto + nbpyto + nbheto + nbpeto
c
c  nombre maximum de volumes par triangle ou quadrangle
c
      if ( nbteto.eq.0 .and. nbpyto.eq.0 .and. nbpeto.eq.0 ) then
        nbvotr = 0
      else
        nbvotr = 2
      endif
c
      if ( nbheto.eq.0 .and. nbpyto.eq.0 .and. nbpeto.eq.0 ) then
        nbvoqu = 0
      else
        nbvoqu = 2
      endif
c
c====
c 2. Application de la regle des ecarts de niveau aux faces
c====
c
      do 2 , laface = -nbquto , nbtrto
cgn      print *,'debut boucle 2 : decfac(',laface,') :',decfac(laface)
c
c 2.1. ==> On s'interesse aux faces du niveau courant :
c             . actives a garder
c          ou . inactives a garder et bord de volume
c          ou . inactives a reactiver
c
        if ( laface.gt.0 ) then
c
          if ( nivtri(laface).eq.niveau ) then
            etat = mod( hettri(laface) , 10 )
cgn            write (ulsort,texte(langue,29))'Triangle', laface,
cgn     >      nivtri(laface), hettri(laface), decfac(laface)
          else
            goto 2
          endif
c
        elseif ( laface.lt.0 ) then
c
          iaux = -laface
          if ( nivqua(iaux).eq.niveau ) then
            etat = mod( hetqua(iaux) , 100 )
cgn            write (ulsort,texte(langue,29))'Quadrangle', -laface,
cgn     >      nivqua(-laface), hetqua(-laface), decfac(laface)
          else
            goto 2
          endif
c
        else
c
          goto 2
c
        endif
c
        afaire = 0
        if ( etat.eq.0  ) then
          if ( decfac(laface).eq.0 ) then
            afaire = 1
          endif
        elseif ( etat.eq.4 .or.
     >           etat.eq.6 .or. etat.eq.7 .or. etat.eq.8  ) then
          if ( decfac(laface).eq.0 .and. nbvoto.gt.0 ) then
            afaire = 3
          elseif ( decfac(laface).eq.-1 ) then
            if ( nbvoto.eq.0 ) then
              afaire = 2
            else
              afaire = 4
            endif
          endif
        endif
cgn        write (ulsort,*) 'Face', laface, ', afaire = ', afaire
c
c 2.2. ==> Liste des aretes de la face
c
        if ( afaire.gt.0 ) then
c
          if ( laface.gt.0 ) then
            nbaret = 3
            do 221 , iarelo = 1 , nbaret
              listar(iarelo) = aretri(laface,iarelo)
  221       continue
          else
            nbaret = 4
            iaux = -laface
            do 222 , iarelo = 1 , nbaret
              listar(iarelo) = arequa(iaux,iarelo)
 222        continue
          endif
c
#ifdef _DEBUG_HOMARD_
        else
          write (ulsort,texte(langue,15))
#endif
        endif
c
c 2.3. ==> Cas du raffinement a propager par voisinage
c
        if ( afaire.eq.1 ) then
c
c 2.3.1. ==> Decompte des aretes coupees en 2 avec une fille a couper :
c            . celles d'etat > 0
c            . et avec une fille de decision > 0
c            S'il n'y en a pas, rien n'est a faire
c
          kaux = 0
          do 231, iaux = 1 , nbaret
            larete = listar(iaux)
cgn      print *,'.... arete possible', larete
            if ( mod(hetare(larete),10).gt.0 ) then
              jaux = filare(larete)
              if ( decare(jaux).gt.0 .or. decare(jaux+1).gt.0 ) then
                kaux = kaux + 1
              endif
            endif
  231     continue
c
c 2.3.2. ==> Propagation du raffinement sur la face et ses
c            aretes actives
c
          if ( kaux.gt.0 ) then
c
cgn            nbareh = 0
c
            decfac(laface) = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', laface,decfac(laface),' '
#endif
            do 232 , iaux = 1 , nbaret
              larete = listar(iaux)
              if ( decare(larete).eq.0 ) then
                if ( mod(hetare(larete),10).eq.0 ) then
                  decare(larete) = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',larete,decare(larete),' '
#endif
cgn                  if ( arehom(larete).ne.0 ) then
cgn                    nbareh = nbareh + 1
cgn                    listah(nbareh) = abs( arehom(larete) )
cgn                  endif
                endif
              endif
  232       continue
cgn        write (ulsort,1000) nbareh,' aretes :',
cgn     >      (listah(iaux),iaux=1,nbareh)
cgn 1000 format(i2,a,12i5)
c
          endif
c
        endif
c
c 2.4. ==> Cas du deraffinement a inhiber par voisinage
c
        if ( afaire.eq.2 .or. afaire.eq.4 ) then
c
c 2.4.1. ==> Decompte des aretes coupees en 2 avec une fille coupee
c            qui ne reapparait pas
c            S'il n'y en a pas, rien n'est a faire
c
          kaux = 0
          do 241, iaux = 1 , nbaret
            larete = listar(iaux)
cgn            write (ulsort,*) larete, decare(larete)
            jaux = filare(larete)
            if ( decare(jaux).gt.0 .or. decare(jaux+1).gt.0 ) then
              kaux = kaux + 1
            endif
  241     continue
c
c 2.4.2. ==> Inhibition du raffinement sur la face et ses aretes
c
          if ( kaux.gt.0 ) then
c
cgn            nbareh = 0
c
            decfac(laface) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', laface,decfac(laface),' '
#endif
            do 242 , iaux = 1 , nbaret
              larete = listar(iaux)
              if ( decare(larete).eq.-1 ) then
                decare(larete) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',larete,decare(larete),' '
#endif
cgn                if ( arehom(larete).ne.0 ) then
cgn                  nbareh = nbareh + 1
cgn                  listah(nbareh) = abs( arehom(larete) )
cgn                endif
              endif
  242       continue
cgn        write (ulsort,1000) nbareh,' aretes :',
cgn     >      (listah(iaux),iaux=1,nbareh)
c
          endif
c
        endif
c
c 2.5. ==> Cas du raffinement a propager ou du deraffinement a inhiber
c          par l'interieur de volumes
c
        if ( afaire.ge.3 ) then
c
c 2.5.1. ==> Pour chaque face, on regarde si une arete tracee sur
c            la face va etre coupee.
c            . Pour un triangle, ces aretes sont celles qui definissent
c              la fille face centrale (cf. cmrdtr)
c            . Pour un quadrangle, ces aretes sont la 2eme et le 3eme
c              du premier et du troisieme fils (cf. cmrdqu)
c            S'il n'y en a pas, rien n'est a faire
c
          kaux = 0
c
          if ( laface.gt.0 ) then
            jaux = filtri(laface)
            nbaret = 3
            do 2511 , iarelo = 1 , nbaret
              listar(iarelo) = aretri(jaux,iarelo)
 2511       continue
          else
            jaux = filqua(-laface)
            nbaret = 4
            listar(1) = arequa(jaux  ,2)
            listar(2) = arequa(jaux  ,3)
            listar(3) = arequa(jaux+2,2)
            listar(4) = arequa(jaux+2,3)
          endif
c
          do 2513 , iarelo = 1 , nbaret
cgn       write (ulsort,*) 'hetare, decare(',listar(iarelo),') =',
cgn     >hetare(listar(iarelo)), decare(listar(iarelo))
            if ( decare(listar(iarelo)).gt.0 ) then
              kaux = kaux + 1
            endif
 2513     continue
cgn         write (ulsort,*)'      kaux', kaux
c
c 2.5.2. ==> La face retenue borde-t-elle un volume ?
c
          nbvolu = 0
c
          if ( kaux.gt.0 ) then
c
            if ( laface.gt.0 ) then
c
              do 2521, iaux = 1 , nbvotr
                jaux = voltri(iaux,laface)
                if ( jaux.gt.0 ) then
                  nbvolu = nbvolu + 1
                  listvo(nbvolu) = jaux
                  typevo(nbvolu) = 3
                elseif ( jaux.lt.0 ) then
                  if ( pypetr(1,-jaux).ne.0 ) then
                    nbvolu = nbvolu + 1
                    listvo(nbvolu) = pypetr(1,-jaux)
                    typevo(nbvolu) = 5
                  endif
                  if ( pypetr(2,-jaux).ne.0 ) then
                    nbvolu = nbvolu + 1
                    listvo(nbvolu) = pypetr(2,-jaux)
                    typevo(nbvolu) = 7
                  endif
                endif
 2521         continue
c
            else
c
              do 2522, iaux = 1 , nbvoqu
                jaux = volqua(iaux,-laface)
                if ( jaux.gt.0 ) then
                  nbvolu = nbvolu + 1
                  listvo(nbvolu) = jaux
                  typevo(nbvolu) = 6
                elseif ( jaux.lt.0 ) then
                  if ( pypequ(1,-jaux).ne.0 ) then
                    nbvolu = nbvolu + 1
                    listvo(nbvolu) = pypequ(1,-jaux)
                    typevo(nbvolu) = 5
                  endif
                  if ( pypequ(2,-jaux).ne.0 ) then
                    nbvolu = nbvolu + 1
                    listvo(nbvolu) = pypequ(2,-jaux)
                    typevo(nbvolu) = 7
                  endif
                endif
 2522         continue
c
            endif
cgn       write (ulsort,*)nbvolu,'volumes', (listvo(iaux),iaux=1,nbvolu)
cgn       write (ulsort,*)nbvolu,'types  ', (typevo(iaux),iaux=1,nbvolu)
c
          endif
c
c 2.5.3. ==> Une des aretes tracees sur laface sera coupee. Il faut que
c            le ou les volumes s'appuyant sur laface soient coupes
c
          if ( nbvolu.gt.0 ) then
c
c 2.5.3. ==> Recherche des faces concernees
c
            nbface = 0
            do 2531 , iaux = 1 , nbvolu
              jaux = listvo(iaux)
cgn       write (ulsort,*)'Volume', jaux,' de type',typevo(iaux)
              if ( typevo(iaux).eq.3 ) then
                do 25311 , kaux = 1 , 4
                  nbface = nbface + 1
                  listfa(nbface) = tritet(jaux,kaux)
25311           continue
              elseif ( typevo(iaux).eq.5 ) then
                listfa(1) =  facpyr(jaux,1)
                listfa(2) =  facpyr(jaux,2)
                listfa(3) =  facpyr(jaux,3)
                listfa(4) =  facpyr(jaux,4)
                listfa(5) = -facpyr(jaux,5)
                nbface = 5
              elseif ( typevo(iaux).eq.6 ) then
                do 25313 , kaux = 1 , 6
                  nbface = nbface + 1
                  listfa(nbface) = -quahex(jaux,kaux)
25313           continue
              elseif ( typevo(iaux).eq.7 ) then
                listfa(1) =  facpen(jaux,1)
                listfa(2) =  facpen(jaux,2)
                listfa(3) = -facpen(jaux,3)
                listfa(4) = -facpen(jaux,4)
                listfa(5) = -facpen(jaux,5)
                nbface = 5
              endif
 2531       continue
cgn        write (ulsort,1000)nbface,' faces :',
cgn     >      (listfa(iaux),iaux=1,nbface)
cgn 1000 format(i2,a,12i5)
c
            do 2532 , iaux = 1 , nbface
c
              lafac2 = listfa(iaux)
cgn              if ( lafac2.gt.0 ) then
cgn            write (ulsort,texte(langue,29))'Triangle', lafac2,
cgn     >      nivtri(lafac2), hettri(lafac2), decfac(lafac2)
cgn              else
cgn            write (ulsort,texte(langue,29))'Quadrangle', -lafac2,
cgn     >      nivqua(-lafac2), hetqua(-lafac2), decfac(lafac2)
cgn              endif
              if ( decfac(lafac2).eq.-1 ) then
                decfac(lafac2) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', lafac2,decfac(lafac2),' '
#endif
              elseif ( decfac(lafac2).eq.0 ) then
                if ( lafac2.gt.0 ) then
                  if ( mod(hettri(lafac2),10).eq.0 ) then
                    decfac(lafac2) = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', lafac2,decfac(lafac2),' '
#endif
                  endif
                else
                  if ( mod(hetqua(-lafac2),100).eq.0 ) then
                    decfac(lafac2) = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', lafac2,decfac(lafac2),' '
#endif
                  endif
                endif
              endif
c
              if ( lafac2.gt.0 ) then
                nbaret = 3
                do 2533 , iarelo = 1 , nbaret
                  listar(iarelo) = aretri(lafac2,iarelo)
 2533           continue
              else
                nbaret = 4
                do 2534 , iarelo = 1 , nbaret
                  listar(iarelo) = arequa(-lafac2,iarelo)
 2534           continue
              endif
c
              do 2535 , jaux = 1 , nbaret
                larete = listar(jaux)
                if ( decare(larete).eq.0 ) then
                  if ( mod(hetare(larete),10).eq.0 ) then
                    decare(larete) = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',larete,decare(larete),' '
#endif
                    if ( arehom(larete).ne.0 ) then
                      decare(abs(arehom(larete))) = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',
     >            abs(arehom(larete)),decare(abs(arehom(larete))),' '
#endif
                    endif
                  endif
                elseif ( decare(larete).eq.-1 ) then
                  decare(larete) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',larete,decare(larete),' '
#endif
                  if ( arehom(larete).ne.0 ) then
                    decare(abs(arehom(larete))) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',
     >            abs(arehom(larete)),decare(abs(arehom(larete))),' '
#endif
                  endif
                endif
 2535         continue
c
 2532       continue
c
          endif
c
        endif
c
    2 continue
c
c====
c 3. Transfert via les volumes ayant des quadrangles comme faces
c    Si une fille de l'une de ses aretes est a couper, le volume
c    doit l'etre entierement : on le declare par ses aretes.
c====
c
      if ( tyconf.eq.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DERCO9', nompro
#endif
        call derco9 ( niveau,
     >                decare,
     >                hetare, filare,
     >                aretri, nivtri,
     >                arequa, nivqua,
     >                quahex, coquhe,
     >                facpyr, cofapy,
     >                facpen, cofape,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'sortie de ',nompro
      do 1106 , iaux = 1 , nbquto
        write (ulsort,90001) 'decision quadrangle', iaux,decfac(-iaux)
cgn        write (ulsort,90001) 'quadrangle', iaux,
cgn     >  arequa(iaux,1), arequa(iaux,2),
cgn     >  arequa(iaux,3), arequa(iaux,4)
 1106 continue
      if ( nbquto.gt.0 ) then
        iaux = min(nbquto,12)
        write (ulsort,90001) 'quadrangle', iaux,
     >  arequa(iaux,1), arequa(iaux,2),
     >  arequa(iaux,3), arequa(iaux,4)
        write (ulsort,90001) 'quadrangle', iaux,
     >  decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >  decare(arequa(iaux,3)), decare(arequa(iaux,4)), decfac(-iaux)
        iaux = min(nbquto,10)
        write (ulsort,90001) 'quadrangle', iaux,
     >  arequa(iaux,1), arequa(iaux,2),
     >  arequa(iaux,3), arequa(iaux,4)
        write (ulsort,90001) 'quadrangle', iaux,
     >  decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >  decare(arequa(iaux,3)), decare(arequa(iaux,4)), decfac(-iaux)
        iaux = min(nbquto,19)
        write (ulsort,90001) 'quadrangle', iaux,
     >  arequa(iaux,1), arequa(iaux,2),
     >  arequa(iaux,3), arequa(iaux,4)
        write (ulsort,90001) 'quadrangle', iaux,
     >  decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >  decare(arequa(iaux,3)), decare(arequa(iaux,4)), decfac(-iaux)
      endif
#endif
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
