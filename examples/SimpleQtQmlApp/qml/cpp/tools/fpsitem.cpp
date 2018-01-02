#include <QDateTime>
#include <QPainter>

#include "fpsitem.h"

FpsItem::FpsItem(QQuickPaintedItem *parent):
    QQuickPaintedItem(parent),
    m_fps(0),
    m_cacheCount(0)
{
    m_times.clear();
    setFlag(QQuickItem::ItemHasContents);
}

FpsItem::~FpsItem()
{
}

int FpsItem::fps() const
{
    return m_fps;
}

void FpsItem::recalculateFPS()
{
    qint64 currentTime = QDateTime::currentDateTime().toMSecsSinceEpoch();
    m_times.push_back(currentTime);

    while (m_times[0] < currentTime - 1000) {
        m_times.pop_front();
    }

    int currentCount = m_times.length();
    m_fps = (currentCount + m_cacheCount) / 2;

    if (currentCount != m_cacheCount) fpsChanged(m_fps);

    m_cacheCount = currentCount;
}

void FpsItem::paint(QPainter *painter)
{
    recalculateFPS();
    QBrush brush(Qt::transparent);

    painter->setBrush(brush);
    painter->setPen(Qt::NoPen);
    painter->setRenderHint(QPainter::Antialiasing);
    painter->drawRoundedRect(0, 0, boundingRect().width(), boundingRect().height(), 0, 0);
    update();
}
