      subroutine utsvmn ( nomail, nosvmn,
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
c    UTilitaire - creation de SauVegardes du Maillage de l'iteration N
c    --                       -  -           -                       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . nosvmn .   s .  ch8   . nom de l'objet contenant les sauvegardes du.
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
      parameter ( nompro = 'UTSVMN' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*8 nomail, nosvmn
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7
      integer codre0
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
c====
c 2. recuperation des pointeurs, initialisations
c====
c
c 2.1. ==> les caracteristiques du maillage
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
c 2.2. ==> allocation de la sauvegarde
c
      if ( codret.eq.0 ) then
c
      call gmalot ( nosvmn, 'Sauve_HM', 0, iaux, codret )
c
      endif
c
c====
c 3. parente
c====
c
c 3.1. ==> Les attributs
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nosvmn, 1, nbarto, codre1 )
      call gmecat ( nosvmn, 2, nbtrto, codre2 )
      call gmecat ( nosvmn, 3, nbteto, codre3 )
      call gmecat ( nosvmn, 4, nbquto, codre4 )
      call gmecat ( nosvmn, 5, nbpyto, codre5 )
      call gmecat ( nosvmn, 6, nbheto, codre6 )
      call gmecat ( nosvmn, 7, nbpeto, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      endif
c
c 3.2. ==> sur les aretes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSVM0_ar', nompro
#endif
      iaux = 1
      jaux = 2
      call utsvm0 ( iaux, jaux, nharet, nosvmn,
     >              ulsort, langue, codret )
c
      endif
c
c 3.3. ==> sur les triangles
c
      if ( codret.eq.0 ) then
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSVM0_tr', nompro
#endif
        iaux = 2
        jaux = 6
        call utsvm0 ( iaux, jaux, nhtria, nosvmn,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.4. ==> sur les quadrangles
c
      if ( codret.eq.0 ) then
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSVM0_qu', nompro
#endif
        iaux = 4
        jaux = 2
        call utsvm0 ( iaux, jaux, nhquad, nosvmn,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.5. ==> sur les tetraedres
c
      if ( codret.eq.0 ) then
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSVM0_te', nompro
#endif
        iaux = 3
        jaux = 2
        call utsvm0 ( iaux, jaux, nhtetr, nosvmn,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.6. ==> sur les pyramides
c
      if ( codret.eq.0 ) then
c
      if ( nbpyto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSVM0_py', nompro
#endif
        iaux = 5
        jaux = 2
        call utsvm0 ( iaux, jaux, nhpyra, nosvmn,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.7. ==> sur les hexaedres
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSVM0_he', nompro
#endif
        iaux = 6
        jaux = 10
        call utsvm0 ( iaux, jaux, nhhexa, nosvmn,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.8. ==> sur les pentaedres
c
      if ( codret.eq.0 ) then
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSVM0_pe', nompro
#endif
        iaux = 7
        jaux = 10
        call utsvm0 ( iaux, jaux, nhpent, nosvmn,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.9. ==> la renumerotation
c
      if ( codret.eq.0 ) then
c
      call gmcpgp ( norenu, nosvmn//'.RenuMail', codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nosvmn)
      call gmprsx (nompro,nosvmn//'.RenuMail')
      call gmprsx (nompro,nosvmn//'.HEtat_Tr')
#endif
c
c====
c 4. la fin
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
