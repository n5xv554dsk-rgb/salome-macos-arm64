      subroutine utcote ( letetr, bilan,
     >                    coonoe,
     >                    somare,
     >                    aretri,
     >                    tritet, cotrte, aretet,
     >                    hettet, filtet,
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
c   UTilitaire - COntroles de TEtraedres
c   --           --           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letetr . e   .   1    . numero du tetraedre a examiner             .
c . bilan  .   s .   1    . 0 : tout va bien                           .
c .        .     .        . 1 : probleme                               .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des triangles des tetraedres       .
c . cotrte . e   .nbtecf*4. codes des triangles des tetraedres         .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
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
      parameter ( nompro = 'UTCOTE' )
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
#include "nombtr.h"
#include "nombte.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer letetr, bilan
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
      integer filtet(nbteto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nbfils
      integer freain, etat
c
      double precision prmixt, prmixf
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
      codret = 0
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''.. Examen du '',a,i10)'
      texte(1,5) = '(''.. Le '',a,i10,'' est actif.'')'
c
      texte(2,4) = '(''.. Examination of '',a,'' # '',i10)'
      texte(2,5) = '(''.. The '',a,'' # '',i10,'' is active.'')'
c
#include "impr03.h"
c
c====
c 2. Controle du tetraedre
c    Le tetraedre et ses fils doivent avoir la meme orientation,
c    sinon c'est que un des noeuds a traverse le bord
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Controle tetraedre ; codret = ', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,3), letetr
#endif
c
      etat = mod(hettet(letetr),100)
cgn      write (ulsort,90002) 'etat', etat
c
      if ( etat.eq.0 ) then
c
        codret = 1
c
      else
c
        bilan = 0
c
c 2.1. ==> Produit mixte du tetraedre
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPMTE', nompro
#endif
        call utpmte ( letetr, prmixt,
     >                coonoe, somare, aretri,
     >                tritet, cotrte, aretet )
cgn      write(ulsort,*) letetr,prmixt
c
c 2.2. ==> Les fils
c
        if ( etat.le.26 ) then
          nbfils = 1
        elseif ( etat.le.47 ) then
          nbfils = 3
        else
          nbfils = 7
        endif
cgn      write(ulsort,*) '   ',etat
        freain = filtet(letetr)
        do 221 , iaux = freain , freain+nbfils
          jaux = iaux
          call utpmte ( jaux, prmixf,
     >                  coonoe, somare, aretri,
     >                  tritet, cotrte, aretet )
cgn      write(ulsort,*) '   ',iaux,prmixf
          if ( prmixt*prmixf.le.0.d0 ) then
            bilan = 1
            goto 29
          endif
  221   continue
c
      endif
c
   29 continue
c
c====
c 3. La fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,5)) mess14(langue,1,3), letetr
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
