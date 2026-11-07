      subroutine utcohe ( lehexa, bilan,
     >                    coonoe,
     >                    somare,
     >                    arequa,
     >                    quahex, coquhe, arehex,
     >                    hethex, filhex,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
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
c   UTilitaire - COntroles de HExaedres
c   --           --           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . numero de l'hexaedre a examiner            .
c . bilan  .   s .   1    . 0 : tout va bien                           .
c .        .     .        . 1 : probleme                               .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'UTCOHE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombhe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer lehexa, bilan
      integer somare(2,nbarto)
      integer arequa(nbquto,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto)
      integer filhex(nbheto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nbfils
      integer som1, som2, som3, som4
      integer freain, etat
c
      double precision prmixt, prmixf
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
      codret = 0
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''.. Examen du '',a,i10)'
c
      texte(2,4) = '(''.. Examination of '',a,'' # '',i10)'
c
c====
c 2. Controle de l'hexaedre
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Controle hexaedre ; codret = ', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,6), lehexa
#endif
c
      etat = mod(hethex(lehexa),1000)
cgn      write (ulsort,*) '   etat =',etat
c
      if ( etat.eq.0 ) then
c
        codret = 1
c
      elseif ( etat.eq.8 ) then
c
        bilan = 0
c
c 2.1. ==> Produit mixte de l'hexaedre
c
        som1 = 1
        som2 = 2
        som3 = 6
        som4 = 4
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPMHE', nompro
#endif
        call utpmhe ( lehexa, prmixt,
     >                som1, som2, som3, som4,
     >                coonoe, somare, arequa,
     >                quahex, coquhe, arehex )
cgn      write(ulsort,*) lehexa,prmixt
c
c 2.2. ==> Parcours des differents situations
c
        nbfils = 7
        freain = filhex(lehexa)
cgn        write(ulsort,*) '   freain =',freain
c
        do 22 , iaux = 1 , 8
c
          if ( iaux.eq.1 ) then
            som1 = 1
            som2 = 2
            som3 = 6
            som4 = 4
          elseif ( iaux.eq.2 ) then
            som1 = 6
            som2 = 1
            som3 = 5
            som4 = 7
          elseif ( iaux.eq.3 ) then
            som1 = 5
            som2 = 6
            som3 = 2
            som4 = 8
          elseif ( iaux.eq.4 ) then
            som1 = 2
            som2 = 5
            som3 = 1
            som4 = 3
          elseif ( iaux.eq.5 ) then
            som1 = 3
            som2 = 4
            som3 = 8
            som4 = 2
          elseif ( iaux.eq.6 ) then
            som1 = 8
            som2 = 3
            som3 = 7
            som4 = 5
          elseif ( iaux.eq.7 ) then
            som1 = 7
            som2 = 8
            som3 = 4
            som4 = 6
          else
            som1 = 4
            som2 = 7
            som3 = 3
            som4 = 1
          endif
c
          do 221 , jaux = freain , freain+nbfils
            kaux = jaux
            call utpmhe ( kaux, prmixf,
     >                    som1, som2, som3, som4,
     >                    coonoe, somare, arequa,
     >                    quahex, coquhe, arehex )
cgn            write(ulsort,*) jaux,prmixf
            if ( prmixt*prmixf.le.0.d0 ) then
              bilan = 1
              goto 29
            endif
  221     continue
c
cgn      write(ulsort,*) ' '
   22   continue
c
      endif
c
   29 continue
c
c====
c 3. La fin
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
