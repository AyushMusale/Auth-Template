import express from "express";
import root_router from "./src/configure/routes.js";
import passport from "passport";
import "./src/configure/passport.js";

const app = express();

app.use(express.json());
app.use(passport.initialize());

app.use("/your-url", root_router);
export async function init() {
  const PORT = process.env.SERVER_PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Server Started on ${PORT}`);
  });
}

export default app;
