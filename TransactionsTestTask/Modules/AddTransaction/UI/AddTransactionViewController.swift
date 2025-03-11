//
//  AddTransactionViewController.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import UIKit

final class AddTransactionViewController: NiblessViewController {
    var didAddTransaction: ((String, String) -> Void)?
    var didEnterAmount: ((String) -> Void)?
    var didMoveToParent: (() -> Void)?
    
    private let addTransactionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .medium)
        return label
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var addTransactionButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.buttonSize = .large
        configuration.titleTextAttributesTransformer = .init { incoming in
            var outgoing = incoming
            outgoing.font = .boldSystemFont(ofSize: 20)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private let categoryPickerView = {
        let view = UIPickerView()
        return view
    }()
    
    private var categories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        amountTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        addTransactionButton.addTarget(self, action: #selector(didTapAddTransactionButton), for: .touchUpInside)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        didMoveToParent?()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        let mainStackView = UIVerticalStackView(
            arrangedSubviews: [
                addTransactionLabel,
                amountTextField,
                categoryPickerView,
                addTransactionButton
            ]
        ).withVerticalAlignmnet(.top) { $0.spacing = 12 }
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = .init(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
        view.addSubview(mainStackView)
        NSLayoutConstraint.activate(
            [
                mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )        
    }
}

extension AddTransactionViewController: UIPickerViewDataSource {
    func numberOfComponents(
        in pickerView: UIPickerView
    ) -> Int {
        1
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        categories.count
    }
}

extension AddTransactionViewController: UIPickerViewDelegate {
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        categories[row]
    }
}

extension AddTransactionViewController: AddTransactionView {
    func display(_ viewModel: AddTransactionViewModel) {
        addTransactionLabel.text = viewModel.title
        amountTextField.placeholder = viewModel.amountPlaceholder
        categories = viewModel.categories
        addTransactionButton.configuration?.title = viewModel.addTransactionButtonTitle
    }
    
    func setAddTransactionButtonEnabled(_ isEnabled: Bool) {
        addTransactionButton.isEnabled = isEnabled
    }
}

private extension AddTransactionViewController {
    @objc
    func textChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        didEnterAmount?(text)
    }
    
    @objc
    func didTapAddTransactionButton() {
        let selectedRow = categoryPickerView.selectedRow(inComponent: 0)
        let selectedCateogry = categories[selectedRow]
        let amountText = amountTextField.text ?? ""
        didAddTransaction?(amountText, selectedCateogry)
    }
}
