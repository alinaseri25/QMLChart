#include "backend.h"

Backend::Backend(QObject *parent)
    : QObject{parent}
{
    seriesTimer = new QTimer(this);
    connect(seriesTimer,&QTimer::timeout,this,&Backend::onSeriesTimerTimeout);
    seriesTimer->stop();
    xCounter = 0;
}

void Backend::onSeriesTimerTimeout()
{
    QPointF point;
    point.setX(QDateTime::currentDateTime().toMSecsSinceEpoch());
    point.setY(QRandomGenerator::global()->bounded(-10,10));
    dataList.append(point);
    //emit dataChanged(dataList);
    emit newPoint(point);
    xCounter++;
}

void Backend::onStartStopPressed()
{
    if(seriesTimer->isActive())
    {
        seriesTimer->stop();
    }
    else
    {
        seriesTimer->start(100);
    }
    emit stateChanged(seriesTimer->isActive());
    //qDebug() << QString("Pressed");
}
