# Development with Devspaces

## Devspaces Info

Manage your Devspaces https://www.devspaces.io/.

Read up-to-date documentation about cli installation and operation in https://www.devspaces.io/devspaces/help.

## Before you begin

### Configure dev Database

Update DB Connections settings in config file `config/dev.exs`:

```
config :remote_retro, RemoteRetro.Repo,
  username: "remote_retro_dev",
  password: "remote_retro_dev",
  database: "remote_retro_dev",
  hostname: "localhost",
  pool_size: 10
```

### Configure test Database

Update DB Connections settings in config file `config/test.exs`:

```
config :remote_retro, RemoteRetro.Repo,
  username: "remote_retro_test",
  password: "remote_retro_test",
  database: "remote_retro_test",
  hostname: "localhost",
  ownership_timeout: 60_000,
  pool: Ecto.Adapters.SQL.Sandbox
```

### About Google OAUTH configuration and HTTP configuration in dev

Devspaces **DOES NOT** supports OAUTH protocol. Neverteless you can use it locally in **docker compose**.

Please refer to Remote Retro main [README](../README.md) file to get instructions about how to configure Google OAuth.

Don't forget to configure your dev environment HTTP settings in `config/dev.exs` file as follows:

```
config :remote_retro, RemoteRetroWeb.Endpoint,
  http: [port: 4000,
    protocol_options: [
          max_header_name_length: 1048576,
          max_header_value_length: 1048576,
          max_headers: 10000,
          max_request_line_length: 1048576
        ]
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [npm: ["run", "watch", cd: Path.expand("../", __DIR__)]]
```

## Development with Devspaces Quick Reference

Here follows the main commands used in Devspaces cli.

|action   |Description                                                                                   |
|---------|----------------------------------------------------------------------------------------------|
|`devspaces --help`                    |Check the available command names.                               |
|`devspaces create [options]`          |Creates a DevSpace using your local DevSpaces configuration file |
|`devspaces start <devSpace>`          |Starts the DevSpace named \[devSpace\]                           |
|`devspaces bind <devSpace>`           |Syncs the DevSpace with the current directory                    |
|`devspaces info <devSpace> [options]` |Displays configuration info about the DevSpace.                  |

Use `devspaces --help` to know about updated commands.

All commands should be issued from **project directory**.

### Development flow

You should have Devspaces cli services started and logged to develop with Devspaces.

1 - Create Devspaces

```bash
cd devspaces/docker
devspaces create
cd ../../
```

2 - Start containers

```bash
devspaces start rretro
```

3 - Start containers synchronization

```bash
devspaces bind rretro
```

4 - Grab some container info

```bash
devspaces info rretro
```

Retrieve published DNS and endpoints using this command

5 - Connect to development container

```bash
devspaces exec rretro
```

6 - Update dependencies and build

```bash
sudo su - retro
cd /data
build_prep

bin/install_erlang_and_elixir_with_dependencies
mix compile
mix ecto.create && mix ecto.migrate
yarn
```

7 - Run application

**NOT** Supported in this import.

8 - Run tests

```bash
mix test
mix e2e
```

## Docker Script Manager (CLI)

Currently, we have these command available to work using local docker compose.

```bash
devspaces/docker-cli.sh <command>
```

|action    |Description                                                               |
|----------|--------------------------------------------------------------------------|
|`build`   |Builds images                                                             |
|`deploy`  |Deploy Docker compose containers                                          |
|`undeploy`|Undeploy Docker compose containers                                        |
|`start`   |Starts Docker compose containers                                          |
|`stop`    |Stops Docker compose containers                                           |
|`exec`    |Get into the container                                                    |

### Development flow

1 - Build and Run `docker-compose` locally.

```bash
devspaces/docker-cli.sh build
devspaces/docker-cli.sh deploy
devspaces/docker-cli.sh start
```

2 - Get into container

```bash
devspaces/docker-cli.sh exec
```

3 - Update dependencies and build

```bash
sudo su - retro
cd /data
build_prep

bin/install_erlang_and_elixir_with_dependencies
mix compile
mix ecto.create && mix ecto.migrate
yarn
```

4 - Run application

**Obs.:** Don't forget to configure http for test environment and get Google Oauth credentials as mentioned in __Before you begin__ section above.

4.1 - Configure your environment variables
```
export REMOTE_RETRO_GOOGLE_OAUTH_CLIENT_ID="<Client Id>"
export REMOTE_RETRO_GOOGLE_OAUTH_CLIENT_SECRET="<Client secret>"
export REMOTE_RETRO_GOOGLE_OAUTH_REDIRECT_URI="http://localhost:4000/auth/google/callback"
```

4.2 - Run Application

```
mix
```

Access application URLs:

* Application:
    * http://localhost:4000

5 - Run tests

```bash
mix test
mix e2e
```
