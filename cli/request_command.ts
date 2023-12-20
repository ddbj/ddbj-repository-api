import { Command } from 'cliffy/command/mod.ts';
import { Table } from 'cliffy/table/mod.ts';
import { colorize } from 'json_colorize/mod.ts';
import { colors } from 'cliffy/ansi/colors.ts';

import { Config } from './config.ts';
import { requireLogin } from './util.ts';

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
      });
  }
}

type Request = {
  id: number;
  created_at: string;
  status: string;
  validity: string;

  submission?: {
    id: string;
  };
};

async function listRequests(endpoint: string, apiKey: string) {
  const res = await fetch(`${endpoint}/requests`, {
    headers: {
      'Authorization': `Bearer ${apiKey}`,
    },
  });

  if (!res.ok) throw new Error();

  const requests: Request[] = await res.json();

  const headers = ['ID', 'Created', 'Status', 'Validity', 'Submission'];
  const table = Table.from([headers.map(colors.bold.yellow)]);

  table.push(headers.map((header) => colors.bold.yellow('-'.repeat(header.length))));

  requests.forEach((req) => {
    table.push([
      colors.bold(req.id.toString()),
      req.created_at,
      req.status,
      req.validity,
      req.submission?.id || '',
    ]);
  });

  table.render();
}

async function showRequest(endpoint: string, apiKey: string, id: number) {
  const res = await fetch(`${endpoint}/requests/${id}`, {
    headers: {
      'Authorization': `Bearer ${apiKey}`,
    },
  });

  if (!res.ok) throw new Error();

  const request = await res.json();

  colorize(JSON.stringify(request, null, 2));
}
