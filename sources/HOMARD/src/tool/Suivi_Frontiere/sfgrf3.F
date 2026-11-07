      subroutine sfgrf3 ( nbfseg,
     >                    nbf, nbgrmx, nblign, lgtabl,
     >                    pointl, taigrl, nomgrl,
     >                    pointf, nomgrf, numfam,
     >                    lifami, linugr, ncafdg,
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
c   Suivi de Frontiere - GRoupes de la Frontiere - phase 3
c   -        -           --            -                 -
c remarque : sfgrf2 et sfgrf3 sont des clones
c   Mise a jour de la liste des groupes de segments voulus
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfseg . e   .   1    . nombre de familles de segments             .
c . nbf    . e   .   1    . nombre de familles du maillage frontiere   .
c . nbgrmx . e   .   1    . nombre maxi de groupes dans les familles   .
c . nblign . es  .   1    . nombre de lignes decrites                  .
c . lgtabl . es  .   1    . longueur des tables                        .
c . pointl . e   .0:nblign. pointeur sur le tableau nomgrl             .
c . taigrl . e   .   *    . taille des noms des groupes des lignes     .
c . nomgrl . e   .   *    . noms des groupes des lignes                .
c . pointf . e   . 0:nbf  . pointeur sur le tableau nomgrf             .
c . numfam . e   .   nbf  . numero des familles au sens MED            .
c . nomgrf . e   .   *    . noms des groupes des familles              .
c . lifami . e   . nbfseg . liste des familles a explorer              .
c . linugr .  s  . nblign . numeros des groupes acceptables            .
c . ncafdg . es  . char*8 . nom de l'objet groupes/attributs frontiere .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'SFGRF3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer nbfseg
      integer nbf, nbgrmx, nblign, lgtabl
      integer pointl(0:nbgrmx), pointf(0:nbf), numfam(nbf)
      integer taigrl(*)
      integer lifami(nbfseg), linugr(nblign)
c
      character*8 nomgrl(*), nomgrf(*)
      character*8 ncafdg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, lig, fam
      integer nbgr, gr
      integer lgngrl, lgngrf
      integer nblnew, lgtnew
      integer pointn, pttgrn, ptngrn
c
      character*80 groupl,groupf
      character*8 ntrava
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
      texte(1,4) = '(''Nombre de familles de '',a,'' :'',i8)'
      texte(1,5) =
     >'(''*'',20x,''Elimination de groupe(s) frontiere discrete'',
     >19x,''*'')'
      texte(1,6) =
     >'(''*'',20x,''Tous les groupes sont elimines'',32x,''*'')'
c
      texte(2,4) = '(''Number of families of '',a,'' :'',i8)'
      texte(2,5) =
     >'(''*'',20x,''Elimination of discrete boundary group(s)'',
     >21x,''*'')'
      texte(2,6) =
     >'(''*'',20x,''All the groups are taken off'',34x,''*'')'
c
#include "impr03.h"
c
 1000 format(/)
 1001 format(84('*'))
 1002 format('* ',a80,' *')
c
      codret = 0
c
c 1.2. ==> A priori, aucune ligne voulue n'est acceptable
c
      do 12 , iaux = 1 , nblign
        linugr(iaux) = 0
   12 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbfseg
      write (ulsort,90002) 'lgtabl', lgtabl
      write (ulsort,93080) (nomgrl(iaux),iaux=1,lgtabl)
#endif
c
c====
c 2. on parcourt toutes les familles de mailles du maillage frontiere
c    pour reperer les groupes de la liste qui sont effectivement dans
c    le maillage frontiere
c====
c
cgn      write (ulsort,93080) (nomgrf(iaux),iaux=1,20)
      do 20 , fam = 1, nbf
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90015) 'Famille ', fam, ', de numero', numfam(fam)
#endif
c
c 2.1. ==> la famille est-elle a traiter ?
c
        do 21 , iaux = 1, nbfseg
c
cgn          write (ulsort,90112) 'lifami', iaux, lifami(iaux)
          if ( numfam(fam).eq.lifami(iaux) ) then
            goto 221
          endif
c
   21   continue
c
        goto 20
c
c 2.2. ==> on parcourt tous les groupes entrant dans la
c          definition de cette famille
c
  221   continue
c
        nbgr = (pointf(fam)-pointf(fam-1))/10
c
        do 22 , gr = 1, nbgr
c
c 2.2.1. ==> nom du groupe associe
c            adresse du debut du groupe numero gr de la famille fam
c
          if ( codret.eq.0 ) then
c
          iaux = pointf(fam-1)+1+10*(gr-1)
c
c         recuperation du nom du groupe numero gr dans la famille
c         numero fam
          call uts8ch ( nomgrf(iaux), 80, groupf,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
c         longueur utile du nom du groupe
          call utlgut ( lgngrf, groupf, ulsort, langue, codret )
c
          endif
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,93020) 'groupf', groupf
          write (ulsort,90002) 'lgngrf', lgngrf
#endif
c
c 2.2.2. ==> on cherche si le groupe est deja present dans la liste
c
          do 222 , lig = 1 , nblign
c
            if ( codret.eq.0 ) then
c         adresse du debut du groupe associe a la ligne lig
            iaux = pointl(lig-1) + 1
c
c           recuperation du nom du groupe associe a la ligne lig
            call uts8ch ( nomgrl(iaux), 80, groupl,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
c           longueur utile du nom du groupe
            call utlgut ( lgngrl, groupl, ulsort, langue, codret )
c
            endif
c
c ......... si le groupe de la ligne et le groupe dans la liste
c ......... coincident, on passe au groupe suivant dans la famille
c ......... on note ce groupe
c
            if ( lgngrl.eq.lgngrf ) then
c
              if ( groupl(1:lgngrl).eq.groupf(1:lgngrf) ) then
                linugr(lig) = 1
                goto 22
              endif
c
            endif
c
  222     continue
c
   22   continue
c
        endif
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'linugr'
      write (ulsort,91020) (linugr(iaux),iaux=1,nblign)
#endif
c
c====
c 3. Si au moins un groupe de la liste n'est pas dans le maillage
c    frontiere, il faut recreer cette liste en eliminant ces groupes.
c====
c 3.1. ==> Decompte du nombre de groupes absents
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. Decompte ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nblnew = nblign
      do 31 , iaux = 1 , nblign
        if ( linugr(iaux).eq.0 ) then
          nblnew = nblnew - 1
        endif
   31 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nblnew', nblnew
#endif
c
      if ( nblnew.lt.nblign ) then
c
c 3.2. ==> Allocation de la nouvelle structure
c
        if ( codret.eq.0 ) then
c
        iaux = 0
        jaux = 0
        kaux = nblign - jaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTATPC', nompro
#endif
        call utaptc ( ntrava, iaux, jaux,
     >                kaux, lgtabl,
     >                pointn, pttgrn, ptngrn,
     >                ulsort, langue, codret )
c
        endif
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,ntrava )
cgn      call gmprsx (nompro,ntrava//'.Pointeur' )
cgn      call gmprsx (nompro,ntrava//'.Table' )
cgn      call gmprsx (nompro,ntrava//'.Taille' )
#endif
c
c 3.3. ==> Remplissage de la nouvelle structure
c
        write (ulsort,1000)
        write (ulsort,1001)
        write (ulsort,texte(langue,5))
        write (ulsort,1001)
c
        lgtnew = 0
c
c 3.3.1. ==> Tous les groupes sont absents
c
        if ( nblnew.eq.0 ) then
c
          write (ulsort,texte(langue,6))

c 3.3.2. ==> Au moins un groupe est absent, mais pas tous
c            On transfere les valeurs
c
        else
c
          nblnew = 0
c
          if ( codret.eq.0 ) then
c
          do 33 , lig = 1 , nblign
c
            if ( codret.eq.0 ) then
c
            if ( linugr(lig).ne.0 ) then
#ifdef _DEBUG_HOMARD_
              write(ulsort,90002) 'Transfert ligne', lig
#endif
c
              kaux = pointl(lig) - pointl(lig-1)
cgn              write(ulsort,*) 'kaux', kaux
c
              nblnew = nblnew + 1
              lgtnew = lgtnew + kaux
              jaux = imem(pointn+nblnew-1)
              imem(pointn+nblnew) = jaux + kaux
c
              do 331 , iaux = 1, kaux
                imem(pttgrn+jaux-1+iaux) = taigrl(pointl(lig-1)+iaux)
                smem(ptngrn+jaux-1+iaux) = nomgrl(pointl(lig-1)+iaux)
  331         continue
c
            else
c
c         adresse du debut du groupe associe a la ligne lig
              iaux = pointl(lig-1) + 1
c
c           recuperation du nom du groupe associe a la ligne lig
              call uts8ch ( nomgrl(iaux), 80, groupl,
     >                      ulsort, langue, codret )
c
              write (ulsort,1002) groupl
c
            endif
c
            endif
c
   33     continue
c
          endif
c
        endif
c
        write (ulsort,1001)
c
c 3.4. ==> Ajustement des tailles de la structure
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. Ajustement ; codret', codret
#endif
c 3.4.1. ==> Ajustement de la structure
c
        if ( codret.eq.0 ) then
c
        jaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTATPC', nompro
#endif
        call utaptc ( ntrava, iaux, jaux,
     >                nblnew, lgtnew,
     >                pointn, pttgrn, ptngrn,
     >                ulsort, langue, codret )
c
        endif
c
c 3.4.2. ==> Transfert
c
        if ( codret.eq.0 ) then
c
        call gmlboj ( ncafdg, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        ncafdg = ntrava
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,ncafdg )
      call gmprsx (nompro,ncafdg//'.Pointeur' )
      call gmprsx (nompro,ncafdg//'.Table' )
      call gmprsx (nompro,ncafdg//'.Taille' )
#endif
c
        endif
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
