      subroutine vcmnc3 ( nbanci,
     >                    nbnocq, qureca, qurecb,
     >                    nbnoct, trreca, trrecb,
     >                    nohman, nhvois,
     >                    coonoe, hetnoe, arenoe,
     >                    coexno, nnosho, nnosca,
     >                    noempo,
     >                    somare, filare,
     >                    hettri, aretri, filtri,
     >                    hetqua, arequa, filqua, perqua,
     >                    coexqu, nqusho, nqusca,
     >                    quahex, coquhe,
     >                    ppovos, pvoiso,
     >                    pposif, pfacar,
     >                    nouent, tabaux, tbdaux,
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
c    aVant adaptation - Conversion de Maillage - Non Conformite - 3
c     -                 -             -          -   -            -
c    Faces en vis-a-vis
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbanci . e   .    1   . nombre de non conformites                  .
c . nbqut1 . e   .   1    . nombre de quad avec aretes 1&3 recouvrantes.
c . nbqut2 . e   .   1    . nombre de quad avec aretes 2&4 recouvrantes.
c . nbqut4 . e   .   1    . nombre de quad avec 4 aretes recouvrantes  .
c . nbnocq . e   .    1   . nombre de non conformites de quadrangles   .
c . qureca .  s  .4*nbnocq. liste des quad. recouvrant un autre        .
c . qurecb .  s  .4*nbnocq. liste des quad. recouverts par un autre    .
c . nbnoct . e   .    1   . nombre de non conformites de quadrangles   .
c . trreca .  s  .4*nbnoct. liste des triangles recouvrant un autre    .
c . trrecb .  s  .4*nbnoct. liste des triangles recouverts par un autre.
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
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . coexqu . es  . nbquto*. codes de conditions aux limites portants   .
c .        .     . nctfqu . sur les quadrangles                        .
c . nqusho . es  . rsquac . numero des quadrangles dans HOMARD         .
c . nqusca . es  . rsquto . numero des quadrangles du calcul           .
c . quahex . es  .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . es  .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . ppovos . es  .   1    . adresse du pointeur des vois. des sommets  .
c . pvoiso . es  .   1    . adresse des voisins des sommets            .
c . pposif . es  .   1    . adresse du pointeur des vois. des aretes   .
c . pfacar . es  .   1    . adresse des voisins des aretes             .
c . nouent .  s  .   *    . nouveau numero des entites (quad+noeuds)   .
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
      parameter ( nompro = 'VCMNC3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "impr02.h"
c
#include "envex1.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "envca1.h"
#include "dicfen.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      character*8 nohman, nhvois
c
      integer nbanci
      integer nbnocq, qureca(4*nbnocq), qurecb(4*nbnocq)
      integer nbnoct, trreca(4*nbnoct), trrecb(4*nbnoct)
      integer noempo(nbmpto)
      integer hetnoe(nbnoto), arenoe(nbnoto)
      integer coexno(nbnoto,nctfno)
      integer nnosho(rsnoac), nnosca(rsnoto)
      integer somare(2,nbarto), filare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer filtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer filqua(nbquto), perqua(nbquto)
      integer coexqu(nbquto,nctfqu)
      integer nqusho(rsquac), nqusca(rsquto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer nouent(0:nbquto)
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
      integer nbpass
      integer advoqu
      integer ngenno(1)
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
      texte(1,5) = '(''Nombre de passages :'',i10))'
      texte(1,8) =
     > '(''Nombre de '',a,'' a aretes recouvrantes :'',i10))'
c
      texte(2,4) =
     > '(''Number of pairs of non-conformal '',a,'' :'',i10))'
      texte(2,5) = '(''Number of turns :'',i10))'
      texte(2,8) =
     > '(''Number of '',a,'' with covering edges :'',i10))'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbanci
      write (ulsort,texte(langue,8)) mess14(langue,3,2), nbnoct
      write (ulsort,texte(langue,8)) mess14(langue,3,4), nbnocq
#endif
c
c====
c 3. Renumerotation des quadrangles
c    On le fait en 3 passes
c====
c
      nbpass = 0
c
      do 31 , iaux = 1 , 3
c
  310   continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nbpass
#endif
c
        jaux = iaux
c
c 3.1. ==> Changement des renumerotations
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTNC13', nompro
#endif
c
        call utnc13 ( jaux,
     >                nbnoct, trreca, trrecb,
     >                nbnocq, qureca, qurecb,
     >                arequa, filqua, perqua,
     >                filare,
     >                nouent, tabaux,
     >                ulsort, langue, codret )
c
        if ( codret.eq.3 ) then
          nbpass = nbpass + 1
          codret = 0
        endif
c
cgn      call gmprsx (nompro, ntrav3 )
        endif
c
c 3.2. ==> Prise en compte des renumerotations
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTNC14', nompro
#endif
cgn        write(ulsort,*) nouent(794),nouent(10361)
c
        call utnc14 ( nbnocq, qureca, qurecb,
     >                nouent, tabaux,
     >                arequa, hetqua,
     >                filqua, perqua,
     >                coexqu, nqusho, nqusca,
     >                quahex,
     >                ulsort, langue, codret )
c
        endif
c
c 3.3. ==> Si on n'a pas eu assez de trous a 2 ou 4 places, il faut
c          recommencer la passe numero 3
c          A priori, on ne devrait pas faire ce traitement plus de
c          nbanci fois
c
        if ( codret.eq.0 ) then
c
        if ( nbpass.eq.nbanci ) then
          codret = 1
        elseif ( nbpass.gt.0 ) then
          goto 310
        endif
c
        endif
c
   31 continue
cgn    do iaux=1,nbarto
cgn    write(ulsort,*) iaux,somare(1,iaux),somare(2,iaux)
cgn    enddo
c
c====
c 4. Mise a jour des faces voisines des aretes et des volumes
c    voisins des faces
c====
c
      if ( codret.eq.0 ) then
c
      voarno = 0
      vofaar = 2
      vovoar = 0
      vovofa = 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nohman, nhvois,
     >              voarno, vofaar, vovoar, vovofa,
     >              ppovos, pvoiso,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
cgn      return
c
      endif
c
c====
c 3. Renumerotation des noeuds centraux des faces recouvrantes
c====
c
c 3.1. ==> Reperage des noeuds centraux et creation de la nouvelle
c          numerotation des noeuds
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC15', nompro
#endif
c
      call utnc15 ( nbnocq, qureca, qurecb,
     >              somare, arequa,
     >              nouent, tabaux,
     >              ulsort, langue, codret )
c
cgn      write(ulsort,*) 'nbnoto = ',nbnoto
cgn      write(ulsort,*) 'nounoe'
c
      endif
c
c 3.2. ==> Prise en compte des renumerotations
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC06', nompro
#endif
c
      iaux = 1
      call utnc06 ( iaux,
     >              nouent, tabaux, tbdaux,
     >              coonoe, hetnoe, arenoe,
     >              coexno, nnosho, nnosca,
     >              ngenno,
     >              noempo,
     >              somare,
     >              ulsort, langue, codret )
c
      endif
c
c 3.3. ==> Mise a jour des aretes voisines des noeuds
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
c 4. Reorientation des faces recouvertes
c====
c
c 4.1. ==> Les volumes voisins des faces
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      iaux = 7
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux,   jaux,   jaux,
     >                jaux, advoqu,
     >                jaux,   jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c 4.2. ==> Reorientation
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC16', nompro
#endif
c
      call utnc16 ( hettri, aretri, filtri,
     >              hetqua, arequa, filqua,
     >              filare,
     >              quahex, coquhe, imem(advoqu),
     >              ulsort, langue, codret )
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
