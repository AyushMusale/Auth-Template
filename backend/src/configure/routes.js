import auth_router from "../services/auth/auth.router.js"
import { Router } from "express";

const root_router = Router();
//root url: /klyr/api

root_router.use('/auth', auth_router);

export default root_router;