import UIKit
import UIKit

class WeightChartView: UIView {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Weight"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chartContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.systemGreen.withAlphaComponent(0.3).cgColor,
                       UIColor.systemGreen.withAlphaComponent(0.0).cgColor]
        layer.locations = [0.0, 1.0]
        return layer
    }()
    
    private let lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = UIColor.systemGreen.cgColor
        layer.lineWidth = 2
        layer.lineCap = .round
        layer.lineJoin = .round
        return layer
    }()
    
    private let dotsLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.white.cgColor
        layer.strokeColor = UIColor.systemGreen.cgColor
        layer.lineWidth = 2
        return layer
    }()
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Properties for data
    var weights: [WeightEntry] = [] {
        didSet {
            updateChart()
            updateStats()
        }
    }
    
    private var dateLabels: [UILabel] = []
    private var valueLabels: [UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(chartContainer)
        containerView.addSubview(statsStackView)
        
        chartContainer.layer.addSublayer(gradientLayer)
        chartContainer.layer.addSublayer(lineLayer)
        chartContainer.layer.addSublayer(dotsLayer)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            chartContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            chartContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            chartContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chartContainer.heightAnchor.constraint(equalToConstant: 200),
            
            statsStackView.topAnchor.constraint(equalTo: chartContainer.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = chartContainer.bounds
        updateChart()
    }
    
    private func updateChart() {
        // Remove existing labels
        dateLabels.forEach { $0.removeFromSuperview() }
        valueLabels.forEach { $0.removeFromSuperview() }
        dateLabels.removeAll()
        valueLabels.removeAll()
        
        guard weights.count > 1 else { return }
        
        let sortedWeights = weights.sorted { $0.date < $1.date }
        let points = calculatePoints(from: sortedWeights)
        
        // Create and animate path
        let linePath = UIBezierPath()
        let fillPath = UIBezierPath()
        let dotsPath = UIBezierPath()
        
        // Start fill path from bottom left
        fillPath.move(to: CGPoint(x: 0, y: chartContainer.bounds.height))
        
        points.enumerated().forEach { index, point in
            if index == 0 {
                linePath.move(to: point)
                fillPath.addLine(to: point)
            } else {
                let previousPoint = points[index - 1]
                let controlPoint1 = CGPoint(x: previousPoint.x + (point.x - previousPoint.x) / 2, y: previousPoint.y)
                let controlPoint2 = CGPoint(x: previousPoint.x + (point.x - previousPoint.x) / 2, y: point.y)
                linePath.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                fillPath.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            }
            
            // Add dots
            dotsPath.move(to: CGPoint(x: point.x - 4, y: point.y))
            dotsPath.addArc(withCenter: point, radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            
            // Add labels
            addDateLabel(for: sortedWeights[index].date, at: point.x)
            addValueLabel(for: sortedWeights[index].value, at: point)
        }
        
        // Complete fill path
        fillPath.addLine(to: CGPoint(x: points.last!.x, y: chartContainer.bounds.height))
        fillPath.addLine(to: CGPoint(x: 0, y: chartContainer.bounds.height))
        fillPath.close()
        
        // Animate paths
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        
        lineLayer.path = linePath.cgPath
        dotsLayer.path = dotsPath.cgPath
        
        let gradientMask = CAShapeLayer()
        gradientMask.path = fillPath.cgPath
        gradientLayer.mask = gradientMask
        
        CATransaction.commit()
    }
    
    private func calculatePoints(from weights: [WeightEntry]) -> [CGPoint] {
        let width = chartContainer.bounds.width
        let height = chartContainer.bounds.height
        let horizontalPadding: CGFloat = 20
        let verticalPadding: CGFloat = 30
        
        let minWeight = weights.map { $0.value }.min() ?? 0
        let maxWeight = weights.map { $0.value }.max() ?? 100
        let weightRange = maxWeight - minWeight
        
        return weights.enumerated().map { index, weight in
            let x = horizontalPadding + (width - 2 * horizontalPadding) * CGFloat(index) / CGFloat(weights.count - 1)
            let normalizedWeight = CGFloat(weight.value - minWeight) / CGFloat(weightRange)
            let y = height - verticalPadding - (height - 2 * verticalPadding) * normalizedWeight
            return CGPoint(x: x, y: y)
        }
    }
    
    private func addDateLabel(for dateString: String, at x: CGFloat) {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "d MMM"
            label.text = dateFormatter.string(from: date)
        }
        
        chartContainer.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: chartContainer.leadingAnchor, constant: x),
            label.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor)
        ])
        
        dateLabels.append(label)
    }
    
    private func addValueLabel(for value: Double, at point: CGPoint) {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = String(format: "%.1f", value)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        chartContainer.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: chartContainer.leadingAnchor, constant: point.x),
            label.bottomAnchor.constraint(equalTo: chartContainer.topAnchor, constant: point.y - 15)
        ])
        
        valueLabels.append(label)
    }
    
    private func updateStats() {
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let startWeight = weights.first?.value,
              let currentWeight = weights.last?.value else { return }
        
        let weightChange = currentWeight - startWeight
        let goal: Double = 61.0 // This should come from user settings
        
        let statsView = WeightStatsView(startWeight: startWeight,
                                      currentWeight: currentWeight,
                                      weightChange: weightChange,
                                      goal: goal)
        statsStackView.addArrangedSubview(statsView)
    }
}

class WeightStatsView: UIView {
    private let startWeightLabel = UILabel()
    private let currentWeightLabel = UILabel()
    private let changeLabel = UILabel()
    private let goalLabel = UILabel()
    
    init(startWeight: Double, currentWeight: Double, weightChange: Double, goal: Double) {
        super.init(frame: .zero)
        setupUI()
        configure(startWeight: startWeight,
                 currentWeight: currentWeight,
                 weightChange: weightChange,
                 goal: goal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [
            createRow(title: "Starting weight", label: startWeightLabel),
            createRow(title: "Current weight", label: currentWeightLabel),
            createRow(title: "Goal", label: goalLabel)
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func createRow(title: String, label: UILabel) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .gray
        
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, label])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        
        return stack
    }
    
    private func configure(startWeight: Double, currentWeight: Double, weightChange: Double, goal: Double) {
        startWeightLabel.text = "\(String(format: "%.1f", startWeight)) kg"
        
        let changeText = weightChange >= 0 ? "+\(String(format: "%.1f", weightChange))" : "\(String(format: "%.1f", weightChange))"
        currentWeightLabel.text = "\(changeText) \(String(format: "%.1f", currentWeight)) kg"
        currentWeightLabel.textColor = weightChange >= 0 ? .systemRed : .systemGreen
        
        goalLabel.text = "\(String(format: "%.1f", goal)) kg"
    }
}
