      subroutine utmczr ( ncazor, nbzord,
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
c     UTilitaire : Mot-Cle - caracterisation des Zones a Raffiner
c     --           -   -                         -       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ncazor . es  . char*8 . nom de l'objet des zones a raffiner        .
c . nbzord .  s  .    1   . nombre de zones a raffiner/deraffiner      .
c .        .     .        . si negatif, les zones sont 2D (en x et y)  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : la configuration est perdue            .
c .        .     .        . 2 : probleme de lecture                    .
c .        .     .        . 8 : Allocation impossible                  .
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
      parameter ( nompro = 'UTMCZR' )
c
#include "nblang.h"
#include "motcle.h"
c
      integer nbmcle
      parameter ( nbmcle = 20 )
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
      integer nbzord
c
      character*8 ncazor
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "utliob.h"
c
      integer codre0
      integer iaux, jaux
      integer loptio
      integer numero
      integer nbfich
c
      integer adnore, adlono, adpono, adnofi, adnoos
      integer adzord
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
      texte(1,4) = '(''Nombre de zones a raffiner :'',i8)'
      texte(1,9) = '(''Le mot-cle '',a,'' apparait :'',i8,'' fois.'')'
      texte(1,11) = '(''La configuration est perdue ?'')'
      texte(1,12) = '(''Probleme de lecture.'')'
      texte(1,13) = '(''Donnees incoherentes.'')'
      texte(1,18) =
     >'(''Impossible d''''allouer la structure memorisant les choix.'')'
c
      texte(2,4) = '(''Number of zones to refine :'',i8)'
      texte(2,9) = '(''Keyword '',a,'' appears :'',i8,'' times.'')'
      texte(2,11) = '(''Configuration is lost ?'')'
      texte(2,12) = '(''Problem while reading.'')'
      texte(2,13) = '(''Data without coherence.'')'
      texte(2,18) = '(''Structure of choices cannot be allocated.'')'
c
c====
c 2. recherche du nombre d'occurences du mot-cle de type
c    Le nombre de zones de raffinement est egal au nombre de
c    fois ou un type a ete declare
c====
c
      if ( codret.eq.0 ) then
c
      motcle = mczrty
      numero = 1
c
      call utfin1 ( motcle, numero,
     >              jaux, option, loptio,
     >              ulsort, langue, codre0 )
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) motcle, jaux
#endif
c
c 2.2. ==> aucune option n'a ete precisee
c
      if ( codre0.eq.2 ) then
c
        jaux = 0
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
c 2.5. ==> bilan
c
      if ( codret.eq.0 ) then
c
        nbzord = jaux
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nbzord
#endif
      else
        codret = 2
      endif
c
      endif
c
c====
c 3. on alloue le receptacle des caracteristiques des zones
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Allocation ; codret = ', codret
#endif
c
      if ( nbzord.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = nbzord*nbmcle
        call gmalot ( ncazor, 'reel    ', iaux, adzord, codret )
c
        endif
c
      endif
c
c====
c 4. recherche des adresses des objets GM lies aux noms des fichiers
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Recherche ; codret = ', codret
#endif
c
      if ( nbzord.ne.0 ) then
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
      endif
c
c====
c 5. remplissage des tableaux
c====
c
      if ( nbzord.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMCZ0', nompro
#endif
        call utmcz0 ( nbzord, rmem(adzord),
     >                nbfich,
     >                smem(adnore), imem(adlono), imem(adpono),
     >                smem(adnofi), smem(adnoos),
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        call gmprsx (nompro, ncazor )
        endif
#endif
c
      endif
c
c====
c 6. la fin
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
