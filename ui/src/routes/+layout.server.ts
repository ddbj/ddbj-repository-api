import type { LayoutServerLoad } from './$types';
import { redirect } from '@sveltejs/kit';

export const load: LayoutServerLoad = async ({ cookies, url }) => {
  const apiKey = cookies.get('apiKey');

  if (new URL(url).pathname !== '/ui/login' && !apiKey) {
    redirect(307, '/ui/login');
  }

  if (apiKey) {
    const res = await fetch('http://localhost:3000/api/me', {
      headers: {
        Authorization: `Bearer ${cookies.get('apiKey')}`
      }
    });
    return { me: await res.json() };
  }
};
