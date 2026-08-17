/**
 * restricted.ts — opt-in restricted mode for pi.
 *
 * Launch with `pi --restricted` to gate any tool call whose target path
 * resolves OUTSIDE the session working directory behind a yes/no prompt:
 *
 *   - file tools: read, write, edit, ls, grep, find
 *   - bash: best-effort scan for write-intent commands (cp, mv, rm, mkdir,
 *     touch, ln, tee, dd, sed -i, redirects >/>>) that touch outside paths
 *
 * Without the flag this extension is a complete no-op — pi keeps its normal
 * unrestricted behavior. `~` is expanded, `..` and absolute paths are
 * handled, and symlinks are resolved (realpath) so escapes through links are
 * caught. In headless/subagent contexts (no UI to ask with) restricted mode
 * denies the call outright.
 *
 * Deployed via home-manager:
 *   ~/nixos/config/pi/extensions/ -> ~/.config/pi/extensions/
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isAbsolute, relative, resolve, sep } from "node:path";
import { realpathSync } from "node:fs";

const FILE_TOOLS = new Set(["read", "write", "edit", "ls", "grep", "find"]);

// bash write-intent markers (verbs, sed -i, redirects)
const BASH_WRITE_RE =
  /\b(cp|mv|rm|mkdir|touch|ln|tee|dd|install|truncate|shred|chmod|chown)\b|\bsed\s+-[a-z]*i\b|>>?/;

export default function (pi: ExtensionAPI) {
  pi.registerFlag("restricted", {
    description: "Ask before tool calls touch files outside the working directory",
    type: "boolean",
    default: false,
  });

  const real = (p: string): string => {
    try {
      return realpathSync(p);
    } catch {
      return p;
    }
  };

  /** Resolve a path against cwd (~, .., absolute, symlinks) and tell if it escapes cwd. */
  const escapesCwd = (raw: string, cwd: string): boolean => {
    const expanded = raw.startsWith("~/") ? `${process.env.HOME ?? "/home"}${raw.slice(1)}` : raw;
    const abs = isAbsolute(expanded) ? expanded : resolve(cwd, expanded);
    const rel = relative(real(cwd), real(abs));
    return rel === ".." || rel.startsWith(`..${sep}`) || isAbsolute(rel);
  };

  const ask = async (ctx: any, verb: string, target: string): Promise<boolean> => {
    if (!ctx.hasUI) return false; // no UI to prompt with -> deny in restricted mode
    return ctx.ui.confirm("Outside working directory", `${verb} ${target}?`);
  };

  pi.on("tool_call", async (event: any, ctx: any) => {
    if (!pi.getFlag("restricted")) return;
    const cwd = ctx.sessionManager?.getCwd?.() ?? process.cwd();

    // --- file tools with an explicit path ---
    const raw = event.input?.path ?? event.input?.file_path;
    if (FILE_TOOLS.has(event.toolName) && typeof raw === "string") {
      if (escapesCwd(raw, cwd) && !(await ask(ctx, event.toolName, raw))) {
        return { block: true, reason: `Blocked: ${raw} is outside ${cwd}` };
      }
      return;
    }

    // --- bash: only care about write-intent commands touching outside paths ---
    if (event.toolName === "bash" && typeof event.input?.command === "string") {
      const cmd: string = event.input.command;
      if (!BASH_WRITE_RE.test(cmd)) return;
      const outside: string[] = cmd
        .split(/[\s"'=;|&()]+/)
        .filter(
          (t: string) =>
            t.startsWith("/") || t.startsWith("~/") || t.startsWith("./") || t.startsWith("../") || t.includes("/"),
        )
        .filter((t: string) => escapesCwd(t, cwd));
      if (outside.length > 0 && !(await ask(ctx, "bash", outside.join(" ")))) {
        return { block: true, reason: `Blocked: bash touches ${outside.join(" ")} outside ${cwd}` };
      }
    }
  });
}
