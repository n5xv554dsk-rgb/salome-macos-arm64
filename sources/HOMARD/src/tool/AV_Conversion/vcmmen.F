      subroutine vcmmen ( nbeled, nbelef,
     >                    nbmaid, nbmaif,
     >                    noeele, fameel, typele, nuelex,
     >                    numfam,
     >                    grfmpo, grfmtl, grfmtb,
     >                    tbaux1, tbaux2, tbaux3,
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
c    aVant adaptation - Conversion de Maillage - MENage
c     -                 -             -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbeled . e   .   1    . nombre d'elements au debut                 .
c . nbelef .  s  .   1    . nombre d'elements a la fin                 .
c . nbmaid . e   .   1    . nombre de mailles au debut                 .
c . nbmaif .  s  .   1    . nombre de mailles a la fin                 .
c . noeele . es  . nbeled . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . fameel . es  . nbeled . famille med des elements                   .
c . typele . es  . nbeled . type des elements pour le code de calcul   .
c . nuelex . es  . nbelem . numerotation des elements en exterieur     .
c . tbaux1 . aux . nbeled . tableau de travail                         .
c . tbaux2 . aux . nbfmed . tableau de travail                         .
c . tbaux3 . aux . nbfmed . tableau de travail                         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'VCMMEN' )
c
#include "consts.h"
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nbutil.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbeled, nbelef
      integer nbmaid, nbmaif
      integer noeele(nbeled,nbmane)
      integer fameel(nbeled), typele(nbeled), nuelex(nbelem)
      integer numfam(nbfmed), grfmpo(0:nbfmed), grfmtl(*)
      integer tbaux1(nbeled), tbaux2(nbfmed), tbaux3(nbfmed)
c
      character*8 grfmtb(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer nbfami, indice
c
      character*80 nomgro
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
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
      texte(1,4) = '(''Groupe : '',a)'
      texte(1,5) = '(''Numero dans le calcul   : '',i10)'
      texte(1,6) = '(''Famille MED : '',i4,'' ; type : '',i4)'
c
      texte(2,4) = '(''Group: '',a)'
      texte(2,5) = '(''# in calculation    : '',i10)'
      texte(2,6) = '(''MED family : '',i4,'' ; type : '',i4)'
c
#include "impr03.h"
c
      codret = 0
c
      nbfami = 0
c
c====
c 2. on passe en revue chaque groupe de mailles doubles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfmed', nbfmed
#endif
c
c 2.1. ==> Famille du groupe 'R_20_b'
c
      nomgro = blan80
      nomgro(1:6) = 'R_20_b'
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomgro
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFMGR', nompro
#endif
      call utfmgr ( nomgro, jaux, tbaux3,
     >              nbfmed, numfam,
     >              grfmpo, grfmtl, grfmtb,
     >              ulsort, langue, codret )
c
cgn      write (ulsort,90002) '==> nombre de familles', jaux
      do 21 , iaux = 1 , jaux
        nbfami = nbfami + 1
        tbaux2(nbfami) = tbaux3(iaux)
   21 continue
c
c 2.2. ==> Familles des groupes 'CAV_xx_b'
c
      do 22 , iaux = 1 , 20
c
        if ( codret.eq.0 ) then
c
        nomgro = blan80
        nomgro(1:8) = 'CAV_00_b'
        if ( iaux.le.9 ) then
          write(nomgro(6:6),'(i1)') iaux
        else
          write(nomgro(5:6),'(i2)') iaux
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomgro
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFMGR', nompro
#endif
        call utfmgr ( nomgro, jaux, tbaux3,
     >                nbfmed, numfam,
     >                grfmpo, grfmtl, grfmtb,
     >                ulsort, langue, codret )
cgn      write (ulsort,90002) '==> nombre de familles', jaux
        do 221 , kaux = 1 , jaux
          nbfami = nbfami + 1
          tbaux2(nbfami) = tbaux3(kaux)
  221   continue
c
        endif
c
   22 continue
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,91020) (tbaux2(iaux),iaux=1,nbfami)
#endif
c
c====
c 3. on passe en revue chaque maille
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) nompro//'-nbeled', nbeled
      write(ulsort,90002) nompro//'-nbmaid', nbmaid
#endif
c
      kaux = 0
c
      do 31 , iaux = 1 , nbeled
c
        indice = 0
        do 311 , jaux = 1 , nbfami
          if ( fameel(iaux).eq.tbaux2(jaux) ) then
            indice = jaux
            goto 312
          endif
  311   continue
c
  312   continue
c
        if ( indice.eq.0 ) then
c
          tbaux1(iaux) = iaux
c
cgn        write (ulsort,texte(langue,6)) fameel(iaux), typele(iaux)
        else
c
          tbaux1(iaux) = 0
cgn          write (ulsort,texte(langue,5)) iaux
          kaux = kaux + 1
c
        endif
c
   31 continue
c
      nbelef = nbeled - kaux
      nbmaif = nbmaid - kaux
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) nompro//'-nbelef', nbelef
      write(ulsort,90002) nompro//'-nbmaif', nbmaif
#endif
c
c====
c 4. consequences
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. consequences ; codret = ', codret
#endif
c
      jaux = 1
      do 41 , iaux = 1 , nbelef
c
c       recherche du 1er element a garder
        laux = jaux
        do 411 , kaux = laux , nbeled
          if ( tbaux1(kaux).ne.0 ) then
            jaux = kaux
            goto 412
          endif
  411   continue
c
  412   continue
c
c       transfert des valeurs des tableaux
        do 413 , kaux = 1 , nbmane
          noeele(iaux,kaux) = noeele(jaux,kaux)
  413   continue
        fameel(iaux) = fameel(jaux)
        typele(iaux) = typele(jaux)
        nuelex(iaux) = nuelex(jaux)
c
c       decalage
        jaux = jaux + 1
c
   41 continue
c
c====
c 5. la fin
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
