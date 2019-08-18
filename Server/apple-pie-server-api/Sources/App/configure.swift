import Vapor
import Leaf
import Fluent
//import FluentPostgreSQL
//import FluentSQLite
import FluentMySQL
import Authentication


/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // - Configure the rest of your application here -
    
    // Register Leaf Provider
    let leafProvider = LeafProvider()
    try services.register(leafProvider)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    //PostgreSQL Setup
//    try services.register(FluentPostgreSQLProvider())
//
//    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "dsmma", port: 5433, username: "postgres", database: "applePie-words", password: "1234", transport: .cleartext)
//    let psqlDatabase = PostgreSQLDatabase(config: psqlConfig)
//
//    var databasesConfig = DatabasesConfig()
//    databasesConfig.add(database: psqlDatabase, as: .psql)
//
//    services.register(databasesConfig)
    
    
     //MySQL Setup
     
     //Register  MySQL Provider
     try services.register(FluentMySQLProvider())
     
     //create config instance
     var databasesConfig = DatabasesConfig()
     
     //create mysql database config
     let mySQLConfig = MySQLDatabaseConfig(hostname: "YOUR_HOST_NAME", port: 3307, username: "YOUR_DATABASE_USERNAME", password: "YOUR_DATABASE_PASSWORD", database: "YOUR_DATABASE_NAME", capabilities: .default , characterSet: .utf8mb4_unicode_ci, transport: .cleartext)
     
     //create database based on config
     let mySQLDataBase = MySQLDatabase(config: mySQLConfig)
     
     //adding mySQL database to dayabasesConfig
     databasesConfig.add(database: mySQLDataBase, as: .mysql)
     
     //register service of databasesConfig
     services.register(databasesConfig)
     
    
    /*    //SQLite Setup
     
     //Create config for Data Base Directory
     let directoryConfig = DirectoryConfig.detect()
     services.register(directoryConfig)
     print(directoryConfig)
     
     //Register Fluent SQL Provider
     try services.register(FluentSQLiteProvider())
     
     
     //SQLite DB config
     let fullPath = "\(directoryConfig.workDir)words.db"
     print(#line, #function, fullPath)
     let database = try SQLiteDatabase(storage: .file(path: fullPath))
     
     var databaseConfig = DatabasesConfig()
     databaseConfig.add(database: database, as: .sqlite)
     
     services.register(databaseConfig)
     
     */
    
    //Migration Config
    var migrationConfig = MigrationConfig()
        migrationConfig.add(model: Category.self, database: .mysql)
        migrationConfig.add(model: Word.self, database: .mysql)
        migrationConfig.add(model: User.self, database: .mysql)
//    migrationConfig.add(model: Category.self, database: .psql)
//    migrationConfig.add(model: Word.self, database: .psql)
//    migrationConfig.add(model: User.self, database: .psql)
    services.register(migrationConfig)
    
    //enable Public folder outside
    var middlewares = MiddlewareConfig.default()
    middlewares.use(FileMiddleware.self)
    
    //Authentication
    try services.register(AuthenticationProvider())
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
}

