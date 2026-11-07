      subroutine esecf0 ( idfmed, nomamd,
     >                    typenh, nbfent, numfam, nhenti,
     >                    tbiaux,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : ECriture des Familles d'une entite - 0
c  -      -        --           -                       -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . typenh . e   .   1    . code des entites                           .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nbfent . e   .   1    . nombre de familles d'entites (cf. nbfami)  .
c . numfam . es  .   1    . numerotation des familles                  .
c . nhenti . e   . char*8 . objet decrivant l'entite                   .
c . tbiaux .     .    *   . tableau tampon entier                      .
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
      parameter ( nompro = 'ESECF0' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "enti01.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer typenh, nbfent, numfam
      integer tbiaux(*)
c
      character*64 nomamd
      character*8 nhenti
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer nbgrox
      parameter (nbgrox = 10 )
c
      integer iaux, jaux, kaux, laux
      integer cptr, kfin, reste
      integer codre1
      integer adcofa
      integer adcoen
      integer nbcode, ngro
c
      character*8 saux08
      character*80 nomgro(nbgrox)
      character*64 saux64
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''. Ecriture des'',i4,'' familles des '',a)'
      texte(1,5) = '(''... Ecriture de la'',i4,''-ieme famille'')'
      texte(1,6) = '(''Probleme de dimensionnement de nomgro.'')'
c
      texte(2,4) = '(''. Writings of'',i4,'' families for '',a)'
      texte(2,5) = '(''... Writings of the'',i4,''-th family'')'
      texte(2,6) = '(''Error in size of array nomgro.'')'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbfent, mess14(langue,3,typenh)
      call gmprsx ( nompro, nhenti//'.Famille' )
      call gmprsx ( nompro, nhenti//'.Famille.Codes' )
cc      call gmprsx ( nompro, nhenti//'.Famille.Groupe' )
#endif
c
c====
c 2. Gestion de la memoire
c====
c 2.1. ==> Determination des adresses
c 2.1.1. ==> pour les noeuds
c
      if ( typenh.lt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
        iaux = 7
        call utad01 (   iaux, nhenti,
     >                  jaux,
     >                  jaux, adcofa,   jaux,
     >                  jaux,   jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
c 2.1.2. ==> pour les mailles
c
      else
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD02', nompro
#endif
        iaux = 37
        call utad02 (   iaux, nhenti,
     >                  jaux,   jaux,   jaux,   jaux,
     >                  jaux, adcofa,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
c 2.2. ==> Nombre de codes definissant les familles
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhenti//'.Famille', 2, nbcode, codre1 )
c
      codret = max ( codret,
     >               abs(codre1) )
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbcode', nbcode
#endif
c
      endif
c
c====
c 3. Ecritures
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Ecritures ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      adcoen = adcofa - 1
      do 31 , iaux = 1 , nbfent
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) iaux
      call gmprsx ( nompro, nhenti//'.Famille.Codes' )
#endif
c
        if ( codret.eq.0 ) then
c
c       fabrication du numero de la famille a ecrire
c
        if ( typenh.lt.0 ) then
          numfam = numfam + 1
        else
          numfam = numfam - 1
        endif
c
c       fabrication du nom de la famille a ecrire
c
        call utench ( numfam, '_', jaux, saux08,
     >                ulsort, langue, codret )
c
        saux64 = blan64
        saux64(1:2) = suffix(3,typenh)(1:2)
        saux64( 3:10) = saux08
c
c       les valeurs entieres a memoriser
c       . le numero de la famille
        tbiaux(1) = iaux
c
c       . les nctfen codes definissant les familles
        do 311 , jaux = 1, nbcode
          tbiaux(jaux+1) = imem(adcoen+jaux)
  311   continue
        adcoen = adcoen + nbcode
c
        endif
c
c       fabrication d'un nom de groupe contenant ces valeurs
c       . Les 8 1ers caracteres sont 'Attribut' obligatoirement, pour
c         se reperer dans le dump
c       . Les caracteres de 2 a nbcode+1 sont les nbcode codes
c         convertis en chaine
c        Remarque : cela suppose qu'il n'y a pas plus de 9 codes
c        et que chaque code est inferieur a 10**8
c
c       nombre de paquets
c
        if ( codret.eq.0 ) then
c
        reste = mod(nbcode+1,9)
        ngro = (nbcode+1-reste)/9
        if ( reste.gt.0 ) then
          ngro = ngro + 1
        endif
        if ( ngro.gt.nbgrox ) then
          codret = 31
        endif
cgn        write(ulsort,*) 'Famille : ', saux64
cgn        write(ulsort,90002) 'nbcode  ', nbcode
cgn        write(ulsort,90002) 'reste ', reste
cgn        write(ulsort,90002) 'ngro  ', ngro
c
        endif
c
        if ( codret.eq.0 ) then
c
        cptr = 0
        do 312 , jaux = 1, ngro
c
          nomgro(jaux) = blan80
c                      12345678
          nomgro(jaux)(1:8) = 'Attribut'
          if ( jaux.lt.ngro .or. reste.eq.0 ) then
            kfin = 9
          else
            kfin = reste
          endif
          do 3121 , kaux = 1, kfin
            cptr = cptr + 1
            call utench ( tbiaux(cptr), 'd', laux, saux08,
     >                    ulsort, langue, codret )
            nomgro(jaux)(8*kaux+1:8*(kaux+1)) = saux08
 3121     continue
  312   continue
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Famille : ', saux64
      write(ulsort,90002) 'nbcode', nbcode
      if ( nbcode.gt.0 ) then
        write(ulsort,90002) '.', (tbiaux(jaux),jaux=1,nbcode+1)
      endif
      write(ulsort,90002) 'ngro', ngro
      write(ulsort,*) nomgro
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFACRE', nompro
#endif
        call mfacre ( idfmed, nomamd, saux64, numfam,
     >                ngro, nomgro, codret )
c
        if ( codret.ne.0 ) then
          write(ulsort,texte(langue,78)) 'mfacre', codret
        endif
c
        endif
c
   31 continue
c
      endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      if ( codret.eq.31 ) then
        write(ulsort,90002) 'ngro  ', ngro
        write(ulsort,90002) 'nbgrox', nbgrox
        write (ulsort,texte(langue,6))
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
