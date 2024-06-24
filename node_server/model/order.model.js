const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const orderSchema = new Schema({
    user: { type: Schema.Types.ObjectId, ref: 'User' }, 
    products: [{
        productId: { type: Schema.Types.ObjectId, ref: 'StoreModel.products' }, 
        quantity: Number,
        storeId: String
    }],
    totalPrice: Number,
    customerInfo: {
        name: String,
        email: String,
        address: String,
        phone: String
    },
    status: {
        type: String,
        enum: ['pending', 'processing', 'shipped', 'delivered'],
        default: 'pending'
    },
    date: { type: Date, default: Date.now },
});

const OrderModel = db.model('Order', orderSchema);



module.exports = OrderModel;
