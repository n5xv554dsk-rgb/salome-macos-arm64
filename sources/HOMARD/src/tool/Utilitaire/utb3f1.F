      subroutine utb3f1 ( nbcoqu, nbcoar,
     >                    coonoe,
     >                    somare, filare, np2are,
     >                    cfaare, famare,
     >                    aretri,
     >                    arequa, filqua,
     >                    cfaqua, famqua,
     >                    hetpyr, facpyr, cofapy, arepyr,
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
c    UTilitaire - Bilan - option 3 - phase F1
c    --           -              -         --
c ______________________________________________________________________
c
c but : controle la presence de noeuds dans les pyramides
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbcoqu .   s .   1    . nombre de corrections pour les quadrangles .
c . nbcoar .   s .   1    . nombre de corrections pour les aretes      .
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
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
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
      parameter ( nompro = 'UTB3F1' )
c
      integer typenh
      parameter ( typenh = 5 )
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
#include "nombqu.h"
#include "nombpy.h"
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
      integer arequa(nbquto,4), filqua(nbquto)
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpyr(nbpyto)
      integer nbarfr, arefro(nbarfr)
      integer nbqufr, quafro(nbqufr)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lapyra, lequad, larete, lenoeu
      integer nuarfr, nuqufr
      integer nbexam, examno(2), examar(2)
      integer sommet(13), nbsomm
      integer listar(8)
c
      double precision v0(5,3)
      double precision v1(3), v2(3), v3(3), v4(3), v5(3)
      double precision v51(3), v52(3), v53(3), v54(3)
      double precision v12(3), v14(3)
      double precision v5n(3)
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
c
#ifdef _DEBUG_HOMARD_
      integer glop
      data glop / 0 /
#endif
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
#include "impr03.h"
c
#include "utb303.h"
c
c 1.2. ==> constantes
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbpyca', nbpyca
      write(ulsort,90002) 'nbpycf', nbpycf
      write(ulsort,90002) 'nbpyto', nbpyto
#endif
c
      codret = 0
c
      if ( degre.eq.1 ) then
        nbsomm = 5
      else
        nbsomm = 13
      endif
c
      nbcoar = 0
      nbcoqu = 0
c
c====
c 2. controle de la penetration de noeuds dans les pyramides
c    remarque : on ne s'interesse qu'aux actives car les autres sont
c    censees avoir ete controlees aux iterations anterieures
c====
cgn      call gtdems (92)
c
      do 20 , lapyra = 1 , nbpyto
c
#ifdef _DEBUG_HOMARD_
        if ( lapyra.lt.0 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
        if ( mod(hetpyr(lapyra),100).eq.0 ) then
cgn      call gtdems (93)
c
#include "utb3f1.h"
c
c 2.1. ==> Les quadrangles
c
          do 21 , nuqufr = 1 , nbqufr
c
c 2.1.1. ==> Elimination des situations ou il est inutile
c          de controler car le quadrangle a deja ete ramene
c
            lequad = quafro(nuqufr)
c
            if ( lequad.le.0 ) then
              goto 21
            endif
c
c 2.1.2. ==> Reperage des situations a examiner :
c          . le noeud central du quadrangle decoupe
c          . les noeuds P2 courbes : a faire
c          ce noeud central est la seconde extremite de la 2eme ou 3eme
c          arete de l'un quelconque des quadrangles fils (cf. cmrdqu)
c
            if ( codret.eq.0 ) then
c
            if ( typsfr.le.2 ) then
              nbexam = 1
              larete = arequa(filqua(lequad),2)
              examno(1) = somare(2,larete)
            else
              codret = 212
            endif
c
            endif
c
c 2.1.3. ==> Examen
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,4), lequad
#endif
c
            do 213 , jaux = 1 , nbexam
c
              lenoeu = examno(jaux)
c
#include "utb304.h"
c
cgn              write(ulsort,1789) vn
cgn              write(ulsort,1789) xmin,xmax
cgn              write(ulsort,1789) ymin,ymax
cgn              write(ulsort,1789) zmin,zmax
cgn              write(ulsort,*) logaux(7)
cgn 1789 format(3g12.5)
c
#include "utb3f2.h"
c
c 2.1.8. ==> si logaux(7) est encore vrai, c'est que le noeud est
c            a l'interieur de la pyramide ... correction
c
              if ( logaux(7) ) then
c
                if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,1,-1), lenoeu
#endif
c
                nbcoqu = nbcoqu + 1
                quafro(nuqufr) = -lequad
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCORN_quadrangle', nompro
#endif
                call utcorn ( lenoeu, lequad, 0,
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
  213       continue
c
            endif
c
   21     continue
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
#include "utb314.h"
c
cgn              write(ulsort,1789) vn
cgn              write(ulsort,1789) xmin,xmax
cgn              write(ulsort,1789) ymin,ymax
cgn              write(ulsort,1789) zmin,zmax
cgn              write(ulsort,*) logaux(7)
cgn 1789 format(3g12.5)
c
#include "utb3f2.h"
c
c 2.2.8. ==> si logaux(7) est encore vrai, c'est que le noeud est
c            a l'interieur de la pyramide ... correction
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
