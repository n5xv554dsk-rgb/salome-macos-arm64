      subroutine dmoufs ( nuroul , nomfic, lnomfi,
     >                    ulmess, codret )
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
c   Dependance Machine - OUverture en Formate Sequentiel
c   -          -         --           -       -
c ______________________________________________________________________
c
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nuroul . e   .    1   . numero de l'unite logique attribuee        .
c . nomfic . e   . ch<200 . nom du fichier a ouvrir                    .
c . lnomfi . e   .    1   . longueur du nom du fichier a ouvrir        .
c . ulmess . e   .    1   . numero d'unite logique des messages        .
c . codret .  s  .    1   . code de retour : 0 si c'est bon            .
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
      integer nuroul, lnomfi, codret, ulmess
c
      character*(*) nomfic
c
c 0.4. ==> variables locales
c
c 0.5. ==> initialisations
c
c===
c 1. pas de differences entre les machines
c===
c
      open ( unit=nuroul, err=10, file=nomfic(1:lnomfi),
     >       access='SEQUENTIAL', form='FORMATTED',
     >       status='UNKNOWN', iostat=codret )
c
      goto 11
c
   10 continue
      if ( codret.eq.0 ) then
         codret = -1
      endif
c
   11 continue
c
      if ( codret.ne.0 ) then
         write(ulmess,*) 'Ouverture du fichier :'
         write(ulmess,*) nomfic(1:lnomfi)
         write(ulmess,*) 'Code retour dans dmoufs : ',codret
      endif
c
      end
