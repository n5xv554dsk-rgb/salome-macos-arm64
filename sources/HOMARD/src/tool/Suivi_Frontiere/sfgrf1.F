      subroutine sfgrf1 ( nbfmed, lifami,
     >                    nbmail, typmai, fammai,
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
c   Suivi de Frontiere - GRoupes de la Frontiere - phase 1
c   -        -           --            -                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfmed .   s .   1    . nombre de familles de mailles de frontiere .
c . lifami .   s .   *    . liste des familles a explorer              .
c . nbmail . e   .   1    . nombre de mailles                          .
c . typmai . e   . nbmail . type des mailles                           .
c . fammai . e   . nbmail . famille MED des mailles                    .
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
      parameter ( nompro = 'SFGRF1' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "envca1.h"
#include "meddc0.h"
c
c 0.3. ==> arguments
c
      integer nbfmed, nbmail
      integer lifami(*)
      integer typmai(nbmail), fammai(nbmail)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lamail
      integer typseg, typtri, typqua
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
      texte(1,4) = '(''Nombre de mailles :'',i11)'
      texte(1,5) = '(''Nombre de familles de '',a,'' :'',i11)'
c
      texte(2,4) = '(''Number of meshes :'',i11)'
      texte(2,5) = '(''Number of families of '',a,'' :'',i11)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbmail
#endif
c
      codret = 0
c
      nbfmed = 0
c
c====
c 2. on parcourt toutes les mailles
c    On repere les mailles de bords et on memorise leur familles MED
c====
c
      if ( degre.eq.1 ) then
        typseg = edseg2
        typtri = edtri3
        typqua = edqua4
      else
        typseg = edseg3
        typtri = edtri6
        typqua = edqua8
      endif
c
      do 2 , lamail = 1, nbmail
c
        if ( typmai(lamail).eq.typseg .or.
     >       typmai(lamail).eq.typtri .or.
     >       typmai(lamail).eq.typqua ) then
c
c         on cherche si sa famille MED est deja enregistree
c         si oui, on passe a la maille suivante
c         si non, on l'ajoute a la liste
c
          do 21 , iaux = 1, nbfmed
c
            if ( fammai(lamail).eq.lifami(iaux) ) then
              goto 2
            endif
c
   21     continue
c
          nbfmed = nbfmed + 1
          lifami(nbfmed) = fammai(lamail)
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'ajout de la famille', fammai(lamail)
#endif
c
        endif
c
    2 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,1), nbfmed
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
