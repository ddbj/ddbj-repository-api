import { colorize } from 'json_colorize/mod.ts';
import { colors } from 'cliffy/ansi/colors.ts';

export function requireLogin() {
  console.error(`First you need to log in; run ${colors.bold('`ddbj-repository auth login`')}.`);

  Deno.exit(1);
}

export async function ensureSuccess(res: Response) {
  if (res.ok) return;

  const type = res.headers.get('content-type');

  if (type?.includes('application/json')) {
    const payload = await res.json();

    colorize(JSON.stringify(payload, null, 2));
  } else {
    console.error(`Error: ${res.status} ${await res.text()}`);
  }

  Deno.exit(1);
}
