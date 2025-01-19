# Laravel Deployment 
Using Image :
- mariadb
- php8.2-fpm
consideration deployment using this image :
- more compact rather and using full build image linux
- faster to load
# Structure
- laravel-docker/
- ├── app/
- ├── bootstrap/
- ├── storage/
- ├── resources/
- │   └── views
- │        └── welcome.blade.php
- ├── docker/
- │   └── nginx
- │   └── php
- │   └── config
- ├── ..
- ├── Dockerfile
- ├── docker-compose.yml
- ├── .env
- └── README.md
# Note
- welcome page on >> welcome.blade.php
- modification file docker >> docker
- backup database >> docker/config
- this using fresh enviroment >> there's some code need to adjust (database connection & exposed port)
# Command
- Build and start all services
docker-compose build 

- Build and start in detached mode
docker-compose up -d

- Stop all services
docker-compose down

- View logs
docker-compose logs

- Rebuild services
docker-compose up --build

- Access container shell
docker exec -it container_name sh
