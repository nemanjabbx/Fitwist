import UIKit
import Foundation

protocol WaterIntakeViewDelegate: AnyObject {
    func didAddWater(amount: Double)
    func didDeleteWater(entryId: Int)
}

class WaterIntakeView: UIView, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    var onAddTapped: (() -> Void)?
    weak var delegate: WaterIntakeViewDelegate?
    private var intakeEntries: [WaterIntakeEntry] = []
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Water Intake"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.trackTintColor = UIColor.systemBlue.withAlphaComponent(0.2)
        progress.progressTintColor = .systemBlue
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.layer.sublayers![1].cornerRadius = 4
        progress.subviews[1].clipsToBounds = true
        return progress
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .systemBlue
        return label
    }()
    
    private let dailyGoalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    private let quickAddButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 12
        return stack
    }()
    
    private let dailyLogLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Today's Logs"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .darkGray
        return label
    }()
    
    private let intakeTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.isScrollEnabled = true
        table.allowsSelection = false
        // Dodaj ovo:
        table.estimatedRowHeight = 50
        table.rowHeight = UITableView.automaticDimension
        return table
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .clear
        
        addSubview(backgroundView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(progressView)
        backgroundView.addSubview(progressLabel)
        backgroundView.addSubview(quickAddButtonsStack)
        backgroundView.addSubview(addButton)
        backgroundView.addSubview(dailyGoalLabel)
        backgroundView.addSubview(dailyLogLabel)
        backgroundView.addSubview(intakeTableView)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        intakeTableView.register(WaterIntakeCell.self, forCellReuseIdentifier: WaterIntakeCell.identifier)
        intakeTableView.delegate = self
        intakeTableView.dataSource = self
        
        setupQuickAddButtons()
        setupConstraints()
    }
    
    private func setupQuickAddButtons() {
        let amounts = [
            (100, "water.cup.coffee"),
            (200, "water.glass.small"),
            (300, "water.glass.medium"),
            (400, "water.glass.large"),
            (500, "water.bottle.small")
        ]
        
        quickAddButtonsStack.isUserInteractionEnabled = true
        quickAddButtonsStack.distribution = .fillEqually // promeni u fillEqually
        quickAddButtonsStack.spacing = 8 // smanji spacing
        
        for (amount, iconName) in amounts {
            let button = createQuickAddButton(amount: amount, iconName: iconName)
            quickAddButtonsStack.addArrangedSubview(button)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            
            addButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            
            dailyGoalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dailyGoalLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            dailyGoalLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            
            progressView.topAnchor.constraint(equalTo: dailyGoalLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            progressLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            
            quickAddButtonsStack.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 16),
            quickAddButtonsStack.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            quickAddButtonsStack.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            quickAddButtonsStack.heightAnchor.constraint(equalToConstant: 60),
            
            dailyLogLabel.topAnchor.constraint(equalTo: quickAddButtonsStack.bottomAnchor, constant: 16),
            dailyLogLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            
            intakeTableView.topAnchor.constraint(equalTo: dailyLogLabel.bottomAnchor, constant: 8),
            intakeTableView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16), // dodaj marginu
            intakeTableView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16), // dodaj marginu
            intakeTableView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createQuickAddButton(amount: Int, iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tag = amount
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .top
        config.imagePadding = 4  // smanji padding
        config.title = "\(amount)ml"
        config.titleAlignment = .center
        
        let titleAttr = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .regular) // smanji font
        ]
        config.attributedTitle = AttributedString(
            "\(amount)ml",
            attributes: AttributeContainer(titleAttr)
        )
        
        button.configuration = config
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(quickAddWaterTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50), // smanji visinu
            button.widthAnchor.constraint(equalToConstant: 45)  // smanji širinu
        ])
        
        return button
    }
    
    @objc private func addButtonTapped() {
        onAddTapped?()
    }
    
    @objc private func quickAddWaterTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.didAddWater(amount: Double(sender.tag))
        }
    }
    
    // MARK: - Public Methods
    func updateWaterLogs(entries: [WaterIntakeEntry], goal: Double) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todayEntries = entries.filter { entry in
            let entryDay = calendar.startOfDay(for: entry.parsedDate)
            return entryDay == today
        }
        
        // Sortiraj po vremenu unosa
        intakeEntries = todayEntries.sorted { $0.parsedDate > $1.parsedDate }
        
        // Izračunaj ukupnu količinu vode samo za današnje unose
        let total = todayEntries.reduce(0) { $0 + $1.value }
        let progress = min(todayEntries.reduce(0) { $0 + $1.value } / goal, 1.0)
            
            dailyGoalLabel.text = String(format: "Daily Goal: %.0f ml • Today's Intake: %.0f ml", goal, total)
        progressLabel.text = String(format: "%.0f ml / %.0f ml (%.0f%%)", total, goal, progress * 100)
        progressView.progress = Float(progress)
        
        intakeTableView.reloadData()
        layoutIfNeeded()
    }
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intakeEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WaterIntakeCell.identifier, for: indexPath) as? WaterIntakeCell else {
            return UITableViewCell()
        }
        
        let entry = intakeEntries[indexPath.row]
        cell.configure(with: entry)
        cell.onDelete = { [weak self] in
            self?.delegate?.didDeleteWater(entryId: entry.id)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - WaterIntakeCell
class WaterIntakeCell: UITableViewCell {
    static let identifier = "WaterIntakeCell"
    
    var onDelete: (() -> Void)?
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 2
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(timeLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            timeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            amountLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                        deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        deleteButton.widthAnchor.constraint(equalToConstant: 24),
                        deleteButton.heightAnchor.constraint(equalToConstant: 24)
                    ])
                    
                    deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
                }
                
                @objc private func deleteButtonTapped() {
                    onDelete?()
                }
                
                func configure(with entry: WaterIntakeEntry) {
                    timeLabel.text = entry.time
                    amountLabel.text = "\(Int(entry.value))ml"
                }
            }
