import { redirect } from '@sveltejs/kit';

export const actions = {
  logout: ({cookies}) => {
    cookies.delete('apiKey', {path: '/ui'});

    redirect(307, '/ui/login');
  }
}
