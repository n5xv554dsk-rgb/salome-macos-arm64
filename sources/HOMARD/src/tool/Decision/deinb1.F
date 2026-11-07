      subroutine deinb1 ( typenh, nbento, ncmpin,
     >                    ensupp, enindi,
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
c traitement des DEcisions - INitialisations - Bilan - etape 1
c                --          --                -             -
c but : impression des bilans de l'indicateur
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nbento . e   .   1    . nombre total d'entites                     .
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . ensupp . e   . nbento . support pour les entites                   .
c . enindi . e   . nbento . valeurs pour les entites                   .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme dans les fichiers             .
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
      parameter ( nompro = 'DEINB1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmreel.h"
c
#include "infini.h"
#include "envada.h"
#include "impr02.h"
#include "enti01.h"
c
c 0.3. ==> arguments
c
      integer typenh
      integer ncmpin
      integer nbento
      integer ensupp(nbento)
c
      integer ulsort, langue, codret
c
      double precision enindi(nbento,ncmpin)
c
c 0.4. ==> variables locales
c
      integer nbclas
      parameter (nbclas=20)
c
      integer histog(nbclas)
      integer iclass(0:nbclas)
      double precision rclass(0:nbclas)
c
      character*8 ntrav1
      character*8 titcou(6)
      character*10 saux10
c
      integer iaux, jaux
      integer ulhist, ulxmgr
      integer lnomfl
      integer ival(1), nbval
      integer adtra1
      integer codre1, codre2, codre3
      integer codre0
#ifdef _DEBUG_HOMARD_
      integer ulbrut
#endif
c
      double precision valmin, valmax
      double precision vamiar, vamaar, valdif
      double precision xlow
c
      logical consta
c
      character*200 nomflo
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
      character*54 mess54(nblang,nbmess)
c
      character*8 mess08(nblang,2)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Impression du bilan de l''''indicateur sur les '',a)'
      texte(1,5) = '(''.. Valeur '',a,'' :'',g16.8)'
      texte(1,6) = '(''--> valeur arrondie pour le '',a,'' :'',g16.8)'
c
      texte(2,4) =
     > '(''Printing of summary of indicator over '',a)'
      texte(2,5) = '(''.. Value '',a,'' :'',g16.8)'
      texte(2,6) = '(''--> round value for '',a,'' :'',g16.8)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
c
      codret = 0
c
c===
c 2. tableaux de travail
c===
c 2.1. ==> Allocation
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'reel    ', nbento, adtra1, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
c 2.2. ==> Copie des valeurs filtrees
c
      if ( codret.eq.0 ) then
c
      nbval = 0
      do 22 , iaux = 1 , nbento
c
        if ( ensupp(iaux).eq.1 ) then
          nbval = nbval + 1
          rmem(adtra1+nbval-1) = enindi(iaux,1)
          if ( nbval.eq.1 ) then
            valmin = enindi(iaux,1)
            valmax = enindi(iaux,1)
          else
            valmin = min (valmin,enindi(iaux,1))
            valmax = max (valmax,enindi(iaux,1))
          endif
        endif
c
   22 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) 'min', valmin
      write (ulsort,texte(langue,5)) 'max', valmax
#endif
c
      endif
c
c 2.3. ==> arrondis des valeurs extremes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARRO', nompro
#endif
      call utarro ( valmin, valmax, vamiar, vamaar,
     >              ulsort, langue, codret )
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) 'min', vamiar
      write (ulsort,texte(langue,6)) 'max', vamaar
#endif
c
      valdif = ( vamaar - vamiar ) * 1.05d0
      if ( valdif.le.zeroma ) then
        consta = .true.
      else
        consta = .false.
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'valdif', valdif
      write (ulsort,99001) 'consta', consta
#endif
c
      endif
c
c====
c 3. Ecriture des bilans
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Ecriture des bilans ; codret', codret
#endif
c
10100 format(/,5x,64('*'))
10200 format(  5x,64('*'))
11100 format(  5x,'*    ',a54,'    *')
11200 format(  5x,'*',14x,2a8,i10,1x,a14,7x,'*')
c
c 3.1. ==> Les fichiers
c 3.1.1. ==> Le fichier d'historique
c
      if ( codret.eq.0 ) then
c
c               1234567890
      saux10 = 'indic.'//suffix(2,typenh)(1:4)
      iaux = 3
      jaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTULBI_hist', nompro
#endif
      call utulbi ( ulhist, nomflo, lnomfl,
     >                iaux, saux10, nbiter, jaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.1.2. ==> Le fichier pour xmgrace
c
      if ( .not.consta ) then
c
      if ( codret.eq.0 ) then
c
      saux10 = 'indic.'//suffix(2,typenh)(1:4)
      iaux = 2
      jaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTULBI_xmgr', nompro
#endif
      call utulbi ( ulxmgr, nomflo, lnomfl,
     >                iaux, saux10, nbiter, jaux,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
c
c 3.1.3. ==> Le fichier des valeurs brutes
c
      if ( codret.eq.0 ) then
c
c               1234   56                      7890
      saux10 = 'ind.'//suffix(4,typenh)(1:2)//'    '
      iaux = 10
      jaux = -1
      write (ulsort,texte(langue,3)) 'UTULBI_brut', nompro
      call utulbi ( ulbrut, nomflo, lnomfl,
     >                iaux, saux10, nbiter, jaux,
     >              ulsort, langue, codret )
c
      endif
#endif
c
c 3.2. ==> Les en-tetes
c
      if ( codret.eq.0 ) then
c
c       123456789012345678901234567890123456789012345678901234'
      mess54(1,1) =
     > '             Champ pilotant l''adaptation              '
      mess54(1,2) =
     > '            Valeur constante :                        '
c
      mess54(2,1) =
     > '            Governing field over the mesh             '
      mess54(2,2) =
     > '              Constant value :                        '
c
      mess08(1,1) = 'Valeur s'
      mess08(1,2) = 'ur les  '
c
      mess08(2,1) = 'Value ov'
      mess08(2,2) = 'er the  '
c
      write (ulhist,10100)
      write (ulhist,11100) mess54(langue,1)
      write (ulhist,11200) mess08(langue,1), mess08(langue,2),
     >                     nbval, mess14(langue,3,typenh)
c
      endif
c
c 3.3. ==> message si constant
c
      if ( codret.eq.0 ) then
c
      if ( consta ) then
c
        write (ulhist,10200)
        write (mess54(langue,2)(32:42),'(f11.4)') valmin
        write (ulhist,11100) mess54(langue,2)
        write (ulhist,10200)
c
      endif
c
      endif
c
c 3.4. ==> Classement
c
      if ( .not.consta ) then
c
      if ( codret.eq.0 ) then
c
      valdif = (vamaar-vamiar)/dble(nbclas)
      rclass(0) = vamiar
      do 34 , iaux = 1 , nbclas-1
        rclass(iaux) = vamiar + valdif*dble(iaux)
   34 continue
      rclass(nbclas) = vamaar
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'valdif', valdif
      do 3434 , iaux = 0 , nbclas
        write (ulsort,90024) 'rclass', iaux, rclass(iaux)
 3434 continue
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      titcou(1) = mess08(langue,1)
      titcou(2) = mess08(langue,2)(1:7)//mess14(langue,3,typenh)(1:1)
      titcou(3) = mess14(langue,3,typenh)(2:9)
      titcou(4) = mess14(langue,3,typenh)(10:14)//'   '
      titcou(5) = mess08(langue,1)(1:6)
      xlow = vamiar
      iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCRHI', nompro
#endif
      call utcrhi ( nbclas, rclass, iclass, histog,
     >              nbval,  iaux,   rmem(adtra1), ival,
     >              titcou, xlow, ulhist, ulxmgr,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
c 3.5. ==> Ecriture des valeurs brutes
c
      if ( codret.eq.0 ) then
c
      do 35 , iaux = 1 , nbval
        write(ulbrut,92010) rmem(adtra1+iaux-1)
   35 continue
c
      endif
#endif
c
c 3.6. ==> Fermeture
c
      if ( codret.eq.0 ) then
c
      call gufeul ( ulhist, codre1 )
      if ( .not.consta ) then
        call gufeul ( ulxmgr, codre2 )
      else
        codre2 = 0
      endif
      codre3 = 0
#ifdef _DEBUG_HOMARD_
      call gufeul ( ulbrut, codre3 )
#endif
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c====
c 4. menage
c====
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
