      subroutine uthonh ( noehom, arehom,
     >                    homtri, quahom,
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
c    UTilitaire - HOmologues - Nombres pour HOMARD
c    --           --           -            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . noehom . e   . nbnoto . liste etendue des homologues par noeuds    .
c . arehom . e   . nbarto . liste etendue des homologues par aretes    .
c . homtri . e   . nbtrto . ensemble des triangles homologues          .
c . quahom . e   . nbquto . ensemble des quadrangles homologues        .
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
      parameter ( nompro = 'UTHONH' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer noehom(nbnoto), arehom(nbarto)
      integer homtri(nbtrto), quahom(nbquto)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) = '(/,''Decompte des equivalences sur les '',a)'
      texte(1,4) = '(''--> Ce nombre doit etre pair !'')'
      texte(1,5) =
     > '(8x,''. Nombre de paires                            :'',i10)'
c
      texte(2,10) = '(/,''Description of equivalences over '',a)'
      texte(2,4) = '(''--> This number should be even !'')'
      texte(2,5) =
     > '(8x,''. Number of pairs                             :'',i10)'
c
      codret = 0
c
c====
c 2. decompte du nombre de paires de noeuds homologues
c    il faut noter les cas ou un noeud est homologue de lui-meme
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) mess14(langue,3,-1)
#endif
c
      nbpnho = 0
c
      do 21 , iaux = 1 , nbnoto
        if ( noehom(iaux).eq.iaux ) then
          nbpnho = nbpnho + 2
        elseif ( noehom(iaux).ne.0 ) then
          nbpnho = nbpnho + 1
        endif
   21 continue
c
      if ( mod(nbpnho,2).eq.0 ) then
        nbpnho = nbpnho / 2
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) nbpnho
#endif
      else
        write (ulsort,texte(langue,5)) nbpnho
        write (ulsort,texte(langue,4))
        codret = 21
      endif
c
      endif
c
c====
c 3. decompte du nombre de paires de noeuds homologues
c    il faut noter les cas ou une arete est homologue d'elle-meme
c====
c
      if ( codret.eq.0 ) then
c
      nbpaho = 0
c
      if ( homolo.ge.2 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) mess14(langue,3,1)
#endif
c
        do 31 , iaux = 1 , nbarto
          if ( abs(arehom(iaux)).eq.iaux ) then
            nbpaho = nbpaho + 2
          elseif ( arehom(iaux).ne.0 ) then
            nbpaho = nbpaho + 1
          endif
   31   continue
c
        if ( mod(nbpaho,2).eq.0 ) then
          nbpaho = nbpaho / 2
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,5)) nbpaho
#endif
        else
          write (ulsort,texte(langue,5)) nbpaho
          write (ulsort,texte(langue,4))
          codret = 31
        endif
c
      endif
c
      endif
c
c====
c 4. decompte du nombre de paires de triangles homologues
c====
c
      if ( codret.eq.0 ) then
c
      nbptho = 0
c
      if ( homolo.ge.3 .and. nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) mess14(langue,3,2)
#endif
c
        do 41 , iaux = 1 , nbtrto
          if ( homtri(iaux).ne.0 ) then
            nbptho = nbptho + 1
          endif
   41   continue
c
        if ( mod(nbptho,2).eq.0 ) then
          nbptho = nbptho / 2
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,5)) nbptho
#endif
        else
          write (ulsort,texte(langue,5)) nbptho
          write (ulsort,texte(langue,4))
          codret = 41
        endif
c
      endif
c
      endif
c
c====
c 5. decompte du nombre de paires de quadrangles homologues
c====
c
      if ( codret.eq.0 ) then
c
      nbpqho = 0
c
      if ( homolo.ge.3 .and. nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) mess14(langue,3,4)
#endif
c
        do 51 , iaux = 1 , nbquto
          if ( quahom(iaux).ne.0 ) then
             nbpqho = nbpqho + 1
          endif
   51   continue
c
         if ( mod(nbpqho,2).eq.0 ) then
          nbpqho = nbpqho / 2
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,5)) nbpqho
#endif
        else
          write (ulsort,texte(langue,5)) nbpqho
          write (ulsort,texte(langue,4))
          codret = 51
        endif
c
      endif
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
