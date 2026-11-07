      subroutine utmopf ( obpafo, option,
     >                    nbraux, tbsaux, tbiaux,
     >                    nomobj,
     >                    nbfopa, typgpf, ngauss, carsup, typint,
     >                    adobfo,
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
c    UTilitaire - MOdification d'un Paquet de Fonctions
c    --           --                -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . obpafo . e   . char8  . nom de l'objet du paquet de fonctions      .
c . option . e   .    1   . option de la modification :                .
c .        .     .        . 1 : ajout de la fonction nomobj            .
c .        .     .        . 2 : modification de typgpf                 .
c .        .     .        . 3 : modification de ngauss                 .
c .        .     .        . 4 : ajout du paquet associe eventuel       .
c .        .     .        . 5 : remplissage des types associes         .
c .        .     .        . 6 : degre du support geometrique           .
c . nbraux . e   .   1    . si option = 4 : nombre de paquets          .
c .        .     .        . si option = 5 : nombre de types            .
c . tbsaux . e   . nbraux . si option = 4 : liste des paquets          .
c . tbiaux . e   . nbraux . si option = 5 : liste des types geo.       .
c . nomobj . e   . char8  . si option = 1 :nom de la fonction a ajouter.
c .        .     .        . si option = 4 :nom du paquet a l'etape n   .
c . nbfopa .   s .   1    . nombre de fonctions dans le paquet         .
c . typgpf .  s  .   1    . si >0 : type geometrique s'il est unique   .
c .        .     .        . si <0 : nombre de type geometriques associe.
c . ngauss .   s .   1    . nombre de points de gauss                  .
c . carsup .   s .   1    . caracteristiques du support                .
c .        .     .        . 1, si aux noeuds par elements              .
c .        .     .        . 2, si aux points de Gauss, associe avec    .
c .        .     .        .    n champ aux noeuds par elements         .
c .        .     .        . 3 si aux points de Gauss autonome          .
c .        .     .        . 0, sinon                                   .
c . typint .   s .   1    . type d'interpolation                       .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  elements : 0 si intensif, sans orientation.
c .        .     .        .             1 si extensif, sans orientation.
c .        .     .        .             2 si intensif, avec orientation.
c .        .     .        .             3 si extensif, avec orientation.
c .        .     .        .  noeuds : 1 si degre 1                     .
c .        .     .        .           2 si degre 2                     .
c .        .     .        .           3 si iso-P2                      .
c . adobfo .   s .   1    . adresse des noms des objets 'Fonction' et  .
c .        .     .        . de l'eventuel paquet associe               .
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
      parameter ( nompro = 'UTMOPF' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbraux
      integer nbfopa, typgpf, ngauss, carsup, typint
      integer adobfo
      integer tbiaux(nbraux)
c
      character*8 obpafo, nomobj
      character*8 tbsaux(nbraux)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre1, codre2
      integer codre0
      integer iaux, jaux, kaux, laux, maux, naux
      integer adobfa, adtyge, adtyga
c
      character*8 nomoba, saux08
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Paquet de fonctions avant modification :'')'
      texte(1,5) = '(''Paquet de fonctions apres modification :'')'
      texte(1,6) = '(''Option'',i8,'' impossible.'')'
      texte(1,7) = '(''Impossible de trouver le paquet.'')'
c
      texte(2,4) = '(''Pack of functions before modification :'')'
      texte(2,5) = '(''Pack of functions after modification :'')'
      texte(2,6) = '(''Option'',i8,'' impossible.'')'
      texte(2,7) = '(''Pack cannot be found.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
10000 format(50('='))
      write (ulsort,10000)
      write (ulsort,texte(langue,4))
      call gmprsx (nompro, obpafo )
      call gmprsx (nompro, obpafo//'.Fonction' )
      call gmprsx (nompro, obpafo//'.TypeSuAs' )
#endif
c
c====
c 2. ajout d'une fonction
c====
c
      if ( option.eq.1 ) then
c
c 2.1. ==> caracteristiques initiales
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
        call utcapf ( obpafo,
     >                nbfopa, typgpf, ngauss, carsup, typint,
     >                adobfo, adtyge,
     >                ulsort, langue, codret )
cgn        print *,'nbfopa = ', nbfopa
cgn        print *,'typgpf = ', typgpf
cgn        print *,'ngauss = ', ngauss
cgn        print *,'carsup = ', carsup
cgn        print *,'typint = ', typint
c
c 2.2. ==> allongement de la structure
c
        if ( codret.eq.0 ) then
c
        call gmecat ( obpafo, 1, nbfopa+1, codre1 )
        call gmmod ( obpafo//'.Fonction',
     >               adobfo, nbfopa+1, nbfopa+2, 1, 1, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
c 2.3. ==> transfert des caracteristiques de la fonction
c 2.3.1. ==> placement a la fin du nom de l'eventuel paquet associe
c
        if ( codret.eq.0 ) then
c
        smem(adobfo+nbfopa+1) = smem(adobfo+nbfopa)
c
        endif
c
c 2.3.2. ==> ajout de la nouvelle fonction
c
        if ( codret.eq.0 ) then
c
        smem(adobfo+nbfopa) = nomobj
        nbfopa = nbfopa + 1
c
        endif
c
c====
c 3. modification des attributs typgpf ou ngauss
c====
c
      elseif ( option.ge.2 .and. option.le.3 ) then
c
c 3.1. ==> ecriture de l'attribut
c
        if ( codret.eq.0 ) then
c
        if ( option.eq.2 ) then
          iaux = typgpf
        else
          iaux = ngauss
        endif
        call gmecat ( obpafo, option, iaux, codret )
c
        endif
c
c 3.2. ==> caracteristiques finales
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
        call utcapf ( obpafo,
     >                nbfopa, typgpf, ngauss, carsup, typint,
     >                adobfo, adtyge,
     >                ulsort, langue, codret )
c
        endif
c
c====
c 4. ajout du paquet associe pour un champ aux points de Gauss
c====
c
      elseif ( option.eq.4 ) then
c
c 4.1. ==> nomobj est le paquet correspondant a obpafo, mais a l'etape n
c          on cherche son associe a l'etape n, nomoba
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro,nomobj)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
        call utcapf ( nomobj,
     >                jaux, kaux, laux, maux, naux,
     >                adobfa, adtyga,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nomoba = smem(adobfa+jaux)
cgn        print *,'===> nomoba = ',nomoba
c
        endif
c
c 4.2. ==> on cherche le correspondant de nomoba a l'etape p
c
        if ( codret.eq.0 ) then
c
        do 42 , iaux = 1 , nbraux
          if ( tbsaux(iaux).eq.nomoba ) then
            saux08 = tbsaux(iaux+nbraux)
            goto 420
          endif
   42   continue
        codret = 5
        write (ulsort,texte(langue,7))
c
  420   continue
c
        endif
c
c 4.3. ==> stockage correspondant de nomoba a l'etape p
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
        call utcapf ( obpafo,
     >                nbfopa, typgpf, ngauss, carsup, typint,
     >                adobfo, adtyge,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        smem(adobfo+nbfopa) = saux08
c
        endif
c
c====
c 5. ajout des types geometriques
c    si la branche existe, on commence par la detruire
c====
c
      elseif ( option.eq.5 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
        call utcapf ( obpafo,
     >                nbfopa, typgpf, ngauss, carsup, typint,
     >                adobfo, adtyge,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( typgpf.lt.0 ) then
c
        call gmlboj ( obpafo//'.TypeSuAs', codret )
c
        endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmaloj ( obpafo//'.TypeSuAs', ' ', nbraux, adtyge, codre1 )
        iaux = -nbraux
        call gmecat ( obpafo, 2, iaux, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
        do 51 , iaux = 1 , nbraux
          imem(adtyge+iaux-1) = tbiaux(iaux)
   51   continue
c
        endif
c
c====
c 6. degre du type geometrique
c====
c
      elseif ( option.eq.6 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
        call utcapf ( obpafo,
     >                nbfopa, typgpf, ngauss, carsup, typint,
     >                adobfo, adtyge,
     >                ulsort, langue, codret )
c
        endif
c
c Le type geometrique
c
        if ( codret.eq.0 ) then
c
cgn        write (ulsort,*) nompro, ' typgpf old', typgpf
        typgpf = medt12(typgpf)
cgn        write (ulsort,*) nompro, ' typgpf new', typgpf
        call gmecat ( obpafo, 2, typgpf, codret )
c
        endif
c
c Le nombre de noeuds par mailles
c
        if ( codret.eq.0 ) then
c
        if ( carsup.eq.1 ) then
c
cgn        write (ulsort,*) nompro, ' ngauss old', ngauss
        ngauss = mednnm(typgpf)
cgn        write (ulsort,*) nompro, ' ngauss new', ngauss
        call gmecat ( obpafo, 3, ngauss, codret )
c
        endif
c
        endif
c
c====
c 7. erreur dans l'option
c====
c
      else
c
        write (ulsort,texte(langue,6)) option
        codret = 1
c
      endif
c
c====
c 8. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5))
      call gmprsx (nompro, obpafo )
      call gmprsx (nompro, obpafo//'.Fonction' )
      call gmprsx (nompro, obpafo//'.TypeSuAs' )
cgn      write (ulsort,10000)
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
