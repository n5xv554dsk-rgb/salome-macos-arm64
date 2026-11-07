      subroutine vcmnco ( nohman,
     >                    nhnoeu, nharet, nhtria, nhquad, nhvois,
     >                    noempo,
     >                    coonoe, hetnoe, arenoe,
     >                    coexno, nnosho, nnosca,
     >                    somare, hetare, np2are,
     >                    merare, filare, insoar,
     >                    coexar, narsho, narsca,
     >                    hettri, aretri, filtri, pertri,
     >                    hetqua, arequa, filqua, perqua,
     >                    coexqu, nqusho, nqusca,
     >                    quahex, coquhe,
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
c    aVant adaptation - Conversion de Maillage - Non COnformite
c     -                 -             -          -   --
c    ATTENTION : cela suppose que le rapport de non conformite est 1/2
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nohman . e   . char*8 . nom de l'objet maillage homard iteration n .
c . nhnoeu . e   . char8  . nom de l'objet decrivant les noeuds        .
c . nharet . e   . char8  . nom de l'objet decrivant les aretes        .
c . nhtria . e   . char8  . nom de l'objet decrivant les triangles     .
c . nhquad . e   . char8  . nom de l'objet decrivant les quadrangles   .
c . nhvois . e   . char8  . nom de la branche Voisins                  .
c . noempo . es  . nbmpto . numeros des noeuds associes aux mailles    .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hetnoe . es  . nbnoto . historique de l'etat des noeuds            .
c . arenoe . es  . nbnoto . 0 pour un sommet, le numero de l'arete pour.
c .        .     .        . un noeud milieu                            .
c . coexno . es  . nbnoto*. codes de conditions aux limites portants   .
c .        .     . nctfno . sur les noeuds                             .
c . nnosho . es  . rsnoac . numero des noeuds dans HOMARD              .
c . nnosca . es  . rsnoto . numero des noeuds dans le calcul           .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . hetare . es  . nbarto . historique de l'etat des aretes            .
c . np2are . es  . nbarto . noeud milieux des aretes                   .
c . merare . es  . nbarto . mere des aretes                            .
c . filare . es  . nbarto . premiere fille des aretes                  .
c . insoar . es  . nbarto . information sur les sommets des aretes     .
c . coexar . es  . nbarto*. codes de conditions aux limites portants   .
c .        .     . nctfar . sur les aretes                             .
c . narsho . es  . rsarac . numero des aretes dans HOMARD              .
c . narsca . es  . rsarto . numero des aretes du calcul                .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . pertri . e   . nbtrto . pere des triangles                         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . coexqu . es  . nbquto*. codes de conditions aux limites portants   .
c .        .     . nctfqu . sur les quadrangles                        .
c . nqusho . es  . rsquac . numero des quadrangles dans HOMARD         .
c . nqusca . es  . rsquto . numero des quadrangles du calcul           .
c . quahex . es  .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . es  .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'VCMNCO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
#include "gmreel.h"
c
#include "impr02.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "nombte.h"
#include "envca1.h"
#include "dicfen.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      character*8 nohman, nhvois
      character*8 nhnoeu, nharet, nhtria, nhquad
c
      integer noempo(nbmpto)
      integer hetnoe(nbnoto), arenoe(nbnoto)
      integer coexno(nbnoto,nctfno)
      integer nnosho(rsnoac), nnosca(rsnoto)
      integer somare(2,nbarto), hetare(nbarto), np2are(nbarto)
      integer filare(nbarto), merare(nbarto), insoar(nbarto)
      integer coexar(nbarto,nctfar)
      integer narsho(rsarac), narsca(rsarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer filtri(nbtrto), pertri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer filqua(nbquto), perqua(nbquto)
      integer coexqu(nbquto,nctfqu)
      integer nqusho(rsquac), nqusca(rsquto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer un
      parameter ( un = 1 )
      integer iaux
      integer codre1, codre2, codre3, codre4
      integer codre0
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer voarno, vofaar, vovoar, vovofa
      integer nbanci, nbnoct, nbnocq
      integer numead
      integer nbgemx
      integer conoct, conocq
c
      integer adnoer, adarra, adarrb
      integer adtrra, adtrrb
      integer adqura, adqurb
      integer ptrav1, ptrav2, ptrav3, ptrav4, ptrav5
      integer ptrav6, ptrav7, ptrav8
c
      character*8 nharrc, nhtrrc, nhqurc
      character*8 ntrav1, ntrav2, ntrav3, ntrav4, ntrav5
      character*8 ntrav6, ntrav7, ntrav8
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
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
      texte(1,4) =
     > '(''Nombre de paires de '',a,'' non-conformes :'',i10))'
c
      texte(2,4) =
     > '(''Number of pairs of non-conformal '',a,'' :'',i10))'
c
      codret = 0
c
c====
c 2. Les structures
c====
c 2.1. ==> Les structures des voisins
c
      if ( codret.eq.0 ) then
c
      voarno = 2
      vofaar = 2
      vovofa = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nohman, nhvois,
     >              voarno, vofaar, vovoar, vovofa,
     >              ppovos, pvoiso,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. Decompte et reperage des non-conformites
c====
c 3.1. ==> Tableau de travail
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', nbarto, ptrav1, codre0 )
      codret = max ( abs(codre0), codret )
c
      endif
c
c 3.2. ==> Decompte et reperage des aretes en vis-a-vis
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC01', nompro
#endif
c
      call utnc01 ( nbanci, nbgemx,
     >              coonoe,
     >              somare, merare,
     >              aretri,
     >              imem(ppovos), imem(pvoiso),
     >              imem(ptrav1),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbanci
#endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprot (nompro,ntrav1,1,nbarto)
#endif
c
c 3.3. ==> Enregistrement
c
      if ( codret.eq.0 ) then
c
      if ( nbanci.gt.0 ) then
c
        maconf = 10
        call gmecat ( nohman, 4, maconf, codret )
c
      endif
c
      endif
c
c====
c 4. Gestion des tableaux
c====
c
c 4.1. ==> Tableaux de travail
c
      if ( nbanci.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmalot ( ntrav2, 'entier  ', nbnoto, ptrav2, codre1 )
        iaux = max( nbarto+1,nbnoto+1)
        call gmalot ( ntrav4, 'entier  ', iaux, ptrav4, codre2 )
        iaux = max(3*nbanci,nbnoto,2*nbarto,nbarto*nctfar)
        call gmalot ( ntrav5, 'entier  ', iaux, ptrav5, codre3 )
        iaux = nbnoto*sdim
        call gmalot ( ntrav6, 'reel    ', iaux, ptrav6, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        endif
c
c 4.2. ==> Allocation de la memorisation des noeuds de non-conformite
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nhnoeu, 4, nbanci, codre1 )
        call gmaloj ( nhnoeu//'.Recollem', ' ', nbanci, adnoer, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
c 4.3. ==> Memorisation des non-conformites en aretes
c
        if ( codret.eq.0 ) then
c
        iaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCMNC4_ar', nompro
#endif
        call vcmnc4 ( iaux, nharet,
     >                nharrc,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nharrc, 1, nbanci, codre1 )
        iaux = 2
        call gmecat ( nharrc, 2, iaux, codre2 )
        iaux = 2*nbanci
        call gmaloj ( nharrc//'.ListeA', ' ', iaux, adarra, codre3 )
        call gmaloj ( nharrc//'.ListeB', ' ', iaux, adarrb, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        endif
c
c 4.4. ==> Memorisation des non-conformites en triangles
c
        if ( codret.eq.0 ) then
c
        if ( nbtrto.ne.0 ) then
c
          iaux = 2
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCMNC4_tr', nompro
#endif
          call vcmnc4 ( iaux, nhtria,
     >                  nhtrrc,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 4.5. ==> Memorisation des non-conformites en quadrangles
c
        if ( codret.eq.0 ) then
c
        if ( nbquto.ne.0 ) then
c
          iaux = 4
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCMNC4_qu', nompro
#endif
          call vcmnc4 ( iaux, nhquad,
     >                  nhqurc,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
      endif
c
c====
c 5. Renumerotation des aretes
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbanci.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCMNC1', nompro
#endif
        call vcmnc1 ( nbanci, nbgemx,
     >                imem(adarra), imem(adarrb),
     >                nohman, nhvois,
     >                arenoe,
     >                somare, hetare, np2are,
     >                merare, filare, insoar,
     >                coexar, narsho, narsca,
     >                aretri, arequa,
     >                ppovos, pvoiso,
     >                pposif, pfacar,
     >                imem(ptrav1), imem(ptrav4), imem(ptrav5),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, nharrc//'.ListeA' )
        call gmprsx (nompro, nharrc//'.ListeB' )
cgn        call gmprot (nompro,ntrav4,1,nbarto+1)
cgn        call gmprot (nompro,ntrav5,1,3*nbanci)
#endif
c
cgn        return
      endif
c
      endif
c
c====
c 6. Renumerotation des noeuds
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbanci.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCMNC2', nompro
#endif
        call vcmnc2 ( nbanci, nbgemx,
     >                imem(adarra), imem(adarrb), imem(adnoer),
     >                nohman, nhvois,
     >                coonoe, hetnoe, arenoe,
     >                coexno, nnosho, nnosca,
     >                noempo,
     >                somare, hetare, np2are,
     >                merare, filare, insoar,
     >                coexar, narsho, narsca,
     >                aretri, arequa,
     >                ppovos, pvoiso,
     >                pposif, pfacar,
     >                imem(ptrav1), imem(ptrav2),
     >                imem(ptrav4), imem(ptrav5),
     >                rmem(ptrav6),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        call gmprot (nompro,ntrav4,1,nbnoto+1)
#endif
c
      endif
c
      endif
c
c====
c 7. On repere chaque face du macro maillage qui est bordee par une
c    arete de non conformite initiale. On declare que cette face a une
c    mere, dont le numero est un numero fictif, ne correspondant a
c    aucune face possible.
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbanci.gt.0 ) then
c
cgn      do iaux=1,nbquto
cgn      write(ulsort,*) iaux,arequa(iaux,1),arequa(iaux,2),
cgn     >                 arequa(iaux,3),arequa(iaux,4)
cgn      enddo
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTNC09', nompro
#endif
c
        iaux = 0
        call utnc09 ( nbanci, imem(adarrb), iaux,
     >                pertri, perqua,
     >                numead,
     >                imem(pposif), imem(pfacar),
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( nbtrto.gt.0 ) then
c
        call gmecat ( nhtrrc, 3, numead, codre0 )
        codret = max ( abs(codre0), codret )
c
        endif
c
        if ( nbquto.gt.0 ) then
c
        call gmecat ( nhqurc, 3, numead, codre0 )
        codret = max ( abs(codre0), codret )
c
        endif
c
        endif
cgn        return
c
      endif
c
      endif
c
c====
c 8. Gestion des non-conformites sur les volumes
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbanci.gt.0 .and.
     >     ( nbheto.gt.0 .or. nbteto.gt.0 ) ) then
c
c 8.1. ==> Reperage des faces dont des aretes sont non-conformes :
c          . les 4 aretes pour des quadrangles
c          . les 3 aretes pour les triangles
c          Les nombres nbnoct et nbnocq ne sont que des maxima : une
c          face peut tres bien avoir ses aretes coupees sans etre
c          decoupee elle-meme.
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTNC11', nompro
#endif
c
        call utnc11 ( nbanci, imem(adarra),
     >                aretri, filtri,
     >                arequa, filqua,
     >                filare, imem(pposif), imem(pfacar),
     >                nbnoct, nbnocq,
     >                ulsort, langue, codret )
c
        endif
c
c 8.2. ==> Les tableaux
c 8.2.1. ==> Allocation de la memorisation des faces en vis-a-vis
c            On est dans un rapport de 4 pour 1 toujours.
c
        if ( codret.eq.0 ) then
c
        if ( nbquto.ne.0 ) then
c
          call gmecat ( nhqurc, 1, nbnocq, codre1 )
          iaux = 4
          call gmecat ( nhqurc, 2, iaux, codre2 )
          nbquri = 4*nbnocq
          call gmaloj ( nhqurc//'.ListeA', ' ', nbquri, adqura, codre3 )
          call gmaloj ( nhqurc//'.ListeB', ' ', nbquri, adqurb, codre4 )
c
          codre0 = min ( codre1, codre2, codre3, codre4 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3, codre4 )
c
        endif
c
        if ( nbtrto.ne.0 ) then
c
          call gmecat ( nhtrrc, 1, nbnoct, codre1 )
          iaux = 4
          call gmecat ( nhtrrc, 2, iaux, codre2 )
          nbtrri = 4*nbnoct
          call gmaloj ( nhtrrc//'.ListeA', ' ', nbtrri, adtrra, codre3 )
          call gmaloj ( nhtrrc//'.ListeB', ' ', nbtrri, adtrrb, codre4 )
c
          codre0 = min ( codre1, codre2, codre3, codre4 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3, codre4 )
c
        endif
c
        endif
c
c 8.2.2. ==> Tableaux de travail
c
        if ( codret.eq.0 ) then
c
        iaux = nbquto + nbtrto + 1
        call gmalot ( ntrav3, 'entier  ', iaux, ptrav3, codre1 )
        iaux = max( nbtrto+1,nbquto+1)
        call gmalot ( ntrav7, 'entier  ', iaux, ptrav7, codre2 )
        iaux =
     >  max(5*nbnocq,5*nbnoct,4*nbquto,nbquto*nctfqu,rsquac,rsquto,
     >      6*nbheto)
        call gmalot ( ntrav8, 'entier  ', iaux, ptrav8, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
        endif
c
c 8.3. ==> RepÃ©rage des faces en vis-a-vis
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC12', nompro
#endif
c
        call utnc12 ( hettri, aretri, filtri, pertri,
     >                hetqua, arequa, filqua, perqua,
     >                filare, imem(pposif), imem(pfacar),
     >                nbnocq, imem(adqura), imem(adqurb), conocq,
     >                nbnoct, imem(adtrra), imem(adtrrb), conoct,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, nhqurc )
        call gmprot (nompro, nhqurc//'.ListeA', 1, 10 )
        call gmprot (nompro, nhqurc//'.ListeA', 4*conocq, nbquri )
        call gmprot (nompro, nhqurc//'.ListeB', 1, 10 )
        call gmprot (nompro, nhqurc//'.ListeB', 4*conocq, nbquri )
#endif
c
        endif
c
c 8.4 ==> Redimensionnement des tableaux
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'debut de 8.4 avec codret = ', codret
#endif
c
       if ( codret.eq.0 ) then
c
        if ( nbquto.ne.0 ) then
c
          nbquri = 4*nbnocq
          iaux = 4*conocq
c
          call gmmod ( nhqurc//'.ListeA',
     >                 adqura, nbquri, iaux, un, un, codre1 )
          call gmmod ( nhqurc//'.ListeB',
     >                 adqurb, nbquri, iaux, un, un, codre2 )
          nbquri = iaux
          nbnocq = conocq
          call gmecat ( nhqurc, 1, nbnocq, codre3 )
c
          codre0 = min ( codre1, codre2, codre3 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3 )
c
        endif
c
        if ( nbtrto.ne.0 ) then
c
          nbtrri = 4*nbnoct
          iaux = 4*conoct
          call gmmod ( nhtrrc//'.ListeA',
     >                 adtrra, nbtrri, iaux, un, un, codre1 )
          call gmmod ( nhtrrc//'.ListeB',
     >                 adtrrb, nbtrri, iaux, un, un, codre2 )
          nbtrri = iaux
          nbnoct = conoct
          call gmecat ( nhtrrc, 1, nbnoct, codre3 )
c
          codre0 = min ( codre1, codre2, codre3 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3 )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, nhqurc )
        call gmprsx (nompro, nhqurc//'.ListeA' )
        call gmprsx (nompro, nhqurc//'.ListeB' )
#endif
c
        endif
c
c 8.5 ==> RenumÃ©rotation
c
       if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCMNC3', nompro
#endif
        call vcmnc3 ( nbanci,
     >                nbnocq, imem(adqura), imem(adqurb),
     >                nbnoct, imem(adtrra), imem(adtrrb),
     >                nohman, nhvois,
     >                coonoe, hetnoe, arenoe,
     >                coexno, nnosho, nnosca,
     >                noempo,
     >                somare, filare,
     >                hettri, aretri, filtri,
     >                hetqua, arequa, filqua, perqua,
     >                coexqu, nqusho, nqusca,
     >                quahex, coquhe,
     >                ppovos, pvoiso,
     >                pposif, pfacar,
     >                imem(ptrav7), imem(ptrav8), rmem(ptrav6),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      endif
c
c====
c 9. Menage
c====
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'debut de 9 avec codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre0 )
      codret = max ( abs(codre0), codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbanci.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmlboj ( ntrav2, codre1 )
        call gmlboj ( ntrav4, codre2 )
        call gmlboj ( ntrav5, codre3 )
        call gmlboj ( ntrav6, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4  )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        endif
c
        if ( nbheto.gt.0 .or. nbteto.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          call gmlboj ( ntrav7 , codre1 )
          call gmlboj ( ntrav8 , codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
c
          endif
c
        endif
c
      endif
c
      endif
c
c====
c 10. la fin
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
