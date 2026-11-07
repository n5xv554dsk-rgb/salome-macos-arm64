      subroutine gbralo ( type1, long, iad, codret )
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
c     Re-allocation,
c     utilisee uniquement en mode gm dynamique,
c     dans le sens reduction de taille,
c     avec une taille finale > 0
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . type1  . e   . char*1 . type du tableau a reallouer                .
c . long   . e   .    1   . nouvelle longueur du tableau               .
c . iad    . es  .    1   . adresse du premier element du tableau      .
c .        .     .        . (adresse memoire)                          .
c . codret .  s  .    1   . code de retour                             .
c . codret .  s  .    1   . 0  : tout va bien                          .
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
c 0.2. ==> communs
c
#include "gmtail.h"
c
#include "gmimpr.h"
c
c 0.3. ==> arguments
c
      character*1 type1
      integer long, iad
      integer codret
c
c 0.4. ==> variables locales
c
      integer ltype, size
      character*60 texte(5)
c
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
      texte(3) = 'L''adresse est hors des limites de la pile (heap). '
      texte(4) = 'La zone a deja ete liberee.                       '
      texte(5) = 'L''adresse n''est pas au debut d''un bloc.           '
c
c====
c 2. recherche de la taille selon le type de tableau a reallouer
c====
c
      if ( type1.eq.'i'.or.type1.eq.'I' ) then
       ltype = tentie
      elseif ( type1.eq.'s'.or.type1.eq.'S' ) then
       ltype = tchain
      elseif ( type1.eq.'r'.or.type1.eq.'R' ) then
       ltype = treel
      else
        write(ulsort,*) ' gbralo type inconnu ', type1
        call ugstop('gbralo',ulsort,0,1,1)
      endif
c
c====
c 3. reallocation effective
c====
c (attention: dmralo ne garantit pas que l'adresse de depart iad
c             ne sera pas changee)
c
      size = ltype*long
c
cgn      write(ulsort,*) 'appel de dmralo avec iad = ', iad
cgn      write(ulsort,*) 'appel de dmralo avec size = ', size
      call dmralo ( iad, size, codret )
cgn      write(ulsort,*) 'retour de dmralo'
c
      if ( codret.ne.0 ) then
        write (ulsort,*) ' GBRALO : erreur a la re-allocation'
        write (ulsort,*) 'Code de retour de DMRALO : ', codret
        if ( codret.ge.-5 .and. codret.le.-3 ) then
          write (ulsort,*) texte(abs(codret))
        endif
        write (ulsort,*) 'Type          : ', type1
        write (ulsort,*) 'Adresse       : ', iad
        write (ulsort,*) 'Taille voulue : ', long
      endif
c
      end
