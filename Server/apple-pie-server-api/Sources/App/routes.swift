import Routing
import Vapor
import Leaf
//import Fluent
//import FluentPostgreSQL
import FluentMySQL
import Crypto
import Authentication


/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)

public func routes(_ router: Router) throws {
    
    //MARK: - Dependencies
    let userController = UserController()
    let homePageController = HomePageController()
    let categoryController = CategoryController()
    let wordController = WordController()
    let apiController = APIController()
    let setupDataBaseController = SampleDataLoader()
    
    //use this to load sample data to your MySQL DataBase, comment after using
    router.get("setup", use: setupDataBaseController.load)
    
    //Middleware for user auth. sessions
    let authSessionRouter = router.grouped(User.authSessionsMiddleware())
    authSessionRouter.post(WebRoutesPaths.login.rawValue, use: userController.login)
    
    //Create group for pages which are could not be able without Authentication
    let protectedClosedPagesRouter = authSessionRouter.grouped(RedirectMiddleware<User>(path: WebRoutesPaths.login.rawValue))
    
    //MARK: --WEB ROUTES--
    
    //GET: /main (main.leaf)
    protectedClosedPagesRouter.get(WebRoutesPaths.main.rawValue, use: homePageController.renderHomePage)
    
    //MARK: -Categories Requests
    
    //GET: /categories (render categories.leaf)
    protectedClosedPagesRouter.get(WebRoutesPaths.categories.rawValue, use: categoryController.renderCategoryList)
    
    //GET: /category/<id> (render category.leaf)
    protectedClosedPagesRouter.get(WebRoutesPaths.category.rawValue, Category.parameter, use: categoryController.renderCategoryWords)
    
    //POST: /categories - create a category on categories page
    protectedClosedPagesRouter.post(WebRoutesPaths.categories.rawValue, use: categoryController.create)
    
    //POST: /category/<id>/update
    protectedClosedPagesRouter.post(WebRoutesPaths.category.rawValue, Category.parameter, "update", use: categoryController.update)
    
    //POST: /category/<id>/delete
    protectedClosedPagesRouter.post(WebRoutesPaths.category.rawValue, Category.parameter, "delete", use: categoryController.delete)
    
    //MARK: -Words Requests
    
    //POST:: /category/<id>/addword
    protectedClosedPagesRouter.post(WebRoutesPaths.category.rawValue, Category.parameter,"addword", use: wordController.create)
    
    //POST:: /word/<id>/update
    protectedClosedPagesRouter.post(WebRoutesPaths.word.rawValue, Word.parameter,"update", use: wordController.update)
    
    //POST:: /word/<id>/delete
    protectedClosedPagesRouter.post(WebRoutesPaths.word.rawValue, Word.parameter,"delete", use: wordController.delete)
    
    
    //MARK: -Users Requests
    
    //GET: /login (Render users-login.leaf)
    router.get(WebRoutesPaths.login.rawValue, use: userController.renderLoginPage)
    
    //GET: /users (Render users.leaf)
    protectedClosedPagesRouter.get(WebRoutesPaths.users.rawValue, use: userController.renderUsersList)
    
    //GET: /users/create (Render users-create.leaf)
    protectedClosedPagesRouter.get(WebRoutesPaths.usersCreate.rawValue, use: userController.renderCreatePage)
    
    //GET: /logout (Deprecated User auth session, redirects to login page)
    protectedClosedPagesRouter.get(WebRoutesPaths.logout.rawValue, use: userController.logout)
    
    //POST: /users/create (Creates User)
    protectedClosedPagesRouter.post(WebRoutesPaths.usersCreate.rawValue, use: userController.createUser)
    
    //POST: /users/<id>/delete (Deletes user with id)
    protectedClosedPagesRouter.post(WebRoutesPaths.users.rawValue, User.parameter, "delete", use: userController.delete)
    
    //POST: /users/<id>/update (Updates user with id)
    protectedClosedPagesRouter.post(WebRoutesPaths.users.rawValue, User.parameter, "update", use: userController.update)
    
    
    //MARK: --API ROUTES--
    
    //GET: /api/categories (Reponse: [Categoires])
    router.get(APIRoutesPaths.categories.rawValue, use: apiController.getCategories)
    
    //GET: /api/category/<id>/words (Reponse: [Categoires])
    router.get(APIRoutesPaths.category.rawValue, Category.parameter, "words", use: apiController.getWordsFromCategory)
}

