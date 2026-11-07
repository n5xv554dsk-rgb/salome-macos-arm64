      subroutine eslmm1 ( idfmed, nomamd, lnomam,
     >                    titre,
     >                    sdimca, mdimca,
     >                     degre, mailet, homolo, nbmane,
     >                    nbelem, nbmaae, nbmafe,
     >                    nbmapo, nbsegm, nbtria, nbtetr,
     >                    nbquad, nbhexa, nbpent, nbpyra,
     >                    nbfmed, ngrouc, nbgrm,
     >                    nbequi, nbeqno, nbeqmp, nbeqar,
     >                    nbeqtr, nbeqqu,
     >                    nbnoto,
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
c  Entree-Sortie - Lecture du Maillage au format MED - phase 1
c  -      -        -          -                  -           -
c  Remarque : on suppose que le maillage est conforme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage d'entree                          .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . lnomam . e   .   1    . longueur du nom du maillage voulu          .
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
      parameter ( nompro = 'ESLMM1' )
c
#include "nblang.h"
#include "consts.h"
c
#include "equiva.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer lnomam
      integer sdimca, mdimca
      integer degre, mailet, homolo, nbmane
      integer nbelem, nbmaae, nbmafe,
     >        nbmapo, nbsegm, nbtria, nbtetr,
     >        nbquad, nbhexa, nbpent, nbpyra,
     >        nbfmed, ngrouc, nbgrm,
     >        nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
      integer nbnoto
c
      character*64 nomamd
      character*(*) titre
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer nbmai1, nbmai2
      integer nbseg2, nbseg3
      integer nbtri3, nbtri6, nbtri7
      integer nbtet4, nbte10
      integer nbqua4, nbqua8, nbqua9
      integer nbhex8, nbhe20, nbhe27
      integer nbpen6, nbpe15
      integer nbpyr5, nbpy13
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
      integer ngro
      integer typnoe, typpoi, typseg, typtri, typqua
c
      integer iaux, jaux
      integer iaux1, iaux2, iaux3, iaux4, iaux5
      integer tbiaux(3,10)
      integer numdt, numit
      integer nstep, nctcor
c
      character*32 saux32
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
      texte(1,4) = '(''Nombre de mailles '',a6,'' :'',i10)'
      texte(1,5) =
     > '(''Ces types de mailles ne sont pas acceptees par HOMARD.'')'
c
      texte(2,4) = '(''Number of meshes '',a6,'' :'',i10)'
      texte(2,5) =
     > '(''These kinds of elements are not treated in HOMARD.'')'
c
#include "esimpr.h"
c
      nbnoto = 0
      nbmane = 0
      nbmaae = 0
      nbmafe = 0
      degre  = 0
      homolo = 0
c
      nbfmed = 0
      ngrouc = 0
      nbgrm = 0
c
      typnoe = 0
c
      numdt = ednodt
      numit = ednoit
c
      titre(1:64) = nomamd
      iaux = len(titre)
      do 11, jaux = 65 , iaux
        titre(jaux:jaux) = ' '
   11 continue
c
c====
c 2. recherche des differents nombres
c====
c 2.1. ==> nombre de sommets
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMN', nompro
#endif
      call eslmmn ( idfmed, nomamd, lnomam,
     >              nbnoto,
     >              ulsort, langue, codret )
c
      endif
c
c 2.2. ==> les mailles
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLNMA', nompro
#endif
      call eslnma ( idfmed, nomamd, mdimca,
     >              nbelem, nbmapo, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpyra, nbpent,
     >              nbseg2, nbseg3,
     >              nbtri3, nbtri6, nbtri7,
     >              nbtet4, nbte10,
     >              nbqua4, nbqua8, nbqua9,
     >              nbhex8, nbhe20, nbhe27,
     >              nbpen6, nbpe15,
     >              nbpyr5, nbpy13,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbhe27.gt.0 ) then
c
        write (ulsort,texte(langue,4)) 'HEXA27', nbhe27
        write (ulsort,texte(langue,5))
        codret = 3
c
      endif
      mailet = 1
      if ( nbtri7.gt.0 ) then
        mailet = mailet*2
      endif
      if ( nbqua9.gt.0 ) then
        mailet = mailet*3
      endif
      if ( nbhe27.gt.0 ) then
        mailet = mailet*5
      endif
c
      endif
c
c 2.3. ==> nombre de familles et de groupes cumules
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFANFA', nompro
#endif
      call mfanfa ( idfmed, nomamd, nbfmed, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 23 , iaux = 1 , nbfmed
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MFANFG', nompro
#endif
        call mfanfg ( idfmed, nomamd, iaux, ngro, codre0 )
        codret = max ( abs(codre0), codret )
c
        ngrouc = ngrouc + ngro
        nbgrm = max ( ngro, nbgrm )
c
        endif
c
   23 continue
c
      endif
c
c====
c 3. nombres deduits
c====
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> Nombre de mailles
c
      nbmai1 = nbtet4 + nbtri3 + nbseg2
     >       + nbqua4 + nbhex8 + nbpyr5 + nbpen6
      nbmai2 = nbte10 + nbtri6 + nbseg3
     >       + nbqua8 + nbhe20 + nbpy13 + nbpe15
     >       + nbtri7 + nbqua9 + nbhe27
c
c 3.2. ==> nbmane : nombre maximal de noeud par element
c
      if ( nbmai1.gt.0 ) then
c
        if ( nbmai2.gt.0 ) then
          write(ulsort,texte(langue,27)) nbmai1, nbmai2
          codret = 30
        endif
c
        degre  = 1
c
        if ( nbhexa.gt.0 ) then
          nbmane = 8
        elseif ( nbpent.gt.0 ) then
          nbmane = 6
        elseif ( nbpyra.gt.0 ) then
          nbmane = 5
        elseif ( nbtetr.gt.0 .or. nbquad.gt.0 ) then
          nbmane = 4
        elseif ( nbtria.gt.0 ) then
          nbmane = 3
        else
          nbmane = 2
        endif
c
      else if ( nbmai2.gt.0 ) then
c
        degre  = 2
c
        if ( nbhe27.gt.0 ) then
          nbmane = 27
        elseif ( nbhe20.gt.0 ) then
          nbmane = 20
        elseif ( nbpent.gt.0 ) then
          nbmane = 15
        elseif ( nbpyra.gt.0 ) then
          nbmane = 13
        elseif ( nbtetr.gt.0 ) then
          nbmane = 10
        elseif ( nbqua9.gt.0 ) then
          nbmane = 9
        elseif ( nbqua8.gt.0 ) then
          nbmane = 8
        elseif ( nbtri7.gt.0 ) then
          nbmane = 7
        elseif ( nbtri6.gt.0 ) then
          nbmane = 6
        else
          nbmane = 3
        endif
c
      else
c
        nbmane = 1
c
      endif
c
c 3.3. ==> nbmaae : nombre maximal d'aretes par element
c          nbmafe : nombre maximal de faces par element
c
      if ( nbhexa.gt.0 ) then
        nbmaae = 12
        nbmafe = 6
      else if ( nbpent.gt.0 ) then
        nbmaae = 9
        nbmafe = 5
      else if ( nbpyra.gt.0 ) then
        nbmaae = 8
        nbmafe = 5
      else if ( nbtetr.gt.0 ) then
        nbmaae = 6
        nbmafe = 4
      else if ( nbquad.gt.0 ) then
        nbmaae = 4
        nbmafe = 1
      else if ( nbtria.gt.0 ) then
        nbmaae = 3
        nbmafe = 1
      else if ( nbsegm.gt.0 ) then
        nbmaae = 1
      endif
c
      endif
c
c====
c 4. les equivalences
c    remarque : il faut le faire seulement maintenant, sinon on ne
c               sait pas ce que valent typseg, typtri et typqua.
c====
c
c 4.1. ==> le nombre d'equivalences
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MEQNEQ', nompro
#endif
      call meqneq ( idfmed, nomamd, nbequi, codret )
c
      endif
c
c 4.2. ==> combien de paires d'entites impliquees
c
      nbeqno = 0
      nbeqmp = 0
      nbeqar = 0
      nbeqtr = 0
      nbeqqu = 0
c
      typpoi = edpoi1
      if ( degre.eq.1 ) then
        typseg = edseg2
        typtri = edtri3
        typqua = edqua4
      else
        typseg = edseg3
        typtri = edtri6
        typqua = edqua8
      endif
c
      if ( codret.eq.0 ) then
c
      jaux = 0
c
      do 42 , iaux = 1, nbequi
c
c 4.2.1. ==> nom et description de l'equivalence
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MEQEQI', nompro
#endif
        call meqeqi ( idfmed, nomamd, iaux,
     >                saux64, sau200, nstep, nctcor, codret )
c
        endif
c
c 4.2.2. ==> si l'equivalence est interdite, on passe a la suivante
c
        if ( codret.eq.0 ) then
c
        if ( saux64.eq.eqinte ) then
c
          jaux = jaux + 1
          goto 42
c
        endif
c
        endif
c
c 4.2.3. ==> nombre d'entites dans chaque categorie
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MEQCSZ', nompro
#endif
        call meqcsz ( idfmed, nomamd, saux64, numdt, numit,
     >                ednoeu, typnoe,
     >                iaux1, codre1 )
c
        if ( nbmapo.ne.0 ) then
          call meqcsz ( idfmed, nomamd, saux64, numdt, numit,
     >                  edmail, typpoi,
     >                  iaux2, codre2 )
        else
          iaux2 = 0
          codre2 = 0
        endif
c
        if ( nbsegm.ne.0 ) then
          call meqcsz ( idfmed, nomamd, saux64, numdt, numit,
     >                  edmail, typseg,
     >                  iaux3, codre3 )
        else
          iaux3 = 0
          codre3 = 0
        endif
c
        if ( nbtria.ne.0 ) then
          call meqcsz ( idfmed, nomamd, saux64, numdt, numit,
     >                  edmail, typtri,
     >                  iaux4, codre4 )
        else
          iaux4 = 0
          codre4 = 0
        endif
c
        if ( nbquad.ne.0 ) then
          call meqcsz ( idfmed, nomamd, saux64, numdt, numit,
     >                  edmail, typqua,
     >                  iaux5, codre5 )
        else
          iaux5 = 0
          codre5 = 0
        endif
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nbeqno = nbeqno + iaux1
        nbeqmp = nbeqmp + iaux2
        nbeqar = nbeqar + iaux3
        nbeqtr = nbeqtr + iaux4
        nbeqqu = nbeqqu + iaux5
c
        endif
c
   42 continue
c
      endif
c
c 4.3. ==> bilan
c
      if ( codret.eq.0 ) then
c
      nbequi = nbequi - jaux
c
      if ( nbeqtr.ne.0 .or. nbeqqu.ne.0 ) then
        homolo = 3
      elseif ( nbeqar.ne.0 ) then
        homolo = 2
      elseif ( nbeqno.ne.0 ) then
        homolo = 1
      else
        homolo = 0
      endif
c
      endif
c
c====
c 5. Informations
c====
c
      if ( codret.eq.0 ) then
c
      write(ulsort,texte(langue,22)) nomamd(1:lnomam)
c
      tbiaux(1,1) = nbmapo
      tbiaux(1,2) = nbsegm
      tbiaux(1,3) = nbtria
      tbiaux(1,4) = nbquad
      tbiaux(1,5) = nbtetr
      tbiaux(1,6) = nbhexa
      tbiaux(1,7) = nbpent
      tbiaux(1,8) = nbpyra
      tbiaux(2,1) = 2
      if ( degre.eq.1 ) then
        tbiaux(2,2) = 4
      else
        tbiaux(2,2) = 5
      endif
      do 51 , iaux = 3 , 8
        tbiaux(2,iaux) = tbiaux(2,iaux-1) + 3
   51 continue
c
      iaux = 1
      jaux = 0
      if ( langue.eq.1 ) then
c                 12345678901234567890123456789012
        saux32 = 'dans le fichier                 '
      else
        saux32 = 'in the file                     '
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTINMA', nompro
#endif
      call utinma ( iaux, saux32,
     >              sdimca, mdimca, degre,
     >              nbnoto,   jaux,  jaux, jaux,
     >              jaux, jaux,
     >              iaux, nbelem,
     >              nbmapo, tbiaux(1,2), tbiaux(1,3), tbiaux(1,4),
     >              tbiaux(1,5), tbiaux(1,6), tbiaux(1,8), tbiaux(1,7),
     >              jaux,
     >              nbmane, nbmaae, nbmafe,
     >              ulsort, langue, codret)
c
      write(ulsort,texte(langue,29)) nbfmed
      write(ulsort,texte(langue,31)) ngrouc
c
      if ( nbequi.ne.0 ) then
        write(ulsort,texte(langue,41)) nbequi
        write(ulsort,texte(langue,42)) mess14(langue,3,-1), nbeqno
        tbiaux(2,1) = 0
        tbiaux(2,2) = 1
        tbiaux(2,3) = 2
        tbiaux(2,4) = 4
        tbiaux(3,1) = nbeqmp
        tbiaux(3,2) = nbeqar
        tbiaux(3,3) = nbeqtr
        tbiaux(3,4) = nbeqqu
        do 53 , iaux = 1 , 4
          if ( tbiaux(1,iaux).gt.0 ) then
            write(ulsort,texte(langue,42))
     >            mess14(langue,3,tbiaux(2,iaux)), tbiaux(3,iaux)
          endif
   53 continue
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
