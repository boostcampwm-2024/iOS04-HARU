import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    // register routes
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080
    try routes(app)
}
