import { delay } from "std/async/mod.ts";

import * as oauth from "https://deno.land/x/doauth@v1.2.2/src/index.ts";
import { Command } from "cliffy/command/mod.ts";
import { colors } from "cliffy/ansi/colors.ts";
import { open } from "https://deno.land/x/open@v0.0.6/index.ts";

import { Config, writeConfig } from "./config.ts";

export default class extends Command {
  constructor(config: Config) {
    super();

    return this
      .action(() => this.showHelp())
      .command("whoami")
      .action(() => {
        if (config.auth) {
          console.log(`Logged in as ${colors.bold(config.auth.uid)}.`);
        } else {
          console.log("Not logged in.");
        }
      })
      .command("login")
      .action(async () => {
        await openAuthorizationURL(config);
      })
      .command("logout")
      .action(async () => {
        await writeConfig({ auth: undefined });
      })
      .reset();
  }
}

const port = 37376;
const redirectUri = `http://localhost:${port}`;

async function openAuthorizationURL(config: Config) {
  const issuer = new URL(config.issuer);

  const res = await oauth.discoveryRequest(issuer);
  const as = await oauth.processDiscoveryResponse(issuer, res);

  const client: oauth.Client = {
    client_id: "ddbj-repository",
    token_endpoint_auth_method: "none",
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
    callbackHandler(
      as,
      client,
      state,
      nonce,
      codeVerifier,
      config,
      async () => {
        await delay(1000);
        await server.shutdown();
      },
    ),
  );

  const authorizationUrl = new URL(as.authorization_endpoint!);

  authorizationUrl.searchParams.set("client_id", client.client_id);
  authorizationUrl.searchParams.set("redirect_uri", redirectUri);
  authorizationUrl.searchParams.set("response_type", "code");
  authorizationUrl.searchParams.set("scope", "openid");
  authorizationUrl.searchParams.set("state", state);
  authorizationUrl.searchParams.set("nonce", nonce);
  authorizationUrl.searchParams.set("code_challenge", codeChallenge);
  authorizationUrl.searchParams.set("code_challenge_method", "S256");

  await open(authorizationUrl.href);
}

function callbackHandler(
  as: oauth.AuthorizationServer,
  client: oauth.Client,
  state: string,
  nonce: string,
  codeVerifier: string,
  config: Config,
  done: () => void,
) {
  return async (req: Request) => {
    try {
      const url = new URL(req.url);

      const params = oauth.validateAuthResponse(
        as,
        client,
        url,
        state,
      );

      if (oauth.isOAuth2Error(params)) {
        throw params;
      }

      const res = await oauth.authorizationCodeGrantRequest(
        as,
        client,
        params,
        redirectUri,
        codeVerifier,
      );

      const result = await oauth.processAuthorizationCodeOpenIDResponse(
        as,
        client,
        res,
        nonce,
      );

      if (oauth.isOAuth2Error(result)) {
        throw result;
      }

      const auth = await obtainAuthResponse(
        config.endpoint,
        result.id_token,
        nonce,
      );

      writeConfig({ auth });

      console.log(`Logged in as ${colors.bold(auth.uid)}.`);

      return new Response(`Logged in as ${auth.uid}.`, { status: 200 });
    } finally {
      done();
    }
  };
}

async function obtainAuthResponse(
  endpoint: string,
  idToken: string,
  nonce: string,
) {
  const res = await fetch(`${endpoint}/auth/login_by_id_token`, {
    method: "post",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      id_token: idToken,
      nonce,
    }),
  });

  if (!res.ok) {
    throw res;
  }

  return await res.json();
}
