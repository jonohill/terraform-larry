# terraform-larry

Personal setup of infra for Oracle Cloud. Probably not useful for others.

## What it does

- Creates the largest free ARM box running Ubuntu (with the essential network components for internet access)
- Sets up SSH, Docker, sops
- Fetches configured repo and does `docker-compose up` against this (mine is at [docker-at-larrys](https://github.com/jonohill/docker-at-larrys))
