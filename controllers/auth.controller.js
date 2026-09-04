const User = require('../models/user.model');



//Regidtration 

const registerUser = async (req, res) => {
    try{
        const {username, password} = req.body;
        if(!username || !password){
            return res.status(400).json({message: "Username & Password required"})
        }
        const existingUser = await User.findOne({ username});
        if(existingUser ){
            return res.status(400).json({message:"User Already Exists"});
        }
        const newUser = await User.create({ username, password});
        res.status(201).json({message:"User Registered ", userId: newUser._id});

    } catch(error){
        res.status(500).json({ message: error.message});
    }
};


// Login Appi 

const loginUser = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ message: "Username & Password Required" });
    }

    const user = await User.findOne({ username });

    if (!user || user.password !== password) {
      return res.status(401).json({ message: "Invalid Username or Password" });
    }

    res.status(200).json({
      message: "Login successful",
      user: { id: user._id, username: user.username },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};



module.exports = {
registerUser,
loginUser,

};