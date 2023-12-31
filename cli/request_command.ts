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
      .description('Manage requests.')
      .action(() => this.showHelp())
      .command('list')
      .description('Get your requests.')
      .action(() => {
        if (!apiKey) requireLogin();

        listRequests(endpoint, apiKey!);
      })
      .command('show')
      .description('Get the request.')
      .arguments('<id:number>')
      .action((_opts, id) => {
        if (!apiKey) requireLogin();

        showRequest(endpoint, apiKey!, id);
      })
      .command('get-file')
      .description('Get the content of submission file.')
      .arguments('<id:string> <path:string>')
      .action((_opts, id, path) => {
        if (!apiKey) requireLogin();

        getFile(endpoint, apiKey!, id, path);
      })
      .command('cancel')
      .description('Cancel the request.')
      .arguments('<id:number>')
      .action((_opts, id) => {
        if (!apiKey) requireLogin();

        cancelRequest(endpoint, apiKey!, id);
      });
  }
}

type Request = {
  id: number;
  created_at: string;
  purpose: string;
  db: string;
  status: string;
  validity: string;

  submission?: {
    id: string;
  };
};

async function listRequests(endpoint: string, apiKey: string) {
  const headers = ['ID', 'Created', 'Purpose', 'DB', 'Status', 'Validity', 'Submission'];
  const table = Table.from([headers.map(colors.bold.yellow)]);

  table.push(headers.map((header) => colors.bold.yellow('-'.repeat(header.length))));

  await paginatedFetch(`${endpoint}/requests`, apiKey, async (res) => {
    await ensureSuccess(res);

    const requests: Request[] = await res.json();

    requests.forEach((req) => {
      table.push([
        colors.bold(req.id.toString()),
        req.created_at,
        req.purpose,
        req.db,
        req.status,
        req.validity,
        req.submission?.id || '',
      ]);
    });
  });

  table.render();
}

async function showRequest(endpoint: string, apiKey: string, id: number) {
  const res = await fetch(`${endpoint}/requests/${id}`, {
    headers: {
      'Authorization': `Bearer ${apiKey}`,
    },
  });

  await ensureSuccess(res);

  const payload = await res.json();

  colorize(JSON.stringify(payload, null, 2));
}

async function getFile(endpoint: string, apiKey: string, id: string, path: string) {
  const res = await fetch(`${endpoint}/requests/${id}/files/${path}`, {
    headers: {
      'Authorization': `Bearer ${apiKey}`,
    },
  });

  await ensureSuccess(res);

  console.log(await res.text());
}

async function cancelRequest(endpoint: string, apiKey: string, id: number) {
  const res = await fetch(`${endpoint}/requests/${id}`, {
    method: 'DELETE',

    headers: {
      'Authorization': `Bearer ${apiKey}`,
    },
  });

  await ensureSuccess(res);

  const payload = await res.json();

  colorize(JSON.stringify(payload, null, 2));
}
