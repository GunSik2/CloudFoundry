## Test CF

- exec_app_push_docker 
```
cf docker-push docker-app cloudfoundry/lattice-app
```

- exec_app_push_diego 
```
mkdir -p test-php; cd test-php
echo "<?php phpinfo(); ?>" > index.php
cf push test-php --no-start -b https://github.com/cloudfoundry/php-buildpack.git
cf enable-diego test-php
cf start test-php
```
