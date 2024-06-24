const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const cartSchema = new Schema({
    user: { type: Schema.Types.ObjectId, ref: 'User' }, 
    productId: { type: Schema.Types.ObjectId, ref: 'StoreModel.products' }, 
    quantity: Number,
    sellingPrice: Number,
    storeId: String,
    offer: Number
});

const CartModel = db.model('Cart', cartSchema);

module.exports = CartModel;



