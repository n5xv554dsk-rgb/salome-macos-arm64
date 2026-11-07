      subroutine eslch1 ( idfmed, nomcha, nbsqch,
     >                    nbtmed, litmed,
     >                    option,
     >                    nbtvch, numdtx,
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
c  Entree-Sortie - Lecture d'un CHamp au format MED - phase 1
c  -      -        -            --                          -
c
c  Recuperation pour le champ a lire :
c  - du nombre total de tableaux ecrits dans le fichier pour toutes
c    les sequences et tous les types geometriques
c  - du dernier instant des sequences enregistrees, comme etant celui
c    de plus grand numero de pas de temps
c  Affichage eventuel
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med en entree       .
c . nomcha . e   . char64 . nom du champ a lire                        .
c . nbsqch . e   .   1    . nombre de sequences associees a ce champ   .
c . nbtmed . e   .   1    . nombre de types MED                        .
c . litmed . e   .0:nbtmed. liste des types MED                        .
c . option . e   .   1    . 0 : lecture et calcul de nbtvch/numdtx     .
c .        .     .        . 1 : lecture et affichage                   .
c . nbtvch .  s  .    1   . nombre total de tableaux pour le champ     .
c . numdtx .  s  .    1   . numero du dernier pas de temps             .
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
      parameter ( nompro = 'ESLCH1' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer nbsqch, nbtmed
      integer litmed(0:nbtmed)
      integer option
      integer nbtvch, numdtx
c
      character*64 nomcha
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer typent, typgeo
      integer numseq
      integer numdt, numit
      integer nrtmed
c
      character*64 nolopg
      character*64 noprof
c
      double precision instan
c
      logical afaire
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
      texte(1,4) = '(''Lecture d''''un nouveau profil.'')'
c
      texte(2,4) = '(''Readings of a new profile.'')'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,32)) nomcha
      write (ulsort,90002) 'Nombre total de sequences  (nbsqch)',nbsqch
      write (ulsort,90002) 'Option', Option
#endif
c
c====
c 2. On parcourt les sequences
c====
c
      nbtvch = 0
      numdtx = ednodt
c
      do 20 , numseq = 1, nbsqch
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '----- Sequence numero', numseq
#endif
c
c====
c 2. Recuperation du pas de temps et numero d'iteration de la sequence
c====
c
        if ( codret.eq.0 ) then
c
        iaux = numseq
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MFDCSI', nompro
#endif
        call mfdcsi ( idfmed, nomcha, iaux,
     >                numdt, numit, instan, codret )
        if ( codret.ne.0 ) then
          write (ulsort,texte(langue,17)) nomcha
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,113)) numdt
        write (ulsort,texte(langue,114)) numit
        write (ulsort,texte(langue,115)) instan
#endif
c
        afaire = .true.
c
        endif
c
c====
c 3. On parcourt tous les types de supports
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. On parcourt ; codret', codret
#endif
c
        do 30 , nrtmed = 0 , 2*nbtmed
c
c 3.1. ==> Le couple (typent,typgeo)
c
          if ( codret.eq.0 ) then
c
          if ( nrtmed.eq.0 ) then
            typent = ednoeu
            typgeo = litmed(nrtmed)
          elseif ( nrtmed.le.nbtmed ) then
            typent = edmail
            typgeo = litmed(nrtmed)
          else
            typent = ednoma
            typgeo = litmed(nrtmed-nbtmed)
          endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,texte(langue,60)) typent
      write (ulsort,texte(langue,64)) typgeo
#endif
c
          endif
c
c 3.2. ==> Nombre de profils pour cette sequence et cette entite
c          Remarque : cela indique si des valeurs ont ete enregistrees
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDNPF', nompro
#endif
          call mfdnpf ( idfmed, nomcha,
     >                  numdt, numit, typent, typgeo,
     >                  noprof, nolopg, iaux, codret )
c
          if ( codret.ne.0 ) then
            write (ulsort,texte(langue,60)) typent
            write (ulsort,texte(langue,64)) typgeo
            write (ulsort,texte(langue,2)) codret
          endif
c
          endif
c
c 3.3. ==> Diagostic pour ce couple (typent,typgeo)
c  0 profil : aucune valeur n'est presente ; on passe au couple suivant
c >1 profil : HOMARD ne sait pas faire
c  1 profil : impeccable.
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,86)) iaux
      if ( iaux.eq.1 ) then
        write (ulsort,texte(langue,61)) noprof
      endif
      write (ulsort,texte(langue,81)) nolopg
#endif
c
          if ( iaux.eq.0 ) then
            goto 30
          elseif ( iaux.gt.1 ) then
            write (ulsort,texte(langue,60)) typent
            write (ulsort,texte(langue,64)) typgeo
            write (ulsort,texte(langue,86)) iaux
            codret = 33
          endif
c
          endif
c
c 3.4. ==> Un profil et un seul :
c 3.4.1.  ==> En vue de la lecture :
c          . cumul du nombre total de tableaux
c          . reperage du dernier pas de temps
c
          if ( option.eq.0 ) then
c
            if ( codret.eq.0 ) then
c
            nbtvch = nbtvch + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'numdt', numdt
#endif
            if ( numdt.ne.ednodt ) then
c
                numdtx = max(numdtx,numdt)
c
            endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbtvch', nbtvch
      write (ulsort,90002) 'numdtx', numdtx
#endif
c
            endif
c
c 3.4.2.  ==> Pour affichage
c
          elseif ( option.eq.1 ) then
c
            if ( codret.eq.0 ) then
c
            if ( afaire ) then
              write (ulsort,*) ' '
              if ( numdt.ne.ednodt ) then
                write (ulsort,texte(langue,113)) numdt
                write (ulsort,texte(langue,114)) numit
                write (ulsort,texte(langue,115)) instan
cgn              else
cgn                write (ulsort,texte(langue,119))
              endif
              afaire = .false.
            endif
c
            write (ulsort,texte(langue,64)) typgeo
c
            endif
c
          endif
c
   30   continue
c
   20 continue
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
