#include <QTextStream>
#include <QBuffer>
#include <QString>
#include <QXmlStreamReader>
#include <QDebug>
#include <QTranslator>
#include <QFile>
#include <QCoreApplication>
#include <QProcess>
#include <QDir>
#include <memory>

namespace LightApp_Msg
{

class Message
{
    public:
        Message(const QString& src, const QString& trl):source(src),translation(trl){};
        QString GetSource() const { return source ;}
        QString GetTranslation() const { return translation ;}
        void Set_Source(const QString& str) { source = str; }
        void Set_Translation(const QString& str) { translation = str; }
    private:
        QString source;
        QString translation;
};

class Context
{
    public:
        Context(const QString& name):Context_name(name){};
        QString GetContext_name(){return Context_name;}
        void AddMsg(Message& msg) {Message_list.append(msg);}
        void AddMsg(const QString& src, const QString& trl) {Message_list.append(Message(src,trl));}
        Message* GetMessagebySrc(const QString&);
        QList<Message>& GetMessageList(){return Message_list;}
        QString ExportContext();
    private:
        QString Context_name;
        QList<Message> Message_list;
};

class LightApp_Msg_handling
{
public:
    LightApp_Msg_handling(std::unique_ptr<QList<Context>> Context_list):
                                            Context_list(std::move(Context_list)){};
    void read(QIODevice *device);
    QString write();
    Context* GetContextbyName(const QString &name);
    bool HaveContext(const QString &name);
private:
    QXmlStreamReader xmlReader;
    std::unique_ptr<QList<Context>> Context_list;
    QString header;

    void readContext();
    void readMessage();
    void readSrc(Message& msg);
    void readTranslation(Message& msg);
};

}
