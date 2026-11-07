      subroutine dmcpch ( chain1, long1, chain2, long2 )
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
c   Dependance Machine : CoPie de CHaine de caracteres
c   -          -         - -      --
c ______________________________________________________________________
c
c
c but : copie "prudente" de la chaine 1 dans la chaine 2
c
c       . les eventuels caracteres non imprimables sont remplaces      .
c       par des blancs ... sauf ceux en debut et fin de chaine,        .
c       qui sont elimines.                                             .
c
c dependance machine : code ASCII
c                      ( blanc = 32, et
c                        non imprimable <==> code < 32 ...
c                        ... sauf que les TAB (code 9) sont remplaces
c                        par un blanc chacun )
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . chain1 . e   . char * . chaine "source"                            .
c . long1  . e   .    1   . longueur utile de la chaine "source"       .
c . chain2 .  s  . char * . chaine "cible"                             .
c . long2  .  s  .    1   . longueur utile de la chaine "cible"        .
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
      integer       long1, long2
      character*(*) chain1, chain2
c
c 0.4. ==> variables locales
c
      integer long, iaux, deb, fin, dern0, deb1, p0
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1.
c====
c
      long = 0
      deb = 0
      deb1 = 0
      dern0 = 0
      p0 = -1
c
      do 1 iaux = 1, min( len(chain1), long1 )
        if ( ichar(chain1(iaux:iaux)).gt.32 ) then
          if ( deb.eq.0 ) then
            deb = iaux
          endif
          fin = iaux
          p0 = 0
          if ( long.lt.len(chain2) ) then
            if ( deb1.eq.0 ) then
              deb1 = iaux
            endif
            long = long + 1
            chain2(long:long) = chain1(iaux:iaux)
          endif
        else if ( ichar(chain1(iaux:iaux)).eq.32 .or.
     >            ichar(chain1(iaux:iaux)).eq.9       ) then
          if ( deb.eq.0 ) then
            deb = iaux
          endif
          if ( long.lt.len(chain2) ) then
            long = long + 1
            chain2(long:long) = ' '
          endif
        else
c
c non imprimables:
c
          if ( deb.gt.0 .and. long.lt.len(chain2) ) then
            long = long + 1
            chain2(long:long) = ' '
          endif
          dern0 = iaux
          if ( p0.eq.0 ) then
            p0 = iaux
          endif
        endif
    1 continue
c
c On complete eventuellement avec des blancs :
c (mais qui ne seront pas comptes dans long2)
c
      do 10 iaux = long+1, len(chain2)
        chain2(iaux:iaux) = ' '
   10 continue
c
c Bilan :
c
      if ( deb1.gt.0 ) then
c
c Il y a au moins un caractere imprimable et non blanc, qui a pu
c etre copie de la chaine source chain1 vers la cible chain2 :
c (deb1 est le premier de ceux-ci dans chain1)
c
        if ( dern0.lt.fin ) then
          long2 = long
        else
c
c Apres le dernier caractere imprimable et non blanc de chain1 (fin),
c on a trouve : des blancs eventuels, puis un premier caractere non
c imprimable (p0), puis eventuellement des blancs ou non impr.
c puis enfin un dernier caractere non impr. (dern0, >= p0),
c puis des blancs eventuels.
c
c deb pointe sur le premier caractere "utile" (blanc ou imprimable)
c de chaine1 (deb<=deb1<=fin)
c p0-1 serait le dernier caractere "utile" de chaine1 (fin<=p0-1)
c
          long2 = min( max(0,len(chain2)) , p0-deb )
c
        endif
c
      else
c
c chaine "source" vide, ou entierement blanche(+caracteres non impr.) :
c
        long2 = 0
c
      endif
c
      end
