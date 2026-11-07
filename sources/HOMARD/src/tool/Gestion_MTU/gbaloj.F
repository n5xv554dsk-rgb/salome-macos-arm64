      subroutine gbaloj (nom,type,iret)
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
c     fonction d'allocation d'un objet "nom", structure, de type
c     "type"
c     ...........................................................
c
c     entrees :
c       nom   : character*8 : nom de l'objet a allouer
c       type  : character*8 : nom du type de l'objet a allouer
c
c             ( ou chaine de 8 caracteres au plus )
c
c     ...........................................................
c
c     sorties : iret   :
c       -3    : erreur : type inconnu
c       -2    : erreur : il existe deja un objet de ce nom
c                        (structure ou simple)
c       -1    : erreur : allocation impossible :
c                        dimensionnement des tables insuffisant
c        0    : OK
c
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
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtors.h"
#include "gmtoas.h"
c
c 0.3. ==> arguments
c
      character*(*) nom, type
      integer iret
c
c 0.4. ==> variables locales
c
      integer ityp, ity, ioal, ityptr
c
c 1.  recherche du type
c
      do 10 ity = 1, nbrtyp
         if (nomtyp(ity).eq.type) then
           ityptr = ity
           goto 20
         endif
   10 continue
c
      iret = -3
      goto 30
c
c 2.  verification si cet objet existe deja
c
   20 continue
c
      call gbobal(nom,ityp,ioal)
c
      if (ioal.ge.1) then
         iret = -2
         goto 30 
      endif
c
c 3.  mise a jour des tables
c
      if ( (iptobj.gt.nobjx) .or.
     >     (iptchp+nbcham(ity).gt.nobcx+1) .or.
     >     (iptatt+nbratt(ity).gt.nobcx+1)      ) then
         iret = -1
      else
c
      nomobj(iptobj) = nom
      typobj(iptobj) = ityptr
      adrdso(iptobj) = iptchp
      adrdsa(iptobj) = iptatt
      iptobj = iptobj+1
      iptchp = iptchp + nbcham(ityptr)
      iptatt = iptatt+nbratt(ityptr)
c
        if ((iptobj.eq.nobjx).or.(iptchp.gt.nobcx)
     >                       .or.(iptatt.gt.nobcx)) then
           iret = -1
        else
           iret = 0
        endif
      endif
c
   30 continue
c
      end
