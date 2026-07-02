import Foundation

@MainActor
final class ServiceRegistry {
    private var services: [String: Any] = [:]

    func register<Service>(_ type: Service.Type, service: Service) {
        let key = key(for: type)
        services[key] = service
    }

    func registerIfAbsent<Service>(_ type: Service.Type, service: Service) {
        let key = key(for: type)
        if services[key] == nil {
            services[key] = service
        }
    }

    func resolve<Service>(_ type: Service.Type) -> Service? {
        let key = key(for: type)
        return services[key] as? Service
    }

    func require<Service>(_ type: Service.Type) -> Service {
        guard let service = resolve(type) else {
            fatalError("Missing service: \(String(reflecting: type))")
        }
        return service
    }

    func contains<Service>(_ type: Service.Type) -> Bool {
        resolve(type) != nil
    }

    var registeredServiceKeys: [String] {
        services.keys.sorted()
    }

    private func key<Service>(for type: Service.Type) -> String {
        String(reflecting: type)
    }
}
