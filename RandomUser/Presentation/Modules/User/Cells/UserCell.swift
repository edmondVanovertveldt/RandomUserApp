//
//  UserCell.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import UIKit
import Kingfisher

extension User {
    final class UserCell: UICollectionViewCell {
        static let identifier = "UserCell"

        private let nameLabel = UILabel()
        private let emailLabel = UILabel()
        private let avatarImageView = UIImageView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupUI() {
            avatarImageView.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            emailLabel.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(avatarImageView)
            contentView.addSubview(nameLabel)
            contentView.addSubview(emailLabel)

            avatarImageView.layer.cornerRadius = 30
            avatarImageView.clipsToBounds = true
            avatarImageView.contentMode = .scaleAspectFill

            NSLayoutConstraint.activate([
                avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                avatarImageView.widthAnchor.constraint(equalToConstant: 60),
                avatarImageView.heightAnchor.constraint(equalToConstant: 60),

                nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
                nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

                emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
                emailLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
            ])
        }

        func configure(with user: User) {
            nameLabel.text = user.fullName
            emailLabel.text = user.email
            loadImage(from: user.pictureURL)
        }

        private func loadImage(from url: URL?) {
            avatarImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.crop.circle"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        }
    }
}

