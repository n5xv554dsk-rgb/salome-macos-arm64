      subroutine deinnu ( nomail, nohind,
     >                    tyconf, pilraf, pilder, nivmax, nivmin,
     >                    typseh, typseb, seuilh, seuilb, usacmp,
     >                    filada, diammi, nbzord, iniada,
     >                    nbsoci,
     >                    decare, decfac,
     >                    povoso, voisom,
     >                    noempo,
     >                    somare, hetare, filare, merare,
     >                    np2are, posifa, facare,
     >                    aretri, hettri, filtri, pertri, nivtri,
     >                    voltri, pypetr,
     >                    arequa, hetqua, filqua, perqua, nivqua,
     >                    volqua,
     >                    tritet, hettet, filtet,
     >                    quahex, hethex, filhex,
     >                    facpyr, hetpyr,
     >                    facpen, hetpen, filpen,
     >                    tabaux,
     >                    lgopts, taopts,
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
c traitement des DEcisions - INitialisations - Non Uniforme
c                --          --                -   -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . nohind . e   .  ch8   . nom de l'objet contenant l'indicateur      .
c . tyconf . e   .   1    .  0 : conforme (defaut)                     .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2                    .
c .        .     .        .  2 : non-conforme avec 1 seul noeud        .
c .        .     .        .      pendant par arete                     .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c . pilraf . e   .   1    . pilotage du raffinement                    .
c .        .     .        . -1 : raffinement uniforme                  .
c .        .     .        .  0 : pas de raffinement                    .
c .        .     .        .  1 : raffinement libre                     .
c .        .     .        .  2 : raff. libre homogene en type d'element.
c . pilder . e   .   1    . pilotage du deraffinement                  .
c .        .     .        . 0 : pas de deraffinement                   .
c .        .     .        . 1 : deraffinement libre                    .
c .        .     .        . -1 : deraffinement uniforme                .
c . nivmax . e   .   1    . niveau max a ne pas depasser en raffinement.
c . nivmin . e   .   1    . niveau min a ne pas depasser en deraffinemt.
c . typseh . e   .   1    . type de seuil haut                         .
c .        .     .        . 1 : absolu                                 .
c .        .     .        . 2 : relatif                                .
c .        .     .        . 3 : pourcentage d'entites                  .
c .        .     .        . 4 : moyenne + nh*ecart-type                .
c .        .     .        . 5 : cible en nombre de noeuds              .
c . typseb . e   .   1    . type de seuil bas                          .
c .        .     .        . 1 : absolu                                 .
c .        .     .        . 2 : relatif                                .
c .        .     .        . 3 : pourcentage d'entites                  .
c .        .     .        . 4 : moyenne - nb*ecart-type                .
c . seuilh . e   .   1    . borne superieure de l'erreur (absolue,     .
c .        .     .        . relatif, pourcentage d'entites ou nh)      .
c . seuilb . e   .   1    . borne inferieure de l'erreur (absolue,     .
c .        .     .        . relatif, pourcentage d'entites ou nb)      .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . filada . e   .   1    . filtrage de l'adaptation                   .
c .        .     .        . 0 : pas de filtrage                        .
c .        .     .        . >0 : filtrage                              .
c . diammi . e   .   1    . diametre minimal voulu                     .
c . nbzord . e   .    1   . nombre de zones a raffiner/deraffiner      .
c . iniada . e   .   1    . initialisation de l'adaptation             .
c .        .     .        . 0 : on garde tout (defaut)                 .
c .        .     .        .-1 : reactivation des mailles ou aucun      .
c .        .     .        .     indicateur n'est defini                .
c .        .     .        . 1 : raffinement des mailles ou aucun       .
c .        .     .        .     indicateur n'est defini                .
c . nbsoci . e   .   1    . cible en nombre de sommets  (-1 si non)    .
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . voisom . e   . nvosom . aretes voisines de chaque noeud            .
c . noempo . e   . nbmpto . numeros des noeuds associes aux mailles    .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . merare . e   . nbarto . mere des aretes                            .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . pertri . e   . nbtrto . pere des triangles                         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . tabaux . a   . -nbquto. tableau auxiliaire sur les faces           .
c .        .     . :nbtrto.  (quad. + tri.)                            .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      parameter ( nompro = 'DEINNU' )
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
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*8 nomail, nohind
c
      integer tyconf, pilraf, pilder, nivmax, nivmin
      integer typseh, typseb
      integer usacmp
      integer nbzord
      integer filada, iniada
      integer nbsoci
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer povoso(0:nbnoto), voisom(*)
      integer noempo(nbmpto)
      integer somare(2,nbarto)
      integer hetare(nbarto), filare(nbarto), merare(nbarto)
      integer np2are(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer aretri(nbtrto,3), hettri(nbtrto)
      integer filtri(nbtrto), pertri(nbtrto), nivtri(nbtrto)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer arequa(nbquto,4), hetqua(nbquto)
      integer filqua(nbquto), perqua(nbquto), nivqua(nbquto)
      integer volqua(2,nbquto)
      integer tritet(nbtecf,4), hettet(nbteto), filtet(nbteto)
      integer quahex(nbhecf,6), hethex(nbheto), filhex(nbheto)
      integer facpyr(nbpycf,5), hetpyr(nbpyto)
      integer facpen(nbpecf,5), hetpen(nbpeto), filpen(nbpeto)
      integer tabaux(-nbquto:nbtrto)
c
      double precision seuilb, seuilh
      double precision diammi
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer pcoono
      integer adnoin, adnorn, adnosu
      integer adarin, adarrn, adarsu
      integer adtrin, adtrrn, adtrsu
      integer adquin, adqurn, adqusu
      integer adtein, adtern, adtesu
      integer adhein, adhern, adhesu
      integer adpyin, adpyrn, adpysu
      integer adpein, adpern, adpesu
      integer adzord
      integer adtra3, adtra4
      integer nbvnoe, nbvare
      integer nbvtri, nbvqua
      integer nbvtet, nbvhex, nbvpyr, nbvpen
      integer dimcst, adcocs
c
      integer codre0, codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8
c
      integer typind, ncmpin
c
      character*8 ncazor
      character*8 obfigr, obfidm
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1, ntrav2, ntrav3, ntrav4
      character*8 ntrano, ntraar, ntratr, ntraqu
      character*8 ntrate, ntrahe, ntrapy, ntrape
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''Erreur de programmation etape 3'')'
      texte(1,5) = '(''Coordonnee '',a,'' constante :'',g13.5)'
      texte(1,6) = '(/,5x,''Filtrage par les groupes'')'
      texte(1,7) = '(/,5x,''Filtrage par le diametre minimal'')'
c
      texte(2,4) = '(''Programming error in stage 3'')'
      texte(2,5) = '(''Coordinate '',a,'' constant:'',g13.5)'
      texte(2,6) = '(/,5x,''Filtering by the groups'')'
      texte(2,7) = '(/,5x,''Filtering by the minimal diametre'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'tyconf', tyconf
      write (ulsort,90002) 'pilraf', pilraf
      write (ulsort,90002) 'pilder', pilder
      write (ulsort,90002) 'usacmp', usacmp
      write (ulsort,90002) 'nivmax', nivmax
      write (ulsort,90002) 'nivmin', nivmin
      write (ulsort,90002) 'typseh', typseh
      write (ulsort,90004) 'seuilh', seuilh
      write (ulsort,90002) 'typseb', typseb
      write (ulsort,90004) 'seuilb', seuilb
      write (ulsort,90002) 'filada', filada
      write (ulsort,90002) 'nbzord', nbzord
      write (ulsort,90004) 'diammi', diammi
#endif
c
      obfigr = taopts(29)
cgn      write (ulsort,90003) 'obfigr', obfigr
      obfidm = taopts(28)
cgn      write (ulsort,90003) 'obfidm', obfidm
c
c====
c 2. gestion des tableaux
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c 2.2. ==> tableaux
c
      if ( nbzord.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
        iaux = 57
        call utad01 ( iaux, nhnoeu,
     >                  jaux,
     >                  jaux,   jaux,   jaux,
     >                pcoono,   jaux,   jaux, adcocs,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nhnoeu, 2, dimcst, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( dimcst.ne.0 ) then
          write (ulsort,texte(langue,5)) saux01(dimcst), rmem(adcocs)
        endif
#endif
c
      endif
c
c====
c 3. Decompte des nombres de valeurs pour les 'faux' indicateurs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Decompte ; codret', codret
#endif
c
      nbvnoe = 0
      nbvare = 0
      nbvtri = 0
      nbvqua = 0
      nbvtet = 0
      nbvpyr = 0
      nbvhex = 0
      nbvpen = 0
c
c 3.1. ==> Uniforme et filtre
c
      if ( ( pilraf.eq.-1 .or. pilder.eq.-1 ) .and.
     >     ( filada.ne.0 .or. diammi.gt.0.d0 ) ) then
c
        if ( codret.eq.0 ) then
c
        if ( filada.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINI5', nompro
#endif
        call deini5 ( obfigr,
     >                nbvnoe, nbvare,
     >                nbvtri, nbvqua,
     >                nbvtet, nbvhex, nbvpyr, nbvpen,
     >                ulsort, langue, codret )
c
        endif
c
        endif
        typind = 1
c
c 3.2. ==> Par zone
c
      elseif ( ( pilraf.gt.0 .or. pilder.gt.0 ) .and.
     >           nbzord.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        nbvare = nbarto
        typind = 0
c
        endif
c
c 3.3. ==> Cas du raffinement ou deraffinement par un indicateur
c
      elseif ( ( pilraf.gt.0 .or. pilder.gt.0 ) .and.
     >           nbzord.eq.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINI0', nompro
#endif
        call deini0 ( nohind, typind, ncmpin,
     >                nbvnoe, nbvare,
     >                nbvtri, nbvqua,
     >                nbvtet, nbvhex, nbvpyr, nbvpen,
     >                adnoin, adnorn, adnosu,
     >                adarin, adarrn, adarsu,
     >                adtrin, adtrrn, adtrsu,
     >                adquin, adqurn, adqusu,
     >                adtein, adtern, adtesu,
     >                adhein, adhern, adhesu,
     >                adpyin, adpyrn, adpysu,
     >                adpein, adpern, adpesu,
     >                ulsort, langue, codret )
c
        endif
c
c 3.4. ==> Autres cas impossibles
c
      elseif ( pilder.ne.-1 ) then
c
        codret = 2
        write (ulsort,texte(langue,4))
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typind', typind
      write (ulsort,90002) 'ncmpin', ncmpin
      write (ulsort,90002)
     >' nbvnoe, nbvare, nbvtri, nbvqua, nbvtet, nbvhex, nbvpyr, nbvpen',
     >                     nbvnoe, nbvare,
     >                     nbvtri, nbvqua,
     >                     nbvtet, nbvhex, nbvpyr, nbvpen
#endif
c
c====
c 4. Allocations des eventuels tableaux entiers :
c    . pour une adaptation selon des zones
c    . pour un indicateur reel
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Allocations ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( typind.eq.0 .or. typind.eq.3 ) then
c
        if ( nbvnoe.eq.0 ) then
          iaux = 0
        else
          iaux = nbnoto
        endif
        call gmalot ( ntrano, 'entier  ', iaux, adnoin, codre1 )
c
        if ( nbvare.eq.0 ) then
          iaux = 0
        else
          iaux = nbarto
        endif
        call gmalot ( ntraar, 'entier  ', iaux, adarin, codre2 )
c
        if ( nbvtri.eq.0 ) then
          iaux = 0
        else
          iaux = nbtrto
        endif
        call gmalot ( ntratr, 'entier  ', iaux, adtrin, codre3 )
c
        if ( nbvqua.eq.0 ) then
          iaux = 0
        else
          iaux = nbquto
        endif
        call gmalot ( ntraqu, 'entier  ', iaux, adquin, codre4 )
c
        if ( nbvtet.eq.0 ) then
          iaux = 0
        else
          iaux = nbteto
        endif
        call gmalot ( ntrate, 'entier  ', iaux, adtein, codre5 )
c
        if ( nbvpyr.eq.0 ) then
          iaux = 0
        else
          iaux = nbpyto
        endif
        call gmalot ( ntrapy, 'entier  ', iaux, adpyin, codre6 )
c
        if ( nbvhex.eq.0 ) then
          iaux = 0
        else
          iaux = nbheto
        endif
        call gmalot ( ntrahe, 'entier  ', iaux, adhein, codre7 )
c
        if ( nbvpen.eq.0 ) then
          iaux = 0
        else
          iaux = nbpeto
        endif
        call gmalot ( ntrape, 'entier  ', iaux, adpein, codre8 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >                 codre6, codre7, codre8 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5,
     >                 codre6, codre7, codre8 )
c
      endif
c
      endif
c
c====
c 5. Remplissage des tableaux entiers
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. remplissage ; codret', codret
#endif
c
      if ( pilraf.gt.0 .or. pilder.gt.0 ) then
c
c 5.1. ==> Cas du raffinement ou deraffinement par des zones
c          geometriques : on convertit en un indicateur entier sur
c          les aretes
c
        if ( nbzord.ne.0 ) then
c
c 5.1.1. ==> Recuperation de la structure
c
          if ( codret.eq.0 ) then
c
          ncazor = taopts(19)
#ifdef _DEBUG_HOMARD_
          call gmprsx (nompro, ncazor )
#endif
c
          call gmadoj ( ncazor, adzord, iaux, codre1 )
          call gmalot ( ntrav1, 'entier  ', nbnoto, adnosu, codre2 )
          call gmalot ( ntrav2, 'entier  ', nbarto, adarsu, codre3 )
c
          codre0 = min ( codre1, codre2, codre3 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3 )
c
          endif
c
c 5.1.2. ==> Deploiement
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEINZR', nompro
#endif
          call deinzr ( nbzord, rmem(adzord),
     >                  rmem(pcoono), dimcst, rmem(adcocs),
     >                  somare, hetare,
     >                  imem(adnosu), imem(adarsu), imem(adarin),
     >                  ulsort, langue, codret )
c
          endif
c
c 5.3. ==> Cas du raffinement ou deraffinement par un indicateur reel :
c          on convertit en un indicateur entier
c
        else
c
          if ( typind.eq.3 ) then
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINRI', nompro
#endif
            call deinri
     >       ( pilraf, pilder,
     >         typseh, typseb, seuilh, seuilb, nbsoci,
     >         usacmp,
     >         nbvpen, nbvpyr, nbvhex, nbvtet,
     >         nbvqua, nbvtri, nbvare, nbvnoe,
     >         imem(adnosu), rmem(adnorn), imem(adnoin),
     >         imem(adarsu), rmem(adarrn), imem(adarin),
     >         imem(adtrsu), rmem(adtrrn), imem(adtrin),
     >         imem(adqusu), rmem(adqurn), imem(adquin),
     >         imem(adtesu), rmem(adtern), imem(adtein),
     >         imem(adhesu), rmem(adhern), imem(adhein),
     >         imem(adpysu), rmem(adpyrn), imem(adpyin),
     >         imem(adpesu), rmem(adpern), imem(adpein),
     >         ulsort, langue, codret)
c
            endif
c
          endif
c
        endif
c
      endif
c
c====
c 6. Elaboration des decisions sur les faces et les aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Elaboration ; codret', codret
#endif
c
c 6.1. ==> Cas du raffinement/deraffinement uniforme
c
      if ( pilraf.eq.-1 .or. pilder.eq.-1 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEINUN', nompro
#endif
        call deinun ( pilraf, pilder, nivmax, nivmin,
     >                decfac, decare,
     >                hetare,
     >                hettri,
     >                hetqua,
     >                ulsort, langue, codret )
c
        endif
c
c 6.2. ==> Zone ou indicateur
c
      else
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEINII', nompro
#endif
        call deinii
     >       ( pilraf, pilder, nivmax, nivmin, iniada,
     >         decare, decfac,
     >         somare, hetare, filare, merare, np2are,
     >         posifa, facare,
     >         aretri, hettri, filtri, pertri, nivtri,
     >         arequa, hetqua, filqua, perqua, nivqua,
     >         tritet, hettet, filtet,
     >         quahex, hethex, filhex,
     >         facpyr, hetpyr,
     >         facpen, hetpen, filpen,
     >         nbvpen, nbvpyr, nbvhex, nbvtet,
     >         nbvqua, nbvtri, nbvare, nbvnoe,
     >         imem(adnosu), imem(adnoin),
     >         imem(adarsu), imem(adarin),
     >         imem(adtrsu), imem(adtrin),
     >         imem(adqusu), imem(adquin),
     >         imem(adtesu), imem(adtein),
     >         imem(adhesu), imem(adhein),
     >         imem(adpysu), imem(adpyin),
     >         imem(adpesu), imem(adpein),
     >         ulsort, langue, codret)
c
        endif
c
      endif
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      iaux = 2
      call delist ( nomail, 'DEINII', iaux,
     >              lgopts, taopts,
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 7. Filtrages
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. Filtrages ; codret', codret
#endif
cgn      write(*,*)'decare'
cgn      write(*,91030)(decare(iaux),iaux=1,nbarto)
cgn      write(*,*)'decfac quad'
cgn      write(*,91030)(decfac(iaux),iaux=-nbquto,-1)
cgn      write(*,*)'decfac tria'
cgn      write(*,91030)(decfac(iaux),iaux=1,nbtrto)
c
      if ( filada.ne.0 .or. diammi.gt.0.d0 ) then
c
c 7.1. ==> Tableaux de travail
c
        if ( codret.eq.0 ) then
c
        call gmalot ( ntrav3, 'entier  ', nbarto, adtra3, codre1 )
        iaux = nbquto + 1 + nbtrto
        call gmalot ( ntrav4, 'entier  ',   iaux, adtra4, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
cgn      write(*,91030)(decare(iaux),iaux=1,nbarto)
cgn      write(*,91030)(decfac(iaux),iaux=1,nbtrto)
c
c 7.2. ==> Applications du ou des filtrages
c 7.2.1. ==> Filtrage par les groupes
c
        if ( filada.ne.0 ) then
c
c 7.2.1.1. ==> Filtrage effectif
c
          if ( codret.eq.0 ) then
c
          write (ulsort,texte(langue,6))
c
          iaux = 1
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'DEINFI-groupes', nompro
#endif
          call deinfi ( iaux, obfigr,
     >                  decare, decfac, iniada,
     >                  imem(adtra3), imem(adtra4),
     >                  povoso, voisom,
     >                  noempo,
     >                  somare,
     >                  aretri,
     >                  arequa,
     >                  tritet,
     >                  quahex,
     >                  facpyr,
     >                  facpen,
     >                  ulsort, langue, codret )
cgn      call gmprsx ( nompro, ntrav3 )
cgn      call gmprsx ( nompro, ntrav4 )
cgn      write(*,91030)(decare(iaux),iaux=1,nbarto)
cgn      write(*,91030)(decfac(iaux),iaux=1,nbtrto)
c
          endif
c
c 7.2.1.2. ==> Affichage final
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DECPTE', nompro
#endif
          call decpte ( pilraf, pilder,
     >                  decare, decfac,
     >                  hettri, hetqua,
     >                  tritet, hettet,
     >                  quahex, hethex,
     >                  facpyr, hetpyr,
     >                  facpen, hetpen,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
c 7.2.2. ==> Filtrage par le diametre minimal
c
        if ( diammi.gt.0.d0 ) then
c
c 7.2.2.1. ==> Filtrage effectif
c
          if ( codret.eq.0 ) then
c
          write (ulsort,texte(langue,7))
c
          iaux = 0
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'DEINFI-diametre', nompro
#endif
          call deinfi ( iaux, obfidm,
     >                  decare, decfac, iniada,
     >                  imem(adtra3), imem(adtra4),
     >                  povoso, voisom,
     >                  noempo,
     >                  somare,
     >                  aretri,
     >                  arequa,
     >                  tritet,
     >                  quahex,
     >                  facpyr,
     >                  facpen,
     >                  ulsort, langue, codret )
cgn      write(*,*)'decare'
cgn      write(*,91030)(decare(iaux),iaux=1,nbarto)
cgn      write(*,*)'decfac quad'
cgn      write(*,91030)(decfac(iaux),iaux=-nbquto,-1)
cgn      write(*,*)'decfac tria'
cgn      write(*,91030)(decfac(iaux),iaux=1,nbtrto)
cgn      call gmprsx ( nompro, ntrav3 )
cgn      call gmprsx ( nompro, ntrav4 )
c
          endif
c
c 7.2.2.2. ==> Affichage final
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DECPTE', nompro
#endif
          call decpte ( pilraf, pilder,
     >                  decare, decfac,
     >                  hettri, hetqua,
     >                  tritet, hettet,
     >                  quahex, hethex,
     >                  facpyr, hetpyr,
     >                  facpen, hetpen,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
cgn      do 7777 , iaux = 1 , nbarto
cgn        if ( decare(iaux).ne.0 ) then
cgn          write (ulsort,90001) '.. arete e/d', iaux,
cgn     >    hetare(iaux), decare(iaux), somare(1,iaux), somare(2,iaux)
cgn        endif
cgn 7777 continue
c
c====
c 8. Corrections selon le mode de conformite
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. correction ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINI4', nompro
#endif
      call deini4 ( tyconf,
     >              decare, decfac,
     >              hetare, filare,
     >              aretri, hettri, filtri,
     >              voltri, pypetr,
     >              arequa, hetqua,
     >              volqua,
     >              tritet, quahex, facpen, facpyr,
     >              tabaux,
     >              ulsort, langue, codret)
cgn      write(*,*)'decare'
cgn      write(*,91030)(decare(iaux),iaux=1,nbarto)
cgn      write(*,*)'decfac quad'
cgn      write(*,91030)(decfac(iaux),iaux=-nbquto,-1)
cgn      write(*,*)'decfac tria'
cgn      write(*,91030)(decfac(iaux),iaux=1,nbtrto)
c
cgn      do 8888 , iaux = 1 , nbarto
cgn        if ( decare(iaux).ne.0 ) then
cgn          write (ulsort,90001) '.. arete e/d', iaux,
cgn     >    hetare(iaux), decare(iaux), somare(1,iaux), somare(2,iaux)
cgn        endif
cgn 8888 continue
      endif
c
c====
c 9. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. Menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 9.1. ==> Zones
c
      if ( ( pilraf.gt.0 .or. pilder.gt.0 ) .and.
     >       nbzord.ne.0 ) then
c
        call gmlboj ( ntrav1, codre1 )
        call gmlboj ( ntrav2, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
c
c 9.2. ==> Filtrage
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2. Filtrage ; codret', codret
#endif
c
      if ( filada.ne.0 .or. diammi.gt.0.d0 ) then
c
        call gmlboj ( ntrav3, codre1 )
        call gmlboj ( ntrav4, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
c
c 9.3. ==> Temporaires
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.3. Temporaire ; codret', codret
#endif
c
      if ( typind.eq.0 .or. typind.eq.3 ) then
c
        call gmlboj ( ntrano, codre1 )
        call gmlboj ( ntraar, codre2 )
        call gmlboj ( ntratr, codre3 )
        call gmlboj ( ntraqu, codre4 )
        call gmlboj ( ntrate, codre5 )
        call gmlboj ( ntrapy, codre6 )
        call gmlboj ( ntrahe, codre7 )
        call gmlboj ( ntrape, codre8 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >                 codre6, codre7, codre8 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5,
     >                 codre6, codre7, codre8 )
c
        endif
c
      endif
c
c====
c 10. la fin
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
