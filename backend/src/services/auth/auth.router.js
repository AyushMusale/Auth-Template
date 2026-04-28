import express from "express";
import {
  verifyEmailController,
  requestOTPController,
} from "./auth.controller.js";
import passport from "passport";
import {googleTokens} from "./auth.controller.js"

const auth_router = express.Router();
//your-url/auth

auth_router.post("/get-otp", requestOTPController);
auth_router.post("/verify", verifyEmailController);
auth_router.get('/google', passport.authenticate('google', {
  scope: ['profile', 'email']
}));
auth_router.get('/google/callback', passport.authenticate('google',{session: false}) ,googleTokens)

export default auth_router;
