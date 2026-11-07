      subroutine gmmaxi (maxtro , mtotro , ntrou , ltrou)
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
c .  derniere modif 15/06/89 jc jyb
c ......................................................................
c .
c .  - fonction
c .       calcule a partir des communs gerant les pointeurs, la taille
c .       des plus gros trous disponibles et la place potentiellement
c .       utilisable si on compactait
c .
c .  - realisation:
c .       examen du common trous
c .
c .  - arguments:
c .       donnees              ntrou  -->  nbre de trous existants
c .                            ltrou  -->  tab des longueurs de trous
c .       resultats
c .                            maxtro <--  taille du + gd trou existant
c .                            mtotro <--  cumul de la place restante
c .                                          dans le tableau
c ......................................................................
c
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
      integer  ntrou  , ltrou (ntrou)
      integer  maxtro , mtotro
c
c 0.4. ==> variables locales
c
      integer  i
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c---
c  2. etude du tableau
c---
c
      maxtro = 0
      mtotro = 0
c
      do 20 i=1,ntrou
         mtotro = mtotro + ltrou(i)
         maxtro = max(maxtro,ltrou(i))
   20 continue
c
ctst  write ( 6, 2000 ) maxtro,mtotro
c2000 format(//2x,'****  spg gmmaxi *****',/5x,
ctst * ' taille du plus gd trou  disponible       :',i9,/5x,
ctst * ' taille totale potentiellement disponible :',i9)
c
      end
