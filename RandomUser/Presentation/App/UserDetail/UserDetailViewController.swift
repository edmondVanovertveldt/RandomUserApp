//
//  UserDetailViewController.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import UIKit

final class UserDetailViewController: UIViewController {

    private let user: User

    // MARK: UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let phoneLabel = UILabel()
    private let locationLabel = UILabel()

    // StackView for details
    private lazy var detailsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel, emailLabel, phoneLabel, locationLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Profile"

        setupScrollView()
        setupUI()
        configure()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupUI() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(detailsStackView)

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),

            detailsStackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 32),
            detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            detailsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -32)
        ])

        [nameLabel, emailLabel, phoneLabel, locationLabel].forEach {
            $0.numberOfLines = 0
            $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
            $0.textColor = .label
        }

        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
    }

    private func configure() {
        if let pictureURL = user.pictureURL {
            // Utiliser une lib comme Kingfisher pour charger l’image
            avatarImageView.kf.setImage(
                with: pictureURL,
                placeholder: UIImage(systemName: "person.crop.circle.fill"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }

        nameLabel.text = user.fullName
        emailLabel.text = "✉️  \(user.email)"
        phoneLabel.text = "📱  \(user.phone)"
        locationLabel.text = "📍  \(user.location)"
    }
}
