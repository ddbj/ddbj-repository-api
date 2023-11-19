import { dirname, join } from 'std/path/mod.ts';

import { expandHome } from 'https://deno.land/x/expandhome@v0.0.5/mod.ts';

export type Config = {
  endpoint: string;
  issuer: string;
  apiToken?: string;
};

export const defaultConfig = {
  endpoint: 'http://localhost:3000/api',
  issuer: 'http://keycloak.localhost:8080/auth/realms/master',
};

export async function readConfig() {
  try {
    const { default: _default } = await import(configFilePath, { with: { type: 'json' } });

    return _default;
  } catch (err) {
    if (err instanceof TypeError) {
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
