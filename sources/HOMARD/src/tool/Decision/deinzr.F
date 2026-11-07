      subroutine deinzr ( nbzord, cazord,
     >                    coonoe, dimcst, coocst,
     >                    somare, hetare,
     >                    nozone, arsupp, arindi,
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
c traitement des DEcisions - INitialisation de l'indicateur
c                --          --
c                                defini par des Zones de Raffinement
c                                               -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbzord . e   .    1   . nombre de zones a raffiner/deraffiner      .
c . cazord . e   .  20 *  . caracteristiques zone a raffiner/deraffiner.
c .        .     . nbzord . 1 : >0 si a raffiner, <0 si a deraffiner   .
c .        .     .        . . si rectangle :                           .
c .        .     .        . 1 : +-1                                    .
c .        .     .        . de 2 a 5 : xmin, xmax, ymin, ymax          .
c .        .     .        . . si parallelepipede :                     .
c .        .     .        . 1 : +-2                                    .
c .        .     .        . de 2 a 7 : xmin, xmax, ymin, ymax          .
c .        .     .        .            zmin, zmax                      .
c .        .     .        . . si disque :                              .
c .        .     .        . 1 : +-3                                    .
c .        .     .        . de  8 a 10 : rayon, xcentr, ycentr         .
c .        .     .        . . si sphere :                              .
c .        .     .        . 1 : +-4                                    .
c .        .     .        . de  8 a 11 : rayon, xcentr, ycentr, zcentr .
c .        .     .        . . si cylindre :                            .
c .        .     .        . 1 : +-5                                    .
c .        .     .        . 8          : rayon                         .
c .        .     .        . de 12 a 14 : xaxe, yaxe, zaxe              .
c .        .     .        . de 15 a 17 : xbase, ybase, zbase           .
c .        .     .        . 18         : hauteur                       .
c .        .     .        . . si disque perce :                        .
c .        .     .        . 1 : +-6                                    .
c .        .     .        . de  9 a 10 : xcentr, ycentr                .
c .        .     .        . 19         : rayon interieur               .
c .        .     .        . 20         : rayon exterieur               .
c .        .     .        . . si tuyau :                               .
c .        .     .        . 1 : +-7                                    .
c .        .     .        . de 12 a 14 : xaxe, yaxe, zaxe              .
c .        .     .        . de 15 a 17 : xbase, ybase, zbase           .
c .        .     .        . 18         : hauteur                       .
c .        .     .        . 19         : rayon interieur               .
c .        .     .        . 20         : rayon exterieur               .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c . dimcst . e   .    1   . dimension de la coordonnee constante       .
c .        .     .        . eventuelle, 0 si toutes varient            .
c . coocst . e   .   11   . 1 : coordonnee constante eventuelle        .
c .        .     .        . 2, 3, 4 : xmin, ymin, zmin                 .
c .        .     .        . 5, 6, 7 : xmax, ymax, zmax                 .
c .        .     .        . 8, 9, 10 : -1 si constant, max-min sinon   .
c .        .     .        . 11 : max des (max-min)                     .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . nozone . aux . nbnoto . auxiliaire pour le transfert zone/noeud    .
c . arsupp .  s  . nbarto . support pour les aretes                    .
c . arindi .  s  . nbarto . valeurs entieres pour les aretes           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEINZR' )
c
#include "nblang.h"
c
      integer nbmcle
      parameter ( nbmcle = 20 )
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer nbzord
      integer somare(2,nbarto), hetare(nbarto)
      integer dimcst
      integer nozone(nbnoto)
      integer arsupp(nbarto), arindi(nbarto)
c
      double precision cazord(nbmcle,nbzord)
      double precision coonoe(nbnoto,sdim)
      double precision coocst(11)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
      integer nrzord, tyzord, tyzosg
c
      character*8 saux08(nbmcle)
c
      double precision daux
      double precision rext2, rint2
c
      logical afaire
      logical mccod2(nbmcle)
c
      integer nbmess
      parameter (nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
      character*13 messag(nblang,8)
c
c 0.5. ==> initialisations
c
#ifdef _DEBUG_HOMARD_
      character*1 saux01(3)
      data saux01 / 'X', 'Y', 'Z' /
#endif
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de zones a raffiner :'',i8)'
      texte(1,5) = '(/,7x,''Zone de raffinement numero'',i3)'
      texte(1,6) = '(/,7x,''Zone de deraffinement numero'',i3)'
      texte(1,7) = '(10x,''Type de la zone : '',a)'
      texte(1,8) = '(10x,''Forme de zone inconnue :'',g15.7)'
      texte(1,9) = '(''Prise en compte du noeud '',i10,3g15.7)'
c
      texte(2,4) = '(''Number of zones to refine :'',i8)'
      texte(2,5) = '(/,7x,''Refinement zone #'',i3)'
      texte(2,6) = '(/,7x,''Unrefinement zone #'',i3)'
      texte(2,7) = '(10x,''Type of zone : '',a)'
      texte(2,8) = '(10x,''Unknown zone shape :'',g15.7)'
      texte(2,9) = '(''OK for node # '',i10,3g15.7)'
c
c                    1234567890123
      messag(1,1) = 'Rectangle    '
      messag(1,2) = 'Parallepipede'
      messag(1,3) = 'Disque       '
      messag(1,4) = 'Sphere       '
      messag(1,5) = 'Cylindre     '
      messag(1,6) = 'Disque perce '
      messag(1,7) = 'Tuyau        '
c
      messag(2,1) = 'Rectangle    '
      messag(2,2) = 'Parallepiped '
      messag(2,3) = 'Disk         '
      messag(2,4) = 'Sphere       '
      messag(2,5) = 'Cylindre     '
      messag(2,6) = 'Disk         '
      messag(2,7) = 'Pipe         '
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbzord
      write (ulsort,90002) 'nbnoto', nbnoto
      write (ulsort,90002) 'sdim  ', sdim
      write (ulsort,90002) 'dimcst', dimcst
      if ( dimcst.ne.0 ) then
      write (ulsort,90104) saux01(dimcst)//' constant', coocst(dimcst+1)
      endif
#endif
c
#include "impr03.h"
c
c====
c 2. les zones
c====
c 2.1. ==> verifications
c
      codret = 0
c
      if ( codret.eq.0 ) then
c
      do 21 , nrzord = 1 , nbzord
        if ( cazord(1,nrzord).gt.0.d0 ) then
          tyzosg = 1
        else
          tyzosg = -1
        endif
        tyzord = nint(abs(cazord(1,nrzord)))
        if ( tyzord.lt.1 .or. tyzord.gt.7 ) then
          write (ulsort,texte(langue,5+(1-tyzosg)/2)) nrzord
          write (ulsort,texte(langue,8)) cazord(1,nrzord)
          codret = codret + 1
        endif
   21 continue
c
      endif
c
c 2.2. ==> impressions
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. impressions ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      saux08( 2) = 'X min   '
      saux08( 3) = 'X max   '
      saux08( 4) = 'Y min   '
      saux08( 5) = 'Y max   '
      saux08( 6) = 'Z min   '
      saux08( 7) = 'Z max   '
      saux08( 8) = 'Rayon   '
      saux08( 9) = 'X centre'
      saux08(10) = 'Y centre'
      saux08(11) = 'Z centre'
      saux08(12) = 'X axe   '
      saux08(13) = 'Y axe   '
      saux08(14) = 'Z axe   '
      saux08(15) = 'X base  '
      saux08(16) = 'Y base  '
      saux08(17) = 'Z base  '
      saux08(18) = 'Hauteur '
      saux08(19) = 'Rayon In'
      saux08(20) = 'Rayon Ex'
c
      do 22 , nrzord = 1 , nbzord
c
        if ( cazord(1,nrzord).gt.0.d0 ) then
          tyzosg = 1
        else
          tyzosg = -1
        endif
        tyzord = nint(abs(cazord(1,nrzord)))
        write (ulsort,texte(langue,5+(1-tyzosg)/2)) nrzord
        write (ulsort,texte(langue,7)) messag(langue,tyzord)
c
        do 221 , iaux = 1 , nbmcle
          mccod2(iaux) = .false.
  221   continue
c
        if ( tyzord.eq.1 ) then
          do 2211 , iaux = 2 , 5
            mccod2(iaux) = .true.
 2211     continue
        elseif ( tyzord.eq.2 ) then
          do 2212 , iaux = 2 , 7
            mccod2(iaux) = .true.
 2212     continue
        elseif ( tyzord.eq.3 ) then
          do 2213 , iaux = 8 , 10
            mccod2(iaux) = .true.
 2213     continue
        elseif ( tyzord.eq.4 ) then
          do 2214 , iaux = 8 , 11
            mccod2(iaux) = .true.
 2214     continue
        elseif ( tyzord.eq.5 ) then
          mccod2(8) = .true.
          do 2215 , iaux = 12 , 18
            mccod2(iaux) = .true.
 2215     continue
        elseif ( tyzord.eq.6 ) then
          mccod2(9) = .true.
          mccod2(10) = .true.
          mccod2(19) = .true.
          mccod2(20) = .true.
        else
          do 2217 , iaux = 12 , 20
            mccod2(iaux) = .true.
 2217     continue
        endif
c
        do 222 , iaux = 2 , nbmcle
          if ( mccod2(iaux) ) then
            write (ulsort,90104) '                 '//saux08(iaux),
     >                            cazord(iaux,nrzord)
          endif
  222   continue
c
   22 continue
c
      endif
c
c====
c 3. Creation d'un indicateur portant sur les aretes : une arete est a
c    decouper si et seulement si ses deux extremites sont dans la meme
c    zone.
c    On parcourt toutes les zones et on marque les noeuds qui sont
c    a l'interieur de la zone. Puis on note les aretes dont les noeuds
c    sont dans la zone.
c    Remarque : cet algorithme de decodage n'est pas hyper performant
c    si on a plusieurs zones. Mais c'est une maniere simple de gerer
c    les recouvrements de zones.
c    Remarque : attention a ne marquer que les aretes actives, comme si
c    on avait produit un veritable indicateur d'erreur
c
c    Exemple 1 :
c           |                |            |
c           |             ooo|oooo        |
c       ....|.............o..|...o........|...
c       .   |             o  |   o        |  .
c     ------A-------------o--B---o--------C-----
c       .   |             o  |   o        |  .
c       .   |             o  |   o        |  .
c       ....|.............o..|...o........|...
c           |             o  |   o        |
c           |             o  |   o        |
c     ------D-------------o--E---o--------F-----
c           |             o  |   o        |
c           |             ooo|oooo        |
c           |                |            |
c     La zone . contient les noeuds A, B et C :
c               ==> les aretes AB et BC sont a couper
c     La zone o contient les noeuds B et E :
c               ==> l'arete BE est a couper
c
c    Exemple 2 :
c           |                |            |
c           |                |            |
c       ....|................|............|...
c       .   |                |            |  .
c     ------A----------------B------------C-----
c       .   |                |           |  .
c       .   |             ooo|oooo        |  .
c       ....|.............o..|...o........|...
c           |             o  |   o        |
c           |             o  |   o        |
c     ------D-------------o--E---o--------F-----
c           |             o  |   o        |
c           |             ooo|oooo        |
c           |                |            |
c     La zone . contient les noeuds A, B et C :
c               ==> les aretes AB et BC sont a couper
c     La zone o contient le noeud E :
c               ==> aucune arete n'est a couper
c
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. creation indicateur ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
cgn      print 1789,0,0.,cazord(2,2),cazord(3,2),cazord(4,2)
c
c 3.1. ==> A priori, on suppose qu'aucune arete n'est concernee
c
      do 31 , iaux = 1, nbarto
c
        arsupp(iaux) = 0
        arindi(iaux) = 0
c
   31 continue
c
c 3.2. ==> Exploration des differentes zones
c          Quand la zone a ete declaree 3D mais que l'espace est 2D,
c          on change de categorie
c
      do 32 , nrzord = 1 , nbzord
c
        if ( cazord(1,nrzord).gt.0.d0 ) then
          tyzosg = 1
        else
          tyzosg = -1
        endif
        tyzord = nint(abs(cazord(1,nrzord)))
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5+(1-tyzosg)/2)) nrzord
        write (ulsort,texte(langue,7)) messag(langue,tyzord)
#endif
c
c 3.2.0. ==> A priori, aucun noeud n'est concerne
c
        do 320 , iaux = 1, nbnoto
          nozone(iaux) = 0
  320   continue
c
c 3.2.1. ==> Filtrage sur une boite rectangulaire
c
        if ( tyzord.eq.1 ) then
c
          do 321 , iaux = 1, nbnoto
c
cgn            write(ulsort,90104) 'X',
cgn     >      coonoe(iaux,1), cazord(2,nrzord),cazord(3,nrzord)
cgn            write(ulsort,90104) 'Y',
cgn     >      coonoe(iaux,2), cazord(4,nrzord),cazord(5,nrzord)
cgn      write (ulsort,90014)iaux, (coonoe(iaux,jaux),jaux=1,sdim)
            afaire = .true.
            if ( coonoe(iaux,1).lt.cazord(2,nrzord) ) then
              afaire = .false.
            elseif ( coonoe(iaux,1).gt.cazord(3,nrzord) ) then
              afaire = .false.
            endif
            if ( afaire .and. sdim.ge.2 ) then
              if ( coonoe(iaux,2).lt.cazord(4,nrzord) ) then
                afaire = .false.
              elseif ( coonoe(iaux,2).gt.cazord(5,nrzord) ) then
                afaire = .false.
              endif
            endif
            if ( afaire ) then
#ifdef _DEBUG_HOMARD_
              write(ulsort,texte(langue,9)) iaux,
     >        (coonoe(iaux,jaux),jaux=1,sdim)
#endif
              nozone(iaux) = tyzosg
            endif
c
  321     continue
c
c 3.2.2. ==> Filtrage sur une boite parallelepipedique
c
        elseif ( tyzord.eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINZ0', nompro
#endif
          call deinz0 ( tyzosg,
     >                  cazord(2,nrzord), cazord(3,nrzord),
     >                  cazord(4,nrzord), cazord(5,nrzord),
     >                  cazord(6,nrzord), cazord(7,nrzord),
     >                  coonoe, dimcst, coocst,
     >                  nozone,
     >                  ulsort, langue, codret )
c
c 3.2.3. ==> Filtrage sur une boite circulaire / circulaire percee
c
        elseif ( tyzord.eq.3 .or. tyzord.eq.6 ) then
c
          if ( tyzord.eq.3 ) then
            rint2 = -1.d0
            rext2 = cazord(8,nrzord)*cazord(8,nrzord)
          else
            rint2 = cazord(19,nrzord)*cazord(19,nrzord)
            rext2 = cazord(20,nrzord)*cazord(20,nrzord)
          endif
cgn      write (ulsort,90004) 'rext2', rext2
cgn      write (ulsort,90004) 'rint2', rint2
cgn      write (ulsort,90004) 'centre', cazord( 9,nrzord),cazord(10,nrzord)
c
          do 323 , iaux = 1, nbnoto
c
            daux =   ( coonoe(iaux,1)-cazord( 9,nrzord) )
     >             * ( coonoe(iaux,1)-cazord( 9,nrzord) )
            if ( sdim.ge.2 ) then
              daux = daux
     >             + ( coonoe(iaux,2)-cazord(10,nrzord) )
     >             * ( coonoe(iaux,2)-cazord(10,nrzord) )
            endif
cgn      write (ulsort,90014)iaux,(coonoe(iaux,jaux),jaux=1,sdim)
c
            if ( daux.ge.rint2 .and. daux.le.rext2 ) then
#ifdef _DEBUG_HOMARD_
              write(ulsort,texte(langue,9)) iaux,
     >        (coonoe(iaux,jaux),jaux=1,sdim)
#endif
              nozone(iaux) = tyzosg
            endif
c
  323     continue
c
c 3.2.4. ==> Filtrage sur une boite spherique
c
        elseif ( tyzord.eq.4 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINZ1', nompro
#endif
          call deinz1 ( tyzosg,
     >                  cazord(8,nrzord),
     >                  cazord(9,nrzord), cazord(10,nrzord),
     >                  cazord(11,nrzord),
     >                  coonoe, dimcst, coocst,
     >                  nozone,
     >                  ulsort, langue, codret )
c
c 3.2.5. ==> Filtrage sur une boite cylindrique/tuyau
c
        elseif ( tyzord.eq.5 .or. tyzord.eq.7 ) then
c
          if ( tyzord.eq.5 ) then
            iaux = 8
            daux = -1.d0
          else
            iaux = 20
            daux = cazord(19,nrzord)
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINZ2', nompro
#endif
          call deinz2 ( tyzosg,
     >                  cazord(iaux,nrzord), daux,
     >                  cazord(18,nrzord),
     >                  cazord(12,nrzord), cazord(13,nrzord),
     >                  cazord(14,nrzord),
     >                  cazord(15,nrzord), cazord(16,nrzord),
     >                  cazord(17,nrzord),
     >                  coonoe, dimcst, coocst,
     >                  nozone,
     >                  ulsort, langue, codret )
c
        endif
c
c 3.2.9. ==> Transfert aux aretes
c
cgn      write(ulsort,4000) (iaux, nozone(iaux) , iaux = 1, nbnoto)
        do 329 , iaux = 1, nbarto
c
          if ( nozone(somare(1,iaux)).eq.tyzosg .and.
     >         nozone(somare(2,iaux)).eq.tyzosg ) then
cgn            write (ulsort,*) 'arete ',iaux,
cgn     >      ' de ',somare(1,iaux),' a ',somare(2,iaux)
            if ( mod(hetare(iaux),10).eq.0 ) then
              arsupp(iaux) = 1
              arindi(iaux) = tyzosg
            endif
          endif
c
  329   continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'fin de 32 ; codret', codret
#endif
c
   32 continue
c
      endif
c
c====
c 4. la fin
c====
c
cgn      write(ulsort,4000) (iaux, arindi(iaux) , iaux = 1, nbarto)
cgn 4000 format(5(i4,' :',i2))
      if ( codret.ne.0 ) then
c
#include "envex2.h"
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
