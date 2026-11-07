       subroutine hoprin
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
c       HOMARD : programme PRINcipal
c       --                 ----
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
      parameter ( nompro = 'HOPRIN' )
c
#include "nblang.h"
#include "referx.h"
c
c 0.2. ==> communs
c          On les met tous pour assurer la coherence en descendance.
c          En principe, le save devrait remedier a cela mais on fait
c          ceinture et bretelles
c
#include "chisig.h"
#include "cndoad.h"
#include "cofhex.h"
#include "cofpen.h"
#include "comp07.h"
#include "defiqu.h"
#include "demitr.h"
#include "dicfen.h"
#include "enti01.h"
#include "envada.h"
#include "envca1.h"
#include "envca2.h"
#include "envex1.h"
#include "fahmed.h"
#include "front0.h"
#include "front1.h"
#include "front2.h"
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
#include "hexcf0.h"
#include "hexcf1.h"
#include "i1i2i3.h"
#include "impr02.h"
#include "indefi.h"
#include "indefr.h"
#include "indefs.h"
#include "infini.h"
#include "j1234j.h"
#include "nancnb.h"
#include "nbfami.h"
#include "nbfamm.h"
#include "nbutil.h"
#include "nombar.h"
#include "nomber.h"
#include "nombhe.h"
#include "nombmp.h"
#include "nombno.h"
#include "nombpe.h"
#include "nombpy.h"
#include "nombqu.h"
#include "nombsr.h"
#include "nombte.h"
#include "nombtr.h"
#include "nomest.h"
#include "nouvnb.h"
#include "op0123.h"
#include "op1234.h"
#include "op1aa6.h"
#include "ope1a3.h"
#include "ope1a4.h"
#include "ope4a6.h"
#include "oriefp.h"
#include "oriefy.h"
#include "orieqh.h"
#include "oriett.h"
#include "permut.h"
#include "precis.h"
#include "refere.h"
#include "refert.h"
#include "rfamed.h"
#include "rftmed.h"
c
c 0.3. ==> arguments
c
c 0.4. ==> variables locales
c
      integer modhom
      integer lnomfi, lang, ulsort, codret, codre0
      integer guimp, gmimp, raison
c
      character*200 nomfic
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
#include "hoconf.h"
#include "langue.h"
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
#include "impr03.h"
c
      lang = langue
      nomfic = nfconf
      lnomfi = lfconf
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Appel de HOINIT par ', nompro
#endif
      call hoinit ( nomfic, lnomfi, lang, codret )
c
      call utulls ( ulsort, codre0 )
c
c====
c 2. lectures
c    modhom est, en sortie, le mode d'utilisation de HOMARD :
c    1 : adaptation standard
c    2 : information sur un maillage
c    3 : modification d'un maillage, sans adaptation
c    4 : conversion de solution
c    5 : mise a jour des coordonnees apres un suivi de frontiere externe
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOLECT', nompro
#endif
      call holect ( modhom, codret )
c
c====
c 3. Mode : HOMARD pur
c====
c
      if ( modhom.eq.1 ) then
c
c 3.1. ==> conversions avant adaptation et ecritures
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAVCV', nompro
#endif
      call hoavcv ( codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAVEC', nompro
#endif
      call hoavec ( codret )
c
c 3.2. ==> attribution des decisions aux faces et aux aretes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HODECI', nompro
#endif
      call hodeci ( codret )
c
c 3.3. ==> creation du nouveau maillage
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOCRMA', nompro
#endif
      call hocrma ( codret )
c
c 3.4. ==> suivi de frontiere (eventuellement)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOSUFR', nompro
#endif
      call hosufr ( codret )
c
c 3.5. ==> conversions apres adaptation
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAPCV', nompro
#endif
      call hoapcv ( codret )
c
c 3.6. ==> informations complementaires
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOINCO', nompro
#endif
      call hoinco ( codret )
c
c 3.7. ==> ecritures
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAPEC', nompro
#endif
      call hoapec ( codret )
c
c 3.8. ==> creation de maillage et solution annexes (eventuellement)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOCMSA', nompro
#endif
      call hocmsa ( codret )
c
c====
c 4. Mode : information
c====
c
      elseif ( modhom.eq.2 ) then
c
c 4.1. ==> conversions
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INCONV', nompro
#endif
      call inconv ( codret )
c
c 4.2. ==> informations
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ININFM', nompro
#endif
      call ininfm ( codret )
c
c 4.3. ==> questions/reponses
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INQURE', nompro
#endif
      call inqure ( codret )
c
c====
c 5. Mode : modification de maillage
c====
c
      elseif ( modhom.eq.3 ) then
c
c 5.1. ==> conversions initiales et ecritures
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAVCV', nompro
#endif
      call hoavcv ( codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAVEC', nompro
#endif
      call hoavec ( codret )
c
c 5.2. ==> modification
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMODI', nompro
#endif
      call mmmodi ( codret )
c
c 5.3. ==> conversions apres modification
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAPCV', nompro
#endif
      call hoapcv ( codret )
c
c 5.4. ==> informations complementaires
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOINCO', nompro
#endif
      call hoinco ( codret )
c
c 5.5. ==> ecritures
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAPEC', nompro
#endif
      call hoapec ( codret )
c
c====
c 6. Mode : conversion de la solution
c====
c
      elseif ( modhom.eq.4 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAPCV', nompro
#endif
      call hoapcv ( codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAPEC', nompro
#endif
      call hoapec ( codret )
c
c====
c 7. Mode : mise a jour des coordonnees
c====
c
      elseif ( modhom.eq.5 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOMAJC', nompro
#endif
      call homajc ( codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAVEC', nompro
#endif
      call hoavec ( codret )
c
c====
c 8. Mode : erreur
c====
c
      else

      codret = 7
c
      endif
c
c====
c 9. la fin
c     Si le code de retour est :
c     . 0 : tout va bien
c     . un multiple de 2 : probleme dans les objets GM
c     . un multiple de 3 : probleme dans les fichiers
c     . 5 : deux appels a des programmes d'initialisations
c     . 7 : mode inconnu
c===
c
      call utulls ( ulsort, codre0 )
c
      guimp = 0
      gmimp = 0
c
      if ( codret.eq.0 ) then
c
        raison = 0
c
      else
c
        raison = 1
        if ( mod(codret,2).eq.0 ) then
          gmimp = 1
        endif
        if ( mod(codret,3).eq.0 ) then
          guimp = 1
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOSTOP', nompro
#endif
      call hostop ( ulsort, guimp, gmimp, raison)
c
      end
