      subroutine utfin1 ( mctyob, numero,
     >                    nombre, nomfic, lnomfi,
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
c             par des blancs. C'est uts8ch qui le fait.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . mctyob . e   .  ch8   . nom symbolique du type d'objet             .
c . numero . e   .   1    . numero du fichier voulu                    .
c . nombre .  s  .   1    . nombre de fichiers correspondants a ce type.
c . nomfic .  s  .  ch*   . nom unix du fichier associe                .
c . lnomfi .  s  .    1   . longueur du nom unix du fichier associe    .
c . ulsort . e   .    1   . unite logique d'impression                 .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : la configuration est perdue            .
c .        .     .        . 2 : pas de nom dans la base                .
c .        .     .        . 3 : mauvais numero                         .
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
      parameter ( nompro = 'UTFIN1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      character*8 mctyob
      character*(*) nomfic
c
      integer numero, nombre, lnomfi
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "utliob.h"
c
      integer adnore, adlono, adpono, adnofi, adnoos
      integer nbfich
      integer iaux, nrofic, poinnf
c
      integer nbmess
      parameter (nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      lnomfi = 0
      nombre = 0
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
      texte(1,10) = '(''Mot-cle symbolique '',a8,'', numero '',i6)'
      texte(1,4) =
     >  '(''Il est present '',i5,'' fois dans la configuration.'')'
      texte(1,11) = '(''La configuration est perdue ?'')'
      texte(1,12) =
     > '(''Ce mot-cle est inconnu dans la configuration.'')'
      texte(1,13) = '(''Le numero voulu est impossible.'')'
      texte(1,14) = '(''La chaine prevue est trop courte.'')'
c
      texte(2,10) = '(''Symbolic keyword '',a8,'', rank '',i6)'
      texte(2,4) =
     >  '(''It is present '',i5,'' times in configuration.'')'
      texte(2,11) = '(''Configuration is lost ?'')'
      texte(2,12) = '(''This keyword is unknown in configuration.'')'
      texte(2,13) = '(''The wanted rank is impossible.'')'
      texte(2,14) = '(''String is too short.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) mctyob, numero
#endif
c
c====
c 2. recherche des adresses des objets GM lies aux noms des fichiers
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD80', nompro
#endif
      call utad80 ( nbfich,
     >              adnore, adlono, adpono, adnofi, adnoos,
     >              ulsort, langue, codret )
c
c====
c 3. recherche du nom de fichier
c====
c
c 3.1. ==> recherche du nom symbolique :
c     on compte combien il y en a au total (nombre)
c     on repere l'indice (nrofic) correspondant a celui demande (numero)
c
      if ( codret.eq.0 ) then
c
      nrofic = 0
c
      do 31 , iaux = 1 , nbfich
        if ( smem(adnore+iaux-1).eq.mctyob ) then
          nombre = nombre + 1
          if ( nombre.eq.numero ) then
            nrofic = iaux
          endif
        endif
   31 continue
c
      if ( nombre.eq.0 ) then
        codret = 2
      else if ( nrofic.eq.0 ) then
        codret = 3
      endif
c
      endif
c
c 3.2. ==> transfert du nom
c
      if ( codret.eq.0 ) then
c
      poinnf = imem(adpono+nrofic-1)
      lnomfi = imem(adlono+nrofic-1)
c
      call uts8ch ( smem(adnofi+poinnf), lnomfi, nomfic,
     >              ulsort, langue, codret )
c
      if ( codret.eq.1 ) then
        codret = 4
      endif
c
      endif
c
c====
c 4. les erreurs
c====
c
#ifdef _DEBUG_HOMARD_
c
      if ( codret.ne.0 ) then
c
        iaux = 10 + codret
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
        write (ulsort,texte(langue,10)) mctyob, numero
        write (ulsort,texte(langue,4)) nombre
        write (ulsort,texte(langue,iaux))
c
      endif
c
#endif
c
      end
