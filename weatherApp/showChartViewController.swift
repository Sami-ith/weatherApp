//
//  showChartViewController.swift
//  weatherApp
//
//  Created by Samieh Sadeghi on 2020-02-24.
//  Copyright © 2020 Samieh Sadeghi. All rights reserved.
//

import UIKit
import Charts

class showChartViewController: UIViewController {
    let defaults = UserDefaults.standard
    var selectedCity:[String]=[]
    var cityTemp:[Double]=[]//[1.1,2.2,3.3,4.4]
    var temp:Double = 0.0
    
    @IBOutlet var barChartView: BarChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
           
        selectedCity=defaults.stringArray(forKey: "selectedCity") ?? [String]()
        cityTemp=defaults.array(forKey: "cityTemp") as! [Double]
//       let vc=ViewController()
//        for i in 0..<selectedCity.count {
//            vc.getWeatherData(_stringCity: selectedCity[i]) { (dbl1, Str1, Str2, Str3, dbl2, dbl3, dbl4, dbl5) in
//                print(dbl1)
//                //self.cityTemp.append(dbl1)
//
//                       }
//        }
//
        if selectedCity.count>0
        {
        barChartView.xAxis.valueFormatter=IndexAxisValueFormatter(values: selectedCity)
        setChart(dataPoints: selectedCity, values: cityTemp)
        }
        
       
    
    }
    
//Show barchart by citynames and citytemp lists
    
    func setChart(dataPoints: [String], values: [Double]) {
       barChartView.noDataText = "You need to provide data for the chart."
     var dataEntries: [BarChartDataEntry] = []
       
       for i in 0..<dataPoints.count {
           
           let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
    
         dataEntries.append(dataEntry)
       }
       
       let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
       let chartData = BarChartData(dataSet: chartDataSet)
       barChartView.data = chartData
     }

}
