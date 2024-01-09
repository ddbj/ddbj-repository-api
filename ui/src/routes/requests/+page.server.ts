import { PUBLIC_API_URL } from '$env/static/public';

import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ cookies }) => {
  const res = await fetch(`${PUBLIC_API_URL}/requests`, {
    headers: {
      Authorization: `Bearer ${cookies.get('apiKey')}`
    }
  });

  return {
    responses: await res.json()
  };
};
