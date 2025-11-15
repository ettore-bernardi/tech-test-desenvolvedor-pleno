## Uso rápido

- Suba containers com `docker-compose up --build`
- Acesse `http://localhost:3000/uploads/new` e envie um .eml
- O arquivo será salvo e um job Sidekiq disparado.
- Verifique logs em `/logs` e customers em `/customers`.
