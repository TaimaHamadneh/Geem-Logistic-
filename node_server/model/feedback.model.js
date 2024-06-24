const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const feedbackSchema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  note: String,
  stars: {
    type: Number,
    required: true,
    min: 1,
    max: 5,
  },
});

const FeedbackModel = db.model('Feedback', feedbackSchema);

module.exports = FeedbackModel;
