      subroutine gmntve ( nomtab, nomvar, nbcain, carint, codret )
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
c    verifie que le nom demande pour un objet terminal est plausible
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomtab . e   .char*(*). nom terminal a verifier                    .
c . nomvar .  s  . char*8 . nom controle                               .
c . nbcain . e   .   1    . nombre de premiers caracteres interdits    .
c . carint . e   . char*1 . liste de caracteres interdits              .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        . 0 : OK                                     .
c .        .     .        . 1 : longueur nulle                         .
c .        .     .        . 2 : longueur superieure a 8                .
c .        .     .        . 3 : nom blanc                              .
c .        .     .        . 4 : nom indefini                           .
c .        .     .        . 5 : premier caractere non valable          .
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
      character*6 nompro
      parameter ( nompro = 'GMNTVE' )
c
c
#include "genbla.h"
c
c 0.2. ==> communs
c
#include "gminds.h"
c
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character*(*) nomtab
      character*8 nomvar
      character*1 carint(*)
c
      integer nbcain, codret
c
c 0.4. ==> variables locales
c
      character*1 saux
      character*8 blan08
c
      integer iaux, laux
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data blan08 / '        ' /
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
      texte(1,10) = '(''Nom de l''''objet simple a verifier :'')'
      texte(1,11) = '(''Le nom est de longueur nulle.'')'
      texte(1,12) = '(''Le nom est de longueur superieure a 8.'')'
      texte(1,13) = '(''Le nom est blanc.'')'
      texte(1,14) = '(''Ce nom est interdit.'')'
      texte(1,15) =
     > '(''Le caractere '',a1,'' est interdit comme 1ere lettre.'')'
c
      texte(2,10) = '(''Name of the object to check :'')'
      texte(2,11) = '(''The length of the name is 0.'')'
      texte(2,12) = '(''The length of the name is greater than 8.'')'
      texte(2,13) = '(''The name is blank.'')'
      texte(2,14) = '(''This name is forbidden.'')'
      texte(2,15) =
     > '(''The character '',a1,'' is forbidden as 1st lettre.'')'
c
c====
c 2.  verification du nom
c====
c
      codret = 0
c
      laux = len(nomtab)
c
c 2.1. ==> verification de la longueur du nom : de 1 a 8
c
      if ( laux.lt.1 ) then
         codret = 1
c
      elseif(laux.gt.8) then
         codret = 2
c
c 2.2. ==> on refuse les noms blancs
c
      elseif ( blan08(1:laux).eq.nomtab(1:laux) ) then
         codret = 3
c
c 2.3. ==> on refuse les noms indefinis
c
      elseif ( sindef.eq.nomtab(1:laux) ) then
         codret = 4
c
c 2.4. ==> on refuse les caracteres interdits
c
      else
         do 24 , iaux = 1 , nbcain
            if ( nomtab(1:1).eq.carint(iaux) ) then
               saux = carint(iaux)
               codret = 5
            endif
  24     continue
      endif
c
c====
c 3. c'est bon. on etend eventuellement a 8 par des blancs
c====
c
      if ( codret.eq.0 ) then
c
         nomvar = '        '
         nomvar(1:laux) = nomtab(1:laux)
c
      endif
c
c====
c 4. gestion des erreurs
c====
c
      if ( codret.ne.0 ) then
c
         iaux = 10+abs(codret)
c
         write (ulsort,90000)
        write (ulsort,texte(langue,1)) 'Sortie', nompro
         write (ulsort,texte(langue,10))
         write (ulsort,*) nomtab
         if ( codret.eq.5 ) then
            write (ulsort,texte(langue,iaux)) saux
         else
            write (ulsort,texte(langue,iaux))
         endif
         write (ulsort,90000)
c
      endif
c
90000 format (70('='))
c
      end
