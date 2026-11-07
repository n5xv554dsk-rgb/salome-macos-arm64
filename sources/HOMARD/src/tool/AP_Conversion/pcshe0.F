      subroutine pcshe0 ( nbfonc, typint, deraff,
     >                    prfcan, prfcap,
     >                    coonoe,
     >                    somare,
     >                    aretri,
     >                    arequa,
     >                    tritet, cotrte, aretet,
     >                    quahex, coquhe, arehex,
     >                    facpyr, cofapy, arepyr,
     >                    hethex, anchex, filhex, fhpyte,
     >                    nbanhe, anfihe, anpthe,
     >                    nheeca, nhesca,
     >                    nteeca, ntesca,
     >                    npyeca, npysca,
     >                    vafoen, vafott,
     >                    vateen, vatett,
     >                    prften, prftep,
     >                    vapyen, vapytt,
     >                    prfpyn, prfpyp,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c                       HExaedres - solution P0
c                       --                    -
c remarque : pcshe0 et pcspe0 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . typint . e   .   1    . type d'interpolation                       .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  elements : 0 si intensif, sans orientation.
c .        .     .        .             1 si extensif, sans orientation.
c .        .     .        .             2 si intensif, avec orientation.
c .        .     .        .             3 si extensif, avec orientation.
c .        .     .        .  noeuds : 1 si degre 1                     .
c .        .     .        .           2 si degre 2                     .
c .        .     .        .           3 si iso-P2                      .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . hethex . e   . nbheto . historique de l'etat des hexaedres        .
c . filhex . e   . nbheto . premier fils des hexaedres                .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . nbanhe . e   .   1    . nombre de hexaedres decoupes par          .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfihe . e   . nbanhe . tableau filhex du maillage de l'iteration n.
c . anpthe . e   .  2**   . tableau fhpyte du maillage de l'iteration n.
c . nheeca . e   .    *   . numero des hexaedres dans le calcul entree .
c . nhesca . e   . rsheto . numero des hexaedres dans le calcul sortie .
c . nteeca . e   .    *   . numero des tetraedres dans le calcul entree.
c . ntesca . e   . rsteto . numero des tetraedres dans le calcul sortie.
c . npyeca . e   .    *   . numero des pyramides dans le calcul entree .
c . npysca . e   . rspyto . numero des pyramides dans le calcul sortie .
c . vafoen .   e . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
c . vateen . e   . nbfonc*. variables en entree de l'adaptation pour   .
c .        .     .    *   . les tetraedres                             .
c . vatett .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les tetraedres                             .
c . prften . es  .   *    . En numero du calcul a l'iteration n   :    .
c .        .     .        . 0 : le tetraedre est absent du profil      .
c .        .     .        . 1 : le tetraedre est present dans le profil.
c . prftep . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : le tetraedre est absent du profil      .
c .        .     .        . 1 : le tetraedre est present dans le profil.
c . vapyen . e   . nbfonc*. variables en entree de l'adaptation pour   .
c .        .     .    *   . les pyramides                              .
c . vapytt .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les pyramides                              .
c . prfpyn . es  .   *    . En numero du calcul a l'iteration n   :    .
c .        .     .        . 0 : la pyramide est absente du profil      .
c .        .     .        . 1 : la pyramide est presente dans le profil.
c . prfpyp . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : la pyramide est absente du profil      .
c .        .     .        . 1 : la pyramide est presente dans le profil
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      character*6 nompro
      parameter ( nompro = 'PCSHE0' )
c
#include "nblang.h"
#include "fracti.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer typint
      integer prfcan(*), prfcap(*)
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      integer hethex(nbheto), anchex(*)
      integer filhex(nbheto), fhpyte(2,nbheco)
      integer nbanhe, anfihe(nbanhe), anpthe(2,*)
      integer nheeca(reheto), nhesca(rsheto)
      integer nteeca(reteto), ntesca(rsteto)
      integer npyeca(repyto), npysca(rspyto)
      integer prften(*), prftep(*)
      integer prfpyn(*), prfpyp(*)
c
      double precision coonoe(nbnoto,sdim)
      double precision vafoen(nbfonc,*)
      double precision vafott(nbfonc,*)
      double precision vateen(nbfonc,*)
      double precision vatett(nbfonc,*)
      double precision vapyen(nbfonc,*)
      double precision vapytt(nbfonc,*)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
c     hehn   = HExaedre courant en numerotation Homard a l'it. N
c     hehnp1 = HExaedre courant en numerotation Homard a l'it. N+1
c
      integer hehn, hehnp1
c
c     etan   = ETAt de l'hexaedre a l'iteration N
c     etanp1 = ETAt de l'hexaedre a l'iteration N+1
c
      integer etan, etanp1
c
      integer nfhexp, nfpyrp, nftetp
      integer ficp(3,18)
      integer nfhexn, nfpyrn, nftetn
      integer ficn(3,18)
c
      double precision propor(18)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. on boucle sur tous les hexaedres du maillage HOMARD n+1
c    on trie en fonction de l'etat de l'hexaedre dans le maillage n
c    remarque : on a scinde en plusieurs programmes pour pouvoir passer
c    les options de compilation optimisees.
c====
c
      if ( nbfonc.ne.0 ) then
c
      do 20 , iaux = 1 , nbheto
c
c 2.1. ==> caracteristiques de l'hexaedre :
c
        if ( codret.eq.0 ) then
c
c 2.1.1. ==> son numero homard dans le maillage precedent
c
        hehnp1 = iaux
        if ( deraff ) then
          hehn = anchex(hehnp1)
        else
          hehn = hehnp1
        endif
c
c 2.1.2. ==> l'historique de son etat
c          On rappelle que l'etat vaut :
c      etat = 0 : le hexaedre est actif.
c      etat = 8 : l'hexaedre est coupe en 8.
c      etat >= 11 : l'hexaedre est coupe par conformite
c
        etanp1 = mod(hethex(hehnp1),1000)
        etan   = (hethex(hehnp1)-etanp1) / 1000
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '=========================================='
        write (ulsort,90002)  mess14(langue,1,6), hehnp1
        write (ulsort,90002) '. hehn   =', hehn
        write (ulsort,90002) '. etan   =', etan
        write (ulsort,90002) '. etanp1 =', etanp1
#endif
c
c 2.1.3. ==> prealables a l'iteration n
c
        if ( etan.ne.5 .and. etan.ne.9 ) then
c
c 2.1.3.1. ==> numerotation des fils
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEHY n', nompro
#endif
          call pcsehy ( nfhexn, nfpyrn, nftetn, ficn,
     >                  hehn, etan,
     >                  anfihe, anpthe,
     >                  nheeca, nteeca, npyeca,
     >                  ulsort, langue, codret )
c
        endif
c
c 2.1.4. ==> prealables a l'iteration n+1
c
        if ( etanp1.ne.5 .and. etanp1.ne.9 ) then
c
c 2.1.4.1. ==> numerotation des fils
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEHY n+1', nompro
#endif
          call pcsehy ( nfhexp, nfpyrp, nftetp, ficp,
     >                  hehnp1, etanp1,
     >                  filhex, fhpyte,
     >                  nhesca, ntesca, npysca,
     >                  ulsort, langue, codret )
c
c 2.1.4.2. ==> en mode extensif, calcul des proportions
c
          if ( typint.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEHZ', nompro
#endif
            call pcsehz ( propor,
     >                    hehnp1, etanp1,
     >                    coonoe, somare, aretri, arequa,
     >                    tritet, cotrte, aretet,
     >                    quahex, coquhe, arehex,
     >                    facpyr, cofapy, arepyr,
     >                    filhex, fhpyte,
     >                    ulsort, langue, codret )
c
          endif
c
        endif
c
        endif
c
c 2.2. ==> Examen des differents etats
c
        if ( codret.eq.0 ) then
c
c=======================================================================
c 2.2.1. ==> etan = 0 : l'hexaedre etait actif
c=======================================================================
c
        if ( etan.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEH0', nompro
#endif
c
          call pcseh0 ( etan, etanp1, hehn, hehnp1, typint,
     >                  prfcan, prfcap,
     >                  nfhexp, nfpyrp, nftetp, ficp, propor,
     >                  nheeca, nhesca,
     >                  nbfonc, vafoen, vafott,
     >                  vatett, prftep,
     >                  vapytt, prfpyp,
     >                  ulsort, langue, codret )
cgn          write (ulsort,*) 'retour de PCSEH0'
c
c=======================================================================
c 2.2.2. ==> l'hexaedre etait coupe en conformite
c=======================================================================
c
      elseif ( etan.ge.11 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEH1', nompro
#endif
c
          call pcseh1 ( etan, etanp1, hehn, hehnp1, typint,
     >                  prfcap,
     >                  nfpyrn, nftetn, ficn,
     >                  nfpyrp, nftetp, ficp, propor,
     >                  coonoe,
     >                  somare,
     >                  aretri,
     >                  arequa,
     >                  tritet, cotrte, aretet,
     >                  quahex, coquhe, arehex,
     >                  facpyr, cofapy, arepyr,
     >                  hethex, filhex, fhpyte,
     >                          nhesca,
     >                  ntesca,
     >                  npysca,
     >                  nbfonc, vafott,
     >                  vateen, vatett,
     >                  prften, prftep,
     >                  vapyen, vapytt,
     >                  prfpyn, prfpyp,
     >                  ulsort, langue, codret )
c
c=======================================================================
c 2.2.3. ==> etan = 8 : le hexaedre etait coupe en 8 hexaedres
c=======================================================================
c
        elseif ( etan.eq.8 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEH8', nompro
#endif
c
          call pcseh8 ( etanp1, hehnp1, typint,
     >                  prfcan, prfcap,
     >                  ficn,
     >                  nfpyrp, nftetp, ficp, propor,
     >                  nhesca,
     >                  nbfonc, vafoen, vafott,
     >                          vatett,
     >                          prftep,
     >                          vapytt,
     >                          prfpyp,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
   20 continue
c
      endif
c
c====
c 3. la fin
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
