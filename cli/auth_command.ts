import { delay } from 'std/async/mod.ts';

import * as oauth from 'https://deno.land/x/doauth@v1.2.2/src/index.ts';
import { Command } from 'cliffy/command/mod.ts';
import { colors } from 'cliffy/ansi/colors.ts';
import { open } from 'https://deno.land/x/open@v0.0.6/index.ts';

import { Config, writeConfig } from './config.ts';

export default class extends Command {
  constructor({ issuer, endpoint, apiKey }: Config) {
    super();

    return this
      .action(() => this.showHelp())
      .command('whoami')
      .action(async () => {
        if (apiKey) {
          const uid = await fetchUid(endpoint, apiKey);

          console.log(`Logged in as ${colors.bold(uid)}.`);
        } else {
          console.log('Not logged in.');
        }
      })
      .command('login')
      .action(async () => {
        await openAuthorizationURL(issuer, endpoint);
      })
      .command('logout')
      .action(async () => {
        await writeConfig({ apiKey: undefined });
      })
      .reset();
  }
}

const port = 37376;
const redirectUri = `http://localhost:${port}`;

async function openAuthorizationURL(_issuer: string, endpoint: string) {
  const issuer = new URL(_issuer);

  const res = await oauth.discoveryRequest(issuer);
  const as = await oauth.processDiscoveryResponse(issuer, res);

  const client: oauth.Client = {
    client_id: 'ddbj-repository',
    token_endpoint_auth_method: 'none',
  };

  const state = oauth.generateRandomState();
  const nonce = oauth.generateRandomNonce();
  const codeVerifier = oauth.generateRandomCodeVerifier();
  const codeChallenge = await oauth.calculatePKCECodeChallenge(codeVerifier);

  const server = Deno.serve(
    {
      port,
      onListen() {
        // do nothing. suppress noisy output
      },
    },
    callbackHandler(as, client, state, nonce, codeVerifier, endpoint, async () => {
      await delay(1000);
      await server.shutdown();
    }),
  );

  const authorizationUrl = new URL(as.authorization_endpoint!);

  authorizationUrl.searchParams.set('client_id', client.client_id);
  authorizationUrl.searchParams.set('redirect_uri', redirectUri);
  authorizationUrl.searchParams.set('response_type', 'code');
  authorizationUrl.searchParams.set('scope', 'openid');
  authorizationUrl.searchParams.set('state', state);
  authorizationUrl.searchParams.set('nonce', nonce);
  authorizationUrl.searchParams.set('code_challenge', codeChallenge);
  authorizationUrl.searchParams.set('code_challenge_method', 'S256');

  await open(authorizationUrl.href);
}

function callbackHandler(as: oauth.AuthorizationServer, client: oauth.Client, state: string, nonce: string, codeVerifier: string, endpoint: string, done: () => void) {
  return async (req: Request) => {
    try {
      const url = new URL(req.url);
      const params = oauth.validateAuthResponse(as, client, url, state);

      if (oauth.isOAuth2Error(params)) throw params;

      const res = await oauth.authorizationCodeGrantRequest(as, client, params, redirectUri, codeVerifier);
      const result = await oauth.processAuthorizationCodeOpenIDResponse(as, client, res, nonce);

      if (oauth.isOAuth2Error(result)) throw result;

      const apiKey = await obtainAPIKey(endpoint, result.id_token, nonce);

      writeConfig({ apiKey });

      const uid = await fetchUid(endpoint, apiKey);

      console.log(`Logged in as ${colors.bold(uid)}.`);

      return new Response(`Logged in as ${uid}.`, { status: 200 });
    } finally {
      done();
    }
  };
}

async function obtainAPIKey(endpoint: string, idToken: string, nonce: string) {
  const res = await fetch(`${endpoint}/auth/login_by_id_token`, {
    method: 'post',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      id_token: idToken,
      nonce,
    }),
  });

  if (!res.ok) throw res;

  const { api_key } = await res.json();

  return api_key;
}

async function fetchUid(endpoint: string, apiKey: string) {
  const res = await fetch(`${endpoint}/me`, {
    headers: {
      Authorization: `Bearer ${apiKey}`,
    },
  });

  if (!res.ok) throw res;

  const { uid } = await res.json();

  return uid;
}
