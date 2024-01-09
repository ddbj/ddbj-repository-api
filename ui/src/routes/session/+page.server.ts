import { redirect } from '@sveltejs/kit';

import { base } from '$app/paths';

import type { Actions } from './$types';

export const actions = {
  logout: ({ cookies }) => {
    cookies.delete('apiKey', { path: base });

    redirect(307, `${base}/login`);
  }
} satisfies Actions;
