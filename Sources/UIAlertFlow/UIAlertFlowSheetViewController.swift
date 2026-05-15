//
//  UIAlertFlowSheetViewController.swift
//  UIAlertFlow
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

import UIKit

@MainActor
protocol UIAlertFlowSheetViewControllerDelegate: AnyObject {
    func uiAlertFlowSheetViewControllerDidDismiss(_ controller: UIAlertFlowSheetViewController)
}

final class UIAlertFlowSheetViewController: UIViewController {
    weak var sheetDelegate: UIAlertFlowSheetViewControllerDelegate?

    private let items: [UIAlertFlowItem]
    private let configuration: UIAlertFlowConfiguration

    private let pagingScrollView = UIScrollView()
    private let pagesContainer = UIView()
    private let bottomBar = UIVisualEffectView(effect: nil)
    private let bottomContentStack = UIStackView()
    private let pageIndicatorStack = UIStackView()
    private let actionButton = UIButton(type: .system)

    private var pageScrollViews: [UIScrollView] = []
    private var pageViews: [NoteItemView] = []
    private var pageIndicatorPills: [UIView] = []
    private var pageIndicatorWidthConstraints: [NSLayoutConstraint] = []
    private var currentPage = 0

    private var isIPad: Bool {
        traitCollection.userInterfaceIdiom == .pad
    }

    init(items: [UIAlertFlowItem], configuration: UIAlertFlowConfiguration) {
        self.items = items
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAppearance()
        setUpPaging()
        setUpBottomBar()
        view.bringSubviewToFront(bottomBar)
        updateChrome(animated: false)
        updatePagePlayback()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePagingContentInset()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isBeingDismissed || presentingViewController == nil else { return }
        notifyDismissIfNeeded()
    }

    private var didNotifyDismiss = false

    private func notifyDismissIfNeeded() {
        guard !didNotifyDismiss else { return }
        didNotifyDismiss = true
        sheetDelegate?.uiAlertFlowSheetViewControllerDidDismiss(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePagingContentInset()
    }

    private func setUpAppearance() {
        view.backgroundColor = .systemBackground
        pagingScrollView.backgroundColor = .systemBackground

        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.prefersGrabberVisible = true
            if isIPad {
                sheet.detents = [.large()]
            } else {
                sheet.detents = [.custom { context in
                    context.maximumDetentValue * 0.85
                }]
            }

            if #available(iOS 26, *) {
                sheet.preferredCornerRadius = 24
            }
        }
    }

    private func setUpPaging() {
        pagingScrollView.translatesAutoresizingMaskIntoConstraints = false
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.showsVerticalScrollIndicator = false
        pagingScrollView.delegate = self
        pagingScrollView.alwaysBounceVertical = false
        pagingScrollView.backgroundColor = .systemBackground

        pagesContainer.translatesAutoresizingMaskIntoConstraints = false
        pagesContainer.backgroundColor = .systemBackground

        pagingScrollView.addSubview(pagesContainer)
        view.addSubview(pagingScrollView)

        NSLayoutConstraint.activate([
            pagingScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            pagingScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pagesContainer.topAnchor.constraint(equalTo: pagingScrollView.contentLayoutGuide.topAnchor),
            pagesContainer.leadingAnchor.constraint(equalTo: pagingScrollView.contentLayoutGuide.leadingAnchor),
            pagesContainer.trailingAnchor.constraint(equalTo: pagingScrollView.contentLayoutGuide.trailingAnchor),
            pagesContainer.bottomAnchor.constraint(equalTo: pagingScrollView.contentLayoutGuide.bottomAnchor),
            pagesContainer.heightAnchor.constraint(equalTo: pagingScrollView.frameLayoutGuide.heightAnchor),
        ])

        var previousPageTrailing = pagesContainer.leadingAnchor

        for item in items {
            let itemView = NoteItemView(item: item, configuration: configuration)
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.alwaysBounceVertical = true
            scrollView.showsVerticalScrollIndicator = true
            scrollView.backgroundColor = .systemBackground

            itemView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(itemView)
            pagesContainer.addSubview(scrollView)

            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: pagesContainer.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: pagesContainer.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: previousPageTrailing),
                scrollView.widthAnchor.constraint(equalTo: pagingScrollView.frameLayoutGuide.widthAnchor),

                itemView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                itemView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                itemView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                itemView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -80),
                itemView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            ])

            previousPageTrailing = scrollView.trailingAnchor
            pageScrollViews.append(scrollView)
            pageViews.append(itemView)
        }

        if let lastPage = pageScrollViews.last {
            lastPage.trailingAnchor.constraint(equalTo: pagesContainer.trailingAnchor).isActive = true
        }
    }

    private func updatePagingContentInset() {
        let bottomInset = max(bottomBar.bounds.height, 1)
        for scrollView in pageScrollViews {
            scrollView.contentInset.bottom = bottomInset
            scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        }
    }

    private func setUpBottomBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .white
        bottomBar.contentView.backgroundColor = .white

        bottomContentStack.translatesAutoresizingMaskIntoConstraints = false
        bottomContentStack.axis = .vertical
        bottomContentStack.spacing = 16
        bottomContentStack.alignment = .center

        pageIndicatorStack.axis = .horizontal
        pageIndicatorStack.spacing = 6
        pageIndicatorStack.alignment = .center
        pageIndicatorStack.isHidden = items.count <= 1

        if items.count > 1 {
            pageIndicatorPills = items.indices.map { index in
                let pill = UIView()
                pill.layer.cornerRadius = 3.5
                pill.translatesAutoresizingMaskIntoConstraints = false
                pill.heightAnchor.constraint(equalToConstant: 7).isActive = true
                let width = pill.widthAnchor.constraint(equalToConstant: index == 0 ? 14 : 7)
                width.isActive = true
                pageIndicatorWidthConstraints.append(width)
                pageIndicatorStack.addArrangedSubview(pill)
                return pill
            }
        }

        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.cornerStyle = .medium
        buttonConfig.baseBackgroundColor = configuration.accentColor
        buttonConfig.baseForegroundColor = .white
        buttonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .preferredFont(forTextStyle: .body).with(weight: .bold)
            return outgoing
        }
        buttonConfig.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0)
        actionButton.configuration = buttonConfig
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        actionButton.isHidden = items.isEmpty

        bottomContentStack.addArrangedSubview(pageIndicatorStack)
        bottomContentStack.addArrangedSubview(actionButton)

        bottomBar.contentView.addSubview(bottomContentStack)
        view.addSubview(bottomBar)

        let bottomPadding: CGFloat = isIPad ? 24 : 0

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            bottomContentStack.topAnchor.constraint(equalTo: bottomBar.contentView.topAnchor, constant: 14),
            bottomContentStack.leadingAnchor.constraint(equalTo: bottomBar.contentView.leadingAnchor),
            bottomContentStack.trailingAnchor.constraint(equalTo: bottomBar.contentView.trailingAnchor),
            bottomContentStack.bottomAnchor.constraint(
                equalTo: bottomBar.contentView.safeAreaLayoutGuide.bottomAnchor,
                constant: -bottomPadding
            ),

            actionButton.leadingAnchor.constraint(equalTo: bottomContentStack.leadingAnchor, constant: 28),
            actionButton.trailingAnchor.constraint(equalTo: bottomContentStack.trailingAnchor, constant: -28),
        ])
    }

    @objc private func actionButtonTapped() {
        if isOnLastPage {
            dismiss(animated: true)
        } else {
            let nextPage = min(currentPage + 1, items.count - 1)
            scrollToPage(nextPage, animated: true)
        }
    }

    private func scrollToPage(_ page: Int, animated: Bool) {
        let offsetX = pagingScrollView.bounds.width * CGFloat(page)
        pagingScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
        if !animated {
            setCurrentPage(page)
        }
    }

    private func setCurrentPage(_ page: Int) {
        guard pageViews.indices.contains(page) else { return }
        guard page != currentPage else { return }
        currentPage = page
        updateChrome(animated: true)
        updatePagePlayback()
    }

    private func updateChrome(animated: Bool) {
        updatePageIndicators(animated: animated)
        updateActionButtonTitle()
    }

    private func updatePageIndicators(animated: Bool) {
        let selectedColor: UIColor = traitCollection.userInterfaceStyle == .light ? .black : .white

        let updates = {
            for (index, pill) in self.pageIndicatorPills.enumerated() {
                let isSelected = index == self.currentPage
                pill.backgroundColor = isSelected
                    ? selectedColor.withAlphaComponent(0.35)
                    : UIColor.secondaryLabel.withAlphaComponent(0.35)
                self.pageIndicatorWidthConstraints[index].constant = isSelected ? 14 : 7
            }
        }

        if animated {
            UIView.animate(withDuration: 0.2, animations: updates)
        } else {
            updates()
        }
    }

    private func updateActionButtonTitle() {
        let title = isOnLastPage
            ? configuration.doneButtonLabel.uiAlertFlowResolved
            : configuration.nextButtonLabel.uiAlertFlowResolved

        var config = actionButton.configuration
        config?.title = title
        actionButton.configuration = config
    }

    private func updatePagePlayback() {
        for (index, pageView) in pageViews.enumerated() {
            pageView.setIsCurrent(index == currentPage)
        }
    }

    private var isOnLastPage: Bool {
        guard !items.isEmpty else { return true }
        return currentPage >= items.count - 1
    }
}

extension UIAlertFlowSheetViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        syncCurrentPageFromScrollOffset()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        syncCurrentPageFromScrollOffset()
    }

    private func syncCurrentPageFromScrollOffset() {
        let width = pagingScrollView.bounds.width
        guard width > 0 else { return }
        let page = Int(round(pagingScrollView.contentOffset.x / width))
        setCurrentPage(page)
    }
}

private extension UIFont {
    func with(weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight],
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
