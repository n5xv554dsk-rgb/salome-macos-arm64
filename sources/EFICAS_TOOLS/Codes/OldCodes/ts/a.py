liste=l.split()
if len(liste) > 1 :
   txt=""
   for e in liste:
       txt+='_'+e
   txt=txt[1:]
else :
   txt=l
