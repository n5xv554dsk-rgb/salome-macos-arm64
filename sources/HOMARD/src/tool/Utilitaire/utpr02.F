      subroutine utpr02 ( option,
     >                    nbentn, nbvapr, listpr,
     >                    neneho, neneca, decala,
     >                    lgneic, neneic, neneih,
     >                    profil,
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
c    UTilitaire - PRofil - operation 02
c    --           --                 --
c
c  On a en entree un profil, c'est-a-dire une liste d'entites exprimees
c  en numerotation du calcul. Cette liste est compacte. On a en sortie
c  un tableau indexe par la numerotation du calcul des entites du meme
c  type. La valeur vaut 1 ou son rang dans le profil si l'entite
c  appartient au profil, 0 sinon.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . option du traitement                       .
c .        .     .        . 1 : avec le rang                           .
c . nbentn . e   .   1    . nombre total d'entites                     .
c . nbvapr . e   .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil                       .
c . listpr . e   .   *    . liste contenant le profil en numerotation  .
c .        .     .        . du calcul                                  .
c . neneho . e   .    *   . numero des entites dans HOMARD             .
c . neneca . e   .    *   . numero des entites dans Calcul (cf. vcmren).
c . decala . e   .   1    . decalage des numerotations selon le type   .
c . neneic . e   .    *   . numero des entites dans Calcul (cf. vcmren).
c . neneih . e   .    *   . reciproque de neneic                       .
c . profil .  s  . nbentn . pour chaque entite :                       .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . >0 : l'entite est presente dans le profil  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . -1 : mauvaise demande pour le type de nom  .
c .        .     .        . -2 : mauvaise demande pour l'option        .
c .        .     .        . -3 : probleme sur le tableau a convertir   .
c .        .     .        . autre : probleme dans l'allocation         .
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
      parameter ( nompro = 'UTPR02' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbentn, nbvapr
      integer listpr(*)
      integer neneho(nbentn)
      integer neneca(*), decala
      integer lgneic, neneic(*)
      integer neneih(*)
      integer profil(nbentn)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
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
      texte(1,4) = '(''Option :'',i4)'
      texte(1,5) = '(''Mauvaise demande d''''option :'',i8)'
      texte(1,6) = '(''Nombre total d''''entites :'',i10)'
      texte(1,7) = '(''Longueur du profil : '',i10)'
      texte(1,8) = '(''... Premiere(s) valeur(s) : '',5i10)'
      texte(1,9) = '(''... Derniere(s) valeur(s) : '',5i10)'
c
      texte(2,4) = '(''Option:'',i4)'
      texte(2,5) = '(''Bad request for the option:'',i8)'
      texte(2,6) = '(''Total number of entities:'',i10)'
      texte(2,7) = '(''Length of profile: '',i10)'
      texte(2,8) = '(''... First value(s): '',5i10)'
      texte(2,9) = '(''... Last value(s) : '',5i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) option
      write (ulsort,texte(langue,6)) nbentn
      write (ulsort,texte(langue,7)) nbvapr
      if ( nbvapr.gt.0 ) then
        write (ulsort,texte(langue,8))
     >           (listpr(iaux),iaux=1,min(5,nbvapr))
      endif
      if ( nbvapr.gt.5 ) then
        write (ulsort,texte(langue,9))
     >           (listpr(iaux),iaux=nbvapr-4,nbvapr)
      endif
      write(ulsort,90002) 'lgneic', lgneic
      write(ulsort,90002) 'decala', decala
#endif
c
c====
c 2. ==> aucune entite ne fait partie du filtre
c====
c
      do 20 , iaux = 1 , nbentn
        profil(iaux) = 0
   20 continue
c
c====
c 3. traitement sans profil : on prend tout
c====
cgn      write (ulsort,*)nompro//'-neneic'
cgn      write (ulsort,91020)(neneic(iaux),iaux=1,lgneic/2)
c
      if ( nbvapr.le.0 ) then
c
c 3.1. ==> option simple : changement de presentation
c          on restitue le rang de l'entite dans le profil quand
c          l'entite est presente, 0 sinon
c
      if ( option.eq.1 ) then
c
        jaux = 0
        if ( lgneic.eq.0 ) then
          do 311 , iaux = 1 , nbentn
cgn        write(ulsort,90002) 'iaux, neneho(iaux)',iaux, neneho(iaux)
            if ( neneho(iaux).ne.0 ) then
              jaux = jaux + 1
              profil(iaux) = neneca(neneho(iaux)) - decala
            endif
  311     continue
        else
          do 312 , iaux = 1 , nbentn
cgn        write(ulsort,90002) 'iaux, neneho(iaux)',iaux, neneho(iaux)
            if ( neneho(iaux).ne.0 ) then
              jaux = jaux + 1
cgn        write(ulsort,90002) 'jaux, neneho, profil',
cgn     >                  jaux, neneho(iaux), neneic(neneho(iaux))
              profil(iaux) = neneic(neneho(iaux))
            endif
  312     continue
        endif
c
c 3.n. ==> erreur
c
      else
c
        write (ulsort,texte(langue,5)) option
        codret = -2
c
      endif
c
c====
c 4. traitement avec profil
c====
c
      else
cgn      write (ulsort,*) nompro//'-listpr',(listpr(iaux),iaux=1,nbvapr)
cgn      write (ulsort,*)nompro//'-neneic',(neneic(iaux),iaux=1,10)
c
c 4.1. ==> option simple : changement de presentation
c          on restitue le rang de l'entite dans le profil quand
c          l'entite est presente, 0 sinon
c
      if ( option.eq.1 ) then
c
        if ( lgneic.eq.0 ) then
          do 411 , iaux = 1 , nbvapr
c         iaux : i-eme valeur du tableau
c         listpr(iaux) : rang MED de la maille dans sa categorie
c         neneih(listpr(iaux)) : numero HOMARD associe
c         neneca(neneih(listpr(iaux))) : numero du calcul associe
cgn          write (ulsort,*)'listpr(',iaux,')=',listpr(iaux)
            profil(listpr(iaux)+decala) = iaux
  411     continue
        else
          do 412 , iaux = 1 , nbvapr
c         iaux : i-eme valeur du tableau
c         listpr(iaux) : rang MED de la maille dans sa categorie
c         neneih(listpr(iaux)) : numero HOMARD associe
c         neneca(neneih(listpr(iaux))) : numero du calcul associe
cgn          write (ulsort,*)'listpr(',iaux,')=',listpr(iaux)
            jaux = neneih(listpr(iaux))
cgn          write (ulsort,*)'neneih(listpr(',iaux,'))=',jaux
cgn          write (ulsort,*)'neneca(',jaux,')=',neneca(jaux)
            profil(neneca(jaux)) = iaux
  412     continue
        endif
c
c 4.n. ==> erreur
c
      else
c
        write (ulsort,texte(langue,5)) option
        codret = -2
c
      endif
c
      endif
c
c====
c 5. la fin
c====
c
cgn      write (ulsort,*)nompro//'-profil',(profil(iaux),iaux=1,nbentn)
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
