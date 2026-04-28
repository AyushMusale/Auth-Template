import passport from "passport";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import { prisma } from "../configure/db.js";

passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID_WEBAPP,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: "http://localhost:${process.env.SERVER_PORT}/your-url/auth/google/callback",
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        const googleId = profile.id;
        const email = profile.emails?.[0]?.value ?? null;

        let user = await prisma.user.findUnique({ where: { email } });

        if (user) {
          user = await prisma.user.update({
            where: { email },
            data: { googleId },
          });
        } else {
          user = await prisma.user.create({
            data: { googleId, email },
          });
        }

        return done(null, user);
      } catch (err) {
        return done(err, null);
      }
    },
  ),
);
