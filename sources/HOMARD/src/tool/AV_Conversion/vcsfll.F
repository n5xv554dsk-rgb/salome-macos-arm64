      subroutine vcsfll ( nbfrgr, nbfran, nbf,
     >                    cacfpo, cacfta, cacfnm,
     >                    calfpo, calfta, calfnm,
     >                    calgpo, calgta, calgnm,
     >                    pointe, nomgrf, numfam, nomfam,
     >                    frofam, decala,
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
c    aVant adaptation - Conversion - Suivi de Frontiere
c     -                 -            -        -
c                     - Lien famille/ligne.surface - par les Liens
c                       -                                    -
c ______________________________________________________________________
c
c  Chaque element de frontiere (ligne ou surface) dont on demande le
c  suivi est designe par son nom.
c  On passe en revue toutes les familles du maillage MED. Quand
c  le nom du groupe lie a une frontiere apparait dans la description
c  des groupes definissant la famille, on indique que la famille est
c  liee a la frontiere  courante. La sortie est donc un tableau donnant
c  pour chaque famille l'eventuel numero de frontiere qui lui
c  correspond.
c  remarque : vcsflg et vcsfll sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfrgr . e   .    1   . nombre de liens frontiere/groupe           .
c . nbfran . e   .    1   . nombre de frontieres analytiques           .
c . nbf    . e   .   1    . nombre de familles du maillage de calcul   .
c . cacfpo . e   .0:nbfran. pointeurs sur le tableau du nom frontieres .
c . cacfta . e   .10nbfran. taille du nom des frontieres               .
c . cacfnm . e   .10nbfran. nom des frontieres                         .
c . calfpo . e   .0:nbfrgr. pointeurs sur le tableau du nom frontieres .
c . calfta . e   .10nbfrgr. taille du nom des frontieres               .
c . calfnm . e   .10nbfrgr. nom des frontieres                         .
c . calgpo . e   .0:nbfrgr. pointeurs sur le tableau du nom groupes    .
c . calgta . e   .10nbfrgr. taille du nom des groupes                  .
c . calgnm . e   .10nbfrgr. nom des groupes                            .
c . pointf . e   . 0:nbf  . pointeur sur le tableau nomgrf             .
c . nomgrf . e   .   *    . noms des groupes des familles              .
c . numfam . e   .   1    . numero MED des familles                    .
c . nomfam . e   . 10*nbf . nom des familles MED                       .
c . frofam .  s  .  nbf   . donne l'eventuel numero de frontiere       .
c .        .     .        . associee a chaque famille                  .
c . decala . e   .   1    . decalage dans le stockage des numeros de fr.
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon probleme                             .
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
      parameter ( nompro = 'VCSFLL' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbfrgr, nbfran, nbf
      integer numfam(nbf)
      integer frofam(nbf), decala
      integer cacfpo(0:nbfran), cacfta(10*nbfran)
      integer calfpo(0:nbfrgr), calfta(10*nbfrgr)
      integer calgpo(0:nbfrgr), calgta(10*nbfrgr)
      integer pointe(0:nbf)
c
      character*8 cacfnm(10*nbfran)
      character*8 calfnm(10*nbfrgr)
      character*8 calgnm(10*nbfrgr)
      character*8 nomgrf(*)
      character*8 nomfam(10,nbf)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nufrgr, fam, nufr
      integer nbgr, gr
      integer lgngro, lgngrm, lgnfro, lgnfra
c
      character*64 saux64
      character*80 nomgro, groupm, nomfro, nomfra
c
      integer nbmess
      parameter ( nbmess = 15 )
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
      texte(1,4) =
     > '(/,''Lien frontiere/groupe numero '',i5,/,21(''=''))'
      texte(1,5) = '(''. Nom du groupe : '',a)'
      texte(1,6) = '(''.. Comparaison avec le groupe : '',a)'
      texte(1,7) =
     > '(''.'',i5,''-eme famille, de numero MED '',i5,'', de nom '',a)'
      texte(1,8) =
     > '(''Cette famille est deja liee a la frontiere '',i5)'
      texte(1,9) = '(''On veut ajouter le groupe : '',a)'
      texte(1,10) =
     > '(i5,'' probleme(s) dans la definition des frontieres.'')'
      texte(1,11) = '(''. Nom de la frontiere : '',a)'
      texte(1,12) = '(''.. Nom de la frontiere numero '',i5,'' : '',a)'
      texte(1,13) =
     > '(/,''Impossible de trouver la definition de la frontiere.'')'
c
      texte(2,4) = '(/,''Link boundary/group #'',i5,/,12(''=''))'
      texte(2,5) = '(''. Name of the group: '',a)'
      texte(2,6) = '(''.. Comparizon with the group: '',a)'
      texte(2,7) = '(''.'',i5,''-th family, MED # '',i5,'', name '',a)'
      texte(2,8) =
     > '(''This family is already connected to boundary'',i5)'
      texte(2,9) = '(''Group : '',a,'' is to be added.'')'
      texte(2,10) = '(i5,'' problem(s) in boundary definition'')'
      texte(2,11) = '(''. Name of the boundary: '',a)'
      texte(2,12) = '(''. Name of the boundary # '',i5,'': '',a)'
      texte(2,13) =
     > '(/,''The definition of this boundary cannot be found.'')'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. a priori, aucune famille n'est liee a une frontiere
c====
c
      do 21 , iaux = 1, nbf
        frofam(iaux) = 0
   21 continue
c
c On parcourt tous les liens frontiere/groupe
c          Remarque : le decodage est analogue a celui de vcfia2
c
      do 30 , nufrgr = 1, nbfrgr
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,texte(langue,4)) nufrgr
        endif
#endif
c
c====
c 3. Nom du groupe associe a ce lien
c====
c
        if ( codret.eq.0 ) then
c
c       adresse du debut du groupe associe au lien nufrgr
        iaux = calgpo(nufrgr-1) + 1
c
c       longueur utile du nom du groupe
        lgngro = 0
        do 31 , jaux = iaux , calgpo(nufrgr)
          lgngro = lgngro + calgta(jaux)
   31   continue
c
        endif
c
        if ( codret.eq.0 ) then
c
c       recuperation du nom du groupe associe au lien nufrgr
        call uts8ch ( calgnm(iaux), lgngro, nomgro,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) nomgro(1:lgngro)
#endif
c
c====
c 4. On parcourt toutes les familles de mailles
c====
c
        if ( codret.eq.0 ) then
c
        do 40 , fam = 1, nbf
c
          if ( numfam(fam).lt.0 ) then
c
          nbgr = (pointe(fam)-pointe(fam-1))/10
c
c 4.1. ==> on parcourt tous les groupes entrant dans la
c              definition de la famille
c
          do 41 , gr = 1, nbgr
c
c 4.1.1. ==> nom du groupe
c
            if ( codret.eq.0 ) then
c
c           adresse du debut du groupe numero gr de la famille fam
            iaux = pointe(fam-1)+1+10*(gr-1)
c
c           recuperation du nom du groupe numero gr dans la famille
c           numero fam
            call uts8ch ( nomgrf(iaux), 80, groupm,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
c           longueur utile du nom du groupe
            call utlgut ( lgngrm, groupm, ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,6)) groupm(1:lgngrm)
#endif
c
            endif
c
c 4.1.2. ==> si le groupe de la frontiere et le groupe courant
c            coincident, on declare que la famille est concernee par
c            cette frontiere
c            On doit chercher le nom de la frontiere dans le lien, puis
c            le rang de cette frontiere dans leurs descriptions
c            attention, on n'autorise qu'une seule frontiere par famille
c
            if ( codret.eq.0 ) then
c
            if ( lgngro.eq.lgngrm ) then
c
              if ( nomgro(1:lgngro).eq.groupm(1:lgngrm) ) then
c
                if ( frofam(fam).eq.0 ) then
c
c 4.1.2.1. ==> nom de la frontiere associee a ce lien
c
                  if ( codret.eq.0 ) then
c
c                 adresse du debut de frontiere associee au lien nufrgr
                  iaux = calfpo(nufrgr-1) + 1
c
c                 longueur utile du nom de la frontiere
                  lgnfro = 0
                  do 4121 , jaux = iaux , calfpo(nufrgr)
                    lgnfro = lgnfro + calfta(jaux)
 4121             continue
c
c              recuperation du nom de frontiere associee au lien nufrgr
                  call uts8ch ( calfnm(iaux), lgnfro, nomfro,
     >                          ulsort, langue, codret )
c
                  endif
c
#ifdef _DEBUG_HOMARD_
                 write (ulsort,texte(langue,11)) nomfro(1:lgnfro)
#endif
c
c 4.1.2.2. ==> on parcourt toutes les frontieres decrites
c
                  do 4122 , nufr = 1, nbfran
c
                    if ( codret.eq.0 ) then
c
                    iaux = cacfpo(nufr-1) + 1
c
c                 longueur utile du nom de la frontiere
                    lgnfra = 0
                    do 41221 , jaux = iaux , cacfpo(nufr)
                      lgnfra = lgnfra + cacfta(jaux)
41221               continue
c
c           recuperation du nom du groupe numero gr dans la famille
                    call uts8ch ( cacfnm(iaux), lgnfra, nomfra,
     >                            ulsort, langue, codret )
c
                    endif
c
#ifdef _DEBUG_HOMARD_
                  write (ulsort,texte(langue,12)) nufr, nomfra(1:lgnfra)
#endif
c
                    if ( lgnfro.eq.lgnfra ) then
                      if ( nomfro(1:lgnfro).eq.nomfra(1:lgnfra) ) then
                        goto 41222
                      endif
                    endif
 4122             continue
c
                  write (ulsort,texte(langue,13))
                  write (ulsort,texte(langue,5)) groupm(1:lgngrm)
                  write (ulsort,texte(langue,11)) nomfro(1:lgnfro)
                  codret = codret + 1
c
41222             continue
c
                  if ( codret.eq.0 ) then
                    frofam(fam) = nufr + decala
#ifdef _DEBUG_HOMARD_
                  saux64( 1: 8) = nomfam(1,fam)
                  saux64( 9:16) = nomfam(2,fam)
                  saux64(17:24) = nomfam(3,fam)
                  saux64(25:32) = nomfam(4,fam)
                  saux64(33:40) = nomfam(5,fam)
                  saux64(41:48) = nomfam(6,fam)
                  saux64(49:56) = nomfam(7,fam)
                  saux64(57:64) = nomfam(8,fam)
                  call utlgut ( jaux, saux64, ulsort, langue, codret )
                  write (ulsort,texte(langue,7))
     >                   fam, numfam(fam), saux64(1:jaux)
#endif
                  endif
                else
                  saux64( 1: 8) = nomfam(1,fam)
                  saux64( 9:16) = nomfam(2,fam)
                  saux64(17:24) = nomfam(3,fam)
                  saux64(25:32) = nomfam(4,fam)
                  saux64(33:40) = nomfam(5,fam)
                  saux64(41:48) = nomfam(6,fam)
                  saux64(49:56) = nomfam(7,fam)
                  saux64(57:64) = nomfam(8,fam)
                  call utlgut ( jaux, saux64, ulsort, langue, codret )
                  write (ulsort,texte(langue,7))
     >                   fam, numfam(fam), saux64(1:jaux)
                  write (ulsort,texte(langue,8)) frofam(fam)
                  write (ulsort,texte(langue,9)) groupm(1:lgngrm)
                  codret = codret + 1
                endif
              endif
c
            endif
c
            endif
c
   41     continue
c
          endif
c
   40   continue
c
        endif
c
   30 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      do 3000 , iaux = 1, nbf
       write (ulsort,90112) 'frofam', iaux, frofam(iaux)
 3000 continue
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
      write (ulsort,texte(langue,10)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
