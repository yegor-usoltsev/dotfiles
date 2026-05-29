import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Context7, Context7Error } from "@upstash/context7-sdk";
import { Type } from "typebox";

const API_KEY = process.env.CONTEXT7_API_KEY;
if (!API_KEY) {
  throw new Error(
    "CONTEXT7_API_KEY is required for the Context7 Pi extension.",
  );
}
const client = new Context7({ apiKey: API_KEY });

function stringifyError(error: unknown) {
  if (error instanceof Context7Error)
    return `Context7 API Error: ${error.message}`;
  if (error instanceof Error) return error.message;
  return String(error);
}

function truncate(text: string, maxChars = 50000) {
  return text.length > maxChars
    ? `${text.slice(0, maxChars)}\n\n[truncated]`
    : text;
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "context7_search_library",
    label: "Context7 Search Library",
    description:
      "Search Context7 for libraries and return matching library IDs with metadata.",
    promptSnippet:
      "Search Context7 for library IDs before fetching library documentation.",
    promptGuidelines: [
      "Use context7_search_library before context7_get_context when the exact Context7 library ID is unknown.",
    ],
    parameters: Type.Object({
      query: Type.String({
        description: "User task/question for relevance ranking.",
      }),
      libraryName: Type.String({
        description: "Library name to search for, e.g. react, next, zod.",
      }),
      format: Type.Optional(
        Type.Union([Type.Literal("json"), Type.Literal("txt")], {
          description: "Response format. Default json.",
        }),
      ),
      maxChars: Type.Optional(
        Type.Number({ description: "Max returned characters. Default 50000." }),
      ),
    }),
    async execute(_toolCallId, params) {
      try {
        const format = params.format ?? "json";
        const result = await client.searchLibrary(
          params.query,
          params.libraryName,
          { type: format },
        );
        const text =
          typeof result === "string" ? result : JSON.stringify(result, null, 2);
        return {
          content: [{ type: "text", text: truncate(text, params.maxChars) }],
          details: result,
        };
      } catch (error) {
        throw new Error(stringifyError(error));
      }
    },
  });

  pi.registerTool({
    name: "context7_get_context",
    label: "Context7 Get Context",
    description:
      "Get relevant documentation context for a Context7 library ID.",
    promptSnippet:
      "Fetch current library documentation from Context7 for a known library ID.",
    promptGuidelines: [
      "Use context7_get_context when the user asks about a library/API and a Context7 library ID is known.",
    ],
    parameters: Type.Object({
      query: Type.String({
        description: "User task/question for relevance ranking.",
      }),
      libraryId: Type.String({
        description: "Context7 library ID, e.g. /facebook/react.",
      }),
      format: Type.Optional(
        Type.Union([Type.Literal("json"), Type.Literal("txt")], {
          description: "Response format. Default json.",
        }),
      ),
      maxChars: Type.Optional(
        Type.Number({ description: "Max returned characters. Default 50000." }),
      ),
    }),
    async execute(_toolCallId, params) {
      try {
        const format = params.format ?? "json";
        const result = await client.getContext(params.query, params.libraryId, {
          type: format,
        });
        const text =
          typeof result === "string" ? result : JSON.stringify(result, null, 2);
        return {
          content: [{ type: "text", text: truncate(text, params.maxChars) }],
          details: result,
        };
      } catch (error) {
        throw new Error(stringifyError(error));
      }
    },
  });
}
