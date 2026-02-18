import "dotenv/config";
import express from "express";
import cors from "cors";
import mogran from "morgan";
import "source-map-support/register";
import { taskRouter } from "./routes/tasks";
import errorHandler from "./middleware/errorHandler";

const app = express();

app.use(cors());
app.use(mogran("tiny"));

app.use(express.json());

app.use("/tasks", taskRouter);

app.use(errorHandler);

export default app;
