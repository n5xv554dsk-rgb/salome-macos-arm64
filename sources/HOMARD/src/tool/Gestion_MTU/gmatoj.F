      subroutine gmatoj (nom1,nom2,codret)
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
c     attacher l'objet-terminal de 'nom2' au champ-terminal de
c     'nom1'
c     ...........................................................
c
c     entrees :
c
c       nom1  : character*(*) : nom etendu
c       nom2  : character*(*) : nom etendu
c
c     ...........................................................
c
c     sorties : codret   : code de retour :
c
c       -6    : erreur : 'nom1' n'a qu'un element
c       -5    : erreur : 'nom1' : nom etendu invalide
c       -4    : erreur : 'nom2' : nom etendu invalide
c       -3    : erreur : objet-terminal de 'nom2' non defini
c       -2    : erreur : objet-terminal de 'nom2' est d'un type
c                      : different de celui attendu pour 
c                      : l'objet-terminal de 'nom1'
c       -1    : erreur : 'nom1' a deja un objet-terminal
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
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtors.h"
#include "gmtoas.h"
c
#include "gmcoer.h"
#include "gmimpr.h"
c
c 0.3. ==> arguments
c
      character*(*) nom1,nom2 
      integer       codret
c
c 0.4. ==> variables locales
c
      character*8   obrep1,obter1,chter1
      character*8   obrep2,obter2,chter2
      character*8   letype
c
      integer       ide1,ide2
      integer       iob,ich,kaux
      integer       itp1,nbc1,itc1,ioc1
      integer       itp2,nbc2,itc2
      integer       indc,iadr,long
c
      integer nroobj, nrocha, nropoi
      integer nrotab
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1.  decodage des noms etendus
c====
c
c 1.1. ==> decodage
c
      call gbdnoe(nom1,obrep1,obter1,chter1,ide1)
      call gbdnoe(nom2,obrep2,obter2,chter2,ide2)
c
c 1.2. ==> probleme sur nom1
c
      if (ide1.lt.0) then
c
c        'nom1' invalide
c
         codret = -5
c
      else if (ide1.eq.0) then
c
c        'nom1' n'a qu'un element
c
         codret = -6
c
      else if ((ide1.eq.2).or.(ide1.eq.3)) then
c
c        'nom1' a deja un objet-terminal
c
         codret = -1
c
      else
c
c 1.3. ==> nom1 est bon mais probleme sur nom2
c
         if (ide2.lt.0) then
c
c           'nom2' invalide
c
            codret = -4
c
         else if (ide2.eq.1) then
c
c           objet-terminal de 'nom2' non defini
c
            codret = -3
c
         else
c
c 1.4. ==> tout va bien
c
            codret = 0
c
         endif
c
      endif
c
c====
c 2. recherche du type de l'objet-terminal de 'nom1'
c====
c
      if ( codret.eq.0 ) then
c   
         do 11 , iob = 1,iptobj-1
            if (nomobj(iob).eq.obrep1) then
               nroobj = iob
               goto 20
            endif
   11    continue
c   
         codret = -5
         goto 120
c
   20    continue
c
         itp1 = typobj(nroobj)
         nbc1 = nbcham(itp1)
         do 21 , kaux = 1,nbc1
            ich = adrdst(itp1)+kaux-1
            if (nomcha(ich).eq.chter1) then
               nrocha = ich
               nropoi = kaux
               goto 40
            endif
   21    continue
c   
         codret = -5
         goto 120
c
   40    continue
c
         itc1 = typcha(nrocha)
         ioc1 = adrdso(nroobj)+nropoi-1            
c
c====
c 3. recherche du type de l'objet-terminal de 'nom2'
c====
c
         indc = 0
         do 51 , iob = 1,iptobj-1
            if (nomobj(iob).eq.obrep2) then
               nroobj = iob
               goto 60
            endif
   51    continue
c   
c       ici nom2 doit avoir un seul element :
c           - il peut etre un objet simple alloue ou non
c           - il peut etre un objet structure mais non alloue
c   
         call gbcara(obter2,nrotab,iadr,long,letype)
         if (coergm.gt.1) then
            write(ulsort,*) ' gmatoj -> retour gbcara > 1'
            call ugstop('gmatoj',ulsort,1,1,1)
         endif
         if (coergm.eq.0) then
            if (letype.eq.nomtyb(1)) then
               itc2 = -1
             else if (letype.eq.nomtyb(2)) then
                itc2 = -2
            else if (letype.eq.nomtyb(3)) then
               itc2 = -3
            else if (letype.eq.nomtyb(4)) then
               itc2 = -4
            else 
               itc2 = -5
            endif
         else
             indc = 1 
         endif
         goto 100
c
   60    continue
c
         itp2 = typobj(nroobj)
         nbc2 = nbcham(itp2)
         do 61 , kaux = 1,nbc2
            ich = adrdst(itp2)+kaux-1
            if (nomcha(ich).eq.chter2) then
               nrocha = ich
               goto 80
            endif
   61    continue
c   
         codret = -4
         goto 120
c
   80   continue
c
        itc2 = typcha(nrocha)
c
c====
c 4. verification de la concordance de type
c====
c
  100   continue
c
        if (indc.eq.0) then
           if (itc1.ne.itc2) then
              codret = -2
              goto 120
           endif    
        endif
c
c====
c 5.    attacher obter2 au champ-terminal de 'nom1'
c====
c
        codret = 0
        nomobc(ioc1) = obter2
c
      endif      
c
  120 continue
c
      end
