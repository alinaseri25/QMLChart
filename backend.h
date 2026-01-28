#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QTimer>
#include <QPointF>
#include <QRandomGenerator>
#include <QDebug>

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);

private:
    QTimer *seriesTimer;
    QList<QPointF> dataList;
    int xCounter;

private slots:
    void onSeriesTimerTimeout(void);

public slots:
    void onStartStopPressed(void);

signals:
    void stateChanged(bool state);
    void dataChanged(QList<QPointF> dataPoints);
};

#endif // BACKEND_H
