      subroutine utsynt ( repere, lgrepe,
     >                    vatype, vaenti, vareel, vachar, lgchar,
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
c    UTilitaire - SYNThese de l'adaptation
c    --           ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . repere . e   . lgrepe . texte reperant l'information a ecrire      .
c . lgrepe . e   .    1   . longueur du texte                          .
c . vatype . e   .    1   . type de la variable associee :             .
c .        .     .        .   1 : entier                               .
c .        .     .        .   2 : reel                                 .
c .        .     .        .   3 : caracteres                           .
c . vaenti . e   .   1    . valeur entiere a ecrire                    .
c . vareel . e   .   1    . valeur reelle a ecrire                     .
c . vachar . e   .   1    . valeur caractere a ecrire                  .
c . lgchar . e   . lgchar . longueur de la valeur caractere a ecrire   .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTSYNT' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envada.h"
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer lgrepe
      integer vatype
      integer lgchar
      integer vaenti
c
      character*(*) repere
      character*(*) vachar
c
      double precision vareel
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nuroul, lnomfl
c
      character*08 saux08
      character*09 mess09(nblang,3)
      character*200 nomflo
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. Messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.1. ==> Messages generaux
c
c                    123456789
      mess09(1,1) = 'entier   '
      mess09(1,2) = 'reel     '
      mess09(1,3) = 'caractere'
      mess09(2,1) = 'integer  '
      mess09(2,2) = 'real     '
      mess09(2,3) = 'character'
c
      texte(1,4) = '(''Texte de reperage : '',a)'
      texte(1,5) = '(''Type de valeur a traiter : '', a)'
      texte(1,6) = '(''--> valeur a ecrire :'',i10)'
      texte(1,7) = '(''--> valeur a ecrire :'',g15.6)'
      texte(1,8) = '(''--> valeur a ecrire : '',a)'
      texte(1,9) = '(''Type inconnu.'')'
c
      texte(2,4) = '(''Text: '',a)'
      texte(2,5) = '(''Type of value: '', a)'
      texte(2,6) = '(''--> value:'',i10)'
      texte(2,7) = '(''--> value:'',g15.6)'
      texte(2,8) = '(''--> value: '',a)'
      texte(2,9) = '(''Unknown type.'')'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. controle
c====
c
      if ( vatype.lt.1 .or. vatype.gt.3 ) then
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      iaux = 1
#else
      iaux = codret
#endif
c
      if ( iaux.ne.0 ) then
c
      write (ulsort,texte(langue,4)) repere(1:lgrepe)
      write (ulsort,texte(langue,5)) mess09(langue,vatype)
      if ( vatype.eq.1 ) then
        write (ulsort,texte(langue,6)) vaenti
      elseif ( vatype.eq.2 ) then
        write (ulsort,texte(langue,7)) vareel
      elseif ( vatype.eq.3 ) then
        write (ulsort,texte(langue,8)) vachar(1:lgchar)
      else
        write (ulsort,texte(langue,9))
      endif
c
      endif
c
c====
c 3. fichier de sortie de la synthese
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. fichier sortie ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      saux08 = '        '
      iaux = 7
      jaux = -1
      kaux = nbiter
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTULBI', nompro
#endif
      call utulbi ( nuroul, nomflo, lnomfl,
     >                iaux, saux08, jaux, kaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. Ecriture de l'information
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Ecriture ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( vatype.eq.1 ) then
        write (nuroul,90002) repere(1:lgrepe), vaenti
      elseif ( vatype.eq.2 ) then
        write (nuroul,90004) repere(1:lgrepe), vareel
      else
        write (nuroul,90003) repere(1:lgrepe), vachar(1:lgchar)
      endif
c
      endif
c
c====
c 5. Fermeture du fichier
c====
c
      if ( codret.eq.0 ) then
c
      call gufeul ( nuroul , codret)
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
