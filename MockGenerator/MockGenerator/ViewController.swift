//
//  ViewController.swift
//  MockGenerator
//
//  Created by Rustem Sayfullin on 16.12.2024.
//

import Cocoa

class ViewController: NSViewController {
    
    // UI-компоненты
    private let containerView: NSStackView = {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let protocolLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Enter Protocol Code:")
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var protocolScrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autoresizingMask = [.width, .height]

        // Создаем NSTextView
        let textView = NSTextView()
        textView.minSize = NSSize(width: 0, height: 400)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: self.view.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        // Добавляем NSTextView в NSScrollView
        scrollView.documentView = textView

        return scrollView
    }()
    
    private var protocolTextView: NSTextView {
        return protocolScrollView.documentView as! NSTextView
    }
    
    private let protocolInsertButton: NSButton = {
        let button = NSButton()
        button.title = "Insert"
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let mockLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Generated Mock Code:")
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var mockScrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder
        
        // Создаем NSTextView
        let textView = NSTextView()
        textView.minSize = NSSize(width: 0, height: 400)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: self.view.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        // Добавляем NSTextView в NSScrollView
        scrollView.documentView = textView
        return scrollView
    }()
    
    private var mockTextView: NSTextView {
        return mockScrollView.documentView as! NSTextView
    }
    
    private let mockCopyButton: NSButton = {
        let button = NSButton()
        button.title = "Copy"
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let generateButton: NSButton = {
        let button = NSButton()
        button.title = "Generate Mock"
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let service = MockGeneratorService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // Настройка интерфейса
    private func setupUI() {
        // Добавляем элементы в StackView
        containerView.addArrangedSubview(protocolLabel)
        containerView.addArrangedSubview(protocolScrollView)
        containerView.addArrangedSubview(mockLabel)
        containerView.addArrangedSubview(mockScrollView)
        containerView.addArrangedSubview(generateButton)
        
        // Добавляем StackView на экран
        view.addSubview(containerView)
        view.addSubview(protocolInsertButton)
        view.addSubview(mockCopyButton)
        
        // Ограничения
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            protocolScrollView.heightAnchor.constraint(equalToConstant: 400),
            mockScrollView.heightAnchor.constraint(equalToConstant: 400),
            
            protocolInsertButton.trailingAnchor.constraint(
                equalTo: protocolScrollView.trailingAnchor,
                constant: -10
            ),
            protocolInsertButton.bottomAnchor.constraint(
                equalTo: protocolScrollView.topAnchor,
                constant: -10
            ),
            
            mockCopyButton.trailingAnchor.constraint(
                equalTo: mockScrollView.trailingAnchor,
                constant: -10
            ),
            mockCopyButton.bottomAnchor.constraint(
                equalTo: mockScrollView.topAnchor,
                constant: -10
            ),
        ])
    }
    
    // Настройка действий
    private func setupActions() {
        generateButton.target = self
        generateButton.action = #selector(generateMockAction)
        
        protocolInsertButton.target = self
        protocolInsertButton.action = #selector(insertTextAction)
        
        mockCopyButton.target = self
        mockCopyButton.action = #selector(copyTextAction)
    }
    
    // Генерация Mock
    @objc private func generateMockAction() {
        let protocolCode = protocolTextView.string
        let generatedMock = service.generateMock(from: protocolCode)
        mockTextView.string = generatedMock
    }
    
    // Вставка текста в поле протокола
    @objc private func insertTextAction() {
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string) {
            protocolTextView.string = text
        }
    }
    
    // Копирование текста из Mock
    @objc private func copyTextAction() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(mockTextView.string, forType: .string)
    }
}
