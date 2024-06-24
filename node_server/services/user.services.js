const UserModel = require('../model/user.model');
const StoreModel = require('../model/store.model');

const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

class UserService {

  static async registerUser(userName, email, password, userType, about, location) {
    try {
      const existingUser = await UserModel.findOne({ email });
      if (existingUser) {
        throw new Error('User with this email already exists');
      }
      const createUser = new UserModel({ userName, email, password, userType, about, location });
      return await createUser.save();
    } catch (err) {
      throw err;
    }
  }

  static async getUserByEmail(email) {
    try {
      return await UserModel.findOne({ email });
    } catch (err) {
      console.log(err);
    }
  }
  static async generateAccessToken(tokenData, JWTSecret_Key, JWT_EXPIRE) {
    return jwt.sign(tokenData, JWTSecret_Key, { expiresIn: JWT_EXPIRE });
  }

  static async updateVerificationCode(userId, verificationCode) {
    try {
      return await UserModel.findByIdAndUpdate(userId, { verificationCode });
    } catch (err) {
      throw err;
    }
  }

  static async getUserByEmailAndVerificationCode(email, verificationCode) {
    try {
      return await UserModel.findOne({ email, verificationCode });
    } catch (err) {
      throw err;
    }
  }

}



module.exports = UserService;
