      subroutine gmcpoj (nom1,nom2,codret)
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
c     copier l'objet 'nom1' a la place de l'objet 'nom2'
c     'nom1' et 'nom2' doivent etre de meme type
c     s'ils sont de type structure : on copie les attributs
c     s'ils sont de type simple    : on copie le contenu
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nom1   . e   . char(*). nom etendu source                          .
c . nom2   . e   .char(*) . nom etendu destinataire                    .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
c .        .     .        . -1 : 'nom1' invalide ou non alloue         .
c .        .     .        . -2 : objets destinataire et source ne sont .
c .        .     .        .      pas de meme type                      .
c .        .     .        . -3 : nom etendu invalide                   .
c .        .     .        . -4 : premier caractere interdit            .
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
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtors.h"
#include "gmtoas.h"
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "gmimpr.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      integer       codret
      character*(*) nom1,nom2
c
c 0.4. ==> variables locales
c
      logical detlg0
c
      character*8   obrep1,obter1,chter1
      character*8   obrep2,obter2,chter2
      character*8   letype
      character*8   typ1
      character*40  mess
c
      integer ide1,ioa1,ity1,ide2,ioa2,ity2
      integer ial2,irt2,iob1,ity,nba,iob2,ia,iat1,iat2
      integer long1,iad1,long2,iad2,il,llres
      integer nrotab
c
c 1.  decodage du nom etendu 'nom1'
c
      codret = 0
      call gbdnoe(nom1,obrep1,obter1,chter1,ide1)
c
      if ((ide1.lt.0).or.(ide1.eq.1).or.(ide1.eq.2)) then
c
c        'nom1' invalide ou non alloue
c
        codret = -1
        goto 9999
c
      else
c
c        ide1 = 0 ou 3
c
        call gbobal(obter1,ity1,ioa1)
c
        if (ioa1.eq.0) then
          codret = -1
          goto 9999
        endif
c
      endif
c
c 2.  copie de obter1
c
      if (ioa1.eq.1) then
c
c 2.1.   obter1 est un objet structure (alloue)
c
c        decodage de nom2
c
        typ1 = nomtyp(ity1)
        call gbdnoe(nom2,obrep2,obter2,chter2,ide2)
        if (ide2.lt.0) then
          codret = -3
          goto 9999
        else if (ide2.eq.0) then
          call gbobal(obter2,ity2,ioa2)
          if (ioa2.eq.0) then
            call gmaloj(obter2,typ1,0,ial2,irt2)
            if (irt2.eq.-3) then
              codret = -2
              goto 9999
            endif
            if (irt2.eq.-7) then
              codret = -4
              goto 9999
            endif
            if ((irt2.ne.0).and.(irt2.ne.-5)) then
              mess = ' gmcpoj -> gmaloj -> codret : '
              write(mess(29:30),'(i2)') irt2
              write(ulsort,*) mess
              call ugstop('gmcpoj',ulsort,1,1,1)
            endif
            ity2 = ity1
          endif
        else
          if (ide2.ne.3) then
            call gmaloj(nom2,typ1,0,ial2,irt2)
            if (irt2.eq.-3) then
              codret = -2
              goto 9999
            endif
            if (irt2.eq.-7) then
              codret = -4
              goto 9999
            endif
            if ((irt2.ne.0).and.(irt2.ne.-5)) then
              mess = ' gmcpoj -> gmaloj -> codret : '
              write(mess(29:30),'(i2)') irt2
              write(ulsort,*) mess
              call ugstop('gmcpoj',ulsort,1,1,1)
            endif
            ity2 = ity1
          endif
          call gbdnoe(nom2,obrep2,obter2,chter2,ide2)
          call gbobal(obter2,ity2,ioa2)
        endif
c
        if (ity1.ne.ity2) then
          codret = -2
          goto 9999
        endif
c
        do 10 , iob1 = 1,iptobj-1
          if (nomobj(iob1).eq.obter1) then
            goto 11
          endif
   10   continue
        codret = -1
        goto 9999
c
   11   continue
        ity = typobj(iob1)
        nba = nbratt(ity)
c
        do 12 , iob2 = 1,iptobj-1
          if (nomobj(iob2).eq.obter2) then
            goto 13
          endif
   12   continue
        codret = -3
        goto 9999
c
   13   continue
        do 14 , ia = 1,nba
          iat1 = adrdsa(iob1)+ia-1
          iat2 = adrdsa(iob2)+ia-1
          valatt(iat2) = valatt(iat1)
   14   continue
c
      else if (ioa1.eq.2) then
c
c 2.2.   obter1 est un objet simple (alloue)
c
        call gbcara(obter1,nrotab,iad1,long1,letype)
c
        typ1 = nomtyb(-ity1)
c
c        decodage de nom2
c
        call gbdnoe(nom2,obrep2,obter2,chter2,ide2)
        if (ide2.lt.0) then
          codret = -3
          goto 9999
        else if (ide2.eq.0) then
          call gbobal(obter2,ity2,ioa2)
          if (ioa2.eq.0) then
            call gmaloj(obter2,typ1,long1,ial2,irt2)
            if (irt2.eq.-3) then
              codret = -2
              goto 9999
            endif
            if (irt2.eq.-7) then
              codret = -4
              goto 9999
            endif
            if ((irt2.ne.0).and.(irt2.ne.-5)) then
              mess = ' gmcpoj -> gmaloj -> codret : '
              write(mess(29:30),'(i2)') irt2
              write(ulsort,*) mess
              call ugstop('gmcpoj',ulsort,1,1,1)
            endif
            ity2 = ity1
          endif
        else
          if (ide2.ne.3) then
            call gmaloj(nom2,typ1,long1,ial2,irt2)
            if (irt2.eq.-3) then
              codret = -2
              goto 9999
            endif
            if (irt2.eq.-7) then
              codret = -4
              goto 9999
            endif
            if ((irt2.ne.0).and.(irt2.ne.-5)) then
              mess = ' gmcpoj -> gmaloj -> codret : '
              write(mess(29:30),'(i2)') irt2
              write(ulsort,*) mess
              call ugstop('gmcpoj',ulsort,1,1,1)
            endif
            ity2 = ity1
          endif
          call gbdnoe(nom2,obrep2,obter2,chter2,ide2)
          call gbobal(obter2,ity2,ioa2)
        endif
c
        if (ity1.ne.ity2) then
           codret = -2
           goto 9999
        endif
c
        call gbcara(obter2,nrotab,iad2,long2,letype)
c
        if (long1.gt.long2) then
c
          call gmdesa(obter2)
          if ( coergm.ne.0 ) then
            codret = coergm
            goto 9999
          endif
c
          if (ity1.eq.-1) then
            call gmaloi(obter2,iad2,long1)
          else if (ity1.eq.-2) then
            call gmalor(obter2,iad2,long1)
          else if (ity1.eq.-3) then
            call gmalos(obter2,iad2,long1)
          endif
        endif
c
        if (typ1.eq.nomtyb(1)) then
          do 21 , il = 1,long1
            imem(iad2+il-1) = imem(iad1+il-1)
   21     continue
        else if (typ1.eq.nomtyb(2)) then
          do 22 , il = 1,long1
            rmem(iad2+il-1) = rmem(iad1+il-1)
   22     continue
        else if (typ1.eq.nomtyb(3)) then
          do 23 , il = 1,long1
            smem(iad2+il-1) = smem(iad1+il-1)
   23     continue
        endif
c
        if (long1.lt.long2) then
          llres = long2-long1
          detlg0 = .false.
          if (ity1.eq.-1) then
            call gmdesi(obter2,llres,detlg0)
          else if (ity1.eq.-2) then
            call gmdesr(obter2,llres,detlg0)
          else if (ity1.eq.-3) then
            call gmdess(obter2,llres,detlg0)
          endif
        endif
      endif
c
 9999 continue
c
      end
