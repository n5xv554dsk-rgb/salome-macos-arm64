      subroutine vcme31 ( nofaqu, cofaqu,
     >                    nharfa, pcfaar, famare, posare, inxare,
     >                    nhqufa, pcfaqu, inxqua,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 31
c     -                 -             -        -               --
c Determine les familles pour le lien face avant / face perpendiculaire
c au cours de l'extrusion des aretes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nofaqu . e   .  1     . nombre d'origine de familles quadrangles   .
c . cofaqu . e   . ncffqu*. codes d'origine des familles des quads.    .
c .        .     . nofaqu .                                            .
c . nharfa . e   . char8  . objet decrivant les familles des aretes    .
c . pcfaar .  e  .    1   . codes des familles des aretes              .
c . famare . es  . nbarto . famille des aretes                         .
c . posare . e   . nbarto . position des aretes                        .
c .        .     .        . 0 : arete avant                            .
c .        .     .        . 1 : arete arriere                          .
c .        .     .        . 2 : arete perpendiculaire                  .
c . inxare . e   .4*nbarto. informations pour l'extrusion des aretes   .
c .        .     .        . 1 : famille de l'arete extrudee            .
c .        .     .        . 2 : famille du quadrangle perpendiculaire  .
c .        .     .        . 3 : code du quadrangle dans le volume      .
c .        .     .        . 4 : quadrangle perpendiculaire             .
c . nhqufa . e   . char8  . objet decrivant les familles de quadrangles.
c . pcfaqu .  s  .  1     . codes des familles de quadrangles          .
c . inxqua . es  .3*nbquto. informations pour l'extrusion des quads    .
c .        .     .        . Pour un quadrangle a l'avant :             .
c .        .     .        .  1 : famille du quadrangle extrude         .
c .        .     .        .  2 : famille de l'hexaedre                 .
c .        .     .        .  3 : orientation du quadrangle dans le vol..
c .        .     .        . Pour un quadrangle a l'arriere :           .
c .        .     .        .  1 : inutile                               .
c .        .     .        .  2 : inutile                               .
c .        .     .        .  3 : orientation du quadrangle dans le vol..
c .        .     .        . Pour un quadrangle perpendiculaire :       .
c .        .     .        .  1 : sens de la 1ere compos. de la normale .
c .        .     .        .  2 : sens de la 2eme compos. de la normale .
c .        .     .        .  3 : orientation du quadrangle dans le vol..
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . e   .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'VCME31' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
#include "nombar.h"
#include "nombqu.h"
#include "nbfami.h"
#include "dicfen.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nofaqu, cofaqu(ncffqu,nofaqu)
      integer famare(nbarto), posare(nbarto), inxare(4,nbarto)
      integer inxqua(3,nbquto)
      integer pcfaar
      integer pcfaqu
c
      character*8 nharfa
      character*8 nhqufa
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbfar0, nbfqu0
      integer numare
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
#include "impr03.h"
c
      texte(1,4) = '(''Familles d''''extrusion des '',a)'
      texte(1,5) = '(''Influence des '',a)'
c
      texte(2,4) = '(''Description of families of extruded '',a)'
      texte(2,5) = '(''Influence of the '',a)'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1)
      write (ulsort,texte(langue,5)) mess14(langue,3,4)
      write (ulsort,90002) 'nctfar', nctfar
      write (ulsort,90002) 'ncffqu', ncffqu
#endif
c
c====
c. Parcours des familles initiales
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. parcours ; codret', codret
#endif
c
c 2.1. ==> Taille initiale du tableau
c
      nbfar0 = nbfare
      nbfqu0 = nbfqua
      numare = 0
c
c 2.2. ==> Allongement de la taille des tableaux des familles
c
   22 continue
c
c 2.2.1. ==> Les familles d'aretes
c
      if ( codret.eq.0 ) then
c
      nbfar0 = nbfar0 + 31
      nbfare = abs(nbfare)
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfare', nbfar0
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFAM2 - are', nompro
#endif
      call utfam2 (   iaux, nharfa, nctfar, nbfar0,
     >              pcfaar,
     >              ulsort, langue, codret)
c
      endif
c
c 2.2.2. ==> Les familles de quadrangles
c
      if ( codret.eq.0 ) then
c
      nbfqu0 = nbfqu0 + 31
      nbfqua = abs(nbfqua)
c
      iaux = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfqua', nbfqu0
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFAM2 - qua', nompro
#endif
      call utfam2 (   iaux, nhqufa, nctfqu, nbfqu0,
     >              pcfaqu,
     >              ulsort, langue, codret)
c
      endif
c
c 2.3. ==> Programme utilitaire
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME32', nompro
#endif
      call vcme32 ( numare,
     >              nofaqu, cofaqu,
     >              famare, posare, inxare,
     >              inxqua,
     >              nbfar0, nbfare, imem(pcfaar),
     >              nbfqu0, nbfqua, imem(pcfaqu),
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ==> A rallonger ?
c
      if ( codret.eq.0 ) then
c
      if ( nbfare.lt.0 ) then
c
        goto 22
c
      endif
c
      if ( nbfqua.lt.0 ) then
c
        goto 22
c
      endif
c
      endif
c
c====
c 3. Redimensionnement final
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Redimensionnement ; codret', codret
#endif
c 3.1. ==> Les familles d'aretes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfare', nbfare
      write (ulsort,90002) 'nbfar0', nbfar0
#endif
c
      if ( nbfare.ne.nbfar0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFAM2 - are', nompro
#endif
        call utfam2 (   iaux, nharfa, nctfar, nbfare,
     >                pcfaar,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 3.2. ==> Les familles de quadrangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfqua', nbfqua
      write (ulsort,90002) 'nbfqu0', nbfqu0
#endif
c
      if ( nbfqua.ne.nbfqu0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 4
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFAM2 - qua', nompro
#endif
        call utfam2 (   iaux, nhqufa, nctfqu, nbfqua,
     >                pcfaqu,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ( mess14(langue,3,1), nharfa//'.Codes')
      call gmprsx ( mess14(langue,3,4), nhqufa//'.Codes')
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
