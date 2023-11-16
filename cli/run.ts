import {
  Command,
  CompletionsCommand,
} from "cliffy/command/mod.ts";

import { submit, validate } from "./database_commands.ts";

const main = new Command()
  .name("ddbj-repository")
  .version("0.1.0")
  .description("Command-line client for DDBJ Repository API")
  .globalOption("--endpoint <url:string>", "API endpoint URL", {
    default: "http://localhost:3000/api",
  })
  .action(() => main.showHelp())
  .command("validate", validate)
  .command("submit", submit)
  .command("completion", new CompletionsCommand());

await main.parse(Deno.args);
