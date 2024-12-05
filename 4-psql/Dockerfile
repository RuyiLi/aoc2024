FROM postgres:17.2-alpine
WORKDIR /prog

ENV POSTGRES_HOST_AUTH_METHOD=trust

# If we use `-f main.sql`, then we'll have no stdin since psql originally takes sql as stdin.
# Thus, we pass the contents of the program to `-c` instead, which doesn't compete for stdin.
COPY . .
CMD ["bash", "-c", "docker-entrypoint.sh postgres >/dev/null 2>&1 & sleep 5 && pg_isready && psql -q -U postgres -d postgres -c \"$(cat main.sql)\""]
