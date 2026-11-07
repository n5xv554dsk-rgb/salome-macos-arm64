      subroutine utbide ( codebi, nbval1, tabaux )
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
c     UTilitaire : du BInaire vers le DEcimal
c     --              --              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . codebi . e   .  1     . code binaire a decoder (<4095=2*12-1)      .
c . nbval1 .  s  .  1     . nombre de valeurs 1                        .
c . tabaux .  s  .  12    . valeurs 0/1                                .
c .____________________________________________________________________.
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
      integer codebi
      integer nbval1, tabaux(12)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer valeur, reste
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. traitement
c    Remarque : on pourrait proceder avec des if sucessifs.
c    Est-ce plus economique ?
c====
c
      nbval1 = 0
      valeur = codebi
      do 10 , iaux = 1 , 12
c
        reste = mod(valeur,2)
        if ( reste.eq.0 ) then
          tabaux(iaux) = 0
        else
          tabaux(iaux) = 1
          valeur = valeur - 1
          nbval1 = nbval1 + 1
        endif
        valeur = valeur/2
c
   10 continue
c
      end
