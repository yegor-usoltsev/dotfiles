import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { tavily } from "@tavily/core";
import { Type } from "typebox";

const API_KEY = process.env.TAVILY_API_KEY;
if (!API_KEY) {
  throw new Error("TAVILY_API_KEY is required for the Tavily Pi extension.");
}
const tvly = tavily({ apiKey: API_KEY });

function clamp(
  n: number | undefined,
  min: number,
  max: number,
  fallback: number,
) {
  if (typeof n !== "number" || Number.isNaN(n)) return fallback;
  return Math.max(min, Math.min(max, n));
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description: "Search the web using Tavily Search.",
    promptSnippet:
      "Search the web for current or external information using Tavily.",
    promptGuidelines: [
      "Use web_search when the user asks for current, external, or online information.",
    ],
    parameters: Type.Object({
      query: Type.String({ description: "Search query." }),
      maxResults: Type.Optional(
        Type.Number({ description: "Max results, 1-20. Default 5." }),
      ),
      searchDepth: Type.Optional(
        Type.Union([Type.Literal("basic"), Type.Literal("advanced")]),
      ),
      topic: Type.Optional(
        Type.Union([
          Type.Literal("general"),
          Type.Literal("news"),
          Type.Literal("finance"),
        ]),
      ),
      includeAnswer: Type.Optional(Type.Boolean()),
      includeRawContent: Type.Optional(Type.Boolean()),
      includeDomains: Type.Optional(Type.Array(Type.String())),
      excludeDomains: Type.Optional(Type.Array(Type.String())),
    }),
    async execute(_toolCallId, params) {
      const response = await tvly.search(params.query, {
        maxResults: clamp(params.maxResults, 1, 20, 5),
        searchDepth: params.searchDepth ?? "basic",
        topic: params.topic ?? "general",
        includeAnswer: params.includeAnswer ?? false,
        includeRawContent: params.includeRawContent ?? false,
        includeDomains: params.includeDomains ?? [],
        excludeDomains: params.excludeDomains ?? [],
      });

      return {
        content: [{ type: "text", text: JSON.stringify(response, null, 2) }],
        details: response,
      };
    },
  });

  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description:
      "Fetch/extract readable content from one URL using Tavily Extract.",
    promptSnippet:
      "Fetch and extract readable markdown/text content from a URL using Tavily.",
    promptGuidelines: [
      "Use web_fetch when the user gives a URL and wants its page contents.",
    ],
    parameters: Type.Object({
      url: Type.String({ description: "HTTP/HTTPS URL to fetch." }),
      query: Type.Optional(
        Type.String({
          description: "Optional user intent for reranking chunks.",
        }),
      ),
      extractDepth: Type.Optional(
        Type.Union([Type.Literal("basic"), Type.Literal("advanced")]),
      ),
      format: Type.Optional(
        Type.Union([Type.Literal("markdown"), Type.Literal("text")]),
      ),
      includeImages: Type.Optional(Type.Boolean()),
      maxChars: Type.Optional(
        Type.Number({ description: "Max returned characters. Default 20000." }),
      ),
    }),
    async execute(_toolCallId, params) {
      const parsed = new URL(params.url);
      if (!["http:", "https:"].includes(parsed.protocol)) {
        throw new Error("Only http/https URLs are supported.");
      }

      const response = await tvly.extract([params.url], {
        query: params.query,
        extractDepth: params.extractDepth ?? "basic",
        format: params.format ?? "markdown",
        includeImages: params.includeImages ?? false,
      });

      const maxChars = clamp(params.maxChars, 1000, 200000, 20000);
      const text = JSON.stringify(response, null, 2);
      const truncated =
        text.length > maxChars
          ? `${text.slice(0, maxChars)}\n\n[truncated]`
          : text;

      return {
        content: [{ type: "text", text: truncated }],
        details: response,
      };
    },
  });
}
