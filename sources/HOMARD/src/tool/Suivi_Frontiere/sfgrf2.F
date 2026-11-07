      subroutine sfgrf2 ( nbfmed,
     >                    nbf, nbgrmx, nblign, lgtabl,
     >                    pointl, taigrl, nomgrl,
     >                    pointf, nomgrf, numfam,
     >                    lifami,
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
c   Suivi de Frontiere - GRoupes de la Frontiere - phase 2
c   -        -           --            -                 -
c remarque : sfgrf2 et sfgrf3 sont des clones
c   Creation de la liste des groupes de segments du maillage frontiere
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfmed . e   .   1    . nombre de familles de mailles de frontiere .
c . nbf    . e   .   1    . nombre de familles du maillage frontiere   .
c . nbgrmx . e   .   1    . nombre maxi de groupes dans les familles   .
c . nblign .  s  .   1    . nombre de lignes decrites                  .
c . lgtabl .  s  .   1    . longueur des tables                        .
c . pointl .  s  .0:nbgrmx. pointeur sur le tableau nomgrl             .
c . taigrl .  s  .   *    . taille des noms des groupes des lignes     .
c . nomgrl .  s  .   *    . noms des groupes des lignes                .
c . pointf . e   . 0:nbf  . pointeur sur le tableau nomgrf             .
c . numfam . e   .   nbf  . numero des familles au sens MED            .
c . nomgrf . e   .   *    . noms des groupes des familles              .
c . lifami . e   . nbfmed . liste des familles a explorer              .
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
      parameter ( nompro = 'SFGRF2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbfmed
      integer nbf, nbgrmx, nblign, lgtabl
      integer lifami(nbfmed)
      integer pointl(0:nbgrmx), pointf(0:nbf), numfam(nbf)
      integer taigrl(*)
c
      character*8 nomgrl(*), nomgrf(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, lig, fam
      integer nbgr, gr
      integer lgngrl, lgngrf
c
      character*80 groupl,groupf
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
      texte(1,5) = '(/,''Ligne numero '',i5,/,18(''=''))'
      texte(1,6) = '(''. Elle est definie par le groupe : '',a,/)'
c
      texte(2,4) = '(''Number of families of '',a,'' :'',i8)'
      texte(2,5) = '(/,''Line # '',i5,/,12(''=''))'
      texte(2,6) = '(''. It is defined by group : '',a,/)'
c
#include "impr03.h"
c
      codret = 0
c
      nblign = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbfmed
#endif
c
c====
c 2. on parcourt toutes les familles de mailles du maillage frontiere
c    pour enregistrer les groupes du maillage frontiere
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
        do 21 , iaux = 1, nbfmed
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
          write (ulsort,*) '.. groupf = ', groupf
          write (ulsort,*) '.. lgngrf = ', lgngrf
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
c
            if ( lgngrl.eq.lgngrf ) then
c
              if ( groupl(1:lgngrl).eq.groupf(1:lgngrf) ) then
                goto 22
              endif
c
            endif
c
  222     continue
c
c 2.2.3. ==> le groupe est absent de la liste ; on allonge la liste
c
          nblign = nblign + 1
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,5)) nblign
          write (ulsort,texte(langue,6)) groupf(1:lgngrf)
#endif
c
          iaux = pointl(nblign-1) + 1
c
          call utchs8 ( groupf, lgngrf, nomgrl(iaux),
     >                  ulsort, langue, codret )
c
          kaux = (lgngrf-mod(lgngrf,8)) / 8
          do 223 , jaux = 1 , kaux
            taigrl(iaux+jaux-1) = 8
  223     continue
c
          if ( mod(lgngrf,8).ne.0 ) then
            taigrl(iaux+kaux) = mod(lgngrf,8)
            kaux = kaux + 1
          endif
c
          pointl(nblign) = pointl(nblign-1) + kaux
          lgtabl = iaux+kaux-1
c
   22   continue
c
        endif
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
#endif
c
c====
c 3. la fin
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
