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

## Technical considerations

I'd like to state in this section some project decisions I made while implementing this API, and why I've decided to take this decisions.

- Both transactions (transfer and withdraw) are made using database level transactions, so we can be assured that money will only be deducted from accounts with all the operations required for this process are successfully performed, in case any of them fails, all the data persistence of the operation will be rolled back.
- In both transfer and withdraw transactions the involved accounts were acquired with row-level locking for updates. This prevents race conditions from causing unexpected behavior when performing critical operations in the involved bank accounts.
- All user input is validated server side to prevent malicious clients from running operations like performing a transfer with a negative amount, which would allow undesired reverse transfer requests. The same statement is valid for withdraws, as a withdraw with negative amount would be categorized as a deposit, and deposits are out of the scope of this implementation.
- Apart from [Phoenix Framework](https://www.phoenixframework.org/) standard libraries this project included a few third party libraries as project dependencies. [Credo](https://github.com/rrrene/credo) was included to provide static code analysis in order to maintain the code quality of the source files. [Basic Auth](https://github.com/paulanthonywilson/basic_auth) was included to provide a Plug for HTTP Basic Authorization on the protected routes. [BCrypt Elixir](https://github.com/riverrun/bcrypt_elixir) was used to provide hashing functionality to secure store account passwords, bcrypt_elixir is implemented on top of [comeonin](https://github.com,/riverrun/comeonin), a password hashing specification for the Elixir language. [Faker](https://github.com/elixirs/faker) was introduced in order to generate fake data for automated application tests during the test cases runtime. [Timex](https://github.com/bitwalker/timex) was used to provide support when dealing with Dates and Datetimes, it was specifically used in order to provide the backoffice report features. All credit for the libraries used in this project, including the Phoenix Framework and the Elixir language itself, should go their respectively maintainers. 
- BCrypt was chosen in place of Argon2, because in the context of this application where it would be out of scope the performing of one time authentication protocols (such as OpenID Connect), the Argon2 hashing algorithms would cause undesired use of computational resources since we have to perform passwords checks on every request made to this API, because we are using the HTTP Basic Authorization.

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
Host: forceful-royal-fulmar.gigalixirapp.com
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

### Checking your account balance / Veryfing the existence of other accounts

You can check your account balance performing a get request to /api/:account_number.

You can also lookup other accounts using this route, you just won't be able to see their balance. The balance is only returned when you are authenticated as the target account of the request.

```
GET /api/bank_accounts/11b10825-3de0-4aad-83f7-84e441000998 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Authorization: Basic MTFiMTA4MjUtM2RlMC00YWFkLTgzZjctODRlNDQxMDAwOTk4OnlvdXJfcGFzc3dvcmQ=
Connection: keep-alive
Host: forceful-royal-fulmar.gigalixirapp.com
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
Host: forceful-royal-fulmar.gigalixirapp.com
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

Note: This route requires authentication, a HTTP Basic Authorization using your account number as username and your password as password.

Note 2: you can check the application logs and see something like this:

    [info] [EMAIL SENT] TO: your_email@yourdomain.com TEXT: You've withdrawn $200.0 of your account

This is a placeholder for sending emails to the clients after they withdrew money from their accounts. You can lookup for this code at the HiringTestStone.EmailDispatcher module.

### Transfering money

You can also transfer money to another account, you will need their account number to provide in the request body tough. This is the same route for withdrawing money, the two operations are distinguished by the API using the transaction_type body parameter (which can be either: "withdraw" or "transfer".

Example:

```
POST /api/transactions HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Authorization: Basic MTFiMTA4MjUtM2RlMC00YWFkLTgzZjctODRlNDQxMDAwOTk4OnlvdXJfcGFzc3dvcmQ=
Connection: keep-alive
Content-Length: 112
Content-Type: application/json
Host: forceful-royal-fulmar.gigalixirapp.com
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
Note: This route requires authentication, a HTTP Basic Authorization using your account number as username and your password as password.

Note 2: if your check your application logs you will also see info logs about emails being sent, just like the withdraw transaction. But in this case we'll dispatch two emails, one to the source account and another to the destination account.

```
[info] [EMAIL SENT] TO: renato.ceolin@renatoceolin.com TEXT: You received a transfer of $500.0 from Your Name
[info] [EMAIL SENT] TO: your_email@yourdomain.com TEXT: You've transfered $500.0 to Renato Ceolin
```

## Admin Area

The API also provide some methods that are only supposed to be called in a backoffice context and not by final user. This routes are also authenticated using HTTP Basic Auth, but they have a fixed username and password, these parameters come from the environment variables passed during the build processes of the release (BASIC_AUTH_USENAME and BASIC_AUTH_PASSWORD). In the deployed API they were set as admin/admin, they are also the same for the test and development environments (the only diference is that in other environments than production they are hardcoded in the env configuration files (dev.exs and test.exs).

### List all accounts

For convenience and perhaps for BI data aquisition you can get a list of all registered bank accounts by performing an authenticated request to GET /api/bank_accounts as the following example:

```
GET /api/bank_accounts HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Authorization: Basic YWRtaW46YWRtaW4=
Connection: keep-alive
Host: forceful-royal-fulmar.gigalixirapp.com
User-Agent: HTTPie/0.9.8



HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 358
content-type: application/json; charset=utf-8
date: Mon, 20 Jan 2020 23:16:48 GMT
server: Cowboy
x-request-id: Feu7db1TUChwMZsAAAEh

{
    "data": [
        {
            "number": "d34d7a64-12a5-4d4b-8627-5f48f8f02dad",
            "user": {
                "email": "your_email@example.com",
                "name": "Your Name"
            }
        },
        {
            "number": "11b10825-3de0-4aad-83f7-84e441000998",
            "user": {
                "email": "your_email@yourdomain.com",
                "name": "Your Name"
            }
        },
        {
            "number": "56539e75-f9d7-462b-b585-9c3c96bf90ee",
            "user": {
                "email": "renato.ceolin@renatoceolin.com",
                "name": "Renato Ceolin"
            }
        }
    ]
}
```

### Daily, monthly and annual reports on transactions

This API also provide methods to return the total amount of transactions performed through the API in specific day, month or year.

This can be done by performing requests to the following three routes:

- GET /api/reports/:report_year
- GET /api/reports/:report_year/:report_month
- GET /api/reports/:report_year/:report_month/:report_day

Example, getting the report for all transactions performed in 2020:

```
GET /api/reports/2020 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Authorization: Basic YWRtaW46YWRtaW4=
Connection: keep-alive
Host: forceful-royal-fulmar.gigalixirapp.com
User-Agent: HTTPie/0.9.8



HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 60
content-type: application/json; charset=utf-8
date: Mon, 20 Jan 2020 23:20:11 GMT
server: Cowboy
x-request-id: Feu7pRwJuknCiroAAAGh

{
    "data": {
        "total": 700.0,
        "transfered": 500.0,
        "withdrew": 200.0
    }
}
```

Example, getting the report for all transactions performed in January of 2020.

```
GET /api/reports/2020/1 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Authorization: Basic YWRtaW46YWRtaW4=
Connection: keep-alive
Host: forceful-royal-fulmar.gigalixirapp.com
User-Agent: HTTPie/0.9.8



HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 60
content-type: application/json; charset=utf-8
date: Mon, 20 Jan 2020 23:21:17 GMT
server: Cowboy
x-request-id: Feu7tJFjX8jJ7ZAAAAHB

{
    "data": {
        "total": 700.0,
        "transfered": 500.0,
        "withdrew": 200.0
    }
}
```

Note: the results were only the same because the API is nearly launched and all transactions were performed in January, 2020.

Last example, getting all transactions performed in 01/20/2020

```
GET /api/reports/2020/1/20 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Authorization: Basic YWRtaW46YWRtaW4=
Connection: keep-alive
Host: forceful-royal-fulmar.gigalixirapp.com
User-Agent: HTTPie/0.9.8



HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 48
content-type: application/json; charset=utf-8
date: Mon, 20 Jan 2020 23:25:09 GMT
server: Cowboy
x-request-id: Feu76SJslK32wFYAAAIh

{
    "data": {
        "total": 0,
        "transfered": 0,
        "withdrew": 0
    }
}
```

Note: In the time of writing this README.md file it was 01/20/2020, and no transactions have been yet performed, this doesn't mean it's the final value for the day. You can only trust the reports to be final when asking for time ranges that are exclusively in the past, for obvious reasons, but I found it was also useful to get partial reports. So this routes accepts any valid date from any calendar year.


## Conclusion

In the end I had some fun and became very proud of the final result of this implementation. It was my very first lines of code written using the Elixir language. It was a though process having to learn some language features and the philosophy of both the language and the Phoenix Framework.

If I could came up with this solution only working on my spare hours and without having to sacrifice my social life during this 12 days, I wonder the possibilities of what I could achieve working full time with the Elixir language and in a company that keeps me interested and happy as working in challenging problems as I was during the time of this project development.
