      subroutine utmfen ( nhenti, nhent2, nbent2,
     >                    ulsort, langue, codret)
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
c    UTilitaire - passage de Mere a Fille pour les ENtites
c    --                      -      -              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nhenti . e   . char8  . nom de l'objet decrivant l'entite          .
c . nhent2 . e   . char8  . nom de l'objet decrivant l'entite frere    .
c . nbent2 . e   .   1    . nombre d'entite frere                      .
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
      parameter ( nompro = 'UTMFEN' )
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
      character*8 nhenti, nhent2
c
      integer nbent2
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbenti, pfille, pmere, lamere
      integer numead
      integer pfill2
      integer iaux, jaux
      integer ideb, ifin, ideb2
      integer codre1, codre2
      integer codre0
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
      texte(1,4) = '(''... Reperage des filles a partir des meres'')'
      texte(1,5) = '(''. Nombre d''''entites           :'',i10)'
      texte(1,6) = '(''. Nombre d''''entites soeurs    :'',i10)'
      texte(1,7) = '(''. Numero de la mere adoptive :'',i10))'
c
      texte(2,4) = '(''... Son arrays from father arrays'')'
      texte(2,5) = '(''. Number of entities        :'',i10)'
      texte(2,6) = '(''. Number of brother entities:'',i10)'
      texte(2,7) = '(''. Number for adoptive mother:'',i10))'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. recuperation des donnees du maillage d'entree
c====
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nhenti )
#endif
c
c 2.1. ==> Parente
c
      call gmliat ( nhenti, 1, nbenti, codre1 )
      call gmadoj ( nhenti//'.Mere', pmere, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nbenti
      write (ulsort,texte(langue,6)) nbent2
#endif
c
c 2.2. ==> Eventuelle parente adoptive
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD03', nompro
#endif
      iaux = 5
      call utad03 ( iaux, nhenti,
     >              jaux, jaux, numead,
     >              jaux, jaux,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) numead
#endif
c
      endif
c
c====
c 3. Creation du tableau des filles
c    Attention, la convention homard veut que le tableau soit cree,
c    meme s'il est vide
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Creation tableau ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      if ( nbenti.le.50 ) then
        call gmprsx (nompro, nhenti//'.Mere' )
      else
        call gmprot (nompro, nhenti//'.Mere', 1, 50)
        call gmprot (nompro, nhenti//'.Mere', max(51,nbenti-50),nbenti )
      endif
#endif
c
      call gmobal ( nhenti//'.Fille', codre1 )
c
      if ( codre1.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Allocation avec nbenti', nbenti
#endif
        call gmaloj ( nhenti//'.Fille', ' ', nbenti, pfille, codre2 )
c
        if ( codre2.eq.0 ) then
c
        ideb = pfille
        ifin = pfille + nbenti - 1
        do 31 , iaux = ideb , ifin
          imem(iaux) = 0
   31   continue
c
        endif
c
      elseif ( codre1.eq.2 ) then
c
        call gmadoj ( nhenti//'.Fille', pfille, iaux, codre2 )
        codre1 = 0
c
      else
        codre2 = 2
c
      endif
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 4. Entite frere eventuelle
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Entite frere eventuelle ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbent2.ne.0 ) then
c
        call gmobal ( nhent2//'.Fille', codre1 )
c
        if ( codre1.eq.0 ) then
c
          call gmaloj ( nhent2//'.Fille', ' ', nbent2, pfill2, codre2 )
c
          if ( codre2.eq.0 ) then
c
          ideb = pfill2
          ifin = pfill2 + nbent2 - 1
          do 41 , iaux = ideb , ifin
            imem(iaux) = 0
   41     continue
c
          endif
c
        elseif ( codre1.eq.2 ) then
c
          call gmadoj ( nhent2//'.Fille', pfill2, iaux, codre2 )
          codre1 = 0
c
        else
          codre2 = 2
c
        endif
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
c
      endif
c
c====
c 5. traitement
c    pour chaque entite qui est fille, on marque la mere
c    attention : la convention homard veut que seule la fille
c                ainee soit marquee
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. traitement ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      ideb = pfille - 1
      ifin = nbenti - 1
c
c 5.1. ==> sans entite frere
c
      if ( nbent2.eq.0 ) then
c
        do 51 , iaux = 0 , ifin
c
          lamere = imem(pmere+iaux)
c
c       lamere > 0 : il existe une mere
c
          if ( lamere.gt.0 ) then
            if ( imem(ideb+lamere).eq.0 ) then
              imem(ideb+lamere) = iaux + 1
            endif
          endif
c
   51   continue
c
c 5.2. ==> avec une entite frere
c
      else
c
        ideb2 = pfill2 - 1
c
        do 52 , iaux = 0 , ifin
c
          lamere = imem(pmere+iaux)
c
c       lamere > 0 : il existe une mere et elle est de meme type
c                    que la fille
c
cgn          print *,'Face =', iaux+1,' ==> lamere =', lamere
          if ( lamere.gt.0 ) then
            if ( imem(ideb+lamere).eq.0 ) then
              imem(ideb+lamere) = iaux + 1
            endif
c
c       lamere < 0 : il existe une mere et elle est du type frere de
c                    celui de la fille
c       attention : il ne faut rien faire quand ce numero vaut
c                   le numero de mere adoptive. Cela signifie que c'est
c                   une mere adoptive pour traiter les non conformites
c                   initiales. S'il n'y en a pas, numead vaut 0
c
          elseif ( lamere.lt.0 .and. lamere.ne.numead ) then
            if ( imem(ideb2-lamere).eq.0 ) then
              imem(ideb2-lamere) = -( iaux + 1 )
            endif
          endif
c
   52   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( nbenti.le.50 ) then
        call gmprsx (nompro, nhenti//'.Mere' )
      else
        call gmprot (nompro, nhenti//'.Mere', 1, 50)
        call gmprot (nompro, nhenti//'.Mere', max(51,nbenti-50), nbenti)
      endif
      if ( nbenti.le.50 ) then
        call gmprsx (nompro, nhenti//'.Fille' )
      else
        call gmprot (nompro, nhenti//'.Fille', 1, 50)
        call gmprot (nompro, nhenti//'.Fille', max(51,nbenti-50),nbenti)
      endif
#endif
c
      endif
c
c====
c 6. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
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
