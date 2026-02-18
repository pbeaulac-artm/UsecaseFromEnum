import Foundation

// MARK: - Repo

protocol ImageRepo {
    func getFromBundle(named: String) -> String?
    func getFromWeb(url: String) -> String?
    func getFromFileSystem(path: String) -> String?
}

class ImageProdRepo: ImageRepo {
    private var cache: [String: String] = [:]

    func getFromBundle(named: String) -> String? {
        return "Bundle image: \(named)"
    }

    func getFromWeb(url: String) -> String? {
        if let cached = cache[url] { return cached }
        let image = "Web image from \(url)"
        cache[url] = image
        return image
    }

    func getFromFileSystem(path: String) -> String? {
        return "FileSystem image at \(path)"
    }
}

class ImageDebugRepo: ImageRepo {
    private var cache: [String: String] = [:]

    func getFromBundle(named: String) -> String? {
        print("[DEBUG] Loading from bundle: \(named)")
        return "Bundle image: \(named)"
    }

    func getFromWeb(url: String) -> String? {
        print("[DEBUG] Fetching from web: \(url)")
        if let cached = cache[url] {
            print("[DEBUG] Cache hit for: \(url)")
            return cached
        }
        let image = "Web image from \(url)"
        cache[url] = image
        return image
    }

    func getFromFileSystem(path: String) -> String? {
        print("[DEBUG] Reading from file system: \(path)")
        return "FileSystem image at \(path)"
    }
}

class ImageMockRepo: ImageRepo {
    func getFromBundle(named: String) -> String? { return "Mock bundle image" }
    func getFromWeb(url: String) -> String? { return "Mock web image" }
    func getFromFileSystem(path: String) -> String? { return "Mock file system image" }
}

// MARK: - UseCase

enum GetFromBundleUseCase {
    static func execute(named: String, repo: ImageRepo) -> String? {
        return repo.getFromBundle(named: named)
    }
}

enum GetFromWebUseCase {
    static func execute(url: String, repo: ImageRepo) -> String? {
        return repo.getFromWeb(url: url)
    }
}

enum GetFromFileSystemUseCase {
    static func execute(path: String, repo: ImageRepo) -> String? {
        return repo.getFromFileSystem(path: path)
    }
}

// MARK: - Environment

enum ImageEnvironment {
    case prod
    case debug
    case mock
    case custom(ImageRepo)

    var repo: ImageRepo {
        switch self {
        case .prod:              return ImageProdRepo()
        case .debug:             return ImageDebugRepo()
        case .mock:              return ImageMockRepo()
        case .custom(let repo):  return repo
        }
    }
}

// MARK: - Container

struct ImageContainer {
    private let repo: ImageRepo

    init(environment: ImageEnvironment) {
        self.repo = environment.repo
    }

    func getFromBundle(named: String) -> String? {
        GetFromBundleUseCase.execute(named: named, repo: repo)
    }

    func getFromWeb(url: String) -> String? {
        GetFromWebUseCase.execute(url: url, repo: repo)
    }

    func getFromFileSystem(path: String) -> String? {
        GetFromFileSystemUseCase.execute(path: path, repo: repo)
    }
}

// MARK: - Usage

let container = ImageContainer(environment: .debug)

print(container.getFromBundle(named: "logo") ?? "not found")
print(container.getFromWeb(url: "https://example.com/photo.jpg") ?? "not found")
print(container.getFromWeb(url: "https://example.com/photo.jpg") ?? "not found")  // cache hit
print(container.getFromFileSystem(path: "/tmp/photo.jpg") ?? "not found")

let customContainer = ImageContainer(environment: .custom(ImageMockRepo()))
print(customContainer.getFromWeb(url: "https://example.com/photo.jpg") ?? "not found")
