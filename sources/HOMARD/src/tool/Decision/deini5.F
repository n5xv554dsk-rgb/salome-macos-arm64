      subroutine deini5 ( obfigr,
     >                    nbvnoe, nbvare,
     >                    nbvtri, nbvqua,
     >                    nbvtet, nbvhex, nbvpyr, nbvpen,
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
c traitement des DEcisions - INITialisations - phase 5
c                --          ---                     -
c ______________________________________________________________________
c  Recuperation des nombres de valeurs d'entites concernees par
c  l'option de raffinement uniforme par des groupes.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . obfigr . e   . char*8 . filtrage de l'adaptation selon des groupes .
c . nbvent .  s  .   1    . nombre de valeurs pour l'entite            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'DEINI5' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 obfigr
c
      integer nbvnoe, nbvare
      integer nbvtri, nbvqua
      integer nbvtet, nbvhex, nbvpyr, nbvpen
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer typenh
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. Initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.1. ==>les messages
c
      texte(1,4) = '(''Donnees pour les '',a)'
c
      texte(2,4) = '(''Data for the '',a)'
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro, obfigr )
#endif
c
c====
c 2. Boucle sur tous les types d'entites (cf. vcfia0)
c====
c
      do 21 , typenh = -1 , 7
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
c
c 2.1. ==> Longueur de la branche de memorisation
c
        if ( codret.eq.0 ) then
c
        iaux = typenh + 2
        call gmliat ( obfigr, iaux, jaux, codret )
c
        endif
c
c 2.2. ==> Enregistrement
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.-1 ) then
          nbvnoe = jaux
ccc        elseif ( typenh.eq.0 ) then
ccc          nbvmpo = jaux
        elseif ( typenh.eq.1 ) then
          nbvare = jaux
        elseif ( typenh.eq.2 ) then
          nbvtri = jaux
        elseif ( typenh.eq.3 ) then
          nbvtet = jaux
        elseif ( typenh.eq.4 ) then
          nbvqua = jaux
        elseif ( typenh.eq.5 ) then
          nbvpyr = jaux
        elseif ( typenh.eq.6 ) then
          nbvhex = jaux
        elseif ( typenh.eq.7 ) then
          nbvpen = jaux
        endif
c
        endif
c
   21 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*)
     >' nbvnoe, nbvare, nbvtri, nbvqua, nbvtet, nbvhex, nbvpyr, nbvpen'
      write (ulsort,4444) nbvnoe, nbvare,
     >                    nbvtri, nbvqua,
     >                    nbvtet, nbvhex, nbvpyr, nbvpen
 4444 format(8i8)
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
