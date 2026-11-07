      subroutine eslmm2 ( idfmed, nomamd,
     >                    option,
     >                    titre,
     >                    degre, mailet, sdimca, nbmane, nbmail,
     >                    nbmapo, nbsegm, nbtria, nbtetr,
     >                    nbquad, nbhexa, nbpent, nbpyra,
     >                    nbfmed, nbfmen, ngrouc,
     >                    nbequi, nbeqno, nbeqmp, nbeqar,
     >                    nbeqtr, nbeqqu,
     >                    nbnoto, numano, numael,
     >                    nunoex, fameno, coonca,
     >                    numaex, fammai, noemai, typele,
     >                    grfmpo, grfmta, grfmtb,
     >                    nbpqt, infptr, inftll, inftbl,
     >                    typrep, nomaxe, uniaxe,
     >                    numfam, nomfam,
     >                    eqpntr, eqinfo,
     >                    eqnoeu,
     >                    eqmapo, eqaret, eqtria, eqquad,
     >                    tabaux,
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
c  Entree-Sortie - Lecture du Maillage au format MED - phase 2
c  -      -        -          -                  -           -
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
c . idfmed . e   .   1    . unite logique du maillage d'entree         .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . option . e   .    1   . option de lecture du maillage              .
c .        .     .        . 1 : lecture integrale                      .
c .        .     .        . 2 : uniquement les coordonnees des noeuds  .
c . fameno .  s  . nbnoto . famille med des noeuds                     .
c . coonca .  s  . nbnoto . coordonnees des noeuds                     .
c . fammai .  s  . nbmail . famille med des mailles                    .
c . noemai .  s  . nbmail*. table de connectivite des mailles          .
c .        .     . nbmane .                                            .
c . numaex .  s  . nbmail . numerotation des mailles en entree         .
c . nunoex .  s  . nbnoto . numerotation des noeuds en entree          .
c .        .     .        .                                            .
c . grfmpo .  s  .nbfmed+1. pointeur des groupes des familles          .
c . grfmta .  s  .10ngrouc. taille des groupes des familles            .
c . grfmtb .  s  .10ngrouc. table des groupes des familles             .
c . nbpqt  .  e  .    1   . nombre de paquets des infos generales      .
c . infptr .  s  . nbpqt+1. pointeur des informations generales        .
c . inftll .  s  .nbpqt*10. tailles des caracteres des infos generales.
c . inftbl .  s  .nbpqt*10. tables en caracteres des infos generales   .
c .        .     .        . regroupees par paquets de 80 caracteres    .
c .        .     .        . pour gerer la conversion en pseudo-groupe  .
c .        .     .        . paquet 1 : 1 : 'NomCo'                       .
c .        .     .        .            2/3, 4/5, 6/7 : nom coordonnees .
c .        .     .        .            8 : nom du repere utilise       .
c .        .     .        . paquet 2 : 1 : 'UniteCo'                     .
c .        .     .        .            2/3, 4/5, 6/7 : unite coord.    .
c .        .     .        . paquet 3 : titre (limite a 80 caracteres)  .
c .        .     .        . paquet 4 : 1 : 'NOMAMD'                    .
c .        .     .        .            2-7 : nom du maillage           .
c . typrep . e   .   1    . type de repere                             .
c . nomaxe . e   .   3    . nom des axes de coordonnees                .
c . uniaxe . e   .   3    . unite des axes de coordonnees              .
c . numfam .  s  . nbfmed . numero des familles                        .
c . nomfam .  s  .10nbfmed. nom des familles                           .
c . numfam .  s  . nbfmed . numero des familles                        .
c . eqpntr .  s  .5*nbequi. 5i-4 : nombre de paires de noeuds pour     .
c .        .     .        .        l'equivalence i                     .
c .        .     .        . 5i-3 : idem pour les mailles-points        .
c .        .     .        . 5i-2 : idem pour les aretes                .
c .        .     .        . 5i-1 : idem pour les triangles             .
c .        .     .        . 5i   : idem pour les quadrangles           .
c . eqinfo .  s  .33nbequi. nom et description de chaque equivalence   .
c . eqnoeu .  s  .2*nbeqno. liste des paires de noeuds equivalents avec.
c .        .     .        . la convention : eqnoeu(i)<-->eqnoeu(i+1)   .
c . eqmapo .  s  .2*nbeqmp. idem pour les points                       .
c . eqaret .  s  .2*nbeqar. idem pour les aretes                       .
c . eqtria .  s  .2*nbeqtr. idem pour les triangles                    .
c . eqquad .  s  .2*nbeqqu. idem pour les quadrangles                  .
c . tabaux .  a  .   *    . tableau auxiliaire entier                  .
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
      parameter ( nompro = 'ESLMM2' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer option
c
      integer         degre, mailet, sdimca, nbmane
      integer         nbmail,
     >                nbmapo, nbsegm, nbtria, nbtetr,
     >                nbquad, nbhexa, nbpent, nbpyra,
     >                nbfmed, nbfmen, ngrouc,
     >                nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
      integer         nbnoto
      integer  numano, numael
c
      integer fameno(nbnoto)
      integer fammai(nbmail), typele(nbmail)
      integer numaex(nbmail), nunoex(nbnoto)
      integer noemai(nbmail,nbmane)
      integer*8 idfmed
      integer grfmpo(0:nbfmed), grfmta(10*ngrouc)
      integer numfam(nbfmed)
      integer nbpqt
      integer infptr(0:nbpqt), inftll(10*nbpqt)
      integer eqpntr(5*nbequi)
      integer eqnoeu(2*nbeqno)
      integer eqmapo(2*nbeqmp), eqaret(2*nbeqar)
      integer eqtria(2*nbeqtr), eqquad(2*nbeqqu)
      integer tabaux(*)
      integer typrep
c
      character*8 saux08
      character*8 grfmtb(10*ngrouc)
      character*8 inftbl(10*nbpqt)
      character*8 nomfam(10,nbfmed)
      character*8 eqinfo(33*nbequi)
      character*16 nomaxe(3), uniaxe(3)
      character*64 nomamd
      character*(*) titre
c
      double precision coonca(nbnoto,sdimca)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer nummai
      integer iaux, jaux, kaux, laux, maux
      integer typnoe, typpoi, typseg, typtri, typtet
      integer typqua, typhex, typpyr, typpen
      integer ibtetr, ibtria, ibsegm, ibmapo
      integer ibquad, ibhexa, ibpyra, ibpent
      integer codre1, codre2
      integer codre0
      integer numero, ngro
      integer adeqin, adeqno, adeqmp, adeqar, adeqtr, adeqqu
      integer numdt, numit
      integer nstep, nctcor
c
      character*64 saux64
      character*200 sau200
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(/,''REPERE NON PREVU ='',i4,/)'
c
      texte(2,4) = '(/,''REPERE NON PREVU ='',i4,/)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
#endif
c
      numdt = ednodt
      numit = ednoit
c
c====
c 2. grandeurs de base
c====
c
      typnoe = 0
      typpoi = edpoi1
      if ( degre.eq.1 ) then
        typseg = edseg2
        typtri = edtri3
        typtet = edtet4
        typqua = edqua4
        typhex = edhex8
        typpyr = edpyr5
        typpen = edpen6
      else
        typseg = edseg3
        if ( mod(mailet,2).eq.0 ) then
          typtri = edtri7
        else
          typtri = edtri6
        endif
        typtet = edte10
        if ( mod(mailet,3).eq.0 ) then
          typqua = edqua9
        else
          typqua = edqua8
        endif
        if ( mod(mailet,5).eq.0 ) then
          typhex = edhe27
        else
          typhex = edhe20
        endif
        typpyr = edpy13
        typpen = edpe15
      endif
c
      ibtetr = 1
      ibtria = nbtetr + 1
      ibsegm = nbtetr + nbtria + 1
      ibmapo = nbtetr + nbtria + nbsegm + 1
      ibquad = nbtetr + nbtria + nbsegm + nbmapo + 1
      ibhexa = nbtetr + nbtria + nbsegm + nbmapo + nbquad + 1
      ibpyra = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa + 1
      ibpent = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa
     >       + nbpyra + 1
c
c====
c 4. les coordonnees des noeuds
c    le tableau coonca est declare ainsi : coonca(nbnoto,sdimca).
c    En fortran, cela correspond au stockage memoire suivant :
c    coonca(1,1), coonca(2,1), coonca(3,1), ..., coonca(nbnoto,1),
c    coonca(1,2), coonca(2,2), coonca(3,2), ..., coonca(nbnoto,2),
c    ...
c    coonca(1,sdimca), coonca(2,sdimca), ..., coonca(nbnoto,sdimca)
c    on a ainsi toutes les abscisses, puis toutes les ordonnees, etc.
c    C'est ce que MED appelle le mode non entrelace.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. coordonnees ; codret', codret
#endif
c
c 4.1. ==> lecture
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMNO', nompro
#endif
      call eslmno ( idfmed, nomamd,
     >              option,
     >              nbnoto, sdimca, coonca, fameno,
     >              ulsort, langue, codret )
c
      endif
c
c 4.2. ==> archivages des informations generales
c            Remarque : elles sont regroupees par paquets de
c                       80 caracteres pour  gerer la conversion en
c                       pseudo-groupe dans hom.med
c            . paquet 1 : 1 : 'NomCo'
c                         2/3, 4/5, 6/7 : nom coordonnees
c                         8 : nom du repere utilise
c            . paquet 2 : 1 : 'UniteCo'
c                         2/3, 4/5, 6/7 : unite coordonnees
c            . paquet 3 : titre (limite a 80 caracteres)
c            . paquet 4 : 1 : 'NOMAMD'
c                         2-7 : nom du maillage
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
c 4.2.1. ==> la base
c
      infptr(0) = 0
      do 4211 , iaux = 1, nbpqt
        infptr(iaux) = infptr(iaux-1) + 10
 4211 continue
c
      do 4212 , iaux = 1, 10*nbpqt
        inftll(iaux) = 8
        inftbl(iaux) = blan08
 4212 continue
c
c 4.2.2. ==> le systeme de coordonnees
c
c 4.2.2.1. ==> le type de repere
c
      if ( codret.eq.0 ) then
c
      call utench ( typrep, 'd', iaux, saux08,
     >              ulsort, langue, codret )
c
      inftbl(10) = saux08
c
      endif
c
c 4.2.2.2. ==> noms et unites des coordonnees existantes
c
      if ( codret.eq.0 ) then
c
      inftbl( 1) = 'NomCo   '
      inftbl(11) = 'UniteCo '
c
      do 4222 , iaux = 1 , sdimca
c
cgn        write (ulsort,90064) iaux, 'nomaxe %'//nomaxe(iaux)//'%'
        inftbl(2*iaux) = nomaxe(iaux)(1:8)
        inftbl(2*iaux+1) = nomaxe(iaux)(9:16)
c
cgn        write (ulsort,90064) iaux, 'uniaxe %'//uniaxe(iaux)//'%'
        inftbl(10+2*iaux) = uniaxe(iaux)(1:8)
        inftbl(11+2*iaux) = uniaxe(iaux)(9:16)
c
 4222 continue
c
      endif
c
c 4.2.3. ==> le titre
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2.3. ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = len(titre)
      call utchs8 ( titre, iaux, inftbl(21),
     >              ulsort, langue, codret )
c
      endif
c
c 4.2.4. ==> le nom du maillage
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2.4. ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      inftbl(31) = 'NOMAMD  '
      iaux = len(nomamd)
      call utchs8 ( nomamd, iaux, inftbl(32),
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. Les mailles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. mailles ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      kaux = 1
c
c 5.1. ==> les tetraedres
c
      if ( codret.eq.0 ) then
c
      if ( nbtetr.gt.0 ) then
c
        iaux = 3
        if ( degre.eq.1 ) then
          jaux = 4
        else
          jaux = 10
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMB_te', nompro
#endif
        call eslmmb ( idfmed, nomamd,
     >                iaux, edmail, typtet,
     >                ibtetr, nbtetr, jaux, nbmail, kaux,
     >                ednoda, nbmail,
     >                noemai, fammai,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 5.2. ==> les triangles
c
      if ( codret.eq.0 ) then
c
      if ( nbtria.gt.0 ) then
c
        iaux = 2
        if ( degre.eq.1 ) then
          jaux = 3
        else
          if ( mod(mailet,2).eq.0 ) then
            jaux = 7
          else
            jaux = 6
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMB_tr', nompro
#endif
        call eslmmb ( idfmed, nomamd,
     >                iaux, edmail, typtri,
     >                ibtria, nbtria, jaux, nbmail, kaux,
     >                ednoda, nbmail,
     >                noemai, fammai,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 5.3. ==> les segments
c
      if ( codret.eq.0 ) then
c
      if ( nbsegm.gt.0 ) then
c
        iaux = 1
        if ( degre.eq.1 ) then
          jaux = 2
        else
          jaux = 3
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMB_se', nompro
#endif
        call eslmmb ( idfmed, nomamd,
     >                iaux, edmail, typseg,
     >                ibsegm, nbsegm, jaux, nbmail, kaux,
     >                ednoda, nbmail,
     >                noemai, fammai,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 5.4. ==> les mailles points
c
      if ( codret.eq.0 ) then
c
      if ( nbmapo.gt.0 ) then
c
        iaux = 0
        jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMB_mp', nompro
#endif
        call eslmmb ( idfmed, nomamd,
     >                iaux, edmail, typpoi,
     >                ibmapo, nbmapo, jaux, nbmail, kaux,
     >                ednoda, nbmail,
     >                noemai, fammai,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif

c
c 5.5. ==> les quadrangles
c
      if ( codret.eq.0 ) then
c
      if ( nbquad.gt.0 ) then
c
        iaux = 4
        if ( degre.eq.1 ) then
          jaux = 4
        else
          if ( mod(mailet,3).eq.0 ) then
            jaux = 9
          else
            jaux = 8
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMB_qu', nompro
#endif
        call eslmmb ( idfmed, nomamd,
     >                iaux, edmail, typqua,
     >                ibquad, nbquad, jaux, nbmail, kaux,
     >                ednoda, nbmail,
     >                noemai, fammai,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 5.6. ==> les pyramides
c
      if ( codret.eq.0 ) then
c
      if ( nbpyra.gt.0 ) then
c
        iaux = 5
        if ( degre.eq.1 ) then
          jaux = 5
        else
          jaux = 13
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMB_py', nompro
#endif
        call eslmmb ( idfmed, nomamd,
     >                iaux, edmail, typpyr,
     >                ibpyra, nbpyra, jaux, nbmail, kaux,
     >                ednoda, nbmail,
     >                noemai, fammai,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 5.7. ==> les hexaedres
c
      if ( codret.eq.0 ) then
c
      if ( nbhexa.gt.0 ) then
c
        iaux = 6
        if ( degre.eq.1 ) then
          jaux = 8
        else
          if ( mod(mailet,3).eq.0 ) then
            jaux = 27
          else
            jaux = 20
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMB_he', nompro
#endif
        call eslmmb ( idfmed, nomamd,
     >                iaux, edmail, typhex,
     >                ibhexa, nbhexa, jaux, nbmail, kaux,
     >                ednoda, nbmail,
     >                noemai, fammai,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 5.8. ==> les pentaedres
c
      if ( codret.eq.0 ) then
c
      if ( nbpent.gt.0 ) then
c
        iaux = 7
        if ( degre.eq.1 ) then
          jaux = 6
        else
          jaux = 15
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMMB_pe', nompro
#endif
        call eslmmb ( idfmed, nomamd,
     >                iaux, edmail, typpen,
     >                ibpent, nbpent, jaux, nbmail, kaux,
     >                ednoda, nbmail,
     >                noemai, fammai,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      endif
c
c====
c 6. les familles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Familles ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      grfmpo(0) = 0
      nbfmen = 0
c
      do 60 , jaux = 1, nbfmed
c
        if ( codret.eq.0 ) then
c
c 6.1. ==> Lecture du nombre de groupes
c
        iaux = jaux
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MFANFG', nompro
#endif
        call mfanfg ( idfmed, nomamd, iaux, ngro, codre1 )
c
        grfmpo(jaux) = grfmpo(iaux-1) + ngro*10
c
c 6.2. ==> Lecture :
c          . du nom de la famille (64)
c          . du numero de la famille
c          . des noms des groupes (80)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MFAFAI', nompro
#endif
        call mfafai ( idfmed, nomamd, iaux,
     >                saux64, numero, grfmtb(grfmpo(iaux-1)+1),
     >                codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
c 6.3. ==> Stockage de la taille reelle des noms des groupes
c
        if ( codret.eq.0 ) then
c
        do 63 , kaux = 1 , ngro
c
          do 631 , maux = 1 , 10
            call utlgut ( laux, grfmtb(grfmpo(iaux-1)+10*(kaux-1)+maux),
     >                    ulsort, langue, codret )
            grfmta(grfmpo(iaux-1)+10*(kaux-1)+maux) = laux
  631   continue
c
   63   continue
c
c 6.4. ==> Stockage du numero et du nom de la famille
c          Attention : on stocke sur 80 caracteres pour le futur
c          archivage HOM-MED
c
        if ( numero.gt.0 ) then
          nbfmen = nbfmen + 1
        endif
c
        numfam(iaux) = numero
c
        call utlgut ( laux, saux64,
     >                ulsort, langue, codret )
c
        do 64 , kaux = laux+1 , 64
          saux64(kaux:kaux) = ' '
   64   continue
c
        nomfam(1,jaux) = saux64( 1: 8)
        nomfam(2,jaux) = saux64( 9:16)
        nomfam(3,jaux) = saux64(17:24)
        nomfam(4,jaux) = saux64(25:32)
        nomfam(5,jaux) = saux64(33:40)
        nomfam(6,jaux) = saux64(41:48)
        nomfam(7,jaux) = saux64(49:56)
        nomfam(8,jaux) = saux64(57:64)
c
        endif
c
   60 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
c 6.9. ==> impressions
c
      if ( codret.eq.0 ) then
c
      do 69 , iaux = 1, nbfmed
c
        if ( codret.eq.0 ) then
c
        numero = numfam(iaux)
c
        ngro = ( grfmpo(iaux) - grfmpo(iaux-1) ) / 10
c
        saux64( 1: 8) = nomfam(1,iaux)
        saux64( 9:16) = nomfam(2,iaux)
        saux64(17:24) = nomfam(3,iaux)
        saux64(25:32) = nomfam(4,iaux)
        saux64(33:40) = nomfam(5,iaux)
        saux64(41:48) = nomfam(6,iaux)
        saux64(49:56) = nomfam(7,iaux)
        saux64(57:64) = nomfam(8,iaux)
c
        jaux = 0
        do 692 , nummai = 1 , nbnoto
          if ( fameno(nummai).eq.numero ) then
            jaux = jaux + 1
          endif
  692   continue
c
        kaux = 0
        do 693 , nummai = 1 , nbmail
          if ( fammai(nummai).eq.numero ) then
            kaux = kaux + 1
          endif
  693   continue
c
        call utinfm ( numero, saux64,
     >                ngro, grfmtb(grfmpo(iaux-1)+1),
     >                jaux, kaux,
     >                ulsort, langue, codret )
c
        endif
c
   69 continue
c
      endif
c
#endif
c
      endif
c
c====
c 7. les renumerotations
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. renumerotations ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLNUM', nompro
#endif
      call eslnum ( idfmed, nomamd, degre,
     >              nbnoto, nbmail,
     >              nbmapo, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpent, nbpyra,
     >              nunoex, numaex,
     >              numano, numael,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 8. equivalences
c    la convention de stockage MED des listes d'equivalences est que
c    l'entite Liste(j) est associee a Liste(j+1)
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. equivalences ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      adeqin = 1
      adeqno = 1
      adeqmp = 1
      adeqar = 1
      adeqtr = 1
      adeqqu = 1
c
c     par defaut, on n'a aucune equivalence
c
      jaux = 5*nbequi
      do 80 , iaux = 1, jaux
        eqpntr(iaux) = 0
   80 continue
c
      do 81 , iaux = 1, nbequi
c
c 8.1. ==> nom et description de l'equivalence numero iaux
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
        if ( codret.eq.0 ) then
c
        kaux = 8
        jaux = 8
        call utchs8 ( saux64, jaux*kaux, eqinfo(adeqin),
     >                ulsort, langue, codret )
        adeqin = adeqin + jaux
c
        endif
c
        if ( codret.eq.0 ) then
c
        jaux = 25
        call utchs8 ( sau200, jaux*kaux, eqinfo(adeqin),
     >                ulsort, langue, codret )
        adeqin = adeqin + jaux
c
        endif
c
c 8.2. ==> equivalence de noeuds
c
        if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MEQCSZ_no', nompro
#endif
        call meqcsz ( idfmed, nomamd, saux64, numdt, numit,
     >                ednoeu, typnoe,
     >                jaux, codret )
        endif
c
        if ( jaux.ne.0 ) then
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MEQCOR_no', nompro
#endif
          call meqcor ( idfmed, nomamd, saux64, numdt, numit,
     >                  ednoeu, typnoe,
     >                  eqnoeu(adeqno), codret )
          endif
c
          eqpntr(5*iaux-4) = jaux
          adeqno = adeqno + 2*jaux
c
        endif
c
c 8.3. ==> equivalence de mailles-points
c
        if ( nbmapo.ne.0 ) then
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MEQCSZ_mp', nompro
#endif
          call meqcsz ( idfmed, nomamd, saux64, numdt, numit,
     >                  edmail, typpoi,
     >                  jaux, codret )
          endif
c
          if ( jaux.ne.0 ) then
c
            if ( codret.eq.0 ) then
            call meqcor ( idfmed, nomamd, saux64, numdt, numit,
     >                    edmail, typpoi,
     >                    eqmapo(adeqmp), codret )
            endif
c
            eqpntr(5*iaux-3) = jaux
            adeqmp = adeqmp + 2*jaux
c
          endif
c
        endif
c
c 8.4. ==> equivalence de segments
c
        if ( nbsegm.ne.0 ) then
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MEQCSZ_ar', nompro
#endif
          call meqcsz ( idfmed, nomamd, saux64, numdt, numit,
     >                  edmail, typseg,
     >                  jaux, codret )
          endif
c
          if ( jaux.ne.0 ) then
c
            if ( codret.eq.0 ) then
            call meqcor ( idfmed, nomamd, saux64, numdt, numit,
     >                    edmail, typseg,
     >                    eqaret(adeqar), codret )
            endif
c
            eqpntr(5*iaux-2) = jaux
            adeqar = adeqar + 2*jaux
c
          endif
c
        endif
c
c 8.5. ==> equivalence de triangles
c
        if ( nbtria.ne.0 ) then
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MEQCSZ_tr', nompro
#endif
          call meqcsz ( idfmed, nomamd, saux64, numdt, numit,
     >                  edmail, typtri,
     >                  jaux, codret )
          endif
c
          if ( jaux.ne.0 ) then
c
            if ( codret.eq.0 ) then
            call meqcor ( idfmed, nomamd, saux64, numdt, numit,
     >                    edmail, typtri,
     >                    eqtria(adeqtr), codret )
            endif
c
            eqpntr(5*iaux-1) = jaux
            adeqtr = adeqtr + 2*jaux
c
          endif
c
        endif
c
c 8.6. ==> equivalence de quadrangles
c
        if ( nbquad.ne.0 ) then
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MEQCSZ_qu', nompro
#endif
          call meqcsz ( idfmed, nomamd, saux64, numdt, numit,
     >                  edmail, typqua,
     >                  jaux, codret )
          endif
c
          if ( jaux.ne.0 ) then
c
            if ( codret.eq.0 ) then
            call meqcor ( idfmed, nomamd, saux64, numdt, numit,
     >                    edmail, typqua,
     >                    eqquad(adeqqu), codret )
            endif
c
            eqpntr(5*iaux  ) = jaux
            adeqqu = adeqqu + 2*jaux
c
          endif
c
        endif
c
   81 continue
c
      endif
c
      endif
c
c====
c 9. tableau des types
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. tableau des types ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      jaux = ibtetr + nbtetr - 1
      do 91 , nummai = ibtetr,  jaux
        typele(nummai) = typtet
   91 continue
c
      jaux = ibtria + nbtria - 1
      do 92 , nummai = ibtria, jaux
        typele(nummai) = typtri
   92 continue
c
      jaux = ibsegm + nbsegm - 1
      do 93 , nummai = ibsegm, jaux
        typele(nummai) = typseg
   93 continue
c
      jaux = ibmapo + nbmapo - 1
      do 94 , nummai = ibmapo, jaux
        typele(nummai) = typpoi
   94 continue
c
      jaux = ibquad + nbquad - 1
      do 95 , nummai = ibquad, jaux
        typele(nummai) = typqua
   95 continue
c
      jaux = ibhexa + nbhexa - 1
      do 96 , nummai = ibhexa, jaux
        typele(nummai) = typhex
   96 continue
c
      jaux = ibpyra + nbpyra - 1
      do 97 , nummai = ibpyra, jaux
        typele(nummai) = typpyr
   97 continue
c
      jaux = ibpent + nbpent - 1
      do 98 , nummai = ibpent, jaux
        typele(nummai) = typpen
   98 continue
c
      endif
c
      endif
c
c====
c 10. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. la fin ; codret', codret
#endif
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
