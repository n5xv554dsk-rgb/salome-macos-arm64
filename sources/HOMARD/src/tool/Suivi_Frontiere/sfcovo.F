      subroutine sfcovo ( bilan,
     >                    nbtetr, nbhexa, nbpyra, nbpent,
     >                    decafv, volare,
     >                    coonoe,
     >                    somare,
     >                    aretri,
     >                    arequa,
     >                    tritet, cotrte, aretet,
     >                    hettet, filtet,
     >                    quahex, coquhe, arehex,
     >                    hethex, filhex,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
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
c   Suivi de Frontiere - COntroles des VOlumes
c   -        -           --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . bilan  .   s .   1    . bilan du controle de l'arete               .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c . nbtetr . e   .   1    . nombre de tetraedres voisins               .
c . nbhexa . e   .   1    . nombre d'hexaedres voisins                 .
c . nbpyra . e   .   1    . nombre de pyramides voisines               .
c . nbpent . e   .   1    . nombre de pentaedres voisins               .
c . decafv . e   .   1    . decalage dans le tableau volare            .
c . volare . e   .   *    . liste des voisins                          .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des triangles des tetraedres       .
c . cotrte . e   .nbtecf*4. codes des triangles des tetraedres         .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'SFCOVO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombhe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer bilan
      integer nbtetr, nbhexa, nbpyra, nbpent
      integer decafv, volare(*)
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto), filtet(nbteto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto), filhex(nbheto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
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
      texte(1,4) = '(/,''.. Examen du '',a,i10)'
      texte(1,5) = '(''.. Probleme.'')'
      texte(1,6) = '(''.. Nombre de voisins de type '',a,'':'',i10)'
c
      texte(2,4) = '(/,''.. Examination of '',a,'' # '',i10)'
      texte(2,5) = '(''.. Problem.'')'
      texte(2,6) = '(''.. Number of neighbours '',a,''type :'',i10)'
c
#include "impr03.h"
c
c====
c 3. Controle des tetraedres
c====

#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Controle tetraedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,3), nbtetr
#endif
c
      do 31 , iaux = 1 , nbtetr
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,3), volare(iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCOTE', nompro
#endif
        call utcote ( volare(iaux), bilan,
     >                coonoe,
     >                somare,
     >                aretri,
     >                tritet, cotrte, aretet,
     >                hettet, filtet,
     >                ulsort, langue, codret)
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( bilan.ne.0 ) then
          goto 70
        endif
c
        endif
c
   31 continue
c
      endif
c
c====
c 4. Controle des hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Controle hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,6), nbhexa
#endif
c
      do 41 , iaux = 1 , nbhexa
c
        if ( codret.eq.0 ) then
ccc        if ( volare(decafv+iaux).ne.49 ) goto 41
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
     >                    mess14(langue,1,6), volare(decafv+iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCOHE', nompro
#endif
        call utcohe ( volare(decafv+iaux), bilan,
     >                coonoe,
     >                somare,
     >                arequa,
     >                quahex, coquhe, arehex,
     >                hethex, filhex,
     >                ulsort, langue, codret)
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( bilan.ne.0 ) then
          goto 70
        endif
c
        endif
c
   41 continue
c
      endif
c
c====
c 5. Controle des pyramides
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Controle pyramides ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,5), nbpyra
#endif
c
      do 51 , iaux = 1 , nbpyra
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
     >                    mess14(langue,1,5), volare(2*decafv+iaux)
#endif
c
        if ( codret.eq.0 ) then
c
        if ( bilan.ne.0 ) then
          goto 70
        endif
c
        endif
c
        endif
c
   51 continue
c
      endif
c
c====
c 6. Controle des pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Controle pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,7), nbpent
#endif
c
      do 61 , iaux = 1 , nbpent
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
     >                    mess14(langue,1,7), volare(3*decafv+iaux)
#endif
c
        if ( codret.eq.0 ) then
c
        if ( bilan.ne.0 ) then
          goto 70
        endif
c
        endif
c
        endif
c
   61 continue
c
      endif
c
c====
c 7. Bilan
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. Bilan ; codret', codret
#endif
c
   70 continue
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      if ( bilan.ne.0 ) then
        write (ulsort,texte(langue,5))
      endif
      endif
#endif
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
