      subroutine eslsm1 ( idfmed, nomamd,
     >                    nbchfi, option,
     >                    nbseal, cactal, caetal, cartal,
     >                    nbcham, nocham, nbtosv,
     >                    nbprof, liprof,
     >                    nblopg, lilopg,
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
c  Entree-Sortie - Lecture d'une Solution au format MED - phase 1
c  -      -        -             -                  -           -
c  En sortie, on a des tableaux caracteristiques des champs contenus
c  dans le fichier
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med en entree       .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . nbchfi . e   .   1    . nombre de champs dans le fichier           .
c . option . e   .   1    . 1 : on controle que l'on a les couples (aux.
c .        .     .        . noeuds par element/aux points de Gauss)    .
c .        .     .        . 0 : pas de controle                        .
c . nbseal . e   .    1   . nombre de sequences a lire                 .
c .        .     .        . si -1, on lit tous les champs du fichier   .
c . cactal . e   .8*nbseal. caracteristiques caracteres de chaque      .
c .        .     .        . tableau a lire                             .
c .        .     .        . 1,..,8. nom du champ associe               .
c . caetal . es  .  12 *  . caracteristiques entieres de chaque        .
c .        .     . nbseal . tableau a lire                             .
c .        .     .        . 1. type de support au sens MED             .
c .        .     .        .  -1, si on prend tous les supports         .
c .        .     .        . 2. 2, on prend le dernier pas de temps     .
c .        .     .        .    1, le numero du pas de temps est fourni .
c .        .     .        .    0, sinon                                .
c .        .     .        . 3. numero du pas de temps                  .
c .        .     .        . 4. 2, on prend le dernier numero d'ordre   .
c .        .     .        .    1, le numero d'ordre est fourni         .
c .        .     .        .    0, sinon                                .
c .        .     .        . 5. numero d'ordre                          .
c .        .     .        . 6. 2, on prend le dernier instant          .
c .        .     .        .    1, l'instant est fourni                 .
c .        .     .        .    0, sinon                                .
c .        .     .        . 7. 1, si aux noeuds par elements, 0 sinon, .
c .        .     .        .   -1, si non precise                       .
c .        .     .        . 8. numero du champ noeuds/element associe  .
c .        .     .        . 9. numero du champ associe dans HOMARD     .
c .        .     .        . 10. type d'interpolation                   .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  1 si degre 1, 2 si degre 2, 3 si iso-P2   .
c .        .     .        . 11. 1, s'il fait partie du champ en cours  .
c .        .     .        .    d'examen, 0, sinon                      .
c .        .     .        . 12. type de champ edfl64/edin64            .
c . cartal . e   . nbseal . caracteristiques reelles de chaque         .
c .        .     .        . tableau a lire                             .
c .        .     .        . 1. instant                                 .
c . nbcham .  s  .   1    . nombre de champs a lire                    .
c . nocham .  s  . nbchfi . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . nbtosv .  s  .   1    . nombre total de tableaux de valeurs        .
c . nbprof . es  .   1    . nombre cumule de profils a lire            .
c . liprof .  s  .9*nbrpro. 1-8 : nom du -i-eme profil lu              .
c .        .     .        . 9 : nom de l'objet de type 'Profil' associe.
c . nblopg . es  .   1    . nombre cumule de localisations Gauss a lire.
c . lilopg .  s  .9*nbrlpg. 1-8 : nom de la -i-eme localisation lue    .
c .        .     .        . 9 : nom de l'objet de type 'LocaPG' associe.
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
      parameter ( nompro = 'ESLSM1' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
#include "litme0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "esutil.h"
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer option
      integer nbchfi, nbseal
      integer nbtosv, nbcham
      integer nbprof, nblopg
      integer caetal(12,*)
c
      double precision cartal(*)
c
      character*8 nocham(nbchfi)
      character*8 cactal(*)
      character*8 liprof(*)
      character*8 lilopg(*)
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      integer lmesh, typcha
      integer iaux, jaux, kaux
      integer adnocp, adcaen, adcare, adcaca
      integer nrocha, nbcomp
      integer nbsqch, nbtvlu
      integer adtra1
      integer nbtvch, numdtx
c
      character*8 ntrav1
      character*8 obcham
      character*64 saux64
      character*64 nomcha, nomach
c
      logical alire
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
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
#include "esimpr.h"
c
#include "impr03.h"
c
#include "litmed.h"
c
      nbcham = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '. Debut de '//nompro//', nbseal', nbseal
      write (ulsort,90002) 'Nombre de champs dans le fichier', nbchfi
cgn      write (ulsort,*) '. Premier champ a lire = ',
cgn     >                   cactal(1),cactal(2),cactal(3),cactal(4),
cgn     >                   cactal(5),cactal(6),cactal(7),cactal(8)
#endif
c
c====
c 2. caracterisation des champs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. caracterisation champ ; codret', codret
#endif
c
      nbtosv = 0
c
      if ( codret.eq.0 ) then
c
      do 20 , nrocha = 1 , nbchfi
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,*) ' '
        write (ulsort,*) '.......................................'//
     >                   '.......................................'
        write (ulsort,90002) 'Dans le fichier, champ numero', nrocha
        endif
#endif
c
c 2.1. ==> allocation de la structure decrivant le champ numero nrocha.
c          le nom de la structure est conserve dans obcham
c
        if ( codret.eq.0 ) then
c
        call gmalot ( obcham, 'InfoCham', 0, iaux, codret )
c
        endif
c
c 2.2. ==> nombre de composantes du champ courant
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDNFC', nompro
#endif
        iaux = nrocha
        call mfdnfc ( idfmed, iaux, nbcomp, codret )
c
        endif
c
c 2.3. ==> allocation des tableaux decrivant le champ et ses composantes
c          remarque : ce dimensionnement suppose que :
c                    1. le nom des champs est code sur 64 caracteres
c                    2. le nom des composantes l'est sur 16
c                    3. le nom des unites des composantes l'est sur 16
c                    4. le nom de l'unite du pas de temps l'est sur 16
c
        if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,85)) nbcomp
#endif
c
        call gmecat ( obcham, 1, nbcomp, codre1 )
        iaux = 8 + 4*nbcomp + 2
        call gmaloj ( obcham//'.Nom_Comp', ' ', iaux, adnocp, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
c 2.4. ==> lecture du nom du champ, du maillage associe, du type
c          de champ, des noms et des unites de ses composantes,
c          de l'unite du pas de temps, du nombre de sequences
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDFDI', nompro
#endif
        nomcha = blan64
        iaux = nrocha
        call mfdfdi ( idfmed, iaux,
     >                nomcha, nomach, lmesh, typcha,
     >                smem(adnocp+8), smem(adnocp+8+2*nbcomp),
     >                smem(adnocp+8+4*nbcomp), nbsqch, codret)
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,32)) nomcha
        do 241 , jaux=1,nbcomp
          write(ulsort,texte(langue,54))smem(adnocp+8+2*(jaux-1))//
     >                                  smem(adnocp+8+2*jaux-1)
          write(ulsort,90003) ' unite',
     >            smem(adnocp+8+2*nbcomp+2*(jaux-1))//
     >            smem(adnocp+8+2*nbcomp+2*(jaux-1)+1)
  241   continue
        write(ulsort,90003) 'nomach', nomach
        write(ulsort,90002) 'lmesh ', lmesh
        write(ulsort,90002) 'typcha', typcha
        write(ulsort,90003) 'dtunit', smem(adnocp+8+4*nbcomp)//
     >                                smem(adnocp+8+4*nbcomp+1)
        write(ulsort,90002) 'nbsqch', nbsqch
#endif
c
        endif
c
c 2.5. ==> On ne lit le champ que si le nombre de sequences
c          est non nul. Logique.
c
        if ( codret.eq.0 ) then
c
          if ( nbsqch.gt.0 ) then
            alire = .true.
          else
            alire = .false.
          endif
c
        endif
c
c 2.6. ==> le champ est-il sur le bon maillage ?
c
        if ( alire ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90003) 'Nom de ce champ (nomcha)', nomcha
      write (ulsort,90003) 'Maillage du champ', nomach
      write (ulsort,90003) 'Maillage courant ', nomamd
#endif
c
        call utdich ( nomach, nomamd,
     >                ulsort, langue, codret )
c
        if ( codret.eq.1 .or. codret.eq.2 ) then
          alire = .false.
          codret = 0
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,99001) 'Fin de 2.6. alire', alire
#endif
c
        endif
c
        endif
c
c 2.7. ==> le champ est-il dans la liste des sequences enregistrees ?
c
        if ( alire ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90003) 'Nom de ce champ (nomcha)', nomcha
#endif
c
        if ( nbseal.gt.0 ) then
c
          alire = .false.
          do 27 , iaux = 1 , nbseal
c
            if ( codret.eq.0 ) then
            call uts8ch ( cactal(8*(iaux-1)+1), 64, saux64,
     >                    ulsort, langue, codret )
            endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90064) iaux,
     >                    '-me champ que l''on veut lire : ', saux64
#endif
c
            if ( codret.eq.0 ) then
c
            if ( saux64.eq.nomcha ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,*) '..... ce champ doit etre lu'
#endif
              alire = .true.
              caetal(11,iaux) = 1
            else
              caetal(11,iaux) = 0
            endif
c
            caetal(12,iaux) = typcha
c
            endif
c
#ifdef _DEBUG_HOMARD_
           write (ulsort,90005) 'caetal',
     >     caetal(1,iaux),caetal(2,iaux),caetal(3,iaux),caetal(4,iaux),
     >     caetal(5,iaux),caetal(6,iaux),caetal(7,iaux),
     >     caetal(8,iaux),caetal(9,iaux),caetal(10,iaux),
     >     caetal(11,iaux),caetal(12,iaux)
           write (ulsort,90004) 'cartal', cartal(iaux)
#endif
   27     continue
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,99001) 'Fin de 2.7. alire', alire
#endif
c
        endif
c
        endif
c
c 2.8. ==> on lira le champ, donc on le garde
c
        if ( alire ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 64
        call utchs8 ( nomcha, iaux, smem(adnocp),
     >                ulsort, langue, codret )
c
        endif
c
        endif
c
c 2.9. ==> Nombre de tableaux de valeurs de ce champ ecrits dans le
c          fichier pour toutes les sequences et tous les types
c          geometriques
c
        if ( alire ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLCH1', nompro
#endif
        call eslch1 ( idfmed, nomcha, nbsqch,
     >                nbtmed, litmed,
     >                iaux,
     >                nbtvch, numdtx,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'Nombre total de tableaux de valeurs '//
     >                       'presents (nbtvch)', nbtvch
        write (ulsort,90002) 'Dernier instant (numdtx)', numdtx
#endif
c
        endif
c
        if ( codret.eq.0 ) then
c
         if ( nbtvch.eq.0 ) then
           alire = .false.
         endif
c
        endif
c
        endif
c
c 2.10. ==> description des tableaux de valeurs
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,99001) '2.10. alire', alire
#endif
c
        if ( alire ) then
c
c 2.10.1. ==> allocation des tableaux decrivant les tableaux de valeurs
c            pour chaque tableau du champ
c
        if ( codret.eq.0 ) then
c
        iaux = nbinec * nbtvch
        call gmaloj ( obcham//'.Cham_Ent', ' ', iaux, adcaen, codre1 )
        call gmaloj ( obcham//'.Cham_Ree', ' ',
     >                nbtvch, adcare, codre2 )
        iaux = nbincc * nbtvch
        call gmaloj ( obcham//'.Cham_Car', ' ',
     >                iaux, adcaca, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
        endif
c
c 2.10.2. ==> remplissage des caracteristiques
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLCH2', nompro
#endif
        call eslch2 ( idfmed, nomcha, numdtx, typcha,
     >                nbtmed, litmed,
     >                nbsqch, nbtvch, nbtvlu,
     >                nbcham, nbseal, caetal, cartal,
     >                imem(adcaen), rmem(adcare), smem(adcaca),
     >                nbprof, liprof,
     >                nblopg, lilopg,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) '... nombre total de tableaux de '//
     >                       'valeurs a lire (nbtvlu)', nbtvlu
        call gmprsx (nompro, obcham )
        call gmprsx (nompro, obcham//'.Cham_Ent' )
        call gmprsx (nompro, obcham//'.Cham_Ree' )
        call gmprsx (nompro, obcham//'.Cham_Car' )
#endif
c
        endif
c
        endif
c
c 2.11. ==> gestion de l'objet qui memorise le champ
c 2.11.1. ==> quand on garde le champ, on memorise son nom et on
c             ajuste la taille des tableaux
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,99001) 'Debut de 2.11, alire',alire
        write (ulsort,90002) 'nbcham', nbcham
#endif
c
        if ( alire ) then
c
        if ( codret.eq.0 ) then
c
        nbcham = nbcham + 1
        nocham(nbcham) = obcham
c
        nbtosv = nbtosv + nbtvlu
c
        if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,21000) nbcham, nomcha
        call gmprsx (nompro, obcham )
        call gmprsx (nompro, obcham//'.Nom_Comp' )
        call gmprsx (nompro, obcham//'.Cham_Ent' )
        call gmprsx (nompro, obcham//'.Cham_Ree' )
        call gmprsx (nompro, obcham//'.Cham_Car' )
        endif
#endif
c
        call gmecat ( obcham, 2, nbtvlu, codre1 )
        call gmecat ( obcham, 3, typcha, codre2 )
        call gmmod ( obcham//'.Cham_Ent',
     >               adcaen, nbinec, nbinec, nbtvch, nbtvlu, codre3 )
        call gmmod ( obcham//'.Cham_Ree',
     >               adcare, 1, 1, nbtvch, nbtvlu, codre4 )
        call gmmod ( obcham//'.Cham_Car',
     >               adcaca, nbincc, nbincc, nbtvch, nbtvlu, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nombre cumule de tableaux de '//
     >                       ' valeurs (nbtosv) = ',nbtosv
#endif
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,21000) nbcham, nomcha
21000 format(/,'Champ numero ',i3,' : ',a64,/,18('='),/)
          call gmprsx (nompro, obcham )
          call gmprsx (nompro, obcham//'.Nom_Comp' )
          call gmprsx (nompro, obcham//'.Cham_Ent' )
          call gmprsx (nompro, obcham//'.Cham_Ree' )
          call gmprsx (nompro, obcham//'.Cham_Car' )
          endif
#endif
c
c 2.11.2. ==> N'etant pas lu, le champ est detruit
c
        else
c
          if ( codret.eq.0 ) then
c
          call gmsgoj ( obcham, codret )
c
          endif
c
        endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)
     > nompro//', avant 20 continue, pour nrocha',nrocha
      call dmflsh (iaux)
#endif
c
   20 continue
c
      endif
c
c====
c 3. On parcourt tous les champs enregistres pour memoriser les
c    relations entre les champs aux points de Gauss et leurs
c    homologues aux noeuds par elements
c    il faut traiter dans l'ordre :
c    1. Les champs standards
c    2. Les champs aux points de Gauss
c    3. Les champs aux noeuds par element
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '... Debut de 3., codret', codret
#endif
c
      if ( option.eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      do 33333 , iaux=1,nbtosv
          write (ulsort,*) '... Champ '//cactal(8*iaux-7)//
     >    cactal(8*iaux-6)//cactal(8*iaux-5)//cactal(8*iaux-4)//
     >    cactal(8*iaux-3)//
     >    cactal(8*iaux-2)//cactal(8*iaux-1)//cactal(8*iaux)
          write (ulsort,90005) '.. caetal',
     >    caetal(1,iaux),caetal(2,iaux),caetal(3,iaux),caetal(4,iaux),
     >    caetal(5,iaux),caetal(6,iaux),caetal(7,iaux),
     >    caetal(8,iaux),caetal(9,iaux),caetal(10,iaux),
     >    caetal(11,iaux)
          write (ulsort,90004) '.. cartal',cartal(iaux)
33333 continue
#endif
c
c 3.1. ==> allocation d'un tableau auxiliaire pour memoriser les
c          correspondances
c
      if ( codret.eq.0 ) then
      call gmalot ( ntrav1, 'entier  ', nbcham, adtra1, codret )
      endif
      do 30 , iaux = adtra1 , adtra1+nbcham-1
        imem(iaux) = -1
   30 continue
c
      do 3 , jaux = 1 , 3
c
c 3.2. ==> choix du type de champ a traiter
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,*) '+++++++++++++++++++++++++++++++++++++++++'
      write (ulsort,texte(langue,64+jaux))
#endif
        if ( jaux.eq.1 ) then
          kaux = 0
        elseif ( jaux.eq.2 ) then
          kaux = 2
        else
          kaux = 1
        endif
c
        endif
c
c 3.3. ==> parcours des champs enregistres
c
        do 33 , nrocha = 1 , nbcham
c
c 3.3.1. ==> caracteristiques du champ numero nrocha
c
          if ( codret.eq.0 ) then
c
          obcham = nocham(nrocha)
c
          call gmliat ( obcham, 2, nbtvlu, codre1 )
          call gmadoj ( obcham//'.Cham_Ent', adcaen, iaux, codre2 )
          call gmadoj ( obcham//'.Nom_Comp', adnocp, iaux, codre3 )
c
          codre0 = min ( codre1, codre2, codre3 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3 )
c
          endif
c
          if ( codret.eq.0 ) then
            iaux = 64
            call uts8ch ( smem(adnocp), iaux, nomcha,
     >                    ulsort, langue, codret )
          endif
c
c 3.3.2. ==> appel ad-hoc
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLCH6', nompro
cgn          call gmprsx (nompro, obcham//'.Cham_Ent' )
#endif
          iaux = nrocha
          call eslch6 ( iaux, kaux, nbtvlu, imem(adcaen), nomcha,
     >                  nbtosv, caetal,
     >                  nbcham, imem(adtra1),
     >                  ulsort, langue, codret )
c
          endif
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,31000) nomcha, nrocha
31000 format(/,60('='),/,'Champ ',a,', de numero ',i3,/)
          call gmprsx (nompro, obcham )
          call gmprsx (nompro, obcham//'.Cham_Ent' )
          endif
#endif
c
   33   continue
c
    3 continue
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codret )
c
      endif
c
      endif
c
c====
c 4. controle de la presence des champs demandes
c    on memorise le codret dans la variable jaux
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '... Debut de 4., codret', codret
#endif
c
      jaux = 0
c
      do 4 , iaux = 1 , nbseal
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90005) 'caetal',
     >  caetal(1,iaux),caetal(2,iaux),caetal(3,iaux),caetal(4,iaux),
     >  caetal(5,iaux),caetal(6,iaux),caetal(7,iaux),
     >  caetal(8,iaux),caetal(9,iaux),caetal(10,iaux),
     >  caetal(11,iaux),caetal(12,iaux)
        write (ulsort,90004) 'cartal', cartal(iaux)
        write (ulsort,90122) 'caetal', 9, iaux, caetal(9,iaux)
#endif
c
        if ( caetal(9,iaux).eq.0 ) then
c
          jaux = 1
c
          if ( codret.eq.0 ) then
          call uts8ch ( cactal(8*iaux-7), 64, saux64,
     >                  ulsort, langue, codret )
          endif
          if ( codret.eq.0 ) then
          write (ulsort,texte(langue,32)) saux64
          if ( caetal(2,iaux).gt.0 ) then
            write (ulsort,texte(langue,113)) caetal(3,iaux)
          endif
          if ( caetal(4,iaux).gt.0 ) then
            write (ulsort,texte(langue,114)) caetal(5,iaux)
          endif
          if ( caetal(6,iaux).gt.0 ) then
            write (ulsort,texte(langue,115)) cartal(iaux)
          endif
          write (ulsort,texte(langue,92))
          endif
c
        endif
c
        endif
c
    4 continue
c
      if ( jaux.ne.0 ) then
        codret = 1
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

