import type { PageLoad } from './$types';

export const load: PageLoad = async ({ params, cookies }) => {
  const payload = await waitForRequestFinished(`http://localhost:3000/api/requests/${params.id}`, cookies.get('apiKey'));

  return {
    response: payload
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
