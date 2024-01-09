import { redirect } from '@sveltejs/kit';

import { PUBLIC_API_URL } from '$env/static/public';

import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params, cookies }) => {
  const url = `${PUBLIC_API_URL}/requests/${params.id}`;
  const apiKey = cookies.get('apiKey')!;
  const payload = await waitForRequestFinished(url, apiKey);

  return {
    request: payload
  };
};

async function waitForRequestFinished(url: string, apiKey: string) {
  const res = await fetch(url, {
    headers: {
      Authorization: `Bearer ${apiKey}`
    }
  });

  const payload = await res.json();

  if (payload.status === 'finished' || payload.status === 'canceled') return payload;

  await new Promise((resolve) => setTimeout(resolve, 1000));

  return waitForRequestFinished(url, apiKey);
}

export const actions = {
  downloadFile: async ({ request, cookies }) => {
    const formData = await request.formData();
    const url = formData.get('url') as string;

    const res = await fetch(url, {
      headers: {
        Authorization: `Bearer ${cookies.get('apiKey')}`
      }
    });

    redirect(303, res.url);
  }
} satisfies Actions;
