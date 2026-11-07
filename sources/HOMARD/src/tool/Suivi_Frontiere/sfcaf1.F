      subroutine sfcaf1 ( nomail, nbarfr, nbqufr,
     >                    ncafdg, nocdfr, ncafan, ncafar,
     >                    suifro, ulgrfr,
     >                    lgetco, taetco,
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
c   Suivi de Frontiere : CAlcul des nouvelles Frontieres - 1
c   --                   --                   -            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard iter. n+1   .
c . nbarfr . e   .   1    . nombre d'aretes concernees                 .
c . nbqufr . e   .   1    . nombre de quadrangles concernes            .
c . ncafdg . e   . char*8 . nom de l'objet des frontieres discretes   :.
c .        .     .        . nom des groupes                            .
c . nocdfr . e   . char8  . nom de l'objet description de la frontiere .
c . ncafan . e   . char*8 . nom de l'objet des frontieres analytiques :.
c .        .     .        . description des frontieres                 .
c . ncafar . e   . char*8 . nom de l'objet des frontieres analytiques :.
c .        .     .        . valeurs reelles                            .
c . suifro . e   .   1    . 1 : pas de suivi de frontiere              .
c .        .     .        . 2x : frontiere discrete                    .
c .        .     .        . 3x : frontiere analytique                  .
c .        .     .        . 5x : frontiere cao                         .
c . ulgrfr . e   .   *    . unite logique des groupes frontieres CAO   .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . en entree = celui du module d'avant        .
c .        .     .        . en sortie = celui du module en cours       .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 2x : probleme dans les memoires            .
c .        .     .        . 3x : probleme dans les fichiers            .
c .        .     .        . 5 : mauvaises options                      .
c .        .     .        . 6 : problemes dans les noms d'objet        .
c ______________________________________________________________________
c
c Nombre d'aretes et de quadrangles concernes :
c            ---> SFCONA
c            ---> SFCONQ
c
c Reperage des noeuds P2 sur les lignes frontiere :
c            ---> SFNOFL ---> SFNNFL
c                        ---> SFLISO ---> SFSENO
c                                    ---> SFLISE
c Suivi des frontieres
c            ---> SFCAF2 ---> SFFA01
c                        ---> SFFA02
c                        ---> SFFA03
c                        ---> SFFA05
c                        ---> SFSLIN
c            ---> SFNULI
c Correction des noeuds P2 :
c            ---> SFMOP2
c Controles :
c            ---> SFCOTL ---> SFCOT1 ---> SFCOVO ---> UTCOTE
c                                                ---> UTCOHE
c                                    ---> UTCORN ---> UTSOQU
c                                    ---> SFCOVO ---> UTCOTE
c                                                ---> UTCOHE
c                                    ---> SFCOFA ---> SFTQTR
c                                                ---> SFTQQU
c                                    ---> UTCORN ---> UTSOQU
c                                    ---> SFBATR ---> SFBATT
c                        ---> SFCOT2 ---> UTB3F1
c                                    ---> UTB3G1
c                                    ---> UTB3D1
c                                    ---> UTB3E1
c Correction des noeuds P2 :
c            ---> SFMOP2
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
      parameter ( nompro = 'SFCAF1' )
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
#include "nombqu.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "precis.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
      character*8 ncafdg, nocdfr, ncafan, ncafar
c
      integer suifro
      integer ulgrfr(*)
      integer nbarfr, nbqufr
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer pcoono, adcocs
      integer adhono, pareno
      integer adnuno, adlino, adacno
      integer phetno
      integer psomar, phetar, pfilar, pnp2ar, pfacar, pposif
      integer pcfaar, pfamar
      integer phettr, paretr, pfiltr
      integer phetqu, parequ, pfilqu
      integer pcfaqu, pfamqu
      integer ptrite, pcotrt, parete, phette, pfilte
      integer pquahe, pcoquh, parehe, phethe, pfilhe
      integer pfacpy, pcofay, parepy, phetpy
      integer pfacpe, pcofap, parepe, phetpe
      integer advotr, advoqu
      integer adpptr, adppqu
      integer adabsc, psomse, psegli, pnumli, ptypli, pgeoco
      integer adcafr
      integer pttgrd
      integer nbfrdi, nbfran
      integer adtra4, adtra5
c
      integer codre0
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6
c
      double precision unst2x, epsid2
c
#ifdef _DEBUG_HOMARD_
      character*8 action
      parameter ( action = 'sufr    ' )
#endif
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1, ntrav2, ntrav3, ntrav4, ntrav5
c
#ifdef _DEBUG_HOMARD_
      character*6 nompra
#endif
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
      if ( codret.eq.0 ) then
c
      iaux = 0
      call utveri ( action, nomail, nompro, iaux,
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 2. recuperation des pointeurs
c====
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
c 2.2.==> tableaux du maillage
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 30*19
      if ( homolo.ge.1 ) then
        iaux = iaux*11
      endif
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >                jaux,   jaux,   jaux,
     >              pcoono, pareno, adhono, adcocs,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 1554
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
      call utad02 ( iaux, nharet,
     >              phetar, psomar, pfilar, jaux,
     >              pfamar, pcfaar,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        iaux = 6
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, pfiltr, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 1554
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, pfilqu, jaux,
     >                pfamqu, pcfaqu,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
        iaux = 78
        if ( nbteca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        call utad02 ( iaux, nhtetr,
     >                phette, ptrite, pfilte,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcotrt,   jaux,
     >                  jaux,   jaux, parete,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
        iaux = 78
        if ( nbheca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 ( iaux, nhhexa,
     >                phethe, pquahe, pfilhe,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcoquh,   jaux,
     >                  jaux,   jaux, parehe,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 ) then
c
        iaux = 26
        if ( nbpyca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        call utad02 ( iaux, nhpyra,
     >                phetpy, pfacpy, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcofay,   jaux,
     >                  jaux,   jaux, parepy,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
        iaux = 26
        if ( nbpeca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 ( iaux, nhpent,
     >                phetpe, pfacpe, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcofap,   jaux,
     >                  jaux,   jaux, parepe,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      iaux = 3
      if ( nbteto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*5
      endif
      if ( nbheto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*7
      endif
      if ( nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*221
      endif
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >              advotr, advoqu,
     >                jaux,   jaux, adpptr, adppqu,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
cgn      call gmprsx(nompro,nhvois)
cgn      call gmprsx(nompro,nhvois//'.Vol/Tri')
c
c 2.3. ==> Stockage des entites concernees par la frontiere
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav4, 'entier', nbarfr, adtra4, codre1 )
      if ( nbquto.gt.0 ) then
        call gmalot ( ntrav5, 'entier', nbqufr, adtra5, codre2 )
      else
        codre2 = 0
      endif
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCONA', nompro
#endif
      call sfcona ( iaux, nbarfr, imem(adtra4),
     >              imem(phetar), imem(pcfaar), imem(pfamar),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx(nompro,ntrav4)
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbqufr.gt.0 ) then
c
        iaux = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCONQ', nompro
#endif
        call sfconq ( iaux, nbqufr, imem(adtra5),
     >                imem(phetqu), imem(pcfaqu), imem(pfamqu),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx(nompro,ntrav5)
#endif
c
       endif
c
      endif
c
c 2.4. ==> Tolerance pour les tests de coincidence
c          Attention : sfcaf1 et sfcoin doivent etre coherents
c
      if ( codret.eq.0 ) then
c
      unst2x = 1.d0 / rmem(adcocs+10)**2
      epsid2 = max(1.d-14,epsima)
c
      endif
c
c====
c 3. Les structures des frontieres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Les frontieres ; codret', codret
#endif
c
c 3.1. ==> Discretes
c
      nbfrdi = 0
c
      if ( mod(suifro,2).eq.0 ) then
c
c 3.1.1. ==> Combien de frontieres discretes
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, ncafdg )
#endif
c
        if ( codret.eq.0 ) then
c
        if ( suifro.gt.0 ) then
c
          call gmliat ( ncafdg, 1, nbfrdi, codret )
c
        else
c
          call gmadoj ( ncafdg, pttgrd, nbfrdi, codret )
c
        endif
c
        endif
c
c 3.1.2. ==> Description des frontieres discretes
c
        if ( nbfrdi.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmliat (nocdfr, 2, iaux, codret )
      call gmprot (nompro, nocdfr//'.CoorNoeu', 1 , 20 )
      call gmprot (nompro, nocdfr//'.CoorNoeu', 3*iaux-19 , 3*iaux )
      call gmprsx (nompro, nocdfr//'.NumeLign' )
      call gmprsx (nompro, nocdfr//'.PtrSomLi' )
      call gmprot (nompro, nocdfr//'.SommSegm', 1 , 20 )
      call gmprot (nompro, nocdfr//'.SommSegm', 999 , 1002 )
      call gmprot (nompro, nocdfr//'.SommSegm', 1003 , 1008 )
      call gmprot (nompro, nocdfr//'.SommSegm', 1999 , 2004 )
      call gmprot (nompro, nocdfr//'.AbsCurvi', 1 , 20 )
      call gmprot (nompro, nocdfr//'.AbsCurvi', 999 , 1002 )
      call gmprot (nompro, nocdfr//'.AbsCurvi', 1003 , 1008 )
      call gmprot (nompro, nocdfr//'.AbsCurvi', 1999 , 2004 )
#endif
c
          call gmadoj ( nocdfr//'.CoorNoeu', pgeoco, iaux, codre1 )
          call gmadoj ( nocdfr//'.NumeLign', pnumli, iaux, codre2 )
          call gmadoj ( nocdfr//'.TypeLign', ptypli, iaux, codre3 )
          call gmadoj ( nocdfr//'.PtrSomLi', psegli, iaux, codre4 )
          call gmadoj ( nocdfr//'.SommSegm', psomse, iaux, codre5 )
          call gmadoj ( nocdfr//'.AbsCurvi', adabsc, iaux, codre6 )
c
          codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >                   codre6 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3, codre4, codre5,
     >                   codre6 )
c
          endif
c
        endif
c
      endif
c
c 3.2. ==> Analytiques
c
      nbfran = 0
c
      if ( mod(suifro,3).eq.0 ) then
c
c 3.2.1. ==> Combien de frontieres analytiques
c
        if ( codret.eq.0 ) then
c
        call gmliat ( ncafan, 1, nbfran, codret )
c
        endif
c
c 3.2.2. ==> Description des frontieres analytiques
c
        if ( nbfran.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, ncafar )
#endif
c
        if ( codret.eq.0 ) then
c
          call gmadoj ( ncafar, adcafr, iaux, codret )
c
        endif
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfrdi', nbfrdi
      write (ulsort,90002) 'nbfran', nbfran
#endif
c
c====
c 4. Noeuds initiaux et frontiere
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Noeuds ini / frontiere ; codret', codret
#endif
c
      if ( nbfrdi.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFNOFL', nompro
#endif
        call sfnofl ( ntrav1, ntrav2, ntrav3,
     >                adnuno, adlino, adacno,
     >                unst2x, epsid2,
     >                rmem(pcoono),
     >                imem(psomar), imem(phetar), imem(pfilar),
     >                imem(pnp2ar),
     >                imem(pcfaar), imem(pfamar),
     >                rmem(pgeoco), rmem(adabsc),
     >                imem(psomse), imem(psegli),
     >                lgetco, taetco,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      nompra = 'sfnofl'
      iaux = 2
      call utveri ( action, nomail, nompra, iaux,
     >              ulsort, langue, codret )
c
      endif
#endif
c
      endif
c
c====
c 5. Suivi sur les frontieres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Suivi ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCAF2', nompro
#endif
      call sfcaf2 ( suifro, ulgrfr,
     >              nbfrdi, rmem(pgeoco), rmem(adabsc),
     >              imem(adnuno), imem(adlino), rmem(adacno),
     >              imem(ptypli), imem(psomse), imem(psegli),
     >              nbfran, rmem(adcafr),
     >              unst2x, epsid2,
     >              rmem(pcoono),
     >              imem(adhono),
     >              imem(phetar), imem(psomar), imem(pfilar),
     >              imem(pnp2ar), imem(pcfaar), imem(pfamar),
     >              imem(pfacar), imem(pposif),
     >              imem(phettr), imem(paretr), imem(pfiltr),
     >              imem(advotr),
     >              imem(phetqu), imem(parequ), imem(pfilqu),
     >              imem(pcfaqu), imem(pfamqu),
     >              imem(advoqu),
     >              lgetco, taetco,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      nompra = 'sfcaf2'
      iaux = 2
      call utveri ( action, nomail, nompra, iaux,
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 6. Retablissement des numeros de ligne
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. retablissement nros ; codret', codret
#endif
c
      if ( nbfrdi.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFNULI', nompro
#endif
        call sfnuli ( imem(pcfaar), imem(pnumli), iaux,
     >                lgetco, taetco,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 7. Mouvements de noeud induits
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. Mouvements 1 ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( typsfr.eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFMOP2', nompro
#endif
      call sfmop2 ( rmem(pcoono), imem(phetno), imem(pareno),
     >              imem(psomar),
     >              ulsort, langue, codret)
      endif
c
      endif
c
c====
c 8. Controles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. Controles ; codret', codret
#endif
c
      if ( mod(suifro,5).ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCOTL', nompro
#endif
      call sfcotl ( rmem(pcoono),
     >              imem(psomar), imem(pfilar), imem(pnp2ar),
     >              imem(pcfaar), imem(pfamar),
     >              imem(pfacar), imem(pposif),
     >              imem(phettr), imem(paretr), imem(pfiltr),
     >              imem(phetqu), imem(parequ), imem(pfilqu),
     >              imem(pcfaqu), imem(pfamqu),
     >              imem(ptrite), imem(pcotrt), imem(parete),
     >              imem(phette),
     >              imem(pfilte),
     >              imem(pquahe), imem(pcoquh), imem(parehe),
     >              imem(phethe),
     >              imem(pfilhe),
     >              imem(pfacpy), imem(pcofay), imem(parepy),
     >              imem(phetpy),
     >              imem(pfacpe), imem(pcofap), imem(parepe),
     >              imem(phetpe),
     >              imem(advotr), imem(adpptr),
     >              imem(advoqu), imem(adppqu),
     >              nbarfr, imem(adtra4),
     >              nbqufr, imem(adtra5),
     >              lgetco, taetco,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 10. Corrections P2
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. Mouvements 2 ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( typsfr.eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFMOP2', nompro
#endif
      call sfmop2 ( rmem(pcoono), imem(phetno), imem(pareno),
     >              imem(psomar),
     >              ulsort, langue, codret)
      endif
c
      endif
c
c====
c 11. Mise a jour des coordonnes extremes
c====
c
      if ( mod(suifro,5).ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMMCO', nompro
#endif
      call utmmco ( rmem(adcocs+1), rmem(adcocs+4), rmem(adcocs+7),
     >              nbnoto, sdim, rmem(pcoono),
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 12. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '12. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbfrdi.gt.0 ) then
c
        call gmlboj ( ntrav1, codre1 )
        call gmlboj ( ntrav2, codre2 )
        call gmlboj ( ntrav3, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav4, codre1 )
      if ( nbquto.gt.0 ) then
        call gmlboj ( ntrav5, codre2 )
      else
        codre2 = 0
      endif
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      iaux = 2
      call utveri ( action, nomail, nompro, iaux,
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 13. la fin
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
