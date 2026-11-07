      subroutine utmclc ( nbseal, majsol, nochso,
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
c     UTilitaire : Mot-Cle - Liste des Champs a mettre a jour
c     --           -   -     -         -
c ______________________________________________________________________
c
c but : creer une structure de type ChampMAJ qui memorise les
c       caracteristiques des champs a mettre a jour
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbseal . es  .    1   . En entree :                                .
c .        .     .        . 0 : aucune demande particuliere            .
c .        .     .        . 1 : on a demande la mise a jour de tous    .
c .        .     .        .     les champs                             .
c .        .     .        . En sortie :                                .
c .        .     .        . -1 : tous les champs sont a lire           .
c .        .     .        .  0 : aucun champ n'est a lire              .
c .        .     .        . >0 : nombre de champs a mettre a jour      .
c . majsol .  s  .   1    . conversion de la solution 0 : non, 1 : oui .
c . nochso . es  . char*8 . nom de l'objet qui memorise les champs     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : la configuration est perdue            .
c .        .     .        . 2 : probleme de lecture                    .
c .        .     .        . 8 : Allocation impossible                  .
c .        .     .        . 9 : incoherence de donnees                 .
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
      parameter ( nompro = 'UTMCLC' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer nbseal, majsol
c
      character*8 nochso
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "utliob.h"
c
      integer codre1, codre2, codre3, codre4
      integer codre0
      integer iaux
      integer loptio
      integer numero
      integer nbfich
      integer adcaet, adcact, adcart
      integer adnore, adlono, adpono, adnofi, adnoos
c
      character*8 motcle
      character*200 option
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
c 1.1. ==> tout va bien
c
      codret = 0
c
c 1.2. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) = '(''Nombre de champs a mettre a jour :'',i8)'
      texte(1,11) = '(''La configuration est perdue ?'')'
      texte(1,12) = '(''Probleme de lecture.'')'
      texte(1,18) =
     >'(''Impossible d''''allouer la structure memorisant les choix.'')'
      texte(1,19) =
     > '(''Mise a jour de tous les champs ou de certains ?'')'
c
      texte(2,10) = '(''Number of fields to update :'',i8)'
      texte(2,11) = '(''Configuration is lost ?'')'
      texte(2,12) = '(''Problem while reading.'')'
      texte(2,18) = '(''Structure of choices cannot be allocated.'')'
      texte(2,19) = '(''Updating of all fields or someone ?'')'
c
c====
c 2. recherche du nombre d'occurences du mot-cle
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> on recherche la premiere occurence associe au mot-cle
c
      numero = 1
c
      motcle = mcchno
      call utfin1 ( motcle, numero,
     >              iaux, option, loptio,
     >              ulsort, langue, codre0 )
c
c 2.2. ==> aucune option n'a ete precisee
c
      if ( codre0.eq.2 ) then
c
        codret = 0
c
c 2.3. ==> probleme de lecture
c
      elseif ( codre0.ne.0 ) then
c
        codret = 1
c
c 2.4. ==> on peut y aller
c
      else
c
        codret = 0
c
      endif
c
      if ( codret.ne.0 ) then
        codret = 2
      endif
c
      endif
c
c 2.5. ==> coherence avec la demande globale de mise a jour des champs
c
      if ( codret.eq.0 ) then
c
      if ( nbseal.eq.0 ) then
        nbseal = iaux
      else
        if ( iaux.eq.0 ) then
          nbseal = -1
        else
          codret = 9
        endif
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) nbseal
#endif
c
c====
c 3. Les caracteristiques des champs quand on en lit quelques uns
c====
c
      if ( nbseal.gt.0 ) then
c
c 3.1. ==> on alloue le receptacle des caracteristiques des champs
c
        if ( codret.eq.0 ) then
        call gmalot ( nochso, 'ChampMAJ', 0, iaux, codret )
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 8*nbseal
        call gmecat ( nochso, 1, nbseal, codre1 )
        call gmaloj ( nochso//'.CarCaChp', ' ', iaux, adcact, codre2 )
        iaux = 12*nbseal
        call gmaloj ( nochso//'.CarEnChp', ' ', iaux, adcaet, codre3 )
        iaux = 1*nbseal
        call gmaloj ( nochso//'.CarReChp', ' ', iaux, adcart, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        if ( codret.ne.0 ) then
          codret = 8
        endif
c
        endif
c
c 3.2. ==> adresses des objets GM lies aux noms des fichiers
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD80', nompro
#endif
        call utad80 ( nbfich,
     >                adnore, adlono, adpono, adnofi, adnoos,
     >                ulsort, langue, codret )
c
        endif
c
c 3.3. ==> remplissage des tableaux
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMCC0', nompro
#endif
        call utmcc0 ( nbseal,
     >                imem(adcaet), smem(adcact), rmem(adcart),
     >                nbfich,
     >                smem(adnore), imem(adlono), imem(adpono),
     >                smem(adnofi), smem(adnoos),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( nbseal.gt.0 ) then
cgn      call gmprsx (nompro, nochso )
      call gmprsx (nompro, nochso//'.CarCaChp' )
      call gmprsx (nompro, nochso//'.CarEnChp' )
      call gmprsx (nompro, nochso//'.CarReChp' )
      endif
#endif
c
c====
c 4. consequence sur la conversion de solution
c====
c
      if ( codret.eq.0 ) then
c
c 4.1. ==> pointeur sur la conversion de solution
c
      if ( nbseal.eq.0 ) then
        majsol = 0
      else
        majsol = 1
      endif
c
c 4.2. ==> si tous les champs sont concernes, on met un nom blanc pour
c          la structure de stockage car c'est ainsi que l'on se repere
c          ensuite
c
      if ( nbseal.eq.-1 ) then
c                 12345678
        nochso = '        '
      endif
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
      write (ulsort,texte(langue,10+codret))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
