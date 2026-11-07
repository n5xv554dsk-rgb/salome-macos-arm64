      subroutine vcfia2 ( ngrofi, grfipt, grfitb,
     >                    nbfmed, numfam, grfmpo, grfmtb,
     >                    nbfamd,
     >                    tbxgro, tbxfam,
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
c    aVant adaptation - FIltrage de l'Adaptation - phase 2
c     -                 --            -                  -
c
c    Retourne les numeros des familles MED correspondant
c    aux groupes demandes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ngrofi . e   .    1   . nombre de groupes de filtrage              .
c . grfipt . e   .0:ngrofi. groupes de filtrage - pointeur             .
c . grfitb . e   .   *    . groupes de filtrage - table                .
c . nbfmed . e   .    1   . nombre de familles MED dans le maillage    .
c . numfam . e   . nbfmed . numero MED des familles                    .
c . grfmpo . e   .0:nbfmed. groupes calcul - pointeur                  .
c . grfmtb . e   .   *    . groupes calcul - table                     .
c . nbfamd .   s .   1    . nombre de familles MED concernees          .
c . tbxgro . -   . ngrofi . tableau de travail                         .
c . tbxfam . s   . nbfmed . tableau de travail                         .
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
      parameter ( nompro = 'VCFIA2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer ngrofi, grfipt(0:ngrofi)
      integer nbfmed, numfam(nbfmed), grfmpo(0:nbfmed)
      integer nbfamd
      integer tbxgro(ngrofi), tbxfam(nbfmed)
c
      character*8 grfitb(*)
      character*8 grfmtb(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer fam, nbgr, gr
      integer lgngrf, lggrfi
      integer nugrfi
c
      character*80 groupf
      character*200 sau200
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
      texte(1,4) = '(/,''Famille MED numero'',i10)'
      texte(1,5) = '(''. Groupe'',i5,'' : '',a)'
      texte(1,6) = '(a,''Groupe de filtrage : '',a)'
      texte(1,7) =
     >'(5x,''Attention : ce groupe est inconnu dans le maillage.'')'
      texte(1,8) = '(''Nombre de familles MED concernees :'',i10)'
      texte(1,9) = '(''Numero de ces familles :'')'
      texte(1,10) = '(''... Le groupe a ete trouve dans la famille.'')'
c
      texte(2,4) = '(/,''MED family #'',i10)'
      texte(2,5) = '(''. Group'',i5,'': '',a)'
      texte(2,6) = '(a,''Filtering group: '',a)'
      texte(2,7) =
     >'(5x,''Warning : this group is not known in the mesh.'')'
      texte(2,8) = '(''Number of MED families in cause:'',i10)'
      texte(2,9) = '(''# of those families:'')'
      texte(2,10) = '(''... The group was found into the family.'')'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. a priori, aucun groupe n'a ete repere
c====
c
      do 21 , nugrfi = 1 , ngrofi
        tbxgro(nugrfi) = 0
   21 continue
c
c====
c 3. Recherche des familles MED concernees
c    Remarque : le decodage est analogue a celui de vcsffl
c====
c
      if ( codret.eq.0 ) then
c
      nbfamd = 0
c
c 3.1. ==> on parcourt toutes les familles MED du maillage
c
      do 31 , fam = 1 , nbfmed
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) fam
#endif
c
        nbgr = (grfmpo(fam)-grfmpo(fam-1))/10
c
c 3.1.1. ==> on parcourt tous les groupes entrant dans la
c            definition de la famille
c
        do 311 , gr = 1, nbgr
c
c 3.1.1.1. ==> nom du groupe associe
c             adresse du debut du groupe numero gr de la famille fam
          iaux = grfmpo(fam-1)+1+10*(gr-1)
c
          if ( codret.eq.0 ) then
c
c         recuperation du nom du groupe numero gr dans la famille
c         numero fam
          call uts8ch ( grfmtb(iaux), 80, groupf,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
c         longueur utile du nom du groupe
          call utlgut ( lgngrf, groupf, ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,5)) gr, groupf(1:lgngrf)
#endif
          endif
c
c 3.1.1.2. ==> on parcourt tous les groupes designes pour le filtrage
c
          if ( codret.eq.0 ) then
c
          do 3112 , nugrfi = 1 , ngrofi
c
c 3.1.1.2.1. ==> nom du groupe associe
c
            if ( codret.eq.0 ) then
c
            jaux = grfipt(nugrfi-1) + 1
            call uts8ch ( grfitb(jaux), 200, sau200,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
            call utlgut ( lggrfi, sau200, ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,6)) '.. ', sau200(1:lggrfi)
#endif
c
            endif
c
c 3.1.1.2.2. ==> est-ce le meme ?
c                si oui on memorise le numero de cette famille MED
c
            if ( codret.eq.0 ) then
c
            if ( lgngrf.eq.lggrfi ) then
c
              if ( groupf(1:lgngrf).eq.sau200(1:lggrfi) ) then
#ifdef _DEBUG_HOMARD_
                write (ulsort,texte(langue,10))
#endif
                tbxgro(nugrfi) = tbxgro(nugrfi) + 1
                do 3113 , jaux = 1 , nbfamd
                  if ( tbxfam(jaux).eq.numfam(fam) ) then
                    goto 3112
                  endif
 3113           continue
                nbfamd = nbfamd + 1
                tbxfam(nbfamd) = numfam(fam)
              endif
c
            endif
c
            endif
c
 3112     continue
c
          endif
c
  311   continue
c
   31 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) nbfamd
      write (ulsort,texte(langue,9))
      write (ulsort,91020) (tbxfam(iaux), iaux=1,nbfamd)
#endif
c
      endif
c
c====
c 4. Information
c====
c
      do 41 , nugrfi = 1 , ngrofi
c
        if ( codret.eq.0 ) then
c
        jaux = grfipt(nugrfi-1) + 1
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) nugrfi, grfitb(jaux)//' ...'
#endif
c
        call uts8ch ( grfitb(jaux), 200, sau200,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call utlgut ( lggrfi, sau200, ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,6)) ' ', sau200(1:lggrfi)
        if ( tbxgro(nugrfi).eq.0 ) then
          write (ulsort,texte(langue,7))
        endif
c
        endif
c
   41 continue
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
