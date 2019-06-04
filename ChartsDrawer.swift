
import UIKit
import Foundation
import Charts

class ChartsDrawer {
    
    /// These are the colors used to draw charts.
    private static let Colors = [
    NSUIColor(displayP3Red: CGFloat(57.0 / 255.0), green: CGFloat(106.0 / 255.0), blue: CGFloat(177.0 / 255.0), alpha: CGFloat(1)),
    NSUIColor(red: CGFloat(204.0 / 255.0), green: CGFloat(37.0 / 255.0), blue: CGFloat(41.0 / 255.0), alpha: CGFloat(1)),
    NSUIColor(red: CGFloat(62.0 / 255.0), green: CGFloat(150.0 / 255.0), blue: CGFloat(81.0 / 255.0), alpha: CGFloat(1)),
    NSUIColor(red: CGFloat(218.0 / 255.0), green: CGFloat(124.0 / 255.0), blue: CGFloat(48.0 / 255.0), alpha: CGFloat(1))
    ]
    
    /// Draws a pie chart on the given PieChartView, with the given PieChartDataSet. By default, the pie chart can be rotated by the user.
    ///
    /// - parameter dataSet: The dataset to draw.
    /// - parameter view: The view on which to draw the data.
    ///
    /// - returns: Void
    static func DrawPieChart(dataSet: PieChartDataSet, view: PieChartView) {
        view.chartDescription?.enabled = false
        view.rotationAngle = 0
        view.highlightPerTapEnabled = false
        view.legend.enabled = false
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        formatter.percentSymbol = "h"
        formatter.zeroSymbol = "0"
        
        dataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
        
        dataSet.colors = Colors
        view.data = PieChartData(dataSet: dataSet)
    }
    
    /// Draws a pie static chart on the given PieChartView, with the given PieChartDataSet. The user can not interact with this pie chart.
    ///
    /// - parameter dataSet: The dataset to draw.
    /// - parameter view: The view on which to draw the data.
    ///
    /// - returns: Void
    static func DrawStaticPieChart(dataSet: PieChartDataSet, view: PieChartView) {
        view.rotationEnabled = false
        view.isUserInteractionEnabled = false
        view.drawHoleEnabled = false
        DrawPieChart(dataSet: dataSet, view: view)
    }
}
