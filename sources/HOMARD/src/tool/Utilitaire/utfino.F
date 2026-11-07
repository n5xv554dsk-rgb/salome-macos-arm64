      subroutine utfino ( mctyob, option, nomfic, lnomfi,
     >                    optimp,
     >                    ulsort, langue, codret )
c
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
c  but : renvoyer le nom unix complet correspondant a un fichier
c        de nom symbolique donne
c  remarque : si la variable nomfic est trop grande, elle est completee
c             par des blancs
c  remarque : utfino et utfin2 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . mctyob . e   .  ch8   . nom symbolique du type de fichier          .
c . option . e   .   1    . 0 : le nom est renvoye tel quel            .
c .        .     .        . 1 : les minuscules deviennent majuscules   .
c .        .     .        . 2 : les majuscules deviennent minuscules   .
c .        .     .        . si negatif, on interdit tout caractere     .
c .        .     .        . non alphabetique                           .
c . nomfic .  s  .  ch*   . nom unix du fichier associe                .
c . lnomfi .  s  .    1   . longueur du nom unix du fichier associe    .
c . optimp . e   .    1   . 0 : pas d'affichage de message             .
c .        .     .        . 1 : affichage de message d'erreur          .
c . ulsort . e   .    1   . unite logique d'impression                 .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : la configuration est perdue            .
c .        .     .        . 2 : pas de nom dans la base                .
c .        .     .        . 4 : la chaine prevue est trop courte       .
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
      parameter ( nompro = 'UTFINO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      character*8 mctyob
      character*(*) nomfic
      integer optimp
c
      integer option, lnomfi
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer numero, nombre, ulmess
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
#include "motcle.h"
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1.  messages
c     si on recherche le fichier de la liste standard, il faut
c     imprimer sur la sortie standard.
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) = '(1x,''La configuration est perdue.'')'
      texte(1,4) =
     > '(1x,''Objet '',a8,'' : '',i4,'' fichiers possibles.'')'
c
      texte(2,10) = '(1x,''The configuration is lost.'')'
      texte(2,4) =
     > '(1x,''Object '',a8,'' : '',i4,'' available files.'')'
c
      if ( mctyob.eq.mclist ) then
        call gusost ( ulmess )
      else
        ulmess = ulsort
      endif
c
c====
c 2. appel de l'utilitaire : on n'est interesse que par le premier
c    fichier ou le mot-cle apparait
c    code retour : 0 : pas de probleme
c                  1 : la configuration est perdue
c                  2 : pas de nom dans la base
c                  3 : mauvais numero
c                  4 : la chaine nomfic est trop courte
c====
c
      numero = 1
c
      call utfin1 ( mctyob, numero,
     >              nombre, nomfic, lnomfi,
     >              ulmess, langue, codret )
c
      if ( codret.eq.3 ) then
        codret = 2
      endif
c
      if ( codret.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,1)) 'Sortie', nompro
#else
        if ( optimp.gt.0 ) then
#endif
        write (ulsort,texte(langue,2)) codret
        if ( codret.eq.1 ) then
          write (ulmess,texte(langue,10))
        else
          call utosme ( mctyob, ulsort, langue )
          write (ulmess,texte(langue,4)) mctyob, nombre
        endif
#ifdef _DEBUG_HOMARD_
c
#else
        endif
#endif
c
      endif
c
c====
c 3. conversion eventuelle
c====
c
      if ( codret.eq.0 ) then
c
      if ( option.ne.0 ) then
c
        call utmnmj ( option, nomfic, iaux,
     >                ulmess, langue, codret )
c
      endif
c
      endif
c
      end
