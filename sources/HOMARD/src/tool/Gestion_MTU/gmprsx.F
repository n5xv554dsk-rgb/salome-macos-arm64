      subroutine gmprsx ( chaine, nom )
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
c but : imprime le contenu d'un objet
c       . si l'objet est structure, on imprime ses attributs
c       . si l'objet est simple, on imprime son contenu complet
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . chaine . e   . char*  . chaine de commentaire a imprimer           .
c .  nom   . e   . char*  . nom de la structure a imprimer             .
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
      parameter ( nompro = 'GMPRSX' )
c
#include "genbla.h"
c
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtoas.h"
#include "gmtors.h"
c
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character*(*) chaine
      character*(*) nom
c
c 0.4. ==> variables locales
c
      integer nba, nbc, letype
      integer adsa, adso, adst
      integer iaux, jaux, ideb, ifin
      integer codret
c
      character*8 nomter, typtab, nocham
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
      texte(1,5) = '(a)'
      texte(1,4) =
     > '(/,''=== Structure '',a8,'' de type '',a8,'' ==='',/)'
      texte(1,6) = '(''Attribut numero'',i6,'' : '',i15)'
      texte(1,7) = '(''Champ numero   '',i6,'' : '',a8)'
      texte(1,8) = '(''  Type : '',a8,'' --> objet associe : '',a8)'
      texte(1,9) = '(''==> le nom de cette structure est invalide.'',/)'
      texte(1,10) = '(''==> cette structure n''''est pas allouee.'',/)'
c
      texte(2,5) = '(a)'
      texte(2,4) ='(/,''=== Structure '',a8,'' : Type '',a8,'' ==='',/)'
      texte(2,6) = '(''Attribute #'',i6,'' : '',i15)'
      texte(2,7) = '(''Field #    '',i6,'' : '',a8)'
      texte(2,8) = '(''  Type : '',a8,'' --> related object : '',a8)'
      texte(2,9) = '(''The name of this structure is not valid.'',/)'
      texte(2,10) = '(''==> this structure is not allocated.'',/)'
c
c====
c 2. etat de l'objet en memoire
c====
c
      call gmobal ( nom, codret )
c
c====
c 3. si objet non alloue
c====
c
      if ( codret.eq.0 ) then
c
        write (ulsort,*) ' '
        write (ulsort,*) nom
        write (ulsort,texte(langue,10))
c
c====
c 4. decodage des attributs pour un objet structure
c====
c
      elseif ( codret.eq.1 ) then
c
c 4.1. ==> recherche du nom terminal de l'objet et de son type
c
        call gmtyoj ( nom, typtab, iaux, codret )
c
        call gmnomc ( nom, nomter, codret )
c
c 4.2. ==> recherche du numero de l'objet
c
        do 42 , iaux = 1 , iptobj-1
          if ( nomobj(iaux).eq.nomter ) then
            letype = iaux
            nba = nbratt(typobj(letype))
            nbc = nbcham(typobj(letype))
            adsa = adrdsa(letype)
            adso = adrdso(letype)
            adst = adrdst(typobj(letype))
            goto 431
          endif
   42   continue
c
        goto 440
c
c 4.3. ==> ecriture des attributs
c
  431   continue
c
        write (ulsort,texte(langue,4)) nomter, typtab
        if ( len(chaine).gt.0 ) then
          write (ulsort,texte(1,5)) chaine
        endif
        write (ulsort,*) nom
        write (ulsort,*) ' '
c
        do 432 , iaux = 1 , nba
          write(ulsort,texte(langue,6)) iaux, valatt(adsa+iaux-1)
  432   continue
c
        do 433 , iaux = 1 , nbc
          jaux = typcha(adst+iaux-1)
          if ( jaux.gt.0 ) then
            nocham = nomtyp(jaux)
          else
            nocham = nomtyb(abs(jaux))
          endif
          write(ulsort,texte(langue,7)) iaux, nomcha(adst+iaux-1)
          write(ulsort,texte(langue,8)) nocham, nomobc(adso+iaux-1)
  433   continue
c
  440   continue
c
c====
c 5. appel du programme generique pour un objet simple
c====
c
      elseif ( codret.eq.2 ) then
c
        ideb = 0
        ifin = 0
        call gmprot ( chaine, nom, ideb, ifin )
c
c====
c 6. si objet non defini
c====
c
      else
c
        write (ulsort,*) ' '
        write (ulsort,*) nom
        write (ulsort,texte(langue,9))
c
      endif
c
      end
