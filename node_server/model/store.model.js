const mongoose = require('mongoose');
const db = require('../config/db');
const { Schema } = mongoose;

const statusOption = [
    'available',
    'sold out'
];

const productSchema = new Schema({
    name: String,
    SerialNumber: String,
    date: { type: Date, default: Date.now },
    quantity: Number,
    store: { type: Schema.Types.ObjectId, ref: 'store' },
    sellingPrice: Number,
    image: String,
    description: String,
    category: String,
    status: { 
        type: String,
        enum: statusOption,
        default: 'available'
    },
    offer: Number
});

const storeSchema = new Schema({
    name: String,
    location: {
        type: { type: String },
        coordinates: [Number] 
    },
    category: String,
    image: String,
    address: String,
    area: String,
    contactNumber: String,
    products: [productSchema]
});

storeSchema.index({ location: '2dsphere' });

const StoreModel = db.model('store', storeSchema);

module.exports = {
    StoreModel,
    productSchema
};