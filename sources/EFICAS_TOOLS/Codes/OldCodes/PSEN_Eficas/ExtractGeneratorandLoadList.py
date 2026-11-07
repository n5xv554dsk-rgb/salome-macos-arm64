NetworkFile = r"C:\Users\J15773\Documents\GTDosier\PSENdocs\Victoria ALL - EFICAS PSEN\Data\2030Conv_HFP2.sav"
PSSE_PATH = "C:/Program Files/PTI/PSSE33/PSSBIN" #emplacement de PSSE

def ExtractGeneratorandLoadList(NetworkFile,PSSE_PATH):

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

    LoadList = []  # [Bus name, load ID, extended bus name, bus number]
    for i in range(len(iarray[0])):
        LoadList.append([carray[0][i].strip(),carray[1][i],carray[2][i],iarray[0][i]])

    #Extract Generators
    sid = -1 #all buses
    flag = 1 #all in service loads/generators (4 all loads/generators)
        
    string = ['NUMBER']
    ierr,iarray = psspy.amachint(sid,flag,string)

    string = ['NAME','ID','EXNAME']
    ierr,carray = psspy.amachchar(sid,flag,string)

    MachineList = [] # [Bus name, machine ID, extended bus name, bus number]
    for i in range(len(iarray[0])):
        MachineList.append([carray[0][i].strip(),carray[1][i],carray[2][i],iarray[0][i]])

    return MachineList, LoadList
                                
def ExtractGeneratorandLoadList2(NetworkFile,PSSE_PATH):
    MachineList = [['GT 6', '1 ', 'GT 6        11.500', 10], ['GT 7', '1 ', 'GT 7        11.500', 11], ['GT10', '1 ', 'GT10        11.500', 12], ['GT 5', '1 ', 'GT 5        11.500', 13], ['NEWHUNT', '1 ', 'NEWHUNT     11.500', 15], ['BSTMB', '1 ', 'BSTMB       11.500', 23], ['HYD_MAG', '1 ', 'HYD_MAG     6.9000', 25], ['RF1', '1 ', 'RF1         13.800', 37], ['OH2', '1 ', 'OH2         13.800', 41], ['RF2', '1 ', 'RF2         13.800', 42], ['GT3', '1 ', 'GT3         11.500', 43], ['OH3', '1 ', 'OH3         13.800', 47], ['OH4', '1 ', 'OH4         13.800', 50], ['OH6', '1 ', 'OH6         13.800', 52], ['GT 11', '1 ', 'GT 11       11.500', 56], ['B6_BUS13', '1 ', 'B6_BUS13    13.800', 57], ['GT8', '1 ', 'GT8         11.500', 58], ['HYDRR', '1 ', 'HYDRR       6.9000', 59], ['GT9', '1 ', 'GT9         11.500', 63], ['HYD_UWR', '1 ', 'HYD_UWR     6.9000', 64], ['HYD_RIOB', '1 ', 'HYD_RIOB    6.9000', 65], ['HRYD_LW', '1 ', 'HRYD_LW     6.9000', 68], ['GT13B', '1 ', 'GT13B       11.500', 76], ['GT12B', '1 ', 'GT12B       11.500', 77], ['CSPRING', '1 ', 'CSPRING     69.000', 91], ['OLDHARB1', '1 ', 'OLDHARB1    138.00', 114], ['WIGTON', '1 ', 'WIGTON      0.6900', 202], ['JEPWK1', '1 ', 'JEPWK1      11.500', 300], ['JEPWK1', '2 ', 'JEPWK1      11.500', 300], ['JEPWK1', '3 ', 'JEPWK1      11.500', 300], ['JEPWK2', '1 ', 'JEPWK2      11.500', 301], ['JEPWK2', '2 ', 'JEPWK2      11.500', 301], ['JEPWK2', '3 ', 'JEPWK2      11.500', 301], ['W_MUN1', '1 ', 'W_MUN1      69.000', 503], ['HYD_RHORN', '1 ', 'HYD_RHORN   69.000', 711]]

    LoadList= [['TREDEGAR', '1 ', 'TREDEGAR    69.000', 5], ['HOPE', '1 ', 'HOPE        69.000', 16], ['MILCHELT', '1 ', 'MILCHELT    69.000', 17], ['PARADISE', '1 ', 'PARADISE    69.000', 24], ['BLEDGE', '1 ', 'BLEDGE      69.000', 26], ['CANE RIV', '1 ', 'CANE RIV    69.000', 27], ['HIGHGATE', '1 ', 'HIGHGATE    69.000', 29], ['QUEENS D', '1 ', 'QUEENS D    69.000', 30], ['OCHO', '1 ', 'OCHO        69.000', 32], ['BOGUE_69', '1 ', 'BOGUE_69    69.000', 33], ['ROSE HAL', '1 ', 'ROSE HAL    69.000', 35], ['OH1', '1 ', 'OH1         13.800', 36], ['RF1', '1 ', 'RF1         13.800', 37], ['CEMENT C', '1 ', 'CEMENT C    69.000', 38], ['OBAY69', '1 ', 'OBAY69      69.000', 39], ['DUNCANS6', '1 ', 'DUNCANS6    69.000', 40], ['OH2', '1 ', 'OH2         13.800', 41], ['RF2', '1 ', 'RF2         13.800', 42], ['3MLS69', '1 ', '3MLS69      69.000', 45], ['WBLVD69', '1 ', 'WBLVD69     69.000', 46], ['OH3', '1 ', 'OH3         13.800', 47], ['PORT ANT', '1 ', 'PORT ANT    69.000', 48], ['OH4', '1 ', 'OH4         13.800', 50], ['B6_BUS13', '1 ', 'B6_BUS13    13.800', 57], ['GREENWOO', '1 ', 'GREENWOO    69.000', 60], ['LYSSONS', '1 ', 'LYSSONS     69.000', 61], ['PORUS', '1 ', 'PORUS       69.000', 62], ['R RIVER', '1 ', 'R RIVER     69.000', 66], ['MARTHA B', '1 ', 'MARTHA B    69.000', 67], ['WKH69', '1 ', 'WKH69       69.000', 69], ['PNASUS69', '1 ', 'PNASUS69    69.000', 70], ['ANNOTTO', '1 ', 'ANNOTTO     69.000', 71], ['UW RIVER', '1 ', 'UW RIVER    69.000', 74], ['KNDAL 69', '1 ', 'KNDAL 69    69.000', 75], ['MONYMUSK', '1 ', 'MONYMUSK    69.000', 78], ['OROCABES', '1 ', 'OROCABES    69.000', 79], ['MAGGOTTY', '1 ', 'MAGGOTTY    69.000', 80], ['UP PARK', '1 ', 'UP PARK     69.000', 82], ['TWICKENH', '1 ', 'TWICKENH    69.000', 85], ['MAY PEN', '1 ', 'MAY PEN     69.000', 88], ['PAJ', '1 ', 'PAJ         69.000', 89], ['GROAD_69', '1 ', 'GROAD_69    69.000', 90], ['CSPRING', '1 ', 'CSPRING     69.000', 91], ['S_ TREE6', '1 ', 'S_ TREE6    69.000', 92], ['NAGGOS H', '1 ', 'NAGGOS H    69.000', 94], ['GOODYEAR', '1 ', 'GOODYEAR    69.000', 99], ['HBAY_69', '1 ', 'HBAY_69     69.000', 101], ['RFORT69', '1 ', 'RFORT69     69.000', 102], ['RHODEN P', '1 ', 'RHODEN P    69.000', 105], ['DUHANEY6', '1 ', 'DUHANEY6    69.000', 107], ['CARDIFF', '1 ', 'CARDIFF     69.000', 109], ['JAB13.8', '1 ', 'JAB13.8     13.800', 112], ['JAM13.8', '1 ', 'JAM13.8     13.800', 113]]
    return MachineList, LoadList

if __name__ == "__main__":
   MachineList,LoadList= ExtractGeneratorandLoadList2(NetworkFile,PSSE_PATH)
   print MachineList, LoadList
