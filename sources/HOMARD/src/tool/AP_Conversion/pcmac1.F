      subroutine pcmac1 ( nbele0,
     >                    coonoe, hetnoe, ancnoe, trav1a,
     >                    noempo, hetmpo,
     >                    somare, np2are, hetare,
     >                    aretri, hettri, nintri,
     >                    arequa, hetqua, ninqua,
     >                    tritet, cotrte, aretet, hettet,
     >                    quahex, coquhe, arehex, hethex,
     >                    ninhex,
     >                    facpyr, cofapy, arepyr, hetpyr,
     >                    facpen, cofape, arepen, hetpen,
     >                    famnoe, cfanoe, fammpo, cfampo,
     >                    famare, cfaare,
     >                    famtri, cfatri, famqua, cfaqua,
     >                    famtet, cfatet, famhex, cfahex,
     >                    fampyr, cfapyr, fampen, cfapen,
     >                    nnosca, nnosho, nmpsca, nmpsho,
     >                    narsca, narsho,
     >                    ntrsca, ntrsho, nqusca, nqusho,
     >                    ntesca, ntesho, nhesca, nhesho,
     >                    npysca, npysho, npesca, npesho,
     >                    dimcst, coocst, coonca, fameno,
     >                    famele, noeele, typele,
     >                    fmdeig, noeeig,
     >                    noeord, deraff,
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
c    aPres adaptation - Conversion - MAillage Connectivite - phase 1
c     -                 -            --       -                    -
c ______________________________________________________________________
c
c remarque : on s'arrange pour que les mailles externes soient
c            numerotees dans cet ordre :
c            . les tetraedres
c            . les triangles
c            . les aretes
c            . les mailles-points
c            . les quadrangles
c            . les hexaedres
c            . les pyramides
c            . les pentaedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbele0 . e   .   1    . estimation du nombre d'elements            .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hetnoe . e   . nbnoto . historique de l'etat des noeuds            .
c . noempo . e   . nbmpto . numeros des noeuds associes aux mailles    .
c . hetmpo . e   . nbmpto . historique de l'etat des mailles-points    .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu d'arete          .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nintri . e   . nbtrto . noeud interne au triangle                  .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . ninqua . e   . nbquto . noeud interne au quadrangle                .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . ninhex . e   . nbheto . noeud interne a l'hexaedre                 .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. codes des faces des pentaedres             .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . cfanoe . e   . nctfno*. codes des familles des noeuds              .
c .        .     . nbnoto .   1 : famille MED                          .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . fammpo . e   . nbmpto . famille des mailles-points                 .
c . cfampo . e   . nctfmp*. codes des familles des mailles-points      .
c .        .     . nbfmpo .   1 : famille MED                          .
c .        .     .        .   2 : type de maille-point                 .
c .        .     .        .   3 : famille des sommets                  .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famare . e   . nbarto . famille des aretes                         .
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
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famtet . e   . nbteto . famille des tetraedres                     .
c . cfatet .     . nctfte. codes des familles des tetraedres          .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
c . famhex . e   . nbheto . famille des hexaedres                      .
c . cfahex .     . nctfhe. codes des familles des hexaedres            .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . fampyr . e   . nbpyto . famille des pyramides                      .
c . cfapyr .     . nctfpy. codes des familles des pyramides            .
c .        .     . nbfpyr .   1 : famille MED                          .
c .        .     .        .   2 : type de pyramides                    .
c . fampen . e   . nbpeto . famille des pentaedres                     .
c . cfapen .     . nctfpe. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . nnosca .  s  . rsnoto . numero des noeuds du code de calcul        .
c . nnosho .  s  . rsnoac . numero des noeuds dans HOMARD              .
c . nmpsca .  s  . rsmpto . numero des mailles-points du calcul        .
c . nmpsho .  s  . rsmpac . numero des mailles-points dans HOMARD      .
c . narsca .  s  . rsarto . numero des aretes du calcul                .
c . narsho .  s  . rsarac . numero des aretes dans HOMARD              .
c . ntrsca .  s  . rstrto . numero des triangles du calcul             .
c . ntrsho .  s  . rstrac . numero des triangles dans HOMARD           .
c . nqusca .  s  . rsquto . numero des quadrangles du calcul           .
c . nqusho .  s  . rsquac . numero des quadrangles dans HOMARD         .
c . ntesca .  s  . rsteto . numero des tetraedres du calcul            .
c . ntesho .  s  . rsteac . numero des tetraedres dans HOMARD          .
c . nhesho .  s  . reheac . numero des hexaedres dans HOMARD           .
c . nhesca .  s  . rsheto . numero des hexaedres dans le calcul        .
c . npysho .  s  . repyac . numero des pyramides dans HOMARD           .
c . npysca .  s  . rspyto . numero des pyramides dans le calcul sortie .
c . npesho .  s  . repeac . numero des pentaedres dans HOMARD          .
c . npesca .  s  . rspeto . numero des pentaedres dans le calcul       .
c . dimcst . e   .    1   . dimension de la coordonnee constante       .
c .        .     .        . eventuelle, 0 si toutes varient            .
c . coocst . e   .   11   . 1 : coordonnee constante eventuelle        .
c .        .     .        . 2, 3, 4 : xmin, ymin, zmin                 .
c .        .     .        . 5, 6, 7 : xmax, ymax, zmax                 .
c .        .     .        . 8, 9, 10 : -1 si constant, max-min sinon   .
c .        .     .        . 11 : max des (max-min)                     .
c . coonca .   s . nbnoto . coordonnees des noeuds dans le calcul      .
c .        .     . *sdimca.                                            .
c . fameno .   s . nbnoto . famille med des noeuds                     .
c . famele .   s . nbele0 . famille med des elements                   .
c . noeele .   s . nbele0 . noeuds des elements                        .
c .        .     . *nbmane.                                            .
c . typele .   s . nbele0 . type des elements                          .
c . noeord . e   .   1    . vrai si les noeuds sont ordonnes           .
c .        .     .        . faux si sans importance                    .
c . noeeig . e   .nbelig**. noeuds des elements                        .
c . fmdeig . e   . nbelig . famille med des elements                   .
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
      parameter ( nompro = 'PCMAC1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
c
#include "nbfami.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombno.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
#include "nombsr.h"
#include "nbutil.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer nbele0
      integer dimcst
c
      double precision coocst(11)
      double precision coonoe(nbnoto,sdim), coonca(nbnoto,sdimca)
c
      integer hetnoe(nbnoto), ancnoe(nbnoto), trav1a(nbnoto)
      integer noempo(nbmpto), hetmpo(nbmpto)
      integer somare(2,nbarto), np2are(nbarto)
      integer hetare(nbarto)
      integer aretri(nbtrto,3), hettri(nbtrto), nintri(nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto), ninqua(nbquto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto), ninhex(nbheto)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpyr(nbpyto)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto)
c
      integer cfanoe(nctfno,nbfnoe), famnoe(nbnoto)
      integer cfampo(nctfmp,nbfmpo), fammpo(nbmpto)
      integer cfaare(nctfar,nbfare), famare(nbarto)
      integer cfatri(nctftr,nbftri), famtri(nbtrto)
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
      integer cfatet(nctfte,nbftet), famtet(nbteto)
      integer cfahex(nctfhe,nbfhex), famhex(nbheto)
      integer cfapyr(nctfpy,nbfpyr), fampyr(nbpyto)
      integer cfapen(nctfpe,nbfpen), fampen(nbpeto)
c
      integer nnosca(rsnoto), nnosho(rsnoac)
      integer nmpsca(rsmpto), nmpsho(nbele0)
      integer narsca(rsarto), narsho(nbele0)
      integer ntrsca(rstrto), ntrsho(nbele0)
      integer nqusca(rsquto), nqusho(nbele0)
      integer ntesca(rsteto), ntesho(nbele0)
      integer nhesca(rsheto), nhesho(nbele0)
      integer npysca(rspyto), npysho(nbele0)
      integer npesca(rspeto), npesho(nbele0)
c
      integer fameno(nbnoto), famele(nbele0), noeele(nbele0,nbmane)
      integer typele(nbele0)
      integer fmdeig(nbelig)
      integer noeeig(nbelig,*)
c
      logical noeord
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer elemen
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
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de mailles calcule :'',i11)'
      texte(1,5) = '(''Nombre de mailles estime  :'',i11)'
      texte(1,6) = '(''Elements hierarchiques :'',i2)'
c
      texte(2,4) = '(''Computed number of meshes  :'',i11)'
      texte(2,5) = '(''Estimated number of meshes :'',i11)'
      texte(2,6) = '(''Hierarchical elements :'',i2)'
c
#include "impr03.h"
c
      nbquad = 0
      nbhexa = 0
      nbpent = 0
      nbpyra = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) hierar
#endif
c
      codret = 0
c
c====
c 2. les noeuds
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMANO', nompro
#endif
      call pcmano ( coonoe, hetnoe,
     >              famnoe, cfanoe,
     >              nnosca, nnosho,
     >              dimcst, coocst, sdimca, coonca,
     >              noeord,
     >              fameno,
     >              ulsort, langue, codret )
c
c====
c 3. les mailles
c    on rappelle que la caracteristique numero 2 d'une maille
c    est nulle si ce n'etait pas une maille du calcul.
c    si c'est une maille de calcul, la caracteristique vaut le type
c    correspondant a celui du code de calcul associe.
c
c remarque : on s'arrange pour que les mailles externes soient
c            numerotees dans cet ordre :
c            . les tetraedres
c            . les triangles
c            . les aretes
c            . les mailles-points
c            . les quadrangles
c            . les hexaedres
c            . les pyramides
c            . les pentaedres
c            Cela est indispensable pour les algorithmes de
c            conversion de solution et pour la gestion des equivalences
c
c remarque : dans le cas general, on ne prend que les mailles actives.
c            mais dans le cas hierarchique, on prend tous les niveaux.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. mailles ; codret', codret
#endif
c
      elemen = 0
c
c 3.1. ==> les tetraedres actifs
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. tetraedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( rsteto.eq.0 ) then
c
        nbtetr = 0
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMATE', nompro
#endif
        call pcmate ( elemen, nbele0,
     >                somare, np2are,
     >                aretri,
     >                tritet, cotrte, aretet,
     >                hettet, famtet, cfatet,
     >                nnosca, ntesca, ntesho,
     >                famele, noeele, typele,
     >                ulsort, langue, codret )
c
        nbtetr = elemen
c
      endif
c
      endif
c
c 3.2. ==> les mailles triangulaires :
c                                 - triangles actifs en 2,5d
c                                 - triangles actifs isoles en 3d,
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. triangles ; codret', codret
      write (ulsort,90002) 'nbtrac', nbtrac
#endif
c
      if ( codret.eq.0 ) then
c
      if ( rstrto.eq.0 ) then
c
        nbtria = 0
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMATR', nompro
#endif
        call pcmatr ( elemen, nbele0,
     >                somare, np2are,
     >                aretri, hettri, nintri,
     >                famtri, cfatri,
     >                nnosca, ntrsca, ntrsho,
     >                famele, noeele, typele,
     >                ulsort, langue, codret )
c
        nbtria = elemen - nbtetr
c
      endif
c
      endif
c
c 3.3. ==> les poutres, c'est-a-dire les aretes isolees
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( rsarto.eq.0 ) then
c
        nbsegm = 0
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAAR', nompro
#endif
        call pcmaar ( elemen, nbele0,
     >                somare, np2are, hetare,
     >                famare, cfaare,
     >                nnosca, narsca, narsho,
     >                famele, noeele, typele,
     >                ulsort, langue, codret )
c
        nbsegm = elemen - nbtetr - nbtria
c
      endif
c
      endif
c
c 3.4. ==> les mailles-points
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. mailles-points ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( rsmpto.eq.0 ) then
c
        nbmapo = 0
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAMP', nompro
#endif
        call pcmamp ( elemen, nbele0,
     >                noempo, hetmpo,
     >                fammpo, cfampo,
     >                nnosca, nmpsca, nmpsho,
     >                famele, noeele, typele,
     >                ulsort, langue, codret )
c
        nbmapo = elemen - nbtetr - nbtria - nbsegm
c
      endif
c
      endif
c
c 3.5. ==> les elements quadrangulaires :
c                                 - quadrangles actifs en 2,5d
c                                 - quadrangles actifs isoles en 3d,
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.5. quadrangles ; codret', codret
      write (ulsort,90002) 'nbquac', nbquac
#endif
c
      if ( codret.eq.0 ) then
c
      if ( rsquto.eq.0 ) then
c
        nbquad = 0
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAQU', nompro
#endif
        call pcmaqu ( elemen, nbele0,
     >                somare, np2are,
     >                arequa, hetqua, ninqua,
     >                famqua, cfaqua,
     >                nnosca, nqusca, nqusho,
     >                famele, noeele, typele,
     >                ulsort, langue, codret )
c
        nbquad = elemen - nbtetr - nbtria - nbsegm - nbmapo
c
      endif
c
      endif
c
c 3.6. ==> les hexaedres actifs
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.6. hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( rsheto.eq.0 ) then
c
        nbhexa = 0
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAHE', nompro
#endif
        call pcmahe ( elemen, nbele0,
     >                somare, np2are,
     >                arequa,
     >                quahex, coquhe, arehex,
     >                hethex, ninhex,
     >                famhex, cfahex,
     >                nnosca, nhesca, nhesho,
     >                famele, noeele, typele,
     >                ulsort, langue, codret )
c
        nbhexa = elemen - nbtetr - nbtria - nbsegm - nbmapo - nbquad
c
      endif
c
      endif
c
c 3.7. ==> les pyramides actives
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.7. pyramides ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( rspyto.eq.0 ) then
c
        nbpyra = 0
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAPY', nompro
#endif
        call pcmapy ( elemen, nbele0,
     >                somare, np2are,
     >                aretri,
     >                facpyr, cofapy, arepyr,
     >                hetpyr, fampyr, cfapyr,
     >                nnosca, npysca, npysho,
     >                famele, noeele, typele,
     >                ulsort, langue, codret )
c
        nbpyra = elemen - nbtetr - nbtria - nbsegm - nbmapo - nbquad
     >                  - nbhexa
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Nombre de pyramides converties', nbpyra
#endif
c
      endif
c
      endif
c
c 3.8. ==> les pentaedres actifs
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.8. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( rspeto.eq.0 ) then
c
        nbpent = 0
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAPE', nompro
#endif
        call pcmape ( elemen, nbele0,
     >                somare, np2are,
     >                arequa,
     >                facpen, cofape, arepen,
     >                hetpen, fampen, cfapen,
     >                nnosca, npesca, npesho,
     >                famele, noeele, typele,
     >                ulsort, langue, codret )
c
        nbpent = elemen - nbtetr - nbtria - nbsegm - nbmapo - nbquad
     >                  - nbhexa - nbpyra
c
      endif
c
      endif
c
c===
c 4. Les eventuelles mailles ignorees
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Elements ignores ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbelig.ne.0 ) then
c
        nbpyra = nbpyra + nbelig
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Nombre de pyramides', nbpyra
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAIG', nompro
#endif
        call pcmaig ( nbele0, nbelig,
     >                fmdeig, noeeig,
     >                elemen, typele, famele, noeele,
     >                nnosca, ancnoe, trav1a, deraff,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. mise a jour
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. mise a jour ; codret', codret
#endif
c
c 5.1.==>  nombres caracteristiques du maillage de calcul
c
      if ( codret.eq.0 ) then
c
      if ( nbhexa.ne.0 ) then
        nbmaae = 12
        nbmafe = 6
      elseif ( nbpent.ne.0 ) then
        nbmaae = 9
        nbmafe = 5
      elseif ( nbpyra.ne.0 ) then
        nbmaae = 8
        nbmafe = 5
      elseif ( nbtetr.ne.0 ) then
        nbmaae = 6
        nbmafe = 4
      elseif ( nbquad.ne.0 ) then
        nbmaae = 4
        nbmafe = 1
      elseif ( nbtria.ne.0 ) then
        nbmaae = 3
        nbmafe = 1
      else
        nbmaae = 1
        nbmafe = 0
      endif
c
      nbelem = nbmapo + nbsegm +
     >         nbtria + nbquad +
     >         nbtetr + nbhexa + nbpyra + nbpent
c
      if ( elemen.ne.nbelem ) then
        write (ulsort,texte(langue,4)) elemen
        write (ulsort,texte(langue,5)) nbelem
        write (ulsort,texte(langue,3))
        codret = 1
      endif
c
      numael = nbelem
      numano = nbnoto
c
      nvoare = -1
      nvosom = -1
c
      endif
c
c 5.2. ==> nombres propres a la renumerotation des entites
c
      if ( codret.eq.0 ) then
c
      if ( nbmapo.ne.0 ) then
        rsmpac = elemen
      else
        rsmpac = 0
      endif
c
      if ( nbsegm.ne.0 ) then
        rsarac = elemen
      else
        rsarac = 0
      endif
c
      if ( nbtria.ne.0 ) then
        rstrac = elemen
      else
        rstrac = 0
      endif
c
      if ( nbquad.ne.0 ) then
        rsquac = elemen
      else
        rsquac = 0
      endif
c
      if ( nbteto.ne.0 ) then
        rsteac = elemen
      else
        rsteac = 0
      endif
c
      if ( nbheto.ne.0 ) then
        rsheac = elemen
      else
        rsheac = 0
      endif
c
      if ( nbpyto.ne.0 ) then
        rspyac = elemen
      else
        rspyac = 0
      endif
c
      if ( nbpeto.ne.0 ) then
        rspeac = elemen
      else
        rspeac = 0
      endif
c
      rseutc = elemen
      if ( rsteac.eq.0 .and. rsheac.eq.0 .and. rspyac.eq.0 ) then
        rsevca = nbtria + nbquad
        rsevto = rstrto + rsquto
      else
        rsevca = nbtetr + nbhexa + nbpyra + nbpent
        rsevto = rsteto + rsheto + rspyto + rspeto
      endif
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
