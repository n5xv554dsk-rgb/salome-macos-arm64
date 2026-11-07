      subroutine vccfca ( nbfare, cfaare,
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
c    aVant adaptation - Creation des Familles - CArmel
c                       -            -          --
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
      parameter ( nompro = 'VCCFCA' )
c
#include "nblang.h"
#include "consts.h"
c
#include "cofaar.h"
#include "coftfq.h"
#include "cofatq.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
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
c
      texte(2,4) = '(a14,'' : number of HOMARD families:'',i8)'
      texte(2,5) = '(''This number is greater than maximum:'',i8)'
      texte(2,6) = '(''Modify UTINCG program.'')'
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
c 2. On ajoute deux nouvelles familles d'aretes internes :
c    - le type des autres aretes
c    - aucune autre caracteristique
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Ajout fam. aretes ; codret', codret
#endif
c
c 2.1. ==> a priori, aucune caracteristique particuliere
c
      do 21 , iaux = 1 , nctfar
        cfaare(iaux,nbfare+1) = 0
        cfaare(iaux,nbfare+2) = 0
   21 continue
c
c 2.2. ==> Le type des elements est le meme que celui d'une
c          autre famille
c
      kaux = 0
c
      do 22 , iaux = 1 , nbfare
c
        if ( cfaare(cotyel,iaux).ne.0 ) then
          kaux = cfaare(cotyel,iaux)
          goto 220
        endif
c
   22 continue
c
  220 continue
c
      cfaare(cotyel,nbfare+1) = kaux
      cfaare(cotyel,nbfare+2) = kaux
c
c 2.3. ==> les orientations
c
      cfaare(coorfa,nbfare+1) = 1
      cfaare(coorfa,nbfare+2) = -1
c
      cfaare(cofifa,nbfare+1) = nbfare+2
      cfaare(cofifa,nbfare+2) = nbfare+1
c
c 2.4. ==> total des familles
c
      nbfare = nbfare + 2
c
#ifdef _DEBUG_HOMARD_
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
c 3. On reporte cette famille chez les familles des triangles
c    et quadrangles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Report tria/quad ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 31 , iaux = 1 , nbftri
c
        if ( cfatri(cofafa,iaux).eq.1 ) then
          cfatri(cofafa,iaux) = nbfare
        endif
c
   31 continue
c
      do 32 , iaux = 1 , nbfqua
c
        if ( cfaqua(cofafa,iaux).eq.1 ) then
          cfaqua(cofafa,iaux) = nbfare
        endif
c
   32 continue
c
      endif
c
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
