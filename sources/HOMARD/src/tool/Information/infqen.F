      subroutine infqen ( choix, nbenti,
     >                    coonoe, somare,
     >                    hettri, aretri,
     >                    famtri, cfatri,
     >                    hetqua, arequa,
     >                    famqua, cfaqua,
     >                    tritet, cotrte, aretet, hettet,
     >                    quahex, coquhe, arehex, hethex,
     >                    facpyr, cofapy, arepyr, hetpyr,
     >                    facpen, cofape, arepen, hetpen,
     >                    ntreca, nqueca, nteeca,
     >                    ulsost,
     >                    ulsort, langue, codret   )
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
c   INformation : Qualite des ENtites
c   ---           -           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbenti . e   .   1    . nombre d'entites a imprimer                .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . ntreca . e   .   *    . nro des triangles dans le calcul en entree .
c . nqueca . e   .   *    . nro des quadrangles dans le calcul en ent. .
c . nteeca . e   . reteto . numero des tetraedres du code de calcul    .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'INFQEN' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmreel.h"
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "envca1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*2 choix
c
      double precision coonoe(nbnoto,sdim)
c
      integer nbenti
      integer somare(2,nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer cfatri(nctftr,nbftri), famtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpyr(nbpyto)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto)
      integer ntreca(*), nqueca(*), nteeca(*)
c
      integer ulsost
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre0
      integer codre1, codre2, codre3, codre4
      integer ptrav1, ptrav2, ptrav3, ptrav4
      integer ltrav1
      integer iaux, jaux
      integer ideb, ifin, ipas
      integer nbeexa
      integer typenh, nbenac
      integer uldeb, ulfin, ulpas, ulecr
c
      double precision vmin, vmax
c
      character*8 ntrav1, ntrav2, ntrav3, ntrav4
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c====
c 1. initialisation
c====
c
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Quel choix : '',a,'' ?'')'
      texte(1,5) = '(/,''Les pires '',a14,'' :'',/,25(''=''),/)'
      texte(1,6) = '(/,''Les meilleurs '',a14,'' :'',/,30(''=''),/)'
      texte(1,8) = '(''*        Numeros        |    Qualite   *'')'
      texte(1,9) = '(''*  HOMARD   |   calcul  |              *'')'
      texte(1,10) =
     > '(''Aucune face non liee a un tetraedre dans ce maillage.'')'
c
      texte(2,4) = '(''What choice : '',a,'' ?'')'
      texte(2,5) = '(/,''Worst '',a14,'' :'',/,21(''=''),/)'
      texte(2,6) = '(/,''Best '',a14,'' :'',/,20(''=''),/)'
      texte(2,8) = '(''*        Numbers        |    Quality   *'')'
      texte(2,9) = '(''*  HOMARD   |calculation|              *'')'
      texte(2,10) =
     > '(''In this mesh, all the faces are connected to tetraedra.'')'
c
#include "impr03.h"
c
10000 format (40('*'))
10001 format ('*',i10   ,' |',i10   ,' | ',g12.5,' *')
c
      codret = 0
c
c 1.2. ==> type d'entites
c
      if ( choix.eq.'tr' .or.
     >     choix.eq.'TR' ) then
        typenh = 2
        nbenac = nbtrac
c
      elseif ( choix.eq.'qu' .or.
     >     choix.eq.'QU' ) then
        typenh = 4
        nbenac = nbquac
c
      elseif ( choix.eq.'te' .or.
     >     choix.eq.'TE' ) then
        typenh = 3
        nbenac = nbteac
c
      else
        write (ulsort,texte(langue,4)) choix
        codret = 1
      endif
c
c 1.2. ==> tableaux de travail
c
      if ( codret.eq.0 ) then
c
      ltrav1 = nbenac
      call gmalot ( ntrav1, 'entier  ', 2*ltrav1, ptrav1, codre1 )
      call gmalot ( ntrav2, 'reel    ', nbenac, ptrav2, codre2 )
      call gmalot ( ntrav3, 'entier  ', nbenac, ptrav3, codre3 )
      call gmalot ( ntrav4, 'reel    ', nbenac, ptrav4, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c 1.3. ==> Preparation de l'affichage
c
      uldeb = min(ulsost,ulsort)
      ulfin = max(ulsost,ulsort)
      ulpas = max ( 1 , ulfin-uldeb )
c
c====
c 2. recherche des qualites globales
c====
c
      if ( codret.eq.0 ) then
c
cgn      write (ulsost,90002) 'typenh',typenh
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB05A', nompro
#endif
      call utb05a ( typenh,
     >              coonoe, somare,
     >              hettri, aretri,
     >              famtri, cfatri,
     >              hetqua, arequa,
     >              famqua, cfaqua,
     >              tritet, cotrte, aretet, hettet,
     >              quahex, coquhe, arehex, hethex,
     >              facpyr, cofapy, arepyr, hetpyr,
     >              facpen, cofape, arepen, hetpen,
     >              jaux,
     >              nbeexa,
     >              imem(ptrav1), imem(ptrav1+ltrav1),
     >              rmem(ptrav2), rmem(ptrav4),
     >              ulsost,
     >              ulsort, langue, codret )
c
cgn      write (ulsost,90002) 'nbeexa',nbeexa
cgn      do 31 , iaux = 1 , nbeexa
cgn        write (ulsost,*) imem(ptrav1+iaux-1), rmem(ptrav2+iaux-1)
cgn 31      continue
c
      endif
c
c====
c 3. tri
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbeexa.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTTRIR', nompro
#endif
      call uttrir ( imem(ptrav3), vmin, vmax,
     >              nbeexa, rmem(ptrav2),
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 4. affichage
c====
c
      if ( codret.eq.0 ) then
c
      do 40 , ulecr = uldeb , ulfin, ulpas
c
        if ( nbeexa.ne.0 ) then
c
        if ( nbenti.lt.0 ) then
          ideb = nbeexa
          ifin = max(1,nbeexa+nbenti+1)
          ipas = -1
          write (ulecr,texte(langue,5)) mess14(langue,3,typenh)
        else
          ideb = 1
          ifin = min(nbeexa,nbenti)
          ipas = 1
          write (ulecr,texte(langue,6)) mess14(langue,3,typenh)
        endif
c
        write (ulecr,10000)
        write (ulecr,texte(langue,8))
        write (ulecr,texte(langue,9))
        write (ulecr,10000)
        if ( typenh.eq.2 ) then
          do 41 , iaux = ideb, ifin, ipas
            jaux = imem(ptrav3+iaux-1)
            write (ulecr,10001) imem(ptrav1+jaux-1),
     >      ntreca(imem(ptrav1+jaux-1)), rmem(ptrav2+jaux-1)
 41       continue
        elseif ( typenh.eq.3 ) then
          do 42 , iaux = ideb, ifin, ipas
            jaux = imem(ptrav3+iaux-1)
            write (ulecr,10001) imem(ptrav1+jaux-1),
     >      nteeca(imem(ptrav1+jaux-1)), rmem(ptrav2+jaux-1)
 42       continue
        elseif ( typenh.eq.4 ) then
          do 43 , iaux = ideb, ifin, ipas
            jaux = imem(ptrav3+iaux-1)
            write (ulecr,10001) imem(ptrav1+jaux-1),
     >      nqueca(imem(ptrav1+jaux-1)), rmem(ptrav2+jaux-1)
 43       continue
        endif
        write (ulecr,10000)
c
        else
c
        write (ulecr,texte(langue,10))
c
        endif
c
 40   continue
c
      endif
c
c====
c 5. menage
c====
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
      call gmlboj ( ntrav3, codre3 )
      call gmlboj ( ntrav4, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
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
