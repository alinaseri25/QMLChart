#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QQmlContext>
#include "backend.h"

int main(int argc, char *argv[])
{
    // Qt Charts uses Qt Graphics View Framework for drawing, therefore QApplication must be used.
    QApplication app(argc, argv);

    Backend *myBackend = new Backend(&app);

    QQuickView viewer;
    //viewer.setMinimumSize({600, 400});
    viewer.rootContext()->setContextProperty("myBackend",myBackend);

    // The following are needed to make examples run without having to install the module
    // in desktop environments.
#ifdef Q_OS_WIN
    QString extraImportPath(QStringLiteral("%1/../../../../%2"));
#else
    QString extraImportPath(QStringLiteral("%1/../../../%2"));
#endif
    viewer.engine()->addImportPath(extraImportPath.arg(QGuiApplication::applicationDirPath(),
                                                       QString::fromLatin1("qml")));
    QObject::connect(viewer.engine(), &QQmlEngine::quit, &viewer, &QWindow::close);

    viewer.setTitle(QStringLiteral("Qt Charts QML Example Gallery"));
    viewer.setSource(QUrl("qrc:/Main.qml"));
    viewer.setResizeMode(QQuickView::SizeRootObjectToView);
    viewer.show();

    return app.exec();
}
