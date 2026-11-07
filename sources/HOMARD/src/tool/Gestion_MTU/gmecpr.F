      subroutine gmecpr ( nuroul, numann )
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
c       Gestionnaire de la Memoire : ECriture du PRogramme
c       -                  -         --          --
c ______________________________________________________________________
c
c     ecrit un programme qui realise l'initialisation des tables
c     de description des types d'objet structure.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numann . e   .   1    . numero de l'annee                          .
c . nuroul . e   .    1   . numero de l'unite logique ou on ecrit      .
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c 0.1 ==> generalites
c
      implicit none
      save
c
      character*6 nompro
      parameter ( nompro = 'GMECPR' )
c
#include "genbla.h"
c
#include "gmmatc.h"
c
#include "nuvers.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtors.h"
#include "gmtove.h"
c
#ifdef _DEBUG_HOMARD_
#include "gmimpr.h"
#include "gmlang.h"
#endif
c
c 0.3. ==> arguments
c
      integer nuroul
      integer numann
c
      character*48 ladate
c
c 0.4. ==> variables locales
c
#include "gmnelx.h"
c
      integer iaux, jaux, jdeb, jfin
c
      integer nbmess
      parameter ( nbmess = 10 )
c
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1.  les messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 2. ecriture du fichier
c====
c
c 2.1. ==> en-tete
c
      write (nuroul,21001) nuvers
      write (nuroul,21002) numann
      write (nuroul,21003)
      write (nuroul,21004)
c
21001 format (
     >  '      subroutine gmitob',
     >/,'c ',70('_'),
     >/,'c',
     >/,'c',25x,'H O M A R D     ',a8,
     >/,'c')
c
21002 format (
     >  'c Outil de Maillage Adaptatif par Raffinement',
     >  ' et Deraffinement d''EDF R&D',
     >/,'c',
     >/,'c Version originale enregistree le 18 juin 1996',
     >  ' sous le numero 96036',
     >/,'c aupres des huissiers de justice Simart et Lavoir a Clamart',
     >/,'c Version 11.2 enregistree le 13 fevrier 2015',
     >  ' sous le numero 2015/014',
     >/,'c aupres des huissiers de justice',
     >/,'c Lavoir, Silinski & Cherqui-Abrahmi a Clamart',
     >/,'c',
     >/,'c',
     >/,'c Copyright EDF 1996, ',i4,
     >/,'c ',70('_'),
     >/,'c')
21003 format (
     >  'c       Gestionnaire de la Memoire :',
     >/,'c       -                  -',
     >/,'c       Initialisation des Tables d''OBjets',
     >/,'c       -                  -        --',
     >/,'c',
     >/,'      save',
     >/,'c')
c
21004 format (
     >  '#include "gmmatc.h"',
     >/,'c',
     >/,'#include "gmtoas.h"',
     >/,'#include "gmtori.h"',
     >/,'#include "gmtors.h"',
     >/,'#include "gmtove.h"',
     >/,'c',
     >/,'      integer iaux',
     >/,'c')
c
c 2.2. ==> numeros de version
c
      write (nuroul,22001) nuveto, nusvto, daheto, nuanto
c
22001 format (
     >  'c numeros de version des tables d''objets',
     >/,'c',
     >/,'      nuveto = ',i12,
     >/,'      nusvto = ',i12,
     >/,'      daheto = ',i12,
     >/,'      nuanto = ',i12,
     >/,'c')
c
c 2.3. ==> tables
c
      write (nuroul,23001) nbrtyp
      do 23 , iaux = 1 , nbrtyp
        write (nuroul,23002) iaux, nomtyp(iaux),
     >                       iaux, nbratt(iaux),
     >                       iaux, nbcham(iaux),
     >                       iaux, adrdst(iaux)
        jdeb = adrdst(iaux)
        jfin = jdeb + nbcham(iaux) - 1
        do 231 , jaux = jdeb , jfin
          write (nuroul,23003) jaux, nomcha(jaux),
     >                         jaux, typcha(jaux)
  231   continue
   23 continue
c
23001 format (
     >  'c objets structures',
     >/,'c',
     >/,'      nbrtyp = ',i12)
23002 format (
     >  'c',
     >/,'c--------------------------------------------------',
     >/,'c',
     >/,'      nomtyp(',i10,') = ''',a8,'''',
     >/,'      nbratt(',i10,') = ',i12,
     >/,'      nbcham(',i10,') = ',i12,
     >/,'      adrdst(',i10,') = ',i12,
     >/,'c')
23003 format (
     >  '        nomcha(',i10,') = ''',a8,'''',
     >/,'        typcha(',i10,') = ',i12)
c
c 2.4. ==> transfert
c
      write (nuroul,24001)
c
24001 format (
     >  'c',
     >/,'      do 24 , iaux = 1 , nbrtyp',
     >/,'        nomtbp(iaux) = nomtyp(iaux)',
     >/,'   24 continue',
     >/,'c')
c
c 2.5. ==> la fin
c
      write (nuroul,25001)
c
25001 format (
     >  '      end')
c
      end
