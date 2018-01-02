#ifndef FPSITEM_H
#define FPSITEM_H

#include <QQuickPaintedItem>

class FpsItem : public QQuickPaintedItem
{
    Q_OBJECT
    Q_DISABLE_COPY(FpsItem)

    Q_PROPERTY(int fps READ fps NOTIFY fpsChanged)

    void recalculateFPS();

    int m_fps;
    int m_cacheCount;
    QVector<qint64> m_times;

public:
    FpsItem(QQuickPaintedItem *parent = 0);
    ~FpsItem();

    virtual void paint(QPainter *);

    int fps() const;

signals:
    void fpsChanged(int fps);

};

#endif // FPSITEM_H
