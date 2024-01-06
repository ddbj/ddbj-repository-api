import { redirect } from '@sveltejs/kit';

import type { LayoutServerLoad } from './$types';
import { base } from '$app/paths';

export const load: LayoutServerLoad = () => {
  redirect(307, `${base}/submit`);
};
