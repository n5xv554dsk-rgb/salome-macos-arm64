      subroutine pcfaat ( typcca,
     >                    nhsupe, nhsups, nhqufa,
     >                    hetare, somare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    perqua, nivqua,
     >                    povoso, voisom,
     >                    posifa, facare,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, pcfaqu,
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
c    aPres adaptation - Conversion - FAmilles pour ATHENA
c     -                 -            --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typcca . e   .   1    . type du code de calcul                     .
c . nhsupe . es  . char8  . informations supplementaires entieres      .
c . nhsups . es  . char8  . informations supplementaires caracteres 8  .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . nhqufa . e   . char8  . nom de l'objet des familles de quadrangles .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . povoso . e   .0:nbnoto. pointeur des voisins par noeud             .
c . voisom . e   . nvosom . aretes voisines de chaque noeud            .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
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
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . es  . nbquto . famille des quadrangles                    .
c . pcfaqu . es  .    1   . adresse des codes des familles de quad.    .
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
      parameter ( nompro = 'PCFAAT' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
#include "nbutil.h"
#include "nbfami.h"
#include "nbfamm.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
#include "dicfen.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typcca
c
      integer hetare(nbarto), somare(2,nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer perqua(nbquto), nivqua(nbquto)
      integer povoso(0:nbnoto), voisom(*)
      integer posifa(0:nbarto), facare(nbfaar)
c
      integer famare(nbarto), cfaare(nctfar,nbfare)
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
      integer famqua(nbquto)
      integer pcfaqu
c
      character*8 nhsupe, nhsups, nhqufa
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codre0
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6
      integer ptrav1, ptrav2, ptrav3, ptrav4, ptrav5
      integer ptra15, ptra16
      integer ptrae3, ptrae4, ptrae9, ptras4, ptras5
      integer adsue3, adsue4, adsue9, adsus4, adsus9
c
      integer un
      integer nbblqu
      integer nattrc, nbattr, nbfold, nbfn00, nbfnew, nbfq00
c
      character*8 ntrav1, ntrav2, ntrav3, ntrav4, ntrav5
      character*8 ntra15, ntra16
      character*8 ntrae3, ntrae4, ntrae9, ntras4, ntras9
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
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Traitement specifique a ATHENA'')'
      texte(1,5) = '(i6,'' blocs de '',a,/)'
      texte(1,10) = '(''Type du code de calcul (typcca) :'',i5)'
c
      texte(2,4) = '(''Specific treatment to ATHENA'')'
      texte(2,5) = '(i6,'' blocks of '',a,/)'
      texte(2,10) = '(''Type of calculation code (typcca) :'',i5)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) typcca
#endif
c
      if ( typcca.eq.16 ) then
        codret = 0
      else
        codret = 1
        write (ulsort,texte(langue,10)) typcca
        write (ulsort,texte(langue,4))
      endif
c
      un = 1
c
c====
c 2. tableaux de travail
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. tableaux de travail ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', nbquto, ptrav1, codre1 )
      call gmalot ( ntrav2, 'entier  ', nbnoto, ptrav2, codre2 )
      call gmalot ( ntrav3, 'entier  ', nbarto, ptrav3, codre3 )
      iaux = nbquto + nbtrto + 1
      call gmalot ( ntrav4, 'entier  ', iaux, ptrav4, codre4 )
      iaux = nbquto + 1
      call gmalot ( ntrav5, 'entier  ', iaux, ptrav5, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      call gmalot ( ntra15, 'entier  ', nbarto, ptra15, codre1 )
      call gmalot ( ntra16, 'entier  ', nbarto, ptra16, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 3. recherche des blocs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. recherche des blocs ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
c       on examine toutes les faces
c
      jaux = nbquto + nbtrto
      do 42 , iaux = 0, jaux
        imem(ptrav4+iaux) = 1
   42 continue
      imem(ptrav4+nbquto) = 0
      iaux = 0
      jaux = 0
      call utb11c ( nbblqu, iaux, imem(ptrav4),
     >              hetare, somare,
     >              hettri, aretri,
     >              hetqua, arequa,
     >              povoso, voisom,
     >              posifa, facare,
     >              famare, cfaare,
     >              famtri, cfatri,
     >              famqua, imem(pcfaqu),
     >              imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >              imem(ptra15), imem(ptra16),
     >              imem(ptrav5),
     >              jaux, ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
10000 format(3x,20i4)
10001 format(4x,80('-'))
      write(ulsort,*) 'Fin etape 3 avec codret = ', codret
      write(ulsort,texte(langue,5)) nbblqu, mess14(langue,3,4)
      write(ulsort,10000) (iaux,iaux=1,min(20,nbquto))
      write(ulsort,10001)
      write(ulsort,10000) (imem(ptrav5+iaux),iaux=0,min(20,nbquto-1))
      write(ulsort,10000) (imem(pcfaqu+iaux),iaux=0,nctfqu*nbfqua-1)
      write(ulsort,10000) (famqua(iaux),iaux=1,min(20,nbquto))
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav2, codret )
c
      endif
c
c====
c 4. Gestion des tableaux
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Gestion des tableaux ; codret = ', codret
#endif
c
      nbattr = 4
c
c 4.1. ==> Description actuelle des attributs
c
c      nhsupe//'.Tab3' : Pointeur dans la table des attributs
c      nhsupe//'.Tab4' : Table des attributs
c      nhsupe//'.Tab5' : Pointeur dans la table des groupes
c      nhsupe//'.Tab6' : Taille des noms des groupes
c      nhsupe//'.Tab9' : Numero des familles MED
c      nhsups//'.Tab2' : Noms des groupes (char*80)
c      nhsups//'.Tab4' : Noms des familles MED (char*64)
c      nhsups//'.Tab9' : Descriptions des attributs (char*200)
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nhsupe )
      call gmprsx (nompro, nhsupe//'.Tab3' )
      call gmprsx (nompro, nhsupe//'.Tab4' )
      call gmprsx (nompro, nhsupe//'.Tab9' )
      call gmprsx (nompro, nhsups )
      call gmprsx (nompro, nhsups//'.Tab4' )
      call gmprsx (nompro, nhsups//'.Tab9' )
#endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( nhsupe//'.Tab3', adsue3, iaux, codre1 )
      call gmadoj ( nhsupe//'.Tab4', adsue4, iaux, codre2 )
      call gmadoj ( nhsupe//'.Tab9', adsue9, iaux, codre3 )
      call gmadoj ( nhsups//'.Tab4', adsus4, iaux, codre4 )
      call gmadoj ( nhsups//'.Tab9', adsus9, iaux, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
c 4.2. ==> Caracteristiques des familles MED
c
      nbfn00 = nbblqu*nbfmed
      nbfq00 = nbfqum
c
      if ( codret.eq.0 ) then
c
      iaux = nbfn00 + 1
      call gmalot ( ntrae3, 'entier  ', iaux, ptrae3, codre1 )
      iaux = nbattr * (nbfn00-1)
      call gmalot ( ntrae4, 'entier  ', iaux, ptrae4, codre2 )
      call gmalot ( ntrae9, 'entier  ', nbfn00, ptrae9, codre3 )
      iaux = 10 * nbfn00
      call gmalot ( ntras4, 'chaine  ', iaux, ptras4, codre4 )
      iaux = 25 * nbattr * (nbfn00-1)
      call gmalot ( ntras9, 'chaine  ', iaux, ptras5, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      call gmmod ( nhqufa//'.Codes', pcfaqu,
     >             nctfqu, nctfqu, nbfqua, nbfq00, codre1 )
      iaux = nbfn00 * (nctfqu+3)
      call gmalot ( ntrav2, 'entier  ', iaux, ptrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 5. Creation des familles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Creation des familles ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFAA1', nompro
#endif
      nbfold = nbfmed
      call pcfaa1 ( nbblqu,
     >              nbattr, nbfold, nbfn00, nbfnew, nbfq00,
     >              perqua, nivqua,
     >              famqua, imem(pcfaqu),
     >              imem(adsue3), imem(ptrae3),
     >              imem(adsue4), imem(ptrae4),
     >              imem(adsue9), imem(ptrae9),
     >              smem(adsus4), smem(ptras4),
     >              smem(adsus9), smem(ptras5),
     >              imem(ptrav5), imem(ptrav2),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 6. Gestion des tableaux
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. Gestion des tableaux ; codret = ', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ntrae3 )
      call gmprsx (nompro, ntrae4 )
      call gmprsx (nompro, ntrae9 )
      call gmprsx (nompro, ntras4 )
      call gmprsx (nompro, ntras9 )
#endif
c
c 6.1. ==> Redimensionnement des tableaux lies aux attributs
c
      if ( codret.eq.0 ) then
c
      nbfmed = nbfnew
      nattrc = nbattr*(nbfmed-1)
c
      iaux = nbfn00 + 1
      jaux = nbfmed + 1
      call gmmod ( ntrae3, ptrae3, iaux, jaux, un, un, codre1 )
      call gmmod ( ntrae4, ptrae4,
     >             nbattr, nbattr, nbfn00-1, nbfmed-1, codre2 )
      call gmmod ( ntrae9, ptrae9, nbfn00, nbfmed, un, un, codre3 )
      iaux = 4
      call gmmod ( ntras4, ptras4, iaux, iaux, nbfn00, nbfmed, codre4 )
      iaux = nbattr * 25
      call gmmod ( ntras9, ptras5,
     >             iaux, iaux, nbfn00-1, nbfmed-1, codre5 )
      call gmmod ( nhqufa//'.Codes', pcfaqu,
     >             nctfqu, nctfqu, nbfq00, nbfqua, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ntrae3 )
      call gmprsx (nompro, ntrae4 )
      call gmprsx (nompro, ntrae9 )
      call gmprsx (nompro, ntras4 )
      call gmprsx (nompro, ntras9 )
#endif
c
      endif
c
c 6.2. ==> Remplacement dans la structure generale des tableaux
c          lies aux attributs
c
      if ( codret.eq.0 ) then
c
      call gmcpoj ( ntrae3, nhsupe//'.Tab3', codre1 )
      call gmcpoj ( ntrae4, nhsupe//'.Tab4', codre2 )
      call gmcpoj ( ntrae9, nhsupe//'.Tab9', codre3 )
      call gmcpoj ( ntras4, nhsups//'.Tab4', codre4 )
      call gmcpoj ( ntras9, nhsups//'.Tab9', codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      call gmecat ( nhsupe, 3, nbfmed+1, codre1 )
      call gmecat ( nhsupe, 4, nattrc, codre2 )
      iaux = 25 * nattrc
      call gmecat ( nhsups, 9, iaux, codre3 )
      call gmecat ( nhsupe, 9, nbfmed, codre4 )
      iaux = 4*nbfmed
      call gmecat ( nhsups, 4, iaux, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nhsupe )
      call gmprsx (nompro, nhsupe//'.Tab3' )
      call gmprsx (nompro, nhsupe//'.Tab4' )
      call gmprsx (nompro, nhsupe//'.Tab9' )
      call gmprsx (nompro, nhsups )
      call gmprsx (nompro, nhsups//'.Tab4' )
      call gmprsx (nompro, nhsups//'.Tab9' )
#endif
c
      endif
c
c 6.3. ==> Menage
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
      call gmlboj ( ntrav3, codre3 )
      call gmlboj ( ntrav4, codre4 )
      call gmlboj ( ntrav5, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      call gmlboj ( ntra15, codre1 )
      call gmlboj ( ntra16, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      call gmlboj ( ntrae3, codre1 )
      call gmlboj ( ntrae4, codre2 )
      call gmlboj ( ntrae9, codre3 )
      call gmlboj ( ntras4, codre4 )
      call gmlboj ( ntras9, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
c====
c 7. la fin
c====
c
#ifdef _DEBUG_HOMARD_
70000 format(3x,20i4)
      write(ulsort,*) 'Etape 7 avec codret = ', codret
      write(ulsort,70000) (imem(pcfaqu+iaux),iaux=0,nctfqu*nbfqua-1)
      write(ulsort,70000) (famqua(iaux),iaux=1,min(20,nbquto))
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
