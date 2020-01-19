# Stone Backend Challenge

Hi! I'm [Renato Ceolin](https://github.com/ceolinrenato) and this repository contains my implementation for the backend technical challenge proposed by Stone (a fintech company from Brazil). You can find the challenge instructions [here](https://gist.github.com/thuli/e021378b27ff471795e37ba5a5b73539).

**pt-BR**: Olá! Sou [Renato Ceolin](https://github.com/ceolinrenato) e nesse repositório você encontra a minha implementação do desáfio técnico para o cargo de Desenvolvedor Backend proposto pela Stone (uma fintech do Brasil). Você pode encontrar as instruções do desafio [aqui](https://gist.github.com/thuli/e021378b27ff471795e37ba5a5b73539).

## Setup

This project comes with a docker-compose.yml and a Dockerfile ready, in order to help you setup a development environment very quickly.

First follow the instructions to install Docker and Docker Compose on your operational system, you can find official documentation on the [Docker Website](https://docs.docker.com).

Once you have Docker and Docker Compose up and running you can start the development server with a single command:

    docker-compose up

This command also starts PostgreSQL and PgAdmin.

If you are running the project for the very first time you will need to setup the project database and run the migrations, this project comes with a simple shell script to help you run commands in the application container, to do so run:

    ./mix ecto.create
This will create the database for you.
Next run:

    ./mix ecto.migrate
This will run the database migrations and now your app is ready to go.

If you are in a Linux environment and you got an error saying you don't have permissions to run the above commands you first gotta add execution permission to the mix file:

    chmod +x mix

## Deployment

This project was deployed using [Gigalixir](https://www.gigalixir.com/) and Elixir Releases. You can find a deployed version of this project at: [https://forceful-royal-fulmar.gigalixirapp.com](https://forceful-royal-fulmar.gigalixirapp.com).

In order to run your own deployment of this project you can follow the official instructions of the Pheonix framework and deploy it in any platform or you can signup for a Gigalixir account yourself.

To generate a release you need to setup a few environment variables:
* DATABASE_URL
* SECRET_KEY_BASE
* BASIC_AUTH_USERNAME
* BASIC_AUTH_PASSWORD

The later two ones (BASIC_AUTH_****) are the username and password you need to access the Admin Area API: in the public deployment the credentials were setup as (admin/admin).
## Using the API

For this example we are going to use the base URI of the public deployment: ***https://forceful-royal-fulmar.gigalixirapp.com***.

### Creating an Account

The first operation you will most likely do is the create a Bank Account. This can be done in a post request without any authorization headers.

```
POST /api/bank_accounts HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 98
Content-Type: application/json
Host: localhost:4000
User-Agent: HTTPie/0.9.8

{
    "password": "your_password",
    "user": {
        "email": "your_email@yourdomain.com",
        "name": "Your Name"
    }
}

HTTP/1.1 201 Created
cache-control: max-age=0, private, must-revalidate
content-length: 122
content-type: application/json; charset=utf-8
date: Sun, 19 Jan 2020 20:12:56 GMT
server: Cowboy
x-request-id: Feti2GT9cBYsxewAAABE

{
    "data": {
        "number": "11b10825-3de0-4aad-83f7-84e441000998",
        "user": {
            "email": "your_email@yourdomain.com",
            "name": "Your Name"
        }
    }
}
```
Above you can see an example request and response to create a account. Write down your account number and your password, you are gonna need them to perform withdraw and transfer transactions.

Note: I've used an UUID as an abstraction to a Bank Account number, so I didn't have to implement any business logic to generate account numbers, since it was out of scope of this tech challenge.

### Checking your account balance

You can check your account balance performing a get request to /api/:account_number

```
GET /api/bank_accounts/11b10825-3de0-4aad-83f7-84e441000998 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Authorization: Basic MTFiMTA4MjUtM2RlMC00YWFkLTgzZjctODRlNDQxMDAwOTk4OnlvdXJfcGFzc3dvcmQ=
Connection: keep-alive
Host: localhost:4000
User-Agent: HTTPie/0.9.8



HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 138
content-type: application/json; charset=utf-8
date: Sun, 19 Jan 2020 20:17:42 GMT
server: Cowboy
x-request-id: FetjGykEgEFqcckAAACE

{
    "data": {
        "balance": 1000.0,
        "number": "11b10825-3de0-4aad-83f7-84e441000998",
        "user": {
            "email": "your_email@yourdomain.com",
            "name": "Your Name"
        }
    }
}
```
Note: This route requires authentication, a HTTP Basic Authorization using your account number as username and your password as password.

Note 2: You can lookup other accounts using this route, you just won't be able to see their balance.

### Withdrawing money

You can withdraw money performing a POST request to /api/transactions

Example:

```
POST /api/transactions HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Authorization: Basic MTFiMTA4MjUtM2RlMC00YWFkLTgzZjctODRlNDQxMDAwOTk4OnlvdXJfcGFzc3dvcmQ=
Connection: keep-alive
Content-Length: 49
Content-Type: application/json
Host: localhost:4000
User-Agent: HTTPie/0.9.8

{
    "amount": "200",
    "transaction_type": "withdraw"
}

HTTP/1.1 201 Created
cache-control: max-age=0, private, must-revalidate
content-length: 137
content-type: application/json; charset=utf-8
date: Sun, 19 Jan 2020 20:22:17 GMT
server: Cowboy
x-request-id: FetjW1Y_gdiHsykAAACk

{
    "data": {
        "amount": 200.0,
        "remaining_balance": 800.0,
        "source_account": "11b10825-3de0-4aad-83f7-84e441000998",
        "transaction_type": "withdraw"
    }
}
```

In the end your remaining account balance is returned as well

Note: you can check the application logs and see something like this:

    [info] [EMAIL SENT] TO: your_email@yourdomain.com TEXT: You've withdrawn $200.0 of your account

This is a placeholder for sending emails to the clients after they withdrew money from their accounts. You can lookup for this code at the HiringTestStone.EmailDispatcher module.

### Transfer money

You can also transfer money to another account, you will need their account number to provide in the request body tough.

Example:

```
POST /api/transactions HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Authorization: Basic MTFiMTA4MjUtM2RlMC00YWFkLTgzZjctODRlNDQxMDAwOTk4OnlvdXJfcGFzc3dvcmQ=
Connection: keep-alive
Content-Length: 112
Content-Type: application/json
Host: localhost:4000
User-Agent: HTTPie/0.9.8

{
    "amount": "500",
    "destination_account": "56539e75-f9d7-462b-b585-9c3c96bf90ee",
    "transaction_type": "transfer"
}

HTTP/1.1 201 Created
cache-control: max-age=0, private, must-revalidate
content-length: 198
content-type: application/json; charset=utf-8
date: Sun, 19 Jan 2020 20:26:21 GMT
server: Cowboy
x-request-id: FetjlCkbTKzluDMAAADk

{
    "data": {
        "amount": 500.0,
        "destination_account": "56539e75-f9d7-462b-b585-9c3c96bf90ee",
        "remaining_balance": 300.0,
        "source_account": "11b10825-3de0-4aad-83f7-84e441000998",
        "transaction_type": "transfer"
    }
}
```

Note: if your check your application logs you will also see info logs about emails being sent, just like the withdraw transaction. But in this case we'll dispatch two emails, one to the source account and another to the destination account.

```
[info] [EMAIL SENT] TO: renato.ceolin@renatoceolin.com TEXT: You received a transfer of $500.0 from Your Name
[info] [EMAIL SENT] TO: your_email@yourdomain.com TEXT: You've transfered $500.0 to Renato Ceolin
```
