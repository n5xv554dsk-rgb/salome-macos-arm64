      subroutine gblibe (typtab,n,iad,codret)
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
c     liberation
c   remarque : pour l'instant la taille, n, ne sert a rien
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typtab . e   . char*1 . type du tableau a allouer                  .
c . n      . e   .    1   . longueur du tableau                        .
c . iad    .  s  .    1   . adresse du premier element du tableau      .
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
      character*1 typtab
      integer n, iad
      integer codret
c
c 0.4. ==> variables locales
c
      integer ltype
c
      character*60 texte(5)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
c                 12345678901234567890123456789012345678901234567890
      texte(3) = 'L''adresse est hors des limites de la pile (heap). '
      texte(4) = 'La zone a deja ete liberee.                       '
      texte(5) = 'L''adresse n''est pas au debut d''un bloc.           '
c
c====
c 2. liberation effective
c====
c
cgn      print *,'appel de dmlibe : ',iad
      call dmlibe (iad,codret)
cgn      print *,'retour de dmlibe'
c
c====
c 3. message d'erreur
c====
c
      if ( codret.ne.0) then
c
      if ( typtab.eq.'i'.or.typtab.eq.'I') then
       ltype = tentie
      elseif ( typtab.eq.'s'.or.typtab.eq.'S') then
       ltype = tchain
      elseif ( typtab.eq.'r'.or.typtab.eq.'R') then
       ltype = treel
      else
        write(ulsort,*) ' gblibe type inconnu ', typtab
        call ugstop('gblibe',ulsort,0,1,1)
      endif
c
      write (ulsort,*) ' GBLIBE : erreur a la liberation'
      write (ulsort,*) 'Code de retour de DMLIBE : ', codret
      if ( codret.ge.-5 .and. codret.le.-3 ) then
         write (ulsort,*) texte(abs(codret))
      endif
      write (ulsort,*) 'Type          : ', typtab
      write (ulsort,*) 'Adresse       : ', iad
      write (ulsort,*) 'Taille voulue : ', n
c
      endif
c
      end
