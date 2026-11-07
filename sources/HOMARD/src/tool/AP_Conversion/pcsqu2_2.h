c           .................         .................
c           .               .         .       .       .
c           .               .         .       .       .
c           .               .         .       .       .
c           .               .  ===>   .................
c           .               .         .       .       .
c           .               .         .       .       .
c           .               .         .       .       .
c           .................         .................
c
            f1hp = filqua(quhnp1)
            f1cp = nqusca(f1hp)
            f2cp = nqusca(f1hp+1)
            f3cp = nqusca(f1hp+2)
            f4cp = nqusca(f1hp+3)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            prfcap(f3cp) = 1
            prfcap(f4cp) = 1

            do 223 , nrofon = 1 , nbfonc
c           pour le quadrangle Q1
c
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prqucn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q5,prqucn)
c     
              vafott(nrofon,q3,f1cp) = 
     >      -unsqu*(vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >              vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >       unsde*(vafoen(nrofon,q5,prqucn)+vafoen(nrofon,q6,prqucn)+
     >              vafoen(nrofon,q7,prqucn)+vafoen(nrofon,q8,prqucn))          
              vafott(nrofon,q4,f1cp) = vafoen(nrofon,q8,prqucn)
c     
              vafott(nrofon,q5,f1cp) =
     >       -unshu*vafoen(nrofon,q2,prqucn)+
     >        trshu*vafoen(nrofon,q1,prqucn)+
     >        trsqu*vafoen(nrofon,q5,prqucn)
c
              vafott(nrofon,q6,f1cp) =
     >       -trssz*(vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >               vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >        trshu*(vafoen(nrofon,q6,prqucn)+vafoen(nrofon,q8,prqucn))+
     >        unsqu*vafoen(nrofon,q7,prqucn)+
     >        trsqu*vafoen(nrofon,q5,prqucn)
c
              vafott(nrofon,q7,f1cp) =
     >       -trssz*(vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >               vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >        trshu*(vafoen(nrofon,q5,prqucn)+vafoen(nrofon,q7,prqucn))+
     >        unsqu*vafoen(nrofon,q6,prqucn)+
     >        trsqu*vafoen(nrofon,q8,prqucn)
c
              vafott(nrofon,q8,f1cp) =
     >       -unshu*vafoen(nrofon,q4,prqucn)+
     >        trshu*vafoen(nrofon,q1,prqucn)+
     >        trsqu*vafoen(nrofon,q8,prqucn)
c
c           pour le quadrangle Q2
c
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q2,prqucn)
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q6,prqucn)
c     
              vafott(nrofon,q3,f2cp) = vafott(nrofon,q3,f1cp)
c     
              vafott(nrofon,q4,f2cp) = vafoen(nrofon,q5,prqucn)
c     
              vafott(nrofon,q5,f2cp) =
     >       -unshu*vafoen(nrofon,q3,prqucn)+
     >        trshu*vafoen(nrofon,q2,prqucn)+
     >        trsqu*vafoen(nrofon,q6,prqucn)
c
              vafott(nrofon,q6,f2cp) =
     >       -trssz*(vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >               vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >        trshu*(vafoen(nrofon,q5,prqucn)+vafoen(nrofon,q7,prqucn))+
     >        unsqu*vafoen(nrofon,q8,prqucn)+
     >        trsqu*vafoen(nrofon,q6,prqucn)
c
              vafott(nrofon,q7,f2cp) =vafott(nrofon,q6,f1cp)
c
              vafott(nrofon,q8,f2cp) =
     >       -unshu*vafoen(nrofon,q1,prqucn)+
     >        trshu*vafoen(nrofon,q2,prqucn)+
     >        trsqu*vafoen(nrofon,q5,prqucn)
c
c           pour le quadrangle Q3
c
              vafott(nrofon,q1,f3cp) = vafoen(nrofon,q3,prqucn)
c
              vafott(nrofon,q2,f3cp) = vafoen(nrofon,q7,prqucn)
c     
              vafott(nrofon,q3,f3cp) = vafott(nrofon,q3,f1cp)
c     
              vafott(nrofon,q4,f3cp) = vafoen(nrofon,q6,prqucn)
c     
              vafott(nrofon,q5,f3cp) =
     >       -unshu*vafoen(nrofon,q4,prqucn)+
     >        trshu*vafoen(nrofon,q3,prqucn)+
     >        trsqu*vafoen(nrofon,q7,prqucn)
c
              vafott(nrofon,q6,f3cp) =
     >       -trssz*(vafoen(nrofon,q1,prqucn)+vafoen(nrofon,q2,prqucn)+
     >               vafoen(nrofon,q3,prqucn)+vafoen(nrofon,q4,prqucn))+
     >        trshu*(vafoen(nrofon,q6,prqucn)+vafoen(nrofon,q8,prqucn))+
     >        unsqu*vafoen(nrofon,q5,prqucn)+
     >        trsqu*vafoen(nrofon,q7,prqucn)
c
              vafott(nrofon,q7,f3cp) =vafott(nrofon,q6,f2cp)
c
              vafott(nrofon,q8,f3cp) =
     >       -unshu*vafoen(nrofon,q2,prqucn)+
     >        trshu*vafoen(nrofon,q3,prqucn)+
     >        trsqu*vafoen(nrofon,q6,prqucn)
c
c           pour le quadrangle Q4
c
              vafott(nrofon,q1,f4cp) = vafoen(nrofon,q4,prqucn)
c
              vafott(nrofon,q2,f4cp) = vafoen(nrofon,q8,prqucn)
c     
              vafott(nrofon,q3,f4cp) = vafott(nrofon,q3,f1cp)
c     
              vafott(nrofon,q4,f4cp) = vafoen(nrofon,q7,prqucn)
c     
              vafott(nrofon,q5,f4cp) =
     >       -unshu*vafoen(nrofon,q1,prqucn)+
     >        trshu*vafoen(nrofon,q4,prqucn)+
     >        trsqu*vafoen(nrofon,q8,prqucn)
c
              vafott(nrofon,q6,f4cp) = vafott(nrofon,q7,f1cp)
c
              vafott(nrofon,q7,f4cp) = vafott(nrofon,q6,f3cp)
c
              vafott(nrofon,q8,f4cp) =
     >       -unshu*vafoen(nrofon,q3,prqucn)+
     >        trshu*vafoen(nrofon,q4,prqucn)+
     >        trsqu*vafoen(nrofon,q7,prqucn)
c            
  223       continue

