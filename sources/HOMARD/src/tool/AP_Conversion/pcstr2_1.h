c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .       .      ===>       .   .   .
c              .         .               .    .    .
c             .           .             .     .     .
c            .             .           .      .      .
c           .................         .................
c
c         Pour un decoupage selon l'arete numero 1 :
c
          elseif ( etanp1.eq.1 ) then          
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', 'pcstr2_1 etanp1=1'
#endif
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
c
            do 2221 , nrofon = 1 , nbfonc
c
c           Pour le fils aine :
c
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prtrcn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prtrcn)
c
              vafott(nrofon,q4,f1cp) =
     >       -unshu*(vafoen(nrofon,q2,prtrcn)+vafoen(nrofon,q3,prtrcn))+
     >        unsde*(vafoen(nrofon,q4,prtrcn)+vafoen(nrofon,q6,prtrcn))+
     >         unsqu*vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q5,f1cp) =
     >       -unshu*vafoen(nrofon,q2,prtrcn)+
     >        trshu*vafoen(nrofon,q3,prtrcn)+
     >        trsqu*vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q6,f1cp) = vafoen(nrofon,q6,prtrcn)
c
c           Pour le triangle fils NF+1 :
c
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prtrcn)
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prtrcn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q4,f2cp) = vafoen(nrofon,q4,prtrcn)
c
              vafott(nrofon,q5,f2cp) =
     >        trshu*vafoen(nrofon,q2,prtrcn)-
     >        unshu*vafoen(nrofon,q3,prtrcn)+
     >        trsqu*vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q6,f2cp) = vafott(nrofon,q4,f1cp)
c
 2221       continue
c
c         Pour un decoupage selon l'arete numero 2 :
c
          elseif ( etanp1.eq.2 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', 'pcstr2_1 etanp1=2'
#endif
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
c
            do 2222 , nrofon = 1 , nbfonc
c
c           Pour le fils aine :
c
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q6,prtrcn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prtrcn)
c
              vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prtrcn)
c
              vafott(nrofon,q4,f1cp) =
     >       -unshu*(vafoen(nrofon,q1,prtrcn)+vafoen(nrofon,q3,prtrcn))+
     >        unsde*(vafoen(nrofon,q4,prtrcn)+vafoen(nrofon,q5,prtrcn))+
     >         unsqu*vafoen(nrofon,q6,prtrcn)
c
              vafott(nrofon,q5,f1cp) = vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q6,f1cp) =
     >       -unshu*vafoen(nrofon,q1,prtrcn)+
     >        trshu*vafoen(nrofon,q3,prtrcn)+
     >        trsqu*vafoen(nrofon,q6,prtrcn)
c
c           Pour le triangle fils NF+1 :
c
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prtrcn)
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prtrcn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q6,prtrcn)
c
              vafott(nrofon,q4,f2cp) = vafoen(nrofon,q4,prtrcn)
c
              vafott(nrofon,q5,f2cp) = vafott(nrofon,q4,f1cp)
c
              vafott(nrofon,q6,f2cp) =
     >        trshu*vafoen(nrofon,q1,prtrcn)-
     >        unshu*vafoen(nrofon,q3,prtrcn)+
     >        trsqu*vafoen(nrofon,q6,prtrcn)
c
 2222       continue
c
c         Pour un decoupage selon l'arete numero 3 :
c
          elseif ( etanp1.eq.3 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', 'pcstr2_1 etanp1=3'
#endif
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
c
            do 2223 , nrofon = 1 , nbfonc
c
c           Pour le fils aine :
c
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q4,prtrcn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prtrcn)
c
              vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prtrcn)
c
              vafott(nrofon,q4,f1cp) =
     >       -unshu*vafoen(nrofon,q1,prtrcn)+
     >        trshu*vafoen(nrofon,q2,prtrcn)+
     >        trsqu*vafoen(nrofon,q4,prtrcn)
c
              vafott(nrofon,q5,f1cp) = vafoen(nrofon,q5,prtrcn)
c
              vafott(nrofon,q6,f1cp) =
     >       -unshu*(vafoen(nrofon,q1,prtrcn)+vafoen(nrofon,q2,prtrcn))+
     >        unsde*(vafoen(nrofon,q5,prtrcn)+vafoen(nrofon,q6,prtrcn))+
     >         unsqu*vafoen(nrofon,q4,prtrcn)
c
c           Pour le triangle fils NF+1 :
c
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prtrcn)
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q4,prtrcn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q3,prtrcn)
c
              vafott(nrofon,q4,f2cp) =
     >        trshu*vafoen(nrofon,q1,prtrcn)-
     >        unshu*vafoen(nrofon,q2,prtrcn)+
     >        trsqu*vafoen(nrofon,q4,prtrcn)
c
              vafott(nrofon,q5,f2cp) = vafott(nrofon,q6,f1cp)
c
              vafott(nrofon,q6,f2cp) = vafoen(nrofon,q6,prtrcn)
c
 2223       continue
