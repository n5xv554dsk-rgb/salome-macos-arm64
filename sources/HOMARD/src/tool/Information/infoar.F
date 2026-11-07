      subroutine infoar ( choix,  larete,
     >                    somare, posifa, facare,
     >                    hetare, filare, merare, np2are,
     >                    famare, cfaare,
     >                    nareho, nareca, narecs,
     >                    arehom,
     >                    coonoe,
     >                    hettri, hetqua,
     >                    hettet, hetpyr, hethex, hetpen,
     >                    nbtear, pttear, tatear,
     >                    nbhear, pthear, tahear,
     >                    nbpyar, ptpyar, tapyar,
     >                    nbpear, ptpear, tapear,
     >                    nbpafo, nopafo,
     >                    ulsost,
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
c   INFOrmation : ARete
c   ----          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .  ch2   . choix                                      .
c . larete . e   .   1    . numero de l'arete a analyser               .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . fille ainee de chaque arete                .
c . merare . e   . nbarto . mere de chaque arete                       .
c . np2are . e   . nbarto . numero du noeud p2 milieu de l'arete       .
c . famare . e   . nbarto . famille des aretes                         .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nareho . e   . rearac . numero des aretes dans HOMARD              .
c . nareca . e   .   *    . nro des aretes du code de calcul           .
c . narecs . e   .   *    . nro des aretes du calcul pour la solution  .
c . arehom . e   . nbarto . liste etendue des correspondances          .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . nbtear . e   .    1   . nombre de tetraedres voisins d'aretes      .
c . pttear . e   .0:nbarto. nombre de tetraedres voisins par aretes    .
c . tatear . e   . nbtear . tetraedres voisins par aretes              .
c . nbhear . e   .    1   . nombre d'hexaedres voisins d'aretes        .
c . pthear . e   .0:nbarto. nombre d'hexaedres voisins par aretes      .
c . tahear . e   . nbhear . hexaedres voisins par aretes               .
c . nbpyar . e   .    1   . nombre de pyramides voisines d'aretes      .
c . ptpyar . e   .0:nbarto. nombre de pyramides voisines par aretes    .
c . tapyar . e   . nbpyar . pyramides voisines par aretes              .
c . nbpear . e   .    1   . nombre de pentaedres voisins d'aretes      .
c . ptpear . e   .0:nbarto. nombre de pentaedres voisins par aretes    .
c . tapear . e   . nbpear . pentaedres voisins par aretes              .
c . nbpafo . e   .   1    . nombre de paquets de fonctions             .
c . nopafo . e   . nbpafo . nom des objets qui contiennent la          .
c .        .     .        . description de chaque paquet de fonctions  .
c . textar . e   .  ch40  . commentaires sur l'etat des aretes         .
c . texttr . e   .  ch40  . commentaires sur l'etat des triangles      .
c . textte . e   .  ch40  . commentaires sur l'etat des tetraedres     .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
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
      parameter ( nompro = 'INFOAR' )
c
      integer langst
      parameter ( langst = 1 )
c
#include "nblang.h"
#include "consts.h"
#include "tbdim0.h"
#include "meddc0.h"
#include "cofaar.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "inmess.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nomber.h"
#include "envca1.h"
#include "envada.h"
c
c 0.3. ==> arguments
c
      character*2 choix
c
      integer larete
c
      integer somare(2,nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hetare(nbarto), filare(nbarto), merare(nbarto)
      integer np2are(nbarto)
      integer cfaare(nctfar,nbfare), famare(nbarto)
      integer nareho(rearac), nareca(*), narecs(*)
      integer arehom(nbarto)
      integer hettri(nbtrto)
      integer hetqua(nbquto)
      integer hettet(nbteto)
      integer hetpyr(nbpyto)
      integer hethex(nbheto)
      integer hetpen(nbpeto)
c
      integer nbtear, pttear(0:nbarto), tatear(nbtear)
      integer nbhear, pthear(0:nbarto), tahear(nbhear)
      integer nbpyar, ptpyar(0:nbarto), tapyar(nbpyar)
      integer nbpear, ptpear(0:nbarto), tapear(nbpear)
c
      integer nbpafo
c
      double precision coonoe(nbnoto,sdim)
c
      character*8 nopafo(*)
c
      integer ulsost
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer numcal
      integer ndeb, nfin, nbface
      integer etat00, etat01, orient
      integer sommde, sommfi, milieu
      integer laface, soeain
      integer uldeb, ulfin, ulpas, ulecr
c
      integer trav1a(tbdim)
c
      double precision daux, vn(3)
c
      character*40 taux40
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
#include "fracta.h"
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
#include "infoen.h"
#include "tbdim1.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      codret = 0
c
      uldeb = min(ulsost,ulsort)
      ulfin = max(ulsost,ulsort)
      ulpas = max ( 1 , ulfin-uldeb )
c
c====
c 2. numero de l'arete dans HOMARD
c====
c
      if ( choix.eq.'AR' ) then
        iaux = larete
        if ( larete.gt.0 .and. larete.le.rearac ) then
          larete = nareho(iaux)
        else
          larete = 0
        endif
      endif
c
c====
c 3. reponses
c====
c
      do 30 , ulecr = uldeb , ulfin, ulpas
c
      write (ulecr,40000)
c
c 3.1. ==> numero d'arete impossible
c
      if ( larete.le.0 .or. larete.gt.nbarto ) then
c
        if ( choix.eq.'AR' ) then
          write (ulecr,40010) iaux
        else
          write (ulecr,40020) larete
        endif
        write (ulecr,40031)
c
c 3.2. ==> numero d'arete correct
c
      else
c
        if ( rearac.ne.0 ) then
          numcal = nareca(larete)
          if ( numcal.ne.0 ) then
            write (ulecr,40020) larete
            write (ulecr,40010) numcal
          else
            write (ulecr,40020) larete
            write (ulecr,40041)
          endif
        else
          write (ulecr,40020) larete
          write (ulecr,40041)
        endif
c
c 3.2.1. ==> maillage initial ?
c
        if ( larete.le.nbarma) then
          write (ulecr,41000)
        endif
c
c 3.2.2. ==> caracteristiques
c
        write (ulecr,42000) famare(larete)
c
        if ( numcal.ne.0 ) then
c
          orient = cfaare(coorfa,famare(larete))
          if ( orient.gt.0 ) then
            write (ulecr,42020)
          elseif ( orient.lt.0 ) then
            write (ulecr,42030)
          endif
c
          iaux = cfaare(cosfli,famare(larete))
          if ( iaux.gt.0 ) then
            write (ulecr,42040) iaux
          endif
c
        endif
c
c 3.2.3. ==> les extremites
c
        sommde = somare(1,larete)
        sommfi = somare(2,larete)
        write (ulecr,43110) sommde, sommfi
        if ( degre.eq.2 ) then
          milieu = np2are(larete)
          write (ulecr,43120) milieu
        endif
c
c 3.2.4. ==> etat
c
        etat01 = mod(hetare(larete),10)
        etat00 = (hetare(larete)-etat01) / 10
c
        taux40 = textar(etat01)
        write (ulecr,44010)
        write (ulecr,40001) taux40
        if ( nbiter.ge.1 ) then
          taux40 = textar(etat00)
          write (ulecr,44020)
          write (ulecr,40001) taux40
        endif
c
c 3.2.5. ==> la parente
c
        if ( etat01.ne.0 ) then
          write (ulecr,45019)
          iaux = 1
          soeain = filare(larete)
          do 3251 , jaux = 0 , iaux
            kaux = soeain+jaux
            if ( rearac.ne.0 ) then
              if ( nareca(kaux).eq.0 ) then
                write (ulecr,45070) kaux
              else
                write (ulecr,45080) kaux, nareca(kaux)
              endif
            else
              write (ulecr,45070) kaux
            endif
 3251     continue
        endif
c
        if ( merare(larete).ne.0 ) then
          write (ulecr,45049) merare(larete)
          iaux = filare(merare(larete))
          if ( iaux.eq.larete ) then
            jaux = larete + 1
          else
            jaux = iaux
          endif
          write (ulecr,45059) jaux
        endif
c
c 3.2.6. ==> les faces
c
        nbface = 0
c
        ndeb = posifa(larete-1)+1
        nfin = posifa(larete)
        if ( nfin.lt.ndeb ) then
          write (ulecr,46010)
        else
          if ( nfin.eq.ndeb ) then
            write (ulecr,46020)
          else
            write (ulecr,46021)
          endif
          do 3261 , jaux = ndeb , nfin
            laface = facare(jaux)
            if ( laface.gt.0 ) then
              taux40 = texttr(mod(hettri(laface),10))
            else
              taux40 = textqu(mod(hetqua(-laface),100))
            endif
            write (ulecr,46040) laface, taux40
            nbface = nbface + 1
            iaux = nbface
#include "tbdim2.h"
            trav1a(iaux) = laface
 3261     continue
        endif
c
c 3.2.7. ==> les voisins volumiques
c
        if ( nbteto.ne.0 .or. nbheto.ne.0 .or.
     >       nbpyto.ne.0 .or. nbpeto.ne.0 ) then
c
          iaux = 10
          jaux = 1
          trav1a(1) = larete
          kaux = ulecr
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOVA', nompro
#endif
          call infova ( iaux, jaux, trav1a,
     >                  nbtear, pttear, tatear,
     >                  nbhear, pthear, tahear,
     >                  nbpyar, ptpyar, tapyar,
     >                  nbpear, ptpear, tapear,
     >                  hettet, hetpyr, hethex, hetpen,
     >                  kaux,
     >                  ulsort, langue, codret )
c
        endif
c
c 3.2.8. ==> les homologues
c
        if ( homolo.ne.0 ) then
c
          if ( arehom(larete).ne.0 ) then
            if ( arehom(larete).eq.larete ) then
              write (ulecr,48011)
            else
              if ( arehom(larete).ge.0 ) then
                iaux = 2
              else
                iaux = 1
              endif
              write (ulecr,48021) iaux, abs(arehom(larete))
            endif
          endif
c
        endif
c
c 3.2.9. ==> le centre de gravite
c
        do 329 , iaux = 1 , sdim
          vn(iaux) = unsde * ( coonoe(sommde,iaux) +
     >                         coonoe(sommfi,iaux) )
  329   continue
c
        if ( sdim.eq.1 ) then
          write (ulecr,49001) vn(1)
        elseif ( sdim.eq.2 ) then
          write (ulecr,49002) (vn(iaux), iaux = 1 , sdim)
        else
          write (ulecr,49003) (vn(iaux), iaux = 1 , sdim)
        endif
c
c 3.2.10. ==> la longueur
c
        if ( sdim.eq.1 ) then
c
          vn(1) = coonoe(sommfi,1) - coonoe(sommde,1)
          daux = abs ( vn(1) )
c
        elseif ( sdim.eq.2 ) then
c
          vn(1) = coonoe(sommfi,1) - coonoe(sommde,1)
          vn(2) = coonoe(sommfi,2) - coonoe(sommde,2)
          daux = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) )
c
        else
c
          vn(1) = coonoe(sommfi,1) - coonoe(sommde,1)
          vn(2) = coonoe(sommfi,2) - coonoe(sommde,2)
          vn(3) = coonoe(sommfi,3) - coonoe(sommde,3)
          daux = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
        endif
c
        write (ulecr,49010) daux
c
c 3.2.11. ==> les valeurs des fonctions
c
        if ( nbpafo.ne.0 .and. numcal.ne.0 ) then
c
          if ( degre.eq.1 ) then
            iaux = edseg2
          else
            iaux = edseg3
          endif
          jaux = narecs(numcal)
          kaux = ulecr
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOPF', nompro
#endif
          call infopf ( nbpafo, nopafo,
     >                  iaux, jaux,
     >                  kaux,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
      write (ulecr,40000)
c
   30 continue
c
c===
c 4. formats
c===
c
40020 format(
     >  '* Arete numero :',i10,   ' dans HOMARD                      *')
c
41000 format(
     >  '* . C''est une arete du maillage initial.                    ',
     >  '*')
c
42020 format(
     >  '*   Meme orientation que dans le maillage de calcul         *')
42030 format(
     >  '*   Orientation differente du maillage de calcul            *')
42040 format(
     >  '*   Elle appartient a la ligne-frontiere numero :',i7, '    *')
c
43110 format(
     >  '* . Elle va du noeud ',i10,   ' au noeud ',i10,   '         *')
43120 format(
     >  '*    Le noeud au milieu est ',i10,   '                      *')
c
46010 format(
     >  '* . Elle est isolee.                                        *')
46020 format(
     >  '* . Elle borde la face :                                    *')
46021 format(
     >  '* . Elle borde des faces :                                  *')
46040 format(
     >  '* ',i10,   ' : ',a40,                                 '     *')
c
c====
c 5. La fin
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
