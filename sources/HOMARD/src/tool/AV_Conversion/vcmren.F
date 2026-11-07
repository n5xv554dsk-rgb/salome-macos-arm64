      subroutine vcmren ( nnosho, nnosca, nnosic,
     >                    nmpsho, nmpsca, nmpsic,
     >                    narsho, narsca, narsic,
     >                    ntrsho, ntrsca, ntrsic,
     >                    nqusho, nqusca, nqusic,
     >                    ntesho, ntesca, ntesic,
     >                    npysho, npysca, npysic,
     >                    nhesho, nhesca, nhesic,
     >                    npesho, npesca, npesic,
     >                    nunoex, nuelex, decanu,
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
c    aVant adaptation - Conversion de Maillage - RENumerotation
c     -                 -             -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nnosho . es  . rsnoac . numero des noeuds dans HOMARD              .
c . nnosca . es  . rsnoto . numero des noeuds du code de calcul        .
c . nnosic . es  . rsnoto . numero des noeuds du code de calcul (init) .
c . nmpsho . es  . rsmpac . numero des mailles-points dans HOMARD      .
c . nmpsca . es  . rsmpto . numero des mailles-points du calcul        .
c . nmpsic . es  . rsmpto . numero des mailles-points du calcul (init) .
c . narsho . es  . rsarac . numero des aretes dans HOMARD              .
c . narsca . es  . rsarto . numero des aretes du calcul                .
c . narsic . es  . rsarto . numero des aretes du calcul (initial)      .
c . ntrsho . es  . rstrac . numero des triangles dans HOMARD           .
c . ntrsca . es  . rstrto . numero des triangles du calcul             .
c . ntrsic . es  . rstrto . numero des triangles du calcul (initial)   .
c . nqusho . es  . rsquac . numero des quadrangles dans HOMARD         .
c . nqusca . es  . rsquto . numero des quadrangles du calcul           .
c . nqusic . es  . rsquto . numero des quadrangles du calcul (initial) .
c . ntesho . es  . rsteac . numero des tetraedres dans HOMARD          .
c . ntesca . es  . rsteto . numero des tetraedres du calcul            .
c . ntesca . es  . rsteto . numero des tetraedres du calcul (initial)  .
c . npysho . es  . rspyac . numero des pyramides dans HOMARD           .
c . npysca . es  . rspyto . numero des pyramides du calcul             .
c . npysic . es  . rspyto . numero des pyramides du calcul (initial)   .
c . nhesho . es  . rsheac . numero des hexaedres dans HOMARD           .
c . nhesca . es  . rsheto . numero des hexaedres du calcul             .
c . nhesic . es  . rsheto . numero des hexaedres du calcul (initial)   .
c . npesho . es  . rspeac . numero des pentaedres dans HOMARD          .
c . npesca . es  . rspeto . numero des pentaedres du calcul            .
c . npesic . es  . rspeto . numero des pentaedres du calcul (initial)  .
c . nunoex . e   . nbnoto . numerotation des noeuds en exterieur       .
c . nuelex . e   . nbelem . numerotation des elements en exterieur     .
c . decanu . e   .  -1:7  . decalage des numerotations selon le type   .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 3 : anglais                  .
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
      parameter ( nompro = 'VCMREN' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombmp.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombsr.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer nnosho(rsnoac), nnosca(rsnoto), nnosic(rsnoto)
      integer nmpsho(rsmpac), nmpsca(rsmpto), nmpsic(rsmpto)
      integer narsho(rsarac), narsca(rsarto), narsic(rsarto)
      integer ntrsho(rstrac), ntrsca(rstrto), ntrsic(rstrto)
      integer nqusho(rsquac), nqusca(rsquto), nqusic(rsquto)
      integer ntesho(rsteac), ntesca(rsteto), ntesic(rsteto)
      integer npysho(rspyac), npysca(rspyto), npysic(rspyto)
      integer nhesho(rsheac), nhesca(rsheto), nhesic(rsheto)
      integer npesho(rspeac), npesca(rspeto), npesic(rspeto)
c
      integer nunoex(nbnoto), nuelex(nbelem)
      integer decanu(-1:7)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 2. renumerotation des noeuds
c====
c
      iaux = decanu(-1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMRE0_NO', nompro
#endif
      call vcmre0 ( nbnoto, rsnoac, rsnoto, nbnoto,
     >              nnosho, nnosca, nnosic,
     >              nunoex, iaux,
     >              ulsort, langue, codret )
c
c====
c 3. renumerotation des mailles-points le cas echeant
c====
c
      if ( codret.eq.0 ) then
c
      if ( rsmpac.ne.0 ) then
c
        iaux = decanu(0)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMRE0_MP', nompro
#endif
        call vcmre0 ( nbelem, rsmpac, rsmpto, nbmpto,
     >                nmpsho, nmpsca, nmpsic,
     >                nuelex, iaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 4. renumerotation des aretes le cas echeant
c====
c
      if ( codret.eq.0 ) then
c
      if ( rsarac.ne.0 ) then
c
        iaux = decanu(1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMRE0_AR', nompro
#endif
        call vcmre0 ( nbelem, rsarac, rsarto, nbarto,
     >                narsho, narsca, narsic,
     >                nuelex, iaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. renumerotation des triangles le cas echeant
c====
c
      if ( codret.eq.0 ) then
c
      if ( rstrac.ne.0 ) then
c
        iaux = decanu(2)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMRE0_TR', nompro
#endif
        call vcmre0 ( nbelem, rstrac, rstrto, nbtrto,
     >                ntrsho, ntrsca, ntrsic,
     >                nuelex, iaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 6. renumerotation des quadrangles le cas echeant
c====
c
      if ( codret.eq.0 ) then
c
      if ( rsquac.ne.0 ) then
c
        iaux = decanu(4)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMRE0_QU', nompro
#endif
        call vcmre0 ( nbelem, rsquac, rsquto, nbquto,
     >                nqusho, nqusca, nqusic,
     >                nuelex, iaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 7. renumerotation des tetraedres le cas echeant
c====
c
      if ( codret.eq.0 ) then
c
      if ( rsteac.ne.0 ) then
c
        iaux = decanu(3)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMRE0_TE', nompro
#endif
        call vcmre0 ( nbelem, rsteac, rsteto, nbteto,
     >                ntesho, ntesca, ntesic,
     >                nuelex, iaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 8. renumerotation des pyramides le cas echeant
c====
c
      if ( codret.eq.0 ) then
c
      if ( rspyac.ne.0 ) then
c
        iaux = decanu(5)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMRE0_PY', nompro
#endif
        call vcmre0 ( nbelem, rspyac, rspyto, nbpyto,
     >                npysho, npysca, npysic,
     >                nuelex, iaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 9. renumerotation des hexaedres le cas echeant
c====
c
      if ( codret.eq.0 ) then
c
      if ( rsheac.ne.0 ) then
c
        iaux = decanu(6)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMRE0_HE', nompro
#endif
        call vcmre0 ( nbelem, rsheac, rsheto, nbheto,
     >                nhesho, nhesca, nhesic,
     >                nuelex, iaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 10. renumerotation des pentaedres le cas echeant
c====
c
      if ( codret.eq.0 ) then
c
      if ( rspeac.ne.0 ) then
c
        iaux = decanu(7)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMRE0_PE', nompro
#endif
        call vcmre0 ( nbelem, rspeac, rspeto, nbpeto,
     >                npesho, npesca, npesic,
     >                nuelex, iaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 11. la fin
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
