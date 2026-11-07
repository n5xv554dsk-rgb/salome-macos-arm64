      subroutine gbpart (chaine,elem,lelm,nelm,lgtot,sepa,ns,codret)
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
c     partition d'une chaine de caracteres 'chaine' en differents
c     elements separes par des caracteres 'sepa'
c
c     on elimine les blancs en fin de ligne
c
c     ...........................................................
c
c     entrees  :
c       chaine : chaine a departager
c       sepa   : les caracteres separateurs
c       ns     : nombre de caracteres separateurs
c     sorties  :
c       elem   : tableau des elements separes
c       lelm   : longueurs des elements
c       nelm   : nombre d'elements
c       lgtot  : longueur totale de la chaine
c       codret   :
c        -1    : chaine vide
c         0    : OK
c
c     ...........................................................
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
#include "gmnelx.h"
c
      character*(*) chaine
      character*80  elem(nelx)
      character*1   sepa(4)
      integer       lelm(nelx), nelm, lgtot, ns, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, sepcav, sepcco, iel
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1.  initialisation
c====
c
      do 10 , iaux = 1,nelx
         elem(iaux) = ' '
         lelm(iaux) = 0
   10 continue
c
c====
c 2.  partition
c====
c
      codret = -1
c
c 2.1. ==> longueur de la chaine, apres avoir elimine les blancs
c          en fin de ligne
c
      lgtot = len(chaine) 
c
      jaux = lgtot
      do 21 , iaux = lgtot , 1 , -1
         if ( chaine(iaux:iaux).eq.' ' ) then
            jaux = jaux - 1
         else
            goto 22
         endif
   21 continue
c
   22 continue
c
      lgtot = max(0,jaux)
c
      nelm = 0
      sepcav = 1
c
c     sepcav = 1 : le caractere precedent est un separateur
c              0 : le caractere precedent n'est pas un separateur
c     sepcco = 1 : le caractere courant est un separateur
c              0 : le caractere courant n'est pas un separateur
c
      do 23 , iaux = 1 , lgtot
c
c 2.2. ==> le caractere courant est-il un separateur ?
c
         sepcco = 0
         do 24 , jaux = 1 , ns
            if (chaine(iaux:iaux).eq.sepa(jaux)) then
               sepcco = 1
            endif
   24    continue
c
c 2.3. ==> le caractere courant n'est pas un separateur
c          si le caractere d'avant etait un separateur, on change de mot
c          on memorise le caractere
c
         if (sepcco.eq.0) then
c
            if (sepcav.eq.1) then
               sepcav = 0
               nelm = nelm+1
               iel  = 0
            endif
            iel = iel+1
            elem(nelm)(iel:iel) = chaine(iaux:iaux)
c
c 2.4. ==> le caractere courant est un separateur
c
         else
c
            if (sepcav.eq.0) then
               lelm(nelm) = iel
            endif
            sepcav = 1
c
         endif
c
   23 continue
c
c====
c 3. longueur vraie du dernier troncon
c====
c
      if (nelm.ne.0) then
c
         lelm(nelm) = iel
c
         codret = 0
c
      endif
c
      end
