      subroutine pcceq4 ( option,
     >                    nbento, nctfen, nbfent, ncffen, ncefen,
     >                    nbeqen, ibenti, tyhen1, tyhen2, nbenca,
     >                    enthom, cfaent, fament, nensho, nensca,
     >                    typele,
     >                    eqpntr, eqenti, nbeqev,
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
c    aPres adaptation - Conversion - Creation des EQuivalences - phase 4
c     -                 -            -            --                   -
c ______________________________________________________________________
c
c    remarque : il vaut mieux que la boucle sur les entites soit a
c               l'interieur car elle sera toujours plus longue que
c               celle sur les equivalences, d'ou une meilleure
c               vectorisation
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . variantes                                  .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   4 : quadrangles                          .
c . nbento . e   .    1   . nombre d'entites total                     .
c . nctfen . e   .    1   . nombre total de caracteristiques           .
c . nbfent . e   .    1   . nombre de familles de l'entite             .
c . ncffen . e   .    1   .                                            .
c . ncefen . e   .    1   . nombre de caracteristiques d'equivalence   .
c .        .     .        . dans les familles de l'entite              .
c . nbeqen . e   .    1   . nombre d'equivalences de l'entite          .
c . ibenti . e   .    1   . decalage dans la numerotation              .
c . tyhen1 . e   .    1   . 1er type homard representant cette entite  .
c . tyhen2 . e   .    1   . 2nd type homard representant cette entite  .
c . nbenca . e   .    1   . nombre d'entites du calcul                 .
c . enthom . e   . nbento . liste etendue des entites homologues       .
c .        .     .        . enthom(i) = abs(hom(i)) ssi i sur face 2   .
c .        .     .        . enthom(i) = -abs(hom(i)) ssi i sur face 1  .
c . cfaent . e   . nctfen*. codes des familles des entites             .
c .        .     . nbfent .                                            .
c . fament . e   . nbento . famille des entites                        .
c . nensho . e   . rsenac . numero des entites dans HOMARD             .
c . nensca . e   . rsento . numero des entites du calcul               .
c . typele . e   . nbelem . type des elements                          .
c . eqpntr .  s  .5*nbequi. 5i-4 : nombre de paires de noeuds pour     .
c .        .     .        .        l'equivalence i                     .
c .        .     .        . 5i-3 : idem pour les mailles-points        .
c .        .     .        . 5i-2 : idem pour les aretes                .
c .        .     .        . 5i-1 : idem pour les triangles             .
c .        .     .        . 5i   : idem pour les quadrangles           .
c . eqenti .  s  .2*nbeqen. liste des paires d'entites equivalentes    .
c .        .     .        . avec la convention :                       .
c .        .     .        . eqenti(i)<-->eqenti(i+1)                   .
c . nbeqev .  s  .    1   . vrai nombre d'equivalences de l'entite     .
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
      parameter ( nompro = 'PCCEQ4' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "rftmed.h"
c
#include "impr02.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbento, nctfen, nbfent, ncffen, ncefen
      integer nbeqen, ibenti, tyhen1, tyhen2, nbenca
      integer nensca(*), nensho(*)
      integer typele(*)
c
      integer cfaent(nctfen,nbfent), fament(nbento)
      integer enthom(nbento)
c
      integer eqpntr(5*nbequi)
      integer eqenti(2*nbeqen)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nucode, nroequ, decala
      integer iaux, jaux, kaux, ifin
      integer nbeqev
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,''Creation des equivalences sur les '',a)'
      texte(1,6) =
     > '(8x,a14,'' : nombre d''''equivalences        :'',i10)'
      texte(1,7) =
     > '(8x,''. Nombre de paires                            :'',i10)'
      texte(2,6) =
     > '(8x,a14,'' : number of equivalences       :'',i10)'
      texte(2,7) =
     > '(8x,''. Number of pairs                             :'',i10)'
c
      texte(2,4) = '(/,''Creation of equivalences over '',a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,option)
      write (ulsort,90002) 'nbeqen', nbeqen
#endif
c
      codret = 0
c
c====
c 2. Tri selon les equivalences
c====
c
      nbeqev = 0
c
      if ( nbeqen.ne.0 ) then
c
c 2.1. ==> initialisations
c
        if ( option.eq.4 ) then
          decala = 0
        else
          decala = option - 3
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'enthom', enthom
        write (ulsort,90002) 'nbequi', nbequi
        write (ulsort,90002) 'nbento', nbento
        write (ulsort,90002) 'nbenca', nbenca
        write (ulsort,90002) 'ibenti', ibenti
        write (ulsort,90002) 'tyhen1', tyhen1
        write (ulsort,90002) 'tyhen2', tyhen2
        write (ulsort,90002) 'decala', decala
#endif
c
        ifin = 2*nbeqen
        do 21 , iaux = 1 , ifin
          eqenti(iaux) = 0
  21    continue
c
        kaux = 0
c
c 2.2. ==> on passe en revue toutes les equivalences
c          attention au bon rangement dans les faces 1 et 2 selon le
c          signe de enthom : on filtre seulement ceux pour lesquels
c          enthom est > 0. Cela permet de capturer les axes de symetrie.
c
        do 22 , nroequ = 1 , nbequi
c
          nucode = ncffen + nroequ
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'nroequ', nroequ
          write (ulsort,90002) '5*nroequ+decala', 5*nroequ+decala
          write (ulsort,90002) 'nucode', nucode
#endif
c
c 2.2.1. ==> cas particulier des noeuds
c
          if ( option.lt.0 ) then
c
            do 221 , iaux = 1, nbenca
              if ( cfaent(nucode,fament(nensho(iaux))).ne.0 ) then
                if ( enthom(nensho(iaux)).gt.0 ) then
                  kaux = kaux + 2
                  jaux = nensca(enthom(nensho(iaux)))
                  eqenti(kaux-1) = jaux
                  eqenti(kaux)   = iaux
                  eqpntr(5*nroequ+decala) = eqpntr(5*nroequ+decala) + 1
                endif
              endif
  221        continue
c
c 2.2.2. ==> les mailles
c
          else
c
            do 222 , iaux = 1, nbenca
              if ( medtrf(typele(iaux)).eq.tyhen1 .or.
     >             medtrf(typele(iaux)).eq.tyhen2 ) then
                if ( cfaent(nucode,fament(nensho(iaux))).ne.0 ) then
                  if ( enthom(nensho(iaux)).gt.0 ) then
                    jaux = nensca(enthom(nensho(iaux)))
                    kaux = kaux + 2
                    eqenti(kaux-1) = jaux - ibenti
                    eqenti(kaux)   = iaux - ibenti
                    eqpntr(5*nroequ+decala) = eqpntr(5*nroequ+decala)+1
                  endif
                endif
              endif
  222       continue
c
          endif
c
          nbeqev = nbeqev + eqpntr(5*nroequ+decala)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) 'fin de la boucle 22, eqenti = ', eqenti
#endif
c
  22    continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,option)
      write (ulsort,90002) 'nbeqen nouveau', nbeqev
#endif
c
      endif
c
c====
c 3. impressions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. impressions ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbento.ne.0 ) then
c
      write(ulsort,texte(langue,6)) mess14(langue,4,option), ncefen
      if ( ncefen.ne.0 ) then
        write(ulsort,texte(langue,7)) nbeqev
      endif
c
      endif
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
