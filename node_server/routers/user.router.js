const router = require('express').Router();
const UserController = require("../controller/user.controller");

router.post('/registration', UserController.register);
router.post('/verify', UserController.verifyUser);
router.post('/login', UserController.login);
// router.post('/loginEmloyee', UserController.loginEmloyee);

router.post('/forgotPassword', UserController.forgotPassword);
router.put('/updatePassword', UserController.updatePasswordByEmail);
router.put('/:userId', UserController.updateUser);
router.get('/search', UserController.getUserByEmail);

router.post('/:userId/addStore', UserController.addStoreForUser);
router.delete('/:userId/stores/:storeId', UserController.deleteStoreForUser);
router.get('/stores', UserController.stores);
router.get('/:userId/storesById', UserController.storesById);
router.get('/stores/:storeId/products', UserController.getProductsByStore);
router.post('/:userId/stores/:storeId/products', UserController.addProductsToStore);
router.put('/:userId/EditStores/:storeId', UserController.editStore);
router.get('/storesWithProducts', UserController.allStoresWithProducts);


router.get('/users/:userId/products', UserController.getProductsForUser);
router.delete('/:storeId/products/:productId', UserController.deleteProduct);
router.get('/stores/:storeId/products/:productId', UserController.getProductById);
router.put('/stores/:storeId/products/:productId', UserController.editProduct);
router.get('/stores/:storeId/name', UserController.getStoreNameById);
router.get('/:productId/product', UserController.getProductByItsId);
router.get('/products', UserController.allProducts);
router.put('/:productId/product', UserController.updateProductOffer);


router.post('/users/:userId/addEmployee', UserController.addEmployee);
router.delete('/:userId/employees/:employeeId', UserController.deleteEmployee);
router.get('/:userId/employees', UserController.getEmployeesOfUser);
router.put('/:userId/employees/:employeeId', UserController.updateEmployee);
router.get('/employee/:employeeId/user', UserController.getUserFromEmployeeId);

router.post('/AddOrder', UserController.createOrder);
router.delete('/:orderId/deleteOrder', UserController.deleteOrder);
router.get('/:userId/orders', UserController.getOrdersByUser);
router.put('/orders/:orderId', UserController.editOrderCustomerInfo);
router.put('/orders/:orderId/products', UserController.editOrderProducts);


router.post('/addnotifications', UserController.addNotification);
router.get('/notifications/:userId', UserController.getAllNotificationsByUser);
router.delete('/notifications/:userId/:notificationId', UserController.deleteNotification);
router.get('/notifications', UserController.getAllNotifications);

router.post('/:userId/addFavorite', UserController.addFavorite);
router.get('/:userId/AllFavorites', UserController.getAllFavoritesByUser);
router.delete('/:userId/:productId/deleteFavorite', UserController.deleteFavorite);


router.post('/:userId/addToCart', UserController.addToCart);
router.delete('/:userId/:productId/removeFromCart', UserController.removeFromCart);
router.get('/:userId/getCartProducts', UserController.getCartProducts);
router.put('/:userId/updateQuantityInCart', UserController.updateQuantityInCart);
router.delete('/:userId/removeAllCartProducts', UserController.removeAllCartProducts);



router.get('/merchant/:userId/orders', UserController.getOrdersForMerchant);

router.post('/employee/:employeeId/tasks', UserController.addTaskToEmployee);
router.get('/employee/:employeeId/tasks', UserController.getTasksByEmployeeId);
router.put('/task/:taskId', UserController.editTask);
router.delete('/task/:taskId', UserController.deleteTaskFromEmployee);
router.get('/getTasksForUser/:userId', UserController.getTasksForUser);

router.get('/employees/:employeeId', UserController.getEmployeeById);

//Admin Dashboard - Users
router.get('/getMerchantCount', UserController.getMerchantCount);
router.get('/getUserCount', UserController.getUserCount);
router.get('/getAdminCount', UserController.getAdminCount);
router.get('/getEmployeeCount', UserController.getEmployeeCount);

router.get('/getAllUsers', UserController.getAllUsers);
router.get('/employees', UserController.getAllEmployees);

router.get('/getAllOrders', UserController.getAllOrders);

router.get('/getProductsWithOffers', UserController.getProductsWithOffers);

router.post('/addFeedback', UserController.addFeedback);
router.get('/allFeedback', UserController.getAllFeedback);
router.get('/feedbackByUser/:userId', UserController.getFeedbackByUserId);

module.exports = router;
