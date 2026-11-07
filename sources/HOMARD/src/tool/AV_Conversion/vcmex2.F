      subroutine vcmex2 ( maconf,
     >                    nhnofa, famnoe, notfno, nofano, cofano,
     >                    posnoe, inxnoe, pcfano,
     >                    nharfa, famare, notfar, nofaar, cofaar,
     >                    posare, inxare, pcfaar,
     >                    nhtrfa, famtri, notftr, nofatr, cofatr,
     >                    postri, inxtri, pcfatr,
     >                    nhqufa, famqua, notfqu, nofaqu, cofaqu,
     >                    posqua, inxqua, pcfaqu,
     >                    pcfahe,
     >                    nhpefa, pcfape,
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
c    aVant adaptation - Conversion de Maillage EXtrude - phase 2
c     -                 -             -        --              -
c Determine les nouvelles familles pour les mailles du maillage 2D
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . maconf . e   .    1   . conformite du maillage                     .
c .        .     .        .  0 : oui                                   .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2 par face           .
c .        .     .        .  2 : non-conforme avec 1 seul noeud        .
c .        .     .        .      pendant par arete                     .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . 10 : non-conforme sans autre connaissance  .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c .        .     .        . 10 : non-conforme sans autre connaissance  .
c . nhnofa . e   . char8  . objet decrivant les familles des noeuds    .
c . famnoe . es  . nbnoto . famille des noeuds                         .
c . notfno . e   .  1     . nombre d'origine des carac. des f. noeuds  .
c . nofano . e   .  1     . nombre d'origine de familles de noeuds     .
c . cofano . e   . notfno*. codes d'origine des familles des noeuds    .
c .        .     . nofano .   1 : famille MED                          .
c . posnoe . e   . nbnoto . position des noeuds                        .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c . inxnoe . e   .2*nbnoto. informations pour l'extrusion des noeuds   .
c .        .     .        . 1 : famille du noeud extrude               .
c .        .     .        . 2 : famille de l'arete perpendiculaire     .
c . pcfano .  s  .  1     . familles pour l'extrusion des noeuds       .
c . nharfa . e   . char8  . objet decrivant les familles des aretes    .
c . famare . es  . nbarto . famille des aretes                         .
c . notfar . e   .  1     . nombre d'origine des carac. des f. aretes  .
c . nofaar . e   .  1     . nombre d'origine de familles d'aretes      .
c . cofaar . e   . notfar*. codes d'origine des familles des aretes    .
c .        .     . nofaar .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c . posare . e   . nbarto . position des aretes                        .
c .        .     .        . 0 : arete avant                            .
c .        .     .        . 1 : arete arriere                          .
c .        .     .        . 2 : arete perpendiculaire                  .
c . inxare . e   .4*nbarto. informations pour l'extrusion des aretes   .
c .        .     .        . 1 : famille de l'arete extrudee            .
c .        .     .        . 2 : famille du quadrangle perpendiculaire  .
c .        .     .        . 3 : code du quadrangle dans le volume      .
c .        .     .        . 4 : quadrangle perpendiculaire             .
c . pcfaar .  s  .  1     . familles pour l'extrusion des aretes       .
c . nhtrfa . e   . char8  . objet decrivant les familles des triangles .
c . famtri . es  . nbtrto . famille des triangles                      .
c . notftr . e   .  1     . nombre d'origine des carac. des f. tria.   .
c . nofatr . e   .  1     . nombre d'origine de familles de triangles  .
c . cofatr . e   . notftr*. codes d'origine des familles des triangles .
c .        .     . nofatr .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c . postri . e   . nbtrto . position des triangles                     .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c .        .     .        . 2 : face perpendiculaire                   .
c . inxtri . e   .3*nbtrto. informations pour l'extrusion des triangles.
c .        .     .        . 1 : famille du triangle extrude            .
c .        .     .        . 2 : famille du pentaedre                   .
c .        .     .        . 3 : code du triangle dans le pentaedre     .
c . pcfatr .  s  .  1     . familles pour l'extrusion des triangles    .
c . nhqufa . e   . char8  . objet decrivant les familles des quad.     .
c . famqua . es  . nbquto . famille des quadrangles                    .
c . notfqu . e   .  1     . nombre d'origine des carac. des f. quad.   .
c . nofaqu . e   .  1     . nombre d'origine de familles de quad.      .
c . cofaqu . e   . notfqu*. codes d'origine des familles des quad.     .
c .        .     . nofaqu .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c . posqua . e   . nbquto . position des quadrangles                   .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c .        .     .        . 2 : face perpendiculaire                   .
c . inxqua . e   .3*nbquto. informations pour l'extrusion des quads    .
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
c . pcfaqu .  s  .  1     . familles pour l'extrusion des quadrangles  .
c . pcfahe . es  .   1    . codes des familles des hexaedres           .
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
      parameter ( nompro = 'VCMEX2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "nbfami.h"
#include "dicfen.h"
#include "cofexa.h"
#include "cofexn.h"
#include "cofext.h"
#include "cofexq.h"
c
c 0.3. ==> arguments
c
      integer maconf
c
      integer pcfano
      integer pcfaar
      integer pcfatr
      integer pcfaqu
      integer pcfape
c
      integer famnoe(nbnoto), notfno, nofano, cofano(notfno,nofano)
      integer posnoe(nbnoto), inxnoe(2,nbnoto)
      integer famare(nbarto), notfar, nofaar, cofaar(notfar,nofaar)
      integer posare(nbarto), inxare(4,nbarto)
      integer famtri(nbtrto), notftr, nofatr, cofatr(notftr,nofatr)
      integer postri(nbtrto), inxtri(3,nbtrto)
      integer famqua(nbquto), notfqu, nofaqu, cofaqu(notfqu,nofaqu)
      integer posqua(nbquto), inxqua(3,nbquto)
      integer pcfahe
c
      character*8 nhnofa, nharfa, nhtrfa, nhqufa
      character*8 nhpefa
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
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
      codret = 0
c
#ifdef _DEBUG_HOMARD_
49900 format(/,24x,a)
      write(ulsort,49900) ' famille fa noe ex  fa arete'
      do 4991 , iaux = 1 , nbnoto
        if ( posnoe(iaux).eq.0 ) then
        write(ulsort,90012) 'noeud',iaux,famnoe(iaux),
     >                      inxnoe(1,iaux),inxnoe(2,iaux)
        endif
 4991 continue
c
      write(ulsort,49900)
     > ' famille fa are ex   fa quad code q/vo face perp'
      do 4992 , iaux = 1 , nbarto
        if ( posare(iaux).eq.0 ) then
        write(ulsort,90012) 'arete',iaux,famare(iaux),
     >  inxare(1,iaux),inxare(2,iaux),inxare(3,iaux),inxare(4,iaux)
        endif
 4992 continue
c
      if ( nbtrto.ne.0 ) then
      write(ulsort,49900) 'famille fa tri ex   fa pent code t/pe'
      do 4993 , iaux = 1 , nbtrto
        if ( postri(iaux).eq.0 ) then
        write(ulsort,90012) 'tria',iaux,famtri(iaux),
     >               inxtri(1,iaux),inxtri(2,iaux),inxtri(3,iaux)
        endif
 4993 continue
      endif
c
      write(ulsort,49900)
     >'famille  position fa qua ex   fa hexa code q/vo'
      do 4994 , iaux = 1 , nbquto
        write(ulsort,90012) 'quad',iaux,famqua(iaux),posqua(iaux),
     >               inxqua(1,iaux),inxqua(2,iaux),inxqua(3,iaux)
 4994 continue
#endif
c
c====
c 2. Phase 1 : famille des entites sur la face avant
c====
c 2.1. ==> Traitement des noeuds
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.1. noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = -1
      jaux = -1
      kaux = 2
      nctfno = nctfno + ncxfno
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME21-noe', nompro
#endif
      call vcme21 (   iaux, jaux,
     >                kaux, nctfno, nbnoto,
     >              notfno, nofano, cofano,
     >              nhnofa, famnoe, posnoe, inxnoe,
     >              nbfnoe, pcfano,
     >              ulsort, langue, codret )
c
      endif
c
c 2.2. ==> Traitement des aretes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = -1
      kaux = 4
      nctfar = nctfar + ncxfar
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME21-are', nompro
#endif
      call vcme21 (   iaux, jaux,
     >                kaux, nctfar, nbarto,
     >              notfar, nofaar, cofaar,
     >              nharfa, famare, posare, inxare,
     >              nbfare, pcfaar,
     >              ulsort, langue, codret )
c
      endif
c
c 2.3. ==> Traitement des triangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. triangles ; codret', codret
#endif
c
      if ( nbtrto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 2
        jaux = cofxto
        kaux = 3
        nctftr = nctftr + ncxftr
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCME21-tri', nompro
#endif
        call vcme21 (   iaux, jaux,
     >                  kaux, nctftr, nbtrto,
     >                notftr, nofatr, cofatr,
     >                nhtrfa, famtri, postri, inxtri,
     >                nbftri, pcfatr,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 2.4. ==> Traitement des quadrangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 4
      jaux = cofxqo
      kaux = 3
      nctfqu = nctfqu + ncxfqu
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME21-qua', nompro
#endif
      call vcme21 (   iaux, jaux,
     >                kaux, nctfqu, nbquto,
     >              notfqu, nofaqu, cofaqu,
     >              nhqufa, famqua, posqua, inxqua,
     >              nbfqua, pcfaqu,
     >              ulsort, langue, codret )
c
      endif
c
cgn      call gmprsx(nompro//' - apres Phase 1, noeuds', nhnofa//'.Codes' )
cgn      call gmprsx(nompro//' - apres Phase 1, aretes', nharfa//'.Codes' )
cgn      call gmprsx(nompro//' - apres Phase 1, trias', nhtrfa//'.Codes' )
cgn      call gmprsx(nompro//' - apres Phase 1, quads', nhqufa//'.Codes' )
c
c====
c 3. Phase 2 : Traitement des relations hexaedres/pentaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. hexa/pent ; codret', codret
#endif
c
      if ( ( ( maconf.eq.0 ) .or. ( maconf.eq.-1 ) ) .and.
     >      nbheto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME23', nompro
#endif
        call vcme23 ( nhpefa,
     >                pcfaqu,
     >                pcfahe,
     >                pcfape,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
cgn      call gmprsx(nompro//' - apres Phase 2, quads', nhqufa//'.Codes' )
cgn      call gmprsx(nompro//' - apres Phase 2, aretes', nhpefa//'.Codes' )
c
c====
c 4. Phase 3 : relation face avant / face arriere
c====
c 4.1. ==> Traitement des noeuds
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1. noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = -1
      jaux = cofxnt
      kaux = cofxnp
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME25-noe', nompro
#endif
      call vcme25 (   iaux,
     >              nctfno, ncffno,   jaux,   kaux,
     >              notfno, nofano, cofano,
     >              nhnofa,
     >              nbfnoe, pcfano,
     >              ulsort, langue, codret )
c
      endif
c
c 4.2. ==> Traitement des aretes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = cofxat
      kaux = cofxap
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME25-are', nompro
#endif
      call vcme25 (   iaux,
     >              nctfar, ncffar,   jaux,   kaux,
     >              notfar, nofaar, cofaar,
     >              nharfa,
     >              nbfare, pcfaar,
     >              ulsort, langue, codret )
c
      endif
c
c 4.3. ==> Traitement des triangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.3. triangles ; codret', codret
#endif
c
      if ( nbtrto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 2
        jaux = cofxtt
        kaux = cofxtp
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCME25-tri', nompro
#endif
        call vcme25 (   iaux,
     >                nctftr, ncfftr,   jaux,   kaux,
     >                notftr, nofatr, cofatr,
     >                nhtrfa,
     >                nbftri, pcfatr,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 4.4. ==> Traitement des quadrangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.4. quadrangles ; codret', codret
#endif
c
      if ( nbquto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 4
        jaux = cofxqt
        kaux = cofxqp
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCME25-qua', nompro
#endif
        call vcme25 (   iaux,
     >                nctfqu, ncffqu,   jaux,   kaux,
     >                notfqu, nofaqu, cofaqu,
     >                nhqufa,
     >                nbfqua, pcfaqu,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
cgn      call gmprsx(nompro//' - apres Phase 3, noeuds', nhnofa//'.Codes' )
cgn      call gmprsx(nompro//' - apres Phase 3, aretes', nharfa//'.Codes' )
cgn      call gmprsx(nompro//' - apres Phase 3, trias', nhtrfa//'.Codes' )
cgn      call gmprsx(nompro//' - apres Phase 3, quads', nhqufa//'.Codes' )
c
c====
c 5. Phase 4 : Traitement des relations quadrangles/triangles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. quad/tria ; codret', codret
#endif
c
      if ( ( maconf.eq.0 ) .or. ( maconf.eq.-1 ) ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCME27', nompro
#endif
        call vcme27 ( notftr, nofatr, cofatr,
     >                nhtrfa,
     >                pcfatr,
     >                pcfaqu,
     >                pcfahe,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
cgn      call gmprsx(nompro//' - apres Phase 4, trias', nhtrfa//'.Codes' )
cgn      call gmprsx(nompro//' - apres Phase 4, quads', nhqufa//'.Codes' )
c
c====
c 6. Phase 5 : relation face avant / face perpendiculaire
c====
c 6.1. ==> Traitement de l'extrusion des noeuds
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.1. noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME29', nompro
#endif
      call vcme29 ( nofaar, cofaar,
     >              imem(pcfano),
     >              nharfa,
     >              pcfaar,
     >              ulsort, langue, codret )
c
      endif
c
c 6.2. ==> Traitement de l'extrusion des aretes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.2. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME31', nompro
#endif
      call vcme31 ( nofaqu, cofaqu,
     >              nharfa, pcfaar, famare, posare, inxare,
     >              nhqufa, pcfaqu, inxqua,
     >              ulsort, langue, codret )
c
      endif
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
