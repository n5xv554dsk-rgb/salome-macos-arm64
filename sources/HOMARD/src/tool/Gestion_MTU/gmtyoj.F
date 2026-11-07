      subroutine gmtyoj ( nom, typobj, simple, codret )
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
c    determine le type d'un objet
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nom    . e   .char*(*). nom etendu de l'objet                      .
c . typobj .  s  . char*8 . type de l'objet                            .
c . simple .  s  . ent    . 1 : l'objet est simple                     .
c .        .     .        . 0 : l'objet est compose                    .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
c .        .     .        . -1 : objet-terminal non alloue             .
c .        .     .        . -2 : objet-terminal non defini             .
c .        .     .        . -3 : nom etendu invalide                   .
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c
c 0.1. ==> generalites
c
      implicit none
      save
      character*6 nompro
      parameter ( nompro = 'GMTYOJ' )
c
c
#include "genbla.h"
c
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtoas.h"
c
#include "gmimpr.h"
#include "gmlang.h"
#include "gminds.h"
c
c 0.3. ==> arguments
c
      character*(*) nom
      character*8 typobj
c
      integer simple, codret
c
c 0.4. ==> variables locales
c
      character*8 objrep,objter,chater
c
      integer iaux, idec, ioal, letype
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) = '(''Nom de l''''objet en memoire centrale :'')'
      texte(1,11) = '(''L''''objet n''''est pas alloue.'')'
      texte(1,12) = '(''L''''objet n''''est pas defini.'')'
      texte(1,13) = '(''Le nom est invalide.'')'
c
      texte(2,10) = '(''Name of the object in central memory :'')'
      texte(2,11) = '(''The object is not allocated.'')'
      texte(2,12) = '(''The object is not defined.'')'
      texte(2,13) = '(''Bad name in central memory.'')'
#ifdef _DEBUG_HOMARD_
      write (ulsort,90000)
        write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,10))
      write (ulsort,*) nom
#endif
c
c====
c 2. on se base sur le nom interne pour travailler
c====
c
      typobj = sindef
c
      codret = 0
c
c 2.1. ==> appel de la fonction generique
c
      call gbdnoe ( nom, objrep, objter, chater, idec )
c
      if (idec.lt.0) then
c
c 2.2. ==> nom etendu invalide
c
         codret = -3
c
      else if (idec.eq.1) then
c
c 2.3. ==> objet-terminal non defini
c
         codret = -2
c
      else if (idec.eq.2) then
c
c 2.4. ==> objet-terminal non alloue
c
         codret = -1
c
      else
c
c 2.5. ==> sous quel forme l'objet terminal est-il alloue ?
c
         call gbobal ( objter, letype, ioal )
c
         if ( ioal.eq.1 ) then
            simple = 0
            typobj = nomtbp(letype)
         elseif ( ioal.eq.2 ) then
            simple = 1
            typobj = nomtbp(letype)
         else
            codret = -1
         endif
c
      endif
c
c 2.6. ==> bilan
c
      if ( codret.ne.0 ) then
         goto 91
      endif
c
c====
c 9. gestion des erreurs
c====
c
   91 continue
c
      if ( codret.ne.0 ) then
c
         iaux = 10+abs(codret)
c
         write (ulsort,90000)
         write (ulsort,texte(langue,1)) 'Sortie', nompro
         write (ulsort,texte(langue,10))
         write (ulsort,*) nom
         write (ulsort,texte(langue,iaux))
         write (ulsort,90000)
c
      endif
c
90000 format (70('='))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90000)
#endif
      end
