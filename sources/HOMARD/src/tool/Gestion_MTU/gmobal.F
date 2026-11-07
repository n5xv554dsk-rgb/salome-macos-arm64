      subroutine gmobal (nom,iret)
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
c     sous programme d'interrogation si l'objet de nom etendu "nom"
c     est alloue ou non
c     ...........................................................
c
c     entrees :
c
c       nom   : character*(*) : nom etendu
c
c     ...........................................................
c
c     sorties : iret   : code de retour :
c
c       -1    : erreur : nom etendu invalide
c        0    : objet non alloue
c        1    : objet structure alloue
c        2    : objet simple    alloue
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
c 0.2. ==> communs
c
c
c 0.3. ==> arguments
c
      character*(*) nom
      integer iret
c
c 0.4. ==> variables locales
c
      character*8 objrep,objter,chater
      integer     idec,ityp 
c
c 1.  decodage du nom etendu
c
      call gbdnoe(nom,objrep,objter,chater,idec)
c
      if (idec.lt.0) then
c
c        nom etendu invalide
c
         iret = -1
c
      else if (idec.eq.0) then
c
c        'nom' n'a qu'un element
c
         call gbobal(objter,ityp,iret)
c
      else if (idec.eq.3) then
c
c        objet-terminal defini et alloue
c
         call gbobal(objter,ityp,iret)
c
      else
c
c        objet-terminal non alloue
c
         iret = 0
c
      endif 
c
      end
