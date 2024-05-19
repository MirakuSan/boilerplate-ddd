# Boilerplate DDD

A [Docker](https://www.docker.com/)-based boilerplate for the [Symfony](https://symfony.com) web framework and DDD projects.
based on: 
- [Symfony Docker FrankenPHP](https://github.com/dunglas/symfony-docker)
- [apip-ddd](https://github.com/mtarld/apip-ddd) by [Mathias Arlaud](https://github.com/mtarld) and [Robin Chalas](https://github.com/chalasr)

## Getting Started

1. If not already done, [install Docker Compose](https://docs.docker.com/compose/install/) (v2.10+)
2. Run `make build` to build fresh images
3. Run `make up` to set up and start a fresh Symfony project
4. Run `make open` to open `https://localhost` in your favorite web browser and [accept the auto-generated TLS certificate](https://stackoverflow.com/a/15076602/1352334)
5. Run `make down` to stop the Docker containers.

## Licence

This project is released under the MIT license. See the included [LICENSE](LICENSE) file for more information.
