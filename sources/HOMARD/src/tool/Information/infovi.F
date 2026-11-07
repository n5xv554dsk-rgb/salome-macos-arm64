      subroutine infovi ( typmes,
     >                    nbtevr, tatevr,
     >                    nbhevr, tahevr,
     >                    nbpyvr, tapyvr,
     >                    nbpevr, tapevr,
     >                    hettet, hetpyr, hethex, hetpen,
     >                    ulecr,
     >                    ulsort, langue, codret )
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
c   INFOrmation : Volumes voisins - Impression
c   ----          -                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typmes . e   .   1    . 10 : message pour les aretes               .
c .        .     .        . 20 : message pour les noeuds sommets       .
c .        .     .        . 30 : message pour les noeuds milieux       .
c . nbtevr . e   .    1   . nombre de tetraedres voisins d'aretes      .
c . tatevr . e   . nbtevr . tetraedres voisins par aretes              .
c . nbhevr . e   .    1   . nombre d'hexaedres voisins d'aretes        .
c . tahevr . e   . nbhevr . hexaedres voisins par aretes               .
c . nbpyvr . e   .    1   . nombre de pyramides voisines d'aretes      .
c . tapyvr . e   . nbpyvr . pyramides voisines par aretes              .
c . nbpevr . e   .    1   . nombre de pentaedres voisins d'aretes      .
c . tapevr . e   . nbpevr . pentaedres voisins par aretes              .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . ulecr  . e   .   1    . unite logique pour l'ecriture              .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . non nul : probleme                         .
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
      parameter ( nompro = 'INFOVI' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "inmess.h"
#include "impr02.h"
c
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "hexcf0.h"
#include "hexcf1.h"
c
c 0.3. ==> arguments
c
      integer typmes
      integer nbtevr, tatevr(nbtevr)
      integer nbhevr, tahevr(nbhevr)
      integer nbpyvr, tapyvr(nbpyvr)
      integer nbpevr, tapevr(nbpevr)
      integer hettet(nbteto)
      integer hetpyr(nbpyto)
      integer hethex(nbheto)
      integer hetpen(nbpeto)
c
      integer ulecr
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer etat, bindec
      integer letetr, lehexa, lapyra, lepent
      integer inditv (0:2,0:2,0:2,0:2)
c
      character*40 taux40
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c 1.1. ==> messages
c
#include "impr01.h"
#include "infoen.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
c 1.2. ==> indirections dans les messages
c
      inditv(1,0,0,0) = 1 + typmes
      inditv(2,0,0,0) = 2 + typmes
      inditv(0,1,0,0) = 3 + typmes
      inditv(0,2,0,0) = 4 + typmes
      inditv(0,0,1,0) = 5 + typmes
      inditv(0,0,2,0) = 6 + typmes
      inditv(0,0,0,1) = 7 + typmes
      inditv(0,0,0,2) = 8 + typmes
c
c====
c 2. tetraedres
c====
c
#ifdef _DEBUG_HOMARD_
        write (ulecr,90002) 'nbtevr', nbtevr
#endif
c
      if ( nbtevr.gt.0 ) then
c
        iaux = min(2,nbtevr)
        write (ulecr,40002) textvo(inditv(iaux,0,0,0))
c
        do 21 , iaux = 1 , nbtevr
          letetr = tatevr(iaux)
          etat = mod(hettet(letetr),100)
          taux40 = textte(etat)
          write (ulecr,46000) letetr, taux40
   21   continue
c
      endif
c
c====
c 3. hexaedres
c====
c
#ifdef _DEBUG_HOMARD_
        write (ulecr,90002) 'nbhevr', nbhevr
#endif
c
      if ( nbhevr.gt.0 ) then
c
        iaux = min(2,nbhevr)
        write (ulecr,40002) textvo(inditv(0,iaux,0,0))
c
        do 31 , iaux = 1 , nbhevr
          lehexa = tahevr(iaux)
          etat = mod(hethex(lehexa),1000)
          if ( etat.le.10 ) then
            taux40 = texthe(etat)
            write (ulecr,46000) lehexa, taux40
          else
            bindec = chbiet(etat)
            if ( etat.le.22 ) then
              write (ulecr,46031) lehexa, charde(bindec)(1:3)
            elseif ( ( etat.ge.285 ) .and. ( etat.le.290 ) ) then
              taux40 = texthe(etat-244)
              write (ulecr,46000) lehexa, taux40
            else
              write (ulecr,46030) lehexa, charde(bindec)(1:27)
            endif
          endif
   31   continue
c
      endif
c
c====
c 4. pyramides
c====
c
#ifdef _DEBUG_HOMARD_
        write (ulecr,90002) 'nbpyvr', nbpyvr
#endif
c
      if ( nbpyvr.gt.0 ) then
c
        iaux = min(2,nbpyvr)
        write (ulecr,40002) textvo(inditv(0,0,iaux,0))
c
        do 41 , iaux = 1 , nbpyvr
          lapyra = tapyvr(iaux)
          etat = mod(hetpyr(lapyra),100)
          taux40 = textpy(etat)
          write (ulecr,46000) lapyra, taux40
   41   continue
c
      endif
c
c====
c 5. pentaedres
c====
c
#ifdef _DEBUG_HOMARD_
        write (ulecr,90002) 'nbpevr', nbpevr
#endif
c
      if ( nbpevr.gt.0 ) then
c
        iaux = min(2,nbpevr)
        write (ulecr,40002) textvo(inditv(0,0,0,iaux))
c
        do 51 , iaux = 1 , nbpevr
          lepent = tapevr(iaux)
          etat = mod(hetpen(lepent),100)
          taux40 = textpe(etat)
          write (ulecr,46000) lepent, taux40
   51   continue
c
      endif
c
c====
c 6. La fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
