import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.setFooter((tui, theme, footerData) => ({
      invalidate() {},

      render(width: number): string[] {
        const lines: string[] = [];
        const entries = ctx.sessionManager.getEntries();

        // ---- cumulative token stats ----
        let totalInput = 0;
        let totalOutput = 0;
        let totalCacheRead = 0;
        let totalCacheWrite = 0;
        let totalCost = 0;
        let latestCacheHitRate: number | undefined;

        for (const entry of entries) {
          if (entry.type === "message" && entry.message.role === "assistant") {
            const u = entry.message.usage || { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: { total: 0 } };
            totalInput += u.input || 0;
            totalOutput += u.output || 0;
            totalCacheRead += u.cacheRead || 0;
            totalCacheWrite += u.cacheWrite || 0;
            totalCost += (u.cost?.total) || 0;
            const latest = (u.input || 0) + (u.cacheRead || 0) + (u.cacheWrite || 0);
            latestCacheHitRate = latest > 0 ? ((u.cacheRead || 0) / latest) * 100 : undefined;
          }
        }

        const fmt = (n: number): string =>
          n < 1000 ? `${n}` : n < 10000 ? `${(n / 1000).toFixed(1)}k` :
          n < 1000000 ? `${Math.round(n / 1000)}k` :
          n < 10000000 ? `${(n / 1000000).toFixed(1)}M` : `${Math.round(n / 1000000)}M`;

        const ctxUsage = ctx.getContextUsage();
        const ctxWindow = ctxUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
        const ctxPctVal = ctxUsage?.percent ?? 0;
        const ctxPct = ctxUsage?.percent !== null ? ctxPctVal.toFixed(1) : "?";
        const model = ctx.model;
        const sub = model ? ctx.modelRegistry.isUsingOAuth(model) : false;
        const dim = (s: string) => theme.fg("dim", s);

        // ---- Build stats line ----
        // Layout: ↑91k ↓41k • $0.037 13.0%/1.0M • R4.5M CH98.8%

        // Part 1: input / output (dimmed)
        let leftBlock = "";
        if (totalInput) leftBlock += `↑${fmt(totalInput)}`;
        if (totalOutput) leftBlock += ` ↓${fmt(totalOutput)}`;

        // Part 2: cost + context (highlighted in syntaxString — the str pink)
        const costStr = totalCost || sub ? `$${totalCost.toFixed(3)}${sub ? " (sub)" : ""}` : "";
        const ctxStr = `${ctxPct}%/${fmt(ctxWindow)} (auto)`;
        const highlightBlock = [costStr, ctxStr].filter(Boolean).join(" ");

        // Part 3: cache stats (dimmed)
        let rightBlock = "";
        if (totalCacheRead) rightBlock += `R${fmt(totalCacheRead)}`;
        if (totalCacheWrite) rightBlock += ` W${fmt(totalCacheWrite)}`;
        if ((totalCacheRead > 0 || totalCacheWrite > 0) && latestCacheHitRate !== undefined) {
          rightBlock += ` CH${latestCacheHitRate.toFixed(1)}%`;
        }

        // Assemble with dimmed • separators
        const segments: string[] = [];
        if (leftBlock) segments.push(dim(leftBlock));
        if (highlightBlock) segments.push(theme.fg("accent", highlightBlock));
        if (rightBlock) segments.push(dim(rightBlock));
        const statsLeft = segments.join(dim(" • "));

        // ---- pwd line ----
        let pwd = ctx.sessionManager.getCwd() || "";
        const home = process.env.HOME || process.env.USERPROFILE;
        if (home && pwd.startsWith(home)) pwd = "~" + pwd.slice(home.length);
        const branch = footerData.getGitBranch();
        if (branch) pwd = `${pwd} (${branch})`;
        const sname = ctx.sessionManager.getSessionName();
        if (sname) pwd = `${pwd} • ${sname}`;
        lines.push(truncateToWidth(dim(pwd), width, dim("...")));

        // ---- model name on the right ----
        // Highlight the model id itself (not the provider prefix)
        const provCnt = footerData.getAvailableProviderCount();
        const providerPart = provCnt > 1 && ctx.model ? dim(`(${ctx.model.provider}) `) : "";
        const modelPart = ctx.model?.id ? theme.fg("accent", ctx.model.id) : dim("no-model");

        const rightSide = providerPart + modelPart;
        const rightPlain = providerPart + (ctx.model?.id || "no-model");

        const leftW = visibleWidth(statsLeft);
        const rightW = visibleWidth(rightPlain);
        const pad = 2;

        let stats: string;
        if (leftW + pad + rightW <= width) {
          stats = statsLeft + dim(" ".repeat(width - leftW - rightW)) + rightSide;
        } else {
          const avail = width - leftW - pad;
          if (avail > 0) {
            const tr = truncateToWidth(rightPlain, avail, "");
            const trW = visibleWidth(tr);
            // Rebuild right side truncated: check if provider fits
            if (provCnt > 1 && ctx.model) {
              const provStr = `(${ctx.model.provider}) `;
              const provW = visibleWidth(provStr);
              if (provW < avail) {
                const modelTrunc = truncateToWidth(ctx.model.id, avail - provW, "");
                const rightTrunc = dim(provStr) + theme.fg("accent", modelTrunc);
                stats = statsLeft + dim(" ".repeat(Math.max(0, width - leftW - visibleWidth(provStr + modelTrunc)))) + rightTrunc;
              } else {
                stats = statsLeft;
              }
            } else {
              const rightTrunc = theme.fg("accent", tr);
              stats = statsLeft + dim(" ".repeat(Math.max(0, width - leftW - trW))) + rightTrunc;
            }
          } else {
            stats = statsLeft;
          }
        }

        lines.push(stats);

        // ---- extension statuses ----
        const ext = footerData.getExtensionStatuses();
        if (ext.size > 0) {
          const s = Array.from(ext.entries())
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([, t]) => t.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim())
            .join(" ");
          lines.push(truncateToWidth(s, width, dim("...")));
        }

        return lines;
      },

      dispose() {},
    }));
  });
}
