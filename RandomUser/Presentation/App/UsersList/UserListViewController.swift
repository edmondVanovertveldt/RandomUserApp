//
//  UserListViewController.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import UIKit
import Combine

final class UserListViewController: UIViewController {
    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No users found."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        return label
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    private var viewModel: UserListViewModel!
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Users"
        setupUI()

        DispatchQueue.main.async {
            Task {
                await self.viewModel.loadInitialUsers()
            }
        }
    }

    private func setupUI() {
        setupCollectionView()
        setupActivityIndicator()
        setupEmptyStateView()
        bindViewModel()
    }

    // MARK: -
    // MARK: CollectionView

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 80)
        layout.minimumLineSpacing = 8

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(User.UserCell.self, forCellWithReuseIdentifier: User.UserCell.identifier)
        collectionView.register(LoaderFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: LoaderFooterView.identifier)
        view.addSubview(collectionView)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.footerReferenceSize = CGSize(width: collectionView.frame.width, height: 50)
        }

        setupDataSource()

        collectionView.delegate = self
        collectionView.prefetchDataSource = self

        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { collectionView, indexPath, userID in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: User.UserCell.identifier, for: indexPath) as! User.UserCell
            let user = self.viewModel.user(at: indexPath.item)
            cell.configure(with: user)
            return cell
        }

        // Footer view
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: LoaderFooterView.identifier,
                    for: indexPath
                ) as! LoaderFooterView

                if self.viewModel.isLoadingMoreUsers {
                    footer.startAnimating()
                } else {
                    footer.stopAnimating()
                }

                return footer
            }
            return nil
        }
    }

    // MARK: -
    // MARK: ActivityIndicator

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: -
    // MARK: EmptyState

    private func setupEmptyStateView() {
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !(viewModel.isFirstLoadDone && viewModel.numberOfUsers == 0)
    }

    // MARK: -
    // MARK: ViewModel

    private func bindViewModel() {
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showError(message: message)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.showLoading(isLoading)
            }
            .store(in: &cancellables)

        viewModel.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.reloadData()
                self?.collectionView.refreshControl?.endRefreshing()
            }
            .store(in: &cancellables)

        viewModel.$isFirstLoadDone
            .combineLatest(viewModel.$users)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (_, _) in
                self?.updateEmptyState()
            }
            .store(in: &cancellables)

        viewModel.$isLoadingMoreUsers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadData()
            }
            .store(in: &cancellables)
    }

    // MARK: -
    // MARK: Actions

    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        let ids = viewModel.users.map { $0.id }
        snapshot.appendItems(ids, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
        updateEmptyState()
    }

    @objc private func refreshPulled() {
        Task {
            await viewModel.refresh()
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showLoading(_ show: Bool) {
        DispatchQueue.main.async {
            if show {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

// MARK: - UICollectionViewDelegate & UIScrollViewDelegate

extension UserListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = viewModel.user(at: indexPath.item)
        let detailVC = UserDetailViewController(user: user)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension UserListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight * 1.5 && viewModel.users.count > 0 {
            Task {
                await viewModel.loadMoreUsersIfNeeded(currentIndex: viewModel.numberOfUsers - 1)
            }
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension UserListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let maxIndex = indexPaths.map(\.item).max() else { return }
        Task {
            await viewModel.loadMoreUsersIfNeeded(currentIndex: maxIndex)
        }
    }
}
