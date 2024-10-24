import UIKit

protocol WeightChartViewDelegate: AnyObject {
    func didRequestAddWeight()
    func didRequestEditWeight(entry: WeightEntry)
    func didRequestDeleteWeight(entry: WeightEntry)
}

class WeightChartView: UIView {
    // MARK: - Properties
    weak var delegate: WeightChartViewDelegate?
    public var weights: [WeightEntry] = [] {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - UI Components
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
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Weight Progress"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .systemGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let statsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let chartView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let yAxisView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let xAxisView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let historyLabel: UILabel = {
        let label = UILabel()
        label.text = "Weight History"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let historyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.systemGreen.withAlphaComponent(0.3).cgColor,
            UIColor.systemGreen.withAlphaComponent(0.05).cgColor
        ]
        layer.locations = [0.0, 1.0]
        return layer
    }()
    
    private let lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = UIColor.systemGreen.cgColor
        layer.lineWidth = 3
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
    
    private lazy var tooltipView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tooltipLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGestures()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(headerView)
        containerView.addSubview(statsView)
        containerView.addSubview(chartView)
        containerView.addSubview(yAxisView)
        containerView.addSubview(xAxisView)
        containerView.addSubview(historyLabel)
        containerView.addSubview(historyStackView)
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(addButton)
        statsView.addSubview(statsStackView)
        
        chartView.layer.addSublayer(gradientLayer)
        chartView.layer.addSublayer(lineLayer)
        chartView.layer.addSublayer(dotsLayer)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        // Setup tooltip
        containerView.addSubview(tooltipView)
        tooltipView.addSubview(tooltipLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            addButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            
            statsView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            statsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            statsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            statsStackView.topAnchor.constraint(equalTo: statsView.topAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: statsView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: statsView.trailingAnchor, constant: -16),
            statsStackView.bottomAnchor.constraint(equalTo: statsView.bottomAnchor, constant: -16),
            
            yAxisView.topAnchor.constraint(equalTo: statsView.bottomAnchor, constant: 20),
            yAxisView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            yAxisView.bottomAnchor.constraint(equalTo: xAxisView.topAnchor),
            yAxisView.widthAnchor.constraint(equalToConstant: 50),
            
            chartView.topAnchor.constraint(equalTo: statsView.bottomAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: yAxisView.trailingAnchor),
            chartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            chartView.heightAnchor.constraint(equalToConstant: 220),
            
            xAxisView.topAnchor.constraint(equalTo: chartView.bottomAnchor),
            xAxisView.leadingAnchor.constraint(equalTo: yAxisView.trailingAnchor),
            xAxisView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            xAxisView.heightAnchor.constraint(equalToConstant: 30),
            
            historyLabel.topAnchor.constraint(equalTo: xAxisView.bottomAnchor, constant: 20),
            historyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            historyStackView.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 12),
            historyStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            historyStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            historyStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            tooltipView.widthAnchor.constraint(equalToConstant: 120),
            tooltipView.heightAnchor.constraint(equalToConstant: 50),
            tooltipLabel.topAnchor.constraint(equalTo: tooltipView.topAnchor, constant: 8),
            tooltipLabel.leadingAnchor.constraint(equalTo: tooltipView.leadingAnchor, constant: 8),
            tooltipLabel.trailingAnchor.constraint(equalTo: tooltipView.trailingAnchor, constant: -8),
            tooltipLabel.bottomAnchor.constraint(equalTo: tooltipView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleChartPan(_:)))
        chartView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleChartPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: chartView)
        
        switch gesture.state {
        case .began, .changed:
            updateTooltip(at: location)
        case .ended, .cancelled:
            hideTooltip()
        default:
            break
        }
    }
    
    private func updateTooltip(at location: CGPoint) {
        guard !weights.isEmpty else { return }
        
        let points = calculatePoints(from: weights.sorted { $0.date < $1.date })
        guard let (nearestPoint, weight) = findNearestPoint(to: location, points: points) else { return }
        
        tooltipView.center = CGPoint(x: nearestPoint.x, y: nearestPoint.y - 30)
        tooltipLabel.text = String(format: "%.1f kg\n%@", weight.value, formatDate(weight.date))
        tooltipView.isHidden = false
    }
    
    private func hideTooltip() {
        tooltipView.isHidden = true
    }
    
    private func findNearestPoint(to location: CGPoint, points: [CGPoint]) -> (CGPoint, WeightEntry)? {
        let sortedWeights = weights.sorted { $0.date < $1.date }
        
        var minDistance = CGFloat.greatestFiniteMagnitude
        var nearestIndex = 0
        
        for (index, point) in points.enumerated() {
            let distance = abs(point.x - location.x)
            if distance < minDistance {
                minDistance = distance
                nearestIndex = index
            }
        }
        
        if minDistance <= 20 { // 20 points threshold
            return (points[nearestIndex], sortedWeights[nearestIndex])
        }
        
        return nil
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        guard let date = dateFormatter.date(from: dateString) else { return "" }
        
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: date)
    }
    // MARK: - Actions
        @objc private func addButtonTapped() {
            delegate?.didRequestAddWeight()
        }
        
        // MARK: - UI Updates
        private func updateUI() {
            guard !weights.isEmpty else {
                showEmptyState()
                return
            }
            
            hideEmptyState()
            updateStats()
            updateChart()
            updateHistory()
        }
        
        private func showEmptyState() {
            // Hide all content views
            statsView.isHidden = true
            chartView.isHidden = true
            yAxisView.isHidden = true
            xAxisView.isHidden = true
            historyLabel.isHidden = true
            historyStackView.isHidden = true
            
            // Show empty state if not already shown
            if containerView.viewWithTag(100) == nil {
                let emptyStateView = createEmptyStateView()
                emptyStateView.tag = 100
                containerView.addSubview(emptyStateView)
                
                NSLayoutConstraint.activate([
                    emptyStateView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    emptyStateView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                    emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                    emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
                ])
            }
        }
        
        private func hideEmptyState() {
            containerView.viewWithTag(100)?.removeFromSuperview()
            statsView.isHidden = false
            chartView.isHidden = false
            yAxisView.isHidden = false
            xAxisView.isHidden = false
            historyLabel.isHidden = false
            historyStackView.isHidden = false
        }
        
        private func createEmptyStateView() -> UIView {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView = UIImageView(image: UIImage(systemName: "scale"))
            imageView.tintColor = .systemGray3
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = "No weight records yet\nTap + to add your first weight"
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16)
            label.textColor = .systemGray
            label.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(imageView)
            view.addSubview(label)
            
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: view.topAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 60),
                imageView.heightAnchor.constraint(equalToConstant: 60),
                
                label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            return view
        }
        
        private func updateStats() {
            statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            let sortedWeights = weights.sorted { $0.date < $1.date }
            guard let firstWeight = sortedWeights.first?.value,
                  let lastWeight = sortedWeights.last?.value else { return }
            
            let change = lastWeight - firstWeight
            let changePercentage = (change / firstWeight) * 100
            
            // Starting Weight
            let startBox = createStatsBox(
                title: "Starting",
                value: String(format: "%.1f kg", firstWeight)
            )
            
            // Current Weight
            let currentBox = createStatsBox(
                title: "Current",
                value: String(format: "%.1f kg", lastWeight)
            )
            
            // Total Change
            let changeBox = createStatsBox(
                title: "Change",
                value: String(format: "%.1f kg\n(%.1f%%)", abs(change), abs(changePercentage)),
                valueColor: change <= 0 ? .systemGreen : .systemRed,
                prefix: change <= 0 ? "↓" : "↑"
            )
            
            [startBox, currentBox, changeBox].forEach { statsStackView.addArrangedSubview($0) }
        }
        
        private func updateChart() {
            // Clear previous labels
            yAxisView.subviews.forEach { $0.removeFromSuperview() }
            xAxisView.subviews.forEach { $0.removeFromSuperview() }
            
            let sortedWeights = weights.sorted { $0.date < $1.date }
            let points = calculatePoints(from: sortedWeights)
            
            // Update Y-axis
            let (min, max) = getWeightRange(from: sortedWeights)
            setupYAxis(min: min, max: max)
            
            // Update X-axis
            setupXAxis(for: sortedWeights)
            
            // Draw chart with animation
            animateChart(with: points)
        }
        
        private func animateChart(with points: [CGPoint]) {
            // Create paths
            let linePath = createLinePath(from: points)
            let fillPath = createFillPath(from: points)
            let dotsPath = createDotsPath(from: points)
            
            // Animate line
            let lineAnimation = CABasicAnimation(keyPath: "strokeEnd")
            lineAnimation.fromValue = 0
            lineAnimation.toValue = 1
            lineAnimation.duration = 1.0
            
            lineLayer.path = linePath.cgPath
            lineLayer.add(lineAnimation, forKey: "lineAnimation")
            
            // Animate gradient fill
            gradientLayer.frame = chartView.bounds
            let fillMask = CAShapeLayer()
            fillMask.path = fillPath.cgPath
            
            let fillAnimation = CABasicAnimation(keyPath: "opacity")
            fillAnimation.fromValue = 0
            fillAnimation.toValue = 1
            fillAnimation.duration = 1.0
            
            gradientLayer.mask = fillMask
            gradientLayer.add(fillAnimation, forKey: "fillAnimation")
            
            // Animate dots
            let dotsAnimation = CABasicAnimation(keyPath: "opacity")
            dotsAnimation.fromValue = 0
            dotsAnimation.toValue = 1
            dotsAnimation.duration = 1.0
            dotsAnimation.beginTime = CACurrentMediaTime() + 0.5
            
            dotsLayer.path = dotsPath.cgPath
            dotsLayer.add(dotsAnimation, forKey: "dotsAnimation")
        }
        
        private func updateHistory() {
            historyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            let sortedWeights = weights.sorted { $0.date > $1.date }
            
            for (index, entry) in sortedWeights.prefix(5).enumerated() {
                let rowView = createHistoryRow(
                    entry: entry,
                    showDivider: index < sortedWeights.prefix(5).count - 1
                )
                historyStackView.addArrangedSubview(rowView)
            }
        }
        
        private func createHistoryRow(entry: WeightEntry, showDivider: Bool) -> UIView {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            
            let dateLabel = UILabel()
            dateLabel.text = formatDate(entry.date)
            dateLabel.font = .systemFont(ofSize: 14)
            dateLabel.textColor = .gray
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let weightLabel = UILabel()
            weightLabel.text = String(format: "%.1f kg", entry.value)
            weightLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            weightLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let actionsStack = UIStackView()
            actionsStack.axis = .horizontal
            actionsStack.spacing = 12
            actionsStack.translatesAutoresizingMaskIntoConstraints = false
            
            let editButton = UIButton(type: .system)
            editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            editButton.tintColor = .systemBlue
            
            let deleteButton = UIButton(type: .system)
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
            deleteButton.tintColor = .systemRed
            
            actionsStack.addArrangedSubview(editButton)
            actionsStack.addArrangedSubview(deleteButton)
            
            container.addSubview(dateLabel)
            container.addSubview(weightLabel)
            container.addSubview(actionsStack)
            
            editButton.addAction(.init(handler: { [weak self] _ in
                self?.delegate?.didRequestEditWeight(entry: entry)
            }), for: .touchUpInside)
            
            deleteButton.addAction(.init(handler: { [weak self] _ in
                self?.delegate?.didRequestDeleteWeight(entry: entry)
            }), for: .touchUpInside)
            
            if showDivider {
                let divider = UIView()
                divider.backgroundColor = .systemGray5
                divider.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(divider)
                
                NSLayoutConstraint.activate([
                    divider.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                    divider.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                    divider.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                    divider.heightAnchor.constraint(equalToConstant: 1)
                ])
            }
            
            NSLayoutConstraint.activate([
                container.heightAnchor.constraint(equalToConstant: 44),
                
                dateLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                dateLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                
                weightLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                weightLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                
                actionsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                actionsStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
            
            return container
        }
    // MARK: - Helper Methods
    private func createStatsBox(title: String, value: String, valueColor: UIColor = .black, prefix: String = "") -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = prefix + value
        valueLabel.font = .systemFont(ofSize: 14, weight: .bold)
        valueLabel.textColor = valueColor
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        return container
    }

    private func calculatePoints(from weights: [WeightEntry]) -> [CGPoint] {
        let (minWeight, maxWeight) = getWeightRange(from: weights)
        let weightRange = maxWeight - minWeight
        
        let width = chartView.bounds.width
        let height = chartView.bounds.height
        let horizontalPadding: CGFloat = 20
        let verticalPadding: CGFloat = 20
        
        return weights.enumerated().map { index, entry in
            let x = horizontalPadding + (width - 2 * horizontalPadding) * CGFloat(index) / CGFloat(weights.count - 1)
            let normalizedWeight = CGFloat((entry.value - minWeight) / weightRange)
            let y = height - verticalPadding - (height - 2 * verticalPadding) * normalizedWeight
            return CGPoint(x: x, y: y)
        }
    }

    private func getWeightRange(from weights: [WeightEntry]) -> (min: Double, max: Double) {
        let values = weights.map { $0.value }
        guard let min = values.min(), let max = values.max() else { return (0, 0) }
        let padding = (max - min) * 0.2
        return (min - padding, max + padding)
    }

    private func setupYAxis(min: Double, max: Double) {
        let steps = 5
        let stepValue = (max - min) / Double(steps - 1)
        
        for i in 0..<steps {
            let value = min + stepValue * Double(i)
            let label = UILabel()
            label.text = String(format: "%.1f kg", value)
            label.font = .systemFont(ofSize: 10)
            label.textColor = .gray
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            
            yAxisView.addSubview(label)
            
            let yPosition = chartView.frame.height * (1 - CGFloat(i) / CGFloat(steps - 1))
            
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: yAxisView.trailingAnchor, constant: -4),
                label.centerYAnchor.constraint(equalTo: chartView.topAnchor, constant: yPosition)
            ])
        }
    }

    private func setupXAxis(for weights: [WeightEntry]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d"
        
        for (index, entry) in weights.enumerated() {
            guard let date = dateFormatter.date(from: entry.date) else { continue }
            
            let label = UILabel()
            label.text = displayFormatter.string(from: date)
            label.font = .systemFont(ofSize: 10)
            label.textColor = .gray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            xAxisView.addSubview(label)
            
            let xPosition = chartView.frame.width * CGFloat(index) / CGFloat(weights.count - 1)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: chartView.leadingAnchor, constant: xPosition),
                label.topAnchor.constraint(equalTo: xAxisView.topAnchor)
            ])
        }
    }

    private func createLinePath(from points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        
        points.enumerated().forEach { index, point in
            if index == 0 {
                path.move(to: point)
            } else {
                let previousPoint = points[index - 1]
                let controlPoint1 = CGPoint(
                    x: previousPoint.x + (point.x - previousPoint.x) / 2,
                    y: previousPoint.y
                )
                let controlPoint2 = CGPoint(
                    x: previousPoint.x + (point.x - previousPoint.x) / 2,
                    y: point.y
                )
                path.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            }
        }
        
        return path
    }

    private func createFillPath(from points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: points[0].x, y: chartView.bounds.height))
        
        points.enumerated().forEach { index, point in
            if index == 0 {
                path.addLine(to: point)
            } else {
                let previousPoint = points[index - 1]
                let controlPoint1 = CGPoint(
                    x: previousPoint.x + (point.x - previousPoint.x) / 2,
                    y: previousPoint.y
                )
                let controlPoint2 = CGPoint(
                    x: previousPoint.x + (point.x - previousPoint.x) / 2,
                    y: point.y
                )
                path.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            }
        }
        
        path.addLine(to: CGPoint(x: points.last?.x ?? 0, y: chartView.bounds.height))
        path.close()
        
        return path
    }

    private func createDotsPath(from points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        
        points.forEach { point in
            path.move(to: CGPoint(x: point.x - 4, y: point.y))
            path.addArc(withCenter: point, radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        }
        
        return path
    }

    }
