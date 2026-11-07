      subroutine gbntde ( nom , codret )
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
c     detruit un nom d'objet temporaire
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nom    . e   . char*8 . nom de l'objet temporaire a retirer        .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
c .        .     .        .  2 : objet inconnu                         .
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
#include "gmmaxt.h"
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtenb.h"
#include "gmteno.h"
#include "gminds.h"
#include "gmimpr.h"
c
c 0.3. ==> arguments
c
      character*8 nom
      integer     codret
c
c 0.4. ==> variables locales
c
      integer numero, iaux
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. exploration de la liste
c====
c
      do 21 iaux = mxtbtp, 1, -1
         if ( nomalt(iaux).eq.nom ) then
            numero = iaux
            goto 22
         endif
   21 continue
c
         codret = 2
c
         write (ulsort,*) 'SP GBNTDE :'
         write (ulsort,*) 'Probleme a la destruction' 
         write (ulsort,*) '(nom temporaire a detruire non trouve)'
         write (ulsort,*) 'Nom de l''objet detruit : ', nom
         write (ulsort,*) 'Nombre maxi de noms temporaires ', maxtbt
         write (ulsort,*) 'Numero maxi atteint ', mxtbtp
         write (ulsort,*) 'Les 5 premiers noms sont :'
         write (ulsort,10000) (iaux,nomalt(iaux),iaux=1,5)
c
         goto 999
c
   22 continue
c
         numete(numero) = 0
         nomalt(numero) = sindef
         codret = 0
c
         if (numero.eq.mxtbtp) then
c
           do 23 iaux = numero-1, 1, -1
             if ( numete(iaux).ne.0 ) then
               mxtbtp = iaux
               goto 24
             endif
   23      continue
           mxtbtp = 0
   24      continue
c
         endif
c
#ifdef _DEBUG_HOMARD_
c
        write (ulsort,*) 'SP GBNTDE : OK'
        write (ulsort,*) 'Numero tmp et nom de l''objet detruit : ',
     >                   numero,' ',nom
        write (ulsort,*) 'Les 5 premiers noms sont :'
        write (ulsort,10000) (iaux,nomalt(iaux),iaux=1,5)
c
#endif
c
10000 format(5(i5,' : ',a8,' | '))
c
  999 continue
c
      end
