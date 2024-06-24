const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
const db = require('../config/db');
const { StoreModel, productSchema } = require('./store.model');
const { Schema } = mongoose;

const locationOptions = [
    'other',
    'Jerusalem',
    'Tulkarm',
    'Qalqilya',
    'Bethlehem',
    'Beit Sahour',
    'Jericho',
    'Salfit',
    'Bethlehem',
    'Jenin',
    'Nablus',
    'Ramallah',
    'Al-Bireh',
    'Tubas',
    'Hebron'
];

const userSchema = new Schema({
    userName: {
        type: String,
        required: true
    },
    email: {
        type: String,
        lowercase: true,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    emailVerified: {
        type: Boolean,
        default: false
    },
    verificationCode: String,
    userType: {
        type: String,
        enum: ['admin', 'merchant', 'employee', 'user'],
        default: 'merchant'
    },
    about: String,
    location: {
        type: String,
        enum: locationOptions,
        default: 'other'
    },
    stores: [{ type: Schema.Types.ObjectId, ref: 'Store' }],
    employees: [{ type: Schema.Types.ObjectId, ref: 'Employee' }], 
    orders: [{ type: Schema.Types.ObjectId, ref: 'Order' }],
    date: { type: Date, default: Date.now },

});

userSchema.pre('save', async function (next) {
    try {
        var user = this;
        user.verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
        next();
    } catch (error) {
        next(error);
    }
});

const UserModel = db.model('User', userSchema);

module.exports = UserModel;
