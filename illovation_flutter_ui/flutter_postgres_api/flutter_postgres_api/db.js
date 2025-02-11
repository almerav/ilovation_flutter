const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  user: "postgres",
  host: "localhost",  // or your server IP if deployed
  database: "ilovation",
  password: "postgres",
  port: 5435, // This should match your docker-compose.yml port
});

pool.connect()
  .then(() => console.log("Connected to PostgreSQL"))
  .catch(err => console.error("Connection Error:", err));

module.exports = pool;
