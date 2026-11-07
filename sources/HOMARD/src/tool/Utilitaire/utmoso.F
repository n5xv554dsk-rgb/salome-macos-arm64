      subroutine utmoso ( nocsol, option,
     >                    nomobj,
     >                    nbcham, nbpafo, nbprof, nblopg,
     >                    adinch, adinpf, adinpr, adinlg,
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
c    UTilitaire - MOdifie une SOlution
c    --           --          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocsol . e   . char8  . nom de l'objet solution                    .
c . option . e   .    1   . option de la modification :                .
c .        .     .        . 1 : ajout de la fonction nomobj            .
c .        .     .        . 2 : ajout du profil nomobj                 .
c . nomobj . e   . char8  . nom de la fonction a ajouter               .
c . nbcham .   s .   1    . nombre de champs associes                  .
c . nbpafo .   s .   1    . nombre de paquets de fonctions             .
c . nbprof .   s .   1    . nombre de profils associes                 .
c . nblopg .   s .   1    . nombre de localisations de points de Gauss .
c . adinch .   s .   1    . adresse de l'information sur les champs    .
c . adinpf .   s .   1    . adresse de l'inf. sur paquets de fonctions .
c . adinpr .   s .   1    . adresse de l'information sur les profils   .
c . adinlg .   s .   1    . adresse de l'information sur les           .
c .        .     .        . localisations de points de Gauss           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'UTMOSO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbcham, nbpafo, nbprof, nblopg
      integer adinch, adinpf, adinpr, adinlg
c
      character*8 nocsol, nomobj
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
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
      texte(1,10) = '(''Solution avant modification :'')'
      texte(1,4) = '(''Solution apres modification :'')'
c
      texte(2,10) = '(''Solution before modification :'')'
      texte(2,4) = '(''Solution after modification :'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10))
      call gmprsx (nompro, nocsol )
      call gmprsx (nompro, nocsol//'.InfoCham' )
      call gmprsx (nompro, nocsol//'.InfoPaFo' )
      call gmprsx (nompro, nocsol//'.InfoProf' )
      call gmprsx (nompro, nocsol//'.InfoLoPG' )
#endif
c
c====
c 2. caracteristiques de depart
c====
c
      if ( codret.eq.0 ) then
c
      call utcaso ( nocsol,
     >              nbcham, nbpafo, nbprof, nblopg,
     >              adinch, adinpf, adinpr, adinlg,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. ajout d'un paquet de fonction
c====
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
      codret = 123
c
cgn      iaux = nbpafo + 1
cgn      call gmmod ( nocsol//'.InfoPaFo',
cgn     >             adinpf, nbpafo, iaux, 1, 1, codre1 )
cgn      call gmecat ( nocsol, 2, iaux, codre2 )
cgnc
cgn      codre0 = min ( codre1, codre2 )
cgn      codret = max ( abs(codre0), codret,
cgn     >               codre1, codre2 )
cgnc
cgn      smem(adinpf+nbpafo) = nomobj
cgn      nbpafo = nbpafo + 1
c
      endif
c
      endif
c
c====
c 4. ajout d'un profil
c====
c
      if ( option.eq.2 ) then
c
c 4.1. ==> tableau recueillant les noms des profils
c
c 4.1.1. ==> il n'y en avait pas : on en cree
c
      if ( codret.eq.0 ) then
c
      if ( nbprof.eq.0 ) then
c
        iaux = 1
        call gmaloj ( nocsol//'.InfoProf', ' ', iaux, adinpr, codret )
c
c 4.1.2. ==> il y en avait deja : on allonge d'une case
c
      else
c
        iaux = nbprof + 1
        call gmmod ( nocsol//'.InfoProf',
     >               adinpr, nbprof, iaux, 1, 1, codret )
c
      endif
c
      endif
c
c 4.2. ==> enregistrement
c
      if ( codret.eq.0 ) then
c
      iaux = nbprof + 1
      call gmecat ( nocsol, 3, iaux, codret )
c
      smem(adinpr+nbprof) = nomobj
      nbprof = nbprof + 1
c
      endif
c
      endif
c
c====
c 3. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      call gmprsx (nompro, nocsol )
      call gmprsx (nompro, nocsol//'.InfoCham' )
      call gmprsx (nompro, nocsol//'.InfoPaFo' )
      call gmprsx (nompro, nocsol//'.InfoProf' )
      call gmprsx (nompro, nocsol//'.InfoLoPG' )
#endif
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
