      subroutine deini0 ( nohind, typind, ncmpin,
     >                    nbvnoe, nbvare,
     >                    nbvtri, nbvqua,
     >                    nbvtet, nbvhex, nbvpyr, nbvpen,
     >                    adnoin, adnorn, adnosu,
     >                    adarin, adarrn, adarsu,
     >                    adtrin, adtrrn, adtrsu,
     >                    adquin, adqurn, adqusu,
     >                    adtein, adtern, adtesu,
     >                    adhein, adhern, adhesu,
     >                    adpyin, adpyrn, adpysu,
     >                    adpein, adpern, adpesu,
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
c traitement des DEcisions - INITialisations - phase 0
c                --          ---                     -
c ______________________________________________________________________
c  Recuperation des adresses pour les indicateurs
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nohind . e   .  ch8   . nom de l'objet contenant l'indicateur      .
c . typind .  s  .   1    . type de valeurs                            .
c .        .     .        . 2 : entieres                               .
c .        .     .        . 3 : reelles                                .
c . ncmpin .  s  .   1    . nombre de composantes de l'indicateur      .
c . nbvent .  s  .   1    . nombre de valeurs pour l'entite            .
c . adensu .  s  .   1    . adresse du support                         .
c . adenin .  s  .   1    . adresse des valeurs entieres               .
c . adenrn .  s  .   1    . adresse des valeurs reelles                .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'DEINI0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#ifdef _DEBUG_HOMARD_
#include "nombar.h"
#include "nombno.h"
#include "enti01.h"
#endif
c
c 0.3. ==> arguments
c
      character*8 nohind
c
      integer typind, ncmpin
      integer nbvnoe, nbvare
      integer nbvtri, nbvqua
      integer nbvtet, nbvhex, nbvpyr, nbvpen
      integer adnoin, adnorn, adnosu
      integer adarin, adarrn, adarsu
      integer adtrin, adtrrn, adtrsu
      integer adquin, adqurn, adqusu
      integer adtein, adtern, adtesu
      integer adhein, adhern, adhesu
      integer adpyin, adpyrn, adpysu
      integer adpein, adpern, adpesu
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer typin0(-1:7)
      integer ncmpi0(-1:7)
c
      integer codre0
c
#ifdef _DEBUG_HOMARD_
      integer kaux
      character*15 saux15
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
c 1. Initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.1. ==>les messages
c
      texte(1,4) = '(''La structure nohind est inconnue.'')'
      texte(1,5) = '(a,'' pour les '',a,'' :'',i4)'
      texte(1,6) = '(''Les types d''''indicateurs sont incoherents.'')'
      texte(1,7) = '(''Les nombres de composantes sont incoherents.'')'
c
      texte(2,4) = '(''nohind structure is unknown.'')'
      texte(2,5) = '(a,'' for the '',a,'':'',i4)'
      texte(2,6) = '(''Non coherent types for indicators.'')'
      texte(2,7) = '(''Non coherent numbers for components.'')'
c
#include "impr03.h"
c
c 1.2. ==> les types d'indicateurs : aucun pour le moment
c
      do 12 , iaux = -1 , 7
        typin0(iaux) = 0
        ncmpi0(iaux) = 0
   12 continue
c
      codret = 0
c
c====
c 2. La structure generale de l'indicateur d'erreur
c====
c
      call gmobal ( nohind, codre0 )
      if ( codre0.ne.1 ) then
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx (nompro, nohind )
      do 23000 , iaux = 1 , 1
cgn      do 23000 , iaux = 1 , 2
        if ( iaux.eq.1 ) then
          saux15(8:15) = 'ValeursR'
        else
          saux15(8:15) = 'ValeursE'
        endif
        do 2999 , jaux = -1, 7
          kaux = 0
          if ( jaux.eq.-1 ) then
            kaux = nbnoto
          elseif ( jaux.eq.1 ) then
            kaux = nbarto
          elseif ( jaux.eq.2 ) then
            kaux = nbtrto
          elseif ( jaux.eq.3 ) then
            kaux = nbteto
          elseif ( jaux.eq.4 ) then
            kaux = nbquto
          elseif ( jaux.eq.5 ) then
            kaux = nbpyto
          elseif ( jaux.eq.6 ) then
            kaux = nbheto
          elseif ( jaux.eq.7 ) then
            kaux = nbpeto
          endif
          if ( kaux.gt.0 ) then
            saux15(1:7) = '.'//suffix(1,jaux)(1:5)//'.'
            call gmobal ( nohind//saux15, codre0 )
            if ( codre0.eq.2 ) then
cgn              call gmprsx ( nompro, nohind//saux15 )
              call gmprot (nompro, nohind//saux15, 1, min(kaux,50) )
              if ( kaux.gt.50 ) then
                call gmprot (nompro, nohind//saux15,
     >                       max(1,kaux-49),kaux)
              endif
            endif
          endif
 2999   continue
23000 continue
      endif
#endif
c
c====
c 3. Les adresses par type d'entites
c    Le type (entier/reel) doit etre le meme pour toutes
c====
c
c 3.1. ==> noeuds
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD31_no', nompro
#endif
      iaux = -30
      jaux = -1
      call utad31 ( iaux, nohind, jaux,
     >              nbvnoe, ncmpin,
     >              adnosu, adnoin, adnorn, typind,
     >              ulsort, langue, codret )
      typin0(jaux) = typind
      ncmpi0(jaux) = ncmpin
c
      endif
c
c 3.2. ==> aretes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD31_ar', nompro
#endif
      iaux = -30
      jaux = 1
      call utad31 ( iaux, nohind, jaux,
     >              nbvare, ncmpin,
     >              adarsu, adarin, adarrn, typind,
     >              ulsort, langue, codret )
      typin0(jaux) = typind
      ncmpi0(jaux) = ncmpin
c
      endif
c
c 3.3. ==> triangles
c
      if ( nbtrto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD31_tr', nompro
#endif
        iaux = -30
        jaux = 2
        call utad31 ( iaux, nohind, jaux,
     >                nbvtri, ncmpin,
     >                adtrsu, adtrin, adtrrn, typind,
     >                ulsort, langue, codret )
        typin0(jaux) = typind
        ncmpi0(jaux) = ncmpin
c
        endif
c
      else
c
        nbvtri = 0
c
      endif
c
c 3.4. ==> quadrangles
c
      if ( nbquto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD31_qu', nompro
#endif
        iaux = -30
        jaux = 4
        call utad31 ( iaux, nohind, jaux,
     >                nbvqua, ncmpin,
     >                adqusu, adquin, adqurn, typind,
     >                ulsort, langue, codret )
        typin0(jaux) = typind
        ncmpi0(jaux) = ncmpin
c
        endif
c
      else
c
        nbvqua = 0
c
      endif
c
c 3.5. ==> tetraedres
c
      if ( nbteto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD31_te', nompro
#endif
        iaux = -30
        jaux = 3
        call utad31 ( iaux, nohind, jaux,
     >                nbvtet, ncmpin,
     >                adtesu, adtein, adtern, typind,
     >                ulsort, langue, codret )
        typin0(jaux) = typind
        ncmpi0(jaux) = ncmpin
c
        endif
c
      else
c
        nbvtet = 0
c
      endif
c
c 3.6. ==> pyramides
c
      if ( nbpyto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD31_py', nompro
#endif
        iaux = -30
        jaux = 5
        call utad31 ( iaux, nohind, jaux,
     >                nbvpyr, ncmpin,
     >                adpysu, adpyin, adpyrn, typind,
     >                ulsort, langue, codret )
        typin0(jaux) = typind
        ncmpi0(jaux) = ncmpin
c
        endif
c
      else
c
        nbvpyr = 0
c
      endif
c
c 3.7. ==> hexaedres
c
      if ( nbheto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD31_he', nompro
#endif
        iaux = -30
        jaux = 6
        call utad31 ( iaux, nohind, jaux,
     >                nbvhex, ncmpin,
     >                adhesu, adhein, adhern, typind,
     >                ulsort, langue, codret )
        typin0(jaux) = typind
        ncmpi0(jaux) = ncmpin
c
        endif
c
      else
c
        nbvhex = 0
c
      endif
c
c 3.8. ==> pentaedres
c
      if ( nbpeto.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD31_pe', nompro
#endif
        iaux = -30
        jaux = 7
        call utad31 ( iaux, nohind, jaux,
     >                nbvpen, ncmpin,
     >                adpesu, adpein, adpern, typind,
     >                ulsort, langue, codret )
        typin0(jaux) = typind
        ncmpi0(jaux) = ncmpin
c
        endif
c
      else
c
        nbvpen = 0
c
      endif
c
c====
c 4. Le type (entier/reel) doit etre le meme pour toutes les entites
c    Idem pour le nombre de composantes
c====
c
      if ( codret.eq.0 ) then
c
      typind = 0
      ncmpin = 0
      do 41 , iaux = -1 , 7
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) 'typind',
     >         mess14(langue,3,iaux), typin0(iaux)
        write (ulsort,texte(langue,5)) 'ncmpin',
     >         mess14(langue,3,iaux), ncmpi0(iaux)
#endif
        if ( typin0(iaux).ne.0 ) then
          if ( typind.eq.0 ) then
            typind = typin0(iaux)
          else
            if ( typind.ne.typin0(iaux) ) then
              codret = 2
            endif
          endif
        endif
        if ( ncmpi0(iaux).ne.0 ) then
          if ( ncmpin.eq.0 ) then
            ncmpin = ncmpi0(iaux)
          else
            if ( ncmpin.ne.ncmpi0(iaux) ) then
              codret = 3
            endif
          endif
        endif
c
   41 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)
     >'nbvnoe, nbvare, nbvtri, nbvqua, nbvtet, nbvhex, nbvpyr, nbvpen',
     >                     nbvnoe, nbvare,
     >                     nbvtri, nbvqua,
     >                     nbvtet, nbvhex, nbvpyr, nbvpen
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
      if ( codret.eq.1 ) then
        write (ulsort,texte(langue,4))
      elseif ( codret.eq.2 ) then
        do 51 , iaux = -1 , 7
#ifdef _DEBUG_HOMARD_
          if ( typin0(iaux).ge.0 ) then
#else
          if ( typin0(iaux).ne.0 ) then
#endif
            write (ulsort,texte(langue,5)) 'typind',
     >             mess14(langue,3,iaux), typin0(iaux)
          endif
   51   continue
        write (ulsort,texte(langue,6))
      elseif ( codret.eq.3 ) then
        do 52 , iaux = -1 , 7
#ifdef _DEBUG_HOMARD_
          if ( ncmpi0(iaux).ge.0 ) then
#else
          if ( ncmpi0(iaux).ne.0 ) then
#endif
            write (ulsort,texte(langue,5)) 'ncmpin',
     >             mess14(langue,3,iaux), ncmpi0(iaux)
          endif
   52   continue
        write (ulsort,texte(langue,7))
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
