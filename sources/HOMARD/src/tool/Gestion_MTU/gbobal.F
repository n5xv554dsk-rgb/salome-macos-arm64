      subroutine gbobal ( nom , letype , codret ) 
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
c     sous-programme d'interrogation si un objet "nom" (structure 
c     ou non) est alloue ou non en memoire centrale
c     ...........................................................
c
c     entrees :
c
c       nom   : chaine de 8 caracteres au plus ou
c             : character*8 : nom de l'objet a interroger
c
c     ...........................................................
c
c     sorties : 
c
c      letype   : numero du type de l'objet
c      codret :
c        0    : objet non alloue
c        1    : objet structure alloue
c        2    : objet simple    alloue
c
c     ...........................................................
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
c
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtors.h"
#include "gmtoas.h"
#include "gmindi.h"
c
#include "gmimpr.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*(*) nom 
      integer       letype,codret
c
c 0.4. ==> variables locales
c
      character*8   typtab 
c
      integer       iaux,iadr,long
      integer nrotab
c
c====
c 1. c'est un objet structure ?
c====
c
      codret = 0
      do 10 , iaux = 1,iptobj-1
         if (nomobj(iaux).eq.nom) then
            letype = typobj(iaux)
            codret = 1
         endif
   10 continue
c
c====
c 2. c'est un objet simple ?
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> interrogation sur le type
c
         call gbcara(nom,nrotab,iadr,long,typtab)
c
c 2.2. ==> l'objet est bien alloue
c
         if (coergm.eq.0) then
c
            codret = 0
            do 21 , iaux = 1,ntyb
               if (typtab.eq.nomtyb(iaux)) then
                  letype = -iaux
                  codret = 2
               endif
   21       continue
c
c 2.3. ==> l'objet n'est pas alloue
c
         elseif (coergm.eq.1) then
c
            letype = iindef
            coergm = 0
            codret = 0
c
c 2.4. ==> erreur grave
c 
         else
c
            write(ulsort,*)' gbobal -> retour gbcara > 1' 
            call ugstop('gbobal',ulsort,1,1,1)
c
         endif
c
      endif
c
      end
