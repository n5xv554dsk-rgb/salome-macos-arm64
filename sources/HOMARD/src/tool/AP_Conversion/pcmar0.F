      subroutine pcmar0 ( nonexm,
     >                    hetare, filare, merare,
     >                    famare, posifa, facare,
     >                    aretri, hettri, nivtri,
     >                    famtri, pertri, filtri,
     >                    arequa, hetqua, nivqua,
     >                    famqua, perqua, filqua,
     >                    hettet,
     >                    hethex,
     >                    hetpyr,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
     >                    nbanci, nbenrc, numead,
     >                    arreca, trreca, qureca,
     >                    nparrc, nptrrc, npqurc,
     >                    npterc, npherc, npperc, nppyrc,
     >                    arerec, trirec, quarec,
     >                    tetrec, hexrec, penrec, pyrrec,
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
c    aPres adaptation - Conversion de MAillage - Recollements - phase 0
c     -                 -             --         -                    -
c    Reperage des faces de raccordement non conforme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nonexm . e   .    1   . non exportation de mailles                 .
c .        .     .        .   1 : on exporte toutes les mailles        .
c .        .     .        .  2x : les segments ne sont pas exportes    .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . fille ainee de chaque arete                .
c . merare . e   . nbarto . mere de chaque arete                       .
c . famare . es  . nbarto . famille des aretes                         .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . famtri . es  . nbtrto . famille des triangles                      .
c . pertri . e   . nbtrto . pere des triangles                         .
c . filtri . e   . nbtrto . fils des triangles                         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . famqua . es  . nbquto . famille des quadrangles                    .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . filqua . e   . nbquto . fils des quadrangles                       .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . nbanci . e   .    1   . nombre de non conformites initiales        .
c . nbenrc . e   .    1   . nombre d'entites par recollement unitaire  .
c . numead . e   .   1    . numero de la mere adoptive                 .
c . arreca . e   .2*nbanci. liste des aretes recouvrant une autre      .
c . nparrc .  s  .   1    . nombre de paires d'aretes a recoller       .
c . nptrrc .  s  .   1    . nombre de paires de triangles a recoller   .
c . npqurc .  s  .   1    . nombre de paires de quadrangles a recoller .
c . npterc .  s  .   1    . nombre de paires de tetraedres recolles    .
c . npherc .  s  .   1    . nombre de paires d'hexaedres recolles      .
c . npperc .  s  .   1    . nombre de paires de pentaedres recolles    .
c . nppyrc .  s  .   1    . nombre de paires de pyramides recollees    .
c . arerec .  s  .  2*x   . paires des aretes a recoller               .
c . trirec .  s  .  2*x   . paires des triangles a recoller            .
c . quarec .  s  .  2*x   . paires des quadrangles a recoller          .
c . tetrec .  s  .  3*x   . paires des tetra. voisins faces a recoller .
c . hexrec .  s  .  3*x   . paires des hexa. voisins faces a recoller  .
c . penrec .  s  .  3*x   . paires des penta. voisins faces a recoller .
c . pyrrec .  s  .  3*x   . paires des pyram. voisines faces a recoller.
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
      parameter ( nompro = 'PCMAR0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nbfami.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nonexm
c
      integer hetare(nbarto), filare(nbarto), merare(nbarto)
      integer famare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer aretri(nbtrto,3), hettri(nbtrto), nivtri(nbtrto)
      integer famtri(nbtrto), pertri(nbtrto), filtri(nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto), nivqua(nbquto)
      integer famqua(nbquto), perqua(nbquto),filqua(nbquto)
      integer hettet(nbteto)
      integer hethex(nbheto)
      integer hetpyr(nbpyto)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer volqua(2,nbquto), pypequ(2,*)
      integer nbanci, nbenrc, numead
      integer arreca(nbenrc*nbanci)
      integer nparrc, nptrrc, npqurc
      integer npterc, npherc, npperc, nppyrc
      integer trreca(nbtrri)
      integer qureca(nbquri)
      integer arerec(2,*), trirec(2,*), quarec(2,*)
      integer tetrec(3,*), hexrec(3,*), penrec(3,*), pyrrec(3,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 30 )
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
      texte(1,4) = '(''On ne devrait pas passer dans '',a)'
      texte(1,5) = '(''Examen du '',a,''numero '',i10)'
      texte(1,6) =
     > '(2x,''Nombre de paires de '',a,''a recoller :'',i10)'
      texte(1,8) =
     > '(''.. Modification de la famille du '',a,''numero '',i10)'
      texte(1,9) =
     > '(''.. Modification de l''''etat du '',a,''numero '',i10)'
      texte(1,10) = '(5x,''==> avant :'',i5,'', apres :'',i5)'
      texte(1,11) = '(''Nombre de non-conformites initiales :'',i10))'
      texte(1,12) = '(''. de fils :'',2i10))'
      texte(1,13) = '(''. Etat du '',a,''numero '',i10,'' :'',i10)'
c
      texte(2,4) = '(a,'' should not be called.'')'
      texte(2,5) = '(''Examination of '',a,'',# '',i10)'
      texte(2,6) = '(2x,''Number of pairs of '',a,''to glue :'',i10)'
      texte(2,8) =
     > '(''.. Modification of the family of '',a,'',# '',i10)'
      texte(2,9) =
     > '(''.. Modification of the state of '',a,'',# '',i10)'
      texte(2,10) = '(5x,''==> old :'',i5,'', new :'',i5)'
      texte(2,11) = '(''Number of non-conformal situations :'',i10))'
      texte(2,12) = '(''. with sons :'',2i10))'
      texte(2,13) = '(''. State for '',a,''# '',i10,'' :'',i10)'
c
#include "impr03.h"
c
      codret = 0
c
      nparrc = 0
      nptrrc = 0
      npqurc = 0
      npterc = 0
      npherc = 0
      npperc = 0
      nppyrc = 0
c
c====
c 2. Les aretes
c====
c
      if ( mod(nonexm,2).ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAR2', nompro
#endif
        call pcmar2 ( hetare, filare, merare,
     >                famare, posifa, facare,
     >                aretri, hettri, nivtri,
     >                voltri,
     >                arequa, hetqua, nivqua,
     >                nbanci, nbenrc,
     >                arreca,
     >                nparrc, arerec,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 3. Les triangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Les triangles ; codret', codret
#endif
c
      if ( nbtrto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 2
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'PCMAR3_tr', nompro
#endif
        call pcmar3 (   iaux, numead,
     >                nbtrto, nbteto, nbftri,
     >                hettri, nivtri,
     >                famtri, pertri, filtri,
     >                hettet, hetpyr,
     >                voltri, pypetr,
     >                nbtrri, trreca,
     >                nptrrc, trirec,
     >                npterc, tetrec, npperc, penrec, nppyrc, pyrrec,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 4. Les quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Les quadrangles ; codret', codret
#endif
c
      if ( nbquto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAR3_qu', nompro
#endif
        call pcmar3 (   iaux, numead,
     >                nbquto, nbheto, nbfqua,
     >                hetqua, nivqua,
     >                famqua, perqua, filqua,
     >                hethex, hetpyr,
     >                volqua, pypequ,
     >                nbquri, qureca,
     >                npqurc, quarec,
     >                npherc, hexrec, npperc, penrec, nppyrc, pyrrec,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 5. Bilan
c====
#ifdef _DEBUG_HOMARD_
c
      if ( codret.eq.0 ) then
c
      if ( mod(nonexm,2).ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,1), nparrc
      endif
      write (ulsort,texte(langue,6)) mess14(langue,3,2), nptrrc
      write (ulsort,texte(langue,6)) mess14(langue,3,4), npqurc
      write (ulsort,*) ' '
c
      endif
#endif
c
c====
c 6. la fin
c====
c
cgn      iaux = 12274
cgn          write (ulsort,texte(langue,5)) mess14(langue,1,2), iaux
cgn          write (ulsort,*) 'etat    = ',hettri(iaux),
cgn     >                     ', famille = ',famtri(iaux)
cgn      iaux = 31599
cgn          write (ulsort,texte(langue,5)) mess14(langue,1,2), iaux
cgn          write (ulsort,*) 'etat    = ',hettri(iaux),
cgn     >                     ', famille = ',famtri(iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. la fin ; codret = ', codret
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
