require("dotenv").config();
module.exports = {
  development: {
    username: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_DATABASE,
    host: process.env.DB_ENDPOINT,
    port: process.env.DB_PORT,
    dialect: "postgres",
    define: {
      freezeTableName: true,
    },
    connectionString: process.env.DB_CONNECTION_STRING,
    configToken: {
      SEED: "secret",
      expiration: "24h",
    },
  },
  test: {
    username: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_DATABASE,
    host: process.env.DB_ENDPOINT,
    port: process.env.DB_PORT,
    dialect: "postgres",
    define: {
      freezeTableName: true,
    },
    configToken: {
      SEED: "secret",
      expiration: "24h",
    },
  },
  production: {
    username: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_DATABASE,
    host: process.env.DB_ENDPOINT,
    port: process.env.DB_PORT,
    dialect: "postgres",
    define: {
      freezeTableName: true,
    },
    configToken: {
      SEED: "secret",
      expiration: "24h",
    },
  },
};
