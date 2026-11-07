      subroutine vccfnc ( nbfare, cfaare,
     >                    nbfqua, cfaqua,
     >                    nbftri, cfatri,
     >                    faminf, famsup,
     >                    nbfme0, numfam, nomfam,
     >                    grfmpo, grfmta, grfmtb,
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
c    aVant adaptation - Creation des Familles - Non Conforme
c                       -            -          -   -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfare . es  .   1    . nombre de familles d'aretes                .
c . cfaare . es  . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nbfqua . e   .   1    . nombre de familles de quadrangles          .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nbftri . e   .   1    . nombre de familles de triangles            .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftrm .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . faminf . e   .   1    . famille med des quad de la face inferieure .
c . famsup . e   .   1    . famille med des quad de la face superieure .
c . nbfme0 . e   .   1    . nombre initial de familles med             .
c . numfam . es  . nbfmed . numero des familles                        .
c . nomfam . es  .10nbfmed. nom des familles                           .
c . grfmpo .  s  .nbfmed+1. pointeur des groupes des familles          .
c . grfmta .  s  .10ngrouc. taille des groupes des familles            .
c . grfmtb .  s  .10ngrouc. table des groupes des familles             .
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
      parameter ( nompro = 'VCCFNC' )
c
#include "nblang.h"
#include "consts.h"
c
#include "cofaar.h"
#include "coftfq.h"
#include "cofatq.h"
#include "coftex.h"
c
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
#include "nbutil.h"
#include "nbfamm.h"
#include "dicfen.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbfare
      integer cfaare(nctfar,nbfarm)
      integer nbfqua
      integer cfaqua(nctfqu,nbfqum)
      integer nbftri
      integer cfatri(nctftr,nbftrm)
c
      integer faminf, famsup
      integer nbfme0
      integer numfam(nbfmed)
      integer grfmpo(0:nbfmed)
      integer grfmta(10*ngrouc)
c
      character*8 nomfam(10,nbfmed)
      character*8 grfmtb(10*ngrouc)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nufamd(3)
c
      character*8 saux08
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
      texte(1,4) = '(a14,'' : nombre de familles HOMARD : '',i8)'
      texte(1,5) = '(''Ce nombre est superieur au maximum :'',i8)'
      texte(1,6) = '(''Modifier le programme UTINCG'')'
      texte(1,7) = '(''. Famille MED supplementaire'',i2,'' :'',i6)'
      texte(1,8) = '(/,a14,'' : ajout de la famille MED'',i8)'
      texte(1,9) = '(''Aucun type n''''a ete trouve pour les '',a)'
c
      texte(2,4) = '(a14,'' : number of HOMARD families:'',i8)'
      texte(2,5) = '(''This number is greater than maximum:'',i8)'
      texte(2,6) = '(''Modify UTINCG program.'')'
      texte(2,7) = '(''. Additional MED family #'',i2,'':'',i6)'
      texte(2,8) = '(/,a14,'' : addition of MED family #'',i8)'
      texte(2,9) = '(''No type was found for the '',a)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,4,1), nbfare
      if ( nbtria.ne.0 ) then
        write (ulsort,texte(langue,4)) mess14(langue,4,2), nbftri
      endif
      if ( nbquad.ne.0 ) then
        write (ulsort,texte(langue,4)) mess14(langue,4,4), nbfqua
      endif
      write (ulsort,*) ' '
#endif
c
c====
c 2. On recherche trois nouveaux numeros de famille MED
c====
c 2.1. ==> on cherche le minimum entre tous les numeros de familles MED
c          deja existant et ceux des faces inf/sup
c
      iaux = min (faminf, famsup)
c
      do 21 , jaux = 1 , nbfmed-3
c
        iaux = min (iaux,numfam(jaux))
c
   21 continue
c
      nufamd(1) = iaux - 1
      nufamd(2) = iaux - 2
      nufamd(3) = iaux - 3
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) 1, nufamd(1)
      write (ulsort,texte(langue,7)) 2, nufamd(2)
      write (ulsort,texte(langue,7)) 3, nufamd(3)
#endif
c
c====
c 3. On ajoute deux nouvelles familles d'aretes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Ajout fam. aretes ; codret', codret
#endif
c
c 3.1. ==> a priori, aucune caracteristique particuliere
c
      do 31 , iaux = 1 , nctfar
        cfaare(iaux,nbfare+1) = 0
        cfaare(iaux,nbfare+2) = 0
   31 continue
c
c 3.2. ==> La famille MED
c
      cfaare(cofamd,nbfare+1) = nufamd(1)
      cfaare(cofamd,nbfare+2) = nufamd(1)
c
c 3.3. ==> le type des elements est le meme que celui d'une
c          autre famille
c          si aucun n'est trouve, on l'impose
c
      kaux = 0
c
      do 33 , iaux = 1 , nbfare
c
        if ( cfaare(cotyel,iaux).ne.0 ) then
          kaux = cfaare(cotyel,iaux)
          goto 330
        endif
c
   33 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) mess14(langue,3,1)
#endif
c
      if ( degre.eq.1 ) then
        kaux = edseg2
      else
        kaux = edseg3
      endif
c
  330 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Type des '//mess14(langue,3,1), kaux
#endif
c
      cfaare(cotyel,nbfare+1) = kaux
      cfaare(cotyel,nbfare+2) = kaux
c
c 3.4. ==> les orientations
c
      cfaare(coorfa,nbfare+1) = 1
      cfaare(coorfa,nbfare+2) = -1
c
      cfaare(cofifa,nbfare+1) = nbfare+2
      cfaare(cofifa,nbfare+2) = nbfare+1
c
c 3.5. ==> total des familles
c
      nbfare = nbfare + 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,4,1), nufamd(1)
      write (ulsort,texte(langue,4)) mess14(langue,4,1), nbfare
#endif
c
      if ( nbfare.gt.nbfarm ) then
        write (ulsort,texte(langue,4)) mess14(langue,4,1), nbfare
        write (ulsort,texte(langue,5)) nbfarm
        write (ulsort,texte(langue,6))
        codret = 1
      endif
c
c====
c 4. On ajoute une nouvelle famille de quadrangles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Ajout fam. quadrangles ; codret', codret
#endif
c
      if ( nbquad.ne.0 .or. nbhexa.ne.0 .or. nbpent.ne.0 ) then
c
c 4.1. ==> a priori, aucune caracteristique particuliere
c
      do 41 , iaux = 1 , nctfqu
        cfaqua(iaux,nbfqua+1) = 0
   41 continue
c
c 4.2. ==> La famille MED
c
      cfaqua(cofamd,nbfqua+1) = nufamd(2)
c
c 4.3. ==> le type des elements est le meme que celui d'une
c          autre famille
c          si aucun n'est trouve, on l'impose
c
      kaux = 0
c
      do 43 , iaux = 1 , nbfqua
c
        if ( cfaqua(cotyel,iaux).ne.0 ) then
          kaux = cfaqua(cotyel,iaux)
          goto 430
        endif
c
   43 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) mess14(langue,3,4)
#endif
c
      if ( degre.eq.1 ) then
        kaux = edqua4
      else
        kaux = edqua8
      endif
c
  430 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Type des '//mess14(langue,3,4), kaux
#endif
c
      cfaqua(cotyel,nbfqua+1) = kaux
c
c 4.4. ==>  la famille des aretes tracees : la famille libre
c
      cfaqua(cofafa,nbfqua+1) = 1
c
c 4.5. ==> total des familles
c
      nbfqua = nbfqua + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,4,4), nufamd(2)
      write (ulsort,texte(langue,4)) mess14(langue,4,4), nbfqua
#endif
c
      if ( nbfqua.gt.nbfqum ) then
        write (ulsort,texte(langue,4)) mess14(langue,4,4), nbfqua
        write (ulsort,texte(langue,5)) nbfqum
        write (ulsort,texte(langue,6))
        codret = 1
      endif
c
      endif
c
c====
c 5. On ajoute une nouvelle famille de triangles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Ajout fam. triangles; codret', codret
#endif
c
      if ( nbtria.ne.0 .or. nbtetr.ne.0 .or. nbpent.ne.0 ) then
c
c 5.1. ==> a priori, aucune caracteristique particuliere
c
      do 51 , iaux = 1 , nctftr
        cfatri(iaux,nbftri+1) = 0
   51 continue
c
c 5.2. ==> La famille MED
c
      cfatri(cofamd,nbftri+1) = nufamd(3)
c
c 5.3. ==> le type des elements est le meme que celui d'une
c          autre famille
c          si aucun n'est trouve, on l'impose
c
      kaux = 0
c
      do 53 , iaux = 1 , nbftri
c
        if ( cfatri(cotyel,iaux).ne.0 ) then
          kaux = cfatri(cotyel,iaux)
          goto 530
        endif
c
   53 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) mess14(langue,3,2)
#endif
c
      if ( degre.eq.1 ) then
        kaux = edtri3
      else
        kaux = edtri6
      endif
c
  530 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Type des '//mess14(langue,3,2), kaux
#endif
c
      cfatri(cotyel,nbftri+1) = kaux
c
c 5.4. ==> la famille des aretes tracees : la famille libre
c
      cfatri(cofafa,nbftri+1) = 1
c
c 5.5. ==> total des familles
c
      nbftri = nbftri + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,4,2), nufamd(3)
      write (ulsort,texte(langue,4)) mess14(langue,4,2), nbftri
#endif
c
      if ( nbftri.gt.nbftrm ) then
        write (ulsort,texte(langue,4)) mess14(langue,4,2), nbftri
        write (ulsort,texte(langue,5)) nbftrm
        write (ulsort,texte(langue,6))
        codret = 1
      endif
c
      endif
c
c====
c 6. modification des structures des familles MED
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. modification ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 61 , iaux = 1 , 3
c
        if ( codret.eq.0 ) then
c
        jaux = nbfme0+iaux
c
        do 611 , kaux = 1 , 10
          nomfam(kaux,jaux) = blan08
  611   continue
c
        numfam(jaux) = nufamd(iaux)
        call utench ( nufamd(iaux), '_', kaux, saux08,
     >                ulsort, langue, codret )
c                         12345678
        nomfam(1,jaux) = 'HOMARD__'
        nomfam(2,jaux)(1:kaux) = saux08(1:kaux)
c
c       un groupe dont le nom est 'HOMARD', mais que l'on astreint a
c       une longueur totale de 80 caracteres pour etre coherent avec MED
c
        grfmpo(jaux) = grfmpo(jaux-1) + 10
        do 610 , kaux = grfmpo(jaux-1)+1 , grfmpo(jaux)
          grfmta(kaux) = 8
          grfmtb(kaux) = blan08
  610   continue
c                                   12345678
        grfmtb(grfmpo(jaux-1)+1) = 'HOMARD  '
c
        endif
c
   61 continue
c
      endif
c
c====
c 7. la fin
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
