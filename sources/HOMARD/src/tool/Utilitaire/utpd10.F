      subroutine utpd10 ( val, val10, pd10,
     >                    ulsort, langue, codret )
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
c    UTilitaire - Puissance De 10
c    --           -         -  --
c    on retourne val10 et pd10 tels que val = val10 * 10**pd10
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . val    . e   .   1    . valeur a tester                            .
c . val10  .   s .   1    . triteur de la puissance de 10              .
c . pd10   .   s .   1    . puissance de 10 de la valeur :             .
c .        .     .        . x = 0.abc*10**n                            .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'UTPD10' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "infini.h"
c
c 0.3. ==> arguments
c
      double precision val, val10
c
      integer pd10
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      double precision valabs, daux
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Valeur a traiter ='',g25.17)'
      texte(1,5) = '(''Puissance de 10  ='',i4)'
      texte(1,6) = '(''==> '',g25.17,'' * 10**'',i4)'
c
      texte(2,4) = '(''Value       ='',g25.17)'
      texte(2,5) = '(''Power of 10 ='',i4)'
      texte(2,6) = '(''==> '',g25.17,'' * 10**'',i4)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) val
#endif
c
      codret = 0
c
c====
c 2. traitement
c====
c
      valabs = abs(val)
c
c 2.1. ==> cas de la valeur nulle
c
      if ( valabs.le.zeroma ) then
c
        pd10 = 0
        val10 = val
c
c 2.2. ==> valeur tres grande
c
      elseif ( valabs.ge.vinfpo ) then
c
        pd10 = 0
        val10 = val
c
c 2.3. ==> valeur moyenne
c
      else
c
        daux = log10(valabs)
        pd10 = int(daux)
cgn        print *,daux,pd10
        if ( daux.ge.0.d0 ) then
          pd10 = 1+pd10
        endif
c
        val10 = val * 10.d0**(-pd10)
cgn 1000 format(5g25.17)
cgn         print 1000,val,val10,val10*10.d0**(pd10)
cgn         print 1000,val-val10*10.d0**(pd10)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) pd10
      write (ulsort,texte(langue,6)) val10, pd10
#endif
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
