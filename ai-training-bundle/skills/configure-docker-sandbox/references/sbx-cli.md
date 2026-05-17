
## sbx --help

Docker Sandboxes creates isolated sandbox environments for AI agents, powered by Docker.
Run without a command to launch interactive mode, or pass a command for CLI usage.

```
Usage:
  sbx
  sbx [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  cp          Copy files or directories between a sandbox and the host
  create      Create a sandbox for an agent
  diagnose    Diagnose common issues with your sbx installation
  exec        Execute a command inside a sandbox
  help        Help about any command
  login       Sign in to Docker
  logout      Sign out of Docker
  ls          List sandboxes
  policy      Manage sandbox policies
  ports       Manage sandbox port publishing
  reset       Reset all sandboxes and clean up state
  rm          Remove one or more sandboxes
  run         Run an agent in a sandbox
  secret      Manage stored secrets
  stop        Stop one or more sandboxes without removing them
  template    Manage sandbox templates
  version     Show Docker Sandboxes version information

Flags:
  -D, --debug   Enable debug logging
  -h, --help    help for sbx

Use "sbx [command] --help" for more information about a command.
```


## sbx cp

```
Either SRC or DST must be a sandbox path, written as SANDBOX:PATH.
The other must be a local path. Copying between two sandboxes is not supported.

When copying a directory, the directory itself is placed at the destination.
If the destination path does not exist it is created; if it already exists
as a directory, the source is placed inside it.

Usage:
  sbx cp [flags] SRC DST

Examples:
  # Copy a file from host to sandbox
  sbx cp ./config.json my-sandbox:/home/user/

  # Copy a file from sandbox to host
  sbx cp my-sandbox:/home/user/output.log ./

  # Copy a directory
  sbx cp ./src/ my-sandbox:/home/user/src

Flags:
  -L, --follow-link   Follow symbolic links in the source path when copying from host to sandbox
  -h, --help          help for cp

Global Flags:
  -D, --debug   Enable debug logging
```


## sbx create

```
Create a sandbox with access to a host workspace for an agent.

Use "sbx run SANDBOX" to attach to the agent after creation.

Usage:
  sbx create [flags] AGENT PATH [PATH...]
  sbx create [command]

Examples:
  # Create a sandbox for Claude in the current directory
  sbx create claude .

  # Create a sandbox with a custom name
  sbx create --name my-project claude /path/to/project

  # Create with additional read-only workspaces
  sbx create claude . /path/to/docs:ro

  # Create with a Git worktree for isolated changes
  sbx create --branch=feature/login claude .

Available Commands:
  claude       Create a sandbox for claude
  codex        Create a sandbox for codex
  copilot      Create a sandbox for copilot
  cursor       Create a sandbox for cursor
  docker-agent Create a sandbox for docker-agent
  droid        Create a sandbox for droid
  gemini       Create a sandbox for gemini
  kiro         Create a sandbox for kiro
  opencode     Create a sandbox for opencode
  shell        Create a sandbox for shell

Flags:
      --branch string     Create a Git worktree on the given branch
      --cpus int          Number of CPUs to allocate to the sandbox (0 = auto: N-1 host CPUs, min 1)
  -h, --help              help for create
      --kit strings       Kit reference (directory, ZIP, or OCI). Can be specified multiple times
  -m, --memory string     Memory limit in binary units (e.g., 1024m, 8g). Default: 50% of host memory, max 32 GiB
      --name string       Name for the sandbox (default: <agent>-<workdir>, letters, numbers, hyphens, periods, plus signs and minus signs only)
  -q, --quiet             Suppress verbose output
  -t, --template string   Container image to use for the sandbox (default: agent-specific image)

Global Flags:
  -D, --debug   Enable debug logging

Use "sbx create [command] --help" for more information about a command.
```


## sbx diagnose

```
Diagnose common issues with your sbx installation

Usage:
  sbx diagnose

Flags:
  -h, --help            help for diagnose
  -o, --output string   Output format: "json" or "github-issue"
      --upload          Upload diagnostics to Docker support

Global Flags:
  -D, --debug   Enable debug logging

```

## sbx exec

```
Execute a command in a sandbox. If the sandbox is stopped, it is started first.

Flags match the behavior of "docker exec".

Usage:
  sbx exec [flags] SANDBOX COMMAND [ARG...]

Examples:
  # Open a shell inside a sandbox
  sbx exec -it my-sandbox bash

  # Run a command in the background
  sbx exec -d my-sandbox npm start

  # Run as root
  sbx exec -u root my-sandbox apt-get update

Flags:
  -d, --detach                 Detached mode: run command in the background
      --detach-keys string     Override the key sequence for detaching a container
  -e, --env stringArray        Set environment variables
      --env-file stringArray   Read in a file of environment variables
  -h, --help                   help for exec
  -i, --interactive            Keep STDIN open even if not attached
      --privileged             Give extended privileges to the command
  -t, --tty                    Allocate a pseudo-TTY
  -u, --user string            Username or UID (format: <name|uid>[:<group|gid>])
  -w, --workdir string         Working directory inside the container

Global Flags:
  -D, --debug   Enable debug logging

```



## sbx login


```
Sign in to Docker

Usage:
  sbx login [flags]

Flags:
  -h, --help   help for login

Global Flags:
  -D, --debug   Enable debug logging

```

## sbx ls

```
List all sandboxes with their agent, status, published ports, and workspace.

Usage:
  sbx ls [flags]

Aliases:
  ls, list

Flags:
  -h, --help    help for ls
      --json    Output in JSON format
  -q, --quiet   Only display sandbox names

Global Flags:
  -D, --debug   Enable debug logging

```

## sbx policy

```
Manage persistent access policies for sandboxes.

Policies are rules stored locally that control what sandboxes can access.
They apply globally across all sandboxes and persist across restarts.
Use subcommands to allow, deny, list, or remove policies.

Usage:
  sbx policy COMMAND
  sbx policy [command]

Available Commands:
  allow       Add an allow policy for sandboxes
  deny        Add a deny policy for sandboxes
  log         Show sandbox policy logs
  ls          List sandbox policies
  reset       Reset policies to defaults
  rm          Remove a policy
  set-default Set the default network policy

Flags:
  -h, --help   help for policy

Global Flags:
  -D, --debug   Enable debug logging

Use "sbx policy [command] --help" for more information about a command.

```

## sbx policy allow

```
Add a policy that permits sandboxes to access specified resources.

Allowed resources are accessible to all sandboxes. If a resource matches both
an allow and a deny rule, the deny rule takes precedence.

Usage:
  sbx policy allow COMMAND
  sbx policy allow [command]

Available Commands:
  network     Allow network access to specified hosts

Flags:
  -h, --help   help for allow

Global Flags:
  -D, --debug   Enable debug logging

Use "sbx policy allow [command] --help" for more information about a command.

```

## sbx ports

```
Manage sandbox port publishing.

List, publish, or unpublish ports for a running sandbox. Without --publish or
--unpublish flags, lists all published ports.

Port spec format: [[HOST_IP:]HOST_PORT:]SANDBOX_PORT[/PROTOCOL]
If HOST_PORT is omitted, an ephemeral port is allocated automatically.
HOST_IP defaults to 127.0.0.1, PROTOCOL defaults to tcp.
Supported protocols: tcp, tcp4, tcp6, udp, udp4, udp6.

Usage:
  sbx ports SANDBOX [flags]

Examples:
  # List published ports
  sbx ports my-sandbox

  # Publish sandbox port 8080 to an ephemeral host port
  sbx ports my-sandbox --publish 8080

  # Publish with a specific host port
  sbx ports my-sandbox --publish 3000:8080

  # Unpublish a port
  sbx ports my-sandbox --unpublish 3000:8080

Flags:
  -h, --help                    help for ports
      --json                    Output in JSON format (for port listing)
      --publish stringArray     Publish a port (can be repeated): [[HOST_IP:]HOST_PORT:]SANDBOX_PORT[/PROTOCOL]
      --unpublish stringArray   Unpublish a port (can be repeated): [HOST_IP:]HOST_PORT:SANDBOX_PORT[/PROTOCOL]

Global Flags:
  -D, --debug   Enable debug logging

```

## sbx run

```
Run an agent in a sandbox, creating the sandbox if it does not already exist.

Pass agent arguments after the "--" separator. Additional workspaces can be
provided as extra arguments. Append ":ro" to mount them read-only.

To create a sandbox without attaching, use "sbx create" instead.

Available agents: claude, codex, copilot, cursor, docker-agent, droid, gemini, kiro, opencode, shell

Usage:
  sbx run [flags] SANDBOX | AGENT [PATH...] [-- AGENT_ARGS...]

Examples:
  # Create and run a sandbox with claude in current directory
  sbx run claude

  # Create and run with additional workspaces (read-only)
  sbx run claude . /path/to/docs:ro

  # Run an existing sandbox
  sbx run existing-sandbox

  # Run a sandbox with agent arguments
  sbx run claude -- --continue

Flags:
      --branch string     Create a Git worktree on the given branch (use --branch auto to auto-generate)
      --cpus int          Number of CPUs to allocate to the sandbox (0 = auto: N-1 host CPUs, min 1)
  -h, --help              help for run
      --kit strings       Kit reference (directory, ZIP, or OCI). Can be specified multiple times
  -m, --memory string     Memory limit in binary units (e.g., 1024m, 8g). Default: 50% of host memory, max 32 GiB
      --name string       Name for the sandbox (default: <agent>-<workdir>)
  -t, --template string   Container image to use for the sandbox (default: agent-specific image)

Global Flags:
  -D, --debug   Enable debug logging

```

## sbx secret

```
Manage stored secrets for sandbox environments.

Secrets are stored per service name (e.g., "github", "anthropic", "openai").
When a sandbox starts, the proxy uses stored secrets to authenticate API
requests on behalf of the agent. The secret is never exposed directly to the
agent.

Secrets can be scoped globally (shared across all sandboxes) or to a
specific sandbox.

Usage:
  sbx secret [command]

Available Commands:
  ls          List stored secrets
  rm          Remove a secret
  set         Create or update a secret

Flags:
  -h, --help   help for secret

Global Flags:
  -D, --debug   Enable debug logging

Use "sbx secret [command] --help" for more information about a command.

```

## sbx secret set

```
Create or update a secret for a service.

Available services: anthropic, aws, cursor, droid, github, google, groq, mistral, nebius, openai, xai

When no arguments are provided, an interactive prompt guides you through
scope and service selection.

Usage:
  sbx secret set [-g | sandbox] [service] [flags]

Examples:
  # Store a GitHub token globally (available to all sandboxes)
  sbx secret set -g github

  # Store an OpenAI key for a specific sandbox
  sbx secret set my-sandbox openai

  # Non-interactive via stdin (e.g., from a secret manager or env var)
  echo "$ANTHROPIC_API_KEY" | sbx secret set -g anthropic

  # Start OpenAI OAuth flow and store global OAuth tokens
  sbx secret set -g openai --oauth

Flags:
  -f, --force          Overwrite an existing secret when --token is used
  -g, --global         Use global secret scope
  -h, --help           help for set
      --oauth          Start OAuth flow and store OAuth tokens (openai/global only)
  -t, --token string   Secret value (less secure: visible in shell history)

Global Flags:
  -D, --debug   Enable debug logging

```

## sbx template

```
Manage sandbox templates.

Templates are saved snapshots of sandboxes that can be reused to create new
sandboxes with: sbx run -t TAG AGENT [WORKSPACE]

Usage:
  sbx template COMMAND
  sbx template [command]

Available Commands:
  load        Load an image from a tar file into the sandbox runtime
  ls          List template images
  rm          Remove a template image
  save        Save a snapshot of the sandbox as a template

Flags:
  -h, --help   help for template

Global Flags:
  -D, --debug   Enable debug logging

Use "sbx template [command] --help" for more information about a command.

```