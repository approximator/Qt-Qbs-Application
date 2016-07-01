#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QDir>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QString qmlFilesPath = QString("%1/%2").arg(QCoreApplication::applicationDirPath(),
                                                APP_QML_MODULES_PATH);
    engine.addImportPath(QDir::toNativeSeparators(QDir::cleanPath(qmlFilesPath)));
    qDebug() << "qmlFilesPath = " << engine.importPathList();
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
