      subroutine dmmach ( nomare, nomais, typmac,
     >                    noarch, systre, systve,
     >                    lgcar )
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
c   Dependance Machine : caracteristiques de la MACHine
c   -          -                                ----
c ______________________________________________________________________
c
c  retourne le type de machine sur laquelle a lieu le calcul
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomare .  s  . char*  . nom reseau de la machine                   .
c . nomais .  s  . char*  . nom de la machine isolee                   .
c . typmac .  s  . char*  . type de la machine                         .
c . noarch .  s  . char*  . nom de l'architecture systeme              .
c . systre .  s  . char*  . release du systeme                         .
c . systve .  s  . char*  . version du systeme                         .
c . lgcar  .  s  .   6    . longueurs de chacune des chaines de caract..
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
      integer nbcar
      parameter ( nbcar = 6 )
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      character*(*) nomare
      character*(*) nomais
      character*(*) typmac
      character*(*) noarch
      character*(*) systre
      character*(*) systve
c
      integer lgcar(nbcar)
c
c 0.4. ==> variables locales
#ifdef _DEBUG_HOMARD_
      integer enstul, sostul
#endif
c
      integer iaux, jaux
      integer luname(nbcar)
      integer lgcloc(nbcar)
      character*255 uname(nbcar)
c
c 0.5. ==> initialisations
c
c===
c 1. nom et numero de la machine
c===
c
c 1.1. ==> on suppose que l'on ignore tout
c
      lgcloc(1) = len(nomare)
      lgcloc(2) = len(nomais)
      lgcloc(3) = len(typmac)
      lgcloc(4) = len(noarch)
      lgcloc(5) = len(systre)
      lgcloc(6) = len(systve)
c
      nomare = ' '
      nomais = ' '
      typmac = ' '
      noarch = ' '
      systre = ' '
      systve = ' '
c
      do 11 , iaux = 1 , nbcar
        lgcar(iaux) = 1
   11 continue
c
c 1.2. ==> preparation de l'appel a dmmacc : on met la chaine a blanc
c jaux est la taille (nombre de caracteres) de chaque element
c du tableau uname. 256 semblerait etre une bonne valeur,
c preconisee sous unix, ...
c mais ftnchek rale au dela de 255 (portabilite).
c
      jaux = len (uname(1))
c
      do 121 , iaux = 1, jaux
        uname(1)(iaux:iaux) = ' '
  121 continue
      luname(1) = jaux
c
      do 122 , iaux = 2, nbcar
        uname(iaux) = uname(1)
        luname(iaux) = luname(1)
  122 continue
c
c 1.3. ==> appel de la fonction C equivalente
c      argument 1 = nomare
c      argument 2 = typmac
c      argument 3 = noarch
c      argument 4 = systre
c      argument 5 = systve
c
      call dmmacc ( uname(1), luname(1), uname(2), luname(2),
     >              uname(3), luname(3), uname(4), luname(4),
     >              uname(5), luname(5) )
c
c====
c 2. transfert dans les bonnes variables
c====
c 2.1. ==> nettoyage eventuel (caracteres non impr.)
c
      do 21 , iaux = 1, nbcar
        call dmcpch ( uname(iaux), luname(iaux),
     >                uname(iaux), luname(iaux) )
   21 continue
c
c 2.2. ==> transfert
c 2.2.1. ==> argument 1 = nomare
c
      if ( luname(1).gt.0 ) then
        iaux = min(luname(1),lgcloc(1))
        nomare(1:iaux) = uname(1)(1:iaux)
        lgcar(1) = iaux
      endif
      if ( luname(1).gt.0 ) then
        do 22 , iaux = 1 , lgcar(1)
          if ( nomare(iaux:iaux).eq.'.' ) then
            lgcar(2) = iaux-1
            goto 221
          endif
          nomais(iaux:iaux) = nomare(iaux:iaux)
   22   continue
        lgcar(2) = lgcar(1)
  221   continue
      endif
c
c 2.2.2. ==> argument 2 = typmac
c
      if ( luname(2).gt.0 ) then
        iaux = min(luname(2),lgcloc(2))
        typmac(1:iaux) = uname(2)(1:iaux)
        lgcar(3) = iaux
      endif
c
c 2.2.3. ==> argument 2 = noarch
c
      if ( luname(3).gt.0 ) then
        iaux = min(luname(3),lgcloc(3))
        noarch(1:iaux) = uname(3)(1:iaux)
        lgcar(4) = iaux
      endif
c
c 2.2.4. ==> argument 4 = systre
c
      if ( luname(4).gt.0 ) then
        iaux = min(luname(4),lgcloc(4))
        systre(1:iaux) = uname(4)(1:iaux)
        lgcar(5) = iaux
      endif
c
c 2.2.5. ==> argument 5 = systve
c
      if ( luname(5).gt.0 ) then
        iaux = min(luname(5),lgcloc(5))
        systve(1:iaux) = uname(5)(1:iaux)
        lgcar(6) = iaux
      endif
c
#ifdef _DEBUG_HOMARD_
      call dmunit ( enstul, sostul )
      write(sostul,*) 'Dans dmmach :'
      write(sostul,*) 'nom reseau   = ', nomare
      write(sostul,*) 'nom isole    = ', nomais
      write(sostul,*) 'typmac       = ', typmac
      write(sostul,*) 'architecture = ', noarch
      write(sostul,*) 'release      = ', systre
      write(sostul,*) 'version      = ', systve
#endif
c
      end
