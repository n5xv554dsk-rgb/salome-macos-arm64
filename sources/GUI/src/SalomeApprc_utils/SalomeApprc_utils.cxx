#include "SalomeApprc_utils.h"

#include <iostream>
void UpdateCompInfo_with_salomeappdir(const QDir& salomeappdir, SUIT_ResourceMgr* ResMgr)
{
	// Remove module list and  module_root_dirs list
	ResMgr->remove("launch", "user_modules");
	ResMgr->remove("user_modules");

    QString mod_order = getenv("SOD_MODULE_ORDER");
    QStringList ordered_guimod_list ;
    QStringList guimod_list ;
    if ( !mod_order.isEmpty() ){
      ordered_guimod_list = mod_order.split(",", QString::SkipEmptyParts);
    }

	QFileInfoList salomexd_list = QDir(salomeappdir.path() + DFILES_DIR).entryInfoList(QStringList() << "*.salomexd",QDir::Files);
	foreach(QFileInfo filename, salomexd_list)
    {
		QFile file( filename.filePath() );
        if ( !file.open( QFile::ReadOnly ) )
        {
            qWarning() << "file " << filename.fileName() << " is not accessible";
            continue;
        }

        QJsonDocument document = QJsonDocument::fromJson( file.readAll() );
        if ( document.isNull() )
        {
            qWarning() << "invalid json file. Filename: " << filename.fileName();
            continue;
        }
        QJsonObject salomexd_dict = document.object();

		QJsonValue salomegui = salomexd_dict.value(SALOMEGUI_KEY);

		if (salomegui.isBool() && salomegui.toBool())
		{
			QJsonValue salomemodule_name = salomexd_dict.value( SALOMEMODULENAME_KEY );

			QString modname;
			if (salomemodule_name.isString() && !salomemodule_name.toString().isEmpty())
			{
				modname = salomemodule_name.toString();
			}
			else
			{
				modname = salomexd_dict.value(EXTNAME_KEY).toString();
				qDebug() << "extension name is used as salome module name";
			}
			qInfo() << "add module ======================" << modname;
			guimod_list.append(modname);
		}
    }
	if (!guimod_list.isEmpty()){
		QString root(salomeappdir.path() + "/__SALOME_EXT__");
		foreach(QString modname, ordered_guimod_list){
			if (guimod_list.contains(modname)){
				AddGuiComponent(modname, root, ResMgr);
				guimod_list.removeAll(modname);
			}
		}
		foreach(QString modname, guimod_list){
			AddGuiComponent(modname, root, ResMgr);
		}
	}
}

void UpdateCompInfo_with_salomemodules(const QString& salomemodules, const QDir& salomeappdir, SUIT_ResourceMgr* ResMgr)
{
	// Remove module list and  module_root_dirs list
	ResMgr->remove("launch", "user_modules");
	ResMgr->remove("user_modules");

	QRegularExpression sep(":|,");
	QStringList components_list = salomemodules.split(sep,QString::SkipEmptyParts);
	foreach (QString comp, components_list)
	{
		QString comp_root_dir = Qtx::getenv(comp + "_ROOT_DIR");

		qWarning() << comp;
		qWarning() << comp_root_dir;
		if (comp_root_dir.isEmpty())
			comp_root_dir = salomeappdir.path() + "/__SALOME_EXT__";
		AddGuiComponent(comp, comp_root_dir, ResMgr);
	}

}
void AddGuiComponent(const QString& comp, const QString& CompRoot, SUIT_ResourceMgr* ResMgr)
{
	QStringList CompsResMgr = ResMgr->stringValue("launch", "user_modules").split(";", QString::SkipEmptyParts);
	ResMgr->setValue( "user_modules", comp, CompRoot );

	CompsResMgr << comp;
	CompsResMgr.removeDuplicates();
    ResMgr->setValue( "launch", "user_modules", CompsResMgr.join( ";" ) );
}