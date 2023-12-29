export async function load({cookies}) {
  const res = await fetch('http://localhost:3000/api/requests', {
    headers: {
      Authorization: `Bearer ${cookies.get('apiKey')}`
    }
  });
  return {responses: await res.json()};
}
