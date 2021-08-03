# terraform-larry

Personal setup of infra for Oracle Cloud. Probably not useful for others.

# What it does

- Creates the largest free ARM box running Ubuntu (with the essential network components for internet access)
- Creates and attaches a data volume
- Sets up SSH, Docker, sops
- Fetches configured repo and does `docker-compose up` against this (mine is at [docker-at-larrys](https://github.com/jonohill/docker-at-larrys))

If you apply again then your box can be recreated when there's a newer image verision. As always, review the proposed changes and ensure especially that the `data_volume` resource doesn't accidentally get recreated or deleted.
