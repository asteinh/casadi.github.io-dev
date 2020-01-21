#!/bin/bash

CONTAINER=asteinh/casadi_docs

cd content/docs && rm -rf -- */
git clone https://github.com/asteinh/casadi-docs.git source
cd source

container=$(docker run -itd -v ${PWD}:/src $CONTAINER)
docker exec -it $container /bin/bash -c "pip3 install -r requirements.txt"
docker exec -it $container /bin/bash -c "ln -s /usr/bin/python3 /usr/bin/python"

# iterate over all branches of the docs repository
for remote in $(git for-each-ref --format='%(refname)' refs/remotes); do
  if [[ "$remote" != *"HEAD"* ]]; then
    local=${remote#refs/remotes/origin/}
    git checkout $local && git pull
    docker exec -it $container /bin/bash -c "make html"
    chown -R $(id -u):$(id -g) build/
    folder=$(git rev-parse --abbrev-ref HEAD | sed -e 's/\.//g')
    mv build/$folder ../$folder
  fi
done

cd .. && rm -rf source && cd ../..
