      subroutine utb13e ( dimsd, option,
     >                    nbfmed, numfam,
     >                    grfmpo, grfmtl, grfmtb,
     >                    nbgrfm, nomgro, lgnogr,
     >                    famnbv, famnum, famval,
     >                    lifagr,
     >                    ulbila,
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
c    UTilitaire - Bilan sur le maillage - option 13 - phase e
c    --           -                              --         -
c ______________________________________________________________________
c
c impression
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . dimsd  . e   .    1   . dimension du sous-domaine                  .
c . option . e   .    1   . 1 : affichage pour les sous-domaines       .
c .        .     .        . 2 : affichage pour les joints simples      .
c .        .     .        . 3 : affichage pour les joints triples      .
c .        .     .        . 4 : affichage pour les joints quadruples   .
c . nbfmed . e   .    1   . nombre de familles au sens MED             .
c . numfam . e   . nbfmed . numero des familles au sens MED            .
c . grfmpo . e   .0:nbfmed. pointeur des groupes des familles          .
c . grfmtl . e   .   *    . taille des groupes des familles            .
c . grfmtb . e   .10ngrouc. table des groupes des familles             .
c . nbgrfm . e   .    1   . nombre de groupes                          .
c . nomgro . e   .char*(*). noms des groupes (paquets de 10char8)      .
c . lgnogr . e   . nbgrfm . longueur des noms des groupes              .
c . famnbv . e   .   1    . famille : nombre des valeurs               .
c . famnum .  a  .   *    . famille : numero avec une valeur           .
c . famval .  a  .   *    . famille : la valeur                        .
c . lifagr .  a  .   *    . liste des familles contenant le groupe     .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
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
      parameter ( nompro = 'UTB13E' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer dimsd, option
      integer nbfmed, numfam(nbfmed)
      integer grfmpo(0:nbfmed)
      integer grfmtl(*)
      integer nbgrfm, lgnogr(nbgrfm)
      integer famnbv
c
      character*8 grfmtb(*)
      character*8 nomgro(*)
c
      integer famnum(famnbv)
      double precision famval(famnbv)
c
      integer  lifagr(*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer lnogro, nbfgro
      integer nblign
      integer imprgr
c
      logical logaux
c
      double precision daux
      double precision vmin, vmax
c
      character*80 saux80
c
      integer nbmess
      parameter (nbmess = 20 )
      character*80 texte(nblang,nbmess)
      character*8 mess08(nblang,0:3)
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
      texte(1,5) ='(''Nombre de familles :'',i8)'
      texte(1,6) ='(5x,''*'',21x,''Sous-domaines '',i1,''D'',20x,''*'')'
      texte(1,7) = '(5x,''*'',18x,''Numero'',17x,''*   '',a8,''   *'')'
      texte(1,11) ='(5x,''*'',22x,''Joints simples'',22x,''*'')'
      texte(1,12) ='(5x,''*'',22x,''Joints triples'',22x,''*'')'
      texte(1,13) ='(5x,''*'',20x,''Joints quadruples'',19x,''*'')'
c
      texte(2,5) ='(''Number of families :'',i8)'
      texte(2,6) = '(5x,''*'',22x,i1,''D'','' sub-domains'',21x,''*'')'
      texte(2,7) = '(5x,''*'',10x,''#'',20x,''*   '',a8,''   *'')'
      texte(2,11) ='(5x,''*'',20x,''Simple junctions'',21x,''*'')'
      texte(2,12) ='(5x,''*'',20x,''Triple junctions'',21x,''*'')'
      texte(2,13) ='(5x,''*'',19x,''Quadruple junctions'',19x,''*'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
      write (ulsort,texte(langue,5)) nbfmed
      write (ulsort,90002) 'nbgrfm', nbgrfm
      write (ulsort,90002) 'famnbv', famnbv
#endif
c                    12345678
      mess08(1,0) = 'Nom     '
      mess08(1,1) = 'Longueur'
      mess08(1,2) = 'Surface '
      mess08(1,3) = 'Volume  '
c
      mess08(2,0) = 'Name    '
      mess08(2,1) = 'Length  '
      mess08(2,2) = 'Surface '
      mess08(2,3) = 'Volume  '
c
 1100 format(/,5x,59('*'))
 1101 format(  5x,59('*'))
c
 1001 format(5x,'* ',a40,' * ',12x  ,' *')
 1002 format(5x,'* ',a40,' * ',g12.6,' *')
 1003 format(5x,'* Total :',34x,'* ',g12.6,' *')
 1004 format(5x,'* ',a3,'imum :',32x,'* ',g12.6,' *')
 1005 format(5x,'* ',a8,33x,'*  ',a8,'    *')
c
      codret = 0
c
      if ( famnbv.gt.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,91010) (famnum(iaux),iaux=1,famnbv)
      write (ulsort,92010) (famval(iaux),iaux=1,famnbv)
#endif
c
c====
c 2. impression de l'entete
c====
c
      write (ulbila,1100)
      if ( option.eq.1 ) then
        write (ulbila,texte(langue,6)) dimsd
      else
        write (ulbila,texte(langue,9+option))
      endif
      write (ulbila,1101)
c
c====
c 3. parcours des groupes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. parcours des groupes ; codret', codret
#endif
c
      imprgr = 0
c
      nblign = 0
      vmin = famval(1)
      vmax = famval(1)
c
      do 30 , iaux = 1 , nbgrfm
c
c 3.1. ==> Le nom du groupe
c
        if ( codret.eq.0 ) then
c
        lnogro = lgnogr(iaux)
        jaux = 10*(iaux-1) + 1
        call uts8ch ( nomgro(jaux), lnogro, saux80,
     >                ulsort, langue, codret )
cgn        write(ulsort,90003) '. Groupe ', saux80(1:lnogro)
c
        endif
c
c 3.2. ==> Les familles liees a ce groupe
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFMGR', nompro
#endif
        call utfmgr ( saux80, nbfgro, lifagr,
     >                nbfmed, numfam,
     >                grfmpo, grfmtl, grfmtb,
     >                ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) nbfgro
        write (ulsort,91020) (lifagr(jaux), jaux=1,nbfgro)
#endif
c
        endif
c
c 3.3. ==> Cumul des tailles a partir des tailles des mailles
c          par familles
c
        if ( codret.eq.0 ) then
c
        logaux = .false.
        daux = 0.d0
c
        do 33 , jaux = 1 , nbfgro
c
          do 331 , kaux = 1 , famnbv
            if ( famnum(kaux).eq.lifagr(jaux) ) then
              logaux = .true.
              daux = daux + famval(kaux)
            endif
  331     continue
c
   33   continue
c
        endif
c
c 3.3. ==> Impression eventuelle
c
        if ( logaux ) then
c
          if ( codret.eq.0 ) then
c
          if ( imprgr.eq.0 ) then
            write (ulbila,1005) mess08(langue,0), mess08(langue,dimsd)
            write (ulbila,1101)
            imprgr = 1
          endif
c
          if ( lnogro.gt.40 ) then
            write (ulbila,1001) saux80(1:40)
            jaux = 41
          else
            jaux = 1
          endif
          kaux = lnogro - jaux
          if ( kaux.eq.39 ) then
            write (ulbila,1002) saux80(jaux:lnogro), daux
          else
            write (ulbila,1002) saux80(jaux:lnogro)//blan64(1:40-kaux),
     >                          daux
          endif
c
          vmin = min(vmin,daux)
          vmax = max(vmax,daux)
          nblign = nblign + 1
c
          endif
c
        endif
c
   30 continue
c
      if ( imprgr.eq.0 ) then
        write (ulbila,1005) blan08, mess08(langue,dimsd)
      endif
      write (ulbila,1101)
c
c====
c 4. impression finale
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. impression finale ; codret', codret
#endif
c
      daux = 0.d0
      do 40 , iaux = 1 , famnbv
        daux = daux + famval(iaux)
   40 continue
c
      if ( nblign.gt.2 ) then
        write (ulbila,1004) 'Min', vmin
        write (ulbila,1004) 'Max', vmax
        write (ulbila,1101)
      endif
      write (ulbila,1003) daux
      write (ulbila,1101)
c
      endif
c
      end
