      subroutine ppxma5 ( lgtcmx, tbcoli, ncotbl,
     >                    infsup, typcof, typcop, typbor, optnoe,
     >                    porpay, zoom, triedr,
     >                    degre, sdim, mailet,
     >                    titre1, titre2,
     >                    nbarvi, nbtrvi, nbquvi,
     >                    nnarvi, nntrvi, nnquvi,
     >                    coopro, posini,
     >                    nnoeca, nareca, ntreca, nqueca,
     >                    fotrva, foquva, vafomi, vafoma, vafodi,
     >                    ulvecs, nomflo, lnomfl, ulsost,
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
c     Post-Processeur - format Xfig - MAillage - phase 5
c     -    -                   -      --               -
c voir http://www.xfig.org/userman/fig-format.html
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgtcmx . e   .   1    . longueur maximale de la table de couleur   .
c . tbcoli . e   .        . table de couleur                           .
c .        .     . (-3:   . Les immuables sont :                       .
c .        .     . lgtcmx).       -3 : defaut de xfig                  .
c .        .     .        .       -2 : noir                            .
c .        .     .        .       -1 : blanc                           .
c .        .     .        . lgtcmx-2 : rouge pour les aretes de bord   .
c .        .     .        . lgtcmx-1 : un gris pale pour les familles  .
c .        .     .        .            libres et le triedre            .
c .        .     .        .  lgtcmx : un vert pale (cadre de zoom)     .
c . ncotbl . e   .   1    . nombre de couleurs dans la table           .
c . infsup . e   .   1    . information supplementaire a afficher      .
c .        .     .        . 0 : aucune                                 .
c .        .     .        . 1 : numero homard des noeuds               .
c .        .     .        . 2 : numero du calcul des noeuds            .
c .        .     .        . 3 : numero homard des faces                .
c .        .     .        . 4 : numero du calcul des faces             .
c .        .     .        . 5 : numero homard des aretes               .
c .        .     .        . 6 : numero du calcul des aretes            .
c .        .     .        . np : choix n et choix p simultanement      .
c . typcof . e   .   1    . type de coloriage des faces                .
c .        .     .        .   0 : incolore transparent                 .
c .        .     .        .   1 : incolore opaque                      .
c .        .     .        .   2 : famille HOMARD                       .
c .        .     .        .   3 : famille HOMARD, sans orientation     .
c .        .     .        .   4/5 : idem 2/3, en niveau de gris        .
c .        .     .        . +-6 : couleur selon un champ, echelle auto..
c .        .     .        . +-7 : idem avec echelle fixe               .
c .        .     .        . +-8/+-9 : idem +-6/+-7, en niveau de gris  .
c .        .     .        .  10 : niveau                               .
c . typcop . e   .   1    . type de coloriage du perimetre des faces   .
c .        .     .        .   0 : pas de trace                         .
c .        .     .        .   2 : noir                                 .
c .        .     .        .   4 : niveau de la face                    .
c . typbor . e   .   1    . type d'affichage du bord                   .
c .        .     .        .   0 : pas de trace                         .
c .        .     .        .   1 : trace en rouge                       .
c .        .     .        .   2 : trace en noir                        .
c . optnoe . e   .   1    . 0 : rien de special                        .
c .        .     .        . 1 : trace d'un rond vide sur chaque noeud  .
c .        .     .        . 2 : trace d'un rond plein sur chaque noeud .
c . porpay . e   .   1    . 0 : portrait/paysage selon la taille       .
c .        .     .        . 1 : portrait                               .
c .        .     .        . 2 : paysage                                .
c . zoom   . e   .   1    . vrai ou faux selon zoom ou non             .
c . triedr . e   .   1    . 0 : pas de trace du triedre                .
c .        .     .        . 1 : trace du triedre                       .
c . degre  . e   .   1    . degre du maillage                          .
c . sdim   . e   .   1    . dimension du maillage initial              .
c . mailet . e   .   1    . maillage etendu                            .
c . titre1 . e   .  char  . premiere ligne de titre                    .
c . titre2 . e   .  char  . seconde ligne de titre                     .
c . nbarvi . e   .   1    . nombre d'aretes visualisables              .
c . nbtrvi . e   .   1    . nombre triangles visualisables             .
c . nbquvi . e   .   1    . nombre de quadrangles visualisables        .
c . nnarvi . e   .6*nbarvi. numero des aretes a visualiser             .
c .        .     .        . 1 : niveau de l'arete a afficher           .
c .        .     .        . 2 : numero HOMARD de l'arete               .
c .        .     .        . 3, 4 : numero des 2 noeuds                 .
c .        .     .        . 5 : 0, si isolee, 1 si bord                .
c .        .     .        . 6 : numero de l'eventuel noeud P2          .
c . nntrvi . e   .10nbtrvi. 1 : niveau du triangle a afficher          .
c .        .     .        . 2 : numero HOMARD du triangle              .
c .        .     .        . 3, 4, 5 : numeros des noeuds p1            .
c .        .     .        . 6 : famille du triangle                    .
c .        .     .        . 7, 8, 9 : numeros des noeuds p2            .
c .        .     .        . 10 : numero du noeud interne               .
c . nnquvi . e   .12nbquvi. 1 : niveau du quadrangle a afficher        .
c .        .     .        . 2 : numero HOMARD du quadrangle            .
c .        .     .        . 3, 4, 5, 6 : numeros des noeuds p1         .
c .        .     .        . 7 : famille du quadrangle                  .
c .        .     .        . 8, 9, 10, 11 : numeros des noeuds p2       .
c .        .     .        . 12 : numero du noeud interne               .
c . coopro . e   .   3*   . coordonnees projetees de :                 .
c .        .     .nbnot+12. le triedre : -8:O ; -9:I ; -10:J ; -11:K   .
c .        .     .        . la fenetre de zoom : de -7 a 0 en 3D ou    .
c .        .     .        .                      de -3 a 0 en 2D       .
c .        .     .        . les noeuds de 1 a nbnoto                   .
c . posini . aux . nbquvi . tableau auxiliaire de renumerotation des   .
c .        .     .+nbtrvi . faces en fonction de l'affichage           .
c . nnoeca . e   . renoto . noeuds en entree dans le calcul            .
c . nareca . e   . rearto . nro des aretes dans le calcul en entree    .
c . ntreca . e   . retrto . nro des triangles dans le calcul en entree .
c . nqueca . e   . requto . nro des quads dans le calcul en entree     .
c . fotrva . e   . nbtrvi . fonctions triangles : valeur               .
c . foquva . e   . nbquvi . fonctions quadrangles : valeur             .
c . vafomi . e   .   1    . minimum de l'echelle de la fonction        .
c . vafoma . e   .   1    . maximum de l'echelle de la fonction        .
c . ulvecs . e   .   1    . unite logique du fichier PostScript        .
c . nomflo . e   .   *    . nom local du fichier                       .
c . lnomfl . e   .    1   . longueur du nom local du fichier           .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'PPXMA5' )
c
#include "nblang.h"
#include "nuvers.h"
#include "fracta.h"
#include "fractb.h"
#include "fractc.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "impr02.h"
#include "nombno.h"
#include "nomber.h"
#include "nbutil.h"
#include "infini.h"
c
c 0.3. ==> arguments
c
      character*(*) titre1, titre2
c
      integer lgtcmx
      integer tbcoli(-3:lgtcmx)
      integer infsup, typcof, typcop, typbor, optnoe
      integer porpay, triedr
      integer ulvecs, lnomfl, ulsost
      integer nbarvi, nbtrvi, nbquvi
      integer nnarvi(6,nbarvi)
      integer nntrvi(10,nbtrvi)
      integer nnquvi(12,nbquvi)
      integer posini(nbtrvi+nbquvi)
      integer nnoeca(renoto)
      integer nareca(rearto), ntreca(retrto), nqueca(requto)
      integer degre, sdim, mailet
      integer nbface
c
      logical zoom
c
      double precision coopro(3,-11:nbnoto)
      double precision vafomi, vafoma
      double precision fotrva(*), foquva(*)
      character*(*) nomflo
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nuface, nutr, nuqu
      integer noeud, noeud1, noeud2
      integer iaux, jaux, kaux, laux
      integer infsu1, infsu2, infsu3
      integer iaux1, iaux2, iaux3, iaux4, iaux5
      integer iaux6
      integer adtrav
      integer tabaux(20)
      integer lno(9), lglesn, lenoeu
      integer ncotbl
      integer lacoul, leremp
c
      double precision vafodi
      double precision daux
      double precision daux1, daux2, daux3, daux4
      double precision dcotbl
      double precision factx, facty
      double precision decalx, decaly
      double precision tabaur(20)
c
      character*7 saux07
      character*8 ntrava
      character*9 saux09
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c_______________________________________________________________________
c
c====
c 1. Messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Fonction sur les '',a)'
      texte(1,5) = '(a,'' : min = '',g12.5,'', max = '',g12.5)'
c
      texte(2,4) = '(''Function over '',a)'
      texte(2,5) = '(a,'' : min = '',g12.5,'', max = '',g12.5)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. Prealables
c====
c 2.1. ==> Informations sur les fonctions
c
      if ( abs(typcof).ge.6 .and. abs(typcof).le.9 ) then
        iaux = 8
        write (ulsort,texte(langue,4)) mess14(langue,3,iaux)
        write (ulsort,texte(langue,5)) 'Fonction', vafomi, vafoma
        if ( ulsost.ne.ulsort ) then
          write (ulsost,texte(langue,4)) mess14(langue,3,iaux)
          write (ulsost,texte(langue,5)) 'Fonction', vafomi, vafoma
        endif
c   Reajustement pour tenir compte des erreurs d'arrondi aux bornes
        if ( abs(typcof).eq.6 .or. abs(typcof).eq.8 ) then
          daux = vafoma - vafomi
          vafomi = vafomi - daux*1.d-6
          vafoma = vafoma + daux*1.d-6
        endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) 'Fonction', vafomi, vafoma
        if ( ulsost.ne.ulsort ) then
          write (ulsost,texte(langue,5)) 'Fonction', vafomi, vafoma
        endif
#endif
      endif
c
c 2.2. ==> Informations supplementaires
c
cgn       ulve = ulvecs
cgn       do 1789 , nbface = 1,nbtrvi
cgn       ulvecs = 20 +nbface
      nbface = nbtrvi + nbquvi
c
cgn      print *,infsup
      infsu1 = mod(infsup,10)
      if ( infsup.ge.10 ) then
        iaux = ( infsup-infsu1 ) / 10
        infsu2 = mod(iaux,10)
        if ( iaux.ge.10 ) then
          infsu3 = ( iaux-infsu2 ) / 10
        else
          infsu3 = 0
        endif
      else
        infsu2 = 0
        infsu3 = 0
      endif
cgn      print *,'infsu1, infsu2, infsu3 = ', infsu1, infsu2, infsu3
c
c 2.3. ==> Extrema des coordonnees
c
      daux1 = vinfpo
      daux2 = vinfne
      daux3 = vinfpo
      daux4 = vinfne
cgn       print texte(langue,5), 'X', daux1, daux2
cgn       print texte(langue,5), 'Y', daux3, daux4
c
      do 231 , jaux = 1 , nbarvi
        lno(1) = nnarvi(3,jaux)
        lno(2) = nnarvi(4,jaux)
        do 2311 , iaux = 1 , 2
          daux1 = min(daux1, coopro(1,lno(iaux)))
          daux2 = max(daux2, coopro(1,lno(iaux)))
          daux3 = min(daux3, coopro(2,lno(iaux)))
          daux4 = max(daux4, coopro(2,lno(iaux)))
 2311   continue
  231 continue
cgn       if ( nbarvi.gt.0 ) print texte(langue,5), 'X', daux1, daux2
cgn       if ( nbarvi.gt.0 ) print texte(langue,5), 'Y', daux3, daux4
c
      do 232 , nuface = 1 , nbface
        if ( nuface.le.nbtrvi ) then
          lno(1) = nntrvi(3,nuface)
          lno(2) = nntrvi(4,nuface)
          lno(3) = nntrvi(5,nuface)
          lglesn = 3
        else
          nuqu = nuface - nbtrvi
          lno(1) = nnquvi(3,nuqu)
          lno(2) = nnquvi(4,nuqu)
          lno(3) = nnquvi(5,nuqu)
          lno(4) = nnquvi(5,nuqu)
          lglesn = 4
        endif
        do 2321 , iaux = 1 , lglesn
cgn          print *,coopro(1,lno(iaux)), coopro(2,lno(iaux))
          daux1 = min(daux1, coopro(1,lno(iaux)))
          daux2 = max(daux2, coopro(1,lno(iaux)))
          daux3 = min(daux3, coopro(2,lno(iaux)))
          daux4 = max(daux4, coopro(2,lno(iaux)))
 2321   continue
  232 continue
c
cgn      if ( nuface.gt.0 )  print texte(langue,5), 'X', daux1, daux2
cgn      if ( nuface.gt.0 )  print texte(langue,5), 'Y', daux3, daux4
c
      if ( zoom ) then
c
        if ( sdim.le.2 ) then
          jaux = -3
        else
          jaux = -7
        endif
        do 2331 , iaux = jaux , 0
          daux1 = min(daux1, coopro(1,iaux))
          daux2 = max(daux2, coopro(1,iaux))
          daux3 = min(daux3, coopro(2,iaux))
          daux4 = max(daux4, coopro(2,iaux))
 2331   continue
cgn        print texte(langue,5), 'apres zoom, X', daux1, daux2
cgn        print texte(langue,5), 'apres zoom, Y', daux3, daux4
c
      endif
c
      if ( triedr.eq.1 ) then
c
        if ( sdim.le.2 ) then
          jaux = -10
        else
          jaux = -11
        endif
        do 2341 , iaux = jaux , -8
          daux1 = min(daux1, coopro(1,iaux))
          daux2 = max(daux2, coopro(1,iaux))
          daux3 = min(daux3, coopro(2,iaux))
          daux4 = max(daux4, coopro(2,iaux))
 2341   continue
cgn        print texte(langue,5), 'apres triedre, X', daux1, daux2
cgn        print texte(langue,5), 'apres triedre, Y', daux3, daux4
c
      endif
c
c 2.4. ==> Facteur de proportionnalite
c      Dans Xfig, un rectangle de 27x18 cm, donc imprimable au
c      format A4, correspond a des coordonnees 12150x8100, soit un
c      rapport de 450.
c      La figure est dans le rectangle :
c             daux1 <= X <= daux2
c             daux3 <= Y <= daux4
c      Si on n'a pas choisi a priori d'orientation de la page, on la
c      determine en fonction de la taille de la figure.
c      On privilegie le paysage ...
c
cgn      print texte(langue,5), '==> X', daux1, daux2
cgn      print texte(langue,5), '==> Y', daux3, daux4
      if ( porpay.eq.0 ) then
        if ( (daux4-daux3).gt.1.1d0*(daux2-daux1) ) then
          porpay = 1
        else
          porpay = 2
        endif
      endif
c
c      On ramene la figure dans le cadre 27x18, selon l'orientation
c      demandee :
c     Portrait :
      if ( porpay.eq.1 ) then
        if ( (daux2-daux1).lt.1.d-10 ) then
          facty = 27.d0 / (daux4-daux3)
          factx = facty
        elseif ( (daux4-daux3).lt.1.d-10 ) then
          factx = 18.d0 / (daux2-daux1)
        else
          factx = 18.d0 / (daux2-daux1)
          facty = 27.d0 / (daux4-daux3)
          factx = min(factx,facty)
        endif
c     Paysage :
      else
        if ( (daux2-daux1).lt.1.d-10 ) then
          facty = 18.d0 / (daux4-daux3)
          factx = facty
        elseif ( (daux4-daux3).lt.1.d-10 ) then
          factx = 27.d0 / (daux2-daux1)
        else
          factx = 27.d0 / (daux2-daux1)
          facty = 18.d0 / (daux4-daux3)
          factx = min(factx,facty)
        endif
      endif
cgn      print *, 'factx =', factx
cgn      print *, 'facty =', facty
c
c     On termine par le coefficient general
c     Attention : il faut symetriser en Y ... mystere xfig ...
c
      factx = 450.d0*factx
      facty = -factx
cgn      print *, factx
c
c     On cree un decalage pour que le coin soit en (0,0)
c
      decalx = -daux1
      decaly = -daux4
c
c====
c 3. impression des en-tetes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. impression des en-tetes ; codret', codret
#endif
c
      write(ulvecs,30000) nuvers
c
      if ( porpay.eq.1 ) then
        saux09 = 'Portrait '
      else
        saux09 = 'Landscape'
      endif
      write(ulvecs,30010) saux09
      write(ulvecs,30020) nuvers, titre1, titre2
      write(ulvecs,30030)
      write(ulvecs,30031)
     > nomflo(1:lnomfl)//' > '//nomflo(1:lnomfl-3)//'png'
c
c====
c 4. impression du maillage : les faces
c    attention : on doit placer les faces dans l'ordre
c    d'affichage qui a ete determine par pppma3. Il faut donc
c    explorer les caracteristiques de chaque face, contenues dans
c    nntrvi et/ou nnquvi, via l'indirection donnee par le tableau
c    posini.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. impression des faces ; codret', codret
      write (ulsort,90002) 'nbface',nbface
#endif
c
      if ( nbface.ne.0 ) then
c
      write(ulvecs,31002) nbface
c
      dcotbl = dble(ncotbl)
c
      do 41 , nuface = 1 , nbface
c
cgn        write (ulsort,90112) 'posini', nuface, posini(nuface)
        if ( posini(nuface).le.nbtrvi ) then
          nutr = posini(nuface)
          nuqu = 0
        else
          nutr = 0
          nuqu = posini(nuface)-nbtrvi
        endif
c
c 4.1. ==> couleur de la face
c
c de 6 a 9 ou de -9 a -6 : selon les valeurs de la fonction
c             6 ou 7 : couleur de bleu a rouge
c             8 ou 9 : niveau de gris (de blanc pour les faibles valeurs
c                      a noir pour les grandes)
c
        if ( abs(typcof).ge.6 .and. abs(typcof).le.9 ) then
c
          if ( abs(typcof).le.7 ) then
            leremp = 20
          else
            lacoul = tbcoli(-1)
          endif
c
          if ( nutr.gt.0 ) then
            daux1 = fotrva(nutr)
          else
            daux1 = foquva(nuqu)
          endif
c
          if ( daux1.ge.vafoma ) then
            if ( abs(typcof).ge.8 ) then
              leremp = 0
            else
              lacoul = tbcoli(ncotbl)
            endif
          elseif ( daux1.le.vafomi ) then
            if ( abs(typcof).ge.8 ) then
              leremp = 20
            else
              lacoul = tbcoli(0)
            endif
          else
            if ( abs(typcof).ge.8 ) then
              daux1 = 20.d0 * ( vafoma - daux1 ) * vafodi
              leremp = nint(daux1)
cgn              print *,leremp
            else
              daux1 = dcotbl * ( daux1 -vafomi ) * vafodi
              jaux = nint(daux1)
              lacoul = tbcoli(jaux)
            endif
          endif
c
c 2 : selon la famille, avec orientation
c 3 : selon la famille, sans orientation
c          couleur -1 : famille 1 (les libres)
c          couleur  0 : famille 2 et celles d'orientation autre,
c          couleur  1 : famille suivante et celles d'orientation autre,
c           etc
c
        elseif ( typcof.ge.2 .and. typcof.le.3 ) then
c
          leremp = 20
          if ( nutr.gt.0 ) then
            if ( nntrvi(6,nutr).gt.lgtcmx ) then
              jaux = -2
            elseif ( nntrvi(6,nutr).eq.1 ) then
              jaux = lgtcmx - 1
            else
              jaux = nntrvi(6,nutr) - 2
            endif
          else
            if ( nnquvi(7,nuqu).gt.lgtcmx ) then
              jaux = -2
            elseif ( nnquvi(7,nuqu).eq.1 ) then
              jaux = lgtcmx - 1
            else
              jaux = nnquvi(7,nuqu) - 2
            endif
          endif
          lacoul = tbcoli(jaux)
c
c 4 : selon la famille, avec orientation, noir et blanc
c 5 : selon la famille, sans orientation, noir et blanc
c          blanc : famille 1 (les libres)
c          gris pale : famille 2 et celles d'orientation autre,
c           etc
c          noir au dela de la famille 20
c
        elseif ( typcof.ge.4 .and. typcof.le.5 ) then
c
          lacoul = tbcoli(-1)
          if ( nutr.gt.0 ) then
            if ( nntrvi(6,nutr).gt.20 ) then
              leremp = 0
            else
              leremp = 21 - nntrvi(6,nutr)
            endif
          else
            if ( nnquvi(7,nuqu).gt.20 ) then
              leremp = 0
            else
              leremp = 21 - nnquvi(7,nuqu)
            endif
          endif
c
c 10 : niveau de raffinement
c
        elseif ( typcof.eq.10 ) then
c
          if ( nutr.gt.0 ) then
            jaux = nntrvi(1,nutr)
          else
            jaux = nnquvi(1,nuqu)
          endif
          lacoul = tbcoli(jaux)
          leremp = 20
c
c 1 : opaque
c
        elseif ( typcof.eq.1 ) then
c
          lacoul = tbcoli(-1)
          leremp = 20
c
c 0 : invisible
c
        elseif ( typcof.eq.0 .) then
c
          lacoul = tbcoli(-1)
          leremp = -1
c
c autre : erreur
c
        else
          codret = 1
        endif
c
c 4.2. ==> couleur du perimetre
c            0 : pas de trace
c            2 : noir
c            4 : niveau de la face
c        autre : erreur
c
        if ( typcop.eq.0 ) then
          kaux = 0
        elseif ( typcop.eq.2 ) then
          kaux = -2
        elseif ( typcop.eq.4 ) then
          if ( nutr.gt.0 ) then
            kaux = nntrvi(1,nutr)
          else
            kaux = nnquvi(1,nuqu)
          endif
        else
          codret = 1
        endif
c
c 4.3. ==> trace
c
        if ( codret.eq.0 ) then
c
c       Les noeuds
c
        if ( nutr.gt.0 ) then
          lno(1) = nntrvi(3,nutr)
          if ( degre.eq.1 ) then
            lno(2) = nntrvi(4,nutr)
            lno(3) = nntrvi(5,nutr)
            lglesn = 4
          else
            lno(2) = nntrvi(7,nutr)
            lno(3) = nntrvi(4,nutr)
            lno(4) = nntrvi(8,nutr)
            lno(5) = nntrvi(5,nutr)
            lno(6) = nntrvi(9,nutr)
            lglesn = 7
          endif
        else
          lno(1) = nnquvi(3,nuqu)
          if ( degre.eq.1 ) then
            lno(2) = nnquvi(4,nuqu)
            lno(3) = nnquvi(5,nuqu)
            lno(4) = nnquvi(6,nuqu)
            lglesn = 5
          else
            lno(2) = nnquvi( 8,nuqu)
            lno(3) = nnquvi( 4,nuqu)
            lno(4) = nnquvi( 9,nuqu)
            lno(5) = nnquvi( 5,nuqu)
            lno(6) = nnquvi(10,nuqu)
            lno(7) = nnquvi( 6,nuqu)
            lno(8) = nnquvi(11,nuqu)
            lglesn = 9
          endif
        endif
        lno(lglesn) = lno(1)
cgn        write(ulsort,90015) 'face',nuface,' :',
cgn     >                      (lno(lenoeu), lenoeu = 1, lglesn)
c
c       type de polygone : iaux1
c       couleur trait : iaux2
c       couleur remplissage : iaux3
c       profondeur : iaux4
c       remplissage : iaux5 (-1 : rien, 0<=n<=20 : a 5n %)
c       fleche en fin : iaux6
c
        if ( nutr.gt.0 ) then
          write(ulvecs,33001) 'triangle'
        else
          write(ulvecs,33001) 'quadrangle'
        endif
        iaux1 = 3
        iaux2 = tbcoli(kaux)
        iaux3 = lacoul
        if ( nutr.gt.0 ) then
          iaux4 = 51
        else
          iaux4 = 52
        endif
        iaux5 = leremp
        iaux6 = 0
        write(ulvecs,32001) iaux1, iaux2, iaux3, iaux4, iaux5,
     >                      iaux6, lglesn
c
        do 4131 , lenoeu = 1, lglesn
          tabaux(2*lenoeu-1) =nint(factx*(decalx+coopro(1,lno(lenoeu))))
          tabaux(2*lenoeu  ) =nint(facty*(decaly+coopro(2,lno(lenoeu))))
 4131   continue
c
        write(ulvecs,32002) (tabaux(lenoeu), lenoeu = 1, 2*lglesn)
c
        endif
c
   41 continue
c
      endif
c
c====
c 5. impression du maillage : les aretes
c    Quand les bords sont demandes, il faut les passer en dernier
c    pour qu'ils soient clairement visibles
c    En degre 2, il faut decomposer le trace des aretes de bord ou
c    isolee pour pouvoir visualiser les effets de courbure
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. impression des aretes ; codret', codret
      write (ulsort,90002) 'nbarvi', nbarvi
#endif
c
      if ( nbarvi.ne.0 ) then
c
        write(ulvecs,31001)
cgn        do 1222,iaux=-11,nbnoto
cgn       print 1788,iaux,coopro(1,iaux),coopro(2,iaux)
cgn1222   continue
cgn1788   format(i3,4f12.5)
        if ( typbor.gt.0 ) then
          laux = 1
        else
          laux = 0
        endif
cgn            print *, laux
cgn            print *, typcof
c
        do 5 , jaux = 0 , laux
cgn            print *, 'eeeeeeeeeeeeee',jaux
c
          do 51 , iaux = 1 , nbarvi
c
c   nnarvi(5,iaux) vaut 0 pour une arete isolee, 1 pour un bord, 2 sinon
c   . 1ere passe de la boucle 5 (jaux=0) : aretes isolees
c   . 2nde passe (eventuelle) de la boucle 5 : aretes de bord
c
cgn            print *, nnarvi(5,iaux)
            if ( nnarvi(5,iaux).eq.jaux ) then
c
c             Les noeuds
c
              lno(1) = nnarvi(3,iaux)
              if ( degre.eq.2 .and. nnarvi(5,iaux).le.1 ) then
                lno(2) = nnarvi(6,iaux)
                lglesn = 3
              else
                lglesn = 2
              endif
              lno(lglesn) = nnarvi(4,iaux)
cgn            print *, (lno(lenoeu),lenoeu = 1, lglesn)
c
c       type de polygone : iaux1
c       couleur trait : iaux2
c       couleur remplissage : iaux3
c       profondeur : iaux4
c       remplissage : iaux5 (-1 : rien, 0<=n<=20 : a 5n %)
c       fleche en fin : iaux6
c
c si l'arete est un bord et que le coloriage du bord est demande, la
c couleur est celle designee par typbor
c si les faces ont ete demandees par niveau, on retient le niveau
c sinon : defaut (noir)
c
              write(ulvecs,33001) 'segment'
              iaux1 = 1
              if ( jaux.eq.1 ) then
                if ( typbor.eq.1 ) then
                  kaux = -2
                else
                  kaux = lgtcmx-2
                endif
              elseif ( typcof.eq.10 ) then
                kaux = nnarvi(1,iaux)
              else
                kaux = -2
              endif
              iaux2 = tbcoli(kaux)
              iaux3 = -1
              if ( jaux.eq.1 ) then
                iaux4 = 41
              else
                iaux4 = 42
              endif
              iaux5 = -1
              iaux6 = 0
c
              write(ulvecs,32001) iaux1, iaux2, iaux3, iaux4, iaux5,
     >                            iaux6, lglesn
c
              do 511 , lenoeu = 1, lglesn
cgn          print *, coopro(1,lno(lenoeu)),coopro(2,lno(lenoeu))
                tabaux(2*lenoeu-1) =
     >                nint(factx*(decalx+coopro(1,lno(lenoeu))))
                tabaux(2*lenoeu  ) =
     >                nint(facty*(decaly+coopro(2,lno(lenoeu))))
  511         continue
c
              write(ulvecs,32002) (tabaux(lenoeu), lenoeu = 1, 2*lglesn)
c
            endif
c
   51     continue
c
    5   continue
c
      endif
cc      if ( codret.ne.1789) return
c
c====
c 6. impression du maillage : la fenetre de zoom
c          on trace les segments dans l'ordre des pseudo-noeuds :
c             0/-1; -1/-2; -2/-3; -3/0
c          pour le 3D on poursuit avec :
c            -4/-5; -5/-6; -6/-7; -7/-4
c            -4/0;  -5/-1; -6/-2; -7/-3
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. fenetre de zoom ; codret', codret
#endif
c
      if ( zoom ) then
c
      write(ulvecs,31004)
c
      kaux = lgtcmx
      lacoul = tbcoli(kaux)
c
      if ( sdim.eq.3 ) then
        iaux1 = 3
      else
        iaux1 = 1
      endif
c
      do 61 , iaux = 1 , iaux1
c
        if ( iaux.eq.1 ) then
          noeud2 = 0
        else
          noeud2 = -4
        endif
c
        do 611 , jaux = 1 , 4
c
          if ( iaux.lt. 3 ) then
            noeud1 = noeud2
            if ( jaux.eq.4 ) then
              noeud2 = noeud1 + 3
            else
              noeud2 = noeud1 - 1
            endif
          else
            if ( jaux.eq.1 ) then
              noeud1 = noeud2
            else
              noeud1 = noeud1 - 1
            endif
            noeud2 = noeud1 + 4
          endif
c
c       on calcule les abscisses et les ordonnees.
c
          tabaux(1) = nint(factx*(decalx+coopro(1,noeud1)))
          tabaux(2) = nint(facty*(decaly+coopro(2,noeud1)))
          tabaux(3) = nint(factx*(decalx+coopro(1,noeud2)))
          tabaux(4) = nint(facty*(decaly+coopro(2,noeud2)))
c
c       type de polygone : iaux1
c       couleur trait : iaux2
c       couleur remplissage : iaux3
c       profondeur : iaux4
c       remplissage : iaux5 (-1 : rien, 0<=n<=20 : a 5n %)
c       fleche en fin : iaux6
c
          iaux1 = 1
          iaux2 = lacoul
          iaux3 = -1
          iaux4 = 99
          iaux5 = -1
          iaux6 = 0
c
          write(ulvecs,32001) iaux1, iaux2, iaux3, iaux4, iaux5,
     >                        iaux6, 2
          write(ulvecs,32002) (tabaux(lenoeu), lenoeu = 1, 4)
c
  611   continue
c
   61 continue
c
      endif
c
c====
c 7. impression du maillage : le triedre
c          on trace les segments dans l'ordre des pseudo-noeuds :
c          en 2D : O/I ; O/J
c          en 3D : O/I ; O/J ; O/K
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. triedre ; codret', codret
#endif
c
      if ( triedr.ne.0 ) then
c
      write(ulvecs,31005)
c
      kaux = -2
      lacoul = tbcoli(kaux)
c
      if ( sdim.eq.3 ) then
        iaux1 = 3
      else
        iaux1 = 2
      endif
c
      noeud2 = -8
      tabaux(1) = nint(factx*(decalx+coopro(1,noeud2)))
      tabaux(2) = nint(facty*(decaly+coopro(2,noeud2)))
      lglesn = 2
c
      do 71 , iaux = 1 , iaux1
c
        if ( iaux.eq.1 ) then
          noeud1 = -9
c                   123456789
          saux09 = '(x)      '
        elseif ( iaux.eq.2 ) then
          noeud1 = -10
c                   123456789
          saux09 = '(y)      '
        else
          noeud1 = -11
c                   123456789
          saux09 = '(z)      '
        endif
c
c       type de polygone : iaux1
c       couleur trait : iaux2
c       couleur remplissage : iaux3
c       profondeur : iaux4
c       remplissage : iaux5 (-1 : rien, 0<=n<=20 : a 5n %)
c       fleche en fin : iaux6
c
        iaux1 = 1
        iaux2 = lacoul
        iaux3 = -1
        iaux4 = 98
        iaux5 = -1
        iaux6 = 1
c
        write(ulvecs,32001) iaux1, iaux2, iaux3, iaux4, iaux5,
     >                      iaux6, lglesn
        write(ulvecs,32003)
c
        tabaux(3) = nint(factx*(decalx+coopro(1,noeud1)))
        tabaux(4) = nint(facty*(decaly+coopro(2,noeud1)))
c
        write(ulvecs,32002) (tabaux(lenoeu), lenoeu = 1, 2*lglesn)
c
        tabaux(5) = nint(factx*(decalx+coopro(1,noeud1)))
        tabaux(6) = nint(facty*(decaly+coopro(2,noeud1)))
c
c       couleur texte : iaux1
c       profondeur : iaux2
c       police : iaux3
c       taille : iaux4
c
        iaux1 = lacoul
        iaux2 = 97
        iaux3 = 16
        iaux4 = 10
        write(ulvecs,32011) iaux1, iaux2, iaux3, iaux4,
     >                      tabaux(5), tabaux(6), saux09(1:3)
c
   71 continue
c
      endif
c
c====
c 8. affichage d'informations supplementaires pour les faces
c     Attention : c'est fait seulement maintenant pour ne pas etre cache
c     par les faces dessinees
c     En numerotation du calcul, on supprime les faces qui ne sont que
c     des faces HOMARD.
c     remarque : dans pcmac1, on s'est arrange pour que les elements
c                externes soient numerotes par dimension decroissante :
c            . les tetraedres
c            . les triangles
c            . les quadrangles
c            . les aretes
c            . les mailles-points
c            on affichera ici leur numerotation locale au type d'element
c            quand il s'agira de numerotation du calcul
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. affichage suppl faces ; codret', codret
#endif
c
      if ( retrto.eq.0 .and. requto.eq.0 ) then
        jaux = 0
      elseif ( infsu1.ge.3 .and. infsu1.le.4 ) then
        jaux = infsu1
      elseif ( infsu2.ge.3 .and. infsu2.le.4 ) then
        jaux = infsu2
      elseif ( infsu3.ge.3 .and. infsu3.le.4 ) then
        jaux = infsu3
      else
        jaux = 0
      endif
c
      if ( jaux.ne.0 ) then
c
      write(ulvecs,31006)
c
      kaux = nbhexa + nbtetr
      laux = nbhexa + nbtetr + nbtria
c
      do 81 , nuface = 1 , nbface
c
        if ( posini(nuface).le.nbtrvi ) then
          nutr = posini(nuface)
          nuqu = 0
        else
          nutr = 0
          nuqu = posini(nuface)-nbtrvi
        endif
c
        if ( jaux.eq.3 ) then
          if ( nutr.gt.0 ) then
            saux09(1:1) = 't'
            tabaux(3) = nntrvi(2,nutr)
          else
            saux09(1:1) = 'q'
            tabaux(3) = nnquvi(2,nuqu)
          endif
        else
          if ( nutr.gt.0 ) then
            saux09(1:1) = 'T'
            tabaux(3) = ntreca(nntrvi(2,nutr)) - kaux
          else
            saux09(1:1) = 'Q'
            tabaux(3) = nqueca(nnquvi(2,nuqu)) - laux
          endif
        endif
c
        if ( tabaux(3).ne.0 ) then
c
          if ( nutr.gt.0 ) then
            lno(1) = nntrvi(3,nutr)
            lno(2) = nntrvi(4,nutr)
            lno(3) = nntrvi(5,nutr)
            lglesn = 3
          else
            lno(1) = nnquvi(3,nuqu)
            lno(2) = nnquvi(4,nuqu)
            lno(3) = nnquvi(5,nuqu)
            lno(4) = nnquvi(6,nuqu)
            lglesn = 4
          endif
cgn          write(ulsort,90015) 'face',nuface,' :',
cgn     >                        (lno(lenoeu), lenoeu = 1, lglesn)
c
c         on calcule les abscisses et les ordonnees du centre
c
          tabaur(1) = 0.d0
          tabaur(2) = 0.d0
          do 811 , lenoeu = 1, lglesn
            tabaur(1) = tabaur(1) + coopro(1,lno(lenoeu))
            tabaur(2) = tabaur(2) + coopro(2,lno(lenoeu))
  811     continue
c
          if ( nutr.gt.0 ) then
            daux = unstr
          else
            daux = unsqu
          endif
c
          tabaux(1) = nint( factx*(decalx+tabaur(1)*daux) )
          tabaux(2) = nint( facty*(decaly+tabaur(2)*daux) )
c
          call utench ( tabaux(3), 'g', iaux6, saux07,
     >                  ulsort, langue, codret )
          saux09(3:9) = '       '
          if ( codret.eq.0 ) then
            saux09(2:1+iaux6) = saux07(1:iaux6)
          else
            iaux6 = 0
          endif
c
          lacoul = tbcoli(-3)
c
c       couleur texte : iaux1
c       profondeur : iaux2
c       police : iaux3
c       taille : iaux4
c
          iaux1 = lacoul
          iaux2 = 5
          iaux3 = 16
          iaux4 = 10
          write(ulvecs,32011) iaux1, iaux2, iaux3, iaux4,
     >                        tabaux(1), tabaux(2), saux09(1:1+iaux6)
c
        endif
c
   81 continue
c
      endif
c
c====
c 9. affichage d'informations supplementaires pour les noeuds
c    Attention : c'est fait seulement maintenant pour ne pas etre cache
c    par les faces dessinees
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. affichage supp noeuds ; codret', codret
      write(ulsort,90002) 'nbtrvi', nbtrvi
      write(ulsort,90002) 'nbquvi', nbquvi
      write(ulsort,90002) 'nbnoto', nbnoto
#endif
c
      if ( infsu1.ge.1 .and. infsu1.le.2 ) then
        jaux = infsu1
      elseif ( infsu2.ge.1 .and. infsu2.le.2 ) then
        jaux = infsu2
      elseif ( infsu3.ge.1 .and. infsu3.le.2 ) then
        jaux = infsu3
      else
        jaux = 0
      endif
c
      if ( jaux.ne.0 .or. optnoe.ne.0 ) then
c
        write(ulvecs,31007)
c
c 9.1. ==> liste des noeuds a tracer
c
        if ( codret.eq.0 ) then
        call gmalot ( ntrava, 'entier  ', nbnoto, adtrav, codret )
        endif
c
        if ( codret.eq.0 ) then
c
        iaux1 = adtrav
        iaux2 = adtrav + nbnoto - 1
        do 911 , iaux = iaux1, iaux2
          imem(iaux) = 0
  911   continue
c
c les noeuds des aretes
c
        do 912 , iaux = 1 , nbarvi
          imem(adtrav-1+nnarvi(3,iaux)) = 1
          imem(adtrav-1+nnarvi(4,iaux)) = 1
  912   continue
        if ( degre.eq.2 ) then
          do 913 , iaux = 1 , nbarvi
            imem(adtrav-1+nnarvi(6,iaux)) = 2
  913     continue
        endif
cgn        do 3812 , iaux = 1 , nbarvi
cgn        write(ulsort,90015) 'arete',iaux,' :',
cgn     <        nnarvi(3,iaux),nnarvi(6,iaux),nnarvi(4,iaux)
cgn 3812   continue
c
c les noeuds des faces
c
        if ( degre.eq.1 ) then
          iaux1 = 1
        else
          iaux1 = 2
        endif
c
        do 914 , laux = 1 , iaux1
        do 915 , nuface = 1 , nbface
c
          iaux = posini(nuface)
c
          if ( iaux.le.nbtrvi ) then
cgn      if ( laux.eq.1 ) write(ulsort,90015) 'triangle',iaux,' :',
cgn     <             nntrvi(4*laux-1,iaux),
cgn     <             nntrvi(4*laux  ,iaux),
cgn     <             nntrvi(4*laux+1,iaux)
            imem(adtrav-1+nntrvi(4*laux-1,iaux)) = laux
            imem(adtrav-1+nntrvi(4*laux  ,iaux)) = laux
            imem(adtrav-1+nntrvi(4*laux+1,iaux)) = laux
          else
cgn      if ( laux.eq.1 ) write(ulsort,90015) 'quadrangle',iaux,' :',
cgn     <             nnquvi(5*laux-2,iaux-nbtrvi),
cgn     <             nnquvi(5*laux-1,iaux-nbtrvi),
cgn     <             nnquvi(5*laux  ,iaux-nbtrvi),
cgn     <             nnquvi(5*laux+1,iaux-nbtrvi)
            imem(adtrav-1+nnquvi(5*laux-2,iaux-nbtrvi)) = laux
            imem(adtrav-1+nnquvi(5*laux-1,iaux-nbtrvi)) = laux
            imem(adtrav-1+nnquvi(5*laux  ,iaux-nbtrvi)) = laux
            imem(adtrav-1+nnquvi(5*laux+1,iaux-nbtrvi)) = laux
          endif
c
  915   continue
  914   continue
c
c les noeuds internes aux faces
c
cgn      write(ulsort,*) 'les noeuds internes aux faces'
        if ( mod(mailet,2).eq.0 .or.
     >       mod(mailet,3).eq.0 .or.
     >       mod(mailet,5).eq.0 ) then
c
          do 916 , nuface = 1 , nbface
c
            iaux = posini(nuface)
c
            if ( iaux.le.nbtrvi ) then
cgn      write(ulsort,90015) 'triangle',iaux,' :',nntrvi(10,iaux)
              imem(adtrav-1+nntrvi(10,iaux)) = 4
            else
cgn      write(ulsort,90015) 'quadrangle',iaux,' :',nnquvi(12,iaux-nbtrvi)
              imem(adtrav-1+nnquvi(12,iaux-nbtrvi)) = 4
            endif
cgn          print *,nntrvi(10,iaux)
c
  916     continue
c
        endif
c
        endif
c
c 9.2. ==> affichage
c
        if ( codret.eq.0 ) then
c
        if ( jaux.eq.1 ) then
          saux09(1:1) = 'n'
        else
          saux09(1:1) = 'N'
        endif
c
        lacoul = tbcoli(-3)
c
        do 92 , noeud = 1 , nbnoto
cgn        print 90002,'noeud',noeud,imem(adtrav-1+noeud)
cgn        print 1780,coopro(1,noeud),coopro(2,noeud)
cgn 1780 format(2g15.7)
c
          if ( imem(adtrav-1+noeud).ne.0 ) then
c
            tabaux(1) = nint(factx*(decalx+coopro(1,noeud)))
            tabaux(2) = nint(facty*(decaly+coopro(2,noeud)))
c
c           Numero du noeud
c
            if ( jaux.ne.0 ) then
c
              if ( jaux.eq.1 ) then
                tabaux(3) = noeud
              else
                tabaux(3) = nnoeca(noeud)
              endif
c
              call utench ( tabaux(3), 'g', iaux6, saux07,
     >                      ulsort, langue, codret )
              saux09(3:9) = '       '
              if ( codret.eq.0 ) then
                saux09(2:1+iaux6) = saux07(1:iaux6)
              else
                iaux6 = 0
              endif
c
c       couleur texte : iaux1
c       profondeur : iaux2
c       police : iaux3
c       taille : iaux4
c
              iaux1 = lacoul
              iaux2 = 1
              iaux3 = 16
              iaux4 = 10
              write(ulvecs,32011) iaux1, iaux2, iaux3, iaux4,
     >                            tabaux(1), tabaux(2),
     >                            saux09(1:1+iaux6)
c
            endif
c
c           Affichage d'un rond
c
            if ( optnoe.ne.0 ) then
c
c       couleur trait : iaux1
c       profondeur : iaux2
c       remplissage : iaux3
c       rayon : iaux4
c
              iaux1 = lacoul
              iaux2 = 2
              if ( optnoe.eq.1 ) then
                iaux3 = -1
              else
                iaux3 = 20
              endif
              iaux4 = 50
              write(ulvecs,32012) iaux1, iaux1, iaux2, iaux3,
     >                            tabaux(1), tabaux(2),
     >                            iaux4, iaux4,
     >                            tabaux(1), tabaux(2),
     >                            tabaux(1)+iaux4, tabaux(2)
c
            endif
c
c
          endif
c
   92   continue
c
        endif
c
        if ( codret.eq.0 ) then
        call gmlboj ( ntrava, codret )
        endif
c
      endif
c
c====
c 10. Affichage d'informations supplementaires pour les aretes
c     Attention : c'est fait seulement maintenant pour ne pas etre cache
c     par les faces dessinees
c     En numerotation du calcul, on supprime les aretes qui ne sont que
c     des aretes HOMARD.
c     remarque : dans pcmac1, on s'est arrange pour que les elements
c                externes soient numerotes par dimension decroissante :
c            . les tetraedres
c            . les triangles
c            . les quadrangles
c            . les aretes
c            . les mailles-points
c            on affichera ici leur numerotation locale au type d'element
c            quand il s'agira de numerotation du calcul
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. affichage suppl aretes ; codret', codret
#endif
c
cgn      print *,'infsu1, infsu2, infsu3 = ', infsu1, infsu2, infsu3
      if ( infsu1.ge.5 .and. infsu1.le.6 ) then
        jaux = infsu1
      elseif ( infsu2.ge.5 .and. infsu2.le.6 ) then
        jaux = infsu2
      elseif ( infsu3.ge.5 .and. infsu3.le.6 ) then
        jaux = infsu3
      else
        jaux = 0
      endif
      if ( jaux.eq.6 .and. rearto.eq.0 ) then
        jaux = 0
      endif
c
      if ( jaux.ne.0 ) then
c
      write(ulvecs,31008)
c
      if ( infsu1.ge.1 .and. infsu1.le.2 ) then
        kaux = infsu1
      elseif ( infsu2.ge.1 .and. infsu2.le.2 ) then
        kaux = infsu2
      elseif ( infsu3.ge.1 .and. infsu3.le.2 ) then
        kaux = infsu3
      else
        kaux = 0
      endif
c
      do 101 , iaux = 1 , nbarvi
c
        if ( jaux.eq.5 ) then
          saux09(1:1) = 'a'
          tabaux(3) = nnarvi(2,iaux)
        else
          saux09(1:1) = 'A'
          tabaux(3) = nareca(nnarvi(2,iaux))
        endif
c
        if ( tabaux(3).ne.0 ) then
c
          noeud1 = nnarvi(3,iaux)
          noeud2 = nnarvi(4,iaux)
          tabaur(1) = coopro(1,noeud1) + coopro(1,noeud2)
          tabaur(2) = coopro(2,noeud1) + coopro(2,noeud2)
c
          tabaux(1) = nint( factx*(decalx+tabaur(1)*unsde) )
          tabaux(2) = nint( facty*(decaly+tabaur(2)*unsde) )
c
          call utench ( tabaux(3), 'g', iaux6, saux07,
     >                  ulsort, langue, codret )
          saux09(3:9) = '       '
          if ( codret.eq.0 ) then
            saux09(2:1+iaux6) = saux07(1:iaux6)
          else
            iaux6 = 0
          endif
c
          lacoul = tbcoli(-3)
c
c       couleur texte : iaux1
c       profondeur : iaux2
c       police : iaux3
c       taille : iaux4
c
          iaux1 = lacoul
          iaux2 = 10
          iaux3 = 16
          iaux4 = 10
          write(ulvecs,32011) iaux1, iaux2, iaux3, iaux4,
     >                        tabaux(1), tabaux(2), saux09(1:1+iaux6)
c
        endif
c
  101 continue
c
      endif
c
c===
c 11. formats
c===
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11. formats ; codret', codret
#endif
c
30000 format(
     >  '#FIG 3.2  Produced by HOMARD ',a8)
c  string  orientation   ("Landscape" or "Portrait")
c  string  justification   ("Center" or "Flush Left")
c  string  units     ("Metric" or "Inches")
c  string  papersize   ("Letter", "Legal", "Ledger", "Tabloid",
c           "A", "B", "C", "D", "E",
c           "A4",   "A3", "A2", "A1", "A0" and "B5")
c  float magnification   (export and print magnification, %)
c  string  multiple-page   ("Single" or "multiple" pages)
c  int transparent color (color number for transparent color for GIF
c           export. -3=background, -2=None, -1=Default,
c           0-31 for standard colors or 32- for user colors)
30010 format(
     >  a9,
     >/,'Center',
     >/,'Metric',
     >/,'A4',
     >/,'100.00',
     >/,'Single',
     >/,'-2')
c  # optional comment    (An optional set of comments may be here,
c           which are associated with the whole figure)
30020 format(
     >  '#Creator: HOMARD ',a8,
     >/,'#Title:',a,
     >/,'#CreationDate:',a)
c  int resolution: 1200 ppi (standard)
c  coord_system (Fig units/inch and coordinate system:
c             1: origin at lower left corner (NOT USED)
c             2: upper left)
30030 format(
     >  '1200 2')
30031 format(
     >  '# fig2dev -L png -D +1,5,10,41,51 -K ',a)
c
31001 format(
     >  '# ============',
     >/,'# Les segments',
     >/,'# ============')
31002 format(
     >  '# =======================================',
     >/,'# Nombre de polygones traces : ',i10
     >/,'# =======================================')
31004 format(
     >  '# ==================================',
     >/,'# Fenetre de zoom',
     >/,'# ==================================')
31005 format(
     >  '# ==================================',
     >/,'# Triedre',
     >/,'# ==================================')
31006 format(
     >  '# ==================================',
     >/,'# Numeros des faces',
     >/,'# ==================================')
31007 format(
     >  '# ==================================',
     >/,'# Numeros des noeuds',
     >/,'# ==================================')
31008 format(
     >  '# ==================================',
     >/,'# Numeros des segments',
     >/,'# ==================================')
c
c  1 : 1: cercle/ellipse 2:polygone
c  2 : Si polygone :
c        3:courbe fermee (dernier point = premier), 1:courbe ouverte
c      Si cercle/ellipse :
c        1:ellipse definie par les rayons   2:par les diametres
c        3:cercle defini par le rayon       4:par le diametre
c  3 : 0: plein, 1: pointille tiret, 2:pointille point
c  4 : epaisseur du trait
c  5 : couleur du trait (-1: defaut (noir), 0: noir, 4: rouge)
c  6 : couleur du remplissage
c  7 : profondeur (0 = devant, 100 = au fond)
c  8 : inutile
c  9 : -1 : pas de remplissage, n: remplissage a 5n%
c 10 : longueur du pointille (reel)
c Si polygone :
c 11 : type de jonction 0:pointu, 1:arrondi
c 14 : fin de trait : 0, si normal, 1 si fleche
c 15 : debut de trait : 0, si normal, 1 si fleche
c          il y a une ligne de plus decrivant la fleche
c 16 (dernier) : nombre de points
c Si cercle/ellipse :
c 11 : toujours 1
c 12 : angle avec axes des x (reel)
c 13 : centre en x
c 14 : centre en y
c 15 : rayon en x
c 16 : rayon en y
c 17 : 1er point en x = centre en x
c 18 : 1er point en y = centre en y
c 19 : dernier point en x = centre en x + rayon en x
c 20 : dernier point en y = centre en y
32001 format(
     >'2 ',i2,' 0 1 ',3i3,' -1 ',i2,' 0.000 2 0 -1 ',i2,' 0 ',i2)
32002 format(10i8)
32003 format('1 1 1.00 60.00 120.00')
32011 format(
     >'4 0 ',2i3,' -1 ',2i3,' 0.0000 4 135 165 ',2i8,' ',a,'\001')
32012 format(
     >'1 3 0 1',3i3,' -1 ',i3,' 0.000  1 0.000 ',8i8)
33001 format('# ',a,i10)
c
c====
c 9. la fin
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
