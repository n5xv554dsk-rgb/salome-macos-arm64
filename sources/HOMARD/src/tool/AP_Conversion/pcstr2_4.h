c                   .                         .
c                  ...                       . .
c                 . . .                     .   .
c                .  .  .                   .     .
c               .   .   .      ===>       .       .
c              .    .    .               .  .      .
c             .     .     .             .      .    .
c            .      .      .           .          .  .
c           .................         .................
c
c         Pour un decoupage selon l'arete numero 1 :
c
          elseif ( etanp1.ge.1 .and. etanp1.le.3 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', 'pcstr2_4'
      write (ulsort,*) 'etanp1=',etanp1
#endif
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
c            
c     decoupage en 2 par l'arete numero 2 d'un triangle predecoupe en a1
c            
            if ( etan.eq.1 .and. etanp1.eq.2) then
c
            do 23311 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine 
c            
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q6,prf1cn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prf2cn)
c
              vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf1cn)
c
              vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                        vafoen(nrofon,q6,prf2cn))
c
              vafott(nrofon,q5,f1cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q3,prf2cn))
c
              vafott(nrofon,q6,f1cp) =-unshu*vafoen(nrofon,q1,prf1cn)+
     >                                 trshu*vafoen(nrofon,q3,prf1cn)+
     >                                 trsqu*vafoen(nrofon,q6,prf1cn)
c            
c        Pour le triangle fils NF+1 
c            
              vafott(nrofon,q1,f2cp) = unsde*(vafoen(nrofon,q1,prf1cn)+
     >                                        vafoen(nrofon,q1,prf2cn))
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prf2cn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q6,prf1cn)
c
              vafott(nrofon,q4,f2cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q5,f2cp) = vafott(nrofon,q4,f1cp) 
c
              vafott(nrofon,q6,f2cp) =-unshu*vafoen(nrofon,q3,prf1cn)+
     >                                 trshu*vafoen(nrofon,q1,prf1cn)+
     >                                 trsqu*vafoen(nrofon,q6,prf1cn)
c            
23311       continue
c  
c     decoupage en 2 par l'arete numero 3 d'un triangle predecoupe en a1 
c           
            elseif ( etan.eq.1 .and. etanp1.eq.3) then
c
            do 23312 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine 
c            
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prf2cn)
c
              vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf1cn)
c
              vafott(nrofon,q4,f1cp) = -unshu*vafoen(nrofon,q1,prf2cn)+
     >                                  trshu*vafoen(nrofon,q2,prf2cn)+
     >                                  trsqu*vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q5,f1cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q3,prf2cn))
c
              vafott(nrofon,q6,f1cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                        vafoen(nrofon,q4,prf1cn))
c            
c        Pour le triangle fils NF+1 
c            
              vafott(nrofon,q1,f2cp) = unsde*(vafoen(nrofon,q1,prf1cn)+
     >                                        vafoen(nrofon,q1,prf2cn))
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q3,prf1cn)
c
              vafott(nrofon,q4,f2cp) =  trshu*vafoen(nrofon,q1,prf2cn)
     >                                 -unshu*vafoen(nrofon,q2,prf2cn)+
     >                                  trsqu*vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q5,f2cp) =  vafott(nrofon,q6,f1cp)
c
              vafott(nrofon,q6,f2cp) = vafoen(nrofon,q6,prf1cn)
c            
23312       continue
c  
c     decoupage en 2 par l'arete numero 1 d'un triangle predecoupe en a2 
c           
            elseif ( etan.eq.2 .and. etanp1.eq.1) then
c
            do 23313 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine 
c            
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf1cn)
c
              vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                        vafoen(nrofon,q5,prf2cn))
c
              vafott(nrofon,q5,f1cp) = trshu*vafoen(nrofon,q3,prf1cn)
     >                                -unshu*vafoen(nrofon,q2,prf1cn)+
     >                                 trsqu*vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q6,f1cp) = unsde*(vafoen(nrofon,q3,prf2cn)+
     >                                        vafoen(nrofon,q1,prf1cn))
c            
c        Pour le triangle fils NF+1 
c            
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vafott(nrofon,q2,f2cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q2,prf1cn))
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q4,f2cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q5,f2cp) = trshu*vafoen(nrofon,q2,prf2cn)
     >                                -unshu*vafoen(nrofon,q3,prf1cn)+
     >                                 trsqu*vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q6,f2cp) = vafott(nrofon,q4,f1cp)
c            
23313       continue
c
c     decoupage en 2 par l'arete numero 3 d'un triangle predecoupe en a2
c           
            elseif ( etan.eq.2 .and. etanp1.eq.3) then
c
            do 23314 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine 
c            
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q2,f1cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q2,prf2cn))
c
              vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf1cn)
c
              vafott(nrofon,q4,f1cp) = trshu*vafoen(nrofon,q2,prf2cn)
     >                                -unshu*vafoen(nrofon,q1,prf2cn)+
     >                                 trsqu*vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q5,f1cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q6,f1cp) = unsde*(vafoen(nrofon,q5,prf2cn)+
     >                                        vafoen(nrofon,q4,prf1cn))
c            
c        Pour le triangle fils NF+1 
c            
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q3,prf1cn)
c
              vafott(nrofon,q4,f2cp) = trshu*vafoen(nrofon,q1,prf2cn)
     >                                -unshu*vafoen(nrofon,q2,prf2cn)+
     >                                 trsqu*vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q5,f2cp) = vafott(nrofon,q6,f1cp)
c
              vafott(nrofon,q6,f2cp) = unsde*(vafoen(nrofon,q1,prf1cn)+
     >                                        vafoen(nrofon,q3,prf2cn))
c                        
23314       continue
c  
c     decoupage en 2 par l'arete numero 1 d'un triangle predecoupe en a3 
c           
            elseif ( etan.eq.3 .and. etanp1.eq.1) then
c
           
            do 23315 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine 
c            
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q3,f1cp) = unsde*(vafoen(nrofon,q3,prf1cn)+
     >                                        vafoen(nrofon,q3,prf2cn))
c
              vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                        vafoen(nrofon,q5,prf2cn))
c
              vafott(nrofon,q5,f1cp) = trshu*vafoen(nrofon,q3,prf1cn)
     >                                -unshu*vafoen(nrofon,q2,prf1cn)+
     >                                 trsqu*vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q6,f1cp) = vafoen(nrofon,q6,prf2cn)
c            
c        Pour le triangle fils NF+1 
c            
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prf1cn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q4,f2cp) = unsde*(vafoen(nrofon,q1,prf1cn)+
     >                                        vafoen(nrofon,q2,prf2cn))
c
              vafott(nrofon,q5,f2cp) = trshu*vafoen(nrofon,q2,prf1cn)
     >                                -unshu*vafoen(nrofon,q3,prf1cn)+
     >                                 trsqu*vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q6,f2cp) = vafott(nrofon,q4,f1cp)
c
23315       continue
c  
c     decoupage en 2 par l'arete numero 2 d'un triangle predecoupe en a3 
c           
            elseif ( etan.eq.3 .and. etanp1.eq.2) then
c
            do 23316 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine 
c            
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prf1cn)
c
              vafott(nrofon,q3,f1cp) = unsde*(vafoen(nrofon,q3,prf1cn)+
     >                                        vafoen(nrofon,q3,prf2cn))
c
              vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                        vafoen(nrofon,q5,prf2cn))
c
              vafott(nrofon,q5,f1cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q6,f1cp) = trshu*vafoen(nrofon,q3,prf2cn)
     >                                -unshu*vafoen(nrofon,q1,prf2cn)+
     >                                 trsqu*vafoen(nrofon,q6,prf2cn)
c            
c        Pour le triangle fils NF+1 
c            
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prf1cn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q4,f2cp) = unsde*(vafoen(nrofon,q1,prf1cn)+
     >                                        vafoen(nrofon,q2,prf2cn))
c
              vafott(nrofon,q5,f2cp) = vafott(nrofon,q4,f1cp)
c
              vafott(nrofon,q6,f2cp) = trshu*vafoen(nrofon,q1,prf2cn)
     >                                -unshu*vafoen(nrofon,q3,prf2cn)+
     >                                 trsqu*vafoen(nrofon,q6,prf2cn)
c
23316      continue
c
            endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', 'pcstr2_4'
#endif
