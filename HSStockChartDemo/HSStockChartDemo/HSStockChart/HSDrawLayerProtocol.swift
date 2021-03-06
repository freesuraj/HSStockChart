//
//  HSDrawLayerProtocol.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/28.
//  Copyright © 2017年 hanson. All rights reserved.
//

import Foundation
import UIKit

protocol HSDrawLayerProtocol {
    
    var theme: HSStockChartTheme { get }
    
    func getTextLayer(text: String, foregroundColor: UIColor, backgroundColor: UIColor, frame: CGRect) -> CATextLayer 
    func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?) -> CAShapeLayer
}

extension HSDrawLayerProtocol {
    
    var theme: HSStockChartTheme {
        return HSStockChartTheme()
    }
    
    /// 获取字符图层
    func getTextLayer(text: String, foregroundColor: UIColor, backgroundColor: UIColor, frame: CGRect) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.fontSize = 10
        textLayer.foregroundColor = foregroundColor.cgColor
        textLayer.backgroundColor = backgroundColor.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        
        return textLayer
    }
    
    /// 获取纵轴的标签图层
    func getYAxisMarkLayer(frame: CGRect, text: String, y: CGFloat, isLeft: Bool) -> CATextLayer {
        let textSize = theme.getTextSize(text: text)
        let yAxisLabelEdgeInset: CGFloat = 5
        var labelX: CGFloat = 0
        
        if isLeft {
            labelX = yAxisLabelEdgeInset
        } else {
            labelX = frame.width - textSize.width - yAxisLabelEdgeInset
        }
        
        let labelY: CGFloat = y - textSize.height / 2.0
        
        let yMarkLayer = getTextLayer(text: text, foregroundColor: theme.textColor, backgroundColor: UIColor.clear, frame: CGRect(x: labelX, y: labelY, width: textSize.width, height: textSize.height))
        
        return yMarkLayer
    }
    
    /// 获取长按显示的十字线及其标签图层
    func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?) -> CAShapeLayer {
        let highlightLayer = CAShapeLayer()
        
        let corssLineLayer = CAShapeLayer()
        var volMarkLayer = CATextLayer()
        var yAxisMarkLayer = CATextLayer()
        var bottomMarkLayer = CATextLayer()
        var bottomMarkerString = ""
        var yAxisMarkString = ""
        var volumeMarkerString = ""
        
        guard let model = model else { return highlightLayer }
        
        if model.isKind(of: HSKLineModel.self) {
            let entity = model as! HSKLineModel
            yAxisMarkString = entity.close.toStringWithFormat(".2")
            bottomMarkerString = entity.date.toDate("yyyyMMddHHmmss")?.toString("MM-dd") ?? ""
            volumeMarkerString = entity.volume.toStringWithFormat(".2")
            
        } else if model.isKind(of: HSTimeLineModel.self){
            let entity = model as! HSTimeLineModel
            yAxisMarkString = entity.price.toStringWithFormat(".2")
            bottomMarkerString = entity.time
            volumeMarkerString = entity.volume.toStringWithFormat(".2")
            
        } else{
            return highlightLayer
        }
        
        let linePath = UIBezierPath()
        // 竖线
        linePath.move(to: CGPoint(x: pricePoint.x, y: 0))
        linePath.addLine(to: CGPoint(x: pricePoint.x, y: frame.maxY))
        
        // 横线
        linePath.move(to: CGPoint(x: frame.minX, y: pricePoint.y))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: pricePoint.y))
        
        // 标记交易量的横线
        linePath.move(to: CGPoint(x: frame.minX, y: volumePoint.y))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: volumePoint.y))
        
        // 交叉点
        //linePath.addArc(withCenter: pricePoint, radius: 3, startAngle: 0, endAngle: 180, clockwise: true)
        
        corssLineLayer.lineWidth = theme.lineWidth
        corssLineLayer.strokeColor = theme.crossLineColor.cgColor
        corssLineLayer.fillColor = theme.crossLineColor.cgColor
        corssLineLayer.path = linePath.cgPath
        
        // 标记标签大小
        let yAxisMarkSize = theme.getTextSize(text: yAxisMarkString)
        let volMarkSize = theme.getTextSize(text: volumeMarkerString)
        let bottomMarkSize = theme.getTextSize(text: bottomMarkerString)
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        
        // 纵坐标标签
        if pricePoint.x > frame.width / 2 {
            labelX = frame.minX
        } else {
            labelX = frame.maxX - yAxisMarkSize.width
        }
        labelY = pricePoint.y - yAxisMarkSize.height / 2.0
        yAxisMarkLayer = getTextLayer(text: yAxisMarkString, foregroundColor: UIColor.white, backgroundColor: theme.textColor, frame: CGRect(x: labelX, y: labelY, width: yAxisMarkSize.width, height: yAxisMarkSize.height))
        
        // 底部时间标签
        let maxX = frame.maxX - bottomMarkSize.width
        labelX = pricePoint.x - bottomMarkSize.width / 2.0
        labelY = frame.height * theme.uperChartHeightScale
        if labelX > maxX {
            labelX = frame.maxX - bottomMarkSize.width
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        bottomMarkLayer = getTextLayer(text: bottomMarkerString, foregroundColor: UIColor.white, backgroundColor: theme.textColor, frame: CGRect(x: labelX, y: labelY, width: bottomMarkSize.width, height: bottomMarkSize.height))
        
        
        // 交易量右标签
        if pricePoint.x > frame.width / 2 {
            labelX = frame.minX
        } else {
            labelX = frame.maxX - volMarkSize.width
        }
        let maxY = frame.maxY - volMarkSize.height
        labelY = volumePoint.y - volMarkSize.height / 2.0
        labelY = labelY > maxY ? maxY : labelY
        volMarkLayer = getTextLayer(text: volumeMarkerString, foregroundColor: UIColor.white, backgroundColor: theme.textColor, frame: CGRect(x: labelX, y: labelY, width: volMarkSize.width, height: volMarkSize.height))
        
        highlightLayer.addSublayer(corssLineLayer)
        highlightLayer.addSublayer(yAxisMarkLayer)
        highlightLayer.addSublayer(bottomMarkLayer)
        highlightLayer.addSublayer(volMarkLayer)
        
        return highlightLayer
    }
}
