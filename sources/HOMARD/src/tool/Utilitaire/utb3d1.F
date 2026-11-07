      subroutine utb3d1 ( nbcoqu, nbcoar,
     >                    coonoe,
     >                    somare, filare, np2are,
     >                    cfaare, famare,
     >                    aretri,
     >                    hettet, tritet, cotrte, aretet,
     >                    nbarfr, arefro,
     >                    nbqufr, quafro,
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
c    UTilitaire - Bilan - option 3 - phase D1
c    --           -              -         --
c ______________________________________________________________________
c
c but : controle la presence de noeuds dans les tetraedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbcoqu . es  .   1    . nombre de corrections pour les quadrangles .
c . nbcoar . es  .   1    . nombre de corrections pour les aretes      .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famare . e   . nbarto . famille des aretes                         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . nbarfr . e   .   1    . nombre d'aretes concernees                 .
c . arefro . es  . nbarfr . liste des aretes concernees                .
c . nbqufr . e   .   1    . nombre de quadrangles concernes            .
c . quafro . es  . nbqufr . liste des quadrangles concernes            .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB3D1' )
c
      integer typenh
      parameter ( typenh = 3 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer nbcoar, nbcoqu
      integer somare(2,nbarto), filare(nbarto), np2are(nbarto)
      integer cfaare(nctfar,nbfare), famare(nbarto)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
      integer nbarfr, arefro(nbarfr)
      integer nbqufr, quafro(nbqufr)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer letetr, larete, lenoeu
      integer nuarfr
      integer nbexam, examno(2), examar(2)
      integer sommet(10), nbsomm
      integer listar(6)
      integer arequa(1,4), filqua(1)
      integer cfaqua(1,1), famqua(1)
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      double precision v0(4,3)
      double precision v1(3), v2(3), v3(3), v4(3)
      double precision v21(3), v23(3), v24(3), v41(3), v43(3)
      double precision vn(3)
      double precision xmax, xmin, ymax, ymin, zmax, zmin
      double precision prmito, prmilo
      double precision daux1
c
      logical logaux(7)
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
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
#include "utb303.h"
c
c 1.2. ==> constantes
c
      codret = 0
c
      if ( degre.eq.1 ) then
        nbsomm = 4
      else
        nbsomm = 10
      endif
c
      nbcoar = 0
      nbcoqu = 0
c
c====
c 2. controle de la penetration de noeuds dans les tetraedres
c    remarque : on ne s'interesse qu'aux actifs car les autres sont
c    censes avoir ete controles aux iterations anterieures
c====
cgn      call gtdems (92)
c
      do 20 , letetr = 1 , nbteto
c
#ifdef _DEBUG_HOMARD_
        if ( letetr.lt.0 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
        if ( mod(hettet(letetr),100).eq.0 ) then
cgn      call gtdems (93)
cgn        write (ulsort,*) '.. ', mess14(langue,2,3), letetr
c
#include "utb3d1.h"
c
c 2.2. ==> Les aretes
c
          do 22 , nuarfr = 1 , nbarfr
c
#include "utb308.h"
c
c 2.2.3. ==> Examen
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,1), larete
#endif
c
            do 223 , jaux = 1 , nbexam
c
              lenoeu = examno(jaux)
c
#include "utb304.h"
c
#include "utb3d2.h"
c
c 2.2.8. ==> si logaux(7) est encore vrai, c'est que le noeud est
c            a l'interieur du tetraedre ... correction
c
              if ( logaux(7) ) then
c
                if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,1,-1), lenoeu
#endif
c
                nbcoar = nbcoar + 1
                arefro(nuarfr) = -larete
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCORN_arete', nompro
#endif
                call utcorn ( lenoeu, 0, larete,
     >                        coonoe,
     >                        somare, filare,
     >                        cfaare, famare,
     >                        arequa, filqua,
     >                        cfaqua, famqua,
     >                        ulsort, langue, codret)
c
                endif
c
              endif
c
  223       continue
c
            endif
c
   22     continue
cgn      call gtfims (93)
c
        endif
c
   20 continue
cgn      call gtfims (92)
c
c====
c 3. La fin
c====
c
#include "utb307.h"
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
