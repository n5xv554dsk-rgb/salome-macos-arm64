      subroutine infve1 ( option,
     >                    typcof, typcop, typbor, optnoe,
     >                    porpay, triedr,
     >                    anglex, angley, anglez,
     >                    zoom, xyzmiz, xyzmaz,
     >                    vafomi, vafoma,
     >                    xyzmin, xyzmax, xyzeps,
     >                    nbcham, nocham,
     >                    nomcha, nomcmp, nrocha, nrocmp, nrotab,
     >                    ulfido, ulenst, ulsost,
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
c   INformation : Fichiers VEctoriel - 1ere partie
c   --            -        --          -
c ______________________________________________________________________
c
c but : determination des choix pour les fichiers
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option .   s .   1    . 0 : on ne sort aucun fichier               .
c .        .     .        . 1 : sortie graphique sans numero           .
c .        .     .        . 2 : graphique et numero homard des noeuds  .
c .        .     .        . 3 : graphique et numero du calcul des noeud.
c .        .     .        . 4 : graphique et numero homard des faces   .
c .        .     .        . 5 : graphique et numero du calcul des faces.
c .        .     .        . 6 : graphique et numero homard des aretes  .
c .        .     .        . 7 : graphique et numero du calcul des aret .
c .        .     .        . np : choix n et choix p simultanement      .
c .        .     .        . negatif : par blocs connexes               .
c .        .     .        . positif : tout le maillage                 .
c .        .     .        . 100+positif : tout le maillage par niveau  .
c . typcof .   s .   1    . type de coloriage des faces                .
c .        .     .        .   0 : incolore transparent                 .
c .        .     .        .   1 : incolore opaque                      .
c .        .     .        .   2 : famille HOMARD                       .
c .        .     .        .   4 : idem 2, en niveau de gris            .
c .        .     .        . +-6 : couleur selon un champ, echelle auto..
c .        .     .        . +-7 : idem avec echelle fixe               .
c .        .     .        . +-8/+-9 : idem +-6/+-7, en niveau de gris  .
c .        .     .        .  10 : niveau                               .
c . typcop .   s .   1    . type de coloriage du perimetre des faces   .
c .        .     .        .   0 : pas de trace                         .
c .        .     .        .   1 : pas de trace et bord rouge           .
c .        .     .        .   2 : noir                                 .
c .        .     .        .   3 : noir et bord rouge                   .
c .        .     .        .   4 : niveau de la face                    .
c . typbor .   s .   1    . type d'affichage du bord                   .
c .        .     .        .   0 : pas de trace                         .
c .        .     .        .   1 : trace en rouge                       .
c .        .     .        .   2 : trace en noir                        .
c . optnoe .   s .   1    . 0 : rien de special                        .
c .        .     .        . 1 : trace d'un rond vide sur chaque noeud  .
c .        .     .        . 2 : trace d'un rond plein sur chaque noeud .
c . porpay .   s .   1    . 0 : portrait/paysage selon la taille       .
c .        .     .        . 1 : portrait                               .
c .        .     .        . 2 : paysage                                .
c . triedr .   s .   1    . 0 : pas de trace du triedre                .
c .        .     .        . 1 : trace du triedre                       .
c . anglex .   s .   1    . angle de rotation autour de x              .
c . angley .   s .   1    . angle de rotation autour de y              .
c . anglez .   s .   1    . angle de rotation autour de z              .
c . zoom   .   s .   1    . vrai ou faux selon zoom ou non             .
c . xyzmiz .   s .   1    . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) minimales de la fenetre de zoom .
c . xyzmaz .   s .   1    . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) maximales de la fenetre de zoom .
c . vafomi .   s .   1    . minimum de l'echelle de la fonction        .
c . vafoma .   s .   1    . maximum de l'echelle de la fonction        .
c . xyzmin . e   .  sdim  . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) minimales du domaine total      .
c . xyzmax . e   .  sdim  . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) maximales du domaine total      .
c . xyzeps . e   .  sdim  . -1 si min = max dans la direction,         .
c .        .     .        . ecart sinon.                               .
c . nbcham . e   .   1    . nombre de champs definis                   .
c . nocham . e   . nbcham . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . nomcha .   s . char64 . nom du champ retenu pour le coloriage      .
c . nomcmp .   s .   1    . nom de la composante retenue               .
c . nrocha .   s .   1    . nunero du champ retenu pour le coloriage   .
c .        .     .        . -1 si coloriage selon la qualite           .
c . nrocmp .   s .   1    . numero de la composante retenue            .
c . nrotab .   s .   1    . numero du tableau associe au pas de temps  .
c . ulfido . e   .   1    . unite logique du fichier de donnees correct.
c . ulenst . e   .   1    . unite logique de l'entree standard         .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans les memoires             .
c .        .     .        . 3 : probleme dans les fichiers             .
c .        .     .        . 5 : probleme autre                         .
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
      parameter ( nompro = 'INFVE1' )
c
#include "nblang.h"
#include "esutil.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "gmenti.h"
#include "gmstri.h"
#include "infini.h"
#include "precis.h"
c
c 0.3. ==> arguments
c
      integer option
      integer typcof, typcop, typbor, optnoe, porpay, triedr
      integer ulfido, ulenst, ulsost
      integer nbcham
      integer nrocha, nrocmp, nrotab
c
      double precision anglex, angley, anglez
      double precision xyzmin(sdim), xyzmax(sdim), xyzeps(sdim)
      double precision xyzmiz(sdim), xyzmaz(sdim)
      double precision vafomi, vafoma
c
      logical zoom
      logical abssol
c
      character*8 nocham(nbcham)
      character*16 nomcmp
      character*64 nomcha
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbsign
      integer typsig(3), valent(3)
c
      character*1 xyz(3)
      character*1 rep01
      character*2 valcha(3)
      character*80 chaine
c
      integer iaux
      integer iaux1, iaux2, iaux3
c
      double precision daux1, daux2, daux3
      double precision angle1, angle2, angle3
c
      integer nbcomp, nbtvch, typcha
      integer adnocp, adcaen, adcare, adcaca
c
      integer adtrav, lgtrav
c
      character*2 saux02
      character*8 saux08
      character*16 saux16
      character*64 saux64
c
      integer nbmess
      parameter ( nbmess = 110 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisation
c
      data xyz / 'x' , 'y' , 'z' /
c_______________________________________________________________________
c
c====
c 1. initialisation
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
      texte(1,4)  = '(''0 : aucun fichier'')'
      texte(1,5)  = '(''1 : maillage seul'')'
      texte(1,6)  = '(''2 : avec numero HOMARD des noeuds'')'
      texte(1,7)  = '(''3 : avec numero du calcul des noeuds'')'
      texte(1,8)  = '(''4 : avec numero HOMARD des faces'')'
      texte(1,9)  = '(''5 : avec numero du calcul faces'')'
      texte(1,10) = '(''6 : avec numero HOMARD des aretes'')'
      texte(1,11) = '(''7 : avec numero du calcul aretes'')'
      texte(1,12) = '(''8 : avec numero HOMARD pour tout'')'
      texte(1,13) = '(''9 : avec numero du calcul pour tout'')'
      texte(1,17) = '(''si >0, tout le domaine de calcul'')'
      texte(1,18) = '(''si <0, par bloc connexe'')'
      texte(1,19) =
     > '(''si 100+>0, tout le domaine de calcul, par niveau'')'
      texte(1,20) = '(''Option non disponible'',/)'
      texte(1,25) = '(/,''Taille et orientation de l''''image :'')'
      texte(1,26) = '(''0 : A4 portrait ou paysage selon la taille'')'
      texte(1,27) = '(''1 : A4 portrait'')'
      texte(1,28) = '(''2 : A4 paysage'')'
      texte(1,29) = '(''Format non disponible'',/)'
      texte(1,30) = '(/,''Couleur des faces :'')'
      texte(1,31) = '(''0 : incolore transparent'')'
      texte(1,32) = '(''1 : incolore opaque'')'
      texte(1,33) = '(''2 : selon famille HOMARD'')'
      texte(1,35) = '(''4 : idem 2, en N&B'')'
      texte(1,37) = '(''6 : selon la qualite'')'
      texte(1,38) = '(''7 : selon un champ solution'')'
      texte(1,39) = '(''10 : selon niveau'')'
      texte(1,40) = '(/,''Couleur des perimetres des faces :'')'
      texte(1,41) = '(''0 : incolore'')'
      texte(1,43) = '(''2 : noir'')'
      texte(1,45) = '(''4 : selon niveau'')'
      texte(1,50) = '(''Quel choix de champ ?'')'
      texte(1,51) = '(''La norme ou une composante ?'')'
      texte(1,51) = '(''Quelle composante ?'')'
      texte(1,52) = '(''Quel numero de pas de temps ?'')'
      texte(1,58) = '(''Le champ ou sa valeur absolue ? (ch/va)'')'
      texte(1,59) =
     > '(''Repondre ch pour le champ, va pour sa valeur absolue.'')'
      texte(1,60) = '(''Quel type de coloriage ?'')'
      texte(1,61) = '(''1 ! avec une echelle automatique'')'
      texte(1,62) = '(''2 ! avec une echelle fixe'')'
      texte(1,63) = '(''3 ! idem 1 en N&B'')'
      texte(1,64) = '(''4 ! idem 2 en N&B'')'
      texte(1,65) = '(''Donner le min et le max pour l''''echelle'')'
      texte(1,66) = '(''Le min est plus grand que le max ?'')'
      texte(1,67) = '(''min = '',g15.7,'' max = '',g15.7)'
      texte(1,71) =
     > '(''Donner les trois angles de rotation pour la vision.'')'
      texte(1,72) = '(''Suggestion :     x          y           z'')'
      texte(1,73) = '(''            '',3g11.3)'
      texte(1,74) =
     > '(''ATTENTION : les limites pour les angles de vue sont :'')'
      texte(1,75) =
     > '(''[-180:180] pour la rotation autour de chaque axe.'')'
      texte(1,81) = '(/,''Avec zoom ? (o/n) '')'
      texte(1,82) = '(''Donner le min et le max pour '',a1,'' :'')'
      texte(1,83) = '(''Domaine : min/max = '',2g15.7)'
      texte(1,84) = '(''Le zoom est hors du domaine.'')'
      texte(1,85) =
     > '(''min domaine = '',g15.7,'' max zoom = '',g15.7)'
      texte(1,86) =
     > '(''max domaine = '',g15.7,'' min zoom = '',g15.7)'
      texte(1,90) = '(/,''Affichage des bords du domaine :'')'
      texte(1,91) = '(''0 : non'')'
      texte(1,92) = '(''1 : noir'')'
      texte(1,93) = '(''2 : rouge'')'
      texte(1,100) = '(/,''Des cercles pour les noeuds :'')'
      texte(1,101) = '(''0 : non'')'
      texte(1,102) = '(''1 : cercles incolores'')'
      texte(1,103) = '(''2 : cercles pleins'')'
      texte(1,110) = '(/,''On trace le triedre ? (o/n) '')'
c
      texte(2,4) = '(''0 : no file'')'
      texte(2,5) = '(''1 : mesh only'')'
      texte(2,6) = '(''2 : with node HOMARD numbers'')'
      texte(2,7) = '(''3 : with node extern numbers'')'
      texte(2,8) = '(''4 : with face HOMARD numbers'')'
      texte(2,9) = '(''5 : with face extern numbers'')'
      texte(2,10) = '(''6 : with edge HOMARD numbers'')'
      texte(2,11) = '(''7 : with edge extern numbers'')'
      texte(2,12) = '(''8 : with HOMARD numbers for all'')'
      texte(2,13) = '(''9 : with extern numbers for all'')'
      texte(2,17) = '(''if >0, the whole calculation domain'')'
      texte(2,18) = '(''if <0, by connex part'')'
      texte(2,19) =
     > '(''if 100+>0, the whole calculation domain, by level'')'
      texte(2,20) = '(''Option still not available'',/)'
      texte(2,25) = '(/,''Image size and orientation :'')'
      texte(2,26) =
     > '(''0 : A4 portrait or landscape, according to size'')'
      texte(2,27) = '(''1 : A4 portrait'')'
      texte(2,28) = '(''2 : A4 landscape'')'
      texte(2,29) = '(''Size still not available'',/)'
      texte(2,30) = '(/,''Face coloring :'')'
      texte(2,31) = '(''0 : no color with transparency'')'
      texte(2,32) = '(''1 : no color with opacity'')'
      texte(2,33) = '(''2 : by HOMARD family'')'
      texte(2,35) = '(''4 : as #2,  B&W'')'
      texte(2,37) = '(''6 : by quality'')'
      texte(2,38) = '(''7 : by value of solution'')'
      texte(2,39) = '(''1 : by level'')'
      texte(2,40) = '(/,''Color of boundaries of the faces :'')'
      texte(2,41) = '(''0 : no color'')'
      texte(2,43) = '(''2 : black'')'
      texte(2,45) = '(''4 : by level'')'
      texte(2,50) = '(''What is your choice for the field ?'')'
      texte(2,51) = '(''Norm or a component ?'')'
      texte(2,51) = '(''What is your choice for the component ?'')'
      texte(2,52) = '(''What is your choice for the time step ?'')'
      texte(2,58) = '(''Field or absolute value ? (ch/va)'')'
      texte(2,59) =
     > '(''Answer ch for the field, va for its abslute value.'')'
      texte(2,60) = '(''Which coloring ?'')'
      texte(2,61) = '(''1 ! automatic scaling'')'
      texte(2,62) = '(''2 ! fixed scaling'')'
      texte(2,63) = '(''3 ! as #1,but B&W'')'
      texte(2,64) = '(''4 ! as #2,but B&W'')'
      texte(2,65) = '(''Give min and max for scaling'')'
      texte(2,66) = '(''Min is higher than max ?'')'
      texte(2,67) = '(''min = '',g15.7,'' max = '',g15.7)'
      texte(2,71)  = '(''Give the three angles of rotation :'')'
      texte(2,72)  = '(''Suggestion :     x          y           z'')'
      texte(2,73)  = '(''            '',3g11.3)'
      texte(2,74) = '(''CAUTION : limits for the angles are :'')'
      texte(2,75) = '(''[-180:180] for rotation around each axis.'')'
      texte(2,81) = '(/,''Zoom ? (y/n) '')'
      texte(2,82) = '(''Give min and max for '',a1,'' :'')'
      texte(2,83) = '(''Domain : min/max = '',2g15.7)'
      texte(2,84) = '(''Zoom is out of the domain.'')'
      texte(2,85) =
     > '(''min domain = '',g15.7,'' max zoom = '',g15.7)'
      texte(2,86) =
     > '(''max domain = '',g15.7,'' min zoom = '',g15.7)'
      texte(2,90) = '(/,''Boundaries of the domain :'')'
      texte(2,91) = '(''0 : no'')'
      texte(2,92) = '(''1 : black'')'
      texte(2,93) = '(''2 : red'')'
      texte(2,100) = '(/,''Circles around the nodes :'')'
      texte(2,101) = '(''0 : no'')'
      texte(2,102) = '(''1 : empty circles'')'
      texte(2,103) = '(''2 : fll circles'')'
      texte(2,110) = '(/,''Are axes plotted ? (y/n) '')'
c
10000 format(a)
10080 format(a80)
11000 format(i10)
c
c 1.2. ==> initialisation d'une fenetre de zoom infinie
c
      do 11 , iaux1 = 1 , sdim
c
        xyzmiz(iaux1) = -vinfpo
        xyzmaz(iaux1) = vinfpo
c
   11 continue
c
c====
c 2. questions - reponses pour l'option
c====
c
   20 continue
c
c 2.1. ==> interactivite
c
      write (ulsost,texte(langue,4))
      write (ulsost,texte(langue,5))
      write (ulsost,texte(langue,6))
      write (ulsost,texte(langue,7))
      write (ulsost,texte(langue,8))
      write (ulsost,texte(langue,9))
      write (ulsost,texte(langue,10))
      write (ulsost,texte(langue,11))
      write (ulsost,texte(langue,12))
      write (ulsost,texte(langue,13))
      write (ulsost,texte(langue,17))
      write (ulsost,texte(langue,18))
      write (ulsost,texte(langue,19))
c
      call dmflsh ( iaux )
      read (ulenst,10080,err=20,end=20) chaine
c
c 2.2. ==> decoupage de la chaine
c
      call utqure ( chaine,
     >              nbsign, typsig, valcha, valent,
     >              ulsort, langue, codret )
cgn      write(ulsort,*) typsig
cgn      write(ulsort,*) valcha
cgn      write(ulsort,*) valent
c
      if ( nbsign.eq.0 ) then
        goto 20
      elseif ( typsig(1).ne.0 ) then
        goto 20
      endif
c
c 2.4. ==> decodage et validation du choix
c
      option = valent(1)
c
      if ( option.lt.-9 .or.
     >     ( option.gt.9 .and. option.lt.101 ) .or.
     >     option.gt.109 ) then
        write (ulsost,texte(langue,20))
        goto 20
      endif
c
      call utlgut ( iaux, chaine,
     >              ulsort, langue, codret )
      write(ulfido,1000) chaine(1:iaux)
c
c====
c 3. questions - reponses pour la mise en page
c====
c
cgn      if ( option .ne. 0 ) then
c
cgn   30 continue
c
c 3.1. ==> interactivite
c
cgn      write (ulsost,texte(langue,25))
cgn      write (ulsost,texte(langue,26))
cgn      write (ulsost,texte(langue,27))
cgn      write (ulsost,texte(langue,28))
c
cgn      call dmflsh ( iaux )
cgn      read (ulenst,10080,err=30,end=30) chaine
c
c 3.2. ==> iaux1 = place du premier caractere non-blanc
c
cgn      iaux1 = 0
cgn      do 321 , i = 1 , 80
cgn         if ( chaine(i:i).ne.' ' ) then
cgn            iaux1 = i
cgn            goto 322
cgn         endif
cgn  321 continue
c
cgn  322 continue
cgn      if ( iaux1.eq.0 ) then
cgn         goto 30
cgn      endif
c
c 3.3. ==> iaux2 = place du dernier caractere non-blanc du choix
c
cgn      iaux3 = iaux1 + 1
cgn      iaux2 = 0
cgn      do 331 , i = iaux3 , 80
cgn         if ( chaine(i:i).eq.' ' ) then
cgn            iaux2 = i-1
cgn            goto 34
cgn         endif
cgn  331 continue
c
cgn      goto 30
c
c 3.4. ==> decodage du choix
c
cgn   34 continue
c
cgn      fmtent = '(I  )'
cgn      if ( iaux2-iaux1+1.lt.10 ) then
cgn        write(fmtent(3:3),'(i1)') iaux2-iaux1+1
cgn      else
cgn        write(fmtent(3:4),'(i2)') iaux2-iaux1+1
cgn      endif
cgn      call dmflsh ( iaux )
cgn      read (chaine(iaux1:iaux2),fmtent) porpay
c
cgn      if ( porpay.lt.0 .or.
cgn     >     porpay.gt.3 ) then
cgn        write (ulsost,texte(langue,29))
cgn        goto 30
cgn      endif
c
cgn      endif
c
         porpay = 0
c====
c 4. questions - reponses pour les angles
c====
c
      if ( option.ne.0 ) then
c
c 4.1. ==> si le probleme est plan, on se place a la perpendiculaire
c
      if ( sdim.le.2 .or. xyzeps(3).lt.0.d0 ) then
        anglex = 0.d0
        angley = 0.d0
        anglez = 0.d0
c
      elseif ( xyzeps(1).lt.0.d0 ) then
        anglex = 0.d0
        angley = 90.d0
        anglez = 0.d0
c
      elseif ( xyzeps(2).lt.0.d0 ) then
        anglex = -90.d0
        angley = 0.d0
        anglez = 0.d0
c
      else
c
c 4.2. ==> cas 3D
c
        anglex = -60.d0
        angley = 30.d0
        anglez = 0.d0
c
 42     continue
c
        write (ulsost,texte(langue,71))
        write (ulsost,texte(langue,72))
        write (ulsost,texte(langue,73)) anglex, angley, anglez
c
        call dmflsh ( iaux )
        read (ulenst,*,err=42,end=42) angle1, angle2, angle3
c
        if (   (angle1.lt.-180.d0) .or. (angle1.gt.180.d0)
     >    .or. (angle2.lt.-180.d0) .or. (angle2.gt.180.d0)
     >    .or. (angle3.lt.-180.d0) .or. (angle3.gt.180.d0) ) then
          write(ulsost,texte(langue,74))
          write(ulsost,texte(langue,75))
          goto 42
        else
          anglex = angle1
          angley = angle2
          anglez = angle3
          write(ulfido,1200) angle1, angle2, angle3
        endif
c
      endif
c
      endif
c
c====
c 5. questions - reponses pour le zoom
c    si on ne veut pas de zoom, on ne fait rien sur les dimensions
c    de la fenetre car elles sont initialisees a des valeurs extremes
c====
c
      if ( option.ne.0 ) then
c
c 5.1. ==> veut-on un zoom ?
c
   51 continue
c
      write (ulsost,texte(langue,81))
c
      call dmflsh ( iaux )
      read (ulenst,*,err=51,end=51) rep01
c
      if ( rep01.eq.'o' .or. rep01.eq.'O' .or.
     >     rep01.eq.'y' .or. rep01.eq.'Y' ) then
        zoom = .true.
      elseif ( rep01.eq.'n' .or. rep01.eq.'N' ) then
        zoom = .false.
      else
        goto 51
      endif
c
      write(ulfido,1000) rep01
c
c 5.2. ==> Si on veut le zoom, on demande les dimensions de la fenetre
c          Il faut etendre legerement cette fenetre, sinon on risque de
c          perdre des valeurs du fait des erreurs d'arrondi sur les
c          coordonnees
c          Quand une coordonnee est constante, on prend une fenetre de
c          zoom egale a cette constante dans cette direction. Cela
c          permet de passer sans envombre les projections.
c
      if ( zoom ) then
c
      do 52 , iaux1 = 1 , sdim
c
      daux1 = xyzmax(iaux1)-xyzmin(iaux1)
c
      if ( daux1.gt.zeroma ) then
c
  520   continue
c
        write (ulsost,texte(langue,82)) xyz(iaux1)
        write (ulsost,texte(langue,83)) xyzmin(iaux1),xyzmax(iaux1)
c
        call dmflsh ( iaux )
        read (ulenst,*,err=520,end=520) xyzmiz(iaux1), xyzmaz(iaux1)
c
        if ( xyzmaz(iaux1).le.xyzmin(iaux1) ) then
          write(ulsost,texte(langue,84))
          write(ulsost,texte(langue,85)) xyzmin(iaux1),xyzmaz(iaux1)
          goto 520
        endif
c
        if ( xyzmiz(iaux1).ge.xyzmax(iaux1) ) then
          write(ulsost,texte(langue,84))
          write(ulsost,texte(langue,86)) xyzmax(iaux1),xyzmiz(iaux1)
          goto 520
        endif
c
        if ( xyzmaz(iaux1).lt.xyzmiz(iaux1) ) then
          write(ulsost,texte(langue,87))
          write(ulsost,texte(langue,88)) xyzmiz(iaux1),xyzmaz(iaux1)
          goto 520
        endif
c
        write(ulfido,1200) xyzmiz(iaux1), xyzmaz(iaux1)
c
        if ( xyzeps(iaux1).lt.0.d0 ) then
          xyzmiz(iaux1) = xyzmiz(iaux1) - 1.d0
          xyzmaz(iaux1) = xyzmaz(iaux1) + 1.d0
        else
          if ( xyzmiz(iaux1).gt.0.d0 ) then
            xyzmiz(iaux1) = xyzmiz(iaux1)*0.999d0
          elseif ( xyzmiz(iaux1).lt.0 ) then
            xyzmiz(iaux1) = xyzmiz(iaux1)*1.001d0
          else
            xyzmiz(iaux1) = -xyzeps(iaux1)*0.001d0
          endif
          if ( xyzmaz(iaux1).gt.0.d0 ) then
            xyzmaz(iaux1) = xyzmaz(iaux1)*1.001d0
          elseif ( xyzmaz(iaux1).lt.0.d0 ) then
            xyzmaz(iaux1) = xyzmaz(iaux1)*0.999d0
          else
            xyzmaz(iaux1) = xyzeps(iaux1)
          endif
        endif
c
      else
c
        xyzmiz(iaux1) = xyzmin(iaux1)
        xyzmaz(iaux1) = xyzmax(iaux1)
c
      endif
c
   52 continue
c
      endif
c
      endif
c
c====
c 6. questions - reponses pour le triedre
c====
c
      if ( option.ne.0 ) then
c
c 6.1. ==> on repere si le triedre est grosso modo dans l'enveloppe
c          du maillage a traiter
c
      iaux2 = 1
c
      do 61 , iaux1 = 1 , sdim
c
      if ( zoom ) then
        daux1 = xyzmiz(iaux1)
        daux2 = xyzmaz(iaux1)
      else
        daux1 = xyzmin(iaux1)
        daux2 = xyzmax(iaux1)
      endif
      daux3 = daux2 - daux1
c
      if ( daux3.gt.epsima ) then
c
        daux3 = 0.1d0 * daux3
c
        if ( daux1-daux3 .gt. 0.d0 ) then
          iaux2 = 0
        endif
c
        if ( daux2+daux3 .lt. 0.d0 ) then
          iaux2 = 0
        endif
c
      endif
c
   61 continue
c
c 6.2. ==> veut-on tracer le triedre ?
c
      if ( iaux2.eq.0 ) then
c
        triedr = 0
c
      else
c
   62 continue
c
      write (ulsost,texte(langue,110))
c
      call dmflsh ( iaux )
      read (ulenst,*,err=62,end=62) rep01
c
      if ( rep01.eq.'o' .or. rep01.eq.'O' .or.
     >     rep01.eq.'y' .or. rep01.eq.'Y' ) then
        triedr = 1
      elseif ( rep01.eq.'n' .or. rep01.eq.'N' ) then
        triedr = 0
      else
        goto 62
      endif
c
      write(ulfido,1000) rep01
c
      endif
c
      endif
c
c====
c 7. questions - reponses pour les couleurs
c====
c
      if ( option.ne.0 ) then
c
c 7.1. ==> interieur des faces
c
   71 continue
c
c 7.1.1. ==> choix general pour l'interieur des faces
c
      if ( codret.eq.0 ) then
c
      write (ulsost,texte(langue,30))
      write (ulsost,texte(langue,31))
      write (ulsost,texte(langue,32))
      write (ulsost,texte(langue,33))
      write (ulsost,texte(langue,35))
      write (ulsost,texte(langue,37))
      if ( nbcham.eq.0 ) then
        iaux1 = 6
      else
        iaux1 = 7
        write (ulsost,texte(langue,38))
      endif
      if ( rafdef.ne.0 ) then
        write (ulsost,texte(langue,39))
      endif
c
      endif
c
      call dmflsh ( iaux )
      read (ulenst,*,err=71,end=71) typcof
c
c 7.1.2. ==> controle
c
      if ( typcof.eq.10 ) then
        if ( rafdef.eq.0 ) then
          goto 71
        endif
      else
        if ( typcof.lt.0 .or. typcof.gt.iaux1 .or.
     >       typcof.eq.3 .or. typcof.eq.5 ) then
          goto 71
        endif
      endif
      write(ulfido,1102) typcof
c
c 7.1.3. ==> precision quand on colorie selon la qualite ou une fonction
c
      if ( typcof.eq.6 .or. typcof.eq.7 ) then
c
c 7.1.3.1. ==> le champ
c 7.1.3.1.1. ==> la qualite
c
        if ( typcof.eq.6 ) then
c
          abssol = .false.
          nrocha = -1
c
        else
c
c 7.1.3.1.2. ==> un vrai champ
c
          typcof = 6
c
c 7.1.3.1.2.1. ==> choix du champ a representer
c
 7131     continue
c
          write (ulsost,texte(langue,50))
c
          do 71311 , iaux1 = 1 , nbcham
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCACH', nompro
#endif
            saux08 = nocham(iaux1)
            call utcach ( saux08,
     >                    saux64,
     >                    nbcomp, nbtvch, typcha,
     >                    adnocp, adcaen, adcare, adcaca,
     >                    ulsort, langue, codret )
c
            write (ulsost,10000) saux64
c
            endif
c
71311     continue
c
          call dmflsh ( iaux )
          read (ulenst,*,err=7131,end=7131) nomcha
c
          call utlgut ( iaux2, nomcha,
     >                  ulsort, langue, codret )
c
          do 71312 , iaux1 = 1 , nbcham
c
            if ( codret.eq.0 ) then
c
            saux08 = nocham(iaux1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCACH', nompro
#endif
            call utcach ( saux08,
     >                    saux64,
     >                    nbcomp, nbtvch, typcha,
     >                    adnocp, adcaen, adcare, adcaca,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
            call utlgut ( iaux3, saux64,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
            if ( iaux2.eq.iaux3 ) then
              if ( nomcha(1:iaux2).eq.saux64(1:iaux2) ) then
                nrocha = iaux1
                write(ulfido,1000) nomcha(1:iaux2)
                goto 7132
              endif
            endif
c
            endif
c
71312     continue
c
          goto 7131
c
c 7.1.3.1.2.2. ==> choix de la composante a representer
c
 7132     continue
c
          if ( nbcomp.eq.1 ) then
c
            nrocmp = 1
            nomcmp = smem(adnocp+8)//smem(adnocp+9)
c
          else
c
71321       continue
c
            write (ulsost,texte(langue,51))
c
cgn            write (ulsost,10000) 'norme'
            do 71322 , iaux1 = 1 , nbcomp
              write (ulsost,10000) smem(adnocp+7+2*iaux1-1)//
     >                             smem(adnocp+7+2*iaux1)
71322       continue
c
            call dmflsh ( iaux )
            read (ulenst,*,err=7132,end=7132) nomcmp
            call utlgut ( iaux2, nomcmp,
     >                    ulsort, langue, codret )
c
cgn            do 71323 , iaux1 = 0 , nbcomp
            do 71323 , iaux1 = 1 , nbcomp
c
              saux16 = blan16
              if ( iaux1.eq.0 ) then
                iaux3 = 5
                saux16(1:iaux3) = 'norme'
              else
                call utlgut ( iaux3, smem(adnocp+7+2*iaux1-1),
     >                        ulsort, langue, codret )
                saux16(1:iaux3) = smem(adnocp+7+2*iaux1-1)(1:iaux3)
                if ( iaux3.eq.8 ) then
                  call utlgut ( iaux3, smem(adnocp+7+2*iaux1),
     >                          ulsort, langue, codret )
                  if ( iaux3.gt.0 ) then
                    saux16(9:8+iaux3) = smem(adnocp+7+2*iaux1)(1:iaux3)
                    iaux3 = iaux3 + 8
                  endif
                endif
              endif
c
              if ( iaux2.eq.iaux3 ) then
                if ( nomcmp(1:iaux2).eq.saux16(1:iaux2) ) then
                  nrocmp = iaux1
                  write(ulfido,1000) nomcmp
                  goto 7133
                endif
              endif
71323       continue
c
            goto 71321
c
          endif
c
c 7.1.3.1.2.3. ==> choix du pas de temps a representer
c
 7133     continue
c
          if ( nbtvch.eq.1 ) then
c
            nrotab = 1
c
          else
c
            call gmalot ( saux08, 'entier  ', 2*nbtvch, adtrav, codret )
c
71331       continue
c
            lgtrav = 0
            do 71332 , iaux1 = 1 , nbtvch
              iaux3 = imem(adcaen+nbinec*(iaux1-1)+1)
              do 71333 , iaux2 = 1 , lgtrav
                if ( imem(adtrav+iaux2-1).eq.iaux3 ) then
                  goto 71332
                endif
71333         continue
              imem(adtrav+lgtrav) = iaux3
              imem(adtrav+nbtvch+lgtrav) = iaux1
              lgtrav = lgtrav + 1
71332       continue
            if ( lgtrav.eq.1 ) then
              nrotab = 1
              goto 71336
            endif
c
            write (ulsost,texte(langue,52))
c
            do 71324 , iaux1 = 1 , lgtrav
              write (ulsost,11000) imem(adtrav+iaux1-1)
71324       continue
c
            call dmflsh ( iaux )
            read (ulenst,*,err=71331,end=71331) iaux2
c
            do 71335 , iaux1 = 1 , lgtrav
c
              if ( iaux2.eq.imem(adtrav+iaux1-1) ) then
                nrotab = imem(adtrav+nbtvch+iaux1-1)
                write(ulfido,1115) iaux2
                goto 71336
              endif
71335       continue
c
            goto 71331
c
71336       continue
c
            call gmlboj ( saux08, codret )
c
          endif
c
c 7.1.3.1.2.4. ==> le champ ou sa valeur absolue
c
 7134     continue
c
          write (ulsost,texte(langue,58))
          call dmflsh ( iaux )
          read (ulenst,*,err=7134,end=7134) saux02
          if ( saux02.eq.'ch' ) then
            abssol = .false.
          elseif ( saux02.eq.'va' ) then
            abssol = .true.
          else
            write (ulsost,texte(langue,59))
            goto 7134
          endif
          write(ulfido,1000) saux02
c
        endif
c
c 7.1.3.2. ==> type de coloriage
c
 7135     continue
c
        write (ulsost,texte(langue,60))
        write (ulsost,texte(langue,61))
        write (ulsost,texte(langue,62))
        write (ulsost,texte(langue,63))
        write (ulsost,texte(langue,64))
        call dmflsh ( iaux )
        read (ulenst,*,err=7135,end=7135) iaux1
        if ( iaux1.le.0 .or. iaux1.ge.5 ) then
          goto 7135
        endif
        write(ulfido,1101) iaux1
c
        typcof = typcof + iaux1 - 1
        if ( abssol ) then
          typcof = - typcof
        endif
c
c 7.1.3.6. ==> valeurs extremes si echelle fixe
c
        if ( abs(typcof).eq.7 .or. abs(typcof).eq.9 ) then
c
 7136   continue
c
          write (ulsost,texte(langue,65))
          call dmflsh ( iaux )
          read (ulenst,*,err=7136,end=7136) vafomi, vafoma
          if ( vafoma.le.vafomi ) then
            write(ulsost,texte(langue,66))
            write(ulsost,texte(langue,67)) vafomi, vafoma
            goto 7136
          endif
          write(ulfido,1200) vafomi, vafoma
c
        endif
c
      endif
c
c 7.2. ==> perimetre des faces
c
   72 continue
c
      write (ulsost,texte(langue,40))
      if ( typcof.ne.0 ) then
        iaux1 = 0
        write (ulsost,texte(langue,41))
      else
        iaux1 = 2
      endif
      write (ulsost,texte(langue,43))
      if ( rafdef.eq.0 ) then
        iaux2 = 3
      else
        write (ulsost,texte(langue,45))
        iaux2 = 4
      endif
c
      call dmflsh ( iaux )
      read (ulenst,*,err=72,end=72) typcop
c
      if ( typcop.lt.iaux1 .or. typcop.gt.iaux2 .or.
     >     typcop.eq.1 .or. typcop.eq.3 ) then
        goto 72
      endif
      write(ulfido,1101) typcop
c
c 7.3. ==> Trace du bord externe
c
   73 continue
c
      write (ulsost,texte(langue,90))
      write (ulsost,texte(langue,91))
      write (ulsost,texte(langue,92))
      write (ulsost,texte(langue,93))
c
      call dmflsh ( iaux )
      read (ulenst,*,err=73,end=73) typbor
c
      if ( typbor.lt.0 .or. typbor.gt.2 ) then
        goto 73
      endif
      write(ulfido,1101) typbor
c
c 7.4. ==> ronds autour des noeuds
c
   74 continue
c
      write (ulsost,texte(langue,100))
      write (ulsost,texte(langue,101))
      write (ulsost,texte(langue,102))
      write (ulsost,texte(langue,103))
c
      call dmflsh ( iaux )
      read (ulenst,*,err=74,end=74) optnoe
c
      if ( optnoe.lt.0 .or. optnoe.gt.2 ) then
        goto 74
      endif
      write(ulfido,1101) optnoe
c
      endif
c
      write(ulfido,1000) ' '
c
 1000 format(a)
 1101 format(i1)
 1102 format(i2)
 1115 format(i15)
 1200 format(5g15.6)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
