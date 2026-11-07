      subroutine utcrhi ( nbclas, rclass, iclass, histog,
     >                    nbval,  typval,   rval,   ival,
     >                    titcou, xlow, ulbila, ulxmgr,
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
c    UTilitaire - CReation d'un HIstogramme
c    --           --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbclas . e   .   1    . nombre de classes a affecter               .
c . rclass . e   .0:nbclas. limites des classes si reel                .
c . iclass . e   .0:nbclas. limites des classes si entier              .
c . histog .   s . nbclas . histogramme resultant                      .
c . nbval  . e   .   1    . nombre de valeurs a classer                .
c . typval . e   .   1    . 1 : valeurs entieres                       .
c .        .     .        . 2 : valeurs reelles                        .
c . rval   . e   . nbval  . valeurs reelles a classer                  .
c . ival   . e   . nbval  . valeurs entieres a classer                 .
c . titcou . e   . char*8 . titre des courbes                          .
c . xlow   . e   .   1    . limite basse pour les valeurs              .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulxmgr . e   .   1    . unite logique pour le fichier xmgrace      .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTCRHI' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbclas, nbval, typval
      integer iclass(0:nbclas), histog(nbclas)
      integer ival(*)
c
      double precision rclass(0:nbclas)
      double precision rval(*)
      double precision xlow
c
      integer ulbila, ulxmgr
      integer ulsort, langue, codret
c
      character*8 titcou(*)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer ivamax, ivamin
      integer p10max, p10min, p10dec
      integer nrocou
c
      real raux, raux1
      real x1, x2, y1, y2
c
      double precision rvamax, rvamin, epsilo, val10
      double precision rvamoy, rvecty
c
      logical prem
      logical ecart
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
      character*58 mess58(nblang,nbmess)
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
      texte(1,4) = '(''Nombre de classes : '',i8)'
      texte(1,5) = '(''Nombre de valeurs a classer   : '',i8)'
      texte(1,6) = '(''Limite basse pour les valeurs :'',g15.6)'
      texte(1,7) = '(''Classe'',i3,'' : '',g25.7)'
c
      texte(2,4) = '(''Number of classes : '',i8)'
      texte(2,5) = '(''Number of values to sort : '',i8)'
      texte(2,6) = '(''Low limit for values :'',g15.6)'
      texte(2,7) = '(''Class'',i3,'' : '',g25.7)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbclas
      write (ulsort,texte(langue,5)) nbval
      write (ulsort,texte(langue,6)) xlow
      do 1100 , iaux = 0 , nbclas
        write (ulsort,texte(langue,7)) iaux, rclass(iaux)
 1100 continue
#endif
c
c       1234567890123456789012345678901234567890123456789012345678
      mess58(1,1) =
     > '                  Fonction de repartition                 '
      mess58(1,2) =
     > '    Valeurs        *          Nombre de mailles           '
      mess58(1,3) =
     > '  Mini <  < Maxi   *    par classe     *      cumul       '
      mess58(1,4) =
     > '                   * en %  .  nombre   *  en %  .  nombre '
c       123458789012345678901234567890123456789012345678901234
c
      mess58(2,1) =
     > '                 Fonction of repartition                  '
      mess58(2,2) =
     > '    Values        *           Number of meshes            '
      mess58(2,3) =
     > '  Mini <  < Maxi  *     per class      *      total       '
      mess58(2,4) =
     > '                  *  in %  .  number   *  in %  .  number '
c
10200 format(  5x,64('*'))
c
11100 format(5x,'*  ',a58,'  *')
c
13101 format(
     >5x,'*   Minimum : ',i11,  '        Maximum : ',i15,  '     *')
13102 format(
     >5x,'*   Minimum : ',g12.5,'           Maximum : ',g12.5,'    *')
13103 format(
     >5x,'*   Moyenne : ',g12.5,'        Ecart-type : ',g12.5,'    *')
13203 format(
     >5x,'*   Mean    : ',g12.5,'     Std deviation : ',g12.5,'    *')
c
21200 format(
     >  '@map font 0 to "Helvetica", "Helvetica"',
     >/,'@map color 1 to (0, 0, 0), "black"',
     >/,'@map color 2 to (255, 0, 0), "red"',
     >/,'@map color 4 to (0, 0, 255), "blue"')
c
21210 format(
     >  '#',
     >/,'@    title "',4a8,'"',
     >/,'@    title font 0',
     >/,'@    title size 1.00000',
     >/,'@    title color 4')
21220 format(
     >  '#',
     >/,'@with g',i1)
21230 format(
     >  '@    s0 type XY',
     >/,'@    s0 skip 0',
     >/,'@    s0 linestyle 1',
     >/,'@    s0 linewidth 1',
     >/,'@    s0 color 2',
     >/,'@    s0 fill 6',
     >/,'@    s0 fill color 2')
21240 format(
     >  '@    world xmin ',g12.5,
     >/,'@    xaxis  bar color 2',
     >/,'@    xaxis  bar linestyle 1',
     >/,'@    xaxis  bar linewidth 1.0',
     >/,'@    xaxis  label "',a,'"',
     >/,'@    xaxis  label char size 0.80',
     >/,'@    xaxis  label font 0',
     >/,'@    xaxis  label color 4',
     >/,'@    xaxis  ticklabel font 0',
     >/,'@    xaxis  ticklabel char size 0.8')
21241 format(
     >  '@    yaxis  bar color 2',
     >/,'@    yaxis  bar linestyle 1',
     >/,'@    yaxis  bar linewidth 1.0',
     >/,'@    yaxis  label "Pourcentage de mailles"',
     >/,'@    yaxis  label char size 0.80',
     >/,'@    yaxis  label font 0',
     >/,'@    yaxis  label color 4',
     >/,'@    yaxis  ticklabel font 0',
     >/,'@    yaxis  ticklabel char size 0.8')
21250 format(1x,g13.7,3x,g13.7)
c
21260 format(5x,
     >'* ',f8.3,' < ',f8.3,' *',f6.2,' .',i10,' *',f7.2,' .',i10,' *')
21261 format(5x,
     >'* ',g8.3,' < ',g8.3,' *',f6.2,' .',i10,' *',f7.2,' .',i10,' *')
21262 format(5x,
     >'*', f9.2,' <', f9.2,' *',f6.2,' .',i10,' *',f7.2,' .',i10,' *')
21263 format(5x,
     >'*', g9.2,' <', g9.2,' *',f6.2,' .',i10,' *',f7.2,' .',i10,' *')
21270 format(5x,
     >'* ',f8.3,' <  inf.    *',f6.2,' .',i10,' * 100.00 .',i10,' *')
21280 format(
     >  '#',
     >/,'@g',i1,' on')
c
c 1.2. ==> variables locales
c
      codret = 0
c
      if ( ulxmgr.gt.0 ) then
        prem = .true.
      elseif ( ulxmgr.lt.0 ) then
        prem = .false.
        ulxmgr = - ulxmgr
      else
        codret = 1
      endif
c
c====
c 2. classement
c===
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. classement ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> preparation du classement
c
      do 21 , jaux = 1 , nbclas
        histog(jaux) = 0
   21 continue
c
c 2.2. ==> recherche des extrema et rangement des valeurs en entier
c
      if ( typval.eq.1 ) then
c
        ivamin = ival(1)
        ivamax = ival(1)
c
        do 22 , iaux = 1 , nbval
c
          ivamin = min ( ivamin , ival(iaux) )
          ivamax = max ( ivamax , ival(iaux) )
c
          do 221 , jaux = 1 , nbclas
            if ( ival(iaux).ge.iclass(jaux-1) .and.
     >           ival(iaux).lt.iclass(jaux) ) then
              histog(jaux) = histog(jaux) + 1
              goto 222
            endif
  221     continue
c
  222     continue
c
   22   continue
c
        p10min = 0
        p10max = 0
c
c 2.3. ==> recherche des extrema et rangement des valeurs en reel
c          on elargit temporairement les bornes inferieure, rclass(0),
c          et superieure, rclass(nbclas), pour etre certain de ne rien
c          rater dans le classement.
c
      elseif ( typval.eq.2 ) then
c
        epsilo = 1.d-5*(rclass(nbclas)-rclass(0))
        rclass(0) = rclass(0) - epsilo
        rclass(nbclas) = rclass(nbclas) + epsilo
c
        rvamin = rval(1)
        rvamax = rval(1)
        rvamoy = 0.d0
        rvecty = 0.d0
c
        do 23 , iaux = 1 , nbval
c
          rvamin = min ( rvamin , rval(iaux) )
          rvamax = max ( rvamax , rval(iaux) )
          rvamoy = rvamoy + rval(iaux)
          rvecty = rvecty + rval(iaux)**2
c
          do 231 , jaux = 1 , nbclas
            if ( rval(iaux).ge.rclass(jaux-1) .and.
     >           rval(iaux).lt.rclass(jaux) ) then
              histog(jaux) = histog(jaux) + 1
              goto 232
            endif
  231     continue
c
  232     continue
c
   23   continue
c
        rvamoy = rvamoy / dble(nbval)
        rvecty = sqrt ( rvecty/ dble(nbval) - rvamoy**2 )
#ifdef _DEBUG_HOMARD_
        write (ulsort,90004) 'rvamin', rvamin
        write (ulsort,90004) 'rvamax', rvamax
        write (ulsort,90004) 'rvamoy', rvamoy
        write (ulsort,90004) 'rvecty', rvecty
#endif
c
        rclass(0) = rclass(0) + epsilo
        rclass(nbclas) = rclass(nbclas) - epsilo
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPD10', nompro
#endif
        call utpd10 ( rclass(0), val10, p10min,
     >                ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90024) 'rclass', 0, rclass(0)
      write (ulsort,*) '=> val10  =', val10, ', p10min =', p10min
#endif
c
        if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPD10', nompro
#endif
        call utpd10 ( rclass(nbclas), val10, p10max,
     >                ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90024) 'rclass', nbclas, rclass(nbclas)
      write (ulsort,*) '=> val10       =', val10, ', p10max =', p10max
#endif
        endif
c
c 2.4. ==> erreur sinon
c
      else
c
        codret = 1
c
      endif
c
      endif
c
c====
c 3. Impression sur la sortie standard et sur un fichier
c    a exploiter par xmgrace
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Impression ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nrocou = 0
c
      write (ulbila,10200)
      if ( typval.eq.1 ) then
        write (ulbila,13101) ivamin, ivamax
        p10dec = 0
      else
        write (ulbila,13102) dble(rvamin), dble(rvamax)
        if ( langue.eq.1 ) then
          write (ulbila,13103) dble(rvamoy), dble(rvecty)
        else
          write (ulbila,13203) dble(rvamoy), dble(rvecty)
        endif
        if ( p10max.lt.0 .or. p10max.gt.3 ) then
          p10dec = p10max-1
        elseif ( p10max.eq.0 .and. p10min.lt.-1 ) then
          p10dec = p10min-2
        else
          p10dec = 0
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'p10max', p10max, ', p10min', p10min
      write (ulsort,90002) '==> p10dec', p10dec
#endif
        if ( p10dec.ne.0 ) then
          mess58(langue,4)(4:9) = '* 10**'
          if ( p10dec.le.-100 ) then
            write (mess58(langue,4)(10:13),'(i4)') p10dec
          elseif ( p10dec.le.-10 ) then
            write (mess58(langue,4)(10:12),'(i3)') p10dec
          elseif ( p10dec.le.-1 ) then
            write (mess58(langue,4)(10:11),'(i2)') p10dec
          elseif ( p10dec.le.9 ) then
            write (mess58(langue,4)(10:10),'(i1)') p10dec
          elseif ( p10dec.le.99 ) then
            write (mess58(langue,4)(10:11),'(i2)') p10dec
          else
            write (mess58(langue,4)(10:13),'(i4)') p10dec
          endif
        endif
        if ( abs(p10max-p10min).le.3 ) then
          ecart = .true.
        else
          ecart = .false.
        endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,99001) 'ecart', ecart
#endif
      endif
      write (ulbila,10200)
c
      write (ulbila,11100) mess58(langue,1)
      write (ulbila,11100) mess58(langue,2)
      write (ulbila,11100) mess58(langue,3)
      write (ulbila,11100) mess58(langue,4)
      write (ulbila,10200)
c
      if ( ulxmgr.ne.ulbila ) then
        if ( prem ) then
          write (ulxmgr,21200)
          write (ulxmgr,21210) (titcou(iaux), iaux = 1 , 4 )
          write (ulxmgr,21220) nrocou
          write (ulxmgr,21230)
          write (ulxmgr,21240) xlow, titcou(5)
          write (ulxmgr,21241)
          write (ulxmgr,21280) nrocou
        endif
      endif
c
      if ( typval.eq.1 ) then
        x2 = real(iclass(0))
      else
        x2 = real(rclass(0))
      endif
      if ( ulxmgr.ne.ulbila ) then
        write (ulxmgr,21250) x2, 0.
      endif
      raux1 = x2
cgn      write (ulsort,90004) 'raux1', raux1
c
      iaux= 0
      raux = 100. / real(nbval)
      do 31 , jaux = 1 , nbclas
        x1 = x2
        y1 = real(histog(jaux)) * raux
        if ( typval.eq.1 ) then
          x2 = real(iclass(jaux))
        else
          x2 = real(rclass(jaux))
        endif
        iaux = iaux + histog(jaux)
        y2 = real(iaux) * raux
        if ( raux1.ge.0. ) then
          if ( ecart ) then
            write (ulbila,21260)
     >            x1*10.**(-p10dec), x2*10.**(-p10dec),
     >            y1, histog(jaux), y2, iaux
          else
            write (ulbila,21261)
     >            x1*10.**(-p10dec), x2*10.**(-p10dec),
     >            y1, histog(jaux), y2, iaux
          endif
        else
          if ( ecart ) then
            write (ulbila,21262)
     >            x1*10.**(-p10dec), x2*10.**(-p10dec),
     >            y1, histog(jaux), y2, iaux
          else
            write (ulbila,21263)
     >            x1*10.**(-p10dec), x2*10.**(-p10dec),
     >            y1, histog(jaux), y2, iaux
          endif
        endif
        if ( ulxmgr.ne.ulbila ) then
          write (ulxmgr,21250) x1, y1
          write (ulxmgr,21250) x2, y1
        endif
   31 continue
      if ( ulxmgr.ne.ulbila ) then
        write (ulxmgr,21250) x2, 0.
      endif
c
      if ( iaux.lt.nbval ) then
c
        iaux = nbval - iaux
        y1 = real(iaux) * raux
        write (ulbila,21270) x2*10.**(-p10dec), y1, iaux, nbval
c
      endif
c
      write (ulbila,10200)
c
      endif
c
c====
c 4. la fin
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
ctest      program toto
ctest       implicit none
ctest      integer nbclas, nbval, typval
ctest      parameter (nbclas=30)
ctest      parameter (nbval=100)
ctestc
ctest      integer iclass(0:nbclas), histog(nbclas)
ctest      double precision rclass(0:nbclas)
ctest      double precision xlow
ctest      double precision rval(nbval)
ctest      integer ival(nbval)
ctestc
ctest      integer ulbila, ulxmgr
ctest      integer ulsort, langue, codret
ctest      character*8 titcou(10)
ctestc
ctest      integer n
ctest      rclass(0) = 1.d0
ctest      do 2111 , n = 1 , 10
ctest         rclass(n) = rclass(n-1) + 0.1d0
ctest 2111 continue
ctest      do 2112 , n = 11 , 26
ctest         rclass(n) = rclass(n-1) + 0.5d0
ctest 2112 continue
ctest      rclass(27) = 15.d0
ctest      rclass(28) = 20.d0
ctest      rclass(29) = 50.d0
ctest      rclass(30) = 100.d0
ctestc
ctest      typval = 2
ctest      langue = 1
ctest      ulbila = 41
ctest      ulxmgr = 42
ctest      ulsort = 6
ctest      xlow = 1.d0
ctest      do 12 ,n=1,nbval
ctest        rval(n) = 1.d0 + dble(n)/10.d0
ctest  12  continue
ctest      titcou(1) = '12345678'
ctest      titcou(2) = '9 ... 16'
ctest      titcou(3) = '17 .. 24'
ctest      titcou(4) = '25... 32'
ctest      titcou(5) = '33      '
ctest      titcou(7) = '49      '
ctest      titcou(8) = '57... 64'
ctest      titcou(9) = '65... 72'
ctestc
ctest      call utcrhi ( nbclas, rclass, iclass, histog,
ctest     >                    nbval,  typval,   rval,   ival,
ctest     >                    titcou, xlow, ulbila, ulxmgr,
ctest     >                    ulsort, langue, codret )
ctestc
ctest      end
