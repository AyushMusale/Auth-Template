import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { prisma } from "../../configure/db.js";

function authmiddleware(req, res, next) {
  const token = req.headers.authorization?.split(" ")[1]; //gets the token only

  if (!token) return res.status(401).json({ message: "no-token" });

  try {
    const decoded = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
    req.user = decoded; // attach user to request
    next();
  } catch (err) {
    if (err.name === "TokenExpiredError") {
      return res.status(401).json({ message: "access-token-expired" });
    }
    return res.status(401).json({ message: "invalid-token" });
  }
}

async function refreshUserController(req, res) {
  const { refresh_token } = req.body;

  if (!refresh_token) {
    return res.status(400).json({ message: "refresh-token-required" });
  }

  try {
    // verify refresh token signature + expiry
    const decoded = jwt.verify(refresh_token, process.env.JWT_REFRESH_SECRET);

    // check it exists in DB
    const session = await prisma.session.findFirst({
      where: { user_id: decoded.user_id },
    });

    if (!session) {
      return res.status(401).json({ message: "session-not-found" });
    }

    // compare against stored hash
    const isValid = await bcrypt.compare(refresh_token, session.token);
    if (!isValid) {
      return res.status(401).json({ message: "invalid-refresh-token" });
    }

    // issue new tokens
    const newTokens = await assignToken({
      email: decoded.email,
      id: decoded.user_id,
    });

    // replace old session with new refresh token
    await prisma.session.update({
      where: { id: session.id },
      data: {
        token: await bcrypt.hash(newTokens.refresh_token, 10), // ✅ hash new token
        expiresAt: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000),
      },
    });

    return res.status(200).json({
      message: "success",
      tokens: newTokens,
    });
  } catch (err) {
    if (err.name === "TokenExpiredError") {
      return res.status(401).json({ message: "refresh-token-expired" });
    }
    return res.status(401).json({ message: "invalid-token" });
  }
}


export{
    authmiddleware,
    refreshUserController
}