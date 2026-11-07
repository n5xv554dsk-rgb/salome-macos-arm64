      subroutine gbdnof (pere,champ,nomfis,iret)
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
c     recherche le nom de l'objet attache au champ 'champ' de  
c     l'objet 'pere'
c     version memoire centrale
c     ...........................................................
c
c     entrees  :
c        pere  : character*(*) : nom de l'objet pere
c       champ  : character*(*) : chaine de 8 caracteres au plus
c
c     sorties  :
c      nomfis  : nom de l'objet trouve
c       iret   : code de retour :
c       -4     : erreur : l'objet 'pere' n'existe pas
c       -3     : erreur : l'objet 'pere' n'est pas un objet
c                       : structure
c       -2     : erreur : 'champ' ne correspond pas a un champ
c                       : dans le type de l'objet 'pere'
c       -1     : erreur : aucun objet n'a ete attache au champ
c                       : 'champ' de l'objet 'pere'
c        0     : OK
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
#include "gminds.h"
#include "gmimpr.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*(*) pere,champ
      character*8   nomfis
      integer       iret
c
c 0.4. ==> variables locales
c
      character*8   letype
      integer       iob,iadr,long
      integer       ity,nbc,k,ich,ioc
      integer nrocha, nroobj
      integer nrotab
c
c====
c 1.  recherche l'objet 'pere'
c====
c
      do 11 , iob = 1,iptobj-1
         if (nomobj(iob).eq.pere) then
            nroobj = iob
            goto 20
         endif
   11 continue
c
      iret = -3
c
      call gbcara(pere,nrotab,iadr,long,letype)
      if (coergm.gt.1) then
       write(ulsort,*) ' gbdnof -> retour gbcara > 1'
       call ugstop('gbdnof',ulsort,1,1,1)
      endif 
      if (coergm.eq.1) then
         iret = -4 
      endif
c 
      goto 9999
c
c====
c 2.  verification du champ
c====
c
   20 continue
c
      ity = typobj(nroobj)
      nbc = nbcham(ity)
      do 21 , k = 1,nbc
         ich = adrdst(ity)+k-1
         if (nomcha(ich).eq.champ) then
            nrocha = k
            goto 30
         endif
   21 continue
c
      iret = -2
      goto 9999
c
c====
c 3.  recherche de l'objet attache au champ
c====
c
   30 continue
c
      ioc = adrdso(nroobj)+nrocha-1
      if (nomobc(ioc).eq.sindef) then
         iret = -1
         goto 9999
      endif
c
      iret = 0
      nomfis = nomobc(ioc)
c
 9999 continue
c
      end
