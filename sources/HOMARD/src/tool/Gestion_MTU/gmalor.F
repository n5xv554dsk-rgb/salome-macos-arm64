      subroutine gmalor( nomtab, pointe, nb)
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
c ......................................................................
c .  derniere modif decembre 93 appel au programme general
c .           modif juin 93 ntrour=0 + divers
c .           modif 15/06/89 jc jyb
c ......................................................................
c .
c .       allocation d'un tableau dans le common gmreel
c .
c .  - arguments:
c .       donnees a l'appel  nomtab -->  nom de la variable a allouer
c .                                      de 8 caracteres au plus
c .                            nb   -->  nombre de reels demandes
c .       resultat          pointe  <--  pointeur associe
c ......................................................................
c----
c 0. declarations et dimensionnement
c----
c
c
c 0.1. ==> generalites
c
      implicit none
      save
c
      character*6 nompro
      parameter ( nompro = 'GMALOR' )
c
#include "genbla.h"
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmreel.h"
#include "gmadur.h"
#include "gmtrrl.h"
#include "gmalrl.h"
#include "gmindf.h"
#include "gmindr.h"
#include "envex1.h"
#include "gmimpr.h"
#include "gmcoer.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      integer pointe , nb
c
      character*(*) nomtab
c
c 0.4. ==> variables locales
c
      integer iaux
      integer i, ideb, ifin
c
      character*1 typtab
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
c
c ----
c  2. allocation du tableau par le programme generique
c----
c
      typtab = 'r'
      call gmalog ( nomtab, pointe, nb, typtab,
     >      minmer, ntrour, nballr, totalr,
     >      ptrour, ltrour, ptallr, lgallr,adur,
     >      nommxr, nomalr )
c
c---
c 3. au depart, le tableau sera mis a une valeur indefinie, vues
c    les options de compilation.
c    si on alloue apres avoir fait des desallocations, on peut
c    se retrouver dans le tableau rmem a un endroit qui etait occupe
c    autrefois par quelque chose : on recupere alors les valeurs
c    de l'epoque.
c    toutefois cela n'est pas possible en compression car on risque
c    de detruire le debut du tableau que l'on deplace
c    tout ceci est pilote par lindef
c---
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Etape 3 de gmalor , coergm = ', coergm
#endif
c
      if ( coergm.eq.0 ) then
c
      if ( lindef.eq.0 ) then
        ideb = pointe
        ifin = pointe + nb - 1
c  rmem est en fait du double precision
        do 30 , i = ideb , ifin
          rmem(i) = rindef
   30   continue
      endif
c
      endif
c
c====
c 4. Fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Fin de gmalor'
#endif
c
      if ( coergm.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
      end
