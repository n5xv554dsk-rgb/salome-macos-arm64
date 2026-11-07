      subroutine esemm1 ( idfmed, nomamd, lnomam,
     >                    nbnoto,
     >                    coonca, fameno, noeele, famele, typele,
     >                    numfam, nomfam,
     >                    grfmpo, grfmtb,
     >                     nbpqt, inftbl,
     >                    eqpntr, eqinfo,
     >                    eqnoeu,
     >                    eqaret, eqtria, eqquad,
     >                    eqtetr, eqhexa,
     >                    tabaux, listma,
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
c  Entree-Sortie - Ecriture d'un Maillage au format MED - phase 1
c  -      -        -             -                  -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage de sortie                         .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . lnomam . e   .   1    . longueur du nom du maillage voulu          .
c . fameno . e   . nbnoto . famille med des noeuds                     .
c . famele . e   . nbelem . famille med des elements                   .
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     . *nbmane.                                            .
c . typele . e   . nbelem . type des elements                          .
c . coonca .  s  . nbnoto . coordonnees des noeuds dans le calcul      .
c .        .     . *sdimca.                                            .
c . numfam . e   . nbfmed . numero des familles                        .
c . nomfam . e   .10nbfmed. nom des familles                           .
c . grfmpo . e   .0:nbfmed. pointeur des groupes des familles          .
c . grfmtb . e   .10ngrouc. table des groupes des familles             .
c . inftbl . e   .nbpqt*10. tables en caracteres des infos generales   .
c .        .     .        . regroupees par paquets de 80 caracteres    .
c .        .     .        . pour gerer la conversion en pseudo-groupe  .
c .        .     .        . paquet 1 : 1 : 'NomCo'                       .
c .        .     .        .            2/3, 4/5, 6/7 : nom coordonnees .
c .        .     .        .            8 : nom du repere utilise       .
c .        .     .        . paquet 2 : 1 : 'UniteCo'                     .
c .        .     .        .            2/3, 4/5, 6/7 : unite coord.    .
c .        .     .        . paquet 3 : titre (limite a 80 caracteres)  .
c .        .     .        . paquet 4 : 1 : 'NOMAMD'                    .
c .        .     .        .            2-7 :  nom du maillage          .
c . tabaux .     . nbelem . tableau tampon                             .
c .        .     . *nbmane.                                            .
c . listma .     . nbelem . tableau auxiliaire                         .
c . eqpntr . e   .5*nbequi. 5i-4 : nombre de paires de noeuds pour     .
c .        .     .        .        l'equivalence i                     .
c .        .     .        . 5i-3 : idem pour les mailles-points        .
c .        .     .        . 5i-2 : idem pour les aretes                .
c .        .     .        . 5i-1 : idem pour les triangles             .
c .        .     .        . 5i   : idem pour les quadrangles           .
c . eqinfo . e   .33nbequi. nom et description de chaque equivalence   .
c . eqnoeu . e   .2*nbeqno. liste des paires de noeuds equivalents avec.
c .        .     .        . la convention : eqnoeu(i)<-->eqnoeu(i+1)   .
c . eqmapo . e   .2*nbeqmp. idem pour les mailles-points               .
c . eqaret . e   .2*nbeqar. idem pour les aretes                       .
c . eqtria . e   .2*nbeqtr. idem pour les triangles                    .
c . eqquad . e   .2*nbeqqu. idem pour les quadrangles                  .
c . eqtetr . e   .2*nbeqte. idem pour les tetraedres                   .
c . eqhexa . e   .2*nbeqhe. idem pour les hexaedres                    .
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
      parameter ( nompro = 'ESEMM1' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
#include "indefi.h"
c
#include "envca1.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer lnomam
      integer ulsort, langue, codret
c
      integer nbnoto
      integer fameno(nbnoto)
      integer noeele(nbelem,nbmane), famele(nbelem), typele(nbelem)
      integer grfmpo(0:nbfmed)
      integer numfam(nbfmed)
      integer eqpntr(5*nbequi)
      integer eqnoeu(2*nbeqno)
      integer eqaret(2*nbeqar)
      integer eqtria(2*nbeqtr), eqquad(2*nbeqqu)
      integer eqtetr(2*nbeqte), eqhexa(2*nbeqhe)
      integer tabaux(nbelem*nbmane), listma(nbelem)
      integer nbpqt
c
      character*8 grfmtb(10*ngrouc)
      character*8 inftbl(10*nbpqt)
      character*8 nomfam(10,nbfmed)
      character*8 eqinfo(33*nbequi)
c
      character*64 nomamd
c
      double precision coonca(nbnoto,sdimca)
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer typnoe, typpoi, typseg, typtri, typtet, typenc
      integer typqua, typhex, typpyr, typpen
      integer ibtetr, ibtria, ibsegm, ibmapo, ialist, lamail
      integer ibquad, ibhexa, ibpyra, ibpent
      integer iaux, jaux, kaux
#ifdef _DEBUG_HOMARD_
      integer iaux1
#endif
      integer ngro, numero
      integer adeqin, adeqno, adeqmp, adeqar, adeqtr, adeqqu
      integer adeqte, adeqhe
      integer tbiaux(3,10)
      integer numdt, numit
c
      character*32 saux32
      character*64 saux64
      character*80 saux80
      character*200 sau200
c
      double precision instan
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Maille numero '',i10,'', de type'',i10)'
      texte(1,5) =
     > '(''==> Ce type de maille est inconnu pour MED.'')'
c
      texte(2,4) = '(''Mesh #'',i10,'', with type'',i10)'
      texte(2,5) = '(''==> This type is unknown for MED.'')'
c
#include "impr03.h"
#include "esimpr.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'nomamd = ', nomamd
#endif
c
c====
c 2. preliminaires
c====
c 2.1. ==> grandeurs de base
c
      typnoe = 0
      typpoi = edpoi1
      if ( degre.eq.1 ) then
        typseg = edseg2
        typtri = edtri3
        typtet = edtet4
        typqua = edqua4
        typpyr = edpyr5
        typhex = edhex8
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
        typpyr = edpy13
        if ( mod(mailet,5).eq.0 ) then
          typhex = edhe27
        else
          typhex = edhe20
        endif
        typpen = edpe15
      endif
c
c 2.2. ==> rangements des mailles selon le type
c
      ibtetr = 0
      ibtria = nbtetr
      ibsegm = nbtetr + nbtria
      ibmapo = nbtetr + nbtria + nbsegm
      ibquad = nbtetr + nbtria + nbsegm + nbmapo
      ibhexa = nbtetr + nbtria + nbsegm + nbmapo + nbquad
      ibpyra = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa
      ibpent = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa
     >       + nbpyra
c
cgn      write (ulsort,90002) 'nbtetr', nbtetr
cgn      write (ulsort,90002) 'nbtria', nbtria
cgn      write (ulsort,90002) 'nbsegm', nbsegm
cgn      write (ulsort,90002) 'nbquad', nbquad
cgn      write (ulsort,90002) 'nbhexa', nbhexa
cgn      write (ulsort,90002) 'nbpyra', nbpyra
cgn      write (ulsort,90002) 'typtet,typtri,typseg,typpoi',
cgn     >                      typtet,typtri,typseg,typpoi
cgn      write (ulsort,90002) 'typqua,typhex,typpyr,typpen',
cgn     >                      typqua,typhex,typpyr,typpen
      do 22 , lamail = 1, nbelem
        typenc = typele(lamail)
cgn      write (ulsort,90002) 'lamail, typenc', lamail, typenc
        if ( typenc.eq.typtet ) then
          ibtetr = ibtetr+1
          ialist = ibtetr
        elseif ( typenc.eq.typtri ) then
          ibtria = ibtria+1
          ialist = ibtria
        elseif ( typenc.eq.typseg ) then
          ibsegm = ibsegm+1
          ialist = ibsegm
        elseif ( typenc.eq.typpoi ) then
          ibmapo = ibmapo+1
          ialist = ibmapo
        elseif ( typenc.eq.typqua ) then
          ibquad = ibquad+1
          ialist = ibquad
        elseif ( typenc.eq.typhex ) then
          ibhexa = ibhexa+1
          ialist = ibhexa
        elseif ( typenc.eq.typpyr ) then
          ibpyra = ibpyra+1
          ialist = ibpyra
        elseif ( typenc.eq.typpen ) then
          ibpent = ibpent+1
          ialist = ibpent
        else
          write(ulsort,texte(langue,4)) lamail, typenc
          write(ulsort,texte(langue,5))
          codret = 1
        endif
        listma(ialist) = lamail
   22 continue
c
      ibtetr = 1
      ibtria = nbtetr + 1
      ibsegm = nbtetr + nbtria + 1
      ibmapo = nbtetr + nbtria + nbsegm + 1
      ibquad = nbtetr + nbtria + nbsegm + nbmapo + 1
      ibhexa = nbtetr + nbtria + nbsegm + nbmapo + nbquad + 1
      ibpyra = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa + 1
      ibpent = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa
     > + nbpyra + 1
cgn      write (ulsort,90002) 'ibtetr, ibtria, ibsegm, ibmapo',
cgn     >                      ibtetr, ibtria, ibsegm, ibmapo
cgn      write (ulsort,90002) 'ibquad, ibhexa, ibpyra, ibpent',
cgn     >                      ibquad, ibhexa, ibpyra, ibpent
c
c 2.3. ==> Instants d'enregistrement du maillage
c
      if ( codret.eq.0 ) then
c
      numdt = ednodt
      numit = ednoit
      instan = edundt
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'numdt', numdt
      write(ulsort,90002) 'numit', numit
      write(ulsort,90004) 'dt   ', instan
#endif
c
      endif
c
c 2.4. ==> description du fichier
c
      if ( codret.eq.0 ) then
c
      saux80 = blan80
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESDESC', nompro
#endif
      call esdesc ( idfmed, saux80, sau200,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. creation du maillage
c    remarque : on met la meme description que pour le fichier complet
c    attention a ne pas changer les rubriques de cette description car
c    cela sert de reperage pour les codes en couplage avec HOMARD
c    pour definir le numero d'iteration
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. creation du maillage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'nomamd = ', nomamd
      write(ulsort,90002) 'sdimca', sdimca
      write(ulsort,90002) 'mdimca', mdimca
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMM0', nompro
#endif
      call esemm0 ( idfmed, nomamd,
     >              sdimca, mdimca, sau200,
     >               nbpqt, inftbl,
     >              ulsort, langue, codret)
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,78)) 'esemm0', codret
      endif
c
      endif
c
c====
c 4. les noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. les noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMNO', nompro
#endif
      call esemno ( idfmed, nomamd,
     >              nbnoto, sdimca, coonca, fameno,
     >              numdt, numit, instan,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. les mailles :
c    . la connectivite
c    . les numeros des familles
c    On transferera les informations de connectivite depuis le
c    tableau de stockage, noeele, vers le tableau de lecture, itrav1.
c    Pour cela, on explorera les mailles les unes apres les autres.
c    On a donc interet a batir le tableau itrav1 maille par maille.
c    C'est ce que MED appelle le mode entrelace.
c    Remarque : on met une valeur bidon au tableau tbiaux pour ne
c               pas avoir de message avec ftnchek
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. les mailles ; codret', codret
#endif
c
      kaux = 1
      tbiaux(1,1) = iindef
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
      write (ulsort,texte(langue,3)) 'ESEMMB_te', nompro
#endif
        call esemmb ( idfmed, nomamd,
     >                iaux, edmail, typtet,
     >                nbtetr, jaux, nbelem, kaux,
     >                ednoda, nbelem,
     >                noeele, tbiaux, famele, listma(ibtetr),
     >                numdt, numit, instan,
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
        elseif ( mod(mailet,2).eq.0 ) then
          jaux = 7
        else
          jaux = 6
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMMB_tr', nompro
#endif
        call esemmb ( idfmed, nomamd,
     >                iaux, edmail, typtri,
     >                nbtria, jaux, nbelem, kaux,
     >                ednoda, nbelem,
     >                noeele, tbiaux, famele, listma(ibtria),
     >                numdt, numit, instan,
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
      write (ulsort,texte(langue,3)) 'ESEMMB_se', nompro
#endif
        call esemmb ( idfmed, nomamd,
     >                iaux, edmail, typseg,
     >                nbsegm, jaux, nbelem, kaux,
     >                ednoda, nbelem,
     >                noeele, tbiaux, famele, listma(ibsegm),
     >                numdt, numit, instan,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 5.4. ==> les mailles-points
c
      if ( codret.eq.0 ) then
c
      if ( nbmapo.gt.0 ) then
c
        iaux = 0
        jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMMB_mp', nompro
#endif
        call esemmb ( idfmed, nomamd,
     >                iaux, edmail, typpoi,
     >                nbmapo, jaux, nbelem, kaux,
     >                ednoda, nbelem,
     >                noeele, tbiaux, famele, listma(ibmapo),
     >                numdt, numit, instan,
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
        elseif ( mod(mailet,3).eq.0 ) then
          jaux = 9
        else
          jaux = 8
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMMB_qu', nompro
#endif
        call esemmb ( idfmed, nomamd,
     >                iaux, edmail, typqua,
     >                nbquad, jaux, nbelem, kaux,
     >                ednoda, nbelem,
     >                noeele, tbiaux, famele, listma(ibquad),
     >                numdt, numit, instan,
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
      write (ulsort,texte(langue,3)) 'ESEMMB_py', nompro
#endif
        call esemmb ( idfmed, nomamd,
     >                iaux, edmail, typpyr,
     >                nbpyra, jaux, nbelem, kaux,
     >                ednoda, nbelem,
     >                noeele, tbiaux, famele, listma(ibpyra),
     >                numdt, numit, instan,
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
        elseif ( mod(mailet,5).eq.0 ) then
          jaux = 27
        else
          jaux = 20
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMMB_he', nompro
#endif
        call esemmb ( idfmed, nomamd,
     >                iaux, edmail, typhex,
     >                nbhexa, jaux, nbelem, kaux,
     >                ednoda, nbelem,
     >                noeele, tbiaux, famele, listma(ibhexa),
     >                numdt, numit, instan,
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
      write (ulsort,texte(langue,3)) 'ESEMMB_pe', nompro
#endif
        call esemmb ( idfmed, nomamd,
     >                iaux, edmail, typpen,
     >                nbpent, jaux, nbelem, kaux,
     >                ednoda, nbelem,
     >                noeele, tbiaux, famele, listma(ibpent),
     >                numdt, numit, instan,
     >                tabaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 6. les familles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. les familles ; codret', codret
#endif
c
      if ( codret .eq. 0) then
c
      if ( nbfmed.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Nombre de familles MED', nbfmed
#endif
c
      do 61 , iaux = 1 , nbfmed
c
        if ( codret.eq.0 ) then
c
        numero = numfam(iaux)
c
        if ( ngrouc.eq.0 ) then
          ngro = 0
        else
          ngro = ( grfmpo(iaux) - grfmpo(iaux-1) ) / 10
        endif
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
        endif
c
#ifdef _DEBUG_HOMARD_
c
        if ( codret.eq.0 ) then
c        write (ulsort,90002) 'Familles MED numero ', iaux
c
        kaux = 0
        do 621 , jaux = 1 , nbnoto
cgn      print *,'. fameno(jaux) = ',fameno(jaux)
          if ( fameno(jaux).eq.numero ) then
            kaux = kaux + 1
          endif
  621   continue
c
        iaux1 = 0
        do 622 , jaux = 1 , nbelem
cgn      print *,'. famele(jaux)) = ',famele(jaux)
          if ( famele(jaux).eq.numero ) then
            iaux1 = iaux1 + 1
          endif
  622   continue
c
        call utinfm ( numero, saux64,
     >                ngro, grfmtb(grfmpo(iaux-1)+1),
     >                kaux, iaux1,
     >                ulsort, langue, codret )
c
        endif
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFACRE', nompro
#endif
        call mfacre ( idfmed, nomamd, saux64, numero,
     >                ngro, grfmtb(grfmpo(iaux-1)+1), codret )
c
        if ( codret.ne.0 ) then
          write(ulsort,texte(langue,78)) 'mfacre', codret
        endif
c
        endif
c
   61 continue
c
      endif
c
      endif
c
c====
c 7. equivalences
c    la convention de stockage MED des listes d'equivalences est que
c    l'entite Liste(j) est associee a Liste(j+1)
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. equivalences ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      adeqin = 1
      adeqno = 1
      adeqmp = 1
      adeqar = 1
      adeqtr = 1
      adeqqu = 1
      adeqte = 1
      adeqhe = 1
c
      do 71 , iaux = 1, nbequi
c
c 7.1. ==> nom et description de l'equivalence
c
        if ( codret.eq.0 ) then
c
        call uts8ch ( eqinfo(adeqin), 64, saux64,
     >                ulsort, langue, codret )
        adeqin = adeqin + 8
c
        endif
c
        if ( codret.eq.0 ) then
c
        call uts8ch ( eqinfo(adeqin), 200, sau200,
     >                ulsort, langue, codret )
        adeqin = adeqin + 25
c
        endif
c
c 7.2. ==> creation de l'equivalence dans le fichier
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MEQCRE', nompro
#endif
        call meqcre ( idfmed, nomamd, saux64, sau200, codret )
        if ( codret.ne.0 ) then
          write(ulsort,texte(langue,78)) 'meqcre', codret
        endif
c
        endif
c
c 7.3. ==> equivalence de noeuds
c
        if ( codret.eq.0 ) then
c
        jaux = eqpntr(5*iaux-4)
        if ( jaux.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMMQ_no', nompro
#endif
          call esemmq ( idfmed, nomamd, saux64,
     >                   numdt,  numit,
     >                  ednoeu, typnoe,
     >                    jaux, eqnoeu(adeqno),
     >                  ulsort, langue, codret )
          if ( codret.ne.0 ) then
            write(ulsort,texte(langue,78)) 'ESEMMQ_no', codret
          endif
          adeqno = adeqno + 2*jaux
c
        endif
c
        endif
c
c 7.4. ==> equivalence de mailles-points
c
        if ( codret.eq.0 ) then
c
        jaux = eqpntr(5*iaux-3)
        if ( jaux.gt.0 ) then
c
          codret = 74
c
        endif
c
        endif
c
c 7.5. ==> equivalence de segments
c
        if ( codret.eq.0 ) then
c
        jaux = eqpntr(5*iaux-2)
        if ( jaux.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMMQ_ar', nompro
#endif
          call esemmq ( idfmed, nomamd, saux64,
     >                   numdt,  numit,
     >                  edmail, typseg,
     >                    jaux, eqaret(adeqar),
     >                  ulsort, langue, codret )
          if ( codret.ne.0 ) then
            write(ulsort,texte(langue,78)) 'ESEMMQ_ar', codret
          endif
          adeqar = adeqar + 2*jaux
c
        endif
c
        endif
c
c 7.6. ==> equivalence de triangles
c
        if ( codret.eq.0 ) then
c
        jaux = eqpntr(5*iaux-1)
        if ( jaux.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMMQ_tr', nompro
#endif
          call esemmq ( idfmed, nomamd, saux64,
     >                   numdt,  numit,
     >                  edmail, typtri,
     >                    jaux, eqtria(adeqtr),
     >                  ulsort, langue, codret )
          if ( codret.ne.0 ) then
            write(ulsort,texte(langue,78)) 'ESEMMQ_tr', codret
          endif
          adeqtr = adeqtr + 2*jaux
c
        endif
c
        endif
c
c 7.7. ==> equivalence de quadrangles
c
        if ( codret.eq.0 ) then
c
        jaux = eqpntr(5*iaux)
        if ( jaux.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMMQ_qu', nompro
#endif
          call esemmq ( idfmed, nomamd, saux64,
     >                   numdt,  numit,
     >                  edmail, typqua,
     >                    jaux, eqquad(adeqqu),
     >                  ulsort, langue, codret )
          if ( codret.ne.0 ) then
            write(ulsort,texte(langue,78)) 'ESEMMQ_qu', codret
          endif
          adeqqu = adeqqu + 2*jaux
c
        endif
c
        endif
c
c 7.9. ==> equivalence d'hexaedres
c
        if ( codret.eq.0 ) then
c
        if ( nbeqhe.gt.0 ) then
c
cgn#ifdef _DEBUG_HOMARD_
cgn      write (ulsort,texte(langue,3)) 'ESEMMQ_he', nompro
cgn#endif
cgn          call esemmq ( idfmed, nomamd, saux64,
cgn     >                   numdt,  numit,
cgn     >                  edmail, typhex,
cgn     >                  nbeqhe, eqhexa(adeqhe),
cgn     >                  ulsort, langue, codret )
cgn          if ( codret.ne.0 ) then
cgn            write(ulsort,texte(langue,78)) 'ESEMMQ_he', codret
cgn          endif
cgn          adeqhe = adeqhe + 2*nbeqhe
c
        endif
c
        endif
c
   71 continue
c
      endif
c
c====
c 8. informations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. informations ; codret', codret
#endif
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
      do 81 , iaux = 3 , 8
        tbiaux(2,iaux) = tbiaux(2,iaux-1) + 3
   81 continue
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
      write (ulsort,'(A)') 'TEST2'
#endif
      write (ulsort,'(A)') 'TEST'
      call utinma ( iaux, saux32,
     >              sdimca, mdimca, degre,
     >              nbnoto, jaux, jaux, jaux,
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
        do 821 , iaux = 1 , 4
          if ( tbiaux(1,iaux).gt.0 ) then
            write(ulsort,texte(langue,42))
     >            mess14(langue,3,tbiaux(2,iaux)), tbiaux(3,iaux)
          endif
  821   continue
        tbiaux(2,5) = 3
        tbiaux(2,6) = 6
        tbiaux(3,5) = nbeqte
        tbiaux(3,6) = nbeqhe
cgn        do 822 , iaux = 5, 6
cgn          if ( ( tbiaux(1,iaux).gt.0 ) .and.
cgn     >         ( tbiaux(3,iaux).gt.0 ) ) then
cgn            write(ulsort,texte(langue,42))
cgn     >            mess14(langue,3,tbiaux(2,iaux)), tbiaux(3,iaux)
cgn          endif
cgn  822   continue
      endif
c
      endif
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
