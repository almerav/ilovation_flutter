const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const pool = require("./db");

const app = express();

// ✅ Increase body size limit to handle large image uploads
app.use(bodyParser.json({ limit: "50mb" }));
app.use(bodyParser.urlencoded({ limit: "50mb", extended: true }));

app.use(express.json({ limit: "50mb" }));
app.use(cors());

// ✅ Fetch all events
app.get("/events", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM events ORDER BY start_datetime ASC");
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// ✅ Insert a new event
app.post("/events", async (req, res) => {
  try {
    const { title, email, description, location, event_type, category, start_datetime, end_datetime, image_url } = req.body;

    if (!title || !email || !description || !location || !event_type || !category || !start_datetime || !end_datetime) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const newEvent = await pool.query(
      "INSERT INTO events (title, email, description, location, event_type, category, start_datetime, end_datetime, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *",
      [title, email, description, location, event_type, category, start_datetime, end_datetime, image_url]
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
