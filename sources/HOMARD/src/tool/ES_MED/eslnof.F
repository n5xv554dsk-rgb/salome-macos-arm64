      subroutine eslnof ( idfmed,
     >                    nomam1, lnoma1,
     >                    nomam2, lnoma2,
     >                    nomafr, lnomaf,   sdim,  mdim,
     >                    typrep, nomaxe, uniaxe,
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
c  Entree-Sortie - Lecture - NOm du maillage de la Frontiere
c  -      -        -         --                    -
c ______________________________________________________________________
c Remarque : eslnom et eslnof sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage d'entree                          .
c . nomam1 . e   . char64 . nom du maillage 1 a exclure                .
c . lnoma1 . e   .   1    . longueur nom du maillage 1 a exclure       .
c . nomam2 . e   . char64 . nom du maillage 2 a exclure                .
c . lnoma2 . e   .   1    . longueur nom du maillage 2 a exclure       .
c . nomafr .  s  . char64 . nom du maillage MED de la frontiere        .
c . lnomaf .  s  .   1    . longueur du nom du maillage de la frontiere.
c .        .     .        . 0 : le maillage est absent du fichier      .
c . sdim   .  s  .   1    . dimension de l'espace                      .
c . mdim   .  s  .   1    . dimension du maillage                      .
c . typrep .  s  .   1    . type de repere                             .
c . nomaxe .  s  .   3    . nom des axes de coordonnees                .
c . uniaxe .  s  .   3    . unite des axes de coordonnees              .
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
      parameter ( nompro = 'ESLNOF' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer lnoma1, lnoma2
      integer lnomaf
      integer sdim, mdim
      integer typrep
c
      character*16 nomaxe(3), uniaxe(3)
      character*64 nomam1
      character*64 nomam2
      character*64 nomafr
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer nbmaie
      integer nromai
      integer typema
      integer stype, nstep
c
      integer iaux, jaux
      integer ptrav1, ptrav2
      integer codre1, codre2
      integer codre0
c
      character*8 ntrav1, ntrav2
      character*16 saux16
      character*64 saux64
      character*200 sau200
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
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
#include "esimpr.h"
c
      sdim = 0
c
      texte(1,4) = '(''Nombre de maillages :'',i3)'
      texte(1,5) = '(''Nom du maillage numero'',i3,'' : '',a64)'
      texte(1,6) = '(''Maillage a exclure : '',a)'
c
      texte(2,4) = '(''Number of meshes:'',i3)'
      texte(2,5) = '(''Name of mesh #'',i3,'': '',a64)'
      texte(2,6) = '(''Mesh not to take: '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nomam1(1:lnoma1)
      write (ulsort,texte(langue,6)) nomam2(1:lnoma2)
#endif
c
c====
c 2. le maillage est-il present ?
c====
c
c 2.1. ==> combien de maillages
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.1. combien de maillages ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHNMH', nompro
#endif
      call mmhnmh ( idfmed, nbmaie, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,20))
#ifdef _DEBUG_HOMARD_
      else
        write (ulsort,texte(langue,4)) nbmaie
#endif
      endif
c
      endif
c
c 2.2. ==> structures de stockage des noms des maillages du fichier
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.2. structures ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 8*nbmaie
      call gmalot ( ntrav1, 'chaine  ', iaux   , ptrav1, codre1 )
      call gmalot ( ntrav2, 'entier  ', nbmaie , ptrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 2.3. ==> numero et dimension du maillage voulu
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.3. numero et dimension ; codret =', codret
#endif
c
      nromai = 0
c
      if ( codret.eq.0 ) then
c
      do 23 , iaux = 1 , nbmaie
c
c 2.3.1. ==> nom et dimension du maillage numero iaux
c            sdim : Dimension de l'espace de calcul.
c            mdim : Dimension du maillage.
c
        if ( codret.eq.0 ) then
c                        12345678901234567890123456789012
        saux64( 1:32) = '                                '
        saux64(33:64) = '                                '
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHMII', nompro
#endif
        call mmhmii ( idfmed, iaux,
     >                saux64,   sdim,   mdim, typema, sau200,
     >                saux16,  stype,  nstep,
     >                typrep, nomaxe, uniaxe,
     >                codret )
        if ( codret.ne.0 ) then
          write (ulsort,texte(langue,20))
        endif
c
        endif
c
        if ( codret.eq.0 ) then
        call utlgut ( jaux, saux64,
     >                ulsort, langue, codret )
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) iaux, saux64
#endif
c
c 2.3.2. ==> archivage de ce nom
c
        if ( codret.eq.0 ) then
c
        call utchs8 ( saux64, jaux, smem(ptrav1+8*(iaux-1)),
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        imem(ptrav2+iaux-1) = jaux
c
        endif
c
c 2.3.3. ==> comparaison avec le nom voulu
c            il ne doit etre ni le maillage HOMARD, ni le
c            stockage des abscisses survilignes
c            une fois le maillage trouve, on s'assure qu'il est decrit
c            en non structure
c
        if ( codret.eq.0 ) then
c
        if ( jaux.eq.lnoma1 ) then
          if ( saux64(1:jaux).eq.nomam1(1:lnoma1) ) then
            goto 23
          endif
        endif
c
        if ( jaux.eq.lnoma2 ) then
          if ( saux64(1:jaux).eq.nomam2(1:lnoma2) ) then
            goto 23
          endif
        endif
c
        if ( typema.ne.ednost ) then
          write (ulsort,texte(langue,22)) saux64(1:jaux)
          write (ulsort,texte(langue,28)) typema
          codret = 11
        endif
        lnomaf = jaux
        nomafr = blan64
        nomafr(1:jaux) = saux64(1:jaux)
        goto 24
c
        endif
c
   23 continue
c
c 2.3.4. ==> le maillage voulu est inconnu dans ce fichier
c
      lnomaf = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbmaie
c
      do 234 , iaux = 1 , nbmaie
c
        jaux = imem(ptrav2+iaux-1)
        call uts8ch ( smem(ptrav1+8*(iaux-1)), jaux, saux64,
     >                ulsort, langue, codre1 )
        write (ulsort,texte(langue,5)) iaux, saux64
c
  234 continue
#endif
c
      endif
c
c 2.4. ==> menage
c
   24 continue
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre1 )
      call gmlboj ( ntrav2 , codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
