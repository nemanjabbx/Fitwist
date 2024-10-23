import UIKit

class WeightChartView: UIView {
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Weight History"
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
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let weightHistoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let weightHistoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Weight Records"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var dateLabels: [UILabel] = []
    private var valueLabels: [UILabel] = []
    
    // Properties for data
    var weights: [WeightEntry] = [] {
        didSet {
            updateChart()
            updateWeightHistory()
            updateStats()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(chartContainer)
        containerView.addSubview(statsStackView)
        containerView.addSubview(weightHistoryLabel)
        containerView.addSubview(weightHistoryStackView)
        
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
            
            weightHistoryLabel.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 16),
            weightHistoryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            weightHistoryStackView.topAnchor.constraint(equalTo: weightHistoryLabel.bottomAnchor, constant: 8),
            weightHistoryStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            weightHistoryStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            weightHistoryStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = chartContainer.bounds
        updateChart()
    }
    
    // MARK: - Update Methods
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
                linePath.addLine(to: point)
                fillPath.addLine(to: point)
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
        lineLayer.path = linePath.cgPath
        dotsLayer.path = dotsPath.cgPath
        gradientLayer.mask = {
            let mask = CAShapeLayer()
            mask.path = fillPath.cgPath
            return mask
        }()
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
            dateFormatter.dateFormat = "MMM d"
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
    
    private func updateWeightHistory() {
        weightHistoryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Sort weights by date, newest first
        let sortedWeights = weights.sorted { entry1, entry2 in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            let date1 = dateFormatter.date(from: entry1.date) ?? Date()
            let date2 = dateFormatter.date(from: entry2.date) ?? Date()
            return date1 > date2
        }
        
        // Add all weight records
        for entry in sortedWeights {
            let recordView = createWeightRecordView(for: entry)
            weightHistoryStackView.addArrangedSubview(recordView)
        }
        
        if weights.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No weight records available"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = .gray
            emptyLabel.font = .systemFont(ofSize: 14)
            weightHistoryStackView.addArrangedSubview(emptyLabel)
        }
    }
    
    private func createWeightRecordView(for entry: WeightEntry) -> UIView {
        let recordView = UIView()
        recordView.backgroundColor = UIColor(red: 241/255.0, green: 237/255.0, blue: 226/255.0, alpha: 1.0)
        recordView.layer.cornerRadius = 8
        
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        
        let weightLabel = UILabel()
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        weightLabel.font = .systemFont(ofSize: 16, weight: .medium)
        weightLabel.textColor = UIColor(red: 71/255.0, green: 145/255.0, blue: 219/255.0, alpha: 1.0)
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        if let date = dateFormatter.date(from: entry.date) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            dateLabel.text = dateFormatter.string(from: date)
        }
        
        weightLabel.text = "\(String(format: "%.1f", entry.value)) \(entry.unit)"
        
        recordView.addSubview(dateLabel)
        recordView.addSubview(weightLabel)
        
        NSLayoutConstraint.activate([
            recordView.heightAnchor.constraint(equalToConstant: 44),
            
            dateLabel.leadingAnchor.constraint(equalTo: recordView.leadingAnchor, constant: 12),
            dateLabel.centerYAnchor.constraint(equalTo: recordView.centerYAnchor),
            
            weightLabel.trailingAnchor.constraint(equalTo: recordView.trailingAnchor, constant: -12),
            weightLabel.centerYAnchor.constraint(equalTo: recordView.centerYAnchor)
        ])
        
        return recordView
    }
    
    private func updateStats() {
            statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            // Sortiramo težine po datumu
            let sortedWeights = weights.sorted { entry1, entry2 in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
                let date1 = dateFormatter.date(from: entry1.date) ?? Date()
                let date2 = dateFormatter.date(from: entry2.date) ?? Date()
                return date1 < date2
            }
            
            guard let startWeight = sortedWeights.first?.value,
                  let currentWeight = sortedWeights.last?.value else { return }
            
            let weightChange = currentWeight - startWeight
            
            // Kreiramo statistički pregled
            let statsView = createStatsView(
                startWeight: startWeight,
                currentWeight: currentWeight,
                weightChange: weightChange
            )
            
            statsStackView.addArrangedSubview(statsView)
        }
        
        private func createStatsView(startWeight: Double, currentWeight: Double, weightChange: Double) -> UIView {
            let containerView = UIView()
            
            // Kreiranje redova statistike
            let startWeightRow = createStatRow(title: "Starting weight", value: "\(String(format: "%.1f", startWeight)) kg")
            let currentWeightRow = createStatRow(title: "Current weight", value: "\(String(format: "%.1f", currentWeight)) kg")
            let changeRow = createStatRow(
                title: "Total change",
                value: "\(String(format: "%.1f", abs(weightChange))) kg",
                valueColor: weightChange < 0 ? .systemGreen : .systemRed,
                prefix: weightChange < 0 ? "↓" : "↑"
            )
            
            // Stack view za redove
            let stackView = UIStackView(arrangedSubviews: [startWeightRow, currentWeightRow, changeRow])
            stackView.axis = .vertical
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            return containerView
        }
        
        private func createStatRow(title: String, value: String, valueColor: UIColor = .black, prefix: String = "") -> UIView {
            let rowView = UIView()
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 14)
            titleLabel.textColor = .gray
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let valueLabel = UILabel()
            valueLabel.text = prefix + value
            valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
            valueLabel.textColor = valueColor
            valueLabel.textAlignment = .right
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            
            rowView.addSubview(titleLabel)
            rowView.addSubview(valueLabel)
            
            NSLayoutConstraint.activate([
                rowView.heightAnchor.constraint(equalToConstant: 24),
                
                titleLabel.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
                
                valueLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
                valueLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
                valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
            ])
            
            return rowView
        }
    }
