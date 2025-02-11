const express = require("express");
const cors = require("cors");
const pool = require("./db");

const app = express();
app.use(express.json());
app.use(cors());

// ✅ Fetch all events
app.get("/events", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM events ORDER BY start_time ASC");
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// ✅ Insert a new event
app.post("/events", async (req, res) => {
  try {
    const { name, description, location, type, category, start_time, end_time } = req.body;
    
    const newEvent = await pool.query(
      "INSERT INTO events (name, description, location, type, category, start_time, end_time) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *",
      [name, description, location, type, category, start_time, end_time]
    );

    res.json(newEvent.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// ✅ Start the server
const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
