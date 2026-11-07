      subroutine dmvaen ( nomvar, lgnova, nomuti, lgnout,
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
c   Dependance Machine - decodage d'une VAriable d'ENvironnement
c   -          -                        --         --
c ______________________________________________________________________
c
c
c but : decode les variables d'environnement
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomvar . e   . char*  . nom de la variable a decoder               .
c . lgnova . e   .   i    . longueur reelle de nomvar                  .
c . nomuti .  s  . char*  . nom utilisable pour cette variable         .
c . lgnout .  s  .   i    . longueur reelle de nomuti                  .
c . ulsort . e   .    1   . unite logique de la liste standard         .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : impossible de decoder la variable      .
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
      parameter ( nompro = 'DMVAEN' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      character*(*) nomvar, nomuti
c
      integer lgnova, lgnout
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, lgmax
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      parameter ( lgmax = 200 )
c ______________________________________________________________________
c
c====
c 1.  messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Variable d''''environnement :'')'
      texte(1,5) = '(''Impossible de la decoder.'')'
      texte(1,6) = '(''Valeur interpretee :'')'
c
      texte(2,4) = '(''Environment variable :'')'
      texte(2,5) = '(''It cannot be uncoded.'')'
      texte(2,6) = '(''It is equal to :'')'
c
c====
c 2. appel a la fonction machine
c====
c
      lgnout = 0
c
      do 2 iaux = 1 , len(nomuti)
        nomuti(iaux:iaux) = ' '
    2 continue
c
c 2.1. ==> attention a la taille maximale ...
c
      if ( lgnova.le.0 .or. lgnova.gt.len(nomvar) ) then
c
        codret = 1
c
      else
c
c 2.2. ==> appel a la fonction standard ailleurs et
c          comptage du nombre de lettres effectives
c
c NB: sous WINDOWS + Visual Fortran 6.0, l'appel a getenv impose
c     le rajout de la bibliotheque Dfport.lib
c     pour que l'edition des liens se passe bien.
c
        call getenv ( nomvar(1:lgnova) , nomuti )
c
        do 221 , iaux = 1 , min(lgmax,len(nomuti))
          if ( nomuti(iaux:iaux).eq.' ' ) then
            codret = 0
            goto 222
          endif
          lgnout = lgnout + 1
  221   continue
c
        codret = 1
c
  222   continue
c
c nettoyage eventuel:
c
        call dmcpch( nomuti, lgnout, nomuti, lgnout )
c
      endif
c
c====
c 3. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      iaux = -1
#else
      iaux = 0
#endif
c
      if ( codret.ne.iaux ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
        write (ulsort,texte(langue,4))
        if (min(lgnova,len(nomvar)).ge.1) then
          write (ulsort,*) nomvar( 1 : min(lgnova,len(nomvar)) )
        else
          write (ulsort,*)
        endif
        if ( codret.eq.1 ) then
          write (ulsort,texte(langue,5))
        else
          if ( iaux.eq.-1 ) then
            write (ulsort,texte(langue,6))
            if (lgnout.ge.1) then
              write (ulsort,*) nomuti(1:lgnout)
            else
              write (ulsort,*)
            endif
          endif
        endif
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
