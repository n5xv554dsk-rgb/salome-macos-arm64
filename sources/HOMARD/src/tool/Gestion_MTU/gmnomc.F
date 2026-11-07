      subroutine gmnomc (nom,nomter,codret)
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
c  but : rechercher le nom de l'objet-terminal du nom etendu "nom"
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nom    . e   . char*  . nom etendu dont on veut le nom terminal    .
c . nomter .  s  .   ch8  . nom terminal du nom etendu nom             .
c . codret .  s  .    1   . 0  : tout va bien                          .
c .        .     .        . -1 : objet-terminal non defini : aucun     .
c .        .     .        .      objet n'a ete attache au champ        .
c .        .     .        .      terminal de l'objet-repertoire        .
c .        .     .        . -3 : nom etendu invalide                   .
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
      parameter ( nompro = 'GMNOMC' )
c
#include "genbla.h"
c
c 0.2. ==> communs
c
#include "gminds.h"
c
#ifdef _DEBUG_HOMARD_
#include "envex1.h"
#include "gmimpr.h"
#include "gmlang.h"
#endif
c
c 0.3. ==> arguments
c
      character*(*) nom
      character*8   nomter
c
      integer       codret
c
c 0.4. ==> variables locales
c
      character*8   objrep,objter,chater
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
c
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c  1. preliminaires
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Objet : '',a)'
      texte(1,5) = '(''Le nom etendu est invalide.'')'
      texte(1,6) = '(''L''''objet terminal est indefini.'')'
c
      texte(2,4) = '(''Object : '',a)'
      texte(2,5) = '(''Extended name is not valid.'')'
      texte(2,6) = '(''Final object is not defined.'')'
c
c====
c 2. decodage du nom etendu
c====
c
      call gbdnoe(nom,objrep,objter,chater,iaux)
c
      if (iaux.lt.0) then
c
c        nom etendu invalide
c
         nomter = sindef
         codret = -3
c
      else if (iaux.eq.0) then
c
c        'nom' n'a qu'un element
c
         nomter = nom
         codret = 0
c
      else if (iaux.eq.1) then
c
c        objet-terminal non defini
c
         nomter = sindef
         codret = -1
c
      else
c
c        objet-terminal est defini et (eventuellement alloue)
c
         nomter = objter
         codret = 0
c
      endif
c
c====
c 4. Fin
c====
c
#ifdef _DEBUG_HOMARD_
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4)) nom
      if ( codret.eq.-3 ) then
        write (ulsort,texte(langue,5))
      else
        write (ulsort,texte(langue,6))
      endif
c
      endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
