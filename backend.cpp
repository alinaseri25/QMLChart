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
    QPointF point1,point2;
    point1.setX(QDateTime::currentMSecsSinceEpoch());
    point2.setX(point1.x());
    point1.setY(QRandomGenerator::global()->bounded(-10,10));
    point2.setY(QRandomGenerator::global()->bounded(40,50));
    dataList.append(point1);
    //emit dataChanged(dataList);
    emit newPoint(point1,point2);
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
