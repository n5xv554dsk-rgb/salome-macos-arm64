      subroutine cmcdqu ( indnoe, indare, indtri, indqua, decfac,
     >                    coonoe, hetnoe, arenoe, famnoe,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    hetqua, arequa,
     >                    filqua, perqua, famqua,
     >                    nivqua, ninqua,
     >                    cfaqua,
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
c    Creation du Maillage - Conformite - Decoupage des QUadrangles
c    -           -          -            -             --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indtri . es  . 1      . indice du dernier triangle cree            .
c . indqua . es  . 1      . indice du dernier quadrangle cree          .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . famnoe .     . nouvno . famille des noeuds                         .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare . es  . nouvar . caracteristiques des aretes                .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . famtri . es  . nouvtr . famille des triangles                      .
c . hetqua . es  . nouvqu . historique de l'etat des quadrangles       .
c . arequa . es  .nouvqu*3. numeros des 4 aretes des quadrangles       .
c . filqua . es  . nouvqu . premier fils des quadrangles               .
c . famqua . es  . nouvqu . famille des quadrangles                    .
c . perqua . es  . nouvqu . pere des quadrangles                       .
c . nivqua . es  . nouvqu . niveau des quadrangles                     .
c . ninqua . es  . nouvqu . noeud interne au quadrangle                .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
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
      parameter ( nompro = 'CMCDQU' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
#include "nouvnb.h"
#include "dicfen.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nouvno,sdim)
c
      integer indnoe, indare, indtri, indqua
      integer decfac(-permqu:permtr)
      integer hetnoe(nouvno), arenoe(nouvno), famnoe(nouvno)
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer hetqua(nouvqu), arequa(nouvqu,4)
      integer filqua(nouvqu), perqua(nouvqu), famqua(nouvqu)
      integer nivqua(nouvqu)
      integer ninqua(nouvqu)
      integer cfaqua(nctfqu,nbfqua)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer lequad
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
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'au debut de'//nompro//', indnoe= ', indnoe
      write (ulsort,90002) 'au debut de'//nompro//', indare= ', indare
#endif
c====
c 2. Parcours des quadrangles
c====
c
      do 200 , iaux = 1 , permqu
cgn      print *,iaux,decfac(-iaux)
c
        if ( codret.eq.0 ) then
c
        lequad = iaux
c
c 2.1. ==> decoupage en 2 quadrangles des quadrangles
c
        if ( decfac(-iaux).eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCDQ2', nompro
#endif
          call cmcdq2 ( lequad,
     >                  indare, indqua,
     >                  hetare, somare,
     >                  filare, merare, famare,
     >                  hetqua, arequa,
     >                  filqua, perqua, famqua,
     >                  nivqua,
     >                  cfaqua,
     >                  ulsort, langue, codret)
c
c 2.2. ==> decoupage en 3 triangles des quadrangles
c
        elseif ( decfac(-iaux).eq.3 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCDQ3', nompro
#endif
          call cmcdq3 ( lequad,
     >                  indare, indtri,
     >                  hetare, somare,
     >                  filare, merare, famare,
     >                  hettri, aretri,
     >                  filtri, pertri, famtri,
     >                  nivtri,
     >                  hetqua, arequa,
     >                  filqua, famqua,
     >                  nivqua,
     >                  cfaqua,
     >                  ulsort, langue, codret)
c
c 2.3. ==> decoupage en 3 quadrangles des quadrangles
c
        elseif ( decfac(-iaux).eq.5 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCDQ5', nompro
#endif
          call cmcdq5 ( lequad,
     >                  indnoe, indare, indqua,
     >                  coonoe, hetnoe, arenoe, famnoe,
     >                  hetare, somare,
     >                  filare, merare, famare,
     >                  hetqua, arequa,
     >                  filqua, perqua, famqua,
     >                  nivqua, ninqua,
     >                  cfaqua,
     >                  ulsort, langue, codret)
c
        endif
c
        endif
c
  200 continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'a la fin de'//nompro//', indnoe= ', indnoe
      write (ulsort,90002) 'a la fin de'//nompro//', indare= ', indare
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
cgn      print *,'fin de ',nompro,', indtri = ',indtri
cgn      print *,'fin de ',nompro,', indqua = ',indqua
cgn      print *,'fin de ',nompro,', nivtri = ',nivtri
cgn      print *,'fin de ',nompro,', nivqua = ',nivqua
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
