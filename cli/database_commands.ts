import { basename, resolve, toFileUrl } from 'std/path/mod.ts';
import { delay } from 'std/async/mod.ts';

import { Command } from 'cliffy/command/mod.ts';
import { colorize } from 'https://deno.land/x/json_colorize@0.1.0/mod.ts';
import { colors } from 'cliffy/ansi/colors.ts';

import dbs from './db.json' with { type: 'json' };
import { Config } from './config.ts';

class DatabaseCommand extends Command<{ file: Record<string, string> }> {
  constructor({ endpoint, apiKey }: Config, resource: string, descriptionFn: (db: Db) => string) {
    super();

    // deno-lint-ignore no-this-alias
    let cmd = this;

    for (const db of dbs) {
      cmd = cmd
        .command(db.id.toLowerCase())
        .description(descriptionFn(db));

      for (const { id, ext, optional, multiple } of db.objects) {
        cmd = cmd.option(
          `--file.${id.toLowerCase()} <path:file>`,
          `Path to ${id} file (${ext})`,
          { required: optional !== true, collect: multiple === true },
        );
      }

      cmd = cmd.action(async ({ file }) => {
        if (!apiKey) {
          console.log(`First you need to log in; run ${colors.bold('`ddbj-repository auth login`')}.`);

          return;
        }

        const { request } = await createRequest(endpoint, apiKey, resource, db, file);
        const payload = await waitForRequestFinished(request.url, apiKey);

        colorize(JSON.stringify(payload, null, 2));
      });
    }

    return cmd.reset();
  }
}

export class ValidateCommand extends DatabaseCommand {
  constructor(config: Config) {
    super(config, 'validations', (db) => `Validate ${db.id} files.`);

    return this
      .description('Validate the specified files.')
      .action(() => this.showHelp());
  }
}

export class SubmitCommand extends DatabaseCommand {
  constructor(config: Config) {
    super(config, 'submissions', (db) => `Submit files to ${db.id}.`);

    return this
      .description('Submit files to the specified database.')
      .action(() => this.showHelp());
  }
}

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

async function createRequest(endpoint: string, apiKey: string, resource: string, db: Db, files: Record<string, string | string[]>) {
  const body = new FormData();

  const promises = Object.entries(files).flatMap(([id, paths]) => {
    return [paths].flat().map((path) => [id, path]);
  }).map(async ([id, path]) => {
    const obj = db.objects.find((obj) => obj.id.toLowerCase() === id);
    const key = obj?.multiple ? `${obj.id}[]` : obj!.id;
    const file = await fetch(toFileUrl(resolve(path)));

    body.append(`${key}[file]`, await file.blob(), basename(path));
  });

  await Promise.all(promises);

  const res = await fetch(
    `${endpoint}/${resource}/${db.id.toLowerCase()}/via-file`,
    {
      method: 'post',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
      },
      body,
    },
  );

  if (!res.ok) throw new Error(res.statusText);

  return await res.json();
}

async function waitForRequestFinished(url: string, apiKey: string) {
  const res = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${apiKey}`,
    },
  });

  if (!res.ok) throw new Error(res.statusText);

  const payload = await res.json();

  if (payload.status === 'finished') return payload;

  await delay(1000);

  return waitForRequestFinished(url, apiKey);
}
