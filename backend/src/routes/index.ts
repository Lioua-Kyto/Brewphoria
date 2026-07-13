import { Router } from "express";
import authRouter from "./auth";
import userRouter from "./users";
import productRouter from "./products";
import categoryRouter from "./categories";
import cartRouter from "./cart";
import orderRouter from "./orders";
import reviewRouter from "./reviews";
import loyaltyRouter from "./loyalty";
import notificationRouter from "./notifications";
import chatRouter from "./chat";
import placesRouter from "./places";
import adminRouter from "./admin";

const v1Router = Router();

v1Router.use("/auth", authRouter);
v1Router.use("/users", userRouter);
v1Router.use("/products", productRouter);
v1Router.use("/categories", categoryRouter);
v1Router.use("/cart", cartRouter);
v1Router.use("/orders", orderRouter);
v1Router.use("/reviews", reviewRouter);
v1Router.use("/loyalty", loyaltyRouter);
v1Router.use("/notifications", notificationRouter);
v1Router.use("/chat", chatRouter);
v1Router.use("/places", placesRouter);
v1Router.use("/admin", adminRouter);

export default v1Router;
