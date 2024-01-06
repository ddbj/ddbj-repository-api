import { redirect } from '@sveltejs/kit';

import type { Actions } from './$types';
import { base } from '$app/paths';

export const actions = {
  default: async ({ request, cookies }) => {
    const formData = await request.formData();

    cookies.set('apiKey', formData.get('apiKey'), { path: base });

    redirect(303, base);
  }
} satisfies Actions;
