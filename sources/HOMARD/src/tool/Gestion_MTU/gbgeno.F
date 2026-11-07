      subroutine gbgeno ( nomet, champ, nomgen, codret )
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
c     GM - Base - GEneration d'un Nom d'Objet
c     -    -      --              -     -
c
c     Le nom genere est forme par :
c     - caracteres 1 et 2 : les 2 premiers du nom etendu
c     - caracteres 3 et 4 : les 2 premiers du champ
c     - caracteres 5, 6, 7 et 8 : un caractere alphanumerique
c
c     On a le choix entre 10 chiffres, 26 lettres minuscules,
c     26 lettres majuscules, soit 62 signes pour former l'un des
c     caracteres 5, 6, 7 et 8.
c     Cela revient a ecrire le nombre d'appels de ce programme
c     en base 62.
c     Ce qui fait 62**4 - 1 = 14 776 335 possibilites.
c
c     Meme si l'objet est desalloue, on ne reutilise pas sa sequence,
c     donc il y a un risque d'arriver en limite pour un transitoire
c     avec de nombreux pas de temps. Ce risque est tres faible
c     car il faudrait environ 10 000 pas de temps pour l'atteindre.
c     Si cela se produit, il faudra gerer la reutilisation des codes.
c
c     Gerald NICOLAS le 12 mars 1998
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomet  . e   . char*  . nom etendu a traduire                      .
c . champ  . e   . char8  . . si nom-etendu a plusieurs elements :     .
c .        .     .        . = ' ' ou champ-terminal                    .
c .        .     .        . . si nom-etendu a un seul element :        .
c .        .     .        . = champ de l'objet 'nomet'                 .
c . nomgen .  s  . char8  . nom genere                                 .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . -4 : nom-etendu invalide                   .
c .        .     .        . -3 : 'nomet' n'a qu'un element et n'est    .
c .        .     .        .      pas un objet structure                .
c .        .     .        . -2 : 'nomet' a plusieurs elements et       .
c .        .     .        .      'champ' /= '  ' et /= champ-terminal  .
c .        .     .        . -1 : 'nomet' a un seul element et 'champ'  .
c .        .     .        .      ne correspond pas a un champ de 'nomet.
c .        .     .        .  0 : tout va bien                          .
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c
c 0.1. ==> generalites
c
      implicit none
      save
c
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtors.h"
#include "gmtoas.h"
#include "gminom.h"
c
#include "gmimpr.h"
c
c 0.3. ==> arguments
c
      character*(*) nomet,champ
      character*8 nomgen
c
      integer       codret
c
c 0.4. ==> variables locales
c
      character*8 objrep, objter, chater
c
      integer idec,ity,nbc
      integer nroobj
      integer iaux, jaux
c
c 0.5. ==> initialisations
c
#include "alphnu.h"
c ______________________________________________________________________
c
c====
c 1. decodage 'nomet'
c====
c
      codret = 0
c
c 1.1. ==> prgramme de decodage
c
      call gbdnoe(nomet,objrep,objter,chater,idec)
c
c 1.2. ==> le nom etendu est invalide
c
      if (idec.eq.-1) then
c
        codret = -4
c
c 1.3. ==> le nom etendu n'a qu'un element
c
      elseif (idec.eq.0) then
c
        do 131 , iaux = 1,iptobj-1
          if (nomobj(iaux).eq.nomet) then
            nroobj = iaux
            goto 132
          endif
  131   continue
        codret = -3
        goto 134
c
  132   continue
        ity = typobj(nroobj)
        nbc = nbcham(ity)
        do 133 , iaux = adrdst(ity),adrdst(ity)+nbc-1
          if (nomcha(iaux).eq.champ) then
            goto 134
          endif
  133   continue
        codret = -1
c
  134   continue
c
c 1.4. ==> autres cas
c
      else
c
        if ( champ.ne.' ' .and. champ.ne.chater ) then
          codret = -2
        endif
c
      endif
c
c====
c 2. formation du nom genere
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> 4 premiers caracteres deduits du nom etendu
c
        if (champ.eq.' ') then
          nomgen(1:4) = nomet(1:2)//chater(1:2)
        else
          nomgen(1:4) = nomet(1:2)//champ(1:2)
        endif
        do 21 , iaux = 1,4
          if (nomgen(iaux:iaux).eq.' ') then
            nomgen(iaux:iaux) = '$'
          endif
   21   continue
c
c 2.2. ==> 4 caracteres suivants
c
        nomgen(5:8) = '0000'
c
        indnom = indnom+1
c
        iaux = mod(indnom,lgalnu)
        nomgen(8:8) = alphnu(iaux)
c
        if ( indnom.ge.lgalnu ) then
c
          jaux = (indnom-iaux) / lgalnu
          iaux = mod(jaux,lgalnu)
          nomgen(7:7) = alphnu(iaux)
c
          if ( indnom.ge.lgaln2 ) then
c
            jaux = (jaux-iaux) / lgalnu
            iaux = mod(jaux,lgalnu)
            nomgen(6:6) = alphnu(iaux)
c
            if ( indnom.ge.lgaln3 ) then
              jaux = (jaux-iaux) / lgalnu
              iaux = mod(jaux,lgalnu)
              nomgen(5:5) = alphnu(iaux)
            endif
c
          endif
c
        endif
c
      endif
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
        write (ulsort,*) 'Probleme dans gbgeno'
        write (ulsort,*) 'Code de retour = ',codret
      endif
c
      end
