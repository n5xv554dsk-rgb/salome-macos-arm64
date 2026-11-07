      subroutine pcmar1 ( narsca,
     >                    ntrsca, nqusca,
     >                    ntesca, nhesca, npesca, npysca,
     >                    nparrc, nptrrc, npqurc,
     >                    arerec, trirec, quarec,
     >                    tetrec, hexrec, penrec, pyrrec,
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
c    aPres adaptation - Conversion de MAillage - Recollements - phase 1
c     -                 -             --         -                    -
c    Passage des listes de recollements des numerotations HOMARD
c    aux numerotations du calcul
c    Mise a jour des renumerotations
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . narsca . e   . rsarto . numero des aretes du calcul                .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
c . nqusca . e   . rsquto . numero des quadrangles du calcul           .
c . ntesca . e   . rsteto . numero des tetraedres du calcul            .
c . nhesca . e   . rsheto . numero des hexaedres dans le calcul        .
c . npesca . e   . rspeto . numero des pentaedres dans le calcul       .
c . npysca . e   . rspyto . numero des pyramides dans le calcul sortie .
c . nparrc . e   .   1    . nombre de paires d'aretes a recoller       .
c . nptrrc . e   .   1    . nombre de paires de triangles a recoller   .
c . npqurc . e   .   1    . nombre de paires de quadrangles a recoller .
c . arerec . es  .2*nbarto. paires des aretes a recoller               .
c . trirec . es  .  2* x  . paires des triangles a recoller            .
c . quarec . es  .  2* x  . paires des quadrangles a recoller          .
c . tetrec . es  .  3*x   . paires des tetra. voisins faces a recoller .
c . hexrec . es  .  3*x   . paires des hexa. voisins faces a recoller  .
c . penrec . es  .  3*x   . paires des penta. voisins faces a recoller .
c . pyrrec . es  .  3*x   . paires des pyram. voisines faces a recoller.
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
      parameter ( nompro = 'PCMAR1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombsr.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer narsca(rsarto)
      integer ntrsca(rstrto), nqusca(rsquto)
      integer ntesca(rsteto), nhesca(rsheto)
      integer npysca(rspyto), npesca(rspeto)
      integer nparrc, nptrrc, npqurc
      integer arerec(2,*), trirec(2,*), quarec(2,*)
      integer tetrec(3,*), hexrec(3,*), penrec(3,*), pyrrec(3,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 30 )
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
      write (ulsort,90002) 'nparrc', nparrc
      write (ulsort,90002) 'nptrrc', nptrrc
      write (ulsort,90002) 'npqurc', npqurc
#endif
c
      codret = 0
c
c====
c 2. Changement de numerotation dans les listes d'entites a recoller
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> les aretes
c
        do 21 , iaux = 1 , nparrc
c
          arerec(1,iaux) = narsca(arerec(1,iaux))
          arerec(2,iaux) = narsca(arerec(2,iaux))
c
   21   continue
c
c 2.2. ==> les triangles
c
        do 22 , iaux = 1 , nptrrc
c
          trirec(1,iaux) = ntrsca(trirec(1,iaux))
          trirec(2,iaux) = ntrsca(trirec(2,iaux))
c
   22   continue
c
c 2.3. ==> les quadrangles
c
        do 23 , iaux = 1 , npqurc
c
          quarec(1,iaux) = nqusca(quarec(1,iaux))
          quarec(2,iaux) = nqusca(quarec(2,iaux))
c
   23   continue
c
c 2.4. ==> les tetraedres
c
        do 24 , iaux = 1 , nptrrc
c
          tetrec(1,iaux) = ntesca(tetrec(1,iaux))
          tetrec(2,iaux) = ntesca(tetrec(2,iaux))
          tetrec(3,iaux) = ntrsca(tetrec(3,iaux))
c
   24   continue
c
c 2.5. ==> les hexaedres
c
        do 25 , iaux = 1 , npqurc
c
          hexrec(1,iaux) = nhesca(hexrec(1,iaux))
          hexrec(2,iaux) = nhesca(hexrec(2,iaux))
          hexrec(3,iaux) = nqusca(hexrec(3,iaux))
c
   25   continue
c
c 2.6. ==> les pentaedres
c
        if ( rspeto.gt.0 ) then
c
          do 26 , iaux = 1 , nptrrc+npqurc
c
            penrec(1,iaux) = npesca(penrec(1,iaux))
            penrec(2,iaux) = npesca(penrec(2,iaux))
c
   26     continue
c
        endif
c
c 2.7. ==> les pyramides
c
        if ( rspyto.gt.0 ) then
c
          do 27 , iaux = 1 , nptrrc+npqurc
c
            pyrrec(1,iaux) = npysca(pyrrec(1,iaux))
            pyrrec(2,iaux) = npysca(pyrrec(2,iaux))
c
   27     continue
c
        endif
c
      endif
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
