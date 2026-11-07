      subroutine gbntcr ( nom )
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
c     cree un nouveau nom d'objet temporaire
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nom    .  s  . char*8 . nom de l'objet temporaire                  .
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
#include "gmcain.h"
c
c 0.2. ==> communs
c
#include "gmtenb.h"
#include "gmteno.h"
#ifdef _DEBUG_HOMARD_
#include "gmimpr.h"
#endif
c
c 0.3. ==> arguments
c
      character*(*) nom
c
c 0.4. ==> variables locales
c
      integer numero, iaux
c
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
c
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
c====
c 1. determination d'un nouveau nom
c    on lui impose de commencer par le premier caractere interdit
c    on recherche un numero non utilise. il y en a forcement un
c    car on s'autorise 3*maxtab+nobjx tableaux temporaires ce qui est le
c    nombre maxi de tableaux en general. Or ce dernier sera
c    forcement atteint avant (NB: il y a 3 types possibles pour les
c    objets simples, d'ou le 3*maxtab).
c====
c
      nom = caint1//caint1//caint1//caint1//caint1//caint1//caint1//' '
c
      do 11 iaux = 1 , mxtbtp
         if ( numete(iaux).eq.0 ) then
            numero = iaux
            goto 13
         endif
   11 continue
c
      if ( mxtbtp.lt.maxtbt ) then
        mxtbtp = mxtbtp + 1
      endif
      numero = max( 1, min(mxtbtp,9999999) )
c
   13 continue
c
      if ( numero.lt.10 ) then
         write ( nom(8:8),'(i1)') numero
      elseif ( numero.lt.100 ) then
         write ( nom(7:8),'(i2)') numero
      elseif ( numero.lt.1000 ) then
         write ( nom(6:8),'(i3)') numero
      elseif ( numero.lt.10000 ) then
         write ( nom(5:8),'(i4)') numero
      elseif ( numero.lt.100000 ) then
         write ( nom(4:8),'(i5)') numero
      elseif ( numero.lt.1000000 ) then
         write ( nom(3:8),'(i6)') numero
      else
         write ( nom(2:8),'(i7)') numero
      endif
c
      numete(numero) = 1
      nomalt(numero) = nom
c
#ifdef _DEBUG_HOMARD_
      jaux = 5
      write (ulsort,*) 'SP GBNTCR :'
      write (ulsort,*) 'Numero et nom du dernier objet : ',
     >numero,' ',nom
      write (ulsort,*) 'Les ',jaux,' premiers noms sont :'
      write (ulsort,10000) (iaux,nomalt(iaux),iaux=1,jaux)
10000 format(5(i5,' : ',a8,' | '))
#endif
c
      end
