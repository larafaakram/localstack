import fs from "fs";

export const explore = async () => {
  const result = {
    opt: fs.readdirSync("/opt"),
    //nodejs: fs.readdirSync("/opt/nodejs"),
    //files: fs.readdirSync("/opt/nodejs")
  };

  return {
    statusCode: 200,
    body: JSON.stringify(result)
  };
};
