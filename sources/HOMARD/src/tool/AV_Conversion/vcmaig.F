      subroutine vcmaig ( fmdeig, noeeig,
     >                    typele, fameel, noeele,
     >                    nnoeho,
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
c    aVant adaptation - Conversion de MAillage - elements IGnores
c     -                 -             --                  --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . noeeig .  s  .nbelig**. noeuds des elements                        .
c . fmdeig .  s  . nbelig . famille med des elements                   .
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . fameel . e   . nbelem . famille med des elements                   .
c . nnoeho . e   . nbnoto . numero des noeuds dans HOMARD              .
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
      parameter ( nompro = 'VCMAIG' )
c
#include "nblang.h"
#include "referx.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "meddc0.h"
#include "envca1.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer fmdeig(nbelig)
      integer noeeig(nbelig,*)
      integer typele(nbelem), fameel(nbelem)
      integer noeele(nbelem,nbmane)
      integer nnoeho(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer el, elig, noeud, typeig
      integer nbnoel
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
      texte(1,4) =
     > '(''Fin du compteur sur les elements ignores :'',i10)'
      texte(1,5) =
     > '(''Or, on avait prevu'',i10,'' elements ignores.'')'
c
      texte(2,4) = '(''End of count on ignored elements :'',i10)'
      texte(2,5) = '(i10,'' elements were forecasted.'')'
c
#include "impr03.h"
c
c====
c 2. on passe en revue chaque element ignore
c    on memorise son nombre de noeuds et on transfere sa description
c    dans la structure HOMARD
c====
c
      if ( degre.eq.1 ) then
        typeig = edpyr5
        nbnoel = 5
      else
        typeig = edpy13
        nbnoel = 13
      endif
cgn      write (ulsort,90012) 'typeig, nbnoel', typeig, nbnoel
c
      elig = 0
c
      do 21 , el = 1 , nbelem
c
        if ( typele(el).eq.typeig ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90012) 'type de ', el, typele(el)
#endif
c
          elig = elig + 1
          fmdeig(elig) = fameel(el)
c
          do 211 , noeud = 1 , nbnoel
cgn        write (ulsort,90002) 'noeud', noeud, noeele(el,noeud)
            noeeig(elig,noeud) = nnoeho(noeele(el,noeud))
  211     continue
c
        endif
c
   21 continue
c
      if ( elig.ne.nbelig ) then
        write (ulsort,texte(langue,4)) elig
        write (ulsort,texte(langue,5)) nbelig
        codret = 1
      endif
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
