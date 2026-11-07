      subroutine utb13d ( coonoe,
     >                    somare, hetare,
     >                    famare, cfaare,
     >                    nbfmed, numfam,
     >                    grfmpo, grfmtl, grfmtb,
     >                    nbgrfm, nomgro, lgnogr,
     >                    famnum, famval,
     >                    lifagr,
     >                    ulbila,
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
c    UTilitaire - Bilan sur le maillage - option 13 - phase d
c    --           -                              --         -
c ______________________________________________________________________
c
c longueurs des sous-domaines du maillage de calcul
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . famare . e   . nbarto . famille des aretes                         .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
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
c . famtri . e   . nbtrto . famille des triangles                      .
c . nbfmed . e   .    1   . nombre de familles au sens MED             .
c . numfam . e   . nbfmed . numero des familles au sens MED            .
c . grfmpo . e   .0:nbfmed. pointeur des groupes des familles          .
c . grfmtl . e   .   *    . taille des groupes des familles            .
c . grfmtb . e   .10ngrouc. table des groupes des familles             .
c . nbgrfm . e   .    1   . nombre de groupes                          .
c . nomgro . e   .char*(*). noms des groupes (paquets de 10char8)      .
c . lgnogr . e   . nbgrfm . longueur des noms des groupes              .
c . famnum .  a  .   *    . famille : numero avec une valeur           .
c . famval .  a  .   *    . famille : la valeur                        .
c . lifagr .  a  .   *    . liste des familles contenant le groupe     .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB13D' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "envca1.h"
c
#include "dicfen.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto), hetare(nbarto)
c
      integer famare(nbarto), cfaare(nctfar,nbfare)
c
      integer nbfmed, numfam(nbfmed)
      integer grfmpo(0:nbfmed)
      integer grfmtl(*)
      integer nbgrfm, lgnogr(nbgrfm)
c
      character*8 grfmtb(*)
      character*8 nomgro(*)
c
      integer famnum(*)
      double precision famval(*)
c
      integer  lifagr(*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer larete
      integer etat
      integer famnbv
c
      double precision daux
c
      integer nbmess
      parameter (nbmess = 20 )
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
      texte(1,4) = '(''Nombre de '',a,'' actifs : '',i8)'
      texte(1,5) = '(''. Examen du '',a,i8)'
      texte(1,6) = '(''... Longueur du '',a,i8,'' :'',g14.6)'
      texte(1,7) = '(''..... Stockage'',i8,'' pour la famille '',i8)'
c
      texte(2,4) = '(''Number of active '',a,'' : '',i8)'
      texte(2,5) = '(''. Examination of '',a,''#'',i8)'
      texte(2,6) = '(''... Length of '',a,''#'',i8,'' :'',g14.6)'
      texte(2,7) = '(''..... Save'',i8,'' for familiy # '',i8)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbarac
#endif
c
      codret = 0
c
c====
c 2. calcul des longueurs des aretes
c====
c
c 2.1. ==> initialisation
c
      famnbv = 0
c
      if ( nbarac.gt.0 ) then
c
        do 21 , iaux = 1 , nbarac
          famnum(iaux) = 0
          famval(iaux) = 0.d0
   21   continue
c
        do 22 , larete = 1, nbarto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,1), larete
#endif
c
          if ( cfaare(cotyel,famare(larete)).ne.0 ) then
c
          etat = mod( hetare(larete) , 10 )
c
          if ( etat.eq.0 ) then
c
c 2.2.1. ==> longueur de l'arete courante
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLGAR', nompro
#endif
            call utlgar ( larete, coonoe, somare,
     >                    daux,
     >                    ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,1), larete, daux
#endif
c
c 4.2.2. ==> stockage dans la bonne famille
c
            jaux = 0
            do 222 , iaux = 1 , famnbv
              if ( famnum(iaux).eq.cfaare(cofamd,famare(larete)) ) then
                jaux = iaux
                goto 223
              endif
  222       continue
            famnbv = famnbv + 1
            jaux = famnbv
            famnum(jaux) = cfaare(cofamd,famare(larete))
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,7)) jaux, famnum(jaux)
#endif
c
  223       continue
c
            famval(jaux) = famval(jaux) + daux
c
          endif
c
          endif
c
   22   continue
c
      endif
c
c====
c 3. impression
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. impression ; codret =', codret
      write (ulsort,90002) 'famnbv', famnbv
#endif
c
      if ( famnbv.ne.0 ) then
c
      iaux = 1
      kaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB13E_are', nompro
#endif
      call utb13e ( kaux, iaux,
     >              nbfmed, numfam,
     >              grfmpo, grfmtl, grfmtb,
     >              nbgrfm, nomgro, lgnogr,
     >              famnbv, famnum, famval,
     >              lifagr,
     >              ulbila,
     >              ulsort, langue, codret )
c
      endif
c
      end
