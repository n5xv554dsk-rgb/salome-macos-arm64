      subroutine sfgrf0 ( nocmaf,
     >                    nbmail,
     >                    adtyel, adfael,
     >                    adnufa, adgrpo, adgrtb,
     >                    nbfmed, lifami,
     >                    ulsort, langue, codret)
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
c   Suivi de Frontiere - GRoupes de la Frontiere - phase 0
c   -        -           --            -                 -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocmaf . e   . char*8 . nom de l'objet maillage de la frontiere    .
c . nbmail .  s  .   1    . nombre de mailles                          .
c . adtyel .  s  .   1    . type des elements                          .
c . adfael .  s  .   1    . famille MED des elements                   .
c . adnufa .  s  .   1    . numero des familles                        .
c . adgrpo .  s  .   1    . pointeurs des groupes                      .
c . adgrtb .  s  .   1    . table des groupes                          .
c . nbfmed .   s .   1    . nombre de familles de mailles de frontiere .
c . lifami .   s .   *    . liste des familles a explorer              .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme avec la memoire               .
c .        .     .        . 3 : probleme avec le fichier               .
c .        .     .        . 5 : contenu incorrect                      .
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
      parameter ( nompro = 'SFGRF0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer nbfmed, nbmail
      integer adtyel, adfael
      integer adnufa, adgrpo, adgrtb
      integer lifami(*)
c
      character*8 nocmaf
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nbnomb
c
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
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
      codret = 0
c
c====
c 2. recuperation des adresses
c====
c 2.1. ==> les informations generales
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nocmaf )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMC', nompro
#endif
      call utnomc ( nocmaf,
     >                sdim,   mdim,
     >               degre, mailet, maconf, homolo, hierar,
     >              nbnomb,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret)
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ncnoeu )
      call gmprsx (nompro, nccono )
      call gmprsx (nompro, ncfami )
#endif
c
      endif
c
c 2.2. ==> caracteristiques des mailles frontiere
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD11', nompro
#endif
      iaux = 77
      call utad11 ( iaux, ncnoeu, nccono,
     >                jaux,   jaux,   jaux,  jaux,
     >              adtyel, adfael,   jaux,  jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nccono, 1, nbmail, codret )
c
      endif
c
c 2.3. ==> adresses des tableaux des groupes dans les familles
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD13', nompro
#endif
      iaux = 10
      call utad13 ( iaux, ncfami,
     >              adnufa, jaux,
     >              adgrpo,  jaux, adgrtb,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. reperage des numeros des familles de segments
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. reperage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFGRF1', nompro
#endif
      call sfgrf1 ( nbfmed, lifami,
     >              nbmail, imem(adtyel), imem(adfael),
     >              ulsort, langue, codret )
c
      endif
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
