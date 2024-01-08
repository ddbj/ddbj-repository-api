import { redirect } from '@sveltejs/kit';

import { base } from '$app/paths';

import type { Actions } from './$types';

export const actions = {
  default: async ({ request, cookies }) => {
    const formData = await request.formData();
    const apiKey = formData.get('apiKey') as string;

    cookies.set('apiKey', apiKey, { path: base });

    redirect(303, base);
  }
} satisfies Actions;
