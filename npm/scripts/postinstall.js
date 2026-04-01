#!/usr/bin/env node
"use strict";

const https = require("https");
const http = require("http");
const fs = require("fs");
const path = require("path");
const os = require("os");

const REPO = "4DvAnCeBoY/testmu-browser-agent-public";
const BASE_URL = `https://github.com/${REPO}/releases/latest/download`;

const PLATFORM_MAP = {
  darwin: "darwin",
  linux: "linux",
  win32: "windows",
};

const ARCH_MAP = {
  arm64: "arm64",
  x64: "amd64",
};

function getBinaryName() {
  const platform = PLATFORM_MAP[process.platform];
  const arch = ARCH_MAP[process.arch];

  if (!platform) {
    throw new Error(
      `Unsupported platform: ${process.platform}. Supported: darwin, linux, win32`
    );
  }
  if (!arch) {
    throw new Error(
      `Unsupported architecture: ${process.arch}. Supported: x64, arm64`
    );
  }

  const ext = process.platform === "win32" ? ".exe" : "";
  return `testmu-browser-agent-${platform}-${arch}${ext}`;
}

function download(url) {
  return new Promise((resolve, reject) => {
    const client = url.startsWith("https") ? https : http;
    client
      .get(url, { headers: { "User-Agent": "testmu-browser-agent-npm" } }, (res) => {
        // Follow redirects (GitHub releases use 302)
        if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
          return download(res.headers.location).then(resolve, reject);
        }
        if (res.statusCode !== 200) {
          return reject(
            new Error(`Download failed with status ${res.statusCode}: ${url}`)
          );
        }
        const chunks = [];
        res.on("data", (chunk) => chunks.push(chunk));
        res.on("end", () => resolve(Buffer.concat(chunks)));
        res.on("error", reject);
      })
      .on("error", reject);
  });
}

async function main() {
  const binaryName = getBinaryName();
  const url = `${BASE_URL}/${binaryName}`;
  const binDir = path.join(__dirname, "..", "bin");
  const ext = process.platform === "win32" ? ".exe" : "";
  const dest = path.join(binDir, `testmu-browser-agent${ext}`);

  console.log(`Downloading ${binaryName} from GitHub releases...`);

  if (!fs.existsSync(binDir)) {
    fs.mkdirSync(binDir, { recursive: true });
  }

  try {
    const data = await download(url);
    fs.writeFileSync(dest, data);

    if (process.platform !== "win32") {
      fs.chmodSync(dest, 0o755);
    }

    console.log(`Successfully installed testmu-browser-agent to ${dest}`);
  } catch (err) {
    console.error(`\nFailed to download testmu-browser-agent binary.`);
    console.error(`URL: ${url}`);
    console.error(`Error: ${err.message}`);
    console.error(
      `\nYou can manually download the binary from:`
    );
    console.error(
      `https://github.com/${REPO}/releases`
    );
    process.exit(1);
  }
}

main();
