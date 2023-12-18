import { Command } from 'cliffy/command/mod.ts';
import { colorize } from 'https://deno.land/x/json_colorize@0.1.0/mod.ts';
import { colors } from 'cliffy/ansi/colors.ts';
import { Table } from "https://deno.land/x/cliffy@v1.0.0-rc.3/table/mod.ts";

import { Config } from './config.ts';

export default class extends Command {
  constructor({ endpoint, apiKey }: Config) {
    super();

    return this
      .description('Manage requests.')
      .action(() => this.showHelp())
      .command('list')
      .description('Get your requests.')
      .action(async () => {
        const res = await fetch(`${endpoint}/requests`, {
          headers: {
            'Authorization': `Bearer ${apiKey}`,
          },
        });

        if (!res.ok) throw new Error();

        // colorize(JSON.stringify(await res.json(), null, 2));
        const header = ['id', 'status', 'validity', 'submission'];
        const requests = Table.from([header]);
        (await res.json()).forEach(req => requests.push([req.id, req.status, req.validity, req.submission]));
        requests.render();
      })
  }
}
