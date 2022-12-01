# Vagrant box

Создание образа Ubuntu 22.04 LTS для [DigitalOcean](https://digitalocean.com). Образ содержит:

* пользователь `ansible`/`root` без запроса пароля для sudo;
* предустановленные пакеты:
    * net-tools, ufw, wget, curl
    * gnupg
    * lsb-release
    * fish, jq, htop
    * ca-certificates, software-properties-common, apt-transport-https
    * python3, python3-apt, python3-pip, python3-distutils-extra
    * docker

## Сборка

Для сборки требуется token доступа для публикации в [DigitalOcean API token](https://cloud.digitalocean.com/) -> `API`
-> `Personal access tokens`.

```shell
$ echo 'do_token = "<DigitalOcean token>"' > vars.pkrvars.hcl

$ packer build -var-file=vars.pkrvars.hcl template.pkr.hcl
```