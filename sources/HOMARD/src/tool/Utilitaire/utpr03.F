      subroutine utpr03 ( option,
     >                    nbento, profil, nensca,
     >                    nbvapr, obprof,
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
c    UTilitaire - PRofil operation 03
c    --           --               --
c
c  On a en entree un tableau indexe par la numerotation HOMARD des
c  entites d'un type donne. La valeur vaut 1 si l'entite appartient au
c  profil, 0 sinon. On a en sortie un profil de calcul, c'est-a-dire une
c  liste d'entites exprimees en numerotation du calcul. Cette liste est
c  compacte.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . 1 : on traite la liste brutalement         .
c .        .     .        . 2 : on doit utiliser une renumerotation    .
c . nbento . e   .   1    . nombre total d'entites                     .
c . profil . e   . nbento . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . nensca . e   .   *    . numero des entites dans le calcul          .
c . nbvapr .   s .   1    . nombre de valeurs du profil en sortie      .
c .        .     .        . -1, si pas de profil                       .
c . obprof .   s . char*8 . nom de l'objet de type 'Profil' equivalent .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . -2 : mauvaise demande pour l'option        .
c .        .     .        . autre : probleme dans l'allocation         .
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
      parameter ( nompro = 'UTPR03' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbento, nbvapr
      integer profil(nbento)
      integer nensca(*)
c
      character*8 obprof
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer adlipr
      integer numero
c
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data numero / 0 /
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Option :'',i4)'
      texte(1,5) = '(''Mauvaise demande d''''option :'',i8)'
      texte(1,6) = '(''Nom du profil cree : '',a)'
      texte(1,7) = '(''Longueur du profil : '',i10)'
      texte(1,8) = '(''Objet profil cree : '',a)'
c
      texte(2,4) = '(''Option :'',i4)'
      texte(2,5) = '(''Bad request for the option :'',i8)'
      texte(2,6) = '(''Name of created profile : '',a)'
      texte(2,7) = '(''Length of profile : '',i10)'
      texte(2,8) = '(''Created profile object : '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) option
#endif
c
c====
c 2. creation du profil
c====
c 2.1. ==> nom du profil
c
      numero = numero + 1
      call utench ( numero, '0', iaux, noprof,
     >              ulsort, langue, codret )
c
      noprof(1:8) = 'PROFIL__'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) noprof
#endif
c
c 2.2. ==> longueur du profil
c
      if ( codret.eq.0 ) then
c
      nbvapr = 0
      do 22 , iaux = 1 , nbento
        if ( profil(iaux).eq.1 ) then
          nbvapr = nbvapr + 1
        endif
   22 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nbvapr
#endif
c
      endif
c
c 2.3. ==> allocation de l'objet
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALPR', nompro
#endif
      call utalpr ( obprof,
     >              nbvapr, noprof,
     >              adlipr,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) obprof
#endif
c
c 2.4. ==> remplissage du profil
c
      if ( codret.eq.0 ) then
c
c 2.4.1. ==> brutalement
c
      if ( option.eq.1 ) then
c
        nbvapr = 0
        do 241 , iaux = 1 , nbento
          if ( profil(iaux).eq.1 ) then
            imem(adlipr+nbvapr) = iaux
            nbvapr = nbvapr + 1
          endif
  241   continue
c
c 2.4.2. ==> avec renumerotation
c
      elseif ( option.eq.2 ) then
c
        nbvapr = 0
        do 242 , iaux = 1 , nbento
          if ( profil(iaux).eq.1 ) then
            imem(adlipr+nbvapr) = nensca(iaux)
            nbvapr = nbvapr + 1
          endif
  242   continue
c
c 2.n. ==> erreur
c
      else
c
        write (ulsort,texte(langue,5)) option
        codret = -2
c
      endif
c
      endif
cgn      call gmprsx (nompro,obprof)
cgn      call gmprsx (nompro,obprof//'.NomProfi')
cgn      call gmprsx (nompro,obprof//'.ListEnti')
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
