import { basename, resolve, toFileUrl } from "std/path/mod.ts";
import { delay } from "std/async/mod.ts";

import dbs from "./db.json" with { type: "json" };
import { colorize } from "https://deno.land/x/json_colorize@0.1.0/mod.ts";

import {
  Command,
  CompletionsCommand,
} from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";

const validate = databaseCommands(
  "validations",
  dbs,
  (db) => `Validate ${db.id} files.`,
)
  .description("Validate the specified files.")
  .action(() => validate.showHelp());

const submit = databaseCommands(
  "submissions",
  dbs,
  (db) => `Submit files to ${db.id}.`,
)
  .description("Submit files to the specified database.")
  .action(() => submit.showHelp());

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

type Db = {
  id: string;
  objects: Obj[];
};

type Obj = {
  id: string;
  ext: string;
  optional?: boolean;
  multiple?: boolean;
};

function databaseCommands(
  resource: string,
  dbs: Db[],
  descriptionFn: (db: Db) => string,
) {
  let cmd = new Command<
    { endpoint: string; user: string; file: Record<string, string | string[]> }
  >();

  for (const db of dbs) {
    cmd = cmd
      .command(db.id.toLowerCase())
      .description(descriptionFn(db))
      .option("--user <uid:string>", "D-way user ID", { required: true });

    for (const { id, ext, optional, multiple } of db.objects) {
      cmd = cmd.option(
        `--file.${id.toLowerCase()} <path:file>`,
        `Path to ${id} file (${ext})`,
        { required: optional !== true, collect: multiple === true },
      );
    }

    cmd = cmd.action(async ({ endpoint, user, file }) => {
      const { request } = await createRequest(
        endpoint,
        user,
        resource,
        db,
        file,
      );

      const payload = await waitForRequestFinished(request.url, user);

      colorize(JSON.stringify(payload, null, 2));
    });
  }

  return cmd.reset();
}

async function createRequest(
  endpoint: string,
  user: string,
  resource: string,
  db: Db,
  files: Record<string, string | string[]>,
) {
  const body = new FormData();

  const promises = Object.entries(files).flatMap(([id, paths]) => {
    return [paths].flat().map((path) => [id, path]);
  }).map(async ([id, path]) => {
    const obj = db.objects.find((obj) => obj.id.toLowerCase() === id);
    const key = obj?.multiple ? `${obj.id}[]` : obj!.id;
    const file = await fetch(toFileUrl(resolve(path)));

    body.append(key, await file.blob(), basename(path));
  });

  await Promise.all(promises);

  const res = await fetch(
    `${endpoint}/${resource}/${db.id.toLowerCase()}/via-file`,
    {
      method: "post",
      headers: {
        "X-Dway-User-ID": user,
      },
      body,
    },
  );

  if (!res.ok) throw new Error(res.statusText);

  return await res.json();
}

async function waitForRequestFinished(url: string, user: string) {
  const res = await fetch(url, {
    headers: {
      "X-Dway-User-ID": user,
    },
  });

  if (!res.ok) throw new Error(res.statusText);

  const payload = await res.json();

  if (payload.status === "finished") return payload;

  await delay(1000);

  return waitForRequestFinished(url, user);
}
