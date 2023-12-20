import { colors } from 'cliffy/ansi/colors.ts';

export function requireLogin() {
  console.error(`First you need to log in; run ${colors.bold('`ddbj-repository auth login`')}.`);

  Deno.exit(1);
}
