      subroutine vcfia3 ( nbfamd, numfam,
     >                    typenh, nbento, nctfen, nbfenm,
     >                    fament, cfaent,
     >                    tabmem,
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
c    aVant adaptation - FIltrage de l'Adaptation - phase 3
c     -                 --            -                  -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfamd . e   .   1    . nombre de familles MED concernees          .
c . numfam . e   .   1    . liste des familles MED concernees          .
c . typenh . e   .   1    . code des entites au sens homard            .
c . nbento . e   .   1    . nombre d'entites                           .
c . nctfen . e   .    1   . nombre total de caracteristiques           .
c . nbfenm . e   .    1   . nombre maximum de familles                 .
c . fament . e   . nbento . famille des entites                        .
c . cfaent . e   . nctfen*. codes des familles des entites             .
c .        .     . nbfent .                                            .
c . tabmem .   s . nbento . memorisation du filtrage                   .
c .        .     .        . Pour l'entite i :                          .
c .        .     .        .   0 : l'entite est retiree                 .
c .        .     .        .   1 : l'entite est gardee pour l'adaptation.
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'VCFIA3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "coftex.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbfamd
      integer numfam(nbfamd)
      integer typenh, nbento, nctfen, nbfenm
      integer cfaent(nctfen,nbfenm), fament(nbento)
      integer tabmem(nbento)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
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
      texte(1,4) ='(''Prise en compte du filtrage sur les '',a)'
      texte(1,5) = '(''Famille(s) de la zone a adapter :'')'
c
      texte(2,4) = '(''Influence over '',a)'
      texte(2,5) = '(''Familie(s) of refined zone :'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,texte(langue,5))
      write (ulsort,1000) (numfam(iaux), iaux = 1 , nbfamd )
 1000 format(10i5)
#endif
c
c====
c 2. Reperage des entites soumises a adaptation
c    A priori, aucune
c====
c
      do 21 , iaux = 1 , nbento
c
        tabmem(iaux) = 0
        jaux = cfaent(cofamd,fament(iaux))
cgn        write (ulsort,*) 'Famille de', iaux, ' :', jaux
        do 211 , kaux = 1 , nbfamd
          if ( numfam(kaux).eq.jaux ) then
            tabmem(iaux) = 1
            goto 21
          endif
  211   continue
c
   21 continue
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
