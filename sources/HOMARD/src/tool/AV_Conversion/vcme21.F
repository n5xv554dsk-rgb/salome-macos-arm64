      subroutine vcme21 ( typenh, cofxeo,
     >                    nbinfx, nctfen, nbenti,
     >                    notfen, nofaen, cofaen,
     >                    nhenfa, fament, posent, inxent,
     >                    nbfaen, pcfaen,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 21
c     -                 -             -        -               --
c Determine les familles pour un type de mailles de la face avant
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .    1   . type d'entites                             .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : segments                             .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . cofxeo . e   .    1   . orientation de l'entite comme face/volume  .
c . nbinfx . e   .    1   . nombre d'informations pour inxent          .
c . nctfen . e   .    1   . nombre de caracteristique des f. entite    .
c . nbenti . e   .    1   . nombre d'entites                           .
c . notfen . e   .  1     . nombre d'origine des carac. des f. entite  .
c . nofaen . e   .  1     . nombre d'origine de familles de l'entite   .
c . cofaen . e   . notfen*. codes d'origine des familles de l'entite   .
c .        .     . nofaen .                                            .
c . nhenfa . e   . char8  . objet decrivant les familles de l'entite   .
c . fament . es  . nbenti . famille des entites                        .
c . posent . e   . nbenti . position des entites                       .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c .        .     .        . 2 : perpendiculaire                        .
c . inxent . e   . nbinfx*. informations pour l'extrusion des entites  .
c .        .     . nbenti . 1 : famille de l'entite extrudee           .
c .        .     .        . 2 : famille de l'entite perpendiculaire    .
c .        .     .        . Si arete :                                 .
c .        .     .        . 3 : code du quadrangle dans le volume      .
c .        .     .        . 4 : quadrangle perpendiculaire             .
c .        .     .        . Si triangle ou quadrangle :                .
c .        .     .        . 3 : code de la face dans le volume         .
c . nbfaen .  s  .  1     . nombre de familles de l'entite             .
c . pcfaen .  s  .  1     . codes des familles de l'entite             .
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
      parameter ( nompro = 'VCME21' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh
      integer cofxeo
      integer nbinfx, nctfen, nbenti
      integer notfen, nofaen, cofaen(notfen,nofaen)
      integer nbfaen, pcfaen
c
      integer fament(nbenti), posent(nbenti), inxent(nbinfx,nbenti)
c
      character*8 nhenfa
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
      integer nbfae0
      integer nument
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
c
      texte(2,4) = '(''Description of families of extruded '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,90002) 'nbenti', nbenti
      write (ulsort,90002) 'cofxeo', cofxeo
      write (ulsort,90002) 'nbinfx', nbinfx
      write (ulsort,90002) 'nctfen', nctfen
#endif
c
#ifdef _DEBUG_HOMARD_
      do 4991 , nument = 1 , nbenti
        if ( posent(nument).eq.0 .or. typenh.eq.4 ) then
        write(ulsort,90012) mess14(langue,3,typenh),nument,
     >               fament(nument),(inxent(iaux,nument),iaux=1,nbinfx)
        endif
 4991 continue
#endif
c
      codret = 0
c
c====
c 2. Menage initial
c====
c
      call gmlboj ( nhenfa//'.Codes' , codre0  )
      codret = max ( abs(codre0), codret )
c
c====
c 3. Parcours des entites
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. parcours ; codret', codret
#endif
c
c 3.1. ==> Taille initiale du tableau
c
      nbfae0 = 0
      nbfaen = 0
      nument = 0
c
c 3.2. ==> Creation/Allongement du tableau des familles
c          Au moins 6 pour passer la phase initiale
c
   32 continue
c
      if ( codret.eq.0 ) then
c
      nbfae0 = nbfae0 + 21
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfaen', nbfaen
      write (ulsort,90002) 'nbfae0', nbfae0
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFAM2', nompro
#endif
      call utfam2 ( typenh, nhenfa, nctfen, nbfae0,
     >              pcfaen,
     >              ulsort, langue, codret)
#ifdef _DEBUG_HOMARD_
      if ( typenh.eq.1 ) then
      call gmprsx ( mess14(langue,3,typenh), nhenfa//'.Codes')
      endif
#endif
c
      endif
c
c 3.3. ==> Programme utilitaire
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME22', nompro
#endif
      call vcme22 ( typenh, nument, cofxeo,
     >              nbinfx, nctfen, nbenti,
     >              notfen, nofaen, cofaen,
     >              nbfae0, nbfaen, imem(pcfaen),
     >              fament, posent, inxent,
     >              ulsort, langue, codret )
c
      endif
c
c 3.4. ==> A rallonger ?
c
      if ( codret.eq.0 ) then
c
      if ( nbfaen.lt.0 ) then
c
        nbfaen = -nbfaen
        goto 32
c
      endif
c
      endif
c
c====
c 4. Redimensionnement final
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Redimensionnement ; codret', codret
      write (ulsort,90002) 'nbfaen', nbfaen
      write (ulsort,90002) 'nbfae0', nbfae0
#endif
#ifdef _DEBUG_HOMARD_
      if ( typenh.eq.1 ) then
      call gmprsx ( mess14(langue,3,typenh), nhenfa//'.Codes')
      endif
#endif
c
      if ( nbfaen.ne.nbfae0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFAM2', nompro
#endif
        call utfam2 ( typenh, nhenfa, nctfen, nbfaen,
     >                pcfaen,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( typenh.eq.1 ) then
      call gmprsx ( mess14(langue,3,typenh), nhenfa//'.Codes')
      endif
#endif
c
c====
c 5. la fin
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
