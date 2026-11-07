      subroutine utbilm ( nomail, commen, typbil, action,
     >                    lgetco, taetco,
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
c    UTilitaire - BILan sur le Maillage
c    --           ---          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . commen . e   . ch80   . commentaire a ecrire en tete               .
c . typbil . e   .   1    . type de bilan                              .
c .        .     .        . la valeur de typbil est le produit de :    .
c .        .     .        .  0 : rien du tout                          .
c .        .     .        .  2 : nombre d'entites homard               .
c .        .     .        .  3 : interpenetration des mailles          .
c .        .     .        .  5 : qualite des mailles                   .
c .        .     .        .  7 : nombre d'entites du calcul            .
c .        .     .        . 11 : connexite                             .
c .        .     .        . 13 : tailles des sous-domaines             .
c . action . e   .char8/10. action en cours                            .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTBILM' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
      character*(*) action
      character*(*) commen
c
      integer typbil
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nretap, nrsset
c
      integer codava
      integer iaux
c
      character*6 saux06
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
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
      texte(1,4) = '(/,a6,'' ANALYSE DU MAILLAGE'')'
      texte(1,5) = '(26(''=''),/)'
      texte(1,6) = '(''Erreur dans la verification du maillage.'')'
c
      texte(2,4) = '(/,a6,'' MESH ANALYSIS'')'
      texte(2,5) = '(20(''=''),/)'
      texte(2,6) = '(''Error in the verification of the mesh.'')'
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux06, iaux, codret )
c
c 1.5 ==> le titre
c
      write (ulsort,texte(langue,4)) saux06
      write (ulsort,texte(langue,5))
c
#include "impr03.h"
c
c====
c 2. verifications
c====
c
      if ( action(1:4).eq.'info' ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTVERI', nompro
#endif
c
        iaux = 0
        call utveri ( action, nomail, nompro, iaux,
     >                ulsort, langue, codret )
c
        if ( codret.ne.0 ) then
c
          write (ulsort,texte(langue,6))
          codret = 0
          goto 40
c
        endif
c
        endif
c
      endif
c
c====
c 3. Bilan reel
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Bilan reel ; codret', codret
#endif
c
c 3.1. ==> Pour la conversion avant l'adaptation, on ne fait le bilan
c          que si c'est explictement demande
c
      if ( codret.eq.0 ) then
c
      iaux = abs(typbil)
      if ( action(1:4).eq.'avad' ) then
        if ( typbil.gt.0 ) then
          iaux = 0
        endif
      endif
c
      endif
c
c 3.2. ==> Appel du programme de base
c
      if ( codret.eq.0 ) then
c
      if ( iaux.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTBIL1', nompro
#endif
        call utbil1 ( nomail, commen, iaux, action,
     >                lgetco, taetco,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c====
c 4. on impose un code de retour toujours nul
c====
c
   40 continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '40 continue ; codret', codret
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
#endif
c
      endif
c
      codret = 0
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
