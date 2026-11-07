      subroutine gmlboj ( nom, codret )
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
c     liberation de l'objet terminal de nom etendu "nom"
c     tous les attachements de l'objet sont supprimes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nom    . e   .char(*) . nom etendu de l'objet a liberer            .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  1 : nom d'objet temporaire inconnu        .
c .        .     .        .  0 : OK                                    .
c .        .     .        . -1 : objet-terminal non alloue             .
c .        .     .        . -2 : objet-terminal non defini             .
c .        .     .        . -3 : nom etendu invalide                   .
c .        .     .        . -4 : support introuvable dans les tables   .
c .        .     .        . -5 : champ introuvable dans les tables     .
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
      parameter ( nompro = 'GMLBOJ' )
c
#include "genbla.h"
#include "gmcain.h"
c
c 0.2. ==> communs
c
#include "gmimpr.h"
#include "envex1.h"
#include "gmlang.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*(*) nom
c
      integer codret
c
c 0.4. ==> variables locales
c
      character*8 nomaux
      character*8 objrep, objter, chater
c
      integer iaux
      integer idec
      integer icar, imin, imax
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
c====
c 1.  decodage du nom etendu
c====
c
      call gbdnoe(nom,objrep,objter,chater,idec)
c
      if (idec.lt.0) then
c
c        nom etendu invalide
c
         codret = -3 
c
      else if (idec.eq.1) then
c
c        objet-terminal non defini
c
         codret = -2
c
      else if (idec.eq.2) then
c
c        objet-terminal defini mais non alloue
c
         codret = -1
c
      else
c
c====
c 2. liberation de l'objet alloue
c    detachement de l'objet de tous ses supports
c    si c'est un objet temporaire et que c'est une tete, on le raye
c    de la liste
c====
c
        call gblboj ( objter )
c
        if ( coergm.eq.0 ) then
c
          nomaux = '        '
          call gbdtoj ( nomaux, objter )
          codret = coergm
c
        else
c
          codret = coergm
c
        endif
c
        if ( idec.eq.0 .and. codret.eq.0 ) then
c
          if ( nom(1:1).eq.caint1 ) then
c
c avant de supprimer le nom de la liste des noms d'objets temporaires,
c on verifie que le nom (terminal) a bien la structure d'un nom
c temporaire : un certain nombre (>0) de caracteres caint1 (% a priori),
c suivis d'un entier (le tout, code sur 8 caracteres).
c
            imin = 2
            imax = 11
            do 20 icar = 2, 8
              iaux = index('0123456789'//caint1, objter(icar:icar))
              if (iaux.lt.imin.or.iaux.gt.imax) then
                goto 21
              else
                if (iaux.ne.11) then
                  imin = 1
                  imax = 10
                endif
              endif
   20       continue
            if (imax.ne.11) then
              call gbntde ( objter , iaux )
            endif
          endif
c
        endif
c
      endif
c
   21 continue
c
c====
c 4. Fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
      end
