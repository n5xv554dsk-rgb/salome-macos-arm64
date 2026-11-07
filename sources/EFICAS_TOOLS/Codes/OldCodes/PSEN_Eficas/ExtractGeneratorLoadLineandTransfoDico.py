#NetworkFile = r"C:\Users\J15773\Documents\GTDosier\PSENdocs\Victoria ALL - EFICAS PSEN\Data\2030Conv_HFP2.sav"
#PSSE_PATH = "C:/Program Files/PTI/PSSE33/PSSBIN" #emplacement de PSSE

def ExtractGeneratorLoadLineandTransfoDico(NetworkFile,PSSE_PATH):

    import os
    import sys

    print NetworkFile
    print PSSE_PATH
    sys.path.append(PSSE_PATH)
    os.environ['PATH'] +=  ';' + PSSE_PATH + ';'

    import psspy
    import redirect

    ###initialization PSSE
    psspy.psseinit(10000)
    _i=psspy.getdefaultint()
    _f=psspy.getdefaultreal()
    _s=psspy.getdefaultchar()
    redirect.psse2py()

    # Silent execution of PSSe
    islct=6 # 6=no output; 1=standard
    psspy.progress_output(islct)

    #open Network File
    psspy.case(NetworkFile)

    #Extract Loads
    sid = -1 #all buses
    flag = 1 #all in service loads/generators (4 all loads/generators)


    string = ['NUMBER']
    ierr,iarray = psspy.aloadint(sid,flag,string)

    string = ['NAME','ID','EXNAME']
    ierr,carray = psspy.aloadchar(sid,flag,string)

    LoadDico = {}  # [Bus name, load ID, extended bus name, bus number]
    for i in range(len(iarray[0])):
        idname = "Lo" + str(int(carray[1][i]))
        loadname = carray[0][i].strip()+ "__" + idname
        loadname = loadname.replace(" ","_")
        loadname = loadname.replace(".","_")
        loadname = loadname.replace("&","and")
        try:
            int(loadname[0])
            loadname="_" + loadname
        except:
            pass
        LoadDico[loadname]= {}
        LoadDico[loadname]['BusName'] = carray[0][i].strip()
        LoadDico[loadname]['ID'] = carray[1][i]
        LoadDico[loadname]['BusExName'] =carray[2][i]
        LoadDico[loadname]['BusNum']=iarray[0][i]

    #Extract Generators
    sid = -1 #all buses
    flag = 1 #all in service loads/generators (4 all loads/generators)
        
    string = ['NUMBER']
    ierr,iarray = psspy.amachint(sid,flag,string)

    string = ['NAME','ID','EXNAME']
    ierr,carray = psspy.amachchar(sid,flag,string)

    MachineDico = {} # [Bus name, machine ID, extended bus name, bus number]
    for i in range(len(iarray[0])):
        idname = "Gr" + str(int(carray[1][i]))
        machinename = carray[0][i].strip()+ "__" + idname
        machinename = machinename.replace(" ","_")
        machinename = machinename.replace(".","_")
        machinename = machinename.replace("&","and")
        try:
            int(machinename[0])
            machinename="_" + machinename
        except:
            pass
        MachineDico[machinename]={}
        MachineDico[machinename]['NAME'] = carray[0][i].strip()
        MachineDico[machinename]['ID'] = carray[1][i]
        MachineDico[machinename]['EXNAME'] =carray[2][i]
        MachineDico[machinename]['NUMBER']=iarray[0][i]

    #Extract Lignes
    sid = -1
    owner = 1
    ties = 1
    flag = 2 #6 for two-winding transfos
    entry = 1 #each branch once, not both directions
    string = ['FROMNUMBER','TONUMBER']
    ierr,iarray = psspy.abrnint(sid,owner,ties,flag,entry,string)
    string = ['FROMNAME','TONAME','FROMEXNAME','TOEXNAME','ID']
    ierr,carray = psspy.abrnchar(sid,owner,ties,flag,entry,string)

    LineDico = {} #[linename, Bus name 1, Bus name 2, ID, extended bus name 1, extended bus name 2, bus number 1, bus number 2]
    for i in range(len(iarray[0])):
        idname = carray[4][i]
        if '@' in idname:
            idname = idname.replace('@','Br')
        else:
            idname = 'Li' + str(int(idname))
        linename =carray[0][i].strip() + "__" + carray[1][i].strip() + "__" + idname
        linename = linename.replace(" ","_")
        linename = linename.replace(".","_")
        linename = linename.replace("&","and")
        try:
            int(linename[0])
            linename="_" + linename
        except:
            pass
        LineDico[linename]={}
        LineDico[linename]['FROMNAME']=carray[0][i].strip()
        LineDico[linename]['TONAME']=carray[1][i].strip()
        LineDico[linename]['ID']=carray[4][i]
        LineDico[linename]['FROMEXNAME']=carray[2][i]
        LineDico[linename]['TOEXNAME']=carray[3][i]
        LineDico[linename]['FROMNUMBER']=iarray[0][i]
        LineDico[linename]['TONUMBER']=iarray[1][i]

    #Extract Transfos
    sid = -1
    owner = 1
    ties = 1
    flag = 6 #two-winding transfos
    entry = 1 #each branch once, not both directions
    string = ['FROMNUMBER','TONUMBER']
    ierr,iarray = psspy.abrnint(sid,owner,ties,flag,entry,string)
    string = ['FROMNAME','TONAME','FROMEXNAME','TOEXNAME','ID']
    ierr,carray = psspy.abrnchar(sid,owner,ties,flag,entry,string)

    TfoDico = {} #[linename, Bus name 1, Bus name 2, machine ID, extended bus name 1, extended bus name 2, bus number 1, bus number 2]
    for i in range(len(iarray[0])):
        idname = 'Tr' + str(int(carray[4][i]))
        tfoname = carray[0][i].strip() + "__" + carray[1][i].strip() + "__" + idname
        tfoname = tfoname.replace(" ","_")
        tfoname = tfoname.replace(".","_")
        tfoname = tfoname.replace("&","and")
        try:
            int(tfoname[0])
            tfoname="_" + tfoname
        except:
            pass
        TfoDico[tfoname]={}
        TfoDico[tfoname]['FROMNAME']=carray[0][i].strip()
        TfoDico[tfoname]['TONAME']=carray[1][i].strip()
        TfoDico[tfoname]['ID']=carray[4][i]
        TfoDico[tfoname]['FROMEXNAME']=carray[2][i]
        TfoDico[tfoname]['TOEXNAME']=carray[3][i]
        TfoDico[tfoname]['FROMNUMBER']=iarray[0][i]
        TfoDico[tfoname]['TONUMBER']=iarray[1][i]

    return MachineDico, LoadDico, LineDico, TfoDico


#MachineDico, LoadDico, LineDico, TfoDico = ExtractGeneratorLoadLineandTransfoDico(NetworkFile,PSSE_PATH)

 
def ExtractGeneratorLoadLineandTransfoDico2(NetworkFile,PSSE_PATH):
    MachineDico={'M1':'M1','M2':'M2','M3':'M3','M4':'M4','B6_BUS13__1':'AZ','CSPRING__1':'DD','GT12B__1':'ER','BSTMB__1':'JJ'}
    LoadDico={'C1':'C1','C2':'C2','C3':'C3','C4':'C4'}
    LineDico={'L1':'L1','L2':'L2','L3':'L3','L4':'L4'}
    TfoDico={'T1':'T1','T2':'T2','T3':'T3','T4':'T4'}
    MDico={'MZ1':'MZ1','MZ2':'MZ2','MZ3':'MZ3','MZ4':'MZ4'}
    if NetworkFile == '/home/A96028/PSEN/PSEN_V8/Code/PSEN_Eficas/faux2.sav': 
       print "sans T1"
       TfoDico={'T2':'T2','T3':'T3','T4':'T4'}


    return MachineDico, LoadDico, LineDico, TfoDico, MDico
