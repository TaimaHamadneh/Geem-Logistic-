const UserModel = require('../model/user.model');
const { StoreModel } = require('../model/store.model');
const OrderModel = require('../model/order.model');
const UserService = require('../services/user.services');
const nodemailer = require("nodemailer");
const bcrypt = require("bcrypt");
const jwt = require('jsonwebtoken');
const EmployeeModel = require('../model/employee.model');
const mongoose = require('mongoose');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const NotifiScheme = require('../model/notification.model');
const Favorite = require('../model/favorite.model'); 
const Cart = require('../model/cart.model');
const TaskModel = require('../model/task.model');
const Feedback = require('../model/feedback.model');


// Sign up
exports.register = async (req, res, next) => {
  try {
    const { userName, email, password, userType, about, location } = req.body;
    const successRes = await UserService.registerUser(userName, email, password, userType, about, location);
    await sendVerificationEmail(email, successRes.verificationCode);
    res.json({ status: true, success: "User Registered Successfully!" });

  } catch (error) {
    if (error.message === 'User with this email already exists') {
      res.status(409).json({ status: false, error: 'Email already in use' });
    } else {
      next(error);
    }
  }
}
// Forget Password 
exports.forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;
    const user = await UserService.getUserByEmail(email);

    if (!user) {
      throw new Error('User with this email does not exist');
    }

    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    await UserService.updateVerificationCode(user._id, verificationCode);

    await sendVerificationEmail(email, verificationCode);

    res.json({ status: true, success: "Verification code sent successfully!" });

  } catch (error) {
    next(error);
  }
}
// Send Verification Email
async function sendVerificationEmail(email, verificationCode) {

  let transporter = nodemailer.createTransport({
    service: 'gmail',
   
    auth: {
      user: 'ecotrack67@gmail.com',
      pass: 'fpnp cvhk htyu uybj',

    }
  });
  let info = await transporter.sendMail({
    from: 'Logistic Trade',
    to: email,
    subject: 'Email Verification',
    text: `Your verification code is: ${verificationCode}`
  });

}
// Verify User
exports.verifyUser = async (req, res) => {
  try {
    const { email, verificationCode } = req.body;
    const user = await UserModel.findOne({ email, verificationCode });

    if (!user) {
      return res.status(400).json({ message: "Invalid verification code." });
    }

    user.emailVerified = true;
    await user.save();

    return res.status(200).json({ message: "User verified successfully." });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Internal server error." });
  }
};
// Update User Data
exports.updateUser = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const updatedData = req.body;

    const updatedUser = await UserModel.findByIdAndUpdate(userId, updatedData, { new: true });
    res.json({ status: true, success: "User updated successfully!", user: updatedUser });
  } catch (error) {
    next(error);
  }
};
// Return User
exports.getUserByEmail = async (req, res, next) => {
  try {
    const { email } = req.query; 

    const user = await UserModel.findOne({ email }); 
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({ status: true, success: "User ID retrieved successfully!", id: user._id });

  } catch (error) {
    console.error(error, 'err ---->');
    next(error);
  }
};
// Update Password By having Email
exports.updatePasswordByEmail = async (req, res, next) => {
  try {
    const userEmail = req.body.email; 
    const newPassword = req.body.password; 
    const user = await UserModel.findOne({ email: userEmail });

    if (!user) {
      return res.status(404).json({ status: false, error: "User not found" });
    }
    user.password = newPassword;
    const updatedUser = await user.save();

    res.json({ status: true, success: "Password updated successfully!", user: updatedUser });
  } catch (error) {
    next(error);
  }
};

// Add warehouse for users
exports.addStoreForUser = async (req, res, next) => {
  try {
    const { userId } = req.params; 
    const { name, latitude, longitude, area, contactNumber, address, category,image } = req.body;

    const store = new StoreModel({
      name,
      location: {
        type: "Point",
        coordinates: [longitude, latitude] 
      },
      area,
      contactNumber,
      address,
      category,
      image 
    });

    const savedStore = await store.save();

    const user = await UserModel.findByIdAndUpdate(userId, {
      $push: { stores: savedStore._id }
    }, { new: true }); 

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(201).json(savedStore);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.stores = async (req, res, next) => {
  try {
    const stores = await StoreModel.find();
    res.status(200).json(stores); 
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.storesById = async (req, res, next) => {
  try {
    const userId = req.params.userId; 

    const user = await UserModel.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const stores = await StoreModel.find({ _id: { $in: user.stores } });

    res.status(200).json(stores);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.allProducts = async (req, res, next) => {
  try {
    const stores = await StoreModel.find();

    let allProducts = [];

    for (const store of stores) {
      allProducts = allProducts.concat(store.products);
    }

    res.status(200).json(allProducts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
exports.allStoresWithProducts = async (req, res, next) => {
  try {
    const stores = await StoreModel.find().populate('products');
    res.status(200).json(stores);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


exports.deleteStoreForUser = async (req, res, next) => {
  try {
    const { userId, storeId } = req.params;

    const user = await UserModel.findByIdAndUpdate(userId, {
      $pull: { stores: storeId }
    }, { new: true });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const deletedStore = await StoreModel.findByIdAndDelete(storeId);

    if (!deletedStore) {
      return res.status(404).json({ message: 'Store not found' });
    }

    await StoreModel.updateOne({ _id: storeId }, { $unset: { products: 1 } });

    res.status(200).json({ message: 'Store and associated products deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.editStore = async (req, res) => {
  const { storeId } = req.params;
  const updates = req.body;

  try {
    const store = await StoreModel.findById(storeId);

    if (!store) {
      return res.status(404).json({ error: "Store not found" });
    }

    const updatedStore = await StoreModel.findByIdAndUpdate(storeId, updates, { new: true });

    res.json(updatedStore);
  } catch (error) {
    console.error("Error updating store:", error);
    res.status(500).json({ error: "Could not update store" });
  }
};

exports.getProductsByStore = async (req, res, next) => {
  try {
    const { storeId } = req.params;
    const store = await StoreModel.findById(storeId).populate('products');

    if (!store) {
      return res.status(404).json({ message: 'Store not found' });
    }
    const products = store.products;

    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getProductByItsId = async (req, res, next) => {
  try {
    const { productId } = req.params;
    const stores = await StoreModel.find({ 'products._id': productId });

    if (!stores || stores.length === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const storeWithProduct = stores.find(store => {
      const product = store.products.find(p => p._id.toString() === productId);
      return product !== undefined;
    });

    if (!storeWithProduct) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const product = storeWithProduct.products.find(p => p._id.toString() === productId);

    res.status(200).json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.addProductsToStore = async (req, res, next) => {
  try {
    const { userId, storeId } = req.params; 
    const { products } = req.body;
    const productsWithStoreId = products.map(product => ({ ...product, store: storeId }));

    const updatedStore = await StoreModel.findByIdAndUpdate(storeId, {
      $push: { products: { $each: productsWithStoreId } }
    }, { new: true }).populate('products'); 

    if (!updatedStore) {
      return res.status(404).json({ message: 'Store not found' });
    }

    res.status(201).json(updatedStore.products); 
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getProductsForUser = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const stores = await StoreModel.find({ _id: { $in: (await UserModel.findById(userId)).stores } });

    let products = [];
    for (const store of stores) {
      products = products.concat(store.products);
    }

    res.status(200).json(products);
  } catch (error) {
    next(error);
  }
};

exports.updateProductOffer = async (req, res, next) => {
  try {
      const productId = req.params.productId;
      const { offer } = req.body;

      const store = await StoreModel.findOne({ 'products._id': productId });

      if (!store) {
          return res.status(404).json({ message: 'Product not found' });
      }

      const product = store.products.find(product => product._id.toString() === productId);

      if (!product) {
          return res.status(404).json({ message: 'Product not found' });
      }

      product.offer = offer;
      await store.save();

      res.status(200).json({ message: 'Product offer updated successfully' });
  } catch (error) {
      res.status(500).json({ message: error.message });
  }
};



exports.deleteProduct = async (req, res, next) => {
  try {
    const { storeId, productId } = req.params;

    const store = await StoreModel.findById(storeId);

    if (!store) {
      return res.status(404).json({ message: 'Store not found' });
    }
    const productIndex = store.products.findIndex(product => product._id.toString() === productId);

    if (productIndex === -1) {
      return res.status(404).json({ message: 'Product not found' });
    }

    store.products.splice(productIndex, 1);
    await store.save();

    res.status(200).json({ message: 'Product deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getProductsWithOffers = async (req, res, next) => {
  try {

    const stores = await StoreModel.find({
      'products.status': { $exists: true, $ne: null, $gt: 0 }
    });

    if (stores.length === 0) {
      console.log('No stores found with products that have offers.');
    } else {
     // console.log('Stores with offers:', stores);
    }

    const productsWithOffers = stores.reduce((acc, store) => {
      const offeredProducts = store.products.filter(product => product.offer && product.offer > 0);
     // console.log(`Store: ${store._id}, Offered Products:`, offeredProducts);
      return acc.concat(offeredProducts);
    }, []);

    if (productsWithOffers.length === 0) {
      console.log('No products found with offers.');
    }


    res.status(200).json(productsWithOffers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


exports.getProductById = async (req, res, next) => {
  try {
    const { storeId, productId } = req.params;
    const store = await StoreModel.findById(storeId);

    if (!store) {
      return res.status(404).json({ message: 'Store not found' });
    }

    const product = store.products.find(product => product._id.toString() === productId);

    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    res.status(200).json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
exports.editProduct = async (req, res, next) => {
  try {
    const { storeId, productId } = req.params;

    const store = await StoreModel.findById(storeId);

    if (!store) {
      return res.status(404).json({ message: 'Store not found' });
    }

    const productIndex = store.products.findIndex(product => product._id.toString() === productId);

    if (productIndex === -1) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const updatedProduct = { ...store.products[productIndex].toObject(), ...req.body };

    store.products[productIndex] = updatedProduct;

    await store.save();

    res.status(200).json({ message: 'Product updated successfully', product: updatedProduct });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getStoreNameById = async (req, res, next) => {
  try {
    const storeId = req.params.storeId;
    const store = await StoreModel.findById(storeId);

    if (!store) {
      return res.status(404).json({ message: 'Store not found' });
    }

    res.status(200).json({ storeName: store.name });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};



exports.createOrder = async (req, res, next) => {
  try {
    const { userId, products, customerInfo, status } = req.body;
    const invalidProducts = products.filter(product => product.quantity <= 0);
    const { name, email, city, town, phone } = customerInfo;

    if (invalidProducts.length > 0) {
      return res.status(400).json({ message: 'Quantity of products cannot be 0 or less' });
    }

    let totalPrice = 0;
    for (const { productId, quantity } of products) {
      const store = await StoreModel.findOne({ 'products._id': productId });

      if (!store) {
        return res.status(404).json({ message: 'Store not found for the product' });
      }

      const product = store.products.find(prod => prod._id.toString() === productId);

      if (!product) {
        return res.status(404).json({ message: 'Product not found in the store' });
      }

      if (product.quantity < quantity) {
        return res.status(400).json({ message: `Insufficient quantity available for product: ${product.name}` });
      }

      product.quantity -= quantity;

      if (product.quantity === 0) {
        product.status = 'sold out';
      }
      else{
        product.status = 'available';
      }

      totalPrice += product.sellingPrice * quantity;
      await store.save();
    }
    const newOrder = new OrderModel({
      user: userId,
      products,
      totalPrice,
      customerInfo,
      status
    });
    await newOrder.save();

    res.status(201).json({ message: 'Order created successfully', order: newOrder });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deleteOrder = async (req, res, next) => {
  try {
    const { orderId } = req.params;

    const order = await OrderModel.findById(orderId);

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    await OrderModel.deleteOne({ _id: orderId });
    for (const { productId, quantity } of order.products) {
      await StoreModel.updateOne(
        { 'products._id': productId },
        { $inc: { 'products.$.quantity': quantity } }
      );
    }

    res.status(200).json({ message: 'Order and associated products deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getOrdersByUser = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const orders = await OrderModel.find({ user: userId });

    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.editOrderCustomerInfo = async (req, res, next) => {
  try {
    const { userId, products, customerInfo, status } = req.body;
    const { orderId } = req.params;

    let totalPrice = 0;
    for (const { productId, quantity } of products) {
      const product = await StoreModel.findOne({ 'products._id': productId }, { 'products.$': 1 });
      if (!product || !product.products || product.products.length === 0) {
        return res.status(404).json({ message: 'Product not found' });
      }
      const selectedProduct = product.products[0];
      
      totalPrice += selectedProduct.sellingPrice * quantity;
    }
    const updatedOrder = await OrderModel.findByIdAndUpdate(orderId, {
      user: userId,
      products,
      totalPrice,
      customerInfo,
      status
    }, { new: true });

    res.status(200).json({ message: 'Order updated successfully', order: updatedOrder });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


exports.editOrderProducts = async (req, res, next) => {
  try {
    const { products } = req.body;
    const { orderId } = req.params;

    let totalPrice = 0;
    let insufficientProducts = []; 

    const order = await OrderModel.findById(orderId);

    for (const { productId, quantity } of order.products) {
      await StoreModel.updateOne(
        { 'products._id': productId },
        { $inc: { 'products.$.quantity': quantity } }
      );
    }

    const quantityChanges = new Map();

    for (const { productId, quantity } of products) {
      if (quantity <= 0) {
        return res.status(400).json({ message: 'Quantity must be greater than 0' });
      }

      const product = await StoreModel.findOne({ 'products._id': productId }, { 'products.$': 1 });
      if (!product || !product.products || product.products.length === 0) {
        return res.status(404).json({ message: 'Product not found' });
      }
      const selectedProduct = product.products[0];

      if (selectedProduct.quantity < quantity) {
        insufficientProducts.push({ productId: selectedProduct._id, name: selectedProduct.name });
      } else {
        totalPrice += selectedProduct.sellingPrice * quantity;

        if (!quantityChanges.has(productId)) {
          quantityChanges.set(productId, 0);
        }
        quantityChanges.set(productId, quantityChanges.get(productId) - quantity);

        if (quantity > 0) {
            await StoreModel.updateOne(
              { 'products._id': productId },
              { $set: { 'products.$.status': 'available' } }
            );
          }

      }
    }

    if (insufficientProducts.length > 0) {
      for (const [productId, quantity] of quantityChanges.entries()) {
        await StoreModel.updateOne(
          { 'products._id': productId },
          { $inc: { 'products.$.quantity': -quantity } } 
        );
      }
      return res.status(400).json({ message: 'Insufficient quantity for some products', insufficientProducts });
    }

    for (const [productId, quantityChange] of quantityChanges.entries()) {
      await StoreModel.updateOne(
        { 'products._id': productId },
        { $inc: { 'products.$.quantity': quantityChange } }
      );
    }

    const updatedOrder = await OrderModel.findByIdAndUpdate(orderId, {
      products,
      totalPrice,
    }, { new: true });

    res.status(200).json({ message: 'Order updated successfully', order: updatedOrder });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};



exports.addNotification = async (req, res, next) => {
  try {
    const { userId, title, body, id, date } = req.body;

    const notification = new NotifiScheme({
      user: userId,
      title,
      body,
      id, 
      date
    });

    const savedNotification = await notification.save();

    res.status(201).json(savedNotification);
  } catch (error) {
    next(error);
  }
};

exports.getAllNotifications = async (req, res, next) => {
  try {
      const notifications = await NotifiScheme.find(); // Populate 'user' field if you want to include user details

      res.status(200).json(notifications);
  } catch (error) {
      next(error);
  }
};

exports.getAllNotificationsByUser = async (req, res, next) => {
  try {
    const userId = req.params.userId;

    const notifications = await NotifiScheme.find({ user: userId });

    res.status(200).json(notifications);
  } catch (error) {
    next(error);
  }
};
exports.deleteNotification = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const notificationId = req.params.notificationId;

    await NotifiScheme.findOneAndDelete({ user: userId, _id: notificationId });

    res.status(200).json({ message: 'Notification deleted successfully' });
  } catch (error) {
    next(error);
  }
};


exports.addFavorite = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.body.productId;

    const favorite = new Favorite({
      user: userId,
      productId: productId
    });

    await favorite.save();

    res.status(201).json({ message: 'Favorite added successfully' });
  } catch (error) {
    next(error);
  }
};

exports.getAllFavoritesByUser = async (req, res, next) => {
  try {
    const userId = req.params.userId;

    const favorites = await Favorite.find({ user: userId });

    res.status(200).json(favorites);
  } catch (error) {
    next(error);
  }
};

exports.deleteFavorite = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.params.productId;

    await Favorite.findOneAndDelete({ user: userId, productId: productId });

    res.status(200).json({ message: 'Favorite deleted successfully' });
  } catch (error) {
    next(error);
  }
};

exports.addToCart = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.body.productId;
    const quantity = req.body.quantity || 1; 
    const sellingPrice = req.body.sellingPrice;
    const storeId = req.body.storeId;
    const offer = req.body.offer;
    

    const existingCartItem = await Cart.findOne({ user: userId, productId: productId });

    if (existingCartItem) {

      existingCartItem.quantity += quantity; 
      await existingCartItem.save();
      return res.status(200).json({ message: 'Product quantity updated in cart' });
    }

    const cartItem = new Cart({
      user: userId,
      productId: productId,
      quantity: quantity,
      sellingPrice: sellingPrice,
      storeId: storeId,
      offer: offer,
    });

    await cartItem.save();

    res.status(200).json({ message: 'Product added to cart successfully' });
  } catch (error) {
    next(error);
  }
};

exports.removeFromCart = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.params.productId;
    await Cart.findOneAndDelete({ user: userId, productId: productId });

    res.status(200).json({ message: 'Product removed from cart successfully' });
  } catch (error) {
    next(error);
  }
};

exports.getCartProducts = async (req, res, next) => {
  try {
    const userId = req.params.userId;

    const cartItems = await Cart.find({ user: userId });

    res.status(200).json(cartItems);
  } catch (error) {
    next(error);
  }
};
exports.updateQuantityInCart = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.body.productId;
    const newQuantity = req.body.quantity;

    const cartItem = await Cart.findOne({ user: userId, productId: productId });

    if (!cartItem) {
      return res.status(404).json({ message: 'Cart item not found' });
    }

    cartItem.quantity = newQuantity;
    await cartItem.save();

    res.status(200).json({ message: 'Product quantity updated in cart' });
  } catch (error) {
    next(error);
  }
};
exports.removeAllCartProducts = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    
    await Cart.deleteMany({ user: userId });

    res.status(200).json({ message: 'All cart products removed successfully' });
  } catch (error) {
    next(error);
  }
};

exports.getOrdersForMerchant = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const user = await UserModel.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const userStoreId = user.stores;
   // console.log('userStoreId:', userStoreId);

    const allOrders = await OrderModel.find();
   // console.log('allOrders:', allOrders);

    const merchantOrders = allOrders.filter(order => {
      return order.products.some(product => {
        return product.storeId && userStoreId.includes(product.storeId.toString()); 
      });
    });

    const revenue = merchantOrders.reduce((total, order) => total + order.totalPrice, 0);

    res.status(200).json({ merchantOrders, revenue });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};




exports.addEmployee = async (req, res, next) => {
  try {
    const { userId } = req.params; 
    const { name, email, password, position,EmplymentType, ContractDuration, contactNumber, city} = req.body;

    const newEmployeeUser  = new EmployeeModel({
      name,
      email,
      password,
      position,
      EmplymentType,
      ContractDuration,
      userId,
      contactNumber,
      city
    });

    const savedEmployeeUser  = await newEmployeeUser .save();

    const user = await UserModel.findByIdAndUpdate(userId, {
      $push: { employees: savedEmployeeUser._id }
    }, { new: true }); 

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(201).json(savedEmployeeUser);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deleteEmployee = async (req, res, next) => {
  try {
    const { userId, employeeId } = req.params;
    const deletedEmployee = await EmployeeModel.deleteOne({ _id: employeeId });

    if (deletedEmployee.deletedCount === 0) {
      return res.status(404).json({ message: 'Employee not found' });
    }

    const user = await UserModel.findByIdAndUpdate(userId, {
      $pull: { employees: employeeId }
    }, { new: true });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'Employee deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getEmployeesOfUser = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const user = await UserModel.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const employees = await EmployeeModel.find({ userId });

    res.status(200).json(employees);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getEmployeeById = async (req, res, next) => {
  try {
    const { employeeId } = req.params;

    const employee = await EmployeeModel.findById(employeeId)
      .populate('userId', 'name email userType') 
      .populate('Tasks', 'title description status'); 

    if (!employee) {
      return res.status(404).json({ message: 'Employee not found' });
    }

    res.status(200).json(employee);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateEmployee = async (req, res, next) => {
  try {
    const { userId, employeeId } = req.params;
    const updateData = req.body;
    const user = await UserModel.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const employee = await EmployeeModel.findOneAndUpdate(
      { _id: employeeId, userId },
      updateData,
      { new: true }
    );

    if (!employee) {
      return res.status(404).json({ message: 'Employee not found' });
    }

    res.status(200).json(employee);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getUserFromEmployeeId = async (req, res, next) => {
  try {
    const { employeeId } = req.params;
    const employee = await EmployeeModel.findById(employeeId);

    if (!employee) {
      return res.status(404).json({ message: 'Employee not found' });
    }

    const user = await UserModel.findById(employee.userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ userId: user._id });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      throw new Error('Email or password missing');
    }

    let user = await UserService.getUserByEmail(email);
    let userType, userId,position;

    if (!user) {

      const employee = await EmployeeModel.findOne({ email });
      if (!employee) {
        throw new Error('User not found');
      }
      user = employee;
      userType = employee.userType;
      userId = employee.userId;
      position = employee.position;
    } else {
      userType = user.userType;
    }

    const isPasswordCorrect = (password === user.password);

    if (!isPasswordCorrect) {
      throw new Error('Incorrect password');
    }

    const tokenData = { _id: user._id, email: user.email };
    const token = await UserService.generateAccessToken(tokenData, "secret", "10h");

    let responseBody = {
      status: true,
      success: "sendData",
      token: token,
      _id: user._id,
      email: user.email,
      userType: userType,
      userId: userId,

    };

    if (userType === 'employee') {
      responseBody.position = position;
    }

    res.status(200).json(responseBody);
  } catch (error) {
    console.log(error, 'err ---->');
    next(error);
  }
}



exports.addTaskToEmployee = async (req, res, next) => {
  try {
    const { employeeId } = req.params;
    const taskData = req.body;

    const employee = await EmployeeModel.findById(employeeId);
    if (!employee) {
      return res.status(404).json({ message: 'Employee not found' });
    }
    taskData.employeeId = employeeId;

    const newTask = await TaskModel.create(taskData);

    employee.Tasks.push(newTask);
    await employee.save();

    res.status(201).json(newTask);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.editTask = async (req, res, next) => {
  try {
    const { taskId } = req.params;
    const updateData = req.body;

    const task = await TaskModel.findById(taskId);
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    for (const key in updateData) {
      if (task.schema.paths.hasOwnProperty(key)) {
        task[key] = updateData[key];
      }
    }

    const updatedTask = await task.save();

    res.status(200).json(updatedTask);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


exports.getTasksByEmployeeId = async (req, res, next) => {
  try {
    const { employeeId } = req.params;

    const employee = await EmployeeModel.findById(employeeId);
    if (!employee) {
      return res.status(404).json({ message: 'Employee not found' });
    }

    const tasks = await TaskModel.find({ employeeId });
  

    res.status(200).json(tasks);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deleteTaskFromEmployee = async (req, res, next) => {
  try {
    const { taskId } = req.params;

    const task = await TaskModel.findById(taskId);
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    const employee = await EmployeeModel.findOne({ Tasks: taskId });
    if (!employee) {
      return res.status(404).json({ message: 'Employee not found' });
    }

    const index = employee.Tasks.indexOf(taskId);
    employee.Tasks.splice(index, 1);
    await employee.save();

    await TaskModel.findByIdAndDelete(taskId);

    res.status(200).json({ message: 'Task deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getTasksForUser = async (req, res, next) => {
  try {
    const userId = req.params.userId; 
    const tasks = await TaskModel.find({ user: userId }).sort({ createdAt: -1 });

    res.status(200).json(tasks);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


exports.getAllUsers = async (req, res, next) => {
  try {
    const users = await UserModel.find();
    res.json({ status: true, success: "All users retrieved successfully!", users });
  } catch (error) {
    next(error);
  }
};

exports.getUserCount = async (req, res, next) => {
  try {
    const userCount = await UserModel.countDocuments();
    res.json({ status: true, success: "Total user count retrieved successfully!", count: userCount });
  } catch (error) {
    next(error);
  }
};

exports.getMerchantCount = async (req, res, next) => {
  try {
    const merchantCount = await UserModel.countDocuments({ userType: 'merchant' });
    res.json({ status: true, success: "Merchant count retrieved successfully!", count: merchantCount });
  } catch (error) {
    next(error);
  }
};

exports.getAdminCount = async (req, res, next) => {
  try {
    const adminCount = await UserModel.countDocuments({ userType: 'admin' });
    res.json({ status: true, success: "Admin count retrieved successfully!", count: adminCount });
  } catch (error) {
    next(error);
  }
};

exports.getEmployeeCount = async (req, res, next) => {
  try {
    const employeeCount = await EmployeeModel.countDocuments();
    res.json({ status: true, success: "Total employee count retrieved successfully!", count: employeeCount });
  } catch (error) {
    next(error);
  }
};


exports.getAllEmployees = async (req, res, next) => {
  try {
    const employees = await EmployeeModel.find({ userType: 'employee' });
    res.json({ status: true, success: "All employees retrieved successfully!", employees });
  } catch (error) {
    next(error);
  }
};


exports.getAllOrders = async (req, res, next) => {
  try {
    const orders = await OrderModel.find();
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Feedback section: 
exports.addFeedback = async (req, res, next) => {
  try {
    const { userId, note, stars } = req.body;

    // Validate stars
    if (stars < 1 || stars > 5) {
      return res.status(400).json({ message: 'Stars must be between 1 and 5' });
    }

    // Create new feedback
    const feedback = new Feedback({
      user: userId,
      note: note,
      stars: stars,
    });

    // Save to database
    await feedback.save();

    res.status(201).json({ message: 'Feedback added successfully', feedback });
  } catch (error) {
    console.error('Error adding feedback:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get all feedback
exports.getAllFeedback = async (req, res, next) => {
  try {
    const feedbacks = await Feedback.find().populate('user', 'name email');
    res.status(200).json(feedbacks);
  } catch (error) {
    console.error('Error fetching feedback:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get feedback by user ID
exports.getFeedbackByUserId = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const feedbacks = await Feedback.find({ user: userId }).populate('user', 'name email');
    if (feedbacks.length === 0) {
      return res.status(404).json({ message: 'No feedback found for this user' });
    }
    res.status(200).json(feedbacks);
  } catch (error) {
    console.error('Error fetching feedback:', error);
    res.status(500).json({ message: 'Server error' });
  }
};