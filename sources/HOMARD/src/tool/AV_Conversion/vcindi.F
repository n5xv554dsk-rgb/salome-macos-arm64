      subroutine vcindi ( lgopti, taopti, lgopts, taopts,
     >                    lgetco, taetco,
     >                    ulsort, langue, codret)
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
c    aVant adaptation - Conversion d'INDIcateur
c     -                 -            ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options entieres   .
c . taopti . e   . lgopti . tableau des options entieres               .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'VCINDI' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmreel.h"
#include "gmenti.h"
#include "gmstri.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "refert.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
c
      integer rvnoac, adnohn, adnoin, adnosu
      integer rvarac, adarhn, adarin, adarsu
      integer rvtrac, adtrhn, adtrin, adtrsu
      integer rvquac, adquhn, adquin, adqusu
      integer rvteac, adtehn, adtein, adtesu
      integer rvheac, adhehn, adhein, adhesu
      integer rvpyac, adpyhn, adpyin, adpysu
      integer rvpeac, adpehn, adpein, adpesu
      integer typenh
      integer adinca, adindi, nbtafo, nbenmx, nbpg, tyelho
      integer ncmpin, nucomp(100)
      integer adlipr, nbvapr
      integer nrpass
      integer nbcomp, nbtvch
      integer adnocp, adcaca
      integer nrotv
      integer nbelig
c
      integer codre1, codre2
      integer codre0
      integer nretap, nrsset
      integer iaux, jaux, kaux
      integer nbvent(-1:7)
      integer nbvpen, nbvpyr, nbvhex, nbvtet
      integer nbvqua, nbvtri, nbvare, nbvnoe
      integer adpoin, adtail, adtabl
c
      character*6 saux
      character*8 typobs, nocind, nohind, nomail
      character*8 oblist
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 motaux
      character*8 nocham
      character*8 ntrava
c
      logical nomaut, afaire
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data motaux / 'ValeursR' /
c ______________________________________________________________________
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
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
      texte(1,4) = '(/,a6,'' CONVERSION DE L''''INDICATEUR'')'
      texte(1,5) = '(33(''=''),/)'
      texte(1,6) = '(''Impossible de trouver le nom de la composante'')'
      texte(1,7) = '(''Nombre de composantes dans le champ :'',i4)'
      texte(1,8) = '(''Nombre de tableaux dans le champ    :'',i4)'
      texte(1,9) = '(/,''Examen du tableau numero'',i4)'
      texte(1,10) = '(''. Norme L2 des composantes.'')'
      texte(1,11) = '(''. Norme infinie des composantes.'')'
      texte(1,12) = '(''. Valeur relative de la composante.'')'
      texte(1,13) = '(''. Valeur absolue de la composante.'')'
      texte(1,15) = '(''Cette combinaison est impossible.'')'
      texte(1,17) = '(''Plusieurs champs sont presents pour les '',a)'
      texte(1,18) = '(''Il faut choisir un instant unique.'')'
c
      texte(2,4) = '(/,a6,'' INDICATOR CONVERSION'')'
      texte(2,5) = '(27(''=''),/)'
      texte(2,6) = '(''The name of the component cannot be found.'')'
      texte(2,7) = '(''Number of components in the field:'',i4)'
      texte(2,8) = '(''Number of arrays in the field    :'',i4)'
      texte(2,9) = '(/,''Exam of array #'',i4)'
      texte(2,10) = '(''. L2 norm of components.'')'
      texte(2,11) = '(''. Infinite norm of components.'')'
      texte(2,12) = '(''. Relative value for the component.'')'
      texte(2,13) = '(''. Absolute value for the component.'')'
      texte(2,15) = '(''This situation cannot be solved.'')'
      texte(2,17) = '(''More than one field are defined over the '',a)'
      texte(2,18) = '(''A single time-step should be selected.'')'
c
#include "impr03.h"
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5 ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. les structures de base
c====
c
c 2.1. ==> le maillage homard a l'iteration n
c
      if ( codret.eq.0 ) then
c
      typobs = mchman
      iaux = 0
      call utosno ( typobs, nomail, iaux, ulsort, langue, codret )
c
      endif
c
c 2.2. ==> structure generale
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
cgn      call gmprsx ( nompro, nhtria//'.InfoSupp' )
cgn      call gmprsx ( nompro, norenu//'.PeCalcul' )
cgn      call gmprsx ( nompro, nhquad//'.InfoSupp' )
cgn      call gmprsx ( nompro, norenu//'.HeCalcul' )
c
      endif
c
c 2.3. ==> l'indicateur du code de calcul
c
      nocind = taopts(7)
c
c 2.4. ==> l'indicateur au format homard
c          le nom est donne par l'utilisateur ou il est construit
c          en tant qu'objet temporaire
c
      if ( codret.eq.0 ) then
c
      typobs = mchind
      iaux = 0
      call utosno ( typobs, nohind, iaux, ulsort, langue, codre1 )
c
      if ( codre1.eq.0 ) then
        nomaut = .false.
      elseif ( codre1.eq.2 ) then
        nomaut = .true.
      else
        write (ulsort,texte(langue,6))
      endif
c
      endif
C
c 2.5. ==> les eventuels elements elimines
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhelig, 1, nbelig, codret )
c
      endif
c
c====
c 3. recuperation des pointeurs associes a l'indicateur en entree
c    et aux renumerotations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. recuperation ; codret', codret
#endif
c
c 3.1. ==> renumerotation
c
      if ( codret.eq.0 ) then
c
      iaux = -1
      jaux = 10
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_no', nompro
#endif
      call utre03 ( iaux, jaux, norenu,
     >              rvnoac,   kaux, adnohn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = -10
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_ar', nompro
#endif
      call utre03 ( iaux, jaux, norenu,
     >              rvarac,   kaux, adarhn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      if ( nbtrto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 2
        jaux = -10
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTRE03_tr', nompro
#endif
        call utre03 ( iaux, jaux, norenu,
     >                rvtrac,   kaux, adtrhn,   kaux,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
      if ( nbteto.gt.0 ) then
c
      if ( codret.eq.0 ) then
c
        iaux = 3
        jaux = -10
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTRE03_te', nompro
#endif
        call utre03 ( iaux, jaux, norenu,
     >                rvteac,   kaux, adtehn,   kaux,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
      if ( nbquto.gt.0 ) then
c
      if ( codret.eq.0 ) then
c
        iaux = 4
        jaux = -10
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_qu', nompro
#endif
        call utre03 ( iaux, jaux, norenu,
     >                rvquac,   kaux, adquhn,   kaux,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
      if ( nbpyto.gt.0 ) then
c
      if ( codret.eq.0 ) then
c
        iaux = 5
        jaux = -10
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_py', nompro
#endif
        call utre03 ( iaux, jaux, norenu,
     >                rvpyac,   kaux, adpyhn,   kaux,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
      if ( nbheto.gt.0 ) then
c
      if ( codret.eq.0 ) then
c
        iaux = 6
        jaux = -10
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_he', nompro
#endif
        call utre03 ( iaux, jaux, norenu,
     >                rvheac,   kaux, adhehn,   kaux,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
      if ( nbpeto.gt.0 ) then
c
      if ( codret.eq.0 ) then
c
        iaux = 7
        jaux = -10
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_pe', nompro
#endif
        call utre03 ( iaux, jaux, norenu,
     >                rvpeac,   kaux, adpehn,   kaux,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'rvnoac', rvnoac
      write (ulsort,90002) 'rvarac', rvarac
      write (ulsort,90002) 'rvtrac', rvtrac
      write (ulsort,90002) 'rvquac', rvquac
      write (ulsort,90002) 'rvteac', rvteac
      write (ulsort,90002) 'rvheac', rvheac
      write (ulsort,90002) 'rvpeac', rvpeac
      write (ulsort,90002) 'rvpyac', rvpyac
#endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, norenu )
      call gmprot (nompro, norenu//'.NoHOMARD', 1, 30 )
      call gmprot (nompro, norenu//'.ArHOMARD', 1, min(100,rvarac) )
      if ( rvtrac.ne.0 ) then
        call gmprot (nompro, norenu//'.TrHOMARD', 1, min(100,rvtrac) )
      endif
      if ( rvquac.ne.0 ) then
        call gmprot (nompro, norenu//'.QuHOMARD', 1, min(100,rvquac) )
      endif
      if ( rvteac.ne.0 ) then
        call gmprot (nompro, norenu//'.TeHOMARD', 1, min(100,rvteac) )
      endif
      if ( rvpyac.ne.0 ) then
        call gmprot (nompro, norenu//'.PYHOMARD', 1, min(100,rvpyac) )
      endif
      if ( rvheac.ne.0 ) then
        call gmprot (nompro, norenu//'.HeHOMARD', 1, min(100,rvheac) )
      endif
      if ( rvpeac.ne.0 ) then
        call gmprot (nompro, norenu//'.PeHOMARD', 1, min(100,rvpeac) )
      endif
      call gmprsx (nompro, norenu//'.HeHOMARD' )
      call gmprsx (nompro, norenu//'.PeHOMARD' )
      call gmprsx (nompro, norenu//'.InfoSupE' )
      call gmprsx (nompro, norenu//'.InfoSupE.Tab1' )
      call gmprsx (nompro, norenu//'.InfoSupE.Tab3' )
      call gmprsx (nompro, norenu//'.InfoSupE.Tab9' )
#endif
c
c 3.2. ==> les caracteristiques de l'indicateur
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. caract. indic ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nocind )
      call gmprsx (nompro, nocind//'.InfoCham' )
      call gmprsx (nompro, nocind//'.InfoPaFo' )
      call gmprsx (nompro, nocind//'.InfoProf' )
      call gmprsx (nompro, nocind//'.InfoLoPG' )
      call gmprsx (nompro, '%%%%%%11' )
      call gmprsx (nompro, '%%%%%%11.Nom_Comp' )
      call gmprsx (nompro, '%%%%%%11.Cham_Ent' )
      call gmprsx (nompro, '%%%%%%11.Cham_Ree' )
      call gmprsx (nompro, '%%%%%%11.Cham_Car' )
      call gmprsx (nompro, '%%%%%%13' )
      call gmprsx (nompro, '%%%%%%13.ValeursR' )
      call gmprsx (nompro, '%%%%%%14' )
      call gmprsx (nompro, '%%%%%%14.ValeursR' )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCIND0', nompro
#endif
c
      call vcind0 ( nocind,
     >              nocham, nbcomp, nbtvch, adnocp, adcaca,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nbcomp
      write (ulsort,texte(langue,8)) nbtvch
#endif
c
      endif
c
c 3.3. ==> allocation de l'objet
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. allocation ; codret', codret
      write (ulsort,*) 'nomaut =', nomaut
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nomaut ) then
        call gmalot ( nohind, 'HOM_Indi', 0, iaux, codret )
      else
        call gmaloj ( nohind, 'HOM_Indi', 0, iaux, codret )
      endif
c
      endif
c
      if ( codret.eq.0 ) then
        taopts(8) = nohind
      endif
c
c 3.4. ==> noms des composantes retenues, si le champ contient
c          plus d'une composante
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. nom des composantes ; codret', codret
#endif
c
      if ( nbcomp.gt.1 ) then
c
        if ( codret.eq.0 ) then
c
        typobs = mcccin
        iaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTMCLS', nompro
#endif
        call utmcls ( typobs, iaux, oblist, jaux,
     >                ulsort, langue, codre0 )
c
        endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx (nompro, oblist )
      call gmprsx (nompro, oblist//'.Pointeur' )
      call gmprsx (nompro, oblist//'.Taille' )
      call gmprsx (nompro, oblist//'.Table' )
      endif
#endif
c
        if ( codret.eq.0 ) then
c
        iaux = 6
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
        call utadpt ( oblist, iaux,
     >                ncmpin, jaux,
     >                adpoin, adtail, adtabl,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 3.5. ==> Controle des composantes dans le champ
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.5. Controle ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCIND1', nompro
#endif
      call vcind1 ( nbcomp, smem(adnocp+8),
     >              ncmpin, imem(adpoin), imem(adtail), smem(adtabl),
     >              nucomp,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( ncmpin.gt.1 ) then
        write (ulsort,texte(langue,10+taopti(8)))
        if ( taopti(8).eq.2 ) then
          write (ulsort,texte(langue,7)) ncmpin
          write (ulsort,texte(langue,10+taopti(8)))
          write (ulsort,texte(langue,15))
          codret = 35
        endif
      else
        if ( taopti(8).eq.2 ) then
          write (ulsort,texte(langue,12))
        else
          write (ulsort,texte(langue,13))
        endif
      endif
c
      endif
c
c====
c 4. conversion
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. conversion ; codret', codret
#endif
c 4.0. ==> Au depart, on fait comme si aucune indicateur n'etait present
c          a priori, on met des adresses valant 1 pour que quand il n'y
c          a pas de tableaux on garde la coherence de passage
c          d'arguments avec imem

      nbvnoe = 0
      nbvare = 0
      nbvtri = 0
      nbvqua = 0
      nbvtet = 0
      nbvpyr = 0
      nbvhex = 0
      nbvpen = 0
c
      adnosu = 1
      adnoin = 1
      adarsu = 1
      adarin = 1
      adtrsu = 1
      adtrin = 1
      adqusu = 1
      adquin = 1
      adtesu = 1
      adtein = 1
      adpysu = 1
      adpyin = 1
      adhesu = 1
      adhein = 1
      adpesu = 1
      adpein = 1
c
      do 40 , nrotv = 1 , nbtvch
c
        afaire = .false.
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,9)) nrotv
#endif
c
c 4.1 ==> adresse de l'indicateur du code de calcul
c         type de l'element au sens HOMARD
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCIND2', nompro
#endif
        nrpass = nrotv
        call vcind2 ( nrpass,
     >                smem(adcaca),
     >                adinca, nbtafo, nbenmx, nbpg, tyelho,
     >                adlipr, nbvapr,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'tyelho', tyelho
#endif
c
c 4.2. ==> allocation de l'objet
c          remarque : on ne traite que les reels
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. Allocation ; codret', codret
#endif
c
c 4.2.0. ==> prealable
c
        if ( codret.eq.0 ) then
c
        do 420 , iaux = -1 , 7
          nbvent(iaux) = 0
  420   continue
c
        endif
c
c 4.2.1. ==> noeuds
c
        if ( codret.eq.0 ) then
        if ( rvnoac.ne.0 .and.
     >       tyelho.eq.tyhnoe ) then
c
          typenh = -1
          if ( nbvnoe.ne.0 ) then
            codret = 1000 + typenh
          else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_no', nompro
#endif
            call utalih ( nohind, typenh, nbnoto, ncmpin, motaux,
     >                    adnoin, adnosu,
     >                    ulsort, langue, codret)
            nbvent(typenh) = rvnoac
            afaire = .true.
c
          endif
c
        endif
        endif
c
c 4.2.2. ==> aretes
c
        if ( codret.eq.0 ) then
        if ( rvarac.ne.0 .and.
     >       ( tyelho.eq.tyhse1 .or. tyelho.eq.tyhse2 ) ) then
c
          typenh = 1
          if ( nbvare.ne.0 ) then
            codret = 1000 + typenh
          else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_ar', nompro
#endif
            call utalih ( nohind, typenh, nbarto, ncmpin, motaux,
     >                    adarin, adarsu,
     >                    ulsort, langue, codret)
            nbvent(typenh) = rvarac
            afaire = .true.
c
        endif
c
        endif
        endif
c
c 4.2.3. ==> triangles
c
        if ( codret.eq.0 ) then
        if ( rvtrac.ne.0 .and.
     >       ( tyelho.eq.tyhtr1 .or. tyelho.eq.tyhtr2 .or.
     >         tyelho.eq.tyhtr3 ) ) then
c
          typenh = 2
          if ( nbvtri.ne.0 ) then
            codret = 1000 + typenh
          else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_tr', nompro
#endif
            call utalih ( nohind, typenh, nbtrto, ncmpin, motaux,
     >                    adtrin, adtrsu,
     >                    ulsort, langue, codret)
            nbvent(typenh) = rvtrac
            afaire = .true.
c
          endif
c
        endif
        endif
c
c 4.2.4. ==> quadrangles
c
        if ( codret.eq.0 ) then
        if ( rvquac.ne.0 .and.
     >       ( tyelho.eq.tyhqu1 .or. tyelho.eq.tyhqu2 .or.
     >         tyelho.eq.tyhqu3 ) ) then
c
          typenh = 4
          if ( nbvqua.ne.0 ) then
            codret = 1000 + typenh
          else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_qu', nompro
#endif
            call utalih ( nohind, typenh, nbquto, ncmpin, motaux,
     >                    adquin, adqusu,
     >                    ulsort, langue, codret)
            nbvent(typenh) = rvquac
            afaire = .true.
c
          endif
c
        endif
        endif
c
c 4.2.5. ==> tetraedres
c
        if ( codret.eq.0 ) then
        if ( rvteac.ne.0 .and.
     >       ( tyelho.eq.tyhte1 .or. tyelho.eq.tyhte2 ) ) then
c
          typenh = 3
          if ( nbvtet.ne.0 ) then
            codret = 1000 + typenh
          else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_te', nompro
#endif
            call utalih ( nohind, typenh, nbteto, ncmpin, motaux,
     >                    adtein, adtesu,
     >                    ulsort, langue, codret)
            nbvent(typenh) = rvteac
            afaire = .true.
c
          endif
c
        endif
        endif
c
c 4.2.6. ==> pyramides
c
        if ( codret.eq.0 ) then
        if ( rvpyac.ne.0 .and. nbelig.eq.0 .and.
     >       ( tyelho.eq.tyhpy1 .or. tyelho.eq.tyhpy2 ) ) then
c
          typenh = 5
          if ( nbvpyr.ne.0 ) then
            codret = 1000 + typenh
          else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_py', nompro
#endif
            call utalih ( nohind, typenh, nbpyto, ncmpin, motaux,
     >                    adpyin, adpysu,
     >                    ulsort, langue, codret)
c
            nbvent(typenh) = rvpyac
            afaire = .true.
c
          endif
c
        endif
        endif
c
c 4.2.7. ==> hexaedres
c
        if ( codret.eq.0 ) then
        if ( rvheac.ne.0 .and.
     >       ( tyelho.eq.tyhhe1 .or. tyelho.eq.tyhhe2 .or.
     >         tyelho.eq.tyhhe3 ) ) then
c
          typenh = 6
          if ( nbvhex.ne.0 ) then
            codret = 1000 + typenh
          else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_he', nompro
#endif
            call utalih ( nohind, typenh, nbheto, ncmpin, motaux,
     >                    adhein, adhesu,
     >                    ulsort, langue, codret)
c
            nbvent(typenh) = rvheac
            afaire = .true.
c
          endif
c
        endif
        endif
c
c 4.2.8. ==> pentaedres
c
        if ( codret.eq.0 ) then
        if ( rvpeac.ne.0 .and.
     >       ( tyelho.eq.tyhpe1 .or. tyelho.eq.tyhpe2 ) ) then
c
          typenh = 7
          if ( nbvpen.ne.0 ) then
            codret = 1000 + typenh
          else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_pe', nompro
#endif
            call utalih ( nohind, typenh, nbpeto, ncmpin, motaux,
     >                    adpein, adpesu,
     >                    ulsort, langue, codret)
c
            nbvent(typenh) = rvpeac
            afaire = .true.
c
          endif
c
        endif
        endif
c
c 4.3. ==> Si l'indicateur est exprime par points de Gauss, on le
c          rapporte par maille
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.3. points de Gauss ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        if ( nbpg.gt.1 ) then
c
          if ( afaire ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCIND3', nompro
#endif
            call vcind3 ( nbtafo, nbenmx, rmem(adinca), nbpg,
     >                    ncmpin, nucomp,
     >                    adindi, ntrava,
     >                    ulsort, langue, codret)
c
          endif
c
        else
c
          adindi = adinca
c
        endif
c
        endif
c
c 4.4. ==> conversion de l'indicateur en fonction de son type
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.4. en fct du type ; codret', codret
      write (ulsort,99001) 'afaire', afaire
#endif
c
        if ( codret.eq.0 ) then
c
        if ( afaire ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCINRR', nompro
#endif
          call vcinrr ( nbvent,
     >                  imem(adnosu), rmem(adnoin),
     >                  imem(adarsu), rmem(adarin),
     >                  imem(adtrsu), rmem(adtrin),
     >                  imem(adqusu), rmem(adquin),
     >                  imem(adtesu), rmem(adtein),
     >                  imem(adhesu), rmem(adhein),
     >                  imem(adpysu), rmem(adpyin),
     >                  imem(adpesu), rmem(adpein),
     >                  nbvapr, imem(adlipr),
     >                  nbtafo, nbenmx, rmem(adindi),
     >                  ncmpin, nucomp,
     >                  imem(adnohn),
     >                  imem(adarhn),
     >                  imem(adtrhn),
     >                  imem(adquhn),
     >                  imem(adtehn),
     >                  imem(adhehn),
     >                  imem(adpyhn),
     >                  imem(adpehn),
     >                  ulsort, langue, codret)
c
        endif
c
        endif
c
c 4.5. ==> menage eventuel
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.5. Menage ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        if ( nbpg.gt.1 .and. afaire ) then
c
        call gmlboj ( ntrava , codret )
c
        endif
c
        endif
c
        nbvnoe = nbvnoe + nbvent(-1)
        nbvare = nbvare + nbvent(1)
        nbvtri = nbvtri + nbvent(2)
        nbvqua = nbvqua + nbvent(4)
        nbvtet = nbvtet + nbvent(3)
        nbvpyr = nbvpyr + nbvent(5)
        nbvhex = nbvhex + nbvent(6)
        nbvpen = nbvpen + nbvent(7)
c
   40 continue
c
c====
c 5. menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmsgoj ( nocind, codre1 )
      if ( nbcomp.gt.1 ) then
        call gmsgoj ( oblist, codre2 )
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
      call gmprsx(nompro, nohind)
c
      call gmprsx(nompro, nohind//'.Noeud')
      call gmprot (nompro, nohind//'.Noeud.Support' , 1, 10 )
      call gmprot (nompro, nohind//'.Noeud.'//motaux , 1, 10 )
      if ( nbnoto.gt.10 ) then
        call gmprot (nompro, nohind//'.Noeud.Support',nbnoto-9,nbnoto)
        call gmprot (nompro, nohind//'.Noeud.'//motaux,nbnoto-9,nbnoto)
      endif
c
      call gmprot (nompro, nohind//'.Arete.'//motaux , 1, 10 )
      if ( nbarto.gt.10 ) then
        call gmprot (nompro, nohind//'.Arete.'//motaux,nbarto-9,nbarto)
      endif
c
      if ( nbtrto.gt.0 ) then
        call gmprot (nompro, nohind//'.Trian.'//motaux , 1, 10 )
        if ( nbtrto.gt.10 ) then
         call gmprot (nompro, nohind//'.Trian.'//motaux,nbtrto-9,nbtrto)
        endif
      endif
c
      if ( nbquto.gt.0 ) then
        if ( nbquto.gt.50 ) then
        call gmprot (nompro, nohind//'.Quadr.'//motaux , 1, 50 )
        call gmprot (nompro, nohind//'.Quadr.'//motaux,nbquto-49,nbquto)
        else
          call gmprsx (nompro, nohind//'.Quadr.Support' )
          call gmprsx (nompro, nohind//'.Quadr.'//motaux )
        endif
      endif
c
      if ( nbteto.gt.0 ) then
        call gmprot (nompro, nohind//'.Tetra.'//motaux , 1, 10 )
        if ( nbteto.gt.10 ) then
        call gmprot (nompro, nohind//'.Tetra.'//motaux,nbteto-9,nbteto)
        endif
      endif
c
      if ( nbelig.eq.0 .and. nbpyto.gt.0 ) then
        call gmprot (nompro, nohind//'.Pyram.'//motaux , 1, 10 )
        if ( nbpyto.gt.10 ) then
        call gmprot (nompro, nohind//'.Pyram.'//motaux,nbpyto-9,nbpyto)
        endif
      endif
c
      if ( nbheto.gt.0 ) then
        call gmprot (nompro, nohind//'.Hexae.'//motaux , 1, 10 )
        if ( nbheto.gt.10 ) then
        call gmprot (nompro, nohind//'.Hexae.'//motaux,nbheto-9,nbheto)
        endif
      endif
c
      if ( nbpeto.gt.0 ) then
        call gmprot (nompro, nohind//'.Penta.'//motaux , 1, 10 )
        if ( nbpeto.gt.10 ) then
        call gmprot (nompro, nohind//'.Penta.'//motaux,nbpeto-9,nbpeto)
        endif
      endif
c
      endif
#endif
c
c====
c 6. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      if ( codret.ge.999 ) then
        typenh = codret - 1000
        write (ulsort,texte(langue,17)) mess14(langue,3,typenh)
        write (ulsort,texte(langue,18))
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
c=======================================================================
      endif
c=======================================================================
c
      end
