import type { Actions } from './$types';
import { redirect } from '@sveltejs/kit';

export const actions = {
  default: async ({request, cookies}) => {
    const res = await fetch('http://localhost:3000/api/submissions/metabobank/via-file', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${cookies.get('apiKey')}`
      },
      body: await request.formData()
    });
    const payload = await res.json();
    redirect(303, `/ui/request/${payload.request.id}`)
  }
} satisfies Actions;
