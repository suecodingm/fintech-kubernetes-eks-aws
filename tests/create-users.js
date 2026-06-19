import http from 'k6/http';

export const options = {
  vus: 1,
  iterations: 500
};

export default function () {

  const id = __ITER + 1;

  const payload = JSON.stringify({
    nombre: `Usuario${id}`,
    email: `usuario${id}@test.com`,
    saldo: 1000
  });

  http.post(
    'http://44.201.194.184:30081/api/usuarios',
    payload,
    {
      headers: {
        'Content-Type': 'application/json'
      }
    }
  );
}
