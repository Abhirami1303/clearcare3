// const express = require('express');
// const bcryptjs = require('bcryptjs');

// const User = require('../models/user');
// const authRouter = express.Router();

// authRouter.post("/api/signup",async(req,res)=>{
// //authRouter.post("/signup",async(req,res)=>{
//     try{
//         const{name,email,password}=req.body;

//         const existingUser = await User.findOne({email});
//         if (existingUser){
//                 return res
//                 .status(400)
//                 .json({msg :"User with same email already exists! "});
//         }
//         const hashedPassword = await bcryptjs.hash(password,8);

//         let user = new User({
//             email,
//             password: hashedPassword,
//             name,
//         });
//         user = await User.save();

//     }
//     catch(e){
//         res.status(500).json({error : e.message});
//     }
// });

// module.exports = authRouter;




// const express = require("express");
// const bcryptjs = require("bcryptjs");
// const User = require("../models/user");
// const authRouter = express.Router();
// const jwt = require("jsonwebtoken");
// const auth = require("../middleware/auth");

// // Sign Up
// authRouter.post("/api/signup", async (req, res) => {
// //authRouter.post("/signup", async (req, res) => {
//   try {
//     const { name, email, password } = req.body;

//     const existingUser = await User.findOne({ email });
//     if (existingUser) {
//       return res
//         .status(400)
//         .json({ msg: "User with same email already exists!" });
//     }

//     const hashedPassword = await bcryptjs.hash(password, 8);

//     let user = new User({
//       email,
//       password: hashedPassword,
//       name,
//     });
//     user = await user.save();
//     res.json(user);
//   } catch (e) {
//     res.status(500).json({ error: e.message });
//   }
// });

// // Sign In

// authRouter.post("/api/signin", async (req, res) => {
// //authRouter.post("/signin", async (req, res) => {
//   try {
//     const { email, password } = req.body;

//     const user = await User.findOne({ email });
//     if (!user) {
//       return res
//         .status(400)
//         .json({ msg: "User with this email does not exist!" });
//     }

//     const isMatch = await bcryptjs.compare(password, user.password);
//     if (!isMatch) {
//       return res.status(400).json({ msg: "Incorrect password." });
//     }

//     const token = jwt.sign({ id: user._id }, "passwordKey");
//     res.json({ token, ...user._doc });
//   } catch (e) {
//     res.status(500).json({ error: e.message });
//   }
// });

// authRouter.post("/tokenIsValid", async (req, res) => {
//   try {
//     const token = req.header("x-auth-token");
//     if (!token) return res.json(false);
//     const verified = jwt.verify(token, "passwordKey");
//     if (!verified) return res.json(false);

//     const user = await User.findById(verified.id);
//     if (!user) return res.json(false);
//     res.json(true);
//   } catch (e) {
//     res.status(500).json({ error: e.message });
//   }
// });

// // get user data
// authRouter.get("/", auth, async (req, res) => {
//   const user = await User.findById(req.user);
//   res.json({ ...user._doc, token: req.token });
// });

// module.exports = authRouter;



const express = require("express");
const bcryptjs = require("bcryptjs");
const User = require("../models/user");
const Medicine = require("../models/medicine");
const FamilyMember = require("../models/family_member");
const authRouter = express.Router();
const jwt = require("jsonwebtoken");
const auth = require("../middleware/auth");

// Sign Up
authRouter.post("/api/signup", async (req, res) => {
  try {
    const { name, email, password } = req.body;
    console.log("/api/signup")
    // Checking if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res
        .status(400)
        .json({ msg: "User with same email already exists!" });
    }

    // Hashing the password
    const hashedPassword = await bcryptjs.hash(password, 8);

    // Create a new user
    let user = new User({
      email,
      password: hashedPassword,
      name
    });
    user = await user.save();

    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Sign In
authRouter.post("/api/signin", async (req, res) => {
  try {


    //print req //rem
    console.log("req",req)


    const { email, password } = req.body;

    // Find the user
    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(400)
        .json({ msg: "User with this email does not exist!" });
    }

    // Comparing passwords
    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Incorrect password." });
    }

    // Generating token
    const token = jwt.sign({ id: user._id }, "passwordKey");
    res.json({ token, ...user._doc });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

authRouter.post("/tokenIsValid", async (req, res) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) return res.json(false);
    const verified = jwt.verify(token, "passwordKey");
    if (!verified) return res.json(false);

    const user = await User.findById(verified.id);
    if (!user) return res.json(false);
    res.json(true);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get user data
authRouter.get("/", auth, async (req, res) => {
  const user = await User.findById(req.user);
  res.json({ ...user._doc, token: req.token });
});

// Add medicine
authRouter.post("/api/medicines", auth, async (req, res) => {
  try {

    //rem
    console.log("req",req)


    const { name, expiryDate, quantity, timings } = req.body;
    const medicine = new Medicine({
      name,
      expiryDate: new Date(expiryDate),
      quantity,
      timings
    });
    await medicine.save();

    const user = await User.findById(req.user);
    user.medicines.push({
      medicineId: medicine._id,
      quantity,
      timings
    });
    await user.save();

    res.json(medicine);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

//Get medicines
authRouter.get("/api/getmedicines", auth, async (req, res) => {
  try {
    console.log("/api/getmedicines")
    const user = await User.findById(req.user);
    const medicines = await Promise.all(
      user.medicines.map(async (medicine) => {
        const med = await Medicine.findById(medicine.medicineId);
        return med;
      })
    );
    console.log(medicines)
    res.json(medicines);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// Get medicines
// authRouter.get("/api/getmedicines", auth, async (req, res) => {
//   try {
//     // Get the user ID from the request object
//     //rem
//     console.log("req",req)
//     const userId = req.user;

//     // Find the user by ID
//     const user = await User.findById(userId);

//     // Check if the user exists
//     if (!user) {
//       return res.status(404).json({ error: "User not found" });
//     }

//     // Fetch medicines associated with the user
//     const medicines = await Promise.all(
//       user.medicines.map(async (medicine) => {
//         const med = await Medicine.findById(medicine.medicineId);
//         return med;
//       })
//     );

//     // Return the list of medicines
//     res.json(medicines);
//   } catch (e) {
//     res.status(500).json({ error: e.message });
//   }
// });

// // Update medicine quantity
// authRouter.patch("/api/medicines/:id", auth, async (req, res) => {
//   try {

//     //rem
//     console.log("req",req)

//     const { id } = req.params;
//     const { quantity } = req.body;

//     const medicine = await Medicine.findByIdAndUpdate(id, { quantity });
//     const user = await User.findById(req.user);
//     const medicineIndex = user.medicines.findIndex(
//       (m) => m.medicineId.toString() === id
//     );
//     user.medicines[medicineIndex].quantity = quantity;
//     await user.save();

//     res.json(medicine);
//   } catch (e) {
//     res.status(500).json({ error: e.message });
//   }
// });


// Add medicine
authRouter.post("/api/medicines", auth, async (req, res) => {
  try {
    console.log("/api/medicines")
    // Get user ID from the request object
    const userId = req.user;

    // Extract medicine data from the request body
    const { name, quantity, expiryDate, timings } = req.body;

    // Create a new Medicine object
    const medicine = new Medicine({
      name,
      quantity,
      expiryDate: new Date(expiryDate), // Include expiryDate here
      timings
    });

    // Save the medicine to the database
    await medicine.save();

    // Find the user by ID
    const user = await User.findById(userId);

    // Check if the user exists
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Add the newly created medicine to the user's list of medicines
    user.medicines.push({
      medicineId: medicine._id,
      quantity,
      expiryDate: medicine.expiryDate, // Include expiryDate here
      timings
    });

    // Save the updated user object
    await user.save();

    // Return the newly created medicine as the response
 
     res.json(medicine);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Update medicine quantity
authRouter.patch("/api/medicines/:id", auth, async (req, res) => {
  try {
    // Extract medicine ID and updated quantity from the request parameters and body
    const { id } = req.params;
    const { name, quantity, expiryDate, timings } = req.body;

    // Find the medicine by ID and update its quantity
    const medicine = await Medicine.findByIdAndUpdate(id, { quantity });

    // Find the user associated with the token
    const user = await User.findById(req.user);

    // Find the index of the medicine in the user's list of medicines
    const medicineIndex = user.medicines.findIndex(
      (m) => m.medicineId.toString() === id
    );

    // Update the quantity of the medicine in the user's list
    user.medicines[medicineIndex].quantity = quantity;

    // Save the updated user object
    await user.save();

    // Return the updated medicine as the response
    res.json(medicine);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// Add family member
authRouter.post("/api/add-family-member", auth, async (req, res) => {
  console.log("/api/add-family-member")
  try {
    const { name, email, phoneNumber } = req.body;
    const familyMember = new FamilyMember({
      name,
      email,
      phoneNumber
    });
    await familyMember.save();

    const user = await User.findById(req.user);
    user.familyMembers.push({
      familyMemberId: familyMember._id
    });
    await user.save();

    res.statusCode = 201
    res.json(familyMember);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get family members
authRouter.get("/api/family-members", auth, async (req, res) => {
  console.log("/api/family-members")
  try {
    const user = await User.findById(req.user);
    const familyMembers = await Promise.all(
      user.familyMembers.map(async (member) => {
        const m = await FamilyMember.findById(member.familyMemberId);
        return m;
      })
    );
    console.log(familyMembers)
    res.json(familyMembers);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = authRouter;