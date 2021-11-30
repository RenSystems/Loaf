//
//  Loaf.swift
//  Loaf
//
//  Created by Mat Schmid on 2019-02-04.
//  Copyright © 2019 Mat Schmid. All rights reserved.
//

import UIKit

public extension Loaf.Style {
    static let `default` = Loaf.Style(contentInsets: .init(top: 12, left: 14, bottom: 11, right: 17))
}


final public class Loaf {
    
    // MARK: - Specifiers
    
    /// Define a custom style for the loaf.
    public struct Style {
        /// Specifies the position of the icon on the loaf. (Default is `.left`)
        ///
        /// - left: The icon will be on the left of the text
        /// - right: The icon will be on the right of the text
        public enum ContentAlignment {
            case leftToRight
            case rightToLeft
        }
        
        /// Specifies the width of the Loaf. (Default is `.fixed(280)`)
        ///
        /// - fixed: Specified as pixel size. i.e. 280
        /// - screenPercentage: Specified as a ratio to the screen size. This value must be between 0 and 1. i.e. 0.8
        public enum Width {
            case fixed(CGFloat)
            case screenPercentage(CGFloat)
        }
        
        /// The background color of the loaf.
        let backgroundColor: UIColor
        
        /// The color of the label's text
        let textColor: UIColor
        
        /// The color of the button's title text
        let actionButtonTextColor: UIColor
        
        /// The font of the button title
        let actionButtonFont: UIFont
        
        /// The color of the icon (Assuming it's rendered as template)
        let tintColor: UIColor
        
        /// The font of the label
        let font: UIFont
        
        
        /// The icon on the loaf
        let icon: UIImage?
        
        /// The alignment of the text within the Loaf
        let textAlignment: NSTextAlignment
        
        /// The position of the icon
        let contentAlignment: ContentAlignment
        
        /// The width of the loaf
        let width: Width
        
        let contentInsets: UIEdgeInsets
        
        public init(
            backgroundColor: UIColor = .white,
            textColor: UIColor = .white,
            tintColor: UIColor = .white,
            actionButtonTextColor: UIColor = .white,
            actionButtonFont: UIFont = .systemFont(ofSize: 14, weight: .medium),
            font: UIFont = .systemFont(ofSize: 14, weight: .medium),
            icon: UIImage? = UIImage(systemName: "info.circle"),
            textAlignment: NSTextAlignment = .left,
            contentAlignment: ContentAlignment = .leftToRight,
            width: Width = .screenPercentage(0.92),
            contentInsets: UIEdgeInsets = .zero) {
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.tintColor = tintColor
            self.actionButtonTextColor = actionButtonTextColor
            self.actionButtonFont = actionButtonFont
            self.font = font
            self.icon = icon
            self.textAlignment = textAlignment
            self.contentAlignment = contentAlignment
            self.width = width
            self.contentInsets = contentInsets
        }
    }
    
    /// Defines the loaction to display the loaf. (Default is `.bottom`)
    ///
    /// - top: Top of the display
    /// - bottom: Bottom of the display
    public enum Location {
        case top
        case bottom
    }
    
    /// Defines either the presenting or dismissing direction of loaf. (Default is `.vertical`)
    ///
    /// - left: To / from the left
    /// - right: To / from the right
    /// - vertical: To / from the top or bottom (depending on the location of the loaf)
    public enum Direction {
        case left
        case right
        case vertical
    }
    
    /// Defines the duration of the loaf presentation. (Default is .`avergae`)
    ///
    /// - short: 2 seconds
    /// - average: 4 seconds
    /// - long: 8 seconds
    /// - custom: A custom duration (usage: `.custom(5.0)`)
    public enum Duration {
        case short
        case average
        case long
        case custom(TimeInterval)
        
        var length: TimeInterval {
            switch self {
            case .short:   return 2.0
            case .average: return 4.0
            case .long:    return 8.0
            case .custom(let timeInterval):
                return timeInterval
            }
        }
    }
    
    // Reason a Loaf was dismissed
    public enum DismissalReason {
        case performedAction
        case tapped
        case timedOut
    }
    
    // MARK: - Properties
    public typealias LoafCompletionHandler = ((DismissalReason) -> Void)?
    var message: String
    var action: String
    var style: Style
    var location: Location
    var duration: Duration = .average
    var presentingDirection: Direction
    var dismissingDirection: Direction
    var completionHandler: LoafCompletionHandler = nil
    weak var sender: UIViewController?
    
    // MARK: - Public methods
    public init(_ message: String,
                action: String,
                style: Style = .default,
                location: Location = .top,
                presentingDirection: Direction = .vertical,
                dismissingDirection: Direction = .vertical,
                sender: UIViewController) {
        self.message = message
        self.action = action
        self.style = style
        self.location = location
        self.presentingDirection = presentingDirection
        self.dismissingDirection = dismissingDirection
        self.sender = sender
    }
    
    /// Show the loaf for a specified duration. (Default is `.average`)
    ///
    /// - Parameter duration: Length the loaf will be presented
    public func show(_ duration: Duration = .average, completionHandler: LoafCompletionHandler = nil) {
        self.duration = duration
        self.completionHandler = completionHandler
        LoafManager.shared.queueAndPresent(self)
    }
    
    /// Manually dismiss a currently presented Loaf
    ///
    /// - Parameter animated: Whether the dismissal will be animated
    public static func dismiss(sender: UIViewController, animated: Bool = true){
        guard LoafManager.shared.isPresenting else { return }
        guard let vc = sender.presentedViewController as? Notification else { return }
        vc.dismiss(animated: animated) {
            vc.delegate?.loafDidDismiss()
        }
    }
}

final fileprivate class LoafManager: LoafDelegate {
    static let shared = LoafManager()
    
    fileprivate var queue = Queue<Loaf>()
    fileprivate var isPresenting = false
    
    fileprivate func queueAndPresent(_ loaf: Loaf) {
        queue.enqueue(loaf)
        presentIfPossible()
    }
    
    func loafDidDismiss() {
        isPresenting = false
        presentIfPossible()
    }
    
    fileprivate func presentIfPossible() {
        guard isPresenting == false, let loaf = queue.dequeue(), let sender = loaf.sender else { return }
        isPresenting = true
        let loafVC = LoafViewController(loaf)
        loafVC.delegate = self
        sender.present(loafVC)
    }
}

protocol LoafDelegate: AnyObject {
    func loafDidDismiss()
}

protocol Notification {
    init(_ toast: Loaf)
    var delegate: LoafDelegate? { get set }
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}


private struct Queue<T> {
    fileprivate var array = [T]()
    
    mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    mutating func dequeue() -> T? {
        if array.isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
}

final class LoafViewController: UIViewController, Notification {
    
    let loaf: Loaf
    
    let label = UILabel()
    let imageView = UIImageView(image: nil)
    var transDelegate: UIViewControllerTransitioningDelegate
    var button = UIButton(type: .system)
    
    weak var delegate: LoafDelegate?
    
    init(_ toast: Loaf) {
        self.loaf = toast
        self.transDelegate = Manager(loaf: toast, size: .zero)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updatePreferredContentSize() {
        let size = view.systemLayoutSizeFitting(.init(width: width(for: loaf.style), height: .greatestFiniteMagnitude),
                                     withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        self.preferredContentSize = size
    }
    
    private func width(for style: Loaf.Style) -> CGFloat {
        var width: CGFloat = UIScreen.main.bounds.width
        
        switch loaf.style.width {
        case .fixed(let value):
            width = value
        case .screenPercentage(let percentage):
            guard 0...1 ~= percentage else { return width }
            width = width * percentage
        }
        
        return width
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.setTitle(loaf.action, for: .normal)
        button.setTitleColor(loaf.style.actionButtonTextColor, for: .normal)
        button.titleLabel?.font = loaf.style.actionButtonFont
        button.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
        
        label.text = loaf.message
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        label.font = loaf.style.font
        label.textColor = loaf.style.textColor
        
        label.textAlignment = loaf.style.textAlignment
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = loaf.style.icon
        imageView.tintColor = loaf.style.tintColor
        
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 14
        blurView.layer.cornerCurve = .continuous
        
        view.addSubview(blurView)
        view.backgroundColor = loaf.style.backgroundColor
        
        let shadowView = MultiShadowView(frame: .zero)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.layer.cornerCurve = .continuous
        shadowView.layer.cornerRadius = 14
        view.insertSubview(shadowView, at: 0)

        shadowView.shadows = [
            .init(color: .black, radius: 4, offset: .init(x: 0, y: 1), opacity: 0.1),
            .init(color: .black, radius: 6, offset: .init(x: 0, y: 2), opacity: 0.11),
        ]
    
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            shadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shadowView.topAnchor.constraint(equalTo: view.topAnchor),
            shadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
       
    
        buildLayout(for: loaf.style.contentAlignment, contentInsets: loaf.style.contentInsets, showsIcon: imageView.image != nil)
        updatePreferredContentSize()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dismissSelfAfter(loaf.duration.length)
    }
    
    private func dismissSelfAfter(_ timeInterval: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: {
            self.dismiss(animated: true) { [weak self] in
                self?.delegate?.loafDidDismiss()
                self?.loaf.completionHandler?(.timedOut)
            }
        })
    }
    
    @objc
    private func handleButtonAction() {
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.loafDidDismiss()
            self?.loaf.completionHandler?(.performedAction)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentSize()
    }
    
    @objc private func handleTap() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.loafDidDismiss()
            self?.loaf.completionHandler?(.tapped)
        }
    }
    
    private func buildLayout(for contentAligment: Loaf.Style.ContentAlignment, contentInsets: UIEdgeInsets, showsIcon: Bool = true) {
        let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentInsets.left),
            container.topAnchor.constraint(equalTo: view.topAnchor, constant: contentInsets.top),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentInsets.right),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -contentInsets.bottom),
        ])
       
    
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        container.addSubview(button)
        
        if showsIcon {
            container.addSubview(imageView)
        }

        switch contentAligment {
        case .leftToRight:
            
            if showsIcon {
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                    imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: 24),
                    imageView.widthAnchor.constraint(equalToConstant: 24)
                ])
            }
            
            if showsIcon {
                label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 13).isActive = true
            }else {
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
            }
            
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor, constant: -8),
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4.5),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4.5),
                button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
        
        case .rightToLeft:
            
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                button.centerYAnchor.constraint(equalTo: container.centerYAnchor),

                label.leadingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -8),
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4.5),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4.5)
            ])
            
            if showsIcon {
                label.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -13).isActive = true
            }else {
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
            }
            
            if showsIcon {
                NSLayoutConstraint.activate([
                    imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                    imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: 24),
                    imageView.widthAnchor.constraint(equalToConstant: 24)
                ])
            }
        }
    }
}


class MultiShadowView: UIView {
    struct Shadow {
        let color: UIColor
        let radius: CGFloat
        let offset: CGPoint
        let opacity: CGFloat
    }
    
    override var bounds: CGRect {
        didSet {
            layer.mask = makeCutoutMask(maxRadius: maxShadowRadius, maxOffset: maxShadowOffset)
        }
    }
    
    var shadows: [Shadow] = [] {
        didSet {
            layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            for shadow in shadows {
                let sublayer = makeSublayer(for: shadow)
                layer.addSublayer(sublayer)
            }
        }
    }
    
    private var maxShadowOffset: CGPoint {
        shadows.reduce(into: CGPoint(x: 0, y: 0)) { memo, shadow in
            memo.x = max(shadow.offset.x, memo.x)
            memo.y = max(shadow.offset.y, memo.y)
        }
    }
    
    private var maxShadowRadius: CGFloat {
        shadows.max { $0.radius < $1.radius }?.radius ?? 0.0
    }
    
    private func makeSublayer(for shadow: Shadow) -> CALayer {
        let layer = CALayer()
        // XXX: do not set layer.delegate = self, this will cause a crash during VC transitions
        layer.shadowColor = shadow.color.cgColor
        layer.shadowRadius = shadow.radius
        layer.shadowOffset = CGSize(width: shadow.offset.x, height: shadow.offset.y)
        layer.shadowOpacity = Float(shadow.opacity)
        return layer
    }
    
    /// Creates a `CAShapeLayer` that excludes the layer's background from the drawn shadows.
    private func makeCutoutMask(maxRadius radius: CGFloat, maxOffset offset: CGPoint) -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addPath(UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath)
        
        let shadowSize = CGSize(width: offset.x + radius*2, height: offset.y + radius*2)
        let boundsPlusShadow = bounds.inset(by: .init(top: -shadowSize.height, left: -shadowSize.width, bottom: -shadowSize.height, right: -shadowSize.width))
        path.addPath(UIBezierPath(roundedRect: boundsPlusShadow, cornerRadius: radius).cgPath)
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = .evenOdd
        return maskLayer
    }
    
    override func layoutSublayers(of layer: CALayer) {
        let shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.sublayers?.forEach {
            $0.frame = layer.bounds
            $0.shadowPath = shadowPath
        }
    }
}
