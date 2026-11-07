      subroutine sfcaf2 ( suifro, ulgrfr,
     >                    nbfrdi, geocoo, abscur,
     >                    numnoe, lignoe, abscno,
     >                    typlig, somseg, seglig,
     >                    nbfran, casfre,
     >                    unst2x, epsid2,
     >                    coonoe,
     >                    noehom,
     >                    hetare, somare, filare,
     >                    np2are, cfaare, famare,
     >                    facare, posifa,
     >                    hettri, aretri, filtri,
     >                    voltri,
     >                    hetqua, arequa, filqua,
     >                    cfaqua, famqua,
     >                    volqua,
     >                    lgetco, taetco,
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
c   Suivi de Frontiere : CAlcul des nouvelles Frontieres - 2
c   --                   --                   -            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . suifro . e   .   1    . 1 : pas de suivi de frontiere              .
c .        .     .        . 2x : frontiere discrete                    .
c .        .     .        . 3x : frontiere analytique                  .
c .        .     .        . 5x : frontiere cao                         .
c . ulgrfr . e   .   *    . unite logique des groupes frontieres CAO   .
c . nbfrdi . e   .   1    . nombre de frontieres discretes             .
c . geocoo . e   .sfnbso**. coordonnees des sommets de la frontiere    .
c . abscur . e   . sfnbse . abscisse curviligne des somm des segments  .
c . numnoe . e   . mcnvnf . liste des noeuds de calcul sur le bord     .
c . lignoe . e   . mcnvnf . liste lignes pour ces noeuds               .
c . abscno . e   . mcnvnf . abscisse curviligne de ces noeuds          .
c . typlig . e   . sfnbli . type de la ligne                           .
c .        .     .        . 0 : ligne ouverte, a 2 extremites          .
c .        .     .        . 1 : ligne fermee                           .
c . somseg . e   . sfnbse . liste des sommets des lignes separees par  .
c                           des 0                                      .
c . seglig . e   .0:sfnbli. pointeur dans le tableau somseg : les      .
c .        .     .        . segments de la ligne i sont aux places de  .
c .        .     .        . seglig(i-1)+1 a seglig(i)-1 inclus         .
c . nbfran . e   .   1    . nombre de frontieres analytiques           .
c . casfre . e   .13nbfran. caracteristiques des frontieres analytiques.
c .        .     .        . 1 : 1., si cylindre                        .
c .        .     .        .     2., si sphere                          .
c .        .     .        .     3., si cone par  origine, axe et angle .
c .        .     .        .     4., si cone par 2 centres et 2 rayons  .
c .        .     .        .     5., si tore                            .
c .        .     .        . de 2 a 13 :                                .
c .        .     .        . . cylindre : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              8 :     rayon                 .
c .        .     .        . . sphere   : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              8 :     rayon                 .
c .        .     .        . . cone     : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              13 :    angle en degre        .
c .        .     .        . . cone 2   : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              8 :     rayon                 .
c .        .     .        .              9,10,11:xcent2, ycent2, zcent2.
c .        .     .        .              12 :    rayon2                .
c .        .     .        .              13 :    angle en radian       .
c .        .     .        . . tore     : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              8 :     rayon de revolution   .
c .        .     .        .              12 :    rayon primaire        .
c . unst2x . e   .   1    . inverse de la taille maximale au carre     .
c . epsid2 . e   .   1    . precision relative pour carre de distance  .
c . coonoe . es  . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . noehom . e   . nbnoto . ensemble des noeuds homologues             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   3 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famare . es  . nbarto . famille des aretes                         .
c . facare . es  . nbfaar . liste des faces contenant une arete        .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . hettri . es  . nbtrto . historique de l'etat des triangles         .
c . aretri . es  .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetqua . es  . nbquto . historique de l'etat des quadrangles       .
c . arequa . es  .nbquto*4. numeros des 3 aretes des quadrangles       .
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
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
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
      parameter ( nompro = 'SFCAF2' )
c
#include "nblang.h"
#include "cofaar.h"
#include "cofatq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "front1.h"
#include "front2.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombtr.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer suifro
      integer ulgrfr(*)
      integer nbfrdi
      integer numnoe(mcnvnf), lignoe(mcnvnf)
      integer typlig(sfnbli), somseg(sfnbse), seglig(0:sfnbli)
      integer nbfran
      integer noehom(nbnoto)
      integer hetare(nbarto), somare(2,nbarto), filare(nbarto)
      integer np2are(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer cfaare(nctfar,nbfare), famare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3), filtri(nbtrto)
      integer voltri(2,nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
      integer volqua(2,nbquto)
c
      double precision unst2x, epsid2
      double precision casfre(13,nbfran)
      double precision geocoo(sfnbso,sdim)
      double precision abscur(sfnbse)
      double precision coonoe(nbnoto,sdim)
      double precision abscno(mcnvnf)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nretap, nrsset
      integer iaux, jaux, kaux
c
      integer lenoeu, larete, lequad
      integer numfro, numlig, numsur
      integer nbsomm, noeud(2), laret1(2), lesegm
      integer etan, etanp1
      integer sa1a2, sa2a3, sa3a4, sa4a1
c
      double precision coopro(3)
c
      character*6 saux
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
#ifdef _DEBUG_HOMARD_
      integer glop
      data glop /0/
#endif
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
      texte(1,4) = '(/,a6,'' SUIVI DES FRONTIERES'')'
      texte(1,5) = '(27(''=''),/)'
      texte(1,6) = '(''Nombre de frontieres discretes   :'',i8)'
      texte(1,7) = '(''Nombre de frontieres analytiques :'',i8)'
      texte(1,8) =
     > '(/,''. Examen du '',a,i10,'' (frontiere numero'',i8,'')'')'
      texte(1,9) = '(''... '',a,i10,'' a deplacer'')'
      texte(1,10) = '(''... Il est entre les '',a,i10,'' et'',i10)'
      texte(1,11) =
     > '(''. Type de frontiere analytique inconnu :'',i10)'
c
      texte(2,4) = '(/,a6,'' BOUNDARY FITTING'')'
      texte(2,5) = '(23(''=''),/)'
      texte(2,6) = '(''Number of discrete boundaries  :'',i8)'
      texte(2,7) = '(''Number of analytical boundaries:'',i8)'
      texte(2,8) =
     >'(/,''. Examination of '',a,'' #'',i10,'' (boundary #'',i8,'')'')'
      texte(2,9) = '(''... '',a,'' #'',i10,'' to move'')'
      texte(2,10) =
     > '(''... It is between '',a,'' #'',i10,'' and #'',i10)'
      texte(2,11) =
     > '(''. Unknown analytical boundary type:'',i10)'
c
#include "impr03.h"
c
c 1.4. ==> le numero de sous-etape
c
      if ( mod(suifro,5).ne.0 ) then
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
      endif
c
c 1.5. ==> le titre
c
      if ( mod(suifro,5).ne.0 ) then
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'suifro',suifro
      write (ulsort,texte(langue,6)) nbfrdi
      write (ulsort,texte(langue,7)) nbfran
#endif
c
c====
c 2. boucle sur les noeuds homologues
c    attention : rien pour le moment
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. boucle homologues ; codret', codret
#endif
c
c====
c 3. boucle sur les aretes
c    On ne s'interesse qu'aux aretes qui viennent d'etre decoupees
c    et qui font partie d'une frontiere reconnue
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. boucle aretes ; codret', codret
      write (ulsort,90002) 'nbarto', nbarto
      write (ulsort,90002) 'cosfli', cosfli
      write (ulsort,90002) 'cosfsa', cosfsa
#endif
c
      do 31 , larete = 1 , nbarto
c
        if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-2793 .or. larete.eq.-3534 ) then
            glop = 1
          else
            glop = 0
          endif
#endif
c
        if ( hetare(larete).eq.2 ) then
c
          numlig = cfaare(cosfli,famare(larete))
          numsur = cfaare(cosfsa,famare(larete))
          numfro = max(numlig,numsur)
c
          if ( numfro.gt.0 ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.gt.0 ) then
      write (ulsort,texte(langue,8)) mess14(langue,1,1), larete, numfro
        endif
#endif
c
c 3.1. ==> reperage des noeuds a bouger
c
            if ( typsfr.le.2 ) then
c
c 3.1. ==> typsfr = 1 : on est en en degre 1 ; on doit bouger le nouveau
c                       noeud P1 cree sur cette arete.
c          typsfr = 2 : on est en degre 2 et les noeuds P2 sont au
c                       milieu des noeuds P1 ; on doit bouger le
c                       noeud P2 de l'arete qui est devenu P1
c          A chaque fois, c'est la seconde extremite d'une des filles
c          de l'arete.
c
              nbsomm = 1
              laret1(1) = larete
              noeud (1) = somare(2,filare(larete))
c
c 3.2. ==> typsfr = 3 : on est en degre 2 et les noeuds P2 sont sur la
c                       frontiere ; on doit bouger les 2 noeuds P2
c                       crees sur chacune des filles de cette arete
c
            else
c
              nbsomm = 2
              laret1(1) = filare(larete)
              noeud (1) = np2are(filare(larete))
              laret1(2) = filare(larete)+1
              noeud (2) = np2are(filare(larete)+1)
c
            endif
c
c 3.2. ==> Deplacement des noeuds
c
            do 32 , iaux = 1 , nbsomm
c
c 3.2.1. ==> Memorisation des coordonnees initiales
c
              if ( codret.eq.0 ) then
c
              lenoeu = noeud (iaux)
              do 321 , jaux = 1 , sdim
                coopro(jaux) = coonoe(lenoeu,jaux)
  321         continue
c
#ifdef _DEBUG_HOMARD_
        if ( glop.gt.0 ) then
              lesegm = laret1(iaux)
        write (ulsort,texte(langue,8)) mess14(langue,1,1),
     >                                 lesegm, numfro
        write (ulsort,texte(langue,9)) mess14(langue,2,-1), lenoeu
        write (ulsort,90004) 'coo',(coonoe(lenoeu,jaux),jaux=1,sdim)
        endif
#endif
c
              endif
c
c 3.2.2. ==> Frontiere CAO
c            jaux et kaux sont les 2 noeuds voisins de lenoeu
c
              if ( mod(suifro,5).eq.0 ) then
c
                if ( codret.eq.0 ) then
c
                lesegm = laret1(iaux)
                jaux = somare(1,lesegm)
                kaux = somare(2,lesegm)
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) mess14(langue,3,-1), jaux, kaux
                write (ulsort,90002) 'frontiere', numfro
#endif
                write (ulgrfr(numfro),91010) lenoeu, jaux, kaux
c
                endif
c
c 3.2.3. ==> Frontiere discrete
c            jaux et kaux sont les 2 noeuds voisins de lenoeu
c
              elseif ( numfro.le.nbfrdi ) then
c
                if ( codret.eq.0 ) then
c
                lesegm = laret1(iaux)
                jaux = somare(1,lesegm)
                kaux = somare(2,lesegm)
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) mess14(langue,3,-1), jaux, kaux
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFSLIN', nompro
#endif
                call sfslin ( lenoeu, jaux, kaux,
     >                        numfro, unst2x, epsid2,
     >                        geocoo, abscur,
     >                        numnoe, lignoe, abscno,
     >                        typlig, somseg, seglig,
     >                        coopro,
     >                        ulsort, langue, codret)
c
                endif
c
c 3.2.4. ==> Frontiere analytique
c
              else
c
                if ( codret.eq.0 ) then
c
                kaux = numfro - nbfrdi
cc
                jaux = nint(casfre(1,kaux))
c
c 3.2.3.1. ==> Cylindre
c
                if ( jaux.eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFFA01', nompro
#endif
                  call sffa01 ( nbnoto, coopro,
     >                          lenoeu,
     >                          coonoe,
     >                          casfre(2,kaux), casfre(5,kaux),
     >                          casfre(8,kaux),
     >                          ulsort, langue, codret)
c
c 3.2.3.2. ==> Sphere
c
                elseif ( jaux.eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFFA02', nompro
#endif
                  call sffa02 ( nbnoto, coopro,
     >                          lenoeu,
     >                          coonoe,
     >                          casfre(2,kaux), casfre(8,kaux),
     >                          ulsort, langue, codret)
c
c 3.2.3.3./4. ==> Cone
c
                elseif ( jaux.eq.3 .or. jaux.eq.4 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFFA03', nompro
#endif
                  call sffa03 ( nbnoto, coopro,
     >                          lenoeu,
     >                          coonoe,
     >                          casfre(2,kaux), casfre(5,kaux),
     >                          casfre(13,kaux),
     >                          ulsort, langue, codret)
c
c 3.2.3.5. ==> Tore
c
                elseif ( jaux.eq.5 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFFA05', nompro
#endif
                  call sffa05 ( nbnoto, coopro,
     >                          lenoeu,
     >                          coonoe,
     >                          casfre(2,kaux), casfre(5,kaux),
     >                          casfre(8,kaux), casfre(12,kaux),
     >                          ulsort, langue, codret)
c
c 3.2.3.n. ==> Inconnu
c
                else
c
                  write (ulsort,texte(langue,8)) mess14(langue,1,1),
     >                                           laret1(iaux), kaux
                  write (ulsort,texte(langue,11)) jaux
                  codret = 322
c
                endif
c
              endif
c
              endif
c
c 3.2.4. ==> On realise le changement de coordonnees
c
              if ( mod(suifro,5).ne.0 ) then
c
              if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        if ( glop.gt.0 ) then
32490 format(9x,'X',19x,'Y',19x,'Z')
        write (ulsort,32490)
        write (ulsort,90004) 'ancien ',(coonoe(lenoeu,jaux),jaux=1,sdim)
        write (ulsort,90004) 'nouveau',(coopro(jaux),jaux=1,sdim)
        endif
#endif
              do 324 , jaux = 1 , sdim
                coonoe(lenoeu,jaux) = coopro(jaux)
  324         continue
c
              endif
c
              endif
c
   32       continue
c
          endif
c
        endif
c
        endif
c
   31 continue
c
c====
c 4. boucle sur les quadrangles
c    On ne s'interesse qu'aux quadrangles
c    . qui viennent d'etre decoupes soit car ils etaient actifs, soit
c      car ils etaient coupes en 3 triangles
c    . qui font partie d'une frontiere reconnue
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. boucle quadrangles ; codret', codret
#endif
c
      do 41 , lequad = 1 , nbquto
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          if ( lequad.eq.-9 .or. lequad.eq.-10 ) then
            glop = 1
          else
            glop = 0
          endif
#endif
c
        numfro = cfaqua(cosfsu,famqua(lequad))
c
        if ( numfro.gt.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lequad, numfro
#endif
c
        etanp1 = mod(hetqua(lequad),100)
cgn        write (ulsort,90002) 'etanp1', etanp1
c
        if ( ( etanp1.eq.4 ) .or.
     >       ( etanp1.ge.41 .and. etanp1.le.44) ) then
c
          etan = (hetqua(lequad)-etanp1) / 100
c
          if ( etan.eq.0 .or. ( etan.ge.31 .and. etan.le.34 ) ) then
c
c 4.1. ==> reperage des noeuds a bouger
c
            if ( typsfr.le.2 ) then
c
c 4.1. ==> typsfr = 1 : on est en en degre 1 ; on doit bouger le nouveau
c                       noeud P1 cree au centre du quadrangle
c          typsfr = 2 : on est en degre 2 et les noeuds P2 sont au
c                       milieu des noeuds P1 ; on doit bouger le
c                       nouveau noeud P1 cree au centre du quadrangle
c          ce noeud central est la seconde extremite de la 2eme ou 3eme
c          arete de l'un quelconque des quadrangles fils (cf. cmrdqu)
c
              nbsomm = 1
              iaux = lequad
              call utnmqu ( iaux, jaux,
     >                      somare, arequa, filqua )
              noeud (1) = jaux
c
c 4.2. ==> typsfr = 3 : on est en degre 2 et les noeuds P2 sont sur la
c                       frontiere ;
c                       A faire
c
            else
c
              codret = 42
c
            endif
c
c 4.2. ==> Deplacement des noeuds
c
            do 42 , iaux = 1 , nbsomm
c
c 4.2.1. ==> Memorisation des coordonnees initiales
c
              if ( codret.eq.0 ) then
c
              lenoeu = noeud (iaux)
              do 421 , jaux = 1 , sdim
                coopro(jaux) = coonoe(lenoeu,jaux)
  421         continue
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,9)) mess14(langue,2,-1), lenoeu
#endif
c
              endif
c
c 4.2.2. ==> Frontiere CAO
c
              if ( mod(suifro,5).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'surface numfro',numfro
#endif
c
                call utsoqu ( somare,
     >                        arequa(lequad,1), arequa(lequad,2),
     >                        arequa(lequad,3), arequa(lequad,4),
     >                        sa1a2, sa2a3, sa3a4, sa4a1 )
c
                write (ulgrfr(numfro),91010) lenoeu,
     >                                     sa1a2, sa2a3, sa3a4, sa4a1
c
c 4.2.3. ==> Frontiere analytique
c
              else
c
                if ( codret.eq.0 ) then
c
                kaux = numfro - nbfrdi
                jaux = nint(casfre(1,kaux))
c
c 4.2.3.1. ==> Cylindre
c
                if ( jaux.eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFFA01', nompro
#endif
                  call sffa01 ( nbnoto, coopro,
     >                          lenoeu,
     >                          coonoe,
     >                          casfre(2,kaux), casfre(5,kaux),
     >                          casfre(8,kaux),
     >                          ulsort, langue, codret)
c
c 4.2.3.2. ==> Sphere
c
                elseif ( jaux.eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFFA02', nompro
#endif
                  call sffa02 ( nbnoto, coopro,
     >                          lenoeu,
     >                          coonoe,
     >                          casfre(2,kaux), casfre(8,kaux),
     >                          ulsort, langue, codret)
c
c 4.2.3.n. ==> Inconnu
c
                else
c
                  write (ulsort,texte(langue,11)) jaux
                  codret = 422
c
                endif
c
                endif
c
              endif
c
c 4.2.4. ==> On realise le changement de coordonnees
c
              if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.gt.0 ) then
42490 format(9x,'X',19x,'Y',19x,'Z')
        write (ulsort,42490)
        write (ulsort,90004) 'ancien ',(coonoe(lenoeu,jaux),jaux=1,sdim)
        write (ulsort,90004) 'nouveau',(coopro(jaux),jaux=1,sdim)
        endif
#endif
c
              do 424 , jaux = 1 , sdim
                coonoe(lenoeu,jaux) = coopro(jaux)
  424         continue
c
              endif
c
   42       continue
c
          endif
c
        endif
c
        endif
c
        endif
c
   41 continue
c
c====
c 5. La fin
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
