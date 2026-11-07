#include "SalomeApprc_utils.h"

QDir salomeappdir(getenv("SALOME_APPLICATION_DIR"));
SUIT_ResourceMgr ResMgr("SalomeApp");

int main(int argc, char** argv)
{
    QString salome_version;
    if (QString::compare(salomeappdir.dirName(), ".") == 0)
    {
        qWarning() << "SALOME_APPLICATION_DIR must not be empty!!";
        return 1;
    }
    if (argc >2)
    {
        qWarning() << "Too many arguments!! This function accept only one arg for the version name";
        return 1;
    }
    else if (argc < 2)
    {
        qInfo() << "Enter the salome version:";
        bool ok_input = false;
        while(!ok_input)
        {
            QTextStream in (stdin);
            salome_version = in.readLine();
            if (!salome_version.contains(" "))
                ok_input = true;
            else
                qWarning() << "The version string must not contain a blank space. Please re-enter the salome version"; 
        }
    }
    else
    {
        salome_version = (QString)argv[1];
    }

    QApplication app(argc, argv);
    app.setOrganizationName("salome");
    ResMgr.setVersion(salome_version);
    
    QString salomemodules(getenv("SALOME_MODULES"));
    if(salomemodules.isEmpty())
        AddComponents_from_salomeappdir();
    else
        AddComponents_from_salomemodules(salomemodules);
    ResMgr.setCurrentFormat("xml");
    ResMgr.save();
    return 0;
}
