import { redirect } from '@sveltejs/kit';

import { PUBLIC_API_URL } from '$env/static/public';
import { base } from '$app/paths';

import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ cookies, url }) => {
  const apiKey = cookies.get('apiKey');

  if (apiKey && apiKey !== 'null') {
    const res = await fetch(`${PUBLIC_API_URL}/me`, {
      headers: {
        Authorization: `Bearer ${apiKey}`
      }
    });

    return {
      me: await res.json()
    };
  }

  if (new URL(url).pathname !== `${base}/login`) {
    redirect(307, `${base}/login`);
  }

  return {};
};
