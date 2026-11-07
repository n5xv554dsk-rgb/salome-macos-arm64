      subroutine mmsnp2 ( nomail,
     >                    indnoe,
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
c    Modification de Maillage - Suppression des Noeuds P2
c    -               -          -               -      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . indnoe . es  . 1      . indice du dernier noeud cree               .
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
      parameter ( nompro = 'MMSNP2' )
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
#include "envca1.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer indnoe
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer ideb
      integer tbiaux(1)
c
      integer codre0, codre1, codre2, codre3, codre4
c
      integer phetno, pcoono, pareno
      integer adnmtr
      integer adnmqu
      integer pfamno, pcfano
      integer pancno
      integer pnouar, pnouno
      integer adhono
      integer pdisno
      integer nbnore, nbp2re, nbimre
      integer adraux
c
      character*8 saux08
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 nnouar, nnouno, ndisno
c
      integer nbmess
      parameter ( nbmess = 10 )
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
      texte(1,5) =
     > '(5x,''Nombre de noeuds p2 (milieux) supprimes : '',i10)'
      texte(1,6) = '(5x,''Il reste encore '',i10,'' noeuds P2.'')'
c
      texte(2,5) =
     > '(5x,''Number of p2 nodes (center) destroyed : '',i10)'
      texte(2,6) = '(5x,i10,'' P2 nodes are still present.'')'
c
c====
c 2. recuperation des pointeurs
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
      if ( codret.eq.0 ) then
c
      iaux = 210
      if ( homolo.ge.1 ) then
        iaux = iaux*11
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono, pareno, adhono,  jaux,
     >              ulsort, langue, codret )
c
      call gmobal ( nhnoeu//'.Deraffin', codre0 )
      if ( codre0.eq.0 ) then
        call gmaloj ( nhnoeu//'.Deraffin', ' ', nbnoto, pancno, codre1 )
        if ( codre1.eq.0 ) then
          do 221 , iaux = 1, nbnoto
            imem(pancno+iaux-1) = iaux
  221     continue
        endif
      elseif ( codre0.eq.2 ) then
        call gmadoj ( nhnoeu//'.Deraffin', pancno, iaux, codre1 )
      else
        codre1 = 2
      endif
      iaux = nbnoto + 1
      call gmalot ( nnouno, 'entier  ', iaux, pnouno, codre2 )
      call gmalot ( ndisno, 'entier  ', nbnoto, pdisno, codre3 )
      iaux = nbarto + 1
      call gmalot ( nnouar, 'entier  ', iaux, pnouar, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      if ( nbtrto.ne.0 ) then
c
        if ( mod(mailet,2).eq.0 ) then
          iaux = 19
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
          call utad02 ( iaux, nhtria,
     >                    jaux,   jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  adnmtr,   jaux,   jaux,
     >                  ulsort, langue, codret )
          endif
c
      endif
c
      if ( nbquto.ne.0 ) then
c
        if ( mod(mailet,3).eq.0 ) then
          iaux = 19
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
          call utad02 ( iaux, nhquad,
     >                    jaux,   jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  adnmqu,   jaux,   jaux,
     >                  ulsort, langue, codret )
        endif
c
      endif
c
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Fin etape 2 avec codret = ', codret
#endif
c
c====
c 3. suppression effective des noeuds p2
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. suppression effective ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMSN21', nompro
#endif
      call mmsn21 ( imem(pdisno),
     >              imem(pancno), imem(pnouno), imem(phetno),
     >              imem(pnouar),
     >              nbnore, nbp2re, nbimre )
c
      endif
c
      if ( codret.eq.0 ) then
c
      write(ulsort,texte(langue,5)) nbnoto - nbnore
c
      if ( nbp2re.ne.0 ) then
        write(ulsort,texte(langue,6)) nbp2re
        codret = 1
      endif
c
      indnoe = nbnore
c
      endif
c
c====
c 4. compactage des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. compactage ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      if ( mod(mailet,2).eq.0 ) then
        iaux = iaux*2
      endif
      if ( mod(mailet,3).eq.0 ) then
        iaux = iaux*3
      endif
      if ( homolo.ge.1 ) then
        iaux = iaux*5
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCNNO', nompro
#endif
      call utcnno ( iaux,
     >         rmem(pcoono),
     >         imem(phetno), imem(pfamno), imem(pareno), imem(adhono),
     >         tbiaux, tbiaux,
     >         imem(adnmtr),
     >         imem(adnmqu),
     >         imem(pnouar), imem(pnouno), nbnoto )
c
      endif
c
c====
c 5. redimensionnement des tableaux
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. redimensionnement ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 2730
      if ( homolo.ge.1 ) then
        iaux = iaux*11
      endif
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD05', nompro
#endif
      call utad05 ( iaux, jaux, nhnoeu,
     >              nbnoto, nbnore, sdim,
     >              phetno,
     >              pfamno,
     >              pcoono, pareno, adhono, pancno,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( nharet//'.InfoSupp',codret )
c
      endif
c
c====
c 6. Changement de numerotation des noeuds dans les connectivites
c    des mailles-points et des aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. Renumerotation ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbmpto.gt.0 ) then
        ideb = 1
      else
        ideb = 2
      endif
c
      do 60 , iaux = ideb , 2
c
c 6.1. ==> caracterisation de la connectivite
c
        if ( codret.eq.0 ) then
c
        if ( iaux.eq.1 ) then
          saux08 = nhmapo
          jaux = nbmpto
        elseif ( iaux.eq.2 ) then
          saux08 = nharet
          jaux = 2*nbarto
        endif
c
        call gmadoj ( saux08//'.ConnDesc', adraux, kaux, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
c 6.2. ==> changement effectif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MMSN22', nompro
#endif
        call mmsn22 ( jaux, imem(adraux), imem(pnouno) )
c
        endif
c
   60 continue
c
      endif
c
c====
c 7. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '7. Menage ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( nnouno, codre1 )
      call gmlboj ( ndisno, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 8. la fin
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
