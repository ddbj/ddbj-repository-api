import { redirect } from '@sveltejs/kit';

import { PUBLIC_API_URL } from '$env/static/public';
import { base } from '$app/paths';

import type { Actions } from './$types';

export const actions = {
  default: async ({ request, cookies }) => {
    const formData = await request.formData();

    const res = await fetch(`${PUBLIC_API_URL}/${formData.get('resource')}/metabobank/via-file`, {
      method: 'POST',

      headers: {
        Authorization: `Bearer ${cookies.get('apiKey')}`
      },

      body: formData
    });

    const payload = await res.json();

    redirect(303, `${base}/request/${payload.request.id}`);
  }
} satisfies Actions;
