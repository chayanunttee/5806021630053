//
//  ViewController.swift
//  5806021630053
//
//  Created by Admin on 24/4/2562 BE.
//  Copyright © 2562 Admin. All rights reserved.
//

import UIKit
import Charts

struct FindLatLng: Decodable {
    let population: Int?
    let gini: Double?
    let name: String?
    var alpha3Code: String?
}

class ViewController: UIViewController {
    var pop = [Double]()
    var gini = [Double]()
    var name = [String]()
    var arrData = [FindLatLng]()
    var test = LineChartData()
    var arrCountries = [String]()
    
    @IBOutlet weak var chartView: CombinedChartView!
    @IBOutlet weak var inputCountries: UITextField!
    @IBAction func OKButton(_ sender: Any) {
        
        if inputCountries.text == "" {
            alert(checkCondition: 0)
        } else {
            arrCountries = inputCountries.text?.components(separatedBy: ",") ?? [""]
            if(arrCountries.count ?? 2 <= 5 && arrCountries.count ?? 2  >= 2) {
                
                self.viewDidLoad()
                self.setChart(xValues: self.name, yValuesLineChart: self.pop, yValuesBarChart: self.gini)
            } else {
                alert(checkCondition: 1)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    func getData () {
        let jsonUrlString = "https://restcountries.eu/rest/v2/all"
        guard let url = URL(string: jsonUrlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, responds,err) in
            guard let data = data else { return }
            do {
                self.pop = []
                self.gini = []
                self.name = []
                
                self.arrData = try JSONDecoder().decode([FindLatLng].self, from: data)
                
                
                for mainArr in self.arrCountries {
                    let selectedPersons = self.arrData.filter { (person) -> Bool in
                        return person.name == mainArr
                    }
                    
                    for data in selectedPersons {
                        self.pop.append(Double(data.population!)/1000000)
                        self.gini.append(data.gini!)
                        self.name.append(data.alpha3Code!)
                    }
                    
                }
                
            } catch let jsonErr {
                print("Error serializing json", jsonErr)
            }
            }.resume()
    }
    
    func setChart(xValues: [String], yValuesLineChart: [Double], yValuesBarChart: [Double]) {
        chartView.noDataText = "Please provide data for the chart."
        
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        var yVals2 : [BarChartDataEntry] = [BarChartDataEntry]()
        
        for i in 0..<xValues.count {
            yVals1.append(ChartDataEntry(x: Double(i), y: yValuesLineChart[i], data: xValues as AnyObject?))
            yVals2.append(BarChartDataEntry(x: Double(i), y: yValuesBarChart[i], data: xValues as AnyObject?))
        }
        
        let lineChartSet = LineChartDataSet(values: yVals1, label: "Population")
        let barChartSet: BarChartDataSet = BarChartDataSet(values: yVals2, label: "Area")
        barChartSet.colors = [NSUIColor.green]
        
        let data: CombinedChartData = CombinedChartData()
        data.barData=BarChartData(dataSets: [barChartSet])
        if yValuesLineChart.contains(0) == false {
            data.lineData = LineChartData(dataSets:[lineChartSet] )
        }
        
        self.chartView.data = data
        self.chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:xValues)
        self.chartView.xAxis.granularity = 1
    }
    
    // show alert
    func alert (checkCondition: Int) {
        var msg = ""
        if checkCondition == 0 {
            msg = "Please input Countries."
        } else {
            msg = "Data more than 2 or less 5."
        }
        
        let alert = UIAlertController(title: "Warning", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


