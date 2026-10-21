# Exercise 5 - Docker Security with AppArmor and Python
# Run in PowerShell from this folder with Docker Desktop running.

# Check if docker / the kernel supports AppArmor
docker info --format "{{json .SecurityOptions}}"
docker info --format "{{.KernelVersion}} | {{.OperatingSystem}}"
docker run --rm --privileged --pid=host alpine:3.20 sh -c "cat /sys/module/apparmor/parameters/enabled"

# Task 2 - build the image
docker build -t flask-apparmor .

# Task 3 - load the profile (apparmor_parser is not on Windows, so it is run in a privileged ubuntu container)
docker run --rm --privileged -v "${PWD}\my-apparmor-profile:/etc/apparmor.d/my-apparmor-profile:ro" ubuntu:24.04 bash -c "apt-get update -qq && apt-get install -y -qq apparmor apparmor-utils; apparmor_parser --version | head -1; apparmor_parser -r /etc/apparmor.d/my-apparmor-profile; aa-enabled"

# Task 3 - run the container with the profile and check it
docker run -d --name flask-aa --security-opt="apparmor=my-apparmor-profile" -p 5000:5000 flask-apparmor
curl.exe -s http://localhost:5000/
docker inspect flask-aa --format "SecurityOpt={{json .HostConfig.SecurityOpt}} AppArmorProfile={{json .AppArmorProfile}}"
docker exec flask-aa sh -c "head -3 /etc/passwd"
docker exec flask-aa cat /proc/self/attr/current
docker rm -f flask-aa

# Task 4 and 5 - Docker SDK for Python scripts (run inside a python virtual environment)
python -m venv venv
.\venv\Scripts\python.exe -m pip install docker
.\venv\Scripts\python.exe apply_apparmor.py
.\venv\Scripts\python.exe test_restricted_actions.py

# Cleanup (the scripts stop the containers but do not remove them)
docker ps -a --filter ancestor=flask-apparmor
docker rm <container-ids>
docker rmi flask-apparmor
