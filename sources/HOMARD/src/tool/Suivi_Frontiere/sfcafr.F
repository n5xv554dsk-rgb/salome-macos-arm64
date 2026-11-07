      subroutine sfcafr ( lgopti, taopti,
     >                    lgopts, taopts,
     >                    lgetco, taetco,
     >                    nomail, nbarfr, nbqufr,
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
c   Suivi de Frontiere : CAlcul des nouvelles FRontieres
c   --                   --                   --
c remarque : on n'execute ce programme que si le precedent s'est
c            bien passe
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . es  . lgopti . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . nomail . e   . char8  . nom de l'objet maillage homard iter. n+1   .
c . nbarfr . e   .   1    . nombre d'aretes concernees                 .
c . nbqufr . e   .   1    . nombre de quadrangles concernes            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . en entree = celui du module d'avant        .
c .        .     .        . en sortie = celui du module en cours       .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 2x : probleme dans les memoires            .
c .        .     .        . 3x : probleme dans les fichiers            .
c .        .     .        . 5 : mauvaises options                      .
c .        .     .        . 6 : problemes dans les noms d'objet        .
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
      parameter ( nompro = 'SFCAFR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      character*8 nomail
c
      integer nbarfr, nbqufr
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codava
      integer adulgr
c
      character*8 ncafdg, nocdfr, ncafan, ncafar
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les initialisations
c====
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbarfr', nbarfr
      write (ulsort,90002) 'nbqufr', nbqufr
#endif
c
c====
c 2. Les structures de base
c====
c
      nocdfr = taopts(16)
      ncafdg = taopts(17)
      ncafan = taopts(25)
      ncafar = taopts(26)
c
c====
c 3. Preparation pour la frontiere discrete
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Preparation ; codret', codret
#endif
c
      if ( mod(taopti(29),2).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFPREP', nompro
#endif
        call sfprep ( nomail, nocdfr,
     >                lgetco, taetco,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 4. Traitement
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Traitement ; codret', codret
#endif
c
c 4.1. ==> Numeros d'unite logiques pour la CAO
c
      if ( mod(taopti(29),5).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( taopts(27), adulgr, iaux, codret )
c
        endif
c
      endif
c
c 4.2. ==> Calcul
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCAF1', nompro
#endif
      call sfcaf1 ( nomail, nbarfr, nbqufr,
     >              ncafdg, nocdfr, ncafan, ncafar,
     >              taopti(29), imem(adulgr),
     >              lgetco, taetco,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. La fin
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
c=======================================================================
      endif
c=======================================================================
c
      end
