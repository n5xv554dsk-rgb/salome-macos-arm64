      subroutine gbminu (chaine,txminu)
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
c     conversion d'une chaine de caracteres 'chaine' en une
c     chaine 'txminu' de caracteres minuscules
c     ...........................................................
c
c     entrees  :
c       chaine : chaine a convertir
c     sorties  :
c       txminu : chaine en minuscules
c
c===
c 0. declarations et dimensionnement
c===
c
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
      character*(*) chaine,txminu
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lgmin, lgchai, lgtmin
      integer decala, amaju, zmaju
      logical prem
c
      data prem / .true. /
c_______________________________________________________________________
c
c 1. initialisation au premier passage
c
      if ( prem ) then
        amaju = ichar('A')
        zmaju = ichar('Z')
        decala = ichar('a') - amaju
        prem = .false.
      endif
c
c 2.  transformation en minuscules
c
      lgchai = max(0,len(chaine))
      lgtmin = max(0,len(txminu))
c
      lgmin = min ( lgchai , lgtmin )
      do 21 , iaux = 1 , lgmin
        jaux = ichar(chaine(iaux:iaux))
        if ( jaux.ge.amaju .and. jaux.le.zmaju ) then
          txminu(iaux:iaux) = char(jaux+decala)
        else
          txminu(iaux:iaux) = chaine(iaux:iaux)
        endif
   21 continue
c
      jaux = lgmin + 1
      do 22 , iaux = jaux , lgtmin
        txminu(iaux:iaux) = ' '
   22 continue
c
      end
