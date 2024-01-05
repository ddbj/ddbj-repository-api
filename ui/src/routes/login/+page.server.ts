import type { Actions } from './$types';
import { redirect } from '@sveltejs/kit';

export const actions = {
  default: async ({ request, cookies }) => {
    const formData = await request.formData();
    cookies.set('apiKey', formData.get('apiKey'), { path: '/ui' });

    redirect(303, '/ui');
  }
} satisfies Actions;
