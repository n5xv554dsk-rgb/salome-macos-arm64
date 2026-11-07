      subroutine gblboj ( nomter )
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
c     liberation d'un objet 'nomter' structure ou simple  
c     et suppression de tous les attachements qui le concernent
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomter . e   . char*8 . nom terminal de l'objet a liberer          .
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
      parameter ( nompro = 'GBLBOJ' )
c
#include "gmmatc.h"
#include "genbla.h"
c
c 0.2. ==> communs
c
#include "gmtoai.h"
#include "gmtoas.h"
#include "gmindi.h"
#include "gminds.h"
c
#include "gmimpr.h"
#include "envex1.h"
#include "gmlang.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*8 nomter
c
c 0.4. ==> variables locales
c
      integer iaux,ioc,ioa,nbc,nba
      integer nroobj
      integer codre1
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
c 2. l'objet est-il alloue ?
c    codre1 = 0 --> non alloue
c    codre1 = 1 --> objet structure
c    codre1 = 2 --> objet simple
c====
c
      call gbobal ( nomter , iaux , codre1 )
c
      if ( codre1.eq.0 ) then
        coergm = -1
      else
        coergm = 0
      endif
c
c====
c 3. Si l'objet est simple, on le desalloue par le programme basique
c====
c
      if ( coergm.eq.0 ) then
c
      if ( codre1.eq.2 ) then
c
        call gmdesa (nomter)
c 
      endif
c
      endif
c
c====
c 4. Si l'objet est structure, on le recherche dans la liste
c====
c
      if ( coergm.eq.0 ) then
c
      if ( codre1.eq.1 ) then
c
c 4.1. ==> on le recherche dans la liste
c
        nroobj = 0
        do 411 , iaux = 1,iptobj-1
          if (nomobj(iaux).eq.nomter) then
            nroobj = iaux
            goto 412
          endif
  411   continue
c
  412   continue
c
        iptobj = iptobj-1
c
c 4.2. ==> si c'est le dernier objet enregistre : on le supprime
c          . on ramene aux valeurs indefinies toutes les informations
c            qui concernent ses champs.
c          . on memorise les nouvelles adresses des futurs
c            champs et attributs
c          . on ramene aux valeurs indefinies toutes les informations
c            qui le concernent.
c
        if ( nroobj.eq.iptobj ) then
c
          do 421 , ioc = adrdso(nroobj),iptchp-1
            nomobc(ioc) = sindef
  421     continue
c
          do 422 , ioa = adrdsa(nroobj),iptatt-1
            valatt(ioa) = iindef
  422     continue
c
          iptchp = adrdso(nroobj)
          iptatt = adrdsa(nroobj)
c
          nomobj(nroobj) = sindef
          adrdsa(nroobj) = iindef
          adrdso(nroobj) = iindef
          typobj(nroobj) = iindef
c
        else 
c
c 4.3. ==> si ce n'est pas le dernier objet enregistre :
c          . on comprime la liste
c
c 4.3.1 ==> les noms des champs associes aux objets, puis mise
c           a jour du pointeur
c
          nbc = adrdso(nroobj+1)-adrdso(nroobj)
          do 431 , ioc = adrdso(nroobj),iptchp-nbc-1
            nomobc(ioc) = nomobc(ioc+nbc)
  431     continue
c
          do 432 , ioc = iptchp-nbc,iptchp-1
            nomobc(ioc) = sindef
  432     continue
          iptchp = iptchp-nbc
c
c 4.3.2 ==> les attributs associes aux objets, puis mise
c           a jour du pointeur
c
          nba = adrdsa(nroobj+1)-adrdsa(nroobj)
          do 433 , ioa = adrdsa(nroobj),iptatt-nba-1
            valatt(ioa) = valatt(ioa+nba)
  433     continue
c
          do 434 , ioa = iptatt-nba,iptatt-1
            valatt(ioa) = iindef
  434     continue
          iptatt = iptatt-nba
c
c 4.3.3. ==> les adresses dans les tableaux des champs et des attributs
c
          do 435 , iaux = nroobj+1,iptobj-1
            adrdso(iaux) = adrdso(iaux+1)-nbc
            adrdsa(iaux) = adrdsa(iaux+1)-nba
  435     continue
          adrdsa(iptobj) = iindef
          adrdso(iptobj) = iindef
c
c 4.3.4. ==> les noms et types des objets alloues
c
          do 436 , iaux = nroobj,iptobj-1
            nomobj(iaux) = nomobj(iaux+1)
            typobj(iaux) = typobj(iaux+1)
  436     continue
c
          nomobj(iptobj) = sindef
          typobj(iptobj) = iindef
c
        endif
c
      endif
c
      endif
c
c====
c 5. Fin
c====
c
      if ( coergm.ne.0 ) then
c
      write(ulsort,*) nompro, ', code retour ',coergm,' pour ',nomter
c
#include "envex2.h"
c
      endif
c
      end
