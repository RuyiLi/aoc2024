FROM node:23-alpine
WORKDIR /prog

# install sass globally
RUN npm i -g sass

# "run" the program, this bash oneliner is just to convert newlines to escape characters
COPY . .
CMD cat <(sed 's/$/\\n/g' | tr -d '\n' | sed -r 's/^(.*)\\n$/\$input\: '"'"'\1'"'"'/') <(cat main.scss) | sass --stdin
