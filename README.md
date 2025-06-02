# RandomUserApp

RandomUserApp est une application iOS développée en Swift, permettant d'afficher une liste de contacts aléatoires en provenance de l'API [RandomUser.me](https://randomuser.me/).

---

## ✨ Fonctionnalités

- Affichage d'une liste de contacts sous forme de collection view.
- Récupération des utilisateurs via appel réseau (`https://randomuser.me/api/`).
- Infinite scroll : chargement automatique de nouveaux utilisateurs lorsque l'utilisateur atteint le bas de la liste.
- Reload possible (reset de la liste)
- Gestion de l'absence de connexion Internet :
  - Affichage des utilisateurs mis en cache localement avec CoreData.
  - Affichage d'un empty state si aucun utilisateur n'est disponible.
- Détail d'un utilisateur accessible en tapant sur une cellule.
- Gestion d'erreurs réseau avec messages utilisateurs.


## 🏗️ Architecture

L'architecture repose sur les principes de **Clean Architecture** avec une séparation stricte des couches :

- **UI Layer** :
  - `UserListViewController` : affichage de la liste des utilisateurs.
  - `UserDetailViewController` : affichage des détails d'un utilisateur.
- **Presentation Layer** :
  - `UserListViewModel` : logique de présentation, expose les données via `@Published` et Combine.
    
- **Domain Layer** :
  - `FetchUsersUseCase` / `ReloadUsersUseCase` : logique métier pour interagir avec les utilisateurs.
  - `UserRepository` : protocol d'abstraction des sources de données.
  - `User`: entité représentant un utilisateur.
    
- **Data Layer** :
  - `UserRepositoryImpl` : implémentation du `UserRepository` combinant API réseau et cache local (CoreData & Userdefault).
  - `RandomUserAPIService` & objets DTO : service réseau pour consommer l'API [RandomUser.me](https://randomuser.me/).
  - `CoreDataStack` et `UserEntity` : persistance locale avec CoreData.
  - `UserDefaultsUserSettings`: persistance locale des informations de pagination courante & seed avec Userdefault.

Toutes les classes manipulant des données exposées à l'UI sont annotées avec `@MainActor` pour garantir une exécution thread-safe sur le Main Thread.


## 🔧 Stack technique
- **UIKit pur** (pas de SwiftUI, pas de Storyboard, pas de xib).
- **URLSession** pour le réseau.
- **Codable** pour le parsing JSON.
- **CoreData** pour le cache local (gestion du mode offline).
- **async / await** / **Actor** pour la gestion des threads et de l'asynchrone.
- **UICollectionView** pour plus de souplesse.
- **DiffableDataSource** (UIKit moderne) pour éviter les bugs de reload.
- **Combine** : binding des données réactives pour une synchronisation UI simple et fiable (liaison entre ViewModel et ViewController, évite les callbacks)

## 🔧 Dépendances

- **Kingfisher** (via SPM) : Chargement et cache d'images performant
  - raison: Téléchargement asynchrone simple, Gestion de cache automatique (en mémoire et disque), Retry automatique si réseau instable, Support des placeholders (images par défaut en attendant)


## ℹ️ Prérequis :
- **Xcode Xcode 13.2+** (pour Swift Concurrency (async/await) )
- **iOS 15+**

## 🛠️ Axes d'amélioration:
- Découper les couches de l'architecture (UI/DOMAIN/DATA) en framework ou package SPM.
- Implémenter des tests unitaires et d'intégration (Mock des services API et CoreData, Tests sur les UseCases et ViewModel)
- Améliorer l'UX avec des loaders skeletons pendant le chargement initial.
- Ajouter une bannière non bloquante pour les erreurs réseau (plutôt qu'une alerte modale).
- Internationalisation, pour supporter plusieurs langues (Utilisation de String Catalogs, Switgen ou autres ..).
- Accessibilité (Dynamic Type, VoiceOver).
- Améliorer la compatibilité iPad.
- Migration vers SwiftData (iOS 17+) pour une gestion de persistance plus moderne.
- Optimiser le cache CoreData pour éviter les doublons (clé primaire sur UUID).
