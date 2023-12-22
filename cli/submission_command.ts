import { Command } from 'cliffy/command/mod.ts';
import { Table } from 'cliffy/table/mod.ts';
import { colorize } from 'json_colorize/mod.ts';
import { colors } from 'cliffy/ansi/colors.ts';

import paginatedFetch from './paginated_fetch.ts';
import { Config } from './config.ts';
import { ensureSuccess, requireLogin } from './util.ts';

export default class extends Command {
  constructor({ endpoint, apiKey }: Config) {
    super();

    return this
      .description('Manage submissions.')
      .action(() => this.showHelp())
      .command('list')
      .description('Get your submissions.')
      .action(() => {
        if (!apiKey) requireLogin();

        listSubmissions(endpoint, apiKey!);
      })
      .command('show')
      .description('Get the submission.')
      .arguments('<id:string>')
      .action((_opts, id) => {
        if (!apiKey) requireLogin();

        showSubmission(endpoint, apiKey!, id);
      })
      .command('get-file')
      .description('Get the content of submission file.')
      .arguments('<id:string> <path:string>')
      .action((_opts, id, path) => {
        if (!apiKey) requireLogin();

        getFile(endpoint, apiKey!, id, path);
      });
  }
}

type Submission = {
  id: string;
  created_at: string;
  db: string;

  objects: Array<{
    id: string;

    files: Array<{
      path: string;
    }>;
  }>;
};

async function listSubmissions(endpoint: string, apiKey: string) {
  const headers = ['ID', 'Created', 'DB'];
  const table = Table.from([headers.map(colors.bold.yellow)]);

  table.push(headers.map((header) => colors.bold.yellow('-'.repeat(header.length))));

  await paginatedFetch(`${endpoint}/submissions`, apiKey, async (res) => {
    await ensureSuccess(res);

    const submissions: Submission[] = await res.json();

    submissions.forEach((submission) => {
      table.push([
        colors.bold(submission.id),
        submission.created_at,
        submission.db,
      ]);
    });
  });

  table.render();
}

async function showSubmission(endpoint: string, apiKey: string, id: string) {
  const res = await fetch(`${endpoint}/submissions/${id}`, {
    headers: {
      'Authorization': `Bearer ${apiKey}`,
    },
  });

  await ensureSuccess(res);

  const payload = await res.json();

  colorize(JSON.stringify(payload, null, 2));
}

async function getFile(endpoint: string, apiKey: string, id: string, path: string) {
  const res = await fetch(`${endpoint}/submissions/${id}/files/${path}`, {
    headers: {
      'Authorization': `Bearer ${apiKey}`,
    },
  });

  await ensureSuccess(res);

  console.log(await res.text());
}
