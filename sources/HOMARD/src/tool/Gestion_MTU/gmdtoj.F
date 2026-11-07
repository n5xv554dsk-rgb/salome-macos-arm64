      subroutine gmdtoj ( nom, codret )
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
c     detacher l'objet terminal d'un nom etendu "nom" de son 
c     support (sans suppression de cet objet)
c     ...........................................................
c
c     entrees  :
c        nom   : character*(*) : nom etendu
c
c     sorties  : codret   : code de retour :
c       -5     : erreur : champ introuvable dans les tables
c       -4     : erreur : support introuvable dans les tables
c       -3     : erreur : nom etendu invalide
c       -2     : erreur : objet-terminal non defini
c       -1     : erreur : nom a un seul element
c        0     : OK
c     ...........................................................
c
c 0. declarations et dimensionnement
c
c
c 0.1. ==> generalites
c
      implicit none
      save
c
      character*6 nompro
      parameter ( nompro = 'GMDTOJ' )
c
#include "genbla.h"
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmimpr.h"
#include "envex1.h"
#include "gmlang.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*(*) nom
c
      integer codret
c
c 0.4. ==> variables locales
c
      character*8   objrep,objter,chater
      integer idec
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
c====
c 2.  decodage du nom etendu
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.  decodage du nom etendu ; coergm = ', coergm
#endif
c
c 2.1. ==> decodage du nom etendu
c
      call gbdnoe(nom,objrep,objter,chater,idec)
c
c 2.2. ==> nom etendu invalide
c
      if (idec.lt.0) then
c
        codret = -3 
c
c 2.3. ==> objet-terminal non defini
c
      else if (idec.eq.1) then
c
        codret = -2
c
c 2.4. ==> nom etendu a un seul element
c
      else if (idec.eq.0) then
c
        codret = -1
c
      else
c
        codret = 0
c
      endif
c
c====
c 3. appel du programme generique
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. programme generique ; codret = ', codret
      write (ulsort,*) '3. programme generique ; coergm = ', coergm
#endif
c
      if ( codret.eq.0 ) then
c
        call gbdtoj ( objrep, objter )
        codret = coergm
c
      endif
c
c====
c 4. Fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
      end
