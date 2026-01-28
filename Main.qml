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

        // تعریف محور X
        ValueAxis {
            id: axisX
            min: 0              // حداقل مقدار
            max: 100            // حداکثر مقدار
            tickCount: 11       // تعداد tick marks (0, 10, 20, ..., 100)
            labelFormat: "%.0f" // فرمت نمایش اعداد (بدون اعشار)
            titleText: "زمان (ثانیه)"
        }

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

        // ✅ برای حرکات چند لمسی (Pinch to Zoom)
        PinchArea {
            id: pinchArea
            anchors.fill: parent

            property real initialXMin
            property real initialXMax
            property real initialYMin
            property real initialYMax

            onPinchStarted: {
                initialXMin = axisX.min
                initialXMax = axisX.max
                initialYMin = axisY.min
                initialYMax = axisY.max
            }

            onPinchUpdated: (pinch) => {
                // محاسبه zoom factor از مقیاس pinch
                let scale = 1.0 / pinch.scale

                let xRange = initialXMax - initialXMin
                let xCenter = (initialXMax + initialXMin) / 2
                axisX.min = xCenter - (xRange * scale) / 2
                axisX.max = xCenter + (xRange * scale) / 2

                let yRange = initialYMax - initialYMin
                let yCenter = (initialYMax + initialYMin) / 2
                axisY.min = yCenter - (yRange * scale) / 2
                axisY.max = yCenter + (yRange * scale) / 2
            }

            // ✅ MouseArea داخل PinchArea برای Pan
            MouseArea {
                id: chartMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton

                property real lastX: 0
                property real lastY: 0
                property bool isPanning: false

                // ✅ Mouse wheel برای Desktop
                onWheel: (wheel) => {
                    let zoomFactor = wheel.angleDelta.y > 0 ? 0.9 : 1.1

                    let xRange = axisX.max - axisX.min
                    let xCenter = (axisX.max + axisX.min) / 2
                    axisX.min = xCenter - (xRange * zoomFactor) / 2
                    axisX.max = xCenter + (xRange * zoomFactor) / 2

                    let yRange = axisY.max - axisY.min
                    let yCenter = (axisY.max + axisY.min) / 2
                    axisY.min = yCenter - (yRange * zoomFactor) / 2
                    axisY.max = yCenter + (yRange * zoomFactor) / 2
                }

                // ✅ Pan برای هم Desktop و هم Touch
                onPressed: (mouse) => {
                    isPanning = true
                    lastX = mouse.x
                    lastY = mouse.y
                }

                onPositionChanged: (mouse) => {
                    if (isPanning) {
                        let dx = mouse.x - lastX
                        let dy = mouse.y - lastY

                        let xRange = axisX.max - axisX.min
                        let yRange = axisY.max - axisY.min

                        let xShift = -(dx / chartView.plotArea.width) * xRange
                        let yShift = (dy / chartView.plotArea.height) * yRange

                        axisX.min += xShift
                        axisX.max += xShift
                        axisY.min += yShift
                        axisY.max += yShift

                        lastX = mouse.x
                        lastY = mouse.y
                    }
                }

                onReleased: {
                    isPanning = false
                }

                // ✅ Double tap برای Reset
                onDoubleClicked: {
                    axisX.min = 0
                    axisX.max = 100
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
    }
}
