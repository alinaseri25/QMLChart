import QtQuick
import QtCharts

Item {
    width: 640
    height: 480
    visible: true

    signal startStopSignal()

    CButton{
        id:startStopButton
        text: "start"

        width: 100
        height: 40

        x: (parent.width / 2) - (width / 2)
        y: 10


        onClicked: {
            startStopSignal()
        }
    }

    ChartView {
        id: chartView
        title: "Spline Chart"

        antialiasing: true
        x: 0
        y: 50
        width: parent.width
        height: parent.height - 50

        animationOptions: ChartView.NoAnimation

        // ✅ محور X را DateTime تعریف می‌کنیم
        DateTimeAxis {
            id: axisX
            format: "hh:mm:ss"          // فرمت نمایش: ساعت:دقیقه:ثانیه
            tickCount: 6                // تعداد برچسب‌ها
            titleText: "زمان"

            // محدوده زمانی اولیه (10 ثانیه گذشته تا الان)
            min: new Date(Date.now())
            max: new Date(Date.now() + 10000)  // 100 ثانیه بعد
        }

        // // تعریف محور X
        // ValueAxis {
        //     id: axisX
        //     min: 0              // حداقل مقدار
        //     max: 100            // حداکثر مقدار
        //     tickCount: 11       // تعداد tick marks (0, 10, 20, ..., 100)
        //     labelFormat: "%.0f" // فرمت نمایش اعداد (بدون اعشار)
        //     titleText: "زمان (ثانیه)"
        // }

        // تعریف محور Y
        ValueAxis {
            id: axisY
            min: -10
            max: 10
            tickCount: 5
            labelFormat: "%.1f"  // یک رقم اعشار
            titleText: "مقدار"
        }

        SplineSeries {
            id: spLine1
            name: "Spline"

            axisX: axisX
            axisY: axisY
        }

        // PinchArea و MouseArea همون‌طوری که قبلاً بود...
        PinchArea {
            id: pinchArea
            anchors.fill: parent

            property real initialXMin
            property real initialXMax
            property real initialYMin
            property real initialYMax

            onPinchStarted: {
                initialXMin = axisX.min.getTime()
                initialXMax = axisX.max.getTime()
                initialYMin = axisY.min
                initialYMax = axisY.max
            }

            onPinchUpdated: (pinch) => {
                let scale = 1.0 / pinch.scale

                // ✅ برای DateTime باید با millisecond کار کنیم
                let xRange = initialXMax - initialXMin
                let xCenter = (initialXMax + initialXMin) / 2
                axisX.min = new Date(xCenter - (xRange * scale) / 2)
                axisX.max = new Date(xCenter + (xRange * scale) / 2)

                let yRange = initialYMax - initialYMin
                let yCenter = (initialYMax + initialYMin) / 2
                axisY.min = yCenter - (yRange * scale) / 2
                axisY.max = yCenter + (yRange * scale) / 2
            }

            MouseArea {
                id: chartMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton

                property real lastX: 0
                property real lastY: 0
                property bool isPanning: false

                onWheel: (wheel) => {
                    let zoomFactor = wheel.angleDelta.y > 0 ? 0.9 : 1.1

                    // ✅ Zoom برای محور DateTime
                    let xRange = axisX.max.getTime() - axisX.min.getTime()
                    let xCenter = (axisX.max.getTime() + axisX.min.getTime()) / 2
                    axisX.min = new Date(xCenter - (xRange * zoomFactor) / 2)
                    axisX.max = new Date(xCenter + (xRange * zoomFactor) / 2)

                    let yRange = axisY.max - axisY.min
                    let yCenter = (axisY.max + axisY.min) / 2
                    axisY.min = yCenter - (yRange * zoomFactor) / 2
                    axisY.max = yCenter + (yRange * zoomFactor) / 2
                }

                onPressed: (mouse) => {
                    isPanning = true
                    lastX = mouse.x
                    lastY = mouse.y
                }

                onPositionChanged: (mouse) => {
                    if (isPanning) {
                        let dx = mouse.x - lastX
                        let dy = mouse.y - lastY

                        // ✅ Pan برای محور DateTime
                        let xRange = axisX.max.getTime() - axisX.min.getTime()
                        let yRange = axisY.max - axisY.min

                        let xShift = -(dx / chartView.plotArea.width) * xRange
                        let yShift = (dy / chartView.plotArea.height) * yRange

                        axisX.min = new Date(axisX.min.getTime() + xShift)
                        axisX.max = new Date(axisX.max.getTime() + xShift)
                        axisY.min += yShift
                        axisY.max += yShift

                        lastX = mouse.x
                        lastY = mouse.y
                    }
                }

                onReleased: {
                    isPanning = false
                }

                onDoubleClicked: {
                    // Reset به 10 ثانیه گذشته
                    axisX.min = new Date(Date.now() - 10000)
                    axisX.max = new Date(Date.now())
                    axisY.min = -10
                    axisY.max = 10
                }
            }
        }
    }

    Component.onCompleted: {
        startStopSignal.connect(myBackend.onStartStopPressed)
    }

    Connections{
        target: myBackend

        function onStateChanged(state){
            if(state)
            {
                startStopButton.text = "stop"
                // محدوده زمانی اولیه (10 ثانیه گذشته تا الان)
                axisX.min = new Date(Date.now())
                axisX.max =  new Date(Date.now() + 10000)  // 100 ثانیه بعد
            }
            else
            {
                startStopButton.text = "start"
            }
        }

        function onDataChanged(dataPoints)
        {
            spLine1.append(dataPoints[dataPoints.length - 1].x,dataPoints[dataPoints.length - 1].y)

            if(dataPoints[dataPoints.length - 1].x > 100)
            {
                axisX.min = dataPoints[dataPoints.length - 1].x - 99
                axisX.max = dataPoints[dataPoints.length - 1].x + 1
            }
        }

        function onNewPoint(dataPoint){
            let dateTime = new Date(dataPoint.x)
            spLine1.append(dateTime,dataPoint.y)

            // ✅ Auto-scroll: وقتی از محدوده خارج شد، محور رو shift بده
            if (dateTime.getTime() > axisX.max.getTime()) {
                let range = axisX.max.getTime() - axisX.min.getTime()
                axisX.min = new Date(dateTime.getTime() - range + 1000)
                axisX.max = new Date(dateTime.getTime() + 1000)
            }

        }
    }
}
