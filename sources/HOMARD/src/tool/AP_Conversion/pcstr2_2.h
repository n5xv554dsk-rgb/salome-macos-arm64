c                   .                         .
c                  . .                       . .
c                 .   .                     .   .
c                .     .                   .     .
c               .       .      ===>       .........
c              .         .               . .     . .
c             .           .             .   .   .   .
c            .             .           .     . .     .
c           .................         .................
c
c
          elseif ( etanp1.eq.4 .or.
     >             etanp1.eq.6 .or. etanp1.eq.7 .or. etanp1.eq.8 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', 'pcstr2_2'
      write (ulsort,*) 'avec etanp1=',etanp1
#endif
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            f3cp = ntrsca(f1hp+2)
            f4cp = ntrsca(f1hp+3)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            prfcap(f3cp) = 1
            prfcap(f4cp) = 1
c
            do 223 , nrofon = 1 , nbfonc
c
c           Pour le fils aine (centre)
c
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q6,prtrcn)
c     
              vafott(nrofon,q3,f1cp) = vafoen(nrofon,q4,prtrcn)
c     
              vafott(nrofon,q4,f1cp) =
     >       -unshu*(vafoen(nrofon,q1,prtrcn)+vafoen(nrofon,q2,prtrcn))+
     >        unsde*(vafoen(nrofon,q5,prtrcn)+vafoen(nrofon,q6,prtrcn))+
     >         unsqu*vafoen(nrofon,q4,prtrcn)
c     
              vafott(nrofon,q5,f1cp) =
     >       -unshu*(vafoen(nrofon,q2,prtrcn)+vafoen(nrofon,q3,prtrcn))+
     >        unsde*(vafoen(nrofon,q4,prtrcn)+vafoen(nrofon,q6,prtrcn))+
     >         unsqu*vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q6,f1cp) =
     >       -unshu*(vafoen(nrofon,q1,prtrcn)+vafoen(nrofon,q3,prtrcn))+
     >        unsde*(vafoen(nrofon,q4,prtrcn)+vafoen(nrofon,q5,prtrcn))+
     >         unsqu*vafoen(nrofon,q6,prtrcn)
c
cgn          print 1788,f1cp,
cgn     >     (vafott(nrofon,iaux,f1cp), iaux = 1 , nbnoel)
c
c           Pour le triangle fils f1hp+1
c
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prtrcn)
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q4,prtrcn)
c     
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q6,prtrcn)
c     
              vafott(nrofon,q4,f2cp) =
     >        trshu*vafoen(nrofon,q1,prtrcn)-
     >        unshu*vafoen(nrofon,q2,prtrcn)+
     >        trsqu*vafoen(nrofon,q4,prtrcn)
c     
              vafott(nrofon,q5,f2cp) = vafott(nrofon,q5,f1cp)
c
              vafott(nrofon,q6,f2cp) =
     >        trshu*vafoen(nrofon,q1,prtrcn)-
     >        unshu*vafoen(nrofon,q3,prtrcn)+
     >        trsqu*vafoen(nrofon,q6,prtrcn)
cgn          print 1788,f2cp,
cgn     >     (vafott(nrofon,iaux,f2cp), iaux = 1 , nbnoel)
c
c           Pour le triangle fils f1hp+2
c
              vafott(nrofon,q1,f3cp) = vafoen(nrofon,q4,prtrcn)
c
              vafott(nrofon,q2,f3cp) = vafoen(nrofon,q2,prtrcn)
c     
              vafott(nrofon,q3,f3cp) = vafoen(nrofon,q5,prtrcn)
c     
              vafott(nrofon,q4,f3cp) =
     >       -unshu*vafoen(nrofon,q1,prtrcn)+
     >        trshu*vafoen(nrofon,q2,prtrcn)+
     >        trsqu*vafoen(nrofon,q4,prtrcn)
c     
              vafott(nrofon,q5,f3cp) =
     >        trshu*vafoen(nrofon,q2,prtrcn)-
     >        unshu*vafoen(nrofon,q3,prtrcn)+
     >        trsqu*vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q6,f3cp) = vafott(nrofon,q6,f1cp)
cgn          print 1788,f3cp,
cgn     >     (vafott(nrofon,iaux,f3cp), iaux = 1 , nbnoel)
c
c           Pour le triangle fils f1hp+3
c
              vafott(nrofon,q1,f4cp) = vafoen(nrofon,q6,prtrcn)
c
              vafott(nrofon,q2,f4cp) = vafoen(nrofon,q5,prtrcn)
c     
              vafott(nrofon,q3,f4cp) = vafoen(nrofon,q3,prtrcn)
c     
              vafott(nrofon,q4,f4cp) = vafott(nrofon,q4,f1cp)
c     
              vafott(nrofon,q5,f4cp) =
     >       -unshu*vafoen(nrofon,q2,prtrcn)+
     >        trshu*vafoen(nrofon,q3,prtrcn)+
     >        trsqu*vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q6,f4cp) =
     >       -unshu*vafoen(nrofon,q1,prtrcn)+
     >        trshu*vafoen(nrofon,q3,prtrcn)+
     >        trsqu*vafoen(nrofon,q6,prtrcn)
cgn          print 1788,f4cp,
cgn     >     (vafott(nrofon,iaux,f4cp), iaux = 1 , nbnoel)
c
  223       continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', 'pcstr2_2'
#endif
