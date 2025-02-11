const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "ilovation",
  password: "root",  // Ensure this matches the updated password
  port: 5432,
});


pool.connect()
  .then(() => console.log("Connected to PostgreSQL"))
  .catch(err => console.error("Connection Error:", err));

module.exports = pool;
