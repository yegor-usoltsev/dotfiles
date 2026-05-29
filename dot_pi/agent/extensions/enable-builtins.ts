import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const BUILTIN_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls"];

export default function (pi: ExtensionAPI) {
  pi.on("session_start", () => {
    const active = new Set(pi.getActiveTools());
    for (const tool of BUILTIN_TOOLS) active.add(tool);
    pi.setActiveTools([...active]);
  });
}
