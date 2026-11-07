import os
import sys
import numpy as np
import copy

#import Storage


def getNominalkV(NetworkFile):
    print "begin getNominalkV for ", NetworkFile

    print "version en dur"
    BusList=(1,2,3,4,6)
    LinesList=(7,8,9,10)
    TransfosList=('Transfos_A', 'Transfos_B', 'Transfos_C', 'Transfos_D')
    return BusList, LinesList, TransfosList

    import psspy
    import redirect

    psspy.psseinit(80000)
    redirect.psse2py()
    psspy.progress_output(6)

    psspy.case(NetworkFile)
    print "before buses"
    # Buses

    sid = -1
    flag = 2
    ierr, ret = psspy.abusreal(sid, flag, ['BASE'])
    Storage.BusBase = ret[0]

    ierr, carray = psspy.abuschar(sid, flag, ['NAME'])
    Storage.BusBaseList = {}
    for i in range(len(carray[0])):
        Storage.BusBaseList[carray[0][i]] = ret[0][i]

    BusList = []
    for item in Storage.BusBase:
        if item not in BusList:
            BusList.append(item)
    BusList = sorted(BusList)

    print "after buses"

    # Lines

    owner = 1
    ties = 1
    flag = 2
    entry = 1
    string = ['FROMNAME', 'TONAME']
    ierr, carray = psspy.abrnchar(sid, owner, ties, flag, entry, string)

    for i in range(len(carray[0])):
        nom = Storage.BusBaseList[carray[0][i]]
        name = carray[0][i] + '-' + carray[1][i]
        Storage.LinesBaseList[name] = nom
        Storage.LinesBase.append(nom)

    LinesList = []
    for item in Storage.LinesBase:
        if item not in LinesList:
            LinesList.append(item)
    LinesList = sorted(LinesList)

    print "after lines"

    # Transfos

    owner = 1
    ties = 1
    flag = 6
    entry = 1
    string = ['FROMNAME', 'TONAME']
    ierr, carray = psspy.abrnchar(sid, owner, ties, flag, entry, string)

    for i in range(len(carray[0])):
        nom1 = Storage.BusBaseList[carray[0][i]]
        nom2 = Storage.BusBaseList[carray[1][i]]
        name = carray[0][i] + '-' + carray[1][i]
        Storage.TransfoBaseList[name] = [nom1, nom2]
        Storage.TransfoBase.append([nom1, nom2])

    TransfosList = []
    for item in Storage.TransfoBase:
        string = str(item[0]) + ' - ' + str(item[1])
        if string not in TransfosList:
            TransfosList.append(string)
    TransfosList = sorted(TransfosList)

    print "after transfos"

    # Generators

    sid = -1 #all buses
    flag = 1 #all in service loads/generators (4 all loads/generators)

    string = ['NUMBER']
    ierr,iarray = psspy.amachint(sid,flag,string)

    string = ['NAME','ID']
    ierr,carray = psspy.amachchar(sid,flag,string)

    for i in range(len(iarray[0])):
        idname = "GR" + carray[1][i]
        machinename = carray[0][i].strip()+ "__" + idname
        machinename = machinename.replace(" ","_")
        machinename = machinename.replace("-","_")
        machinename = machinename.replace(".","_")
        machinename = machinename.replace("&","and")
        try:
            int(machinename[0])
            machinename = "_" + machinename
        except:
            pass
        Storage.GenBaseList[machinename] = iarray[0][i]

    return BusList, LinesList, TransfosList

#PN --> inutiles
#def getBusNominalkV(NetworkFile):
#    import psspy
#    import redirect
#
#    psspy.psseinit(80000)
#    redirect.psse2py()
#    psspy.progress_output(6)
#
#    psspy.case(NetworkFile)
#
#    sid = -1
#    flag = 2
#    ierr, ret = psspy.abusreal(sid, flag, ['BASE'])
#    Storage.BusBase = ret[0]
#
#    ierr, carray = psspy.abuschar(sid, flag, ['NAME'])
#    buses = {}
#    for i in range(len(carray[0])):
#        buses[carray[0][i]] = ret[0][i]
#    Storage.BusNames = buses
#    ret = []
#    for item in Storage.BusBase:
#        if item not in ret:
#            ret.append(item)
#    return sorted(ret)

#def updateConts():
#    Storage.ContFullList = []
#    tmp = Storage.BusBaseList.keys()
#    tmp.sort()
#    for key in tmp:
#        Storage.ContFullList.append(key)
#    tmp = Storage.GenBaseList.keys()
#    tmp.sort()
#    for key in tmp:
#        Storage.ContFullList.append(key)
#    tmp = Storage.LinesBaseList.keys()
#    tmp.sort()
#    for key in tmp:
#        Storage.ContFullList.append(key)
#    tmp = Storage.TransfoBaseList.keys()
#    tmp.sort()
#    for key in tmp:
#        Storage.ContFullList.append(key)
#    print Storage.ContFullList
#    return Storage.ContFullList
#
#def newContingency(MatList):
#    Storage.CustomContingencies.append(MatList)
#
#def checkIfBorder(graph, key, depth, tmplist):
#    if key in tmplist:
#        return True
#    if depth == 0:
#        return False
#    NonBorders = 0
#    for item in graph[key]:
#        if not checkIfBorder(graph, item, depth - 1, tmplist):
#            NonBorders += 1
#    if NonBorders < 2: # A generator is considered as isolated if it has less than two non-borders neighbours
#        if key not in tmplist:
#            tmplist.append(key)
#        return True
#    return False
#
#def getTrueLines(NetworkFile):
#    import psspy
#    import redirect
#
#    psspy.psseinit(80000)
#    redirect.psse2py()
#    psspy.progress_output(6)
#
#    psspy.case(NetworkFile)
#
#    sid = -1
#    owner = 1
#    ties = 1
#    flag = 4 # 6 for two-winding transfos
#    entry = 1 #each branch once, not both directions
#    string = ['FROMNAME', 'TONAME', 'ID']
#    ierr, iarray = psspy.abrnchar(sid, owner, ties, flag, entry, string)
#    string = ['FROMNUMBER', 'TONUMBER']
#    ierr, carray = psspy.abrnint(sid, owner, ties, flag, entry, string)
#
#    lst = []
#    tmplist = []
#    try:
#        for i in range(len(carray[0])):
#            if carray[0][i] not in lst and carray[0][i] not in tmplist:
#                tmplist.append(carray[0][i])
#            elif carray[0][i] not in lst and carray[0][i] in tmplist:
#                tmplist.remove(carray[0][i])
#                lst.append(carray[0][i])
#            if carray[1][i] not in lst and carray[1][i] not in tmplist:
#                tmplist.append(carray[1][i])
#            elif carray[1][i] not in lst and carray[1][i] in tmplist:
#                tmplist.remove(carray[1][i])
#                lst.append(carray[1][i])
#    except:
#        pass
#
#    # Create the graph
#    graph = {}
#    for i in range(len(carray[0])):
#        try:
#            if graph[carray[0][i]]:
#                pass
#        except:
#            graph[carray[0][i]] = []
#        if carray[1][i] not in graph[carray[0][i]]:
#            graph[carray[0][i]].append(carray[1][i])
#        try:
#            if graph[carray[1][i]]:
#                pass
#        except:
#            graph[carray[1][i]] = []
#        if carray[0][i] not in graph[carray[1][i]]:
#            graph[carray[1][i]].append(carray[0][i])
#
#    # Search it twice, to ensure everything is mapped
#    for key in sorted(graph.keys()):
#        checkIfBorder(graph, key, Storage.RecursiveDepth, tmplist)
#    for key in reversed(sorted(graph.keys())):
#        checkIfBorder(graph, key, Storage.RecursiveDepth, tmplist)
#
#    Storage.IsolatedGenList = []
#    # Unfold it
#    for i in range(len(carray[0])):
#        if carray[0][i] in tmplist:
#            if iarray[0][i] not in Storage.IsolatedGenList:
#                Storage.IsolatedGenList.append(iarray[0][i])
#        if carray[1][i] in tmplist:
#            if iarray[1][i] not in Storage.IsolatedGenList:
#                Storage.IsolatedGenList.append(iarray[1][i])
#
#    lines = []
#    outLines = []
#    for i in range(len(iarray[0])):
#        name = iarray[0][i] + '-' + iarray[1][i]
#        if '@' in iarray[2][i] or '*' in iarray[2][i]:
#            outLines.append(name)
#        elif iarray[0][i] not in Storage.IsolatedGenList and iarray[1][i] not in Storage.IsolatedGenList:
#            lines.append(name)
#        else:
#            outLines.append(name)
#    Storage.TrueLines = lines
#    return lines
#
#NoBreakersandSwitches = True
#
#def ExtractGeneratorLoadLineandTransfoDico(NetworkFile,PSSE_PATH):
#    import os
#    import sys
#    import numpy as np
#
#    print NetworkFile
#    print PSSE_PATH
#    sys.path.append(PSSE_PATH)
#    os.environ['PATH'] +=  ';' + PSSE_PATH + ';'
#
#    import psspy
#    import redirect
#
#    ###initialization PSSE
#    psspy.psseinit(10000)
#    _i=psspy.getdefaultint()
#    _f=psspy.getdefaultreal()
#    _s=psspy.getdefaultchar()
#    redirect.psse2py()
#
#    # Silent execution of PSSe
#    islct=6 # 6=no output; 1=standard
#    psspy.progress_output(islct)
#
#    #open Network File
#    psspy.case(NetworkFile)
#
#    # Extract Buses
#    sid = -1 # all buses
#    flag = 2
#    string = ['NUMBER']
#    ierr, iarray = psspy.abusint(sid, flag, string)
#
#    string = ['NAME', 'EXNAME']
#    ierr, carray = psspy.abuschar(sid, flag, string)
#
#    string = ['BASE']
#    ierr, ret = psspy.abusreal(sid, flag, string)
#
#    BusDico = {}
#    BusNominal = {}
#    for i in range(len(iarray[0])):
#        BusNum = iarray[0][i]
#        BusDico[str(BusNum)] = carray[0][i].strip()
#        BusNominal[BusDico[str(BusNum)]] = ret[0][i]    
#
#    #Extract Loads
#    sid = -1 #all buses
#    flag = 1 #all in service loads/generators (4 all loads/generators)
#
#
#    string = ['NUMBER']
#    ierr,iarray = psspy.aloadint(sid,flag,string)
#
#    string = ['NAME','ID','EXNAME']
#    ierr,carray = psspy.aloadchar(sid,flag,string)
#
#    string = ['mvaact']
#    ierr, xdata = psspy.aloadcplx(sid, flag, string)
#
#    LoadDico = {}  # [Bus name, load ID, extended bus name, bus number]
#    for i in range(len(iarray[0])):
#        idname = "Lo" + carray[1][i].strip()
##        try: #id is an integer
##            idname = "Lo" + str(int(carray[1][i]))
##        except: #id is not an integer
##            idname = "Lo" + carray[1][i]
#        loadname = carray[0][i].strip()+ "__" + idname
#        loadname = loadname.replace(" ","_")
#        loadname = loadname.replace("-","_")
#        loadname = loadname.replace(".","_")
#        loadname = loadname.replace("&","and")
#        try:
#            int(loadname[0])
#            loadname="_" + loadname
#        except:
#            pass
#        LoadDico[loadname]= {}
#        LoadDico[loadname]['NAME'] = carray[0][i].strip()
#        LoadDico[loadname]['ID'] = carray[1][i]
#        LoadDico[loadname]['EXNAME'] =carray[2][i]
#        LoadDico[loadname]['NUMBER']=iarray[0][i]
#        LoadDico[loadname]['P']=np.real(xdata)[0][i]
#        LoadDico[loadname]['Q']=np.imag(xdata)[0][i]
#
#    #Extract Generators
#    sid = -1 #all buses
#    flag = 1 #all in service loads/generators (4 all loads/generators)
#
#    string = ['NUMBER']
#    ierr,iarray = psspy.amachint(sid,flag,string)
#
#    string = ['NAME','ID','EXNAME']
#    ierr,carray = psspy.amachchar(sid,flag,string)
#
#    rstrings = ['pgen','qgen','mbase','pmax','qmax','pmin','qmin']
#    ierr, rarray = psspy.amachreal(sid, flag, rstrings)
#
#    MachineDico = {} # [Bus name, machine ID, extended bus name, bus number]
#    for i in range(len(iarray[0])):
#        idname = "Gr" + carray[1][i].strip()
###        try:
###            idname = "Gr" + str(int(carray[1][i]))
###        except:
###            idname = "Gr" + carray[1][i]
#        machinename = carray[0][i].strip()+ "__" + idname
#        machinename = machinename.replace(" ","_")
#        machinename = machinename.replace("-","_")
#        machinename = machinename.replace(".","_")
#        machinename = machinename.replace("&","and")
#        try:
#            int(machinename[0])
#            machinename="_" + machinename
#        except:
#            pass
#        MachineDico[machinename]={}
#        MachineDico[machinename]['NAME'] = carray[0][i].strip()
#        MachineDico[machinename]['ID'] = carray[1][i]
#        MachineDico[machinename]['EXNAME'] =carray[2][i]
#        MachineDico[machinename]['NUMBER']=iarray[0][i]
#        MachineDico[machinename]['P']=rarray[0][i]
#        MachineDico[machinename]['Q']=rarray[1][i]
#        MachineDico[machinename]['PMAX']=rarray[3][i]
#        MachineDico[machinename]['QMAX']=rarray[4][i]
#        MachineDico[machinename]['PMIN']=rarray[5][i]
#        MachineDico[machinename]['QMIN']=rarray[6][i]
#
#    #Extract Motors
#    sid = -1 #all buses
#    flag = 1 #all in service loads/generators (4 all loads/generators)
#
#    string = ['NUMBER','PSETCODE','BASECODE']
#    ierr,iarray = psspy.aindmacint(sid,flag,string)
#
#    string = ['NAME','ID','EXNAME']
#    ierr,carray = psspy.aindmacchar(sid,flag,string)
#
#    rstrings = ['psetpoint','mbase','p','q']
#    ierr, rarray = psspy.aindmacreal(sid, flag, rstrings)
#
#
#    MotorDico = {} # [Bus name, machine ID, extended bus name, bus number]
#    for i in range(len(iarray[0])):
#        idname = "Mo" + carray[1][i].strip()
###        try:
###            idname = "Gr" + str(int(carray[1][i]))
###        except:
###            idname = "Gr" + carray[1][i]
#        motorname = carray[0][i].strip()+ "__" + idname
#        motorname = motorname.replace(" ","_")
#        motorname = motorname.replace("-","_")
#        motorname = motorname.replace(".","_")
#        motorname = motorname.replace("&","and")
#        try:
#            int(motorname[0])
#            motorname="_" + motorname
#        except:
#            pass
#        MotorDico[motorname]={}
#        MotorDico[motorname]['NAME'] = carray[0][i].strip()
#        MotorDico[motorname]['ID'] = carray[1][i]
#        MotorDico[motorname]['EXNAME'] =carray[2][i]
#        MotorDico[motorname]['NUMBER']=iarray[0][i]
#        MotorDico[motorname]['PSETCODE']=iarray[1][i]
#        MotorDico[motorname]['BASECODE']=iarray[2][i]
#        MotorDico[motorname]['PSETPOINT']=rarray[0][i]
#        MotorDico[motorname]['MBASE']=rarray[1][i]
#        MotorDico[motorname]['P']=rarray[2][i]
#        MotorDico[motorname]['Q']=rarray[3][i]
#
#
#    #Extract Lignes
#    sid = -1
#    owner = 1
#    ties = 1
#    flag = 2 #6 for two-winding transfos
#    entry = 1 #each branch once, not both directions
#    string = ['FROMNUMBER','TONUMBER']
#    ierr,iarray = psspy.abrnint(sid,owner,ties,flag,entry,string)
#    string = ['FROMNAME','TONAME','FROMEXNAME','TOEXNAME','ID']
#    ierr,carray = psspy.abrnchar(sid,owner,ties,flag,entry,string)
#
#    LineDico = {} #[linename, Bus name 1, Bus name 2, ID, extended bus name 1, extended bus name 2, bus number 1, bus number 2]
#    for i in range(len(iarray[0])):
#        idname = carray[4][i].strip()
#        #idname = carray[4][i]
#        if '@' in idname:
#            idname = idname.replace('@','Br')
#        elif '*' in idname:
#            idname = idname.replace('*','Sw')
#        else:
#            try:
#                idname = 'Li' + str(int(idname))
#            except:
#                idname = 'Li' + idname
#        linename =carray[0][i].strip() + "__" + carray[1][i].strip() + "__" + idname
#        linename = linename.replace(" ","_")
#        linename = linename.replace("-","_")
#        linename = linename.replace(".","_")
#        linename = linename.replace("&","and")
#        try:
#            int(linename[0])
#            linename="_" + linename
#        except:
#            pass
#        if NoBreakersandSwitches:
#            if 'Br' not in idname and 'Sw' not in idname:
#                LineDico[linename]={}
#                LineDico[linename]['FROMNAME']=carray[0][i].strip()
#                LineDico[linename]['TONAME']=carray[1][i].strip()
#                LineDico[linename]['ID']=carray[4][i]
#                LineDico[linename]['FROMEXNAME']=carray[2][i]
#                LineDico[linename]['TOEXNAME']=carray[3][i]
#                LineDico[linename]['FROMNUMBER']=iarray[0][i]
#                LineDico[linename]['TONUMBER']=iarray[1][i]
#
#    #Extract Branches
#    sid = -1
#    owner = 1
#    ties = 1
#    flag = 4 # lines & transfos
#    entry = 1 #each branch once, not both directions
#    string = ['FROMNUMBER','TONUMBER']
#    ierr, iarray = psspy.abrnint(sid, owner, ties, flag, entry, string)
#    string = ['FROMNAME','TONAME','FROMEXNAME','TOEXNAME','ID']
#    ierr, carray = psspy.abrnchar(sid, owner, ties, flag, entry, string)
#
#    BranchesDico = {} #[linename, Bus name 1, Bus name 2, ID, extended bus name 1, extended bus name 2, bus number 1, bus number 2]
#    for i in range(len(iarray[0])):
#        idname = carray[4][i]
#        if '@' in idname:
#            idname = idname.replace('@','Br')
#        elif '*' in idname:
#            idname = idname.replace('*','Sw')
#        else:
#            idname = 'LI' + idname
#        linename = carray[0][i].strip() + "__" + carray[1][i].strip() + "__" + idname
#        linename = linename.replace(" ","_")
#        linename = linename.replace("-","_")
#        linename = linename.replace(".","_")
#        linename = linename.replace("&","and")
#        try:
#            int(linename[0])
#            linename = "_" + linename
#        except:
#            pass
#        if linename[-1] == '_':
#            linename = linename[:-1]
#        BranchesDico[linename] = {}
#        BranchesDico[linename]['FROMNAME'] = carray[0][i].strip()
#        BranchesDico[linename]['TONAME'] = carray[1][i].strip()
#        BranchesDico[linename]['ID'] = carray[4][i]
#        BranchesDico[linename]['FROMEXNAME'] = carray[2][i]
#        BranchesDico[linename]['TOEXNAME'] = carray[3][i]
#        BranchesDico[linename]['FROMNUMBER'] = iarray[0][i]
#        BranchesDico[linename]['TONUMBER'] = iarray[1][i]
#
#    
#    #Extract Transfos
#    sid = -1
#    owner = 1
#    ties = 1
#    flag = 6 #two-winding transfos
#    entry = 1 #each branch once, not both directions
#    string = ['FROMNUMBER','TONUMBER']
#    ierr,iarray = psspy.abrnint(sid,owner,ties,flag,entry,string)
#    string = ['FROMNAME','TONAME','FROMEXNAME','TOEXNAME','ID']
#    ierr,carray = psspy.abrnchar(sid,owner,ties,flag,entry,string)
#
#    TfoDico = {} #[linename, Bus name 1, Bus name 2, machine ID, extended bus name 1, extended bus name 2, bus number 1, bus number 2]
#    for i in range(len(iarray[0])):
#        idname = 'Tr' + carray[4][i].strip()
###        try:
###            idname = 'Tr' + str(int(carray[4][i]))
###        except:
###            idname = 'Tr' + carray[4][i]
#        tfoname = carray[0][i].strip() + "__" + carray[1][i].strip() + "__" + idname
#        tfoname = tfoname.replace(" ","_")
#        tfoname = tfoname.replace("-","_")
#        tfoname = tfoname.replace(".","_")
#        tfoname = tfoname.replace("&","and")
#        try:
#            int(tfoname[0])
#            tfoname="_" + tfoname
#        except:
#            pass
#        TfoDico[tfoname]={}
#        TfoDico[tfoname]['FROMNAME']=carray[0][i].strip()
#        TfoDico[tfoname]['TONAME']=carray[1][i].strip()
#        TfoDico[tfoname]['ID']=carray[4][i]
#        TfoDico[tfoname]['FROMEXNAME']=carray[2][i]
#        TfoDico[tfoname]['TOEXNAME']=carray[3][i]
#        TfoDico[tfoname]['FROMNUMBER']=iarray[0][i]
#        TfoDico[tfoname]['TONUMBER']=iarray[1][i]
#        TfoDico[tfoname]['#WIND']=2
#    print "Read Transfos"
#
#    #Extract 3 winding Transfos
#    sid = -1 #assume a subsystem containing all buses in working case
#    owner_3flow = 1 #1 = use bus ownership 2 = use tfo ownership
#    ties_3flow = 3 #ignored bc sid is negative. 3 = interior subsystem and subsystem tie 3 winding transformers 
#    flag=3 #all 3 winding transfo windings
#    string = ['wind1number','wind2number','wind3number']
#    ierr,iarray = psspy.awndint(sid,owner,ties,flag,entry,string)
#    string = ['wind1name','wind2name','wind3name','wind1exname','wind2exname','wind3exname','id']
#    ierr,carray = psspy.awndchar(sid,owner,ties,flag,entry,string)
#
#    #[Bus name 1, Bus name 2, Bus name 3, machine ID, extended bus name 1, extended bus name 2, extended bus name 3, bus number 1, bus number 2, bus number 3]
#    for i in range(len(iarray[0])):
#        idname = 'Tr' + carray[6][i].strip()
###        try:
###            idname = 'Tr' + str(int(carray[4][i]))
###        except:
###            idname = 'Tr' + carray[4][i]
#        tfoname = carray[0][i].strip() + "__" + carray[1][i].strip() + "__" + carray[2][i].strip() + "__" + idname
#        tfoname = tfoname.replace(" ","_")
#        tfoname = tfoname.replace("-","_")
#        tfoname = tfoname.replace(".","_")
#        tfoname = tfoname.replace("&","and")
#        try:
#            int(tfoname[0])
#            tfoname="_" + tfoname
#        except:
#            pass
#        TfoDico[tfoname]={}
#        TfoDico[tfoname]['FROMNAME']=carray[0][i].strip()
#        TfoDico[tfoname]['TONAME']=carray[1][i].strip()
#        TfoDico[tfoname]['3NAME']=carray[2][i].strip()
#        TfoDico[tfoname]['ID']=carray[6][i]
#        TfoDico[tfoname]['FROMEXNAME']=carray[3][i]
#        TfoDico[tfoname]['TOEXNAME']=carray[4][i]
#        TfoDico[tfoname]['3EXNAME']=carray[5][i]
#        TfoDico[tfoname]['FROMNUMBER']=iarray[0][i]
#        TfoDico[tfoname]['TONUMBER']=iarray[1][i]
#        TfoDico[tfoname]['3NUMBER']=iarray[2][i]
#        TfoDico[tfoname]['#WIND']=3
#    print "Read 3-Winding Transfos"
#
#    return MachineDico, LoadDico, LineDico, TfoDico, MotorDico, BusDico, BranchesDico, BusNominal
#
#
##NetworkFile = r'\\Atlas.edf.fr\co\dpit-cist-siege\Der.012\Dpt-Etudes-Reseaux.001\Outils DER - Divers (excel, codes python, etc.)\PSEN_V15\Example\Results\N_20160705_17h36m34\package0_N_20160705_17h36m34\BaseCase.sav'
##PSSE_PATH=r"C:\Program Files (x86)\PTI\PSSE33\PSSBIN"
##sys.path.append(PSSE_PATH)
##os.environ['PATH'] +=  ';' + PSSE_PATH + ';'
##getNominalkV(NetworkFile)
##updateConts()
