      subroutine infofo ( nbfonc, nofonc,
     >                      typg, numcal,
     >                     ulecr,
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
c   INFOrmation : FOnction
c   ----          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .   1    . nombre de fonctions                        .
c . nofonc . e   . nbfonc . nom des objets qui contiennent la          .
c .        .     .        . description de chaque fonction             .
c . typg   . e   .   1    . type de l'entite a examiner                .
c . numcal . e   .   1    . numero du calcul de l'entite a examiner    .
c . ulecr  . e   .   1    . unite logique pour l'ecriture              .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans les memoires             .
c .        .     .        . 3 : probleme dans les fichiers             .
c .        .     .        . 5 : probleme autre                         .
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
      parameter ( nompro = 'INFOFO' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
#include "esutil.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
#include "gmreel.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer typg, numcal
c
      integer ulecr
      integer ulsort, langue, codret
c
      character*8 nofonc(*)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer adaux1, adaux2, adaux3
      integer nrfonc, nrtafo
      integer nbpg
      integer advale, advalr, adobch, adprpg, adtyas
      integer typgeo, ngauss, nbenmx, nbvapr, nbtyas
      integer carsup, nbtafo, typint
c
      integer nbcomp, nbtvch, typcha
      integer nrocmp, nrotch
      integer nument
      integer adnocp, adcaen, adcare, adcaca
      integer adlipr
c
      character*8 nnfonc
      character*8 saux08
      character*16 nomcmp
      character*16 saux16
      character*18 unicmp
      character*64 nomcha, saux64, noprof
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
#include "infoen.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Type de l''''entite a examiner   :'',i5)'
      texte(1,5) = '(''Numero de l''''entite a examiner :'',i5)'
      texte(1,6) = '(/,''Fonction numero '',i5)'
      texte(1,7) = '(''. Nom du profil : '',a)'
      texte(1,8) = '(''Incoherence dans la longueur du profil.'')'
c
      texte(2,4) = '(''Type of entity     :'',i5)'
      texte(2,5) = '(''Number of entity   :'',i5)'
      texte(2,6) = '(/,''Functions # '',i5)'
      texte(2,7) = '(''. Profil name : '',a)'
      texte(2,8) = '(''Profile lengths are not coherent.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) typg
      write (ulsort,texte(langue,5)) numcal
#endif
c
      codret = 0
c
c     Pour eviter un message de ftnchek :
      nomcha = blan64
c
c====
c 2. on parcourt toutes les fonctions
c====
c
      do 20 , nrfonc = 1 , nbfonc
c
c 2.1. ==> caracterisation de la fonction courante
c
        if ( codret.eq.0 ) then
c
        nnfonc = nofonc(nrfonc)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) nrfonc
cgn        call gmprsx (nompro, nnfonc )
cgn        call gmprsx (nompro, nnfonc//'.ValeursR' )
#endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
        call utcafo ( nnfonc,
     >                typcha,
     >                typgeo, ngauss, nbenmx, nbvapr, nbtyas,
     >                carsup, nbtafo, typint,
     >                advale, advalr, adobch, adprpg, adtyas,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'typcha', typcha
        write (ulsort,90002) 'typgeo', typgeo
        write (ulsort,90002) 'ngauss', ngauss
        write (ulsort,90002) 'nbenmx', nbenmx
        write (ulsort,90002) 'nbvapr', nbvapr
        write (ulsort,90002) 'nbtyas', nbtyas
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,90002) 'nbtafo', nbtafo
#endif
c
c 2.2. ==> En l'absence de profil, le numero d'entite a rechercher est
c          le numero dans le calcul qui est fourni en argument
c          Avec un profil, on cherche si ce numero est present dans la
c          liste. Si oui, on memorise sa position avec numcal ; si non,
c          on mentionne qu'aucune valeur n'est disponible.
c
        if ( codret.eq.0 ) then
c
        if ( nbvapr.le.0 ) then
c
          nument = numcal
c
        else
c
          saux08 = smem(adprpg)
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTCAPR', nompro
#endif
          call utcapr ( saux08,
     >                    iaux, noprof, adlipr,
     >                  ulsort, langue, codret )
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,7)) noprof
          call gmprot (nompro,saux08//'.ListEnti',1,50)
#endif
          if ( iaux.ne.nbvapr ) then
            write (ulsort,texte(langue,8))
            write (ulsort,90002) 'Pour la fonction', nbvapr
            write (ulsort,90002) 'Pour le profil  ', iaux
            codret = 3
          endif
c
          endif
c
          if ( codret.eq.0 ) then
c
          nument = 0
          do 220 , iaux = 0 , nbvapr-1
            if ( imem(adlipr+iaux).eq.numcal ) then
              nument = iaux+1
              goto 221
            endif
  220     continue
  221     continue
c
          endif
c
        endif
c
        endif
c
c 2.3. ==> les valeurs
c
        if ( codret.eq.0 ) then
c
        if ( typgeo.eq.typg ) then
c
cgn          call gmprot (nompro, nnfonc//'.ValeursR',1,nbenmx*nbtafo )
          if ( ngauss.eq.ednopg ) then
            nbpg = 1
          else
            nbpg = ngauss
          endif
c
          do 231 , nrtafo = 1 , nbtafo
c
c 2.3.1. ==> le nom du champ et de la composante
c 2.3.1.1. ==> recuperation
c
            if ( codret.eq.0 ) then
c
            saux08 = smem(adobch+nrtafo-1)
#ifdef _DEBUG_HOMARD_
cgn            call gmprsx (nompro,saux08)
cgn            call gmprsx (nompro,saux08//'.Nom_Comp')
cgn            call gmprsx (nompro,saux08//'.Cham_Ent')
cgn            call gmprsx (nompro,saux08//'.Cham_Ree')
            call gmprsx (nompro,saux08//'.Cham_Car')
            call gmprsx (nompro,'%%%%%%19')
            call gmprsx (nompro,'%%%%%%19.ValeursR')
cgn            call gmprsx (nompro,'%%%%%%19.ValeursE')
#endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTCACH', nompro
#endif
            call utcach ( saux08,
     >                    saux64,
     >                    nbcomp, nbtvch, typcha,
     >                    adnocp, adcaen, adcare, adcaca,
     >                    ulsort, langue, codret )
c
            endif
c
cgn            write(ulsort,*) 'nbcomp = ',nbcomp , ', nbtvch = ',nbtvch
            if ( codret.eq.0 ) then
cgn            write(ulsort,*) 'nrtafo = ',nrtafo , ', saux64 = ',saux64
c
c 2.3.1.2. ==> le nom du champ
c
              if ( nrtafo.eq.1 .or. saux64.ne.nomcha ) then
                nomcha = saux64
                write (ulecr,30001) nomcha(1:48)
                call utlgut ( iaux, nomcha, ulsort, langue, codret )
                if ( iaux.gt.48 ) then
                  write (ulecr,30002) nomcha(49:64)
                endif
                nrocmp = nbcomp
                nrotch = 0
              endif
c
c 2.3.1.3. ==> le pas de temps
c
              if ( nrocmp.eq.nbcomp ) then
                nrocmp = 0
                nrotch = nrotch + 1
                if ( imem(adcaen+nbinec*(nrotch-1)+1).eq.ednodt .and.
     >               imem(adcaen+nbinec*(nrotch-1)+2).eq.ednonr ) then
                  write(ulecr,30004)
                else
                  write(ulecr,30003) imem(adcaen+nbinec*(nrotch-1)+1),
     >                               imem(adcaen+nbinec*(nrotch-1)+2)
                  saux16 = smem(adnocp+8+4*nbcomp)//
     >                     smem(adnocp+9+4*nbcomp)
                  if ( saux16(1:8).eq.'INCONNUE' ) then
                    saux16 = blan16
                  endif
                  write(ulecr,30005) rmem(adcare+nrotch-1), saux16
                endif
              endif
c
c 2.3.1.4. ==> le nom et l'unite de la composante
c
              nrocmp = nrocmp + 1
              nomcmp = smem(adnocp+6+2*nrocmp)//smem(adnocp+7+2*nrocmp)
              saux16 = smem(adnocp+6+2*nbcomp+2*nrocmp)//
     >                 smem(adnocp+7+2*nbcomp+2*nrocmp)
c
              if ( saux16.eq.blan16 ) then
                unicmp = blan16//'  '
              else
                unicmp = '('//saux16//')'
              endif
c
            endif
c
c 2.3.2. ==> la/les valeurs
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,90002) 'nument', nument
#endif
c
            if ( nument.eq.0 ) then
c
              if ( nrocmp.eq.nbcomp ) then
                write (ulecr,30300)
              endif
c
            else
c
              if ( typcha.eq.edfl64 ) then
                adaux1 = advalr
              else
                adaux1 = advale
              endif
              adaux1 = adaux1 + nbtafo*nbpg*(nument-1)-1
c
              if ( nomcmp.ne.blan16 ) then
                write (ulecr,30006) nomcmp, unicmp
              else
                if ( nbcomp.gt.1 ) then
                  write (ulecr,30016) nrocmp
                endif
              endif
              adaux2 = adaux1 + nrtafo
c
              if ( nbpg.eq.1 ) then
c
                if ( typcha.eq.edfl64 ) then
                  write (ulecr,30105) rmem(adaux2)
                else
                  write (ulecr,30205) imem(adaux2)
                endif
c
              else
cgn          call gmprot (nompro, nnfonc//'.ValeursR',1,nbenmx*nbtafo*nbpg )
                kaux = nbpg - mod(nbpg,2)
                do 232 , jaux = 1 , kaux, 2
                  adaux3 = adaux2 + nbtafo*jaux
                  if ( carsup.eq.1 ) then
                    if ( typcha.eq.edfl64 ) then
                      write (ulecr,30106) jaux, rmem(adaux3-nbtafo),
     >                                    jaux+1, rmem(adaux3)
                    else
                      write (ulecr,30206) jaux, imem(adaux3-nbtafo),
     >                                    jaux+1, imem(adaux3)
                    endif
                  else
                    if ( typcha.eq.edfl64 ) then
                      write (ulecr,30108) jaux, rmem(adaux3-nbtafo),
     >                                    jaux+1, rmem(adaux3)
                    else
                      write (ulecr,30208) jaux, imem(adaux3-nbtafo),
     >                                    jaux+1, imem(adaux3)
                    endif
                  endif
  232           continue
c
                if ( mod(nbpg,2).ne.0 ) then
                  adaux3 = adaux2 + nbtafo*(nbpg-1)
                  if ( typcha.eq.edfl64 ) then
                    if ( carsup.eq.1 ) then
                      write (ulecr,30107) nbpg, rmem(adaux3)
                    else
                      write (ulecr,30109) nbpg, rmem(adaux3)
                    endif
                  else
                    if ( carsup.eq.1 ) then
                      write (ulecr,30207) nbpg, imem(adaux3)
                    else
                      write (ulecr,30209) nbpg, imem(adaux3)
                    endif
                  endif
                endif
c
              endif
c
            endif
c
  231     continue
c
        endif
c
        endif
c
   20 continue
c
c===
c 3. formats
c===
c
30001 format(
     >  '* Champ : ',a48,                                         '  *')
30002 format(
     >  '*         ',a16,         '                                  *')
30003 format(
     >  '*  Pas de temps :',i10,   ', Numero d''ordre :',i10,   '     ',
     >  '*')
30004 format(
     >  '*  Sans pas de temps, ni numero d''ordre                     ',
     >  '*')
30005 format(
     >  '*  Instant :', d14.7,    '  ',a16,         '                *')
30006 format(
     >  '* . Composante : ',a16,         ' ',a18,           '        *')
30016 format(
     >  '* . Composante numero',i3,
     >  ' :                                  *')
30105 format(
     >  '*   ', d14.7,     42x,                                     '*')
c            12345678901234123456789012345678901234567890123456789012
30106 format(
     >  '*   ',2('no ',i2,' : ', d15.8,4x),    '  *')
30107 format(
     >  '*   ','no ',i2,' : ', d15.8,33x,'*')
30108 format(
     >  '*   ',2('pg ',i2,' : ', d15.8,4x),    '  *')
30109 format(
     >  '*   ','pg ',i2,' : ', d15.8,33x,'*')
30205 format(
     >  '*   ',   i14,     42x,                                     '*')
30206 format(
     >  '*   ',2('no ',i2,' : ',   i15,4x),    '  *')
30207 format(
     >  '*   ','no ',i2,' : ',   i15,33x,'*')
30208 format(
     >  '*   ',2('pg ',i2,' : ',   i15,4x),    '  *')
30209 format(
     >  '*   ','pg ',i2,' : ',   i15,33x,'*')
30300 format(
     >  '*   Aucune valeur n''est presente.                           ',
     >  '*')
c
c====
c 4. La fin
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
