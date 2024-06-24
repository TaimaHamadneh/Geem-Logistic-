const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;


const employeeSchema = new Schema({
    name: String,
    email: String, 
    password: String,
    position: String,
    userId: { type: Schema.Types.ObjectId, ref: 'User' },
    userType: {
        type: String,
        enum: ['admin', 'merchant', 'employee', 'user'],
        default: 'employee'
    },
    EmplymentType: String, // full time, part time
    ContractDuration: {
        startDate: String,
        endDate: String,
        duration: String,

    },
    contactNumber: Number,
    city: String,
    image: String,
    Tasks: [{ type: Schema.Types.ObjectId, ref: 'Task' }],
    date: { type: Date, default: Date.now },
});

const EmployeeModel = db.model('employee', employeeSchema);


module.exports = EmployeeModel;
