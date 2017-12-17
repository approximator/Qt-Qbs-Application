#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QDir>
#include <QDebug>

int main(int argc, char *argv[])
{
#ifdef APP_PLUGINS_PATH
    // Add path to search for Qt plugins
    QString pluginsPaths = QString("%1/%2").arg(QFileInfo(argv[0]).dir().path(), APP_PLUGINS_PATH);
    QCoreApplication::addLibraryPath(pluginsPaths);
#endif

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QString qmlFilesPath = QString("%1/%2").arg(QCoreApplication::applicationDirPath(),
                                                APP_QML_MODULES_PATH);
    engine.addImportPath(QDir::toNativeSeparators(QDir::cleanPath(qmlFilesPath)));
    qDebug() << "qmlFilesPath = " << qmlFilesPath;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
