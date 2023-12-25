import { dirname, join } from 'std/path/mod.ts';

import { expandHome } from 'https://deno.land/x/expandhome@v0.0.5/mod.ts';

export type Config = {
  endpoint: string;
  issuer: string;
  apiKey?: string;
};

export const defaultConfig = {
  endpoint: 'https://repository-dev.ddbj.nig.ac.jp/api',
  issuer: 'https://accounts-staging.ddbj.nig.ac.jp/auth/realms/master',
};

export async function readConfig() {
  try {
    return JSON.parse(await Deno.readTextFile(configFilePath));
  } catch (err) {
    if (err.name === 'NotFound') {
      return {};
    } else {
      throw err;
    }
  }
}

export async function writeConfig(config: object) {
  const newConfig = Object.assign({}, await readConfig(), config);

  await Deno.mkdir(dirname(configFilePath), { recursive: true });
  await Deno.writeTextFile(configFilePath, JSON.stringify(newConfig, null, '  '));
}

const configHome = Deno.env.get('XDG_CONFIG_HOME') || expandHome('~/.config');
const configFilePath = join(configHome, 'ddbj-repository', 'config.json');
