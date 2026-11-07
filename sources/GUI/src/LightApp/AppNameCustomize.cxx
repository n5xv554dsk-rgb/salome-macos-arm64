#include "LightApp_Msg.h"

using namespace LightApp_Msg;

bool qmTots(const QString &qmFilePath, const QString &tsFilePath) {
    QProcess process;

    QString command = "lconvert";
    QStringList arguments;
    arguments << qmFilePath;
    arguments << "-o";
    arguments << tsFilePath;
    
    process.start(command, arguments);

    process.waitForFinished();

    if (process.exitCode()== 0)
        return true;
    else
        return false;
}

bool tsToqm(const QString &tsFilePath, const QString &qmFilePath){
    QProcess process;

    QString command = "lrelease";
    QStringList arguments;
    arguments << tsFilePath;
    arguments << "-qm";
    arguments << qmFilePath;
    
    process.start(command, arguments);

    process.waitForFinished();

    if (process.exitCode()== 0)
        return true;
    else
    {
        qDebug()<< QString("Can not compile %1 to %2").arg(tsFilePath,qmFilePath);
        return false;
    }
}

bool LightApp_Msg_patching(const QString& app_name,const QString& qmFilePath)
{
    // Get SALOME_APPLICATION_DIR
    QByteArray gui_root_dir_env = qgetenv("SALOME_APPLICATION_DIR");
    if (gui_root_dir_env.isEmpty())
    {
        qCritical()<< "SALOME_APPLICATION_DIR must be defined";
        return false;
    }

    QString gui_root_dir = QString::fromUtf8(gui_root_dir_env);
    QDir gui_root_qdir(gui_root_dir);
    QString qmFilePathAbs(gui_root_qdir.filePath(qmFilePath));
    QStringList qmFilePathAbs_splited = qmFilePathAbs.split("/");
    QString tsFilePath(qmFilePathAbs_splited[qmFilePathAbs_splited.size() - 1]);
    tsFilePath.replace(".qm",".ts");

    if (qmTots(qmFilePathAbs,tsFilePath))
        qInfo() <<"qmTots OK";
    else
    {
        qDebug() <<"qmTots KO";
        return false;   
    }

    try
    {
        QFile input_tsFile(tsFilePath);
        if(!input_tsFile.open(QFile::ReadOnly | QFile::Text)) {
            qDebug() << "Could not open tsfile";
            throw;
        }
        std::unique_ptr<QList<Context>> Context_list(new QList<Context>);

        LightApp_Msg_handling LAMsg_handling(std::move(Context_list));

        LAMsg_handling.read(&input_tsFile);

        LAMsg_handling.GetContextbyName("@default")->GetMessagebySrc("APP_NAME")->Set_Translation(app_name);

        input_tsFile.close();

        // Write in tsfile
        QFile output_tsFile(tsFilePath);
        if (!output_tsFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
            qDebug() << "Cannot open file for writing.";
            throw;
        }
        QTextStream out(&output_tsFile);
        out << LAMsg_handling.write();
        output_tsFile.close();
    }
    catch(...)
    {
        qCritical() << "Something wrong with " << qmFilePathAbs;
        return false;
    }

    // write to qm file
    if (tsToqm(tsFilePath,qmFilePathAbs))
        qInfo() <<"tsToqm OK";
    else
    {
        qDebug() <<"tsToqm KO";
        return false;   
    }
    
    return true;
    
}
int main(int argc, char *argv[]) {

    if (argc < 2) {
        qDebug() << "Usage: app_name must be declared";
        return 1;
    }

    QString app_name = QString::fromUtf8(argv[1]);
    QStringList qmFilePath_list = {"share/salome/resources/gui/LightApp_msg_fr.qm",
                                    "share/salome/resources/gui/LightApp_msg_en.qm",
                                    "share/salome/resources/gui/LightApp_msg_ja.qm"};

    for (const QString& qmFilePath:qmFilePath_list)
    {
        if(!LightApp_Msg_patching(app_name,qmFilePath))
        {
            qDebug() << "LightApp_Msg_patching failed!!!!";
            return 1;
        }
    }
    return 0;

}
