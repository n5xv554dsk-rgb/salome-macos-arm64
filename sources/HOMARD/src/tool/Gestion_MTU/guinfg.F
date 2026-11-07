      subroutine guinfg ( liste, codret, imprim )
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
c but : donne l'etat d'une ou de toutes les unites logiques
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . liste  . e   .    1   . 0 : toutes les unites sont a renseigner    .
c .        .     .        . 1<liste<mbmxul : numero de l'unite a       .
c .        .     .        . renseigner                                 .
c . imprim . e   . logical. vrai -> impression, faux -> pas d'impres.  .
c . codret .  s  .    1   . statut de l'unite a renseigner si 1 seule  .
c .        .     .        . 0 si probleme, -1 si tous les fichiers     .
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
      character*6 nompro
      parameter ( nompro = 'GUINFG' )
c
#include "genbla.h"
#include "gunbul.h"
#include "gulggt.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer liste, codret
c
      logical imprim
c
c 0.4. ==> variables locales
c
      integer unideb, unifin
      integer ulsort, langue
      integer iaux, code, unite
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
c
      character*200 nomfic(mbmxul)
      character*49 chau49
      character*200 bla200
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
      character*59 chstat(nblang,0:8), chau59
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c===
c 1. initialisation
c===
c
c 1.1. ==> messages
c
#include "impr01.h"
c
c               1 234 567890 123456789012345678901234567890123456789
      chau49 = '(''*'',12x,''Recapitulatif des unites logiques activ'
      texte(1,10) = chau49//'es'',13x,''*'')'
      texte(1,4) =
     > '(''* No *'',18x,''Statut de l''''unite logique'',18x,''*'')'
      texte(1,5) = '(''*    * Fichier : '',a49,'' *'')'
c
      texte(2,10) =
     > '(''*'',17x,''Summary of active logical units'',18x,''*'')'
      texte(2,4) =
     > '(''* #  *'',17x,''Status of the logical unit'',18x,''*'')'
      texte(2,5) = '(''*    * File : '',a49,''    *'')'
c
c 1.2. ==> recuperation de l'information
c
      code = 1
      call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
      ulsort = gunmbr(16)
      langue = gunmbr(17)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.3. ==> variables auxiliaires
c
c                    1234567890123456789012345678901234567890123456789
      chstat(1,0) = 'Disponible                                       '
      chstat(1,1) = 'Entree standard (sequentiel formate)             '
      chstat(1,2) = 'Sortie standard (sequentiel formate)             '
      chstat(1,3) = 'Ouvert en acces sequentiel formate               '
      chstat(1,4) = 'Ouvert en acces sequentiel binaire               '
      chstat(1,5) = 'Ouvert en acces direct binaire standard          '
      chstat(1,6) = 'Ouvert en acces direct binaire special           '
      chstat(1,7) = 'Interdit                                         '
      chstat(1,8) = 'standard de la machine                           '
c
      chstat(2,0) = 'Available                                        '
      chstat(2,1) = 'Standard input (formatted, sequential access)    '
      chstat(2,2) = 'Standard output (formatted, sequential access)   '
      chstat(2,3) = 'Opened in formatted sequential access mode       '
      chstat(2,4) = 'Opened in binary sequential access mode          '
      chstat(2,5) = 'Opened in binary direct access mode              '
      chstat(2,6) = 'Opened in special binary direct access mode      '
      chstat(2,7) = 'Forbidden                                        '
      chstat(2,8) = 'standard of the computer                         '
c
      do 11 , iaux = 1 , 200
         bla200(iaux:iaux) = ' '
   11 continue
c
c===
c 2. verification
c===
c
      if ( liste.eq.0 ) then
         unideb = 1
         unifin = mbmxul
         iaux = 0
      elseif ( liste.ge.1 .and. liste.le.mbmxul ) then
         unideb = liste
         unifin = liste
         iaux = -1
      else
         if ( ulsort.ge.1 .and. ulsort.le.mbmxul ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
           write (ulsort,20000) liste, mbmxul
         endif
         unideb = 0
         unifin = -1
      endif
c
c===
c 3. impressions
c===
c
      if ( imprim ) then
c
c 3.1. ==> en tete
c
        write (ulsort,30030)
        if ( liste.eq.0 ) then
           write (ulsort,30000)
           write (ulsort,texte(langue,10))
        endif
        write (ulsort,30000)
        write (ulsort,texte(langue,4))
        write (ulsort,30000)
c
c 3.2. ==> pour chaque unite retenue
c
        do 32 , unite = unideb , unifin
c
          if ( statut(unite).ne.iaux ) then
c
            write (ulsort,30010) unite, chstat(langue,statut(unite))
c
            if ( statut(unite).ge.1 .and. statut(unite).le.2 ) then
c
              write (ulsort,texte(langue,5)) chstat(langue,8)
c
            elseif ( statut(unite).ge.3 .and. statut(unite).le.6 ) then
c
              if ( lnomfi(unite).le.49 ) then
                 chau49(1:49) = bla200(1:49)
                 if ( lnomfi(unite).gt.0 ) then
                 chau49(1:lnomfi(unite)) =nomfic(unite)(1:lnomfi(unite))
                 endif
                 write (ulsort,texte(langue,5)) chau49
c
              elseif ( lnomfi(unite).le.108 ) then
                 chau49 = nomfic(unite)(1:49)
                 write (ulsort,texte(langue,5)) chau49
                 chau59(1:59) = bla200(1:59)
                 chau59(1:lnomfi(unite)-49) =
     >           nomfic(unite)(50:lnomfi(unite))
                 write (ulsort,30020) chau59
c
              elseif ( lnomfi(unite).le.167 ) then
                 chau49 = nomfic(unite)(1:49)
                 write (ulsort,texte(langue,5)) chau49
                 chau59 = nomfic(unite)(50:108)
                 write (ulsort,30020) chau59
                 chau59(1:59) = bla200(1:59)
                 chau59(1:lnomfi(unite)-108) =
     >           nomfic(unite)(109:lnomfi(unite))
                 write (ulsort,30020) chau59
c
              else
                 chau49 = nomfic(unite)(1:49)
                 write (ulsort,texte(langue,5)) chau49
                 chau59 = nomfic(unite)(50:108)
                 write (ulsort,30020) chau59
                 chau59 = nomfic(unite)(109:167)
                 write (ulsort,30020) chau59
                 chau59(1:59) = bla200(1:59)
                 chau59(1:lnomfi(unite)-167) =
     >           nomfic(unite)(168:lnomfi(unite))
                 write (ulsort,30020) chau59
c
              endif
c
            endif
c
          endif
c
   32   continue
c
c 3.3. ==> fin du recapitulatif
c
        write (ulsort,30000)
        write (ulsort,30030)
c
      endif
c
c===
c 4. si une seule unite a ete interrogee, on renvoie le statut
c===
c
      if ( liste.ge.1 .and. liste.le.mbmxul ) then
         codret = statut(liste)
      else
         codret = -1
      endif
c
c===
c 5. formats
c===
c
20000 format(
     >/,'Le numero ',i4,' ne correspond a aucun code possible.',
     >/,'Il faut soit un numero d''unite logique, donc compris ',
     >     'entre 1 et ',i4,
     >/,'soit 0 pour les avoir toutes.',/)
c
30000 format(68('*'))
30010 format('* ',i2,' * ',a59,' *')
30020 format('*    * ',a59,' *')
30030 format(//)
c
      end
