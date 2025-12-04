import fs from "fs";
import path from "path";

function searchNodejsDirs(startDir, results = []) {
  let entries = [];

  try {
    entries = fs.readdirSync(startDir, { withFileTypes: true });
  } catch {
    return results; // skip unreadable directories
  }

  for (const entry of entries) {
    const fullPath = path.join(startDir, entry.name);

    // Found a directory named "nodejs"
    if (entry.isDirectory() && entry.name === "nodejs") {
      results.push(fullPath);
    }

    // Recursively continue search
    if (entry.isDirectory()) {
      searchNodejsDirs(fullPath, results);
    }
  }

  return results;
}

export const explore = async () => {
  const matches = searchNodejsDirs("/");

  return {
    statusCode: 200,
    body: JSON.stringify({ matches }, null, 2)
  };
};

/*
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
*/