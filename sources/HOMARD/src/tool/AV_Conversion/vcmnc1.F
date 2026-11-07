      subroutine vcmnc1 ( nbanci, nbgemx,
     >                    arreca, arrecb,
     >                    nohman, nhvois,
     >                    arenoe,
     >                    somare, hetare, np2are,
     >                    merare, filare, insoar,
     >                    coexar, narsho, narsca,
     >                    aretri, arequa,
     >                    ppovos, pvoiso,
     >                    pposif, pfacar,
     >                    ngenar, nouare, tabaux,
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
c    aVant adaptation - Conversion de Maillage - Non Conformite - 1
c     -                 -             -          -   -            -
c    Traitement des aretes en vis-a-vis
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
c . nohman . e   . char*8 . nom de l'objet maillage homard iteration n .
c . nhvois . e   . char8  . nom de la branche Voisins                  .
c . arenoe . es  . nbnoto . 0 pour un sommet, le numero de l'arete pour.
c .        .     .        . un noeud milieu                            .
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
c . nouare .  s  . nbarto . nouveau numero des aretes                  .
c . tabaux . a   .   *    . tableau auxiliaire                         .
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
      parameter ( nompro = 'VCMNC1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "impr02.h"
#include "envex1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "dicfen.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      character*8 nohman, nhvois
c
      integer nbanci, nbgemx
      integer arreca(2*nbanci), arrecb(2*nbanci)
      integer arenoe(nbnoto)
      integer somare(2,nbarto), hetare(nbarto), np2are(nbarto)
      integer filare(nbarto), merare(nbarto), insoar(nbarto)
      integer coexar(nbarto,nctfar)
      integer narsho(rsarac), narsca(rsarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer ngenar(nbarto), nouare(0:nbarto)
      integer tabaux(*)
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
      parameter ( nbmess = 20 )
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
      texte(1,5) =
     > '(''Nombre maximal de generations de '',a,'' :'',i10))'
      texte(1,6) = '(/,''Phase numero'',i2))'
      texte(1,7) = '(''Decalage des '',a,'' de generation'',i3)'
      texte(1,8) = '(''Regroupement des '',a,'' de generation'',i3)'
      texte(1,10) = '(''Il devrait etre '',a,i10)'
      texte(1,11) = '(a,''recouvert'',i10)'
      texte(1,12) = '(a,''recouvrant'',i10)'
c
      texte(2,4) =
     > '(''Number of pairs of non-conformal '',a,'' :'',i10))'
      texte(2,5) =
     > '(''Maximal number of generations for '',a,'':'',i10))'
      texte(2,6) = '(/,''Phase #'',i2)'
      texte(2,7) = '(''Renumbering of '',a,'' in generation'',i3)'
      texte(2,8) = '(''Gathering of '',a,'' in generation'',i3)'
      texte(2,10) = '(''It should be '',a,i10)'
      texte(2,11) = '(a,''covered #'',i10)'
      texte(2,12) = '(a,''covering #'',i10)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbanci
      write (ulsort,texte(langue,5)) mess14(langue,3,1), nbgemx
#endif
c
c====
c 2. Stockage des aretes en vis-a-vis
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC02', nompro
#endif
c
      call utnc02 ( nbanci,
     >              arreca, arrecb,
     >              merare,
     >              ulsort, langue, codret )
c
c====
c 3. Renumerotation des aretes
c    On le fait en 2 passes :
c     1 : on classe par generations
c     2 : au sein d'une generation, on regroupe par fratries de soeurs.
c    Remarque : les generations doivent etre parcourues de la plus jeune
c               a la plus vieille, pour tasser vers la fin de la
c               numerotation
c    Remarque : il est inutile de faire un traitement special pour les
c               aretes sans ascendance. Elles vont logiquement se
c               trouver en tete de numerotation.
c====
c
      if ( codret.eq.0 ) then
c
      do 31 , iaux = 1 , 2
c
        numfin = nbarto
c
        do 310 , numgen = nbgemx , 1 , -1
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,texte(langue,6)) iaux
        if ( iaux.eq.1 ) then
          write (ulsort,texte(langue,7)) mess14(langue,3,1), numgen
        else
          write (ulsort,texte(langue,8)) mess14(langue,3,1), numgen
        endif
        endif
#endif
cgn      write(ulsort,*) 'ante / erte'
cgn      do jaux=1,2*nbanci
cgn      write(ulsort,3333) jaux,arreca(jaux),arrecb(jaux)
cgn 3333 format (i10,' :',2i10)
cgn      enddo
c
c 3.1. ==> Changement des renumerotations
c
        if ( codret.eq.0 ) then
c
        if ( iaux.eq.1 ) then
          jaux = -numgen
        else
          jaux = numgen
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTNC03', nompro
#endif
c
        call utnc03 ( jaux, nbanci, numfin,
     >                arreca, arrecb,
     >                somare, filare, merare,
     >                ngenar, nouare, tabaux,
     >                ulsort, langue, codret )
c
cgn        write (ulsort,*)'nouare : ',nouare
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
     >                nouare, tabaux,
     >                arenoe,
     >                somare, hetare, np2are,
     >                merare, filare, insoar,
     >                coexar, narsho, narsca,
     >                ngenar,
     >                aretri, arequa,
     >                ulsort, langue, codret )
c
        endif
c
  310 continue
cgn       write (ulsort,*)'ngenar : ',ngenar
cgn       write (ulsort,*)'merare : ',merare
c
   31 continue
c
      endif
cgn    do iaux=1,nbarto
cgn    write(ulsort,*) iaux,somare(1,iaux),somare(2,iaux)
cgn    enddo
c
cgn      if ( codret.eq.0 ) then
c
cgn      jaux = 2*nbanci
cgn      do 321 , iaux = 1 , jaux
c
cgn        if ( arreca(iaux).gt.nbanci ) then
cgn          write(ulsort,*) 'arreca(', iaux, ') = ', arreca(iaux)
cgn          codret = codret + 1
cgn        endif
c
cgn  321 continue
c
cgn      endif
c
c====
c 4. Mise a jour des faces voisines des aretes
c====
c
      if ( codret.eq.0 ) then
c
      voarno = 0
      vofaar = 2
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
