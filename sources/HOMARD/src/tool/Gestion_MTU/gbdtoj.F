      subroutine gbdtoj ( objsup, objter )
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
c     detacher l'objet de nom terminal 'objter' de l'objet qui le
c     supporte de nom terminal 'objsup'
c     si le nom terminal 'objsup' est blanc, on detache l'objet 'objter'
c     de tous les objets qui le referencient.
c     remarque : il n'y a pas suppression de l'objet 'objter'. il est
c                simplement debranche de 'objsup'
c
c     ...........................................................
c
c     entrees  :
c     objsup  : character*8 : objet support de l'attachement ou blanc
c     objter  : character*8 : objet a detacher
c
c     sorties  : coergm   : code de retour :
c       -2     : erreur : champ introuvable dans les tables
c       -1     : erreur : objet support introuvable dans les tables
c        0     : OK
c
c     ...........................................................

c====
c 0. declarations et dimensionnement
c====
c
c
c 0.1. ==> generalites
c
      implicit none
      save
c
      character*6 nompro
      parameter ( nompro = 'GBDTOJ' )
c
#include "genbla.h"
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtoas.h"
c
#include "gminds.h"
c
#include "gmimpr.h"
#include "envex1.h"
#include "gmlang.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*8 objsup, objter
c
c 0.4. ==> variables locales
c
      integer iaux, nbc
      integer nroobj, nrocha, nrotyp
      integer nrobde, nrobfi
c
      character*8 blanc
c
      parameter ( blanc = '        ' )
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
c 2. recherche du numero de l'objet support
c====
c
      if ( objsup.eq.blanc ) then
c
        nrobde = 1
        nrobfi = iptobj-1
c
      else
c
        do 21 , iaux = 1 , iptobj-1
          if (nomobj(iaux).eq.objsup) then
            nrobde = iaux
            nrobfi = iaux
            goto 22
          endif
   21   continue
        coergm = -1
c
   22 continue
c
      endif
c
c====
c 3. pour chacun des objets supports concernes, on recherche le champ
c    a detacher.
c    on a un code retour non nul seulement dans le cas ou on veut
c    detacher un objet d'un support defini et que l'on ne le trouve pas.
c====
c
      if ( coergm.eq.0 ) then
c
      do 31 , nroobj = nrobde, nrobfi
c
        nrotyp = typobj(nroobj)
        nbc = nbcham(nrotyp)
        do 311 , iaux = 1 , nbc
          nrocha = adrdso(nroobj)+iaux-1
          if (nomobc(nrocha).eq.objter) then
            nomobc(nrocha) = sindef
            goto 312
          endif
  311   continue
c
        if ( objsup.ne.blanc ) then
          coergm = -2
        endif
c
  312   continue
c
   31 continue
c
      endif
c
c====
c 4. Fin
c====
c
      if ( coergm.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
      end
