      subroutine dmralo ( adress, taille, codret )
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
c   Dependance Machine : ReALlOcation
c   -          -         - -- -
c ______________________________________________________________________
c
c  but : re-alloue une place memoire demarrant a adress,
c        a la nouvelle taille
c  Attention : l'adresse de depart peut etre MODIFIEE, meme si la
c              nouvelle taille est plus petite que l'ancienne.
c              Le contenu, lui, est conserve.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . adress . es  .   1    . adresse de depart de la zone allouee       .
c . taille . e   .   1    . nouvelle taille de la zone allouee         .
c . codret .  s  .   1    . code d'erreur ( 0 : tout va bien )         .
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
c 0.3. ==> arguments
c
      integer adress, taille, codret
c
c 0.4. ==> variables locales
c ______________________________________________________________________
c
c Precautions generales d'emploi:
c         - la taille finale doit etre strictement positive
c           (sinon, ce serait une desallocation complete: cf. dmlibe)
c         - l'adresse de depart doit correspondre (en entree) a une
c           adresse de depart d'une zone allouee (cf. dmalme) ou
c           re-allouee...
c
      if ( taille.gt.0 ) then
c
        call dmralc ( adress, taille )
c
        if ( adress.eq.0 ) then
          codret = 1
        else
          codret = 0
        endif
c
      else
c
        codret = -1
c
      endif
c
      end
