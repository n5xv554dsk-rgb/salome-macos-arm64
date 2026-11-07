      subroutine dmftmp ( nomdep , lnomde , nomfic , lnomfi )
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
c   Dependance Machine - Fichier TeMPoraire
c   -          -         -       - --
c ______________________________________________________________________
c
c  on determine un nom de fichier dont on est sur qu'il n'existe pas.
c  Ce fichier doit se trouver dans le meme repertoire qu'un fichier
c  de depart pour pouvoir faire du renommage par la suite.
c
c  "renomme" un fichier (trouve un nouveau nom, nomfic, a partir
c                        du nom de depart nomdep)
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomdep . e   .  ch    . ancien nom du fichier                      .
c . lnomde . e   .  e     . longueur de l'ancien nom du fichier        .
c . nomfic .  s  .  ch    . nouveau nom du fichier                     .
c . lnomfi .  s  . e   .  . longueur du nouveau nom du fichier         .
c . ulsort . e   .    1   . unite logique de la liste standard         .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      character*(*) nomdep, nomfic
c
      integer lnomde, lnomfi
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, lnomd
c
      character*4 fmt
c
      logical old
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. on concatene une chaine de caracteres jusqu'a trouver un fichier
c    qui n'existe pas.
c====
c
      lnomd = min( max(0,lnomde), max(0,len(nomdep)) )
      do 1 iaux = 1, len(nomfic)
        nomfic(iaux:iaux) = ' '
    1 continue
c
      if ( lnomd.lt.len(nomfic) ) then
        if ( lnomd.gt.0 ) then
          nomfic(1:lnomd) = nomdep( 1 : lnomd )
        endif
        jaux = lnomd + 1
      else
        lnomfi = 0
        goto 12
      endif
c
      do 11 , iaux = 1 , 999999
c
        if ( iaux.le.9 ) then
          fmt = '(I1)'
          lnomfi = lnomd + 1
        elseif ( iaux.le.99 ) then
          fmt = '(I2)'
          lnomfi = lnomd + 2
        elseif ( iaux.le.999 ) then
          fmt = '(I3)'
          lnomfi = lnomd + 3
        elseif ( iaux.le.9999 ) then
          fmt = '(I4)'
          lnomfi = lnomd + 4
        elseif ( iaux.le.99999 ) then
          fmt = '(I5)'
          lnomfi = lnomd + 5
        else
          fmt = '(I6)'
          lnomfi = lnomd + 6
        endif
c
        if ( lnomfi.le.len(nomfic) ) then
c
          write ( nomfic(jaux:lnomfi) , fmt ) iaux
c
          inquire (file=nomfic(1:lnomfi),exist=old)
c
          if ( .not.old ) then
            goto 12
          endif
c
        else
          lnomfi = 0
          goto 12
        endif
c
   11 continue
c
      lnomfi = 0
c
   12 continue
c
      end
