def prepareRunCarmel(repertoireExe,repertoireMed,nom):
    texte=  'echo "Debut execution gendof" \n'
    texte+= 'cd ' + repertoireMed + ' \n'
    texte+= repertoireExe+"/gendof.exe -scale 0.001 < " + nom + ".ingendof\n"
    texte+=  'echo "Debut execution fcarmel" \n'
    #texte+= repertoireExe+"/gendof.exe -scale 0.001 \n"
    #texte+= 'if [ ! -f "'+nom+'.car" ]\n' 
    #texte+= 'then\n    exit(1)\nfi \n\n'
    texte+= repertoireExe+"/fcarmel.exe <  " + nom + ".infcarmel\n"
    #texte+= repertoireExe+"/fcarmel.exe \n"
    #texte+= 'if [ ! -f "'+nom+'.xmat" ]\n' 
    #texte+= 'then\n    exit(1)\nfi \n\n'
    texte+= 'echo "Debut execution postprocess" \n'
    texte+= repertoireExe+"/postprocess.exe < " + nom + ".inpostprocess\n"
    texte+= 'read a' 
    #texte+= repertoireExe+"/postprocess.exe"

    return texte

if __name__ == "__main__":
    repertoire="/home/A96028/ExecCarmel/Compil"
    nom="lance/Domaine"
    print prepareRunCarmel(repertoire,nom)

