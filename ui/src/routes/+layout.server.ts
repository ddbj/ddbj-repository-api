import { redirect } from '@sveltejs/kit';

import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ cookies, url }) => {
  const apiKey = cookies.get('apiKey');

  if (apiKey && apiKey !== 'null') {
    const res = await fetch('http://localhost:3000/api/me', {
      headers: {
        Authorization: `Bearer ${apiKey}`
      }
    });

    return {
      me: await res.json()
    };
  }

  if (new URL(url).pathname !== '/ui/login') {
    redirect(307, '/ui/login');
  }

  return {};
};
