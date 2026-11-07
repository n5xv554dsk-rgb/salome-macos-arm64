      subroutine vcmnc2 ( nbanci, nbgemx,
     >                    arreca, arrecb, noerec,
     >                    nohman, nhvois,
     >                    coonoe, hetnoe, arenoe,
     >                    coexno, nnosho, nnosca,
     >                    noempo,
     >                    somare, hetare, np2are,
     >                    merare, filare, insoar,
     >                    coexar, narsho, narsca,
     >                    aretri, arequa,
     >                    ppovos, pvoiso,
     >                    pposif, pfacar,
     >                    ngenar, ngenno, nouent, tabaux, tbdaux,
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
c    aVant adaptation - Conversion de Maillage - Non Conformite - 2
c     -                 -             -          -   -            -
c    Renumerotations des noeuds
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbanci . e   .    1   . nombre d'aretes de non conformite initiale .
c .        .     .        . egal au nombre d'aretes recouvrant 2 autres.
c . nbgemx . e   .    1   . nombre maximal de generations sous une     .
c .        .     .        . arete                                      .
c . arreca .  s  .2*nbanci. liste des aretes recouvrant une autre      .
c . arrecb .  s  .2*nbanci. liste des aretes recouvertes par une autre .
c . noerec .  s  . nbanci . liste initiale des noeuds de recollement   .
c . nohman . e   . char*8 . nom de l'objet maillage homard iteration n .
c . nhvois . e   . char8  . nom de la branche Voisins                  .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c . hetnoe . es  . nbnoto . historique de l'etat des noeuds            .
c . arenoe . es  . nbnoto . 0 pour un sommet, le numero de l'arete pour.
c .        .     .        . un noeud milieu                            .
c . coexno . es  . nbnoto*. codes de conditions aux limites portants   .
c .        .     . nctfno . sur les noeuds                             .
c . nnosho . es  . rsnoac . numero des noeuds dans HOMARD              .
c . nnosca . es  . rsnoto . numero des noeuds dans le calcul           .
c . noempo . es  . nbmpto . numeros des noeuds associes aux mailles    .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . hetare . es  . nbarto . historique de l'etat des aretes            .
c . np2are . es  . nbarto . noeud milieux des aretes                   .
c . merare . es  . nbarto . mere des aretes                            .
c . filare . es  . nbarto . premiere fille des aretes                  .
c . insoar . es  . nbarto . information sur les sommets des aretes     .
c . coexar . es  . nbarto*. codes de conditions aux limites portants   .
c .        .     . nctfar . sur les aretes                             .
c . narsho . es  . rsarac . numero des aretes dans HOMARD              .
c . narsca . es  . rsarto . numero des aretes du calcul                .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . ppovos . es  .   1    . adresse du pointeur des vois. des sommets  .
c . pvoiso . es  .   1    . adresse des voisins des sommets            .
c . pposif . es  .   1    . adresse du pointeur des vois. des aretes   .
c . pfacar . es  .   1    . adresse des voisins des aretes             .
c . ngenar . e   . nbarto . nombre de generations au-dessus des aretes .
c . ngenno .  s  . nbnoto . nombre de generations au-dessus des noeuds .
c . nouent .  s  . nbnoto . nouveau numero des noeuds                  .
c . tabaux . a   .   *    . tableau auxiliaire                         .
c . tbdaux . a   .   *    . tableau auxiliaire reel                    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'VCMNC2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "impr02.h"
#include "envex1.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "envca1.h"
#include "dicfen.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      character*8 nohman, nhvois
c
      integer nbanci, nbgemx
      integer arreca(2*nbanci), arrecb(2*nbanci)
      integer noerec(nbanci)
      integer noempo(nbmpto)
      integer hetnoe(nbnoto), arenoe(nbnoto)
      integer coexno(nbnoto,nctfno)
      integer nnosho(rsnoac), nnosca(rsnoto)
      integer somare(2,nbarto), hetare(nbarto), np2are(nbarto)
      integer filare(nbarto), merare(nbarto), insoar(nbarto)
      integer coexar(nbarto,nctfar)
      integer narsho(rsarac), narsca(rsarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer ngenar(nbarto), ngenno(nbnoto), nouent(0:nbnoto)
      integer tabaux(*)
c
      double precision tbdaux(*)
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer voarno, vofaar, vovoar, vovofa
      integer numgen
      integer numfin
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Nombre de paires de '',a,'' non-conformes :'',i10))'
      texte(1,8) = '(''Regroupement des '',a,'' de generation'',i3)'
c
      texte(2,4) =
     > '(''Number of pairs of non-conformal '',a,'' :'',i10))'
      texte(2,8) = '(''Gathering of '',a,'' in generation'',i3)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbanci
#endif
c
c====
c 2. Elaboration des generations des noeuds
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC05', nompro
#endif
c
      jaux = -1
      call utnc05 ( jaux, nbanci,numfin,
     >              arreca, arrecb,
     >              somare,
     >              ngenar, ngenno, nouent,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 2. Renumerotation des noeuds
c    Remarque : les generations doivent etre parcourues de la plus jeune
c               a la plus vieille, pour tasser vers la fin de la
c               numerotation
c====
c
      numfin = nbnoto
c
      do 21 , numgen = nbgemx , 1 , -1
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
          write (ulsort,texte(langue,8)) mess14(langue,3,-1), numgen
        endif
#endif
c
c 2.1. ==> Recherche des renumerotations
c
        if ( codret.eq.0 ) then
c
        jaux = numgen
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC05', nompro
#endif
c
        call utnc05 ( jaux, nbanci, numfin,
     >                arreca, arrecb,
     >                somare,
     >                ngenar, ngenno, nouent,
     >                ulsort, langue, codret )
cgn      write(ulsort,*) 'nouent'
cgn      do jaux=1,nbnoto
cgn      write(ulsort,3333) jaux,nouent(jaux)
cgn 3333 format (i10,' :',i10)
cgn      enddo
c
        endif
c
c 2.2. ==> Prise en compte des renumerotations
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC06', nompro
#endif
c
        jaux = 0
        call utnc06 ( jaux,
     >                nouent, tabaux, tbdaux,
     >                coonoe, hetnoe, arenoe,
     >                coexno, nnosho, nnosca,
     >                ngenno,
     >                noempo,
     >                somare,
     >                ulsort, langue, codret )
c
        endif
c
   21 continue
cgn      write(ulsort,*) 'ngenno(',     1,') = ',ngenno(1)
cgn      do 2111,iaux=25300,25310
cgn      write(ulsort,*) 'ngenno(',iaux,') = ',ngenno(iaux)
cgn 2111 continue
cgn      write(ulsort,*) 'ngenno(',36917,') = ',ngenno(36917)
cgn      write(ulsort,*) 'ngenno(',36918,') = ',ngenno(36918)
cgn      write(ulsort,*) 'ngenno(',nbnoto,') = ',ngenno(nbnoto)
c
c====
c 3. Renumerotation des aretes soeurs : il faut que celle de plus petit
c    numero soit celle qui demarre sur le noeud de + petit numero
c====
c
c 3.1. ==> Changement des renumerotations
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC03', nompro
#endif
c
      jaux = 0
      call utnc03 ( jaux, nbanci, iaux,
     >              arreca, arrecb,
     >              somare, filare, merare,
     >              ngenar, nouent, tabaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2. ==> Prise en compte des renumerotations
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC04', nompro
#endif
c
      call utnc04 ( nbanci, arreca, arrecb,
     >              nouent, tabaux,
     >              arenoe,
     >              somare, hetare, np2are,
     >              merare, filare, insoar,
     >              coexar, narsho, narsca,
     >              ngenar,
     >              aretri, arequa,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. Stockage du noeud commun aux aretes de recollement
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC07', nompro
#endif
c
      call utnc07 ( nbanci,
     >              noerec, arreca, arrecb,
     >              somare, arenoe,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. Mise a jour des aretes voisines des noeuds
c====
c
      if ( codret.eq.0 ) then
c
      voarno = 2
      vofaar = 0
      vovoar = 0
      vovofa = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nohman, nhvois,
     >              voarno, vofaar, vovoar, vovofa,
     >              ppovos, pvoiso,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 6. la fin
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
