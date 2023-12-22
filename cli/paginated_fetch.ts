import { ensureSuccess } from './util.ts';

export default async function paginatedFetch(url: string, apiKey: string, callback: (res: Response) => Promise<void>) {
  const res = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${apiKey}`,
    },
  });

  await ensureSuccess(res);
  await callback(res);

  const links = parsePaginationLinkHeader(res.headers.get('link'));

  if (!links.next) return;

  await paginatedFetch(links.next, apiKey, callback);
}

type PaginationLinks = {
  first?: string;
  last?: string;
  prev?: string;
  next?: string;
}

function parsePaginationLinkHeader(header: string | null): PaginationLinks {
  if (!header) return {};

  return header.split(/,\s*/).reduce((acc, line) => {
    const match = /^<(.+)>; rel="(.+)"$/.exec(line);

    if (!match) return acc;

    const [url, rel] = match.slice(1);

    return Object.assign(acc, {[rel]: url});
  }, {});
}
