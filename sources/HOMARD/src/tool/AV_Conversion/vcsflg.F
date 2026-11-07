      subroutine vcsflg ( nbfron, nbf,
     >                    pointl, taigrl, nomgrl,
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
c                     - Lien famille/ligne.surface - par les Groupes
c                       -                                    -
c ______________________________________________________________________
c
c  Chaque element de frontiere (ligne ou surface) dont on demande le
c  suivi est designe par son nom.
c  On passe en revue toutes les familles du maillage MED. Quand
c  le nom du groupe lie a une frontiere apparait dans la description
c  des groupes definissant la famille, on indique que la famille est
c  liee a la frontiere  courante. La sortie est donc un tableau donnant
c  pour chaque famille MED l'eventuel numero de frontiere qui lui
c  correspond.
c  remarque : vcsflg et vcsfll sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfron . e   .   1    . nombre de frontieres decrites              .
c . nbf    . e   .   1    . nombre de familles du maillage de calcul   .
c . pointl . e   .0:nbfron. pointeur sur le tableau nomgrl             .
c . taigrl . e   .   *    . taille des noms des groupes des frontieres .
c . nomgrl . e   .   *    . noms des groupes des frontieres            .
c . pointf . e   . 0:nbf  . pointeur sur le tableau nomgrf             .
c . nomgrf . e   .   *    . noms des groupes des familles              .
c . numfam . e   .   1    . numero MED des familles                    .
c . nomfam . e   . 10*nbf . nom des familles MED                       .
c . frofam .  s  .  nbf   . donne l'eventuel numero de frontiere       .
c .        .     .        . associee a chaque famille MED              .
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
      parameter ( nompro = 'VCSFLG' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbfron, nbf
      integer numfam(nbf)
      integer frofam(nbf), decala
      integer pointl(0:nbfron), pointe(0:nbf)
      integer taigrl(*)
c
      character*8 nomgrl(*)
      character*8 nomgrf(*)
      character*8 nomfam(10,nbf)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, nufro, fam
      integer nbgr, gr
      integer lgngro, lgngrm
c
      character*64 saux64
      character*80 nomgro, groupm
c
      integer nbmess
      parameter ( nbmess = 11 )
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
      texte(1,4) = '(/,''Frontiere numero '',i5,/,16(''=''))'
      texte(1,5) = '(''. Elle est definie sur le groupe : '',a)'
      texte(1,6) = '(7x,''. Comparaison avec le groupe : '',a)'
      texte(1,7) =
     > '(''.'',i5,''-eme famille, de numero MED '',i5,'', de nom '',a)'
      texte(1,8) =
     > '(''Cette famille est deja liee a la frontiere '',i5)'
      texte(1,9) = '(''On veut ajouter le groupe : '',a)'
      texte(1,10) =
     > '(i5,'' probleme(s) dans la definition des frontieres.'')'
      texte(1,11) = '(7x,''. Cette famille correspond'')'
c
      texte(2,4) = '(/,''Boundary #'',i5,/,12(''=''))'
      texte(2,5) = '(''. It is defined on group: '',a)'
      texte(2,6) = '(7x,''. Comparizon with group: '',a)'
      texte(2,7) = '(''.'',i5,''-th family, MED # '',i5,'', name '',a)'
      texte(2,8) =
     > '(''This family is already connected to boundary'',i5)'
      texte(2,9) = '(''Group : '',a,'' is to be added.'')'
      texte(2,10) = '(i5,'' problem(s) in boundary definition'')'
      texte(2,11) = '(7x,''. This family matches.'')'
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
      do 10 , nufro = 1, nbfron
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,texte(langue,4)) nufro
        endif
#endif
c
c====
c 3. Nom du groupe associe a ce lien
c====
c
        if ( codret.eq.0 ) then
c
c       adresse du debut du groupe associe a la frontiere nufro
        iaux = pointl(nufro-1) + 1
c
c       longueur utile du nom du groupe
        lgngro = 0
        do 31 , jaux = iaux , pointl(nufro)
          lgngro = lgngro + taigrl(jaux)
   31   continue
c
        endif
c
        if ( codret.eq.0 ) then
c
c       recuperation du nom du groupe associe a la frontiere nufro
        call uts8ch ( nomgrl(iaux), lgngro, nomgro,
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
     >          fam, numfam(fam), saux64(1:jaux)
#endif
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
                  frofam(fam) = nufro + decala
#ifdef _DEBUG_HOMARD_
                  write (ulsort,texte(langue,11))
#endif
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
c
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
   10 continue
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
c 5. la fin
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
