      subroutine vcme24 ( numfam,
     >                    nbfpe0,
     >                    cfaqua,
     >                    cfahex,
     >                    cfapen,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 24
c     -                 -             -        -               --
c Determine les familles pour la relation hexaedres/pentaedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numfam . es  .    1   . numero de la derniere famille traitee      .
c . nbfpe0 . e   .  1     . nombre de familles pour le dimensionnement .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        .   7 : famille du quadrangle extrude        .
c .        .     .        .   8 : famille du volume perpendiculaire    .
c .        .     .        .   9 : code du quadrangle dans hexa ou penta.
c .        .     .        .  10 : position du quadrangle               .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . cfahex . es  . nctfhe*. codes des familles des hexaedres           .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c .        .     .        . si extrusion :                             .
c .        .     .        .   3 : famille des pentaedres de conformite .
c . cfapen . es  . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
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
      parameter ( nompro = 'VCME24' )
c
#include "nblang.h"
#include "consts.h"
#include "cofaar.h"
#include "coftex.h"
#include "cofexq.h"
#include "cofexh.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "meddc0.h"
#include "dicfen.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      integer numfam
      integer nbfpe0
      integer cfaqua(nctfqu,nbfqua)
      integer cfahex(nctfhe,nbfhex)
      integer cfapen(nctfpe,nbfpen)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lafami, famdeb
      integer fahohe, fammed
      integer nufaex
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'numfam', numfam
      write (ulsort,90002) 'nbfpe0', nbfpe0
      write (ulsort,90002) 'nbfqua', nbfqua
      write (ulsort,90002) 'nctfqu', nctfqu
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Codes des familles des quadrangles'
      do 5991 , iaux = 1 , nbfqua
        write(ulsort,90012) 'Famille', iaux,
     >                      (cfaqua(jaux,iaux),jaux=1,nctfqu)
 5991 continue
      write (ulsort,*) 'Codes des familles des hexaedres'
      do 5992 , iaux = 1 , nbfhex
        write(ulsort,90012) 'Famille', iaux,
     >                      (cfahex(jaux,iaux),jaux=1,nctfhe)
 5992 continue
      write (ulsort,*) 'Codes des familles des pentaedres'
      do 5993 , iaux = 1 , nbfpen
        write(ulsort,90012) 'Famille', iaux,
     >                      (cfapen(jaux,iaux),jaux=1,nctfpe)
#endif
 5993 continue
c
      codret = 0
c
c====
c 2. Parcours des familles de la face avant des quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. parcours ; codret', codret
#endif
c
      famdeb = numfam + 1
      do 20 , lafami = famdeb, nbfqua
c
        if ( cfaqua(cofxqp,lafami).eq.0 ) then
cgn        write (ulsort,90002) '. Famille de quadrangle', lafami
c
c 2.1. ==> La famille du volume d'extrusion
c
          fahohe = cfaqua(cofxqx,lafami)
          fammed = cfahex(cofamd,fahohe)
cgn      write (ulsort,90002) '.. Familles HOMARD/MED hexa',fahohe,fammed
c
c 2.1.2. ==> On veut une famille de pentaedre avec la meme famille MED
c
          do 212 , iaux = 1 , nbfpen
c
            do 2121 , jaux = 1 , nctfpe
              if ( cfapen(cofamd,iaux).ne.fammed ) then
                goto 212
              endif
 2121       continue
c
              nufaex = iaux
cgn            write (ulsort,90002) '.. Correspond a la famille', nufaex
              goto 23
c
  212       continue
c
c 2.2. ==> Creation d'une nouvelle famille
c 2.2.1. ==> S'il n'y a plus de places, on sort et on recommencera
c            pour cette famille
c
          if ( nbfpen.ge.nbfpe0 ) then
c
            numfam = lafami - 1
            nbfpen = -nbfpen
            goto 2999
c
c 2.2.2. ==> Creation
c
          else
c
c 2.2.2.1. ==> La famille avec les memes caracteristiques
c
            nbfpen = nbfpen + 1
            do 222 , iaux = 1 , nctfpe
              cfapen(iaux,nbfpen) = 0
  222       continue
cgn         write (ulsort,90002) '.. Creation de la famille', nbfpen
            cfapen(cofamd,nbfpen) = fammed
            if ( cfahex(cotyel,fahohe).eq.edhex8 ) then
              cfapen(cotyel,nbfpen) = edpen6
            else
              cfapen(cotyel,nbfpen) = edpe15
            endif
            nufaex = nbfpen
c
          endif
c
c 2.3. ==> Enregistrement de la famille de pentaedres associee a
c          la famille des hexaedres
c
   23     continue
c
          cfahex(cofexh,fahohe) = nufaex
c
        endif
c
   20 continue
c
 2999 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'A la sortie de '//nompro//', nbfhex', nbfhex
      write (ulsort,*) 'Codes des familles des hexaedres'
      do 6991 , iaux = 1 , abs(nbfhex)
        write(ulsort,90012) 'Famille', iaux,
     >                      (cfahex(jaux,iaux),jaux=1,nctfhe)
 6991 continue
      write (ulsort,90002) 'A la sortie de '//nompro//', nbfpen', nbfpen
      write (ulsort,*) 'Codes des familles des pentaedres'
      do 6992 , iaux = 1 , abs(nbfpen)
        write(ulsort,90012) 'Famille', iaux,
     >                      (cfapen(jaux,iaux),jaux=1,nctfpe)
 6992 continue
#endif
c
c====
c 3. la fin
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
