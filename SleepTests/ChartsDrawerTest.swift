//
//  ChartsDrawerTest.swift
//  SleepTests
//
//  Created by Brian Peter Olesen on 03/05/2019.
//  Copyright © 2019 Brian Peter Olesen. All rights reserved.
//

import XCTest
@testable import Sleep
import Charts

class ChartsDrawerTest: XCTestCase {

    var pieView : PieChartView = PieChartView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var data : PieChartDataSet = PieChartDataSet(entries: [
        PieChartDataEntry(value: 7.5),
        PieChartDataEntry(value: 0.5),
        PieChartDataEntry(value: 8),
        PieChartDataEntry(value: 8)
        ], label: "Test data set")
    
    override func setUp() {
        pieView = PieChartView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        data = PieChartDataSet(entries: [
        PieChartDataEntry(value: 7.5),
        PieChartDataEntry(value: 0.5),
        PieChartDataEntry(value: 8),
        PieChartDataEntry(value: 8)
        ], label: "Test data set")
    }

    func testDrawPieChartSetsPropertiesCorrectly() {
        ChartsDrawer.DrawPieChart(dataSet: data, view: pieView)
        XCTAssert(pieView.chartDescription?.enabled == false)
        XCTAssert(pieView.rotationAngle == 0)
        XCTAssert(pieView.highlightPerTapEnabled == false)
        XCTAssert(pieView.legend.enabled == false)
        XCTAssert(pieView.rotationEnabled == true)
        XCTAssert(pieView.isUserInteractionEnabled == true)
        XCTAssert(pieView.drawHoleEnabled == true)
    }
    
    func testDrawStaticPieChartSetsPropertiesCorrectly() {
        ChartsDrawer.DrawStaticPieChart(dataSet: data, view: pieView)
        XCTAssert(pieView.chartDescription?.enabled == false)
        XCTAssert(pieView.rotationAngle == 0)
        XCTAssert(pieView.highlightPerTapEnabled == false)
        XCTAssert(pieView.legend.enabled == false)
        XCTAssert(pieView.rotationEnabled == false)
        XCTAssert(pieView.isUserInteractionEnabled == false)
        XCTAssert(pieView.drawHoleEnabled == false)
    }
}
