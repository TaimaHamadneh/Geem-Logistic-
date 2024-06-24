const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const statusOption = [
    'Completed',
    'In Progress'
  ];

const tasksSchema = new Schema({
    title: String,
    description: String,
    user: { type: Schema.Types.ObjectId, ref: 'User' }, 
    employeeId: { type: Schema.Types.ObjectId, ref: 'employee' },
    date: { type: Date, default: Date.now },
    status: { 
        type: String,
        enum: statusOption,
        default: 'In Progress'
    },
    response:String,
    DeadlineDate: String,
});

const TaskModel = db.model('Task', tasksSchema);

module.exports = TaskModel;
