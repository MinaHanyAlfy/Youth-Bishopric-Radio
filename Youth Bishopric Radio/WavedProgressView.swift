//
//  WavedProgressView.swift
//  Youth Bishopric Radio
//
//  Created by Petra Software on 15/08/2021.
//
import UIKit

class WavedProgressView: UIView {

    var lineMargin:CGFloat = 2.0
    var volumes:[CGFloat] = [0.5,0.3,0.2,0.6,0.4,0.5,0.8,0.6,0.4]

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkGray
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    override var frame: CGRect {
        didSet{
            self.drawVerticalLines()
        }
    }

    var lineWidth:CGFloat = 0.1{
        didSet{
            self.drawVerticalLines()
        }
    }
    func clearVolumes()  {
        
        volumes = []
    }
    func drawVerticalLines() {
        let linePath = CGMutablePath()
        for i in 0..<self.volumes.count {
            let height = self.frame.height * volumes[i]
            let y = (self.frame.height - height) / 2.0
            linePath.addRect(CGRect(x: lineMargin + (lineMargin + lineWidth) * CGFloat(i), y: y, width: lineWidth, height: height))
        }

        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath
        lineLayer.lineWidth = 0.5
        lineLayer.strokeColor = #colorLiteral(red: 0.9333333333, green: 0.4392156863, blue: 0.5843137255, alpha: 1)
        lineLayer.fillColor = #colorLiteral(red: 0.9333333333, green: 0.4392156863, blue: 0.5843137255, alpha: 1)
        self.layer.sublayers?.removeAll()
        self.layer.addSublayer(lineLayer)
    }
}
