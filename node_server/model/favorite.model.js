const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const favoriteScheme = new Schema({
    user: { type: Schema.Types.ObjectId, ref: 'User' }, 
    productId : String
});

const favScheme = db.model('Favorite', favoriteScheme);

module.exports = favScheme;
