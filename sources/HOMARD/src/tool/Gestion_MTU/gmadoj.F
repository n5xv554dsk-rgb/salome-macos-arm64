      subroutine gmadoj ( nom, iadres, long, iret)
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
c     rechercher l'adresse memoire de l' objet-terminal simple
c     d'un nom etendu et la taille de cet objet
c     ...........................................................
c
c     entrees :
c       nom   : character*(*) : nom etendu
c     ...........................................................
c
c     sorties :
c     iadres  : adresse memoire de l'objet-terminal
c      long   : la taille de cet objet (en mots)
c      iret   : code de retour :
c       -4    : erreur : nom etendu invalide
c       -3    : erreur : objet-terminal de'nom' non defini
c       -2    : erreur : objet-terminal de'nom' est un objet
c                      : structure
c       -1    : erreur : objet-terminal de 'nom' est defini
c                      : mais non alloue
c        0    : OK
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
c 0.2. ==> communs
c
#include "gmindi.h"
#include "gmimpr.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*(*) nom
      integer       iadres,long,iret
c
c 0.4. ==> variables locales
c
      character*8   objrep,objter,chater
      character*8   letype
      integer       idec,ioal,ityp,iadr
      integer nrotab
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les initialisations
c====
c
      iret   = 0
      iadres = iindef
      long   = iindef
c
c 1.  decodage du nom etendu
c
      call gbdnoe(nom,objrep,objter,chater,idec)
c
      if (idec.lt.0) then
c
c        nom etendu invalide
c
         iret = -4
c
      else if (idec.eq.1) then
c
c        objet-terminal non defini
c
         iret = -3
c
      else if (idec.eq.2) then
c
c        objet-terminal defini mais non alloue
c
         iret = -1
c
      else
c
         if (idec.eq.0) then
c
c           'nom' n'a qu'un element
c
            call gbobal(objter,ityp,ioal)
c
            if (ioal.eq.0) then
c
c              objet non alloue
c
               iret = -1
c
            endif
c
         endif
c
c 2.     objet-terminal defini et alloue : appel gbcara
c
         if ( iret.eq.0 ) then
c
           call gbcara(objter,nrotab,iadr,long,letype)
c
           if (coergm.gt.1) then
            write(ulsort,*) ' gmadoj -> retour gbcara > 1'
            call ugstop('gmadoj',ulsort,1,1,1)
           endif
           if (coergm.eq.0) then
              iret = 0
              iadres = iadr
           else
              iret = -2
           endif
c
         endif
c
      endif
c
      end
