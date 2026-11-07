      subroutine gmecat (nom,numero,valeur,codret)
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
c     attribuer une valeur entiere a l'attribut numero 'numero'
c     de l'objet-terminal du nom etendu "nom"
c     ...........................................................
c
c     entrees :
c
c       nom   : character*(*) : nom etendu
c     numero  : integer       : numero de l'attribut
c     valeur  : integer       : valeur a attribuer
c
c     ...........................................................
c
c     sorties :
c      codret : code de retour :
c       -5    : erreur : nom etendu invalide
c       -4    : erreur : objet-terminal pas defini
c       -3    : erreur : objet-terminal defini mais pas alloue
c       -2    : erreur : objet-terminal n'est pas structure
c       -1    : erreur : numero < 1 ou
c                      : numero > nombre d'attributs de objet-terminal 
c        0    : OK
c
c     ...........................................................
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
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtoas.h"
c
c 0.3. ==> arguments
c
      character*(*) nom 
      integer       numero,valeur,codret
c
c 0.4. ==> variables locales
c
      character*8   objrep,objter,chater
      integer       idec,iob,ity,nba,iat,nroobj
c
c 1.  decodage du nom etendu
c
      call gbdnoe(nom,objrep,objter,chater,idec)
c
      if (idec.lt.0) then
c
c       nom etendu invalide
c
        codret = -5 
c
      else if (idec.eq.1) then
c
c       objet-terminal non defini 
c
        codret = -4
c
      else if (idec.eq.2) then
c
c       objet-terminal defini mais non alloue  
c
        codret = -3
c
      else
c
c       objet-terminal est defini et eventuellement alloue
c
        do 10 , iob = 1,iptobj-1
          if (nomobj(iob).eq.objter) then
            nroobj = iob
            codret = 0
            goto 20
          endif
   10   continue
c
        codret = -2
c
      endif 
c
c====
c 2.  objet structure : ecriture de l'attribut
c====
c
   20 continue
c
      if ( codret.eq.0 ) then
c
      ity = typobj(nroobj)
      nba = nbratt(ity)
      codret = -1
      if ( numero.le.nba.and.numero.gt.0 ) then
         codret = 0
         iat = adrdsa(nroobj)+numero-1
         valatt(iat) = valeur
      endif
c
      endif
c
      end
