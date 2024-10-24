import UIKit

protocol WaterIntakeViewDelegate: AnyObject {
    func didAddWater(amount: Double)
    func didDeleteWater(entryId: Int)
    func didEditWater(entryId: Int, newAmount: Double)
}


class WaterIntakeView: UIView {
    // MARK: - Properties
    weak var delegate: WaterIntakeViewDelegate?
    private var intakeEntries: [WaterIntakeEntry] = []
    
    // MARK: - Colors
    private let viewBackgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)
    private let boxBackgroundColor = UIColor(red: 241/255.0, green: 237/255.0, blue: 226/255.0, alpha: 1.0)
    private let accentColor = UIColor(red: 71/255.0, green: 145/255.0, blue: 219/255.0, alpha: 1.0)
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 241/255.0, green: 237/255.0, blue: 226/255.0, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Water Intake"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(red: 71/255.0, green: 145/255.0, blue: 219/255.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "water.add"), for: .normal)
        button.tintColor = UIColor(red: 71/255.0, green: 145/255.0, blue: 219/255.0, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = UIColor(red: 71/255.0, green: 145/255.0, blue: 219/255.0, alpha: 0.2)
        progress.progressTintColor = UIColor(red: 71/255.0, green: 145/255.0, blue: 219/255.0, alpha: 1.0)
        progress.layer.cornerRadius = 6
        progress.clipsToBounds = true
        progress.layer.sublayers![1].cornerRadius = 6
        progress.subviews[1].clipsToBounds = true
        progress.transform = progress.transform.scaledBy(x: 1, y: 2)
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor(red: 71/255.0, green: 145/255.0, blue: 219/255.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dailyGoalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quickAddButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let dailyLogLabel: UILabel = {
        let label = UILabel()
        label.text = "Today's Logs"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let waterAmounts = [
        (amount: 100, iconName: "water.cup.coffee", name: "Coffee Cup"),
        (amount: 200, iconName: "water.glass.small", name: "Small Glass"),
        (amount: 300, iconName: "water.glass.medium", name: "Medium Glass"),
        (amount: 400, iconName: "water.glass.large", name: "Large Glass"),
        (amount: 500, iconName: "water.bottle.small", name: "Bottle")
    ]

    @objc private func addButtonTapped() {
        guard let viewController = findViewController() else { return }
        
        let alert = UIAlertController(title: "Add Water Intake", message: nil, preferredStyle: .alert)
        
        // Amount TextField
        alert.addTextField { textField in
            textField.placeholder = "Amount (ml)"
            textField.keyboardType = .numberPad
        }
        
        // Date TextField with DatePicker
        alert.addTextField { textField in
            textField.placeholder = "Date"
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .dateAndTime
            datePicker.preferredDatePickerStyle = .wheels
            textField.inputView = datePicker
            
            // Set current date/time
            datePicker.date = Date()
            textField.text = Date().formatted(date: .numeric, time: .shortened)
            
            // Update textfield when date is changed
            datePicker.addTarget(self, action: #selector(self.datePickerChanged(_:)), for: .valueChanged)
        }
        
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let amountText = alert.textFields?[0].text,
                  let amount = Double(amountText),
                  let dateField = alert.textFields?[1],
                  let datePicker = dateField.inputView as? UIDatePicker else { return }
            
            self?.delegate?.didAddWater(amount: amount, date: datePicker.date)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = viewBackgroundColor
        
        addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(addButton)
        containerView.addSubview(dailyGoalLabel)
        containerView.addSubview(progressView)
        containerView.addSubview(progressLabel)
        containerView.addSubview(quickAddButtonsStack)
        containerView.addSubview(dailyLogLabel)
        containerView.addSubview(logsStackView)
        
        setupConstraints()
        setupQuickAddButtons()
        
        addButton.addTarget(self, action: #selector(showCustomAmountPopup), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            addButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            
            dailyGoalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            dailyGoalLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dailyGoalLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            progressView.topAnchor.constraint(equalTo: dailyGoalLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            progressLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            
            quickAddButtonsStack.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 16),
            quickAddButtonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            quickAddButtonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            quickAddButtonsStack.heightAnchor.constraint(equalToConstant: 60),
            
            dailyLogLabel.topAnchor.constraint(equalTo: quickAddButtonsStack.bottomAnchor, constant: 16),
            dailyLogLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            logsStackView.topAnchor.constraint(equalTo: dailyLogLabel.bottomAnchor, constant: 8),
            logsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            logsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            logsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
//    Ova ne radi
    
    private func setupQuickAddButtons() {
        waterAmounts.forEach { (amount, iconName) in
            let button = createQuickAddButton(amount: amount, iconName: iconName)
            quickAddButtonsStack.addArrangedSubview(button)
        }
    }
    
    
    private func createQuickAddButton(amount: Int, iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = amount
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .top
        config.imagePadding = 4
        config.title = "\(amount)ml"
        config.titleAlignment = .center
        
        let titleAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        config.attributedTitle = AttributedString("\(amount)ml", attributes: AttributeContainer(titleAttr))
        
        button.configuration = config
        button.tintColor = accentColor
        button.addTarget(self, action: #selector(quickAddWaterTapped), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Actions
    @objc private func showCustomAmountPopup() {
        if let viewController = findViewController() {
            let alert = UIAlertController(title: "Add Water", message: "Enter amount in milliliters", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Amount (ml)"
                textField.keyboardType = .numberPad
            }
            
            let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
                if let text = alert.textFields?[0].text,
                   let amount = Double(text) {
                    self?.delegate?.didAddWater(amount: amount)
                }
            }
            
            alert.addAction(addAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            viewController.present(alert, animated: true)
        }
    }
    
    @objc private func quickAddWaterTapped(_ sender: UIButton) {
        delegate?.didAddWater(amount: Double(sender.tag))
    }
    
    // MARK: - Public Methods
    func updateWaterLogs(entries: [WaterIntakeEntry], goal: Int) {
        // Clear existing entries
        logsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Filter and sort today's entries
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todayEntries = entries.filter { entry in
            let entryDay = calendar.startOfDay(for: entry.parsedDate)
            return entryDay == today
        }.sorted { $0.parsedDate > $1.parsedDate }
        
        intakeEntries = todayEntries
        
        // Calculate progress
        let total = todayEntries.reduce(0.0) { $0 + $1.value }
        let progress = min(total / Double(goal), 1.0)
        
        // Update labels
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let formattedGoal = numberFormatter.string(from: NSNumber(value: goal)) ?? "0"
        let formattedTotal = numberFormatter.string(from: NSNumber(value: total)) ?? "0"
        
        dailyGoalLabel.text = "Daily Goal: \(formattedGoal) ml • Today's Intake: \(formattedTotal) ml"
        progressLabel.text = "\(formattedTotal) ml / \(formattedGoal) ml (\(Int(progress * 100))%)"
        progressView.progress = Float(progress)
        
        // Add log entries
        if todayEntries.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No water intake logged today"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = .gray
            emptyLabel.font = .systemFont(ofSize: 14)
            logsStackView.addArrangedSubview(emptyLabel)
        } else {
            todayEntries.forEach { entry in
                let logView = createWaterIntakeLogView(for: entry)
                logsStackView.addArrangedSubview(logView)
            }
        }
        
        layoutIfNeeded()
    }
    
    private func createWaterIntakeLogView(for entry: WaterIntakeEntry) -> UIView {
        let container = UIView()
        container.backgroundColor = viewBackgroundColor
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabel = UILabel()
        timeLabel.text = entry.time
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let amountLabel = UILabel()
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedAmount = formatter.string(from: NSNumber(value: Int(entry.value))) ?? "0"
        amountLabel.text = "\(formattedAmount) ml"
        amountLabel.font = .systemFont(ofSize: 14, weight: .medium)
                amountLabel.textColor = accentColor
                amountLabel.translatesAutoresizingMaskIntoConstraints = false
                
                let actionsStackView = UIStackView()
                actionsStackView.axis = .horizontal
                actionsStackView.spacing = 12
                actionsStackView.translatesAutoresizingMaskIntoConstraints = false
                
                let editButton = UIButton(type: .system)
                editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
                editButton.tintColor = .systemBlue
                editButton.tag = entry.id
                editButton.addTarget(self, action: #selector(editEntryTapped), for: .touchUpInside)
                
                let deleteButton = UIButton(type: .system)
                deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
                deleteButton.tintColor = .systemRed
                deleteButton.tag = entry.id
                deleteButton.addTarget(self, action: #selector(deleteEntryTapped), for: .touchUpInside)
                
                actionsStackView.addArrangedSubview(editButton)
                actionsStackView.addArrangedSubview(deleteButton)
                
                container.addSubview(timeLabel)
                container.addSubview(amountLabel)
                container.addSubview(actionsStackView)
                
                NSLayoutConstraint.activate([
                    container.heightAnchor.constraint(equalToConstant: 50),
                    
                    timeLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                    timeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    
                    amountLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    amountLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    
                    actionsStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                    actionsStackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    
                    editButton.widthAnchor.constraint(equalToConstant: 24),
                    editButton.heightAnchor.constraint(equalToConstant: 24),
                    deleteButton.widthAnchor.constraint(equalToConstant: 24),
                    deleteButton.heightAnchor.constraint(equalToConstant: 24)
                ])
                
                return container
            }
            
            @objc private func editEntryTapped(_ sender: UIButton) {
                guard let entry = intakeEntries.first(where: { $0.id == sender.tag }) else { return }
                showEditPopup(for: entry)
            }
            
            @objc private func deleteEntryTapped(_ sender: UIButton) {
                delegate?.didDeleteWater(entryId: sender.tag)
            }
            
            private func showEditPopup(for entry: WaterIntakeEntry) {
                guard let viewController = findViewController() else { return }
                
                let alert = UIAlertController(
                    title: "Edit Water Intake",
                    message: "Update amount in milliliters",
                    preferredStyle: .alert
                )
                
                alert.addTextField { textField in
                    textField.placeholder = "Amount (ml)"
                    textField.keyboardType = .numberPad
                    textField.text = String(format: "%.0f", entry.value)
                }
                
                let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                    guard let text = alert.textFields?[0].text,
                          let amount = Double(text) else { return }
                    
                    self?.delegate?.didEditWater(entryId: entry.id, newAmount: amount)
                }
                
                alert.addAction(updateAction)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                viewController.present(alert, animated: true)
            }
            
            private func findViewController() -> UIViewController? {
                var responder: UIResponder? = self
                while let nextResponder = responder?.next {
                    if let viewController = nextResponder as? UIViewController {
                        return viewController
                    }
                    responder = nextResponder
                }
                return nil
            }
            
            // MARK: - Layout
            override var intrinsicContentSize: CGSize {
                let topHeight: CGFloat = 16 + // Top padding
                    24 + // Title height
                    16 + // Space after title
                    20 + // Daily goal label
                    8 + // Space after daily goal
                    8 + // Progress view
                    8 + // Space after progress
                    20 + // Progress label
                    16 + // Space after progress label
                    60 + // Quick add buttons
                    16 + // Space after buttons
                    20 // Daily log label
                
                let logsHeight = CGFloat(intakeEntries.count) * 50 + // Height per entry
                    CGFloat(max(0, intakeEntries.count - 1)) * 8 + // Spacing between entries
                    16 // Bottom padding
                
                return CGSize(width: UIView.noIntrinsicMetric, height: topHeight + logsHeight)
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                invalidateIntrinsicContentSize()
            }
        }
