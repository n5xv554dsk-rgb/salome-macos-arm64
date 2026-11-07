      subroutine utfin2 ( mctyob, option, nomfic, lnomfi,
     >                    nbrmin, nbrmax,
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
c . nbrmin . e   .   1    . nombre minimal de mots possibles           .
c . nbrmax . e   .   1    . nombre maximal de mots possibles           .
c . nomfic .  s  .  ch*   . nom unix du fichier associe                .
c . lnomfi .  s  .    1   . longueur du nom unix du fichier associe    .
c . ulsort . e   .    1   . unite logique d'impression                 .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : la configuration est perdue            .
c .        .     .        . 2 : pas de nom dans la base                .
c .        .     .        . 3 : le nombre de mots-cles est incorrect   .
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
      parameter ( nompro = 'UTFIN2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      character*8 mctyob
      character*(*) nomfic
c
      integer option, lnomfi
      integer nbrmin, nbrmax
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
      texte(1,4) = '(''Mot-cle symbolique '',a8,)'
      texte(1,5) = '(1x,''La configuration est perdue.'')'
      texte(1,6) =
     >  '(''Il est present '',i5,'' fois dans la configuration.'')'
      texte(1,7) = '(''On voudrait entre'',i5,'' et'',i5)'
      texte(1,8) = '(i4,'' fichiers possibles.'')'
c
      texte(2,4) = '(''Symbolic keyword '',a8,'', rank '',i6)'
      texte(2,5) = '(1x,''The configuration is lost.'')'
      texte(2,6) =
     >  '(''It is present '',i5,'' times in configuration.'')'
      texte(2,7) = '(''Asked: between'',i5,'' and'',i5)'
      texte(2,8) = '(i4,'' available files.'')'
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFIN1', nompro
#endif
      call utfin1 ( mctyob, numero,
     >              nombre, nomfic, lnomfi,
     >              ulmess, langue, codret )
cgn        write (*,texte(langue,4)) mctyob
cgn        write(*,*)'nombre',nombre
cgn        write(*,*)'codret',codret
c
      if ( codret.eq.3 ) then
        codret = 2
      endif
c
      if ( codret.eq.0 ) then
      if ( nombre.lt.nbrmin .or. nombre.gt.nbrmax ) then
        codret = 3
      endif
      endif
c
#ifdef _DEBUG_HOMARD_
c
      if ( codret.ne.0 ) then
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
        write (ulmess,texte(langue,4)) mctyob
        if ( codret.eq.1 ) then
          write (ulmess,texte(langue,5))
        elseif ( codret.eq.3 ) then
          write (ulmess,texte(langue,6)) nombre
          write (ulmess,texte(langue,7)) nbrmin, nbrmax
        else
          call utosme ( mctyob, ulsort, langue )
          write (ulmess,texte(langue,8)) nombre
        endif
c
      endif
c
#endif
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
cgn        write(*,*)'==> codret',codret
c
      end
