c           .................         .................
c           .               .         .      . .      .
c           .               .         .     .   .     .
c           .               .         .    .     .    .
c           .               .  ===>   .   .       .   .
c           .               .         .  .         .  .
c           .               .         . .           . .
c           .               .         ..             ..
c           .................         .................
c
c
            f1hp = -filqua(quhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            f3cp = ntrsca(f1hp+2)
            prftrp(f1cp) = 1
            prftrp(f2cp) = 1
            prftrp(f3cp) = 1
c
            q1t = 1
            q2t = 2
            q3t = 3
            q4t = 4
            q5t = 5
            q6t = 6

c         Pour un decoupage par l'arete numero 1 :

            if ( etanp1.eq.31 ) then
c
            do 2221 , nrofon = 1 , nbfonc
c
c           Pour le triangle NT1 :
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q4,prqucn)
c
              vatrtt(nrofon,q2t,f1cp) = vafoen(nrofon,q5,prqucn)
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q3,prqucn)
c
              vatrtt(nrofon,q4t,f1cp) =
     >       -trssz*
     >              (vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >               vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >        trshu*(vafoen(nrofon,q5,prqucn)+vafoen(nrofon,q7,prqucn))+
     >        unsqu*vafoen(nrofon,q6,prqucn)+
     >        trsqu*vafoen(nrofon,q8,prqucn)
c
              vatrtt(nrofon,q5t,f1cp) =
     >       -trssz*
     >              (vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >               vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >        trshu*(vafoen(nrofon,q5,prqucn)+vafoen(nrofon,q7,prqucn))+
     >        unsqu*vafoen(nrofon,q8,prqucn)+
     >        trsqu*vafoen(nrofon,q6,prqucn)
c
              vatrtt(nrofon,q6t,f1cp) = vafoen(nrofon,q7,prqucn)
c
c           Pour le triangle NT2 :
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q3,prqucn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q5,prqucn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q2,prqucn)
c
              vatrtt(nrofon,q4t,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
              vatrtt(nrofon,q5t,f2cp) =
     >        trshu*vafoen(nrofon,q2,prqucn)-
     >        unshu*vafoen(nrofon,q1,prqucn)+
     >        trsqu*vafoen(nrofon,q5,prqucn)
c
              vatrtt(nrofon,q6t,f2cp) = vafoen(nrofon,q6,prqucn)
c
c           Pour le triangle NT3 :
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q4,prqucn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prqucn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q5,prqucn)
c
              vatrtt(nrofon,q4t,f3cp) = vafoen(nrofon,q8,prqucn)
c
              vatrtt(nrofon,q5t,f3cp) =
     >        trshu*vafoen(nrofon,q1,prqucn)-
     >        unshu*vafoen(nrofon,q2,prqucn)+
     >        trsqu*vafoen(nrofon,q5,prqucn)
c
              vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
 2221       continue

c         Pour un decoupage par l'arete numero 2 :

          elseif ( etanp1.eq.32 ) then
c
            do 2222 , nrofon = 1 , nbfonc
c
c           Pour le triangle NT1 :
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prqucn)
c
              vatrtt(nrofon,q2t,f1cp) = vafoen(nrofon,q6,prqucn)
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q4,prqucn)
c
              vatrtt(nrofon,q4t,f1cp) =
     >       -trssz*
     >            (vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >             vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >        trshu*(vafoen(nrofon,q6,prqucn)+vafoen(nrofon,q8,prqucn))+
     >        unsqu*vafoen(nrofon,q7,prqucn)+
     >        trsqu*vafoen(nrofon,q5,prqucn)
c
              vatrtt(nrofon,q5t,f1cp) =
     >       -trssz*
     >            (vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >             vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >        trshu*(vafoen(nrofon,q6,prqucn)+vafoen(nrofon,q8,prqucn))+
     >        unsqu*vafoen(nrofon,q5,prqucn)+
     >        trsqu*vafoen(nrofon,q7,prqucn)
c
              vatrtt(nrofon,q6t,f1cp) = vafoen(nrofon,q8,prqucn)
c
c           Pour le triangle NT2 :
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q4,prqucn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q6,prqucn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q3,prqucn)
c
              vatrtt(nrofon,q4t,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
              vatrtt(nrofon,q5t,f2cp) =
     >        trshu*vafoen(nrofon,q3,prqucn)-
     >        unshu*vafoen(nrofon,q2,prqucn)+
     >        trsqu*vafoen(nrofon,q6,prqucn)
c
              vatrtt(nrofon,q6t,f2cp) = vafoen(nrofon,q7,prqucn)
c
c           Pour le triangle NT3 :
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prqucn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q2,prqucn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q6,prqucn)
c
              vatrtt(nrofon,q4t,f3cp) = vafoen(nrofon,q5,prqucn)
c
              vatrtt(nrofon,q5t,f3cp) =
     >        trshu*vafoen(nrofon,q2,prqucn)-
     >        unshu*vafoen(nrofon,q3,prqucn)+
     >        trsqu*vafoen(nrofon,q6,prqucn)
c
              vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
 2222       continue

c         Pour un decoupage par l'arete numero 3 :

          elseif ( etanp1.eq.33 ) then
c
            do 2223 , nrofon = 1 , nbfonc
c
c           Pour le triangle NT1 :
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q2,prqucn)
c
              vatrtt(nrofon,q2t,f1cp) = vafoen(nrofon,q7,prqucn)
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prqucn)
c
              vatrtt(nrofon,q4t,f1cp) =
     >       -trssz*
     >           (vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >            vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >      trshu*(vafoen(nrofon,q5,prqucn)+vafoen(nrofon,q7,prqucn))+
     >        unsqu*vafoen(nrofon,q8,prqucn)+
     >        trsqu*vafoen(nrofon,q6,prqucn)
c
              vatrtt(nrofon,q5t,f1cp) =
     >       -trssz*
     >            (vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >             vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >      trshu*(vafoen(nrofon,q5,prqucn)+vafoen(nrofon,q7,prqucn))+
     >        unsqu*vafoen(nrofon,q6,prqucn)+
     >        trsqu*vafoen(nrofon,q8,prqucn)
c
              vatrtt(nrofon,q6t,f1cp) = vafoen(nrofon,q5,prqucn)
c
c           Pour le triangle NT2 :
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prqucn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q7,prqucn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q4,prqucn)
c
              vatrtt(nrofon,q4t,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
              vatrtt(nrofon,q5t,f2cp) =
     >        trshu*vafoen(nrofon,q4,prqucn)-
     >        unshu*vafoen(nrofon,q3,prqucn)+
     >        trsqu*vafoen(nrofon,q7,prqucn)
c
              vatrtt(nrofon,q6t,f2cp) = vafoen(nrofon,q8,prqucn)
c
c           Pour le triangle NT3 :
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q2,prqucn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q3,prqucn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q7,prqucn)
c
              vatrtt(nrofon,q4t,f3cp) = vafoen(nrofon,q6,prqucn)
c
              vatrtt(nrofon,q5t,f3cp) =
     >        trshu*vafoen(nrofon,q3,prqucn)-
     >        unshu*vafoen(nrofon,q4,prqucn)+
     >        trsqu*vafoen(nrofon,q7,prqucn)
c
              vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
 2223       continue

c         Pour un decoupage par l'arete numero 4 :

          elseif ( etanp1.eq.34 ) then
c
            do 2224 , nrofon = 1 , nbfonc
c
c           Pour le triangle NT1 :
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q3,prqucn)
c
              vatrtt(nrofon,q2t,f1cp) = vafoen(nrofon,q8,prqucn)
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q2,prqucn)
c
              vatrtt(nrofon,q4t,f1cp) =
     >       -trssz*
     >          (vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >           vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >      trshu*(vafoen(nrofon,q6,prqucn)+vafoen(nrofon,q8,prqucn))+
     >      unsqu*vafoen(nrofon,q5,prqucn)+
     >      trsqu*vafoen(nrofon,q7,prqucn)
c
              vatrtt(nrofon,q5t,f1cp) =
     >       -trssz*
     >          (vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >           vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >      trshu*(vafoen(nrofon,q6,prqucn)+vafoen(nrofon,q8,prqucn))+
     >      unsqu*vafoen(nrofon,q7,prqucn)+
     >      trsqu*vafoen(nrofon,q5,prqucn)
c
              vatrtt(nrofon,q6t,f1cp) = vafoen(nrofon,q6,prqucn)
c
c           Pour le triangle NT2 :
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q2,prqucn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q8,prqucn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prqucn)
c
              vatrtt(nrofon,q4t,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
              vatrtt(nrofon,q5t,f2cp) =
     >        trshu*vafoen(nrofon,q1,prqucn)-
     >        unshu*vafoen(nrofon,q4,prqucn)+
     >        trsqu*vafoen(nrofon,q8,prqucn)
c
              vatrtt(nrofon,q6t,f2cp) = vafoen(nrofon,q5,prqucn)
c
c           Pour le triangle NT3 :
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q3,prqucn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q4,prqucn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q8,prqucn)
c
              vatrtt(nrofon,q4t,f3cp) = vafoen(nrofon,q7,prqucn)
c
              vatrtt(nrofon,q5t,f3cp) =
     >        trshu*vafoen(nrofon,q4,prqucn)-
     >        unshu*vafoen(nrofon,q1,prqucn)+
     >        trsqu*vafoen(nrofon,q8,prqucn)
c
              vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
 2224       continue
c
           endif
