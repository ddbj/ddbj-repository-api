import { redirect } from '@sveltejs/kit';

import { base } from '$app/paths';

export const actions = {
  logout: ({ cookies }) => {
    cookies.delete('apiKey', { path: base });

    redirect(307, `${base}/login`);
  }
};
