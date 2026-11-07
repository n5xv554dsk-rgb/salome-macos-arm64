      subroutine infc34 ( numcas, nbcomp, nbentc,
     >                    profil, vafoti, vafotr,
     >                    arequa, perqua, nivqua,
     >                    nquaca,
     >                    coonoe, somare,
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
c  INformation - inFormations Complementaires - phase 34
c  --              -          -                       --
c  Valeurs sur les quadrangles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numcas . e   .   1    . numero du cas en cours de traitement       .
c .        .     .        . 1 : niveau                                 .
c .        .     .        . 2 : qualite                                .
c .        .     .        . 3 : diametre                               .
c .        .     .        . 4 : parente                                .
c .        .     .        . 5 : voisins des recollements               .
c . nbcomp . e   .   1    . nombre de composantes                      .
c . nbentc . e   .   1    . nombre total d'entites du calcul           .
c . profil .  s  . nbentc . pour chaque entite du calcul :             .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vafoti .  s  . nbentc . tableau temporaire de la fonction          .
c . vafotr .  s  . nbentc . tableau temporaire de la fonction          .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . nquaca . e   .   *    . nro des quadrangles dans le calcul         .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'INFC34' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "impr02.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer numcas
      integer nbcomp, nbentc
      integer profil(nbentc)
      integer vafoti(nbentc)
      integer arequa(nbquto,4), perqua(nbquto)
      integer nivqua(nbquto)
      integer nquaca(*)
      integer somare(2,nbarto)
c
      double precision coonoe(nbnoto,sdim)
      double precision vafotr(nbentc)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      double precision qualit, surf, diamet
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
      texte(1,4) = '(''.. Valeurs sur les '',a)'
c
      texte(2,4) = '(''.. Values over the '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,4)
      write (ulsort,90002) 'cas   ', numcas
      write (ulsort,90002) 'nbquto', nbquto
      write (ulsort,90002) 'nbqupe', nbqupe
      write (ulsort,90002) 'nbentc', nbentc
#endif
c
      codret = 0
c
c====
c 2. Rien par defaut
c====
c
      do 21 , iaux = 1 , nbentc
        profil(iaux) = 0
   21 continue
c
c====
c 3. Niveau
c====
c
      if ( numcas.eq.1 ) then
c
c 3.1. ==> Les quadrangles de depart ou issus d'un decoupage en 4
c
        do 31 , iaux = 1 , nbqupe
c
          jaux = nquaca(iaux)
          if ( jaux.ne.0 ) then
            vafotr(jaux) = dble(nivqua(iaux))
            profil(jaux) = 1
          endif
c
   31   continue
c
c 3.2. ==> Les quadrangles issus d'un decoupage de conformite
c
        do 32 , iaux = nbqupe+1 , nbquto
c
          jaux = nquaca(iaux)
          if ( jaux.ne.0 ) then
            vafotr(jaux) = dble(nivqua(iaux)) - 0.5d0
            profil(jaux) = 1
          endif
c
   32   continue
c
c====
c 4. Qualite
c====
c
      elseif ( numcas.eq.2 ) then
c
        do 41 , iaux = 1 , nbquto
c
          jaux = nquaca(iaux)
          if ( jaux.ne.0 ) then
            call utqqua ( iaux, qualit, surf,
     >                    coonoe, somare, arequa )
            vafotr(jaux) = qualit
            profil(jaux) = 1
          endif
c
   41   continue
c
c====
c 5. Diametre
c====
c
      elseif ( numcas.eq.3 ) then
c
        do 51 , iaux = 1 , nbquto
c
          jaux = nquaca(iaux)
          if ( jaux.ne.0 ) then
            call utdqua ( iaux, diamet,
     >                    coonoe, somare, arequa )
            vafotr(jaux) = diamet
            profil(jaux) = 1
c
          endif
c
   51   continue
c
c====
c 6. Parente
c====
c
      elseif ( numcas.eq.4 ) then
c
        do 61 , iaux = 1 , nbquto
c
          jaux = nquaca(iaux)
          if ( jaux.ne.0 ) then
            vafoti(jaux) = perqua(iaux)
            profil(jaux) = 1
          endif
c
   61   continue
c
      endif
c
c====
c 7. la fin
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
