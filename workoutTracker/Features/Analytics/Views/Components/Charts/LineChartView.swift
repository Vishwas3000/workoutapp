
import UIKit

class LineChartView: UIView {
    
    // MARK: - Properties
    var dataPoints: [(x: Date, y: Double)] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var lineColor: UIColor = .systemBlue
    var fillColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.1)
    var gridColor: UIColor = UIColor.systemGray.withAlphaComponent(0.2)
    var textColor: UIColor = .label
    var lineWidth: CGFloat = 2.0
    var showGrid: Bool = true
    var showLabels: Bool = true
    var showDots: Bool = true
    var animationDuration: TimeInterval = 0.5
    
    private var minY: Double = 0
    private var maxY: Double = 100
    private let padding: CGFloat = 40
    private let labelHeight: CGFloat = 20
    
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private var animationProgress: CGFloat = 0
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        contentMode = .redraw
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        calculateYRange()
        
        let chartRect = CGRect(
            x: padding,
            y: padding,
            width: rect.width - padding * 2,
            height: rect.height - padding * 2 - labelHeight
        )
        
        if showGrid {
            drawGrid(in: chartRect, context: context)
        }
        
        if !dataPoints.isEmpty {
            drawChart(in: chartRect, context: context)
            
            if showLabels {
                drawLabels(in: chartRect)
            }
        }
    }
    
    private func calculateYRange() {
        guard !dataPoints.isEmpty else { return }
        
        let values = dataPoints.map { $0.y }
        minY = values.min() ?? 0
        maxY = values.max() ?? 100
        
        // Add some padding to the range
        let range = maxY - minY
        minY -= range * 0.1
        maxY += range * 0.1
    }
    
    private func drawGrid(in rect: CGRect, context: CGContext) {
        context.setStrokeColor(gridColor.cgColor)
        context.setLineWidth(0.5)
        
        // Horizontal lines
        let horizontalLines = 5
        for i in 0...horizontalLines {
            let y = rect.minY + (rect.height * CGFloat(i) / CGFloat(horizontalLines))
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        
        // Vertical lines
        let verticalLines = 6
        for i in 0...verticalLines {
            let x = rect.minX + (rect.width * CGFloat(i) / CGFloat(verticalLines))
            context.move(to: CGPoint(x: x, y: rect.minY))
            context.addLine(to: CGPoint(x: x, y: rect.maxY))
        }
        
        context.strokePath()
    }
    
    private func drawChart(in rect: CGRect, context: CGContext) {
        guard dataPoints.count > 1 else { return }
        
        let points = calculatePoints(in: rect)
        
        // Draw fill
        context.setFillColor(fillColor.cgColor)
        context.beginPath()
        
        // Start from bottom left
        context.move(to: CGPoint(x: points[0].x, y: rect.maxY))
        
        // Draw line to first data point
        context.addLine(to: points[0])
        
        // Draw curve through points
        for i in 1..<points.count {
            let point = points[i]
            let previousPoint = points[i - 1]
            
            let midX = (previousPoint.x + point.x) / 2
            let midY = (previousPoint.y + point.y) / 2
            let controlPoint1 = CGPoint(x: midX, y: previousPoint.y)
            let controlPoint2 = CGPoint(x: midX, y: point.y)
            
            context.addCurve(to: point, control1: controlPoint1, control2: controlPoint2)
        }
        
        // Close the path
        context.addLine(to: CGPoint(x: points.last!.x, y: rect.maxY))
        context.closePath()
        context.fillPath()
        
        // Draw line
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        context.beginPath()
        context.move(to: points[0])
        
        for i in 1..<points.count {
            let point = points[i]
            let previousPoint = points[i - 1]
            
            let midX = (previousPoint.x + point.x) / 2
            let midY = (previousPoint.y + point.y) / 2
            let controlPoint1 = CGPoint(x: midX, y: previousPoint.y)
            let controlPoint2 = CGPoint(x: midX, y: point.y)
            
            context.addCurve(to: point, control1: controlPoint1, control2: controlPoint2)
        }
        
        context.strokePath()
        
        // Draw dots
        if showDots {
            for point in points {
                drawDot(at: point, context: context)
            }
        }
    }
    
    private func drawDot(at point: CGPoint, context: CGContext) {
        let dotRadius: CGFloat = 4
        
        context.setFillColor(UIColor.systemBackground.cgColor)
        context.fillEllipse(in: CGRect(
            x: point.x - dotRadius,
            y: point.y - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        ))
        
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(2)
        context.strokeEllipse(in: CGRect(
            x: point.x - dotRadius,
            y: point.y - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        ))
    }
    
    private func calculatePoints(in rect: CGRect) -> [CGPoint] {
        guard !dataPoints.isEmpty else { return [] }
        
        let xRange = dataPoints.last!.x.timeIntervalSince(dataPoints.first!.x)
        let yRange = maxY - minY
        
        return dataPoints.map { dataPoint in
            let xProgress = xRange > 0 ? dataPoint.x.timeIntervalSince(dataPoints.first!.x) / xRange : 0
            let x = rect.minX + rect.width * CGFloat(xProgress)
            
            let yProgress = yRange > 0 ? (dataPoint.y - minY) / yRange : 0.5
            let y = rect.maxY - rect.height * CGFloat(yProgress)
            
            return CGPoint(x: x, y: y * animationProgress + rect.maxY * (1 - animationProgress))
        }
    }
    
    private func drawLabels(in rect: CGRect) {
        // X-axis labels (dates)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        let labelCount = min(dataPoints.count, 6)
        let step = max(1, dataPoints.count / labelCount)
        
        for i in stride(from: 0, to: dataPoints.count, by: step) {
            let dataPoint = dataPoints[i]
            let xProgress = CGFloat(i) / CGFloat(max(1, dataPoints.count - 1))
            let x = rect.minX + rect.width * xProgress
            
            let label = dateFormatter.string(from: dataPoint.x)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: textColor
            ]
            
            let size = label.size(withAttributes: attributes)
            let drawRect = CGRect(
                x: x - size.width / 2,
                y: rect.maxY + 5,
                width: size.width,
                height: size.height
            )
            
            label.draw(in: drawRect, withAttributes: attributes)
        }
        
        // Y-axis labels
        let yLabelCount = 5
        for i in 0...yLabelCount {
            let progress = CGFloat(i) / CGFloat(yLabelCount)
            let value = minY + (maxY - minY) * Double(progress)
            let y = rect.maxY - rect.height * progress
            
            let label = String(format: "%.0f", value)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: textColor
            ]
            
            let size = label.size(withAttributes: attributes)
            let drawRect = CGRect(
                x: rect.minX - size.width - 5,
                y: y - size.height / 2,
                width: size.width,
                height: size.height
            )
            
            label.draw(in: drawRect, withAttributes: attributes)
        }
    }
    
    // MARK: - Animation
    func animateChart() {
        animationProgress = 0
        animationStartTime = CACurrentMediaTime()
        
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateAnimation() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        let progress = min(1.0, elapsed / animationDuration)
        
        animationProgress = easeInOutQuad(progress)
        setNeedsDisplay()
        
        if progress >= 1.0 {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    private func easeInOutQuad(_ t: CGFloat) -> CGFloat {
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
    }
}
