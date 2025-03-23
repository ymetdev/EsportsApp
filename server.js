const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json()); // รองรับ JSON request body

// เชื่อมต่อ MongoDB
mongoose.connect("mongodb://localhost:27017/blog_app", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// สร้าง Schema และ Model สำหรับ Users
const UserSchema = new mongoose.Schema({
  _id: Number,
  username: String,
  email: String,
  password: String,
  createdAt: { type: Date, default: Date.now },
});

const User = mongoose.model("User", UserSchema);

// สร้าง Schema และ Model สำหรับ Topics
const TopicSchema = new mongoose.Schema({
  _id: Number,
  title: String,
  content: String,
  userId: Number,
  createdAt: { type: Date, default: Date.now },
});

const Topic = mongoose.model("Topic", TopicSchema);

// สร้าง Schema และ Model สำหรับ Comments
const CommentSchema = new mongoose.Schema({
  _id: Number,
  topicId: Number,
  userId: Number,
  content: String,
  createdAt: { type: Date, default: Date.now },
});

const Comment = mongoose.model("Comment", CommentSchema);

// 📌 API ดึง users ทั้งหมด
app.get("/users", async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// 📌 API ดึง user ตาม ID
app.get("/users/:id", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// 📌 API สร้าง user ใหม่
app.post("/users", async (req, res) => {
  try {
    const lastUser = await User.findOne().sort({ _id: -1 }).limit(1);
    const newId = lastUser ? lastUser._id + 1 : 1; // ถ้าไม่มี user ก็เริ่มจาก 1

    const { username, email, password } = req.body;

    const newUser = new User({
      _id: newId,
      username,
      email,
      password,
    });

    await newUser.save();

    res.status(201).json({ message: "User Created", user: newUser });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// 📌 API ดึง topics ทั้งหมด
app.get("/topics", async (req, res) => {
  try {
    const topics = await Topic.find();
    res.json(topics);
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});
// 📌 API ลบ topic ตาม ID
app.delete("/topics/:id", async (req, res) => {
  try {
    const deletedTopic = await Topic.findByIdAndDelete(req.params.id);
    if (!deletedTopic) {
      return res.status(404).json({ error: "Topic not found" });
    }
    res.json({ message: "Topic deleted" });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// 📌 API ดึง topic ตาม ID
app.get("/topics/:id", async (req, res) => {
  try {
    const topic = await Topic.findById(req.params.id);
    if (!topic) {
      return res.status(404).json({ error: "Topic not found" });
    }
    res.json(topic);
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});
// 📌 API แก้ไข topic ตาม ID
app.put("/topics/:id", async (req, res) => {
  try {
    const { title, content } = req.body; // รับค่าที่ต้องการแก้ไข
    const topic = await Topic.findByIdAndUpdate(
      req.params.id,
      { title, content },
      { new: true } // ให้คืนค่าอันที่อัปเดตแล้วกลับมา
    );

    if (!topic) {
      return res.status(404).json({ error: "Topic not found" });
    }

    res.json({ message: "Topic updated", topic });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// 📌 API สร้าง topic ใหม่
app.post("/topics", async (req, res) => {
  try {
    const lastTopic = await Topic.findOne().sort({ _id: -1 }).limit(1);
    const newId = lastTopic ? lastTopic._id + 1 : 101; // ถ้าไม่มี topic ก็เริ่มจาก 101

    const { title, content, userId } = req.body;

    const newTopic = new Topic({
      _id: newId,
      title,
      content,
      userId,
    });

    await newTopic.save();

    res.status(201).json({ message: "Topic Created", topic: newTopic });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// 📌 API ดึง comments ทั้งหมด

app.get("/comments", async (req, res) => {
  try {
    const topicId = req.query.topicId;
    const comments = await Comment.find({ topicId: topicId });
    res.json(comments);
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// 📌 API ดึง comment ตาม ID
app.get("/comments/:id", async (req, res) => {
  try {
    const comment = await Comment.findById(req.params.id);
    if (!comment) {
      return res.status(404).json({ error: "Comment not found" });
    }
    res.json(comment);
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});
app.put("/comments/:id", async (req, res) => {
  try {
    const { content } = req.body; // รับค่าที่ต้องการแก้ไข

    // ค้นหาคอมเมนต์ตาม ID และอัปเดต
    const comment = await Comment.findByIdAndUpdate(
      req.params.id,
      { content }, // อัปเดตเฉพาะเนื้อหา
      { new: true } // ให้คืนค่าที่อัปเดตแล้ว
    );

    if (!comment) {
      return res.status(404).json({ error: "Comment not found" });
    }

    res.json({ message: "Comment updated", comment });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});
//  ลบ  comment
app.delete("/comments/:id", async (req, res) => {
  try {
    const deletedComment = await Comment.findByIdAndDelete(req.params.id);
    if (!deletedComment) {
      return res.status(404).json({ error: "Comment not found" });
    }
    res.json({ message: "Comment deleted" });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});
// 📌 API สร้าง comment ใหม่

app.post("/comments", async (req, res) => {
  try {
    const lastComment = await Comment.findOne().sort({ _id: -1 }).limit(1);
    const newId = lastComment ? lastComment._id + 1 : 1001; // ถ้าไม่มี comment ก็เริ่มจาก 1001

    const { topicId, userId, content } = req.body;

    const newComment = new Comment({
      _id: newId,
      topicId,
      userId,
      content,
    });

    await newComment.save();

    res.status(201).json({ message: "Comment Created", comment: newComment });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// เพิ่ม API สำหรับ Login
app.post("/login", async (req, res) => {
  try {
    const { username, password } = req.body;

    // ค้นหาผู้ใช้จาก username
    const user = await User.findOne({ username: username });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // ตรวจสอบ password
    if (user.password !== password) {
      return res.status(401).json({ error: "Invalid password" });
    }

    // หาก login สำเร็จ
    res.json({
      message: "Login successful",
      user: user, // ส่งข้อมูลผู้ใช้ไป
    });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// เริ่มเซิร์ฟเวอร์
app.listen(3000, () => {
  console.log("Server running at http://localhost:3000");
});
