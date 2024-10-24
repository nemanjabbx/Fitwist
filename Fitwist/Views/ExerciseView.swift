import UIKit

protocol ExerciseViewDelegate: AnyObject {
    func didTapAddExercise()
    func didRequestDelete(exercise: ExerciseEntry)
    func didRequestEdit(exercise: ExerciseEntry)
}

class ExerciseView: UIView {
    // MARK: - Properties
    weak var delegate: ExerciseViewDelegate?
    private var exercises: [ExerciseEntry] = [] {
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Exercise Tracking"
        label.font = .systemFont(ofSize: 20, weight: .bold)
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
    
    private let exerciseTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "figure.run.circle"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "No exercises recorded yet\nTap + to add your first exercise"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        return view
    }()
    
    // Static list of exercise types
    static let exerciseTypes = [
        "Walking", "Running", "Cycling", "Swimming", "Gym Workout",
        "Yoga", "Pilates", "Hiking", "Weightlifting", "Aerobics",
        "CrossFit", "Dancing", "Boxing", "Rowing", "Rock Climbing",
        "Martial Arts", "Skiing", "Snowboarding", "Jump Rope", "Tennis",
        "Basketball", "Soccer", "Volleyball", "Badminton", "Golf",
        "Surfing", "Paddleboarding", "Rollerblading", "Skateboarding"
    ].sorted()
    
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
        containerView.addSubview(addButton)
        containerView.addSubview(exerciseTableView)
        containerView.addSubview(emptyStateView)
        
        exerciseTableView.delegate = self
        exerciseTableView.dataSource = self
        exerciseTableView.register(ExerciseCell.self, forCellReuseIdentifier: "ExerciseCell")
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        setupConstraints()
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
            
            exerciseTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            exerciseTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            exerciseTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            exerciseTableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: exerciseTableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: exerciseTableView.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        delegate?.didTapAddExercise()
    }
    
    // MARK: - Public Methods
    public func updateExercises(_ exercises: [ExerciseEntry]) {
        self.exercises = exercises
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        emptyStateView.isHidden = !exercises.isEmpty
        exerciseTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ExerciseView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath) as? ExerciseCell else {
            return UITableViewCell()
        }
        
        let exercise = exercises[indexPath.row]
        cell.configure(with: exercise)
        
        cell.onDelete = { [weak self] in
            self?.delegate?.didRequestDelete(exercise: exercise)
        }
        
        cell.onEdit = { [weak self] in
            self?.delegate?.didRequestEdit(exercise: exercise)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - ExerciseCell
class ExerciseCell: UITableViewCell {
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let exerciseTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        return button
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
        containerView.addSubview(exerciseTypeLabel)
        containerView.addSubview(valueLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(actionsStackView)
        
        actionsStackView.addArrangedSubview(editButton)
        actionsStackView.addArrangedSubview(deleteButton)
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            exerciseTypeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            exerciseTypeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            exerciseTypeLabel.trailingAnchor.constraint(equalTo: actionsStackView.leadingAnchor, constant: -12),
            
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            dateLabel.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 8),
            dateLabel.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            
            actionsStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            actionsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            editButton.widthAnchor.constraint(equalToConstant: 24),
            editButton.heightAnchor.constraint(equalToConstant: 24),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    @objc private func editButtonTapped() {
        onEdit?()
    }
    
    @objc private func deleteButtonTapped() {
        onDelete?()
    }
    
    func configure(with exercise: ExerciseEntry) {
        exerciseTypeLabel.text = exercise.exerciseType
        valueLabel.text = "\(Int(exercise.value)) minutes"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        if let date = dateFormatter.date(from: exercise.date) {
            dateFormatter.dateFormat = "HH:mm"
            dateLabel.text = dateFormatter.string(from: date)
        }
    }
}
