      subroutine gmstop ( gmimp )
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
c but : arrete le programme proprement
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . gmimp  . e   .    1   . 0 => pas d'impression                      .
c .        .     .        . 1 => bilan d'utilisation de la memoire     .
c .        .     .        . 2 => impressions des tables des objets     .
c .        .     .        .      dans l'etat courant                   .
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
#include "gmmatc.h"
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmtoai.h"
#include "gmtoas.h"
#include "gmtors.h"
c
#include "gmtren.h"
#include "gmtrrl.h"
#include "gmtrst.h"
c
#include "gmalen.h"
#include "gmalrl.h"
#include "gmalst.h"
c
#include "gminds.h"
c
#include "gmimpr.h"
c
c 0.3. ==> arguments
c
      integer gmimp
c
c 0.4. ==> variables locales
c
      integer codret
      integer iaux, nbrobj, letype
c
      character*8 obrepc, obterc, chterc
      character*8 nomost(nobjx), nomosi(maxtab)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. impressions gm
c    en deboggage, on imprime quelle que soit la valeur de gmimp
c    em mode standard, on n'imprime que si gmimp est superieur a 1
c====
c
#ifdef _DEBUG_HOMARD_
      iaux = gmimp
#else
      if ( gmimp.le.2 ) then
        iaux = 2
      else
        iaux = gmimp
      endif
#endif
c
      if ( gmimp.ge.iaux ) then
c
         call dmflsh (iaux)
         call gmdmp ( nomtyb(1), gmimp )
         call gmdmp ( nomtyb(2), gmimp )
         call gmdmp ( nomtyb(3), gmimp )
         call gmdmp ( nomtyb(4), gmimp )
         call dmflsh (iaux)
c
      endif
c
c====
c 2. desallocation de tous les objets presents en memoire centrale
c    il est plus rapide de commencer par tous les simples. Ainsi,
c    quand on desallouera les structures, il n'y aura que des problemes
c    de graphes a regler
c====
c
c 2.1. ==> liberation des objets simples
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Debut etape 2.1'
      call dmflsh (iaux)
#endif
c
c 2.1.1. ==> les entiers
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Debut etape 2.1.1 avec nbrobj = ',nballi
      call dmflsh (iaux)
#endif
c
      nbrobj = nballi
      do 2111 , iaux = 1 , nbrobj
        nomosi(iaux) = nomali(iaux)
 2111 continue
c
      do 2112 , iaux = nbrobj , 1 , -1
        call gmdesa ( nomosi(iaux) )
 2112 continue
c
c 2.1.2. ==> les reels
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Debut etape 2.1.2 avec nbrobj = ',nballr
      call dmflsh (iaux)
#endif
c
      nbrobj = nballr
      do 2121 , iaux = 1 , nbrobj
        nomosi(iaux) = nomalr(iaux)
 2121 continue
c
      do 2122 , iaux = nbrobj , 1 , -1
        call gmdesa ( nomosi(iaux) )
 2122 continue
c
c 2.1.3. ==> les chaines
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Debut etape 2.1.3 avec nbrobj = ',nballs
      call dmflsh (iaux)
#endif
c
      nbrobj = nballs
      do 2131 , iaux = 1 , nbrobj
        nomosi(iaux) = nomals(iaux)
 2131 continue
c
      do 2132 , iaux = nbrobj , 1 , -1
        call gmdesa ( nomosi(iaux) )
 2132 continue
c
c 2.1.6. ==> bilan
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Debut etape 2.1.6'
      call dmflsh (iaux)
#endif
c
c 2.2. ==> les objets structures
c          en fait il suffit de s'interesser aux tetes
c         attention : la liberation d'un objet structure conduit au
c                     compactage des listes. Il faut donc boucler sur le
c                     nombre initial d'objets structures et s'interesser
c                     a la liste initiale. En effet la liste courante
c                     sera remaniee.
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Debut etape 2.2'
      call dmflsh (iaux)
#endif
c
      nbrobj = iptobj-1
      do 221 , iaux = 1 , nbrobj
         nomost(iaux) = nomobj(iaux)
  221 continue
c
      do 222 , iaux = nbrobj , 1 , -1
c
         call gbdnoe (nomost(iaux),obrepc,obterc,chterc,codret)
c
         if ( codret.ge.0 .and. nomost(iaux).ne.sindef ) then
c
            call gbobal ( nomost(iaux) , letype , codret )
c
            if ( codret.ne.0) then
               call gmsgoj ( nomost(iaux) , codret )
               if ( codret.ne.0) then
                 write(ulsort,20000) nomost(iaux), codret
               endif
            endif
c
         else
c
              write(ulsort,*) 'gmstop --> gbdnoe : codret = ',codret
c
         endif
c
  222 continue
c
20000 format(' GMSTOP pb a la suppression de l''objet ',a8,
     >     /,' Code retour de la suppression : ',i5)
c
#ifdef _DEBUG_HOMARD_
      call gmdmp ( nomtyb(4), gmimp )
#endif
c
c====
c 3. statistiques gm
c====
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) '3. statistiques gm'
      call dmflsh (iaux)
#endif
c
      call gmstat ( gmimp )
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Fin de gmstop'
      call dmflsh (iaux)
#endif
c
      end
