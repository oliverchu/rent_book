#!/usr/bin/env node
/**
 * flutter_live.mjs — drive a running Flutter app through the Dart MCP server.
 *
 * Why: Flutter's hot reload cannot be triggered from the VM service alone
 * (`reloadSources` fails with "Error while starting Kernel isolate task").
 * It must go through the Flutter tool chain, which the official
 * `dart mcp-server` exposes over MCP. This script speaks MCP to it over stdio,
 * discovers the app via the Dart Tooling Daemon (DTD), and runs a command.
 *
 * Usage:
 *   node tool/flutter_live.mjs <command> [args]
 *
 * Commands:
 *   reload              hot reload the running app
 *   restart             hot restart (resets state, applies const changes)
 *   errors              print recent runtime errors
 *   semantics           print the visible UI text (accessibility labels)
 *   dump                print the widget tree
 *   analyze [path]      run the analyzer
 *   apps                list connected Flutter apps
 *   dtds                list Dart Tooling Daemon instances
 *
 * Env:
 *   FLUTTER_PROJECT   project root (default: cwd)
 *   DART_EXE          dart executable (default: "dart"; on Windows inside
 *                     Android Studio the PATH may be missing dart, so pass the
 *                     absolute path, e.g. E:/APP/Flutter/flutter/bin/cache/dart-sdk/bin/dart.exe)
 */
import { spawn, execSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { join, dirname } from 'node:path';

const PROJECT = process.env.FLUTTER_PROJECT ?? process.cwd();

/**
 * Resolve a dart executable Node can actually spawn. On Windows `where dart`
 * returns `dart.bat`, which Node cannot spawn directly, so derive the real
 * `dart.exe` from the Flutter SDK layout.
 */
function resolveDart() {
  if (process.env.DART_EXE) return { cmd: process.env.DART_EXE, shell: false };
  if (process.env.FLUTTER_ROOT) {
    const p = join(process.env.FLUTTER_ROOT, 'bin', 'cache', 'dart-sdk', 'bin',
      process.platform === 'win32' ? 'dart.exe' : 'dart');
    if (existsSync(p)) return { cmd: p, shell: false };
  }
  if (process.platform === 'win32') {
    try {
      const out = execSync('where dart', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] });
      const lines = out.split(/\r?\n/).map((s) => s.trim()).filter(Boolean);
      for (const l of lines) if (l.toLowerCase().endsWith('.exe') && existsSync(l)) return { cmd: l, shell: false };
      for (const l of lines) {
        const exe = join(dirname(l), 'cache', 'dart-sdk', 'bin', 'dart.exe');
        if (existsSync(exe)) return { cmd: exe, shell: false };
      }
    } catch { /* fall through */ }
  }
  return { cmd: 'dart', shell: true };
}
const DART = resolveDart();
const action = (process.argv[2] ?? 'reload').toLowerCase();
const arg1 = process.argv[3];

const log = (...a) => console.log(...a);
const die = (msg) => { console.error('✗ ' + msg); process.exit(1); };

/** Minimal MCP stdio client (newline-delimited JSON-RPC 2.0). */
class McpClient {
  constructor(exe, cwd) {
    this.proc = spawn(exe.cmd, ['mcp-server'], { cwd, stdio: ['pipe', 'pipe', 'pipe'], shell: exe.shell });
    this.buf = '';
    this.id = 1;
    this.pending = new Map();
    this.proc.stdout.on('data', (d) => this.#onData(d));
    this.proc.stderr.on('data', (d) => {
      const s = d.toString().trim();
      if (s && /error|exception|fail/i.test(s)) console.error('[srv] ' + s);
    });
  }
  #onData(chunk) {
    this.buf += chunk.toString();
    let i;
    while ((i = this.buf.indexOf('\n')) >= 0) {
      const line = this.buf.slice(0, i).trim();
      this.buf = this.buf.slice(i + 1);
      if (!line) continue;
      let msg;
      try { msg = JSON.parse(line); } catch { continue; }
      if (msg.id !== undefined && this.pending.has(msg.id)) {
        const r = this.pending.get(msg.id);
        this.pending.delete(msg.id);
        r(msg);
      }
    }
  }
  #send(obj) { this.proc.stdin.write(JSON.stringify(obj) + '\n'); }
  call(method, params = {}) {
    const id = this.id++;
    return new Promise((res, rej) => {
      this.pending.set(id, res);
      this.#send({ jsonrpc: '2.0', id, method, params });
      setTimeout(() => { if (this.pending.has(id)) { this.pending.delete(id); rej(new Error('timeout: ' + method)); } }, 120000);
    });
  }
  notify(method, params = {}) { this.#send({ jsonrpc: '2.0', method, params }); }
  async init() {
    await this.call('initialize', {
      protocolVersion: '2024-11-05',
      capabilities: {},
      clientInfo: { name: 'flutter_live', version: '1.0' },
    });
    this.notify('notifications/initialized');
  }
  /** Call an MCP tool and return its text payload. */
  async tool(name, args = {}) {
    const r = await this.call('tools/call', { name, arguments: args });
    if (r.error) throw new Error(JSON.stringify(r.error));
    const res = r.result ?? {};
    const text = (res.content ?? []).filter((c) => c.type === 'text').map((c) => c.text).join('\n');
    if (res.isError) throw new Error(text || 'tool error');
    return { text, raw: res };
  }
  close() { try { this.proc.kill(); } catch {} }
}

/** Find the DTD whose workspace root matches PROJECT, then connect. */
async function connectApp(client) {
  const dtds = await client.tool('dtd', { command: 'listDtdUris' });
  const blocks = dtds.text.split(/\n\s*\n/);
  const want = PROJECT.replace(/[\\/]+$/, '').toLowerCase();
  let pick = null;
  for (const b of blocks) {
    const uri = (b.match(/WS URI:\s*(\S+)/) ?? [])[1];
    const root = (b.match(/Workspace Root:\s*(.+)/) ?? [])[1]?.trim();
    if (uri && root && root.replace(/[\\/]+$/, '').toLowerCase() === want) { pick = uri; break; }
  }
  if (!pick) {
    const any = (dtds.text.match(/WS URI:\s*(\S+)/) ?? [])[1];
    if (!any) die('no Dart Tooling Daemon found — is the app running?');
    pick = any;
    log('! no DTD matched ' + PROJECT + ', falling back to ' + pick);
  }
  await client.tool('dtd', { command: 'connect', uri: pick });
  const apps = await client.tool('dtd', { command: 'listConnectedApps' });
  return { dtd: pick, apps: apps.text };
}

async function mainVmMethod(client, method, args = {}) {
  return client.tool('vm_service', { command: 'callMethod', method, ...args });
}

async function mainIsolate(client) {
  const vm = await mainVmMethod(client, 'getVM');
  const raw = vm.raw?.structuredContent ?? JSON.parse(vm.text);
  const iso = (raw.isolates ?? []).find((i) => i.name === 'main') ?? raw.isolates?.[0];
  if (!iso) die('no isolate found');
  return iso.id;
}

(async () => {
  const client = new McpClient(DART, PROJECT);
  try {
    await client.init();

    if (action === 'dtds') { log((await client.tool('dtd', { command: 'listDtdUris' })).text); return; }

    const { dtd, apps } = await connectApp(client);
    if (action === 'apps') { log(apps); return; }

    switch (action) {
      case 'reload': {
        const r = await client.tool('hot_reload', { clearRuntimeErrors: true });
        log('✓ ' + r.text.trim() + '   (dtd ' + dtd + ')');
        break;
      }
      case 'restart': {
        const r = await client.tool('hot_restart', {});
        log('✓ ' + r.text.trim());
        break;
      }
      case 'errors': {
        const r = await client.tool('get_runtime_errors', {});
        log(r.text.trim());
        break;
      }
      case 'analyze': {
        const r = await client.tool('analyze_files', arg1 ? { path: arg1 } : {});
        log(r.text.trim());
        break;
      }
      case 'semantics': {
        const iso = await mainIsolate(client);
        const r = await mainVmMethod(client, 'ext.flutter.debugDumpSemanticsTreeInTraversalOrder', { isolateId: iso });
        const data = r.raw?.structuredContent?.data ?? JSON.parse(r.text).data ?? r.text;
        log((data.match(/label: ".*"/g) ?? []).map((s) => s.replace('label: ', '')).join('\n') || data);
        break;
      }
      case 'dump': {
        const iso = await mainIsolate(client);
        const r = await mainVmMethod(client, 'ext.flutter.debugDumpApp', { isolateId: iso });
        const data = r.raw?.structuredContent?.data ?? JSON.parse(r.text).data ?? r.text;
        log(data);
        break;
      }
      default:
        die('unknown command: ' + action + ' (try reload|restart|errors|semantics|dump|analyze|apps|dtds)');
    }
  } catch (e) {
    die(e.message);
  } finally {
    client.close();
  }
})();
