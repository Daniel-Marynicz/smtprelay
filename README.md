# smtprelay

[![Go Report Card](https://goreportcard.com/badge/github.com/decke/smtprelay)](https://goreportcard.com/report/github.com/decke/smtprelay)

Simple Golang based SMTP relay/proxy server that accepts mail via SMTP
and forwards it directly to another SMTP server.


## Why another SMTP server?

Outgoing mails are usually send via SMTP to an MTA (Mail Transfer Agent)
which is one of Postfix, Exim, Sendmail or OpenSMTPD on UNIX/Linux in most
cases. You really don't want to setup and maintain any of those full blown
kitchensinks yourself because they are complex, fragile and hard to
configure.

My use case is simple. I need to send automatically generated mails from
cron via msmtp/sSMTP/dma, mails from various services and network printers
via a remote SMTP server without giving away my mail credentials to each
device which produces mail.


## Main features

* Supports SMTPS/TLS (465), STARTTLS (587) and unencrypted SMTP (25)
* Checks for sender, receiver, client IP
* Authentication support with file (LOGIN, PLAIN)
* Enforce encryption for authentication
* Forwards all mail to a smarthost (any SMTP server)
* Small codebase
* IPv6 support

### Docker 

You can find docker containers at [https://github.com/decke/smtprelay/pkgs/container/smtprelay](https://github.com/decke/smtprelay/pkgs/container/smtprelay)

Example docker-compose.yaml file:

```yaml
version: '3.7'
services:
    smtprelay:
        image: ghcr.io/decke/smtprelay:latest
        healthcheck:
            test: [ 'CMD-SHELL', 'echo -e "HELO hello\nQUIT" | nc -w 5 localhost 25 || exit 1']
        command:
            - -listen
            - '0.0.0.0:25'
            - -allowed_nets
            - '10.0.0.0/8 127.0.0.0/8'
            - -allowed_sender
            - 'example@example.com'
            - '-remotes'
            - 'starttls://user:pass@example.com:587'
```
