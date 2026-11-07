      subroutine gmaloj (nom, typobj, long, adress, codret)
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
c     allocation l'objet terminal d'un nom etendu "nom"
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nom    . e   . char(*). nom etendu                                 .
c . typobj . e   .char(*) . type de l'objet a allouer                  .
c . long   . e   .   1    . 0 si on veut un objet structure            .
c .        .     .        . longueur si on veut un objet simple        .
c . adress .  s  . ent    . 0 si on veut un objet structure            .
c .        .     .        . adresse de l'objet simple alloue           .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
c .        .     .        . -1 : dimensionnement des tables insuffisant.
c .        .     .        . -2 : le type de l'objet-terminal est celui .
c .        .     .        .      d'un objet structure et long /= 0     .
c .        .     .        . -3 : "nom" a plus d'un element et "type" ne.
c .        .     .        .      correspond pas au type du champ       .
c .        .     .        .      terminal sauf si "type" = ' ' alors   .
c .        .     .        .      c'est le type du champ-terminal       .
c .        .     .        .      qui serait considere                  .
c .        .     .        . -4 : "nom" a un seul element et "type"     .
c .        .     .        .      n'est pas connu
c .        .     .        . -5 : l'objet-terminal est deja alloue      .
c .        .     .        . -6 : nom etendu invalide                   .
c .        .     .        . -7 : premier caractere interdit            .
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
      parameter ( nompro = 'GMALOJ' )
c
#include "gmcain.h"
#include "genbla.h"
c
c 0.2. ==> communs
c
#include "gmimpr.h"
#include "envex1.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character*(*) nom, typobj
      integer       long, adress, codret
c
c 0.4. ==> variables locales
c
      integer nbcain
      integer iaux
c
      character*1 carint(ncainx)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c====
c 1. Initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Objet a allouer : '', a)'
      texte(1,5) = '(''. Type voulu : '',a)'
      texte(1,6) = '(''. Longueur : '',i12)'
c
      texte(2,4) = '(''Object : '',a)'
      texte(2,5) = '(''. Type : '',a)'
      texte(2,6) = '(''. Length : '',i12)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nom
      write (ulsort,texte(langue,5)) typobj
      write (ulsort,texte(langue,6)) long
#endif
c
c====
c 2. on appelle le programme generique avec interdiction de certains
c    caracteres en premiere position
c    de plus, on autorise tous les types de noms
c====
c
      nbcain = ncainx
      carint(1) = caint1
      if ( nbcain.ge.2 ) then
        carint(2) = caint2
      endif
      if ( nbcain.ge.3 ) then
        carint(3) = caint3
      endif
      if ( nbcain.ge.4 ) then
        carint(4) = caint4
      endif
c
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Appel de gballo par gmaloj'
#endif
      call gballo ( nom, typobj, long, adress,
     >              nbcain, carint, codret )
c
c====
c 3. Fin
c====
c
      if ( codret.ne.0 ) then
c
      write (ulsort,texte(langue,4)) nom
      write (ulsort,texte(langue,5)) typobj
      write (ulsort,texte(langue,6)) long
c
#include "envex2.h"
c
      endif
c
      end
