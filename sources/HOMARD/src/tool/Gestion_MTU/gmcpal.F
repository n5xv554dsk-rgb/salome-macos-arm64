      subroutine gmcpal ( nom1, nom2, typnom, adress, codret )
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
c     copier l'objet 'nom1' a la place de l'objet 'nom2'
c     'nom1' et 'nom2' doivent etre de meme type
c     s'ils sont de type structure : on copie les attributs
c     s'ils sont de type simple    : on copie le contenu
c     si l'objet nom2 n'est pas alloue, on l'alloue
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nom1   . e   . char(*). nom etendu source                          .
c . nom2   . es  .char(*) . nom etendu destinataire                    .
c . typnom . e   .    1   . type du nom de l'objet maillage            .
c .        .     .        . 0 : le nom est a creer automatiquement     .
c .        .     .        . 1 : le nom est impose par l'appel          .
c . adress .  s  .   1    . adresse du tableau s'il est simple         .
c . codret .  s  .   1    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
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
c 0.2. ==> communs
c
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      integer typnom
      integer adress
      integer codret
c
      character*(*) nom1,nom2
c
c 0.4. ==> variables locales
c
      integer idec, iadr, long, nrotab
      integer iret
      integer iaux
c
      character*8 objrep,objter,chater
      character*8   letype
c
      codret = 0
c
c====
c 1.  la structure a copier
c====
c 1.1. ==> decodage du nom etendu de la structure a copier
c
      call gbdnoe(nom1,objrep,objter,chater,idec)
c
      if ( idec.lt.0 ) then
c
         codret = -1
c
      endif
c
c 1.2. ==> type de la structure a copier
c
      if ( codret.eq.0 ) then
c
      call gmobal ( objter, iret )
c
      if ( iret.eq.1 ) then
c
c        objet structure
c
         codret = -1
c
      else if ( iret.eq.2 ) then
c
c        objet simple
c
         call gbcara(objter,nrotab,iadr,long,letype)
         codret = coergm
c
      else
c
         codret = -2
c
      endif
c
      endif
c
c====
c 2. Allocation
c====
c
c 2.1. ==> on verifie que l'objet n'est pas deja alloue
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nom2, codret )
c
      endif
c
c 2.2. ==> allocation
c
      if ( codret.eq.0 ) then
c
      if ( typnom.eq.0 ) then
c
        call gmalot ( nom2, letype, 0, iaux, codret )
c
      elseif ( typnom.eq.1 ) then
c
        call gmaloj ( nom2, letype, 0, iaux, codret )
c
      else
c
        codret = -1
c
      endif
c
      endif
c
c====
c 3. Copie veritable
c====
c
      if ( codret.eq.0 ) then
c
      call gmcpoj (nom1, nom2, codret)
c
      endif
c
c====
c 4. L'adresse pour un objet simple
c====
c
      if ( iret.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nom2, adress, iaux, codret )
c
        endif
c
      endif
c
      end
