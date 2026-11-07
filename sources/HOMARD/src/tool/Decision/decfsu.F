      subroutine decfsu ( nomail, nohind,
     >                    lgopti, taopti,
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
c traitement des DEcisions - mise en ConFormite - SUppression
c                --                  -  -         --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . nohind . e   .  ch8   . nom de l'objet contenant l'indicateur      .
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
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
      parameter ( nompro = 'DECFSU' )
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
#include "nancnb.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombno.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      character*8 nomail, nohind
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nrosec
      integer nretap, nrsset
      integer iaux, jaux, kaux
c
      integer nbtran, nbquan
      integer nbtean
      integer nbhean
      integer nbpyan
      integer nbpean
c
      integer pcoono, phetno, pareno
      integer adhono
      integer pposif, pfacar
      integer phetar, psomar, pfilar, pmerar, pancar, pnp2ar
      integer adhoar
      integer phettr, paretr, pfiltr, ppertr, panctr, pnivtr
      integer adpetr, adnmtr
      integer adhotr
      integer phetqu, parequ, pfilqu, pperqu, pancqu, pnivqu
      integer adhequ, adnmqu
      integer adhoqu
      integer phette, ptrite, pcotrt, parete, pfilte, pperte, pancte
      integer phethe, pquahe, pcoquh, parehe, pfilhe, pperhe, panche
      integer adnmhe
      integer adhes2
      integer phetpy, pfacpy, pcofay, parepy, pfilpy, pperpy, pancpy
      integer phetpe, pfacpe, pcofap, parepe, pfilpe, pperpe, pancpe
      integer adpes2
      integer pfamno, pcfano
      integer pfamar
      integer pfamtr
      integer pfamqu
      integer pfamte
      integer pfampy
      integer pfamhe
      integer pfampe
      integer voarno, vofaar, vovoar, vovofa
      integer adnoin, adnorn, adnosu
      integer adarin, adarrn, adarsu
      integer adtrin, adtrrn, adtrsu
      integer adquin, adqurn, adqusu
      integer adtein, adtern, adtesu
      integer adhein, adhern, adhesu
      integer adpyin, adpyrn, adpysu
      integer adpein, adpern, adpesu
      integer nbvnoe, nbvare
      integer nbvtri, nbvqua
      integer nbvtet, nbvhex, nbvpyr, nbvpen
      integer typind, ncmpin
      integer pdisno, pancno, pnouno
c
      logical afaire
c
      integer codre0
      integer codre1, codre2, codre3
c
      character*6 saux
      character*8 saux08
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ndisno, nnouno
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
#include "impr02.h"
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
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.1. ==> le debut des mesures de temps
c
      nrosec = taetco(4)
      call gtdems (nrosec)
c
c 1.3. ==> les messages
c
      texte(1,4) = '(/,a6,'' SUPPRESSION DE LA CONFORMITE'')'
      texte(1,5) = '(35(''=''),/)'
      texte(1,6) = '(''Modification de taille des tableaux des '',a)'
      texte(1,7) = '(''et renumerotation.'')'
      texte(1,8) = '(5x,''==> code de retour :'',i8)'
c
      texte(2,4) = '(/,a6,'' SUPPRESSION OF CONFORMITY'')'
      texte(2,5) = '(32(''=''),/)'
      texte(2,6) = '(''Size modification of arrays for '',a)'
      texte(2,7) = '(''and renumbering.'')'
      texte(2,8) = '(5x,''==> error code :'',i8)'
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. recuperation des pointeurs, initialisations
c====
c
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
c 2.2. ==> tableaux
c
      if ( codret.eq.0 ) then
c
      iaux = 210
      if ( homolo.ge.1 ) then
        iaux = iaux*11
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono, pareno, adhono,  jaux,
     >              ulsort, langue, codret )
c
      iaux = 2
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 (   iaux, nharet,
     >              phetar, psomar, jaux  , jaux  ,
     >                jaux,   jaux,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
        iaux = 30*11
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 (   iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                  jaux,   jaux,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
        iaux = 30*11
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 (   iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                  jaux,   jaux,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
        iaux = 78
        if ( nancta.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        call utad02 (   iaux, nhtetr,
     >                phette, ptrite, pfilte, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcotrt,   jaux,
     >                  jaux,   jaux, parete,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
        iaux = 6
        if ( nbheco.ne.0 ) then
           iaux = iaux*17
        endif
        if ( nancha.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 (   iaux, nhhexa,
     >                phethe, pquahe, pfilhe, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux, adhes2,
     >                  jaux,   jaux, parehe,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
        iaux = 6
        if ( nbpeco.ne.0 ) then
           iaux = iaux*17
        endif
        if ( nancpa.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 (   iaux, nhpent,
     >                phetpe, pfacpe, pfilpe, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux, adpes2,
     >                  jaux,   jaux, parepe,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 ) then
c
        iaux = 6
        if ( nancya.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        call utad02 (   iaux, nhpyra,
     >                phetpy, pfacpy, jaux, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux, pcofay,
     >                  jaux,   jaux, parepy,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.3. ==> si le raffinement ou le deraffinement sont pilotes par un
c          indicateur, recuperation de l'indicateur
c
      nbvtri = 0
      nbvqua = 0
      nbvtet = 0
      nbvhex = 0
      nbvpyr = 0
      nbvpen = 0
c
      if ( ( taopti(31).gt.0 .or. taopti(32).gt.0 ) .and.
     >     taopti(37).eq.0 ) then
c
c 2.3.1. ==> la situation actuelle
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINI0', nompro
#endif
        call deini0 ( nohind, typind, ncmpin,
     >                nbvnoe, nbvare,
     >                nbvtri, nbvqua,
     >                nbvtet, nbvhex, nbvpyr, nbvpen,
     >                adnoin, adnorn, adnosu,
     >                adarin, adarrn, adarsu,
     >                adtrin, adtrrn, adtrsu,
     >                adquin, adqurn, adqusu,
     >                adtein, adtern, adtesu,
     >                adhein, adhern, adhesu,
     >                adpyin, adpyrn, adpysu,
     >                adpein, adpern, adpesu,
     >                ulsort, langue, codret )
c
        endif
c
c 2.3.2. ==> complement eventuels
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINI2', nompro
#endif
        call deini2 ( nohind, typind, ncmpin,
     >                nbvtri, nbvqua,
     >                nbvtet, nbvhex, nbvpyr,
     >                adquin, adqurn, adqusu,
     >                adhein, adhern, adhesu,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbvnoe', nbvnoe
      write (ulsort,90002) 'nbvare', nbvare
      write (ulsort,90002) 'nbvtri', nbvtri
      write (ulsort,90002) 'nbvqua', nbvqua
      write (ulsort,90002) 'nbvtet', nbvtet
      write (ulsort,90002) 'nbvhex', nbvhex
      write (ulsort,90002) 'nbvpyr', nbvpyr
      write (ulsort,90002) 'nbvpen', nbvpen
#endif
c
c====
c 3. Transfert de l'indicateur s'il est defini par maille
c    Remarque : on suppose que s'il est defini sur les noeuds, il ne
c               peut pas avoir de valeurs sur les mailles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Transfert ; codret', codret
#endif
c
      if ( nbvnoe.eq.0 ) then
c
c 3.1. ==> Indicateur pris en valeur relative
c
        if ( taopti(8).eq.2 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DECFS0', nompro
#endif
          call decfs0 ( imem(phettr), imem(pfiltr),
     >                  imem(phetqu), imem(pfilqu),
     >                  imem(phette), imem(pfilte),
     >                  imem(phethe), imem(pfilhe), imem(adhes2),
     >                  imem(phetpe), imem(pfilpe), imem(adpes2),
     >                  nbvtri, nbvqua,
     >                  nbvtet, nbvpyr,
     >                  rmem(adtrrn), imem(adtrsu),
     >                  rmem(adqurn), imem(adqusu),
     >                  rmem(adtern), imem(adtesu),
     >                  rmem(adhern), imem(adhesu),
     >                  rmem(adpyrn), imem(adpysu),
     >                  rmem(adpern), imem(adpesu),
     >                  ulsort, langue, codret )
c
          endif
c
c 3.2. ==> Indicateur pris en valeur absolue : norme L2 ou infinie
c
        else
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DECFS1', nompro
#endif
          call decfs1 ( imem(phettr), imem(pfiltr),
     >                  imem(phetqu), imem(pfilqu),
     >                  imem(phette), imem(pfilte),
     >                  imem(phethe), imem(pfilhe), imem(adhes2),
     >                  imem(phetpe), imem(pfilpe), imem(adpes2),
     >                  nbvtri, nbvqua,
     >                  nbvtet, nbvpyr,
     >                  rmem(adtrrn), imem(adtrsu),
     >                  rmem(adqurn), imem(adqusu),
     >                  rmem(adtern), imem(adtesu),
     >                  rmem(adhern), imem(adhesu),
     >                  rmem(adpyrn), imem(adpysu),
     >                  rmem(adpern), imem(adpesu),
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
c
c====
c 4. mise a jour de certaines donnees concernant le maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. mise a jour ; codret', codret
      write (ulsort,90002) 'nbnoto', nbnoto
      write (ulsort,90002) 'nbarto', nbarto
      write (ulsort,90002) 'nbnoto, nbnop1, nbnop2',
     >                      nbnoto, nbnop1, nbnop2
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DESMAJ', nompro
#endif
      call desmaj ( nhnoeu, nharet, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              afaire,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'nancno', nancno, ' ==> nbnoto', nbnoto
      write (ulsort,90015) 'nancar', nancar, ' ==> nbarto', nbarto
      write (ulsort,90015) 'nanctr', nanctr, ' ==> nbtrto', nbtrto
      write (ulsort,90015) 'nancqu', nancqu, ' ==> nbquto', nbquto
      write (ulsort,99001) 'afaire', afaire
#endif
      endif
c
c====
c 5. Gestion des tableaux dont la taille a ete modifiee
c    Attention : il faut commencer par les noeuds car on a besoin
c    de la structure complete du maillage pour les renumerotations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. tableaux ; codret', codret
      write (ulsort,90002) 'nancno', nancno
      write (ulsort,90002) 'nbnoto', nbnoto
#endif
c
c 5.1. ==> Les noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.1 degre 2 ; codret', codret
#endif
c
c 5.1.1. ==> Renumerotation eventuelle
c
      if ( nancno.ne.nbnoto ) then
c
c 5.1.1.1. ==> Les tableaux
c
        if ( afaire ) then
c
          if ( codret.eq.0 ) then
c
          call gmalot ( ndisno, 'entier  ', nancno, pdisno, codre1 )
          call gmaloj ( nhnoeu//'.Deraffin', ' ',
     >                  nancno, pancno, codre2 )
          iaux = nancno + 1
          call gmalot ( nnouno, 'entier  ', iaux, pnouno, codre3 )
c
          codre0 = min ( codre1, codre2, codre3 )
          codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
          endif
c
          iaux = 0
          if ( ( taopti(31).gt.0 .or. taopti(32).gt.0 ) .and.
     >           taopti(37).eq.0 ) then
c
            if ( typind.eq.2 ) then
              saux08 = 'ValeursE'
            else
              saux08 = 'ValeursR'
            endif
            call gmobal ( nohind//'.Noeud.'//saux08, codre0 )
            if ( codre0.eq.2 ) then
              call gmadoj ( nohind//'.Noeud.'//saux08,
     >                      jaux, iaux, codre0 )
              codret = max (codret, abs(codre0) )
              iaux = typind
            endif
c
          endif
c
c 5.1.1.2. ==> La renumerotation des tableaux lies aux noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.1.1.2 Renumerotation ; codret', codret
#endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DECFS2', nompro
#endif
          call decfs2 ( imem(pdisno), imem(pancno), imem(pnouno),
     >                  imem(phetno), imem(pfamno), imem(pareno),
     >                  imem(adhono), rmem(pcoono),
     >                  imem(pnp2ar), imem(psomar),
     >                  imem(paretr),
     >                  imem(phetqu), imem(parequ), imem(pfilqu),
     >                  imem(ptrite), imem(pcotrt), imem(parete),
     >                  imem(phethe), imem(pfilhe), imem(adhes2),
     >                  imem(pfacpy), imem(pcofay), imem(parepy),
     >                  imem(phetpe), imem(pfilpe), imem(adpes2),
     >                  iaux, imem(jaux), rmem(jaux),
     >                  ulsort, langue, codret )
c
          endif
c
c 5.1.1.3. ==> Le menage
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.1.1.3 Menage ; codret', codret
#endif
c
          if ( codret.eq.0 ) then
c
          call gmlboj ( ndisno, codre1 )
          call gmlboj ( nnouno, codre2 )
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
c 5.1.2. ==> Raccourcissement des tableaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.1.2 Raccourcissement ; codret', codret
      write (ulsort,90002) 'nancno', nancno
      write (ulsort,90002) 'nbnoto', nbnoto
      write (ulsort,90002) 'nancar', nancar
      write (ulsort,90002) 'nbarto', nbarto
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 210
      if ( homolo.ge.1 ) then
        iaux = iaux*11
      endif
      if ( afaire ) then
        iaux = iaux*13
      endif
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD05', nompro
#endif
      call utad05 ( iaux, jaux, nhnoeu,
     >              nancno, nbnoto, sdim,
     >              phetno,
     >              pfamno,
     >              pcoono, pareno, adhono, pancno,
     >              ulsort, langue, codret )
c
      call gmecat ( nhnoeu, 1, nbnoto, codre0 )
c
      codret = max ( abs(codre0), codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.1.2 nohind ; codret', codret
#endif
c
      if ( ( taopti(31).gt.0 .or. taopti(32).gt.0 ) .and.
     >       taopti(37).eq.0 ) then
c
        if ( typind.eq.2 ) then
          saux08 = 'ValeursE'
        else
          saux08 = 'ValeursR'
        endif
        call gmobal ( nohind//'.Noeud.'//saux08, codre0 )
        if ( codre0.eq.2 ) then
          call gmmod ( nohind//'.Noeud.'//saux08,
     >                 jaux, nancno, nbnoto, ncmpin, ncmpin, codre0 )
          codret = max ( abs(codre0), codret )
        endif
        if ( typind.eq.2 ) then
          adnoin = jaux
        else
          adnorn = jaux
        endif
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) 'noeuds'
      write (ulsort,texte(langue,8)) codret
#endif
c
c 5.2. ==> Suppression des fils de mise en conformite
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.2 Suppression fils ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
      call gmobal ( nhhexa//'.InfoSup2', codre0 )
      if ( codre0.eq.2 ) then
        call gmlboj ( nhhexa//'.InfoSup2', codret )
      endif
      endif
c
      if ( codret.eq.0 ) then
      call gmobal ( nhpent//'.InfoSup2', codre0 )
      if ( codre0.eq.2 ) then
        call gmlboj ( nhpent//'.InfoSup2', codret )
      endif
      endif
c
      if ( codret.eq.0 ) then
      call gmobal ( nhtetr//'.InfoSup2', codre0 )
      if ( codre0.eq.2 ) then
        call gmlboj ( nhtetr//'.InfoSup2', codret )
      endif
      endif
c
      if ( codret.eq.0 ) then
      call gmobal ( nhpyra//'.InfoSup2', codre0 )
      if ( codre0.eq.2 ) then
        call gmlboj ( nhpyra//'.InfoSup2', codret )
      endif
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DECFS3', nompro
#endif
      call decfs3 ( imem(phettr), imem(pfiltr),
     >              imem(phetqu), imem(pfilqu),
     >              imem(phette), imem(pfilte),
     >              imem(phethe), imem(pfilhe),
     >              imem(phetpe), imem(pfilpe),
     >              ulsort, langue, codret )
c
      endif
c
c 5.3. ==> Redimensionnement des tableaux du maillage
c          On detruit les objets de tailles nulles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.3. Redim maillage ; codret', codret
      write (ulsort,90002) 'nbtrto, nanctr', nbtrto, nanctr
      write (ulsort,90002) 'nbquto, nancqu', nbquto, nancqu
      write (ulsort,90002) 'nbteto, nancte', nbteto, nancte
      write (ulsort,90002) 'nbheto, nanche', nbheto, nanche
      write (ulsort,90002) 'nbpyto, nancpy', nbpyto, nancpy
      write (ulsort,90002) 'nbpeto, nancpe', nbpeto, nancpe
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      jaux = 0
      if ( nbtrto.ne.0 .or. nanctr.ne.0 ) then
        nbtran = nanctr
      else
        nbtran = -1
      endif
      if ( nbquto.ne.0 .or. nancqu.ne.0 ) then
        nbquan = nancqu
      else
        nbquan = -1
      endif
      if ( nbteto.ne.0 .or. nancte.ne.0 ) then
        nbtean = nancte
      else
        nbtean = -1
      endif
      if ( nbheto.ne.0 .or. nanche.ne.0 ) then
        nbhean = nanche
      else
        nbhean = -1
      endif
      if ( nbpyto.ne.0 .or. nancpy.ne.0 ) then
        nbpyan = nancpy
      else
        nbpyan = -1
      endif
      if ( nbpeto.ne.0 .or. nancpe.ne.0 ) then
        nbpean = nancpe
      else
        nbpean = -1
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbtran', nbtran
      write (ulsort,90002) 'nbquan', nbquan
      write (ulsort,90002) 'nbtean', nbtean
      write (ulsort,90002) 'nbhean', nbhean
      write (ulsort,90002) 'nbpyan', nbpyan
      write (ulsort,90002) 'nbpean', nbpean
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD98', nompro
#endif
      call utad98 ( nomail,   iaux,   jaux,
     >              nancar, nbarto,
     >              nbtran, nbtrto,
     >              nbquan, nbquto,
     >              nbtean, nbteto, nancta, kaux,
     >              nbhean, nbheto, nancha, kaux,
     >              nbpyan, nbpyto, nancya, kaux,
     >              nbpean, nbpeto, nancpa, kaux,
     >              phetar, psomar, pfilar, pmerar, pancar,
     >              pnp2ar, adhoar,
     >              phettr, paretr, pfiltr, ppertr, panctr,
     >              pnivtr, adpetr, adnmtr, adhotr,
     >              phetqu, parequ, pfilqu, pperqu, pancqu,
     >              pnivqu, adhequ, adnmqu, adhoqu,
     >              phette, ptrite, pcotrt, parete,
     >              pfilte, pperte, pancte,
     >              phethe, pquahe, pcoquh, parehe,
     >              pfilhe, pperhe, panche, adnmhe,
     >              phetpy, pfacpy, pcofay, parepy,
     >              pfilpy, pperpy, pancpy,
     >              phetpe, pfacpe, pcofap, parepe,
     >              pfilpe, pperpe, pancpe,
     >              pfamar, pfamtr, pfamqu,
     >              pfamte, pfamhe, pfampy, pfampe,
     >              ulsort, langue, codret )
c
      endif
c
c 5.4. ==> si le raffinement ou le deraffinement sont pilotes par un
c          indicateur, suppression des structures inutiles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.4. suppression ; codret', codret
#endif
c
      if ( ( taopti(31).gt.0 .or. taopti(32).gt.0 ) .and.
     >     taopti(37).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINI3', nompro
#endif
        call deini3 ( nohind,
     >                nbvtri, nbvqua,
     >                nbvtet, nbvhex, nbvpyr, nbvpen,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 6. determination des voisinages
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. voisinage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      voarno = 0
      vofaar = 1
      vovoar = 0
      vovofa = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nomail, nhvois,
     >              voarno, vofaar, vovoar, vovofa,
     >              iaux  , jaux  ,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Apres 6. voisinages : codret', codret
#endif
c
      endif
c
c====
c 7. la fin
c====
c
c 7.1. ==> message si erreur
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
c 7.2. ==> fin des mesures de temps de la section
c
      call gtfims (nrosec)
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
