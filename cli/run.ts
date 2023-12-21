import { Command, CompletionsCommand } from 'cliffy/command/mod.ts';

import AuthCommand from './auth_command.ts';
import RequestCommand from './request_command.ts';
import SubmissionCommand from './submission_command.ts';
import { SubmitCommand, ValidateCommand } from './database_commands.ts';
import { defaultConfig, readConfig } from './config.ts';

const config = Object.assign({}, defaultConfig, await readConfig());

const main: Command = new Command()
  .name('ddbj-repository')
  .version('0.1.0')
  .description('Command-line client for DDBJ Repository API')
  .action(() => main.showHelp())
  .command('auth', new AuthCommand(config))
  .command('validate', new ValidateCommand(config))
  .command('submit', new SubmitCommand(config))
  .command('request', new RequestCommand(config))
  .command('submission', new SubmissionCommand(config))
  .command('completion', new CompletionsCommand())
  .reset();

await main.parse(Deno.args);
