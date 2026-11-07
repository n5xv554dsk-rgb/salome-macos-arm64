      subroutine infve0 ( action, numblo, numniv, numfic,
     >                    infsup, typcof, typcop, typbor, optnoe,
     >                    porpay, zoom, triedr,
     >                    nbcham, nocham,
     >                    nomcha, nomcmp, nrocha, nrocmp, nrotab,
     >                    coonoe,
     >                    somare, np2are, hetare, merare,
     >                    posifa, facare,
     >                    aretri, hettri, nivtri, nintri,
     >                    voltri, pypetr,
     >                    famtri,
     >                    arequa, hetqua, nivqua, ninqua,
     >                    volqua, pypequ,
     >                    famqua,
     >                    nnoeca, nareca, ntreca, nqueca,
     >                    nnoeho, ntreho, nqueho,
     >                    lgnoin, lgtrin, lgquin,
     >                    nnoein, ntrein, nquein,
     >                    decanu,
     >                    anglex, angley, anglez,
     >                    xyzmiz, xyzmaz, vafomi, vafoma,
     >                    tbaux1, tbaux2,
     >                    nublfa, nubnvo,
     >                    ulsost,
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
c   INformation : Fichier VEctoriel - Trace
c   --            -       --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . action . e   . char8  . action en cours                            .
c . numblo . e   .   1    . numero du bloc a tracer                    .
c .        .     .        . 0 : trace du domaine global                .
c . numniv . e   .   1    . numero du niveau a tracer                  .
c .        .     .        . -1 : tous les niveaux                      .
c . numfic . es  .   1    . numero du fichier a ecrire                 .
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
c .        .     .        .   4 : idem 2, en niveau de gris            .
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
c . nbcham . e   .   1    . nombre de champs definis                   .
c . nocham . e   . nbcham . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . nomcha . e   . char64 . nom du champ retenu pour le coloriage      .
c . nomcmp . e   .   1    . nom de la composante retenue               .
c . nrocha . e   .   1    . nunero du champ retenu pour le coloriage   .
c .        .     .        . -1 si coloriage selon la qualite           .
c . nrocmp . e   .   1    . numero de la composante retenue            .
c . nrotab . e   .   1    . numero du tableau associe au pas de temps  .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . merare . e   . nbarto . mere de chaque arete                       .
c . np2are . e   . nbarto . numero du noeud p2 milieu de l'arete       .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . nintri . e   . nbtrto . noeud interne au triangle                  .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr .  s  .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . famtri . e   . nbtrto . famille des triangles                      .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . ninqua . e   . nbquto . noeud interne au quadrangle                .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ .  s  .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . nnoeca . e   . renoto . noeuds en entree dans le calcul            .
c . nareca . e   . rearto . nro des aretes dans le calcul en entree    .
c . ntreca . e   . retrto . nro des triangles dans le calcul en entree .
c . nqueca . e   . requto . nro des quads dans le calcul en entree     .
c . nnoeho . e   . renoto . nro des noeuds dans HOMARD en entree       .
c . ntreho . e   . retrto . nro des triangles dans HOMARD en entree    .
c . nqueho . e   . requto . nro des quads dans HOMARD en entree        .
c . decanu . e   .  -1:7  . decalage des numerotations selon le type   .
c . anglex . e   .   1    . angle de rotation autour de x              .
c . angley . e   .   1    . angle de rotation autour de y              .
c . anglez . e   .   1    . angle de rotation autour de z              .
c . xyzmiz . e   .   1    . abscisse (i=1), ordonnee (i=2) et  .
c .        .     .        . cote (i=3) minimales de la fenetre de zoom .
c . xyzmaz . e   .   1    . abscisse (i=1), ordonnee (i=2) et  .
c .        .     .        . cote (i=3) maximales de la fenetre de zoom .
c . vafomi . e   .   1    . minimum de l'echelle de la fonction        .
c . vafoma . e   .   1    . maximum de l'echelle de la fonction        .
c . tbaux1 . e   . nbftri/. donne un numero equivalent a une famille   .
c .        .     . nbfqua . selon que l'orientation est gardee ou non  .
c . nublfa . e   .-nbquto:. numero de blocs des faces                  .
c .        .     . nbtrto .   .
c . nubnvo . e   .   *    . . si numblo>0 : numero de blocs des volumes.
c .        .     .        . . si numniv >=0 : niveau des volumes       .
c .        .     .        . Rangement :                                .
c .        .     .        . les tetraedres                             .
c .        .     .        . les hexaedres                              .
c .        .     .        . les pyramides                              .
c .        .     .        . les pentaedres                             .
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
      parameter ( nompro = 'INFVE0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "envca1.h"
#include "envada.h"
#include "nomber.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsost
      integer numblo, numniv,numfic
      integer infsup, typcof, typcop, typbor, optnoe, porpay, triedr
      integer nbcham
      integer nrocha, nrocmp, nrotab
      integer somare(2,nbarto)
      integer np2are(nbarto), merare(nbarto), hetare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer aretri(nbtrto,3), hettri(nbtrto), nivtri(nbtrto)
      integer nintri(nbtrto)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer famtri(nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto), nivqua(nbquto)
      integer ninqua(nbquto)
      integer volqua(2,nbquto), pypequ(2,*)
      integer famqua(nbquto)
      integer nnoeca(renoto)
      integer nareca(rearto), ntreca(retrto), nqueca(requto)
      integer nnoeho(*), ntreho(*), nqueho(*)
      integer lgnoin, lgtrin, lgquin
      integer nnoein(*), ntrein(*), nquein(*)
      integer decanu(-1:7)
      integer tbaux1(*), tbaux2(-nbquto:*)
      integer nublfa(-nbquto:nbtrto), nubnvo(*)
c
      double precision anglex, angley, anglez
      double precision xyzmiz(sdim), xyzmaz(sdim)
      double precision vafomi, vafoma
c
      logical zoom
c
      character*8 action
      character*8 nocham(nbcham)
      character*16 nomcmp
      character*64 nomcha
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nuroul, lnomfl
      integer ptrav1, ptrav2
      integer nbquvi, nbtrvi, nbarvi
      integer adquvi, adtrvi, adarvi
      integer adquva, adtrva
      integer lgtit1, lgtit2
c
      integer codre1, codre2, codre3
      integer codre0
c
      character*8 saux08
      character*8 noquvi, notrvi, noarvi
      character*8 noquva, notrva
      character*8 ntrav1, ntrav2
      character*20 titre0
      character*100 titre1, titre2
      character*200 nomflo
c
      integer nbmess
      parameter ( nbmess = 20 )
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
      texte(1,4) = '(/,''Trace du domaine global'')'
      texte(1,5) = '(/,''Trace du bloc numero'',i6)'
      texte(1,6) = '(''Trace de tous les niveaux'')'
      texte(1,7) = '(''Trace du niveau numero'',i6)'
      texte(1,9) = '(''Nombre de '',a,'' a visualiser :'',i10)'
      texte(1,10) = '(''titre'',i1,'' : '',a)'
      texte(1,11) = '(''Projection'')'
      texte(1,12) = '(''Caracterisation de la fonction'')'
      texte(1,18) = '(''Action en cours : '',a)'
      texte(1,20) = '(/,''Creation du fichier Xfig numero'',i4)'
c
      texte(2,4) = '(/,''Writings of the whole domain)'
      texte(2,5) = '(/,''Writings for the block #'',i6)'
      texte(2,6) = '(''Writings of all the levels'')'
      texte(2,7) = '(''Writings for the level #'',i6)'
      texte(2,9) = '(''Number of '',a,'' to be drawn :'',i10)'
      texte(2,10) = '(''titre'',i1,'' : '',a)'
      texte(2,11) = '(''Projection'')'
      texte(2,12) = '(''Characteristics of function'')'
      texte(2,18) = '(''Current action : '',a)'
      texte(2,20) = '(/,''Creation of Xfig file #'',i4)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      if ( numblo.eq.0 ) then
        write (ulsort,texte(langue,4))
      else
        write (ulsort,texte(langue,5)) numblo
      endif
      if ( numniv.eq.-1 ) then
        write (ulsort,texte(langue,6))
      else
        write (ulsort,texte(langue,7)) numniv
      endif
      write (ulsort,texte(langue,18)) action
#endif
c
c====
c 2. recherche des elements et transformations des coordonnees
c    ce travail est a faire pour tous les types de sorties
c====
c
c 2.1. ==> tableaux de travail
c
      if ( codret.eq.0 ) then
c
c     tableau nnarvi
      iaux = 6*nbarto
      call gmalot ( noarvi, 'entier  ', iaux, adarvi, codre1 )
c
c     tableau nntrvi
      iaux = 10*nbtrac
      call gmalot ( notrvi, 'entier  ', iaux, adtrvi, codre2 )
c
c     tableau nnquvi
      iaux = 12*nbquac
      call gmalot ( noquvi, 'entier  ', iaux, adquvi, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 2.2. ==> creation de la liste des elements visualisables
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFVE2', nompro
#endif
      call infve2 ( coonoe,
     >              somare, np2are,
     >              hetare, merare,
     >              posifa, facare,
     >              aretri, hettri, nivtri, nintri,
     >              voltri, pypetr,
     >              famtri,
     >              arequa, hetqua, nivqua, ninqua,
     >              volqua, pypequ,
     >              famqua,
     >              infsup, typbor, tbaux1,
     >              zoom, xyzmiz, xyzmaz,
     >              tbaux2,
     >              numniv, numblo, nublfa, nubnvo,
     >              imem(adquvi), nbquvi,
     >              imem(adtrvi), nbtrvi,
     >              imem(adarvi), nbarvi,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) mess14(langue,3,1), nbarvi
      write (ulsort,texte(langue,9)) mess14(langue,3,2), nbtrvi
      write (ulsort,texte(langue,9)) mess14(langue,3,4), nbquvi
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmmod ( noarvi, adarvi,  6,  6, nbarto, nbarvi, codre1 )
      call gmmod ( notrvi, adtrvi, 10, 10, nbtrac, nbtrvi, codre2 )
      call gmmod ( noquvi, adquvi, 12, 12, nbquac, nbquvi, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 2.3. ==> projection selon l'angle de vue desire
c          ("trav1" contient la liste "coopro" des coordonnees
c          projetees des noeuds)
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11))
#endif
c
c     tableau coopro
      iaux = 3*(nbnoto+12)
      call gmalot ( ntrav1, 'reel    ', iaux, ptrav1, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFVE3', nompro
#endif
      call infve3 ( coonoe,
     >              anglex, angley, anglez,
     >              zoom, triedr, xyzmiz, xyzmaz,
     >              rmem(ptrav1),
     >              ulsort, langue, codret )
c
      endif
c
c 2.3. ==> determination de la fonction
c
      if ( abs(typcof).ge.6 .and. abs(typcof).le.9 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12))
#endif
c
c     tableau notrva
      call gmalot ( notrva, 'reel    ', nbtrvi, adtrva, codre1 )
c
c     tableau noquva
      call gmalot ( noquva, 'reel    ', nbquvi, adquva, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 2.3.1. ==> recherche des valeurs du champ
c
      if ( nrotab.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFFRE', nompro
#endif
        call inffre ( iaux, rmem(adtrva), rmem(adquva), titre0,
     >                nocham(nrocha), nrocmp, nrotab,
     >                nbtrvi, nbquvi,
     >                imem(adtrvi), imem(adquvi),
     >                nnoeca, ntreca, nqueca,
     >                nnoeho, ntreho, nqueho,
     >                lgnoin, lgtrin, lgquin,
     >                nnoein, ntrein, nquein,
     >                decanu,
     >                ulsort, langue, codret )
c
        endif
c
      else
c
c 2.3.2. ==> recherche des qualites
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFVE4', nompro
#endif
        call infve4 ( rmem(adtrva), rmem(adquva),
     >                coonoe, somare, aretri, arequa,
     >                nbtrvi, nbquvi,
     >                imem(adtrvi), imem(adquvi),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      endif
c
c====
c 6. ecriture du maillage sous forme xfig
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. ecriture du maillage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      numfic = numfic + 1
c
      write (ulsort,texte(langue,20)) numfic
      if ( ulsost.ne.ulsort ) then
        write (ulsost,texte(langue,20)) numfic
      endif
c
c 6.1 ==> ouverture du fichier
c
      if ( codret.eq.0 ) then
c
c               12345678
      saux08 = '        '
      if ( action(1:7).eq.'info_av' ) then
        saux08(1:4) = 'avad'
      elseif ( action(1:7).eq.'info_ap' ) then
        saux08(1:4) = 'apad'
      endif
      iaux = -6
      call utulbi ( nuroul, nomflo, lnomfl,
     >                iaux, saux08, nbiter, numfic,
     >              ulsort, langue, codret )
c
      endif
c
c 6.2. ==> titres
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFVE6', nompro
#endif
      call infve6 ( action, numblo, numniv,
     >              infsup, typcof,
     >              nomcha, nomcmp, nrocha,
     >              titre0,
     >              titre1, lgtit1, titre2, lgtit2,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) 1, titre1
      write (ulsort,texte(langue,10)) 2, titre2
#endif
c
c 6.3. ==> tableaux de travail
c
      if ( codret.eq.0 ) then
c
c     tableau liste pour pppmai
      iaux = nbtrvi + nbquvi
      call gmalot ( ntrav2, 'entier  ', iaux, ptrav2, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
c 6.4. ==> trace
c
      if ( codret.eq.0 ) then
c
      jaux = porpay
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PPPXMA', nompro
#endif
c
      call pppxma (
     >   infsup, typcof, typcop, typbor, optnoe,
     >   jaux, zoom, triedr,
     >   degre, sdim, mailet, nivsup,
     >   titre1(1:lgtit1), titre2(1:lgtit2),
     >   nbarvi, nbtrvi, nbquvi,
     >   imem(adarvi), imem(adtrvi), imem(adquvi),
     >   rmem(ptrav1), imem(ptrav2),
     >   nnoeca, nareca, ntreca, nqueca,
     >   rmem(adtrva), rmem(adquva), vafomi, vafoma,
     >   nuroul, nomflo, lnomfl, ulsost,
     >   ulsort, langue, codret )
c
      endif
c
c 6.5. ==> fermeture du fichier
c
      if ( codret.eq.0 ) then
c
      call gufeul ( nuroul , codret)
c
      endif
c
      endif
c
c====
c 7. menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( noarvi, codre1 )
      call gmlboj ( notrvi, codre2 )
      call gmlboj ( noquvi, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      if ( abs(typcof).ge.6 .and. abs(typcof).le.9 ) then
c
        call gmlboj ( notrva, codre1 )
        call gmlboj ( noquva, codre2 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
      endif
c
      endif
c
c====
c 5. la fin
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
cgn      stop
c
      end
