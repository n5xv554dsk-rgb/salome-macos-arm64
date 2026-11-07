      subroutine eslmh2 ( idfmed,
     >                    nomail, lnomai,
     >                      sdim,   mdim,
     >                     degre, maconf, homolo, hierar,
     >                    rafdef, nbmane, typcca, typsfr, maextr,
     >                    mailet,
     >                    dimcst, lgnoig, nbnoco,
     >                    sdimca, mdimca,
     >                    exiren, lgpeli,
     >                    suifro, nomafr, lnomaf,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : Lecture du Maillage Homard - phase 2
c  -      -        -          -        -              -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomail . e   . char*8 . nom du maillage a lire                     .
c . lnomai . e   .   1    . longueur du nom du maillage                .
c . sdim   .  s  .    1   . dimension de l'espace                      .
c . mdim   .  s  .    1   . dimension du maillage                      .
c . degre  .  s  .    1   . degre du maillage                          .
c . maconf .  s  .    1   . conformite du maillage                     .
c .        .     .        .  0 : oui                                   .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2 par face           .
c .        .     .        .  2 : non-conforme avec 1 seul noeud pendant.
c .        .     .        .      par arete                             .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 et des boites pour les  .
c .        .     .        .       quadrangles, hexaedres et pentaedres .
c .        .     .        . 10 : non-conforme sans autre connaissance  .
c . homolo .  s  .    1   . type de relations par homologues           .
c .        .     .        . 0 : pas d'homologues                       .
c .        .     .        . 1 : relations sur les noeuds               .
c .        .     .        . 2 : relations sur les noeuds et les aretes .
c .        .     .        . 3 : relations sur les noeuds, les aretes   .
c .        .     .        .     et les triangles                       .
c . hierar .  s  .    1   . maillage hierarchique                      .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : oui                                    .
c . rafdef .  s  .    1   . 0 : macro-maillage                         .
c .        .     .        . 1 : le maillage est inchange               .
c .        .     .        . 2 : le maillage est issu du raffinement pur.
c .        .     .        .     d'un autre maillage                    .
c .        .     .        . 3 : le maillage est issu du deraffinement  .
c .        .     .        .     pur d'un autre maillage                .
c .        .     .        . 4 : le maillage est issu de raffinement et .
c .        .     .        .     de deraffinement d'un autre maillage   .
c .        .     .        . 12 : le maillage est un maillage passe de  .
c .        .     .        .      degre 1 a 2                           .
c .        .     .        . 21 : le maillage est un maillage passe de  .
c .        .     .        .      degre 2 a 1                           .
c . nbmane .  s  .    1   . nombre maximum de noeuds par element       .
c . typcca .  s  .   1    . type du code de calcul                     .
c . typsfr .  s  .   1    . type du suivi de frontiere                 .
c .        .     .        . 0 : aucun                                  .
c .        .     .        . 1 : maillage de degre 1, avec projection   .
c .        .     .        .     des nouveaux sommets                   .
c .        .     .        . 2 : maillage de degre 2, seuls les noeuds  .
c .        .     .        .     P1 sont sur la frontiere ; les noeuds  .
c .        .     .        .     P2 restent au milieu des P1            .
c .        .     .        . 3 : maillage de degre 2, les noeuds P2     .
c .        .     .        .     etant sur la frontiere                 .
c . maextr .  s  .   1    . maillage extrude                           .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : selon X                                .
c .        .     .        . 2 : selon Y                                .
c .        .     .        . 3 : selon Z (cas de Saturne ou Neptune)    .
c . mailet .  s  .    1   . presence de mailles etendues               .
c .        .     .        .  1 : aucune                                .
c .        .     .        . 2x : TRIA7                                 .
c .        .     .        . 3x : QUAD9                                 .
c .        .     .        . 5x : HEXA27                                .
c . dimcst .  s  .   1    . 0, si toutes les coordonnees varient       .
c .        .     .        . i, si la i-eme est constante et n'est pas  .
c .        .     .        .    memorisee sur chaque noeud              .
c . lgnoig .  s  .   1    . nombre de noeuds lies aux elements ignores .
c . nbnoco .  s  .   1    . nbr noeuds pour la non-conformite initiale .
c . sdimca .  s  .    1   . dimension de l'espace du maillage de calcul.
c . mdimca .  s  .    1   . dimension du maillage du maillage de calcul.
c . exiren .  s  .   1    . vrai/faux selon presence de renumerotations.
c . lgpeli .  s  .   1    . longueur du profil des elements elimines   .
c . suifro . e   .   1    . 1 : pas de suivi de frontiere              .
c .        .     .        . 2x : frontiere discrete                    .
c .        .     .        . 3x : frontiere analytique                  .
c .        .     .        . 5x : frontiere cao                         .
c . nomafr .  s  . char64 . nom du maillage MED de la frontiere        .
c . lnomaf .  s  .   1    . longueur du nom du maillage de la frontiere.
c .        .     .        . 0 : le maillage est absent du fichier      .
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
      parameter ( nompro = 'ESLMH2' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "front1.h"
c
c 0.3. ==> arguments
c
      integer lnomai
      integer*8 idfmed
      integer   sdim,   mdim
      integer  degre, maconf, homolo, hierar
      integer rafdef, nbmane, typcca, typsfr, maextr
      integer mailet
      integer dimcst, lgnoig, nbnoco
      integer sdimca, mdimca
      integer lgpeli
      integer suifro
      integer lnomaf
c
      character*64 nomail
      character*64 nomafr
c
      logical exiren
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer infmgl(30)
      integer nbprof
      integer nbvapr
c
      logical exiigl
c
      character*64 noprof
      character*64 nomam2
      integer typrep
c
      character*16 nomaxe(3), uniaxe(3)
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. intialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Aucun profil dans le fichier ?'')'
      texte(1,5) = '(''Les informations globales sont absentes.'')'
c
      texte(2,5) = '(''No profile into the file?'')'
      texte(2,5) = '(''Global information are missing.'')'
c
#include "esimpr.h"
c
#include "impr03.h"
c
c====
c 2. Le maillage est-il present dans le fichier ?
c    si oui, on retourne les dimensions de l'espace et du maillage
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLNOM', nompro
#endif
      call eslnom ( idfmed, nomail, lnomai,
     >                sdim,   mdim,
     >              typrep, nomaxe, uniaxe,
     >              ulsort, langue, codret )
      if ( codret.ne.0 ) then
        codret = 2
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,22)) nomail(1:lnomai)
      write (ulsort,texte(langue,23)) 'de l''espace', sdim
      write (ulsort,texte(langue,23)) 'du maillage', mdim
      endif
#endif
c
c====
c 3. Recuperation des parametres essentiels
c====
c 3.1. ==> Nombre de profils
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. Nombre de profils ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFNPF', nompro
#endif
      call mpfnpf ( idfmed, nbprof, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,86)) nbprof
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbprof.eq.0 ) then
        write (ulsort,texte(langue,86)) nbprof
        write (ulsort,texte(langue,4))
        codret = 31
      endif
c
      endif
c
c 3.2. ==> Parcours des profils
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. Parcours des profils ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      exiigl = .false.
      exiren = .false.
      lgpeli = 0
c
      do 32 , iaux = 1 , nbprof
c
c 3.2.1. ==> nom et taille du profil a lire
c
        if ( codret.eq.0 ) then
c
        jaux = iaux
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPFI', nompro
#endif
        call mpfpfi ( idfmed, jaux, noprof, nbvapr, codret )
        if ( codret.ne.0 ) then
        write (ulsort,texte(langue,79))
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,61)) noprof
        write (ulsort,texte(langue,62)) nbvapr
#endif
c
        endif
c
c 3.2.2. ==> Les profils que l'on cherche
c
        if ( codret.eq.0 ) then
c
c 3.2.2.1 ==> Recuperation des parametres essentiels
c
c                             1234567890123456789012
        if ( noprof(1:22).eq.'Info_maillage_globales' ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'MPFPRR', nompro
#endif
          call mpfprr ( idfmed, noprof, infmgl, codret )
c
          if ( codret.ne.0 ) then
            write (ulsort,texte(langue,61)) noprof
            write (ulsort,texte(langue,79))
          endif
c
          endif
c
          if ( codret.eq.0 ) then
c
          exiigl = .true.
c
c envca1 + divers
          degre  = infmgl( 3)
          maconf = infmgl( 4)
          homolo = infmgl( 5)
          hierar = infmgl( 6)
          rafdef = infmgl( 7)
          nbmane = infmgl( 8)
          typcca = infmgl( 9)
          typsfr = infmgl(10)
          maextr = infmgl(11)
          mailet = infmgl(12)
          dimcst = infmgl(13)
          lgnoig = infmgl(14)
          nbnoco = infmgl(15)
c nbutil
          sdimca = infmgl(16)
          mdimca = infmgl(17)
c
          endif
c
c 3.2.2.2. ==> Presence de renumerotation
c
c                                 1234567890123456789
        elseif ( noprof(1:19).eq.'Attributs_de_norenu' ) then
c
          exiren = .true.
c
c 3.2.2.3. ==> Presence d'elements ignores
c
c                                 1234567890123456
        elseif ( noprof(1:16).eq.'Elements_Ignores' ) then
c
          lgpeli = nbvapr
c
        endif
c
        endif
c
   32 continue
c
      endif
c
c 3.3. ==> controle
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. controle ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( .not.exiigl ) then
c
      write (ulsort,texte(langue,5))
      codret = 33
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'lgpeli', lgpeli
#endif
c
c====
c 4. L'eventuelle frontiere discrete
c    Le nom doit etre coherent avec esecfd
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Frontiere discrete ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'suifro', suifro
#endif
c
      if ( mod(suifro,2).eq.0 ) then
c
c 4.1. ==> Nom du maillage de la frontiere
c
        if ( codret.eq.0 ) then
c
        nomam2 = blan64
        nomam2(1:8) = 'AbsCurvi'
        iaux = 8
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLNOF', nompro
#endif
        call eslnof ( idfmed,
     >                nomail, lnomai,
     >                nomam2,   iaux,
     >                nomafr, lnomaf, sfsdim, sfmdim,
     >                typrep, nomaxe, uniaxe,
     >                ulsort, langue, codret )
        if ( codret.ne.0 ) then
          codret = 2
        endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,22)) nomafr
      write (ulsort,texte(langue,23)) 'de l''espace', sfsdim
      write (ulsort,texte(langue,23)) 'du maillage', sfmdim
      endif
#endif
c
        endif
c
c 4.2. ==> Si le maillage de la frontiere existe :
c
        if ( lnomaf.gt.0 ) then
c
c 4.2.1. ==> Nombre de noeuds du maillage de la frontiere
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMN-'//nomafr(1:lnomaf),nompro
#endif
          call eslmmn ( idfmed, nomafr, lnomaf,
     >                  sfnbso,
     >                  ulsort, langue, codret )
c
          endif
c
c 4.2.2. ==> Nombre de noeuds de la description
c
          if ( codret.eq.0 ) then
c
          iaux = 8
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMN-'//nomam2(1:iaux),nompro
#endif
          call eslmmn ( idfmed, nomam2, iaux,
     >                  sfnbse,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      else
c
        sfsdim = 0
        sfmdim = 0
        sfnbso = 0
        sfnbse = 0
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'sfsdim', sfsdim
      write (ulsort,90002) 'sfmdim', sfmdim
      write (ulsort,90002) 'sfnbso', sfnbso
      write (ulsort,90002) 'sfnbse', sfnbse
#endif
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
c
      end
