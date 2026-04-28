import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { prisma } from "../../configure/db.js";
import crypto from "crypto";
import { Resend } from "resend";
import { Redis } from "@upstash/redis";

const resend = new Resend(process.env.RESEND_API);
const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN,
});

function generateOTP() {
  return crypto.randomInt(100000, 1000000).toString();
}

async function assignToken(data) {
  const access_token = jwt.sign(
    {
      email: data.email ?? "null",
      user_id: data.user_id,
      google_id: data.googleId ?? "null",
    },
    process.env.JWT_ACCESS_SECRET,
    {
      expiresIn: "15m",
    },
  );
  const refresh_token = jwt.sign(
    {
      email: data.email ?? "null",
      user_id: data.user_id,
      google_id: data.googleId ?? "null",
    },
    process.env.JWT_REFRESH_SECRET,
    {
      expiresIn: "15d",
    },
  );

  return {
    access_token: access_token,
    refresh_token: refresh_token,
  };
}

export async function googleTokens(req, res) {
  try {
    if (!req.user) {
      return res.status(401).json({ message: "Authentication failed" });
    }

    const { googleId, email, id } = req.user;

    if (!req.user) {
      return res.status(401).json({ message: "Authentication failed" });
    }

    const data = {
      email: email,
      googleId: googleId,
      user_id: id,
    };

    const token = await assignToken(data);

    res.redirect(
      `klyr://auth?access_token=${token.access_token}&refresh_token=${token.refresh_token}`,
    );
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
}

async function otpEmail(toEmail) {
  const otp = generateOTP();
  const expiresInMinutes = 5;

  const { data, error } = await resend.emails.send({
    from: "onboarding@resend.dev",
    to: "aayushmusale05@gmail.com",
    subject: "Verification email",
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 400px; margin: auto;">
        <h2>Verification Code</h2>
        <p>Hi,</p>
        <p>Use the code below to verify your identity:</p>
        <div style="
          font-size: 36px;
          font-weight: bold;
          letter-spacing: 8px;
          text-align: center;
          padding: 20px;
          background: #f4f4f4;
          border-radius: 8px;
          margin: 20px 0;
        ">
          ${otp}
        </div>
        <p>This code expires in <strong>${expiresInMinutes} minutes</strong>.</p>
        <p style="color: #999; font-size: 12px;">If you didn't request this, please ignore this email.</p>
      </div>
    `,
  });

  const hashedOTP = await crypto.createHash("sha256").update(otp).digest("hex");
  await redis.set(`otp:${toEmail}`, hashedOTP, { ex: 600 });
}

async function requestOTPController(req, res) {
  const { email } = req.body;

  //validate availability of email
  if (!email) {
    return res.status(400).json({
      message: "email-required",
    });
  }

  try {
    //send emial to verify email
    await otpEmail(email);
    return res.status(200).json({
      message: "success",
      email: email,
    });
  } catch (err) {
    return res.status(500).json({
      message: "server-error",
    });
  }
}

async function verifyEmailController(req, res) {
  try {
    const { email, otp } = req.body;
    const storedOTP = await redis.get(`otp:${email}`);

    //check if otp expired
    if (!storedOTP) {
      return res.status(400).json({ message: "otp-expired" });
    }

    const inputhashedOTP = await crypto
      .createHash("sha256")
      .update(otp)
      .digest("hex");

    //check for the otp
    if (storedOTP === inputhashedOTP) {
      //delete stored otp
      await redis.del(`otp:${email}`);

      //if user exists ok, else create one
      const user = await prisma.user.upsert({
        where: { email },
        update: {},
        create: { email },
      });

      //assign tokens
      const data = {
        email: user.email,
        user_id: user.id,
      };
      const tokens = await assignToken(data);

      const access_token = tokens.access_token;
      const refresh_token = tokens.refresh_token;

      //store hashed token
      const hashed_refresh_token = await bcrypt.hash(refresh_token, 10);
      await prisma.session.create({
        data: {
          user_id: user.id,
          token: hashed_refresh_token,
          expiresAt: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000),
        },
      });

      return res.status(200).json({
        message: "success",
        email: email,
        user_id: data.user_id,
        tokens: {
          access_token,
          refresh_token,
        },
      });
    }

    return res.status(404).json({
      message: "invalid-otp",
    });
  } catch (err) {
    return res.status(500).json({
      message: "server-error",
    });
  }
}

export { requestOTPController, verifyEmailController };
