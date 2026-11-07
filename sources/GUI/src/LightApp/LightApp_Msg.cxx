#include "LightApp_Msg.h"

using namespace LightApp_Msg;

QString Context::ExportContext()
{
    QString context_string;
    context_string.append(QString("<context>\n"));
    context_string.append(QString("<name>%1</name>\n").arg(Context_name));
    foreach (const Message& msg, Message_list)
        {
            context_string.append(QString("<message>\n<source>%1</source>\n<translation>%2</translation>\n</message>\n").arg(msg.GetSource(),msg.GetTranslation()));
        }
    context_string.append(QString("</context>\n"));
    
    return context_string;
}

Message* Context::GetMessagebySrc(const QString& src)
{
    uint i(0);
    while(i < Message_list.size() && Message_list[i].GetSource() != src)
        i++;
    if (i < Message_list.size())
        return &Message_list[i];
}



Context* LightApp_Msg_handling::GetContextbyName(const QString& name)
{
    int i(0);
    while(i < Context_list->size() && (*Context_list)[i].GetContext_name() != name)
        i++;
    if (i < Context_list->size())
        return &(*Context_list)[i];
    else
    {
        qDebug()<<"Context with name " << name << " doesn't exist in LightApp_Msg_handling";
        return nullptr;
    }
}

bool LightApp_Msg_handling::HaveContext(const QString& name)
{
    int i(0);
    while(i < Context_list->size() && (*Context_list)[i].GetContext_name() != name)
        i++;
    if (i < Context_list->size())
        return true;
    else
        return false;
}

QString LightApp_Msg_handling::write()
{
    QString updateXml;
    updateXml.append(header);
    for(auto ct:*Context_list)
        updateXml.append(ct.ExportContext());
    updateXml.append("</TS>");

    return updateXml;

}
void LightApp_Msg_handling::read(QIODevice *device)
{

    //header
    QTextStream textStream(device);
    // Read 3 first header line of ts file
    for (int i = 0; i < 3 && !textStream.atEnd(); ++i) {
        header.append(textStream.readLine() + "\n");
    }
    device->seek(0);
    
    //context
    xmlReader.setDevice(device);
    //CustomEntityResolver resolver;
    //xmlReader.setEntityResolver(&resolver);

    while(xmlReader.readNextStartElement()){
        if(xmlReader.name().toString() == "context")
            readContext();
    }

}

void LightApp_Msg_handling::readContext()
{
    Q_ASSERT(xmlReader.isStartElement() &&
             xmlReader.name() == "context");

    while(xmlReader.readNextStartElement()){
        if(xmlReader.name() == "name")
        {
            QString name = xmlReader.readElementText();
            if (!HaveContext(name))
                Context_list->append(Context(name));
            else
                qWarning()<<"Context with name " << name << " is already appended in LightApp_Msg_handling";
        }
        else if (xmlReader.name() == "message")
        {
            readMessage();
        }
        else
            xmlReader.skipCurrentElement();
    }
}

void LightApp_Msg_handling::readMessage()
{
    Q_ASSERT(xmlReader.isStartElement() &&
             xmlReader.name() == "message");
    Message msg = Message("","");
    Message& msg_ref = msg;
    while(xmlReader.readNextStartElement()){
        if(xmlReader.name() == "source")
            readSrc(msg_ref);
        else if(xmlReader.name() == "translation")
            readTranslation(msg_ref);
        else
            xmlReader.skipCurrentElement();
        
    }
    
    (*Context_list)[Context_list->size() - 1].AddMsg(msg);
}

void LightApp_Msg_handling::readSrc(Message& msg)
{
    Q_ASSERT(xmlReader.isStartElement() &&
             xmlReader.name() == "source");
    QString src = xmlReader.readElementText();

    msg.Set_Source(src);
}

void LightApp_Msg_handling::readTranslation(Message& msg)
{
    Q_ASSERT(xmlReader.isStartElement() &&
             xmlReader.name() == "translation");

    QString trl = xmlReader.readElementText();
    trl.replace("&","&amp;");
    trl.replace("\"","&quot;");
    trl.replace("\'","&apos;");
    trl.replace("<","&lt;");
    trl.replace(">","&gt;");
    msg.Set_Translation(trl);
}
