      subroutine dmnfcv ( nfichi, lfichi )
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
c   Dependance Machine : Nom de Fichier ConVerti
c   -          -         -      -       -  -
c ______________________________________________________________________
c
c REMARQUE : en fait on ne fait RIEN
c            il faudrait traiter le probleme en C pour Windows
c
c but : convertit un nom de fichier UNIX en un nom de fichier
c       acceptable par le systeme d'exploitation utilise.
c       autrement dit, sous WINDOWS, change les / en \ , et            .
c       ailleurs (sous UNIX, en particulier), ne fait RIEN             .
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nfichi . es  . char * . nom de fichier                             .
c . lfichi . e   .    1   . longueur de ce nom                         .
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
      integer       lfichi
      character*(*) nfichi
c
c 0.4. ==> variables locales
c
      integer iaux
c
      character*1 slash
c
      character*1 slashu
      parameter ( slashu = '/' )
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. Recherche du caractere de separation pour la machine courante
c====
c
      call dmsepf ( slash )
c
c====
c 2. Substitution le cas echeant
c====
c
      if ( slash.ne.slashu ) then
c
        do 21 , iaux = 1 , lfichi
          if ( nfichi(iaux:iaux).eq.slashu ) then
            nfichi(iaux:iaux) = slash
          endif
   21   continue
c
      endif
c
      end
