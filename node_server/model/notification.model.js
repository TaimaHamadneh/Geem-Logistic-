const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const notifiScheme = new Schema({
    user: { type: Schema.Types.ObjectId, ref: 'User' }, 
    id: Number,
    title: String,
    body: String,
    date: String,//{ type: Date, default: Date.now },
});

const NotifiScheme = db.model('Notification', notifiScheme);

module.exports = NotifiScheme;
