#!/usr/bin/env node
/**
 * mcp-dws — DingTalk MCP Server
 *
 * Wraps wukong-cli to expose a single `dingtalk` tool for any MCP-compatible
 * AI agent: Claude, Cursor, Windsurf, Cline, Trae, OpenAI Codex, etc.
 *
 * Prerequisites: Wukong (悟空) desktop app must be running and logged in.
 * Download: https://wukong.dingtalk.com
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { execFileSync } from "child_process";
import { writeFileSync, unlinkSync } from "fs";
import { tmpdir } from "os";
import { join } from "path";
import { randomUUID } from "crypto";

// ---------------------------------------------------------------------------
// PowerShell helper — writes a temp .ps1 file to avoid inline escaping issues
// ---------------------------------------------------------------------------
function runPs(script, timeoutMs = 30_000) {
  const tmpFile = join(tmpdir(), `mcp-dws-${randomUUID()}.ps1`);
  try {
    writeFileSync(tmpFile, `﻿${script}`, "utf8"); // BOM for PS encoding
    return execFileSync(
      "powershell",
      ["-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", tmpFile],
      { encoding: "utf8", timeout: timeoutMs, windowsHide: true }
    );
  } finally {
    try { unlinkSync(tmpFile); } catch { /* ignore */ }
  }
}

// ---------------------------------------------------------------------------
// PowerShell scripts
// ---------------------------------------------------------------------------

const PS_CHECK_PIPE = String.raw`
$pipes = [System.IO.Directory]::GetFiles("\\.\pipe\") |
         Where-Object { $_ -match "real-daemon" }
Write-Output ($pipes.Count -gt 0).ToString().ToLower()
`;

const PS_FIND_WKCLI = String.raw`
$wkcli = $null

# Step 1: Locate from running Wukong process (fastest — pre-check guarantees it's running)
$exe = Get-Process -ErrorAction SilentlyContinue |
       Where-Object { $_.Path -and $_.Path -match '\\Wukong\\' } |
       Select-Object -First 1 -ExpandProperty Path
if ($exe) {
    # Process path is typically <root>\Wukong\<version>\xxx.exe — walk up to "Wukong" root
    $searchRoot = $exe
    for ($i = 0; $i -lt 3; $i++) {
        $parent = Split-Path $searchRoot -Parent
        if (-not $parent -or $parent -eq $searchRoot) { break }
        $searchRoot = $parent
        if ((Split-Path $searchRoot -Leaf) -eq 'Wukong') { break }
    }
    $wkcli = Get-ChildItem $searchRoot -Filter "wukong-cli.exe" -Recurse -ErrorAction SilentlyContinue |
             Select-Object -First 1 -ExpandProperty FullName
}

# Step 2 fallback: PATH
if (-not $wkcli -and (Get-Command wukong-cli -ErrorAction SilentlyContinue)) {
    $wkcli = "wukong-cli"
}

# Step 3 fallback: Registry
if (-not $wkcli) {
    $installDir = Get-ChildItem `
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" `
        -ErrorAction SilentlyContinue | Get-ItemProperty |
        Where-Object { $_.DisplayName -like "*Wukong*" -or $_.DisplayName -like "*悟空*" } |
        Select-Object -ExpandProperty InstallLocation -First 1
    if ($installDir) {
        $wkcli = Get-ChildItem $installDir -Recurse -Filter "wukong-cli.exe" `
                 -ErrorAction SilentlyContinue |
                 Select-Object -First 1 -ExpandProperty FullName
    }
}

Write-Output $wkcli
`;

// ---------------------------------------------------------------------------
// Server setup
// ---------------------------------------------------------------------------
const server = new Server(
  { name: "mcp-dws", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "dingtalk",
      description:
        "Execute any DingTalk operation via natural language. " +
        "Capabilities: send/read messages, manage groups, read/write documents, " +
        "check calendar, book meetings, handle OA approvals, manage todos, " +
        "search contacts, read/write spreadsheets, check attendance, send emails, " +
        "query AI meeting minutes, manage DingDrive files, and more. " +
        "Requires Wukong (悟空) desktop app running and logged in to DingTalk.",
      inputSchema: {
        type: "object",
        properties: {
          task: {
            type: "string",
            description:
              "Natural language description of the DingTalk operation. " +
              "Be specific: include names, document URLs/IDs, time ranges, " +
              "and the expected output format when relevant.",
          },
          max_turns: {
            type: "number",
            description:
              "Max agent turns inside wukong-cli. " +
              "3 = simple single-step query (default), " +
              "5 = multi-step or summary tasks, " +
              "8 = complex batch operations.",
            default: 3,
          },
        },
        required: ["task"],
      },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name !== "dingtalk") {
    throw new Error(`Unknown tool: ${request.params.name}`);
  }

  const task = String(request.params.arguments?.task ?? "").trim();
  const maxTurns = Math.min(Math.max(Number(request.params.arguments?.max_turns) || 3, 1), 10);

  if (!task) {
    return { content: [{ type: "text", text: "Error: task parameter is required." }] };
  }

  // --- Check Wukong daemon ---
  let daemonRunning = false;
  try {
    daemonRunning = runPs(PS_CHECK_PIPE).trim() === "true";
  } catch { /* powershell not available or other error */ }

  if (!daemonRunning) {
    return {
      content: [{
        type: "text",
        text: [
          "❌ Wukong daemon is not running.",
          "",
          "Please start the Wukong (悟空) desktop app and log in to your DingTalk account, then try again.",
          "Download: https://wukong.dingtalk.com",
        ].join("\n"),
      }],
    };
  }

  // --- Find wukong-cli ---
  let wkcli = "";
  try {
    wkcli = runPs(PS_FIND_WKCLI, 15_000).trim();
  } catch { /* ignore */ }

  if (!wkcli) {
    return {
      content: [{
        type: "text",
        text: [
          "❌ wukong-cli.exe not found.",
          "",
          "Please ensure the Wukong (悟空) desktop app is installed.",
          "Download: https://wukong.dingtalk.com",
        ].join("\n"),
      }],
    };
  }

  // --- Execute task ---
  // Single-quote escape for PowerShell: ' → ''
  const q = (s) => s.replace(/'/g, "''");

  const execScript = `
$wkcli = '${q(wkcli)}'
$result = & $wkcli \`
    --socket "\\\\.\\pipe\\real-daemon" \`
    -p '${q(task)}' \`
    --output-format json \`
    --max-turns ${maxTurns} \`
    2>&1 | Select-Object -First 20
try {
    $parsed = $result | ConvertFrom-Json
    Write-Output $parsed.output_text
} catch {
    Write-Output ($result -join "\`n")
}
`;

  try {
    const output = runPs(execScript, 120_000).trim();
    return {
      content: [{ type: "text", text: output || "(The operation completed but returned no output.)" }],
    };
  } catch (err) {
    return {
      content: [{ type: "text", text: `Error executing DingTalk task: ${err.message}` }],
    };
  }
});

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------
const transport = new StdioServerTransport();
await server.connect(transport);
