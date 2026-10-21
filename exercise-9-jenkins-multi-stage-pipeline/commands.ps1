# Exercise 9 - Jenkins Multi-Stage Pipeline
# git commands run in Git Bash

# make the github repo
gh repo create exercise-9 --public --description "Python Flask app for Jenkins multi-stage pipeline."

# Step 2 - app folder (app.py, requirements.txt, test_app.py)
mkdir python-flask-app
cd python-flask-app

# Step 3 - push to github
git init
git config user.name "Vaibhavi"
git config user.email "vaibhavijadhav1603@gmail.com"
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/vaibhavijadhav1603/exercise-9.git
git push -u origin main

# Step 5 - Jenkinsfile
git add Jenkinsfile
git commit -m "Added Jenkinsfile"
git push

# Step 4 and 6 - Jenkins (http://localhost:8080, same container as exercise 7)
# New Item > Python-MultiStage-Pipeline > Pipeline > OK
# Pipeline > Definition: Pipeline script from SCM > Git
# Repository URL: https://github.com/vaibhavijadhav1603/exercise-9.git, Branch: */main, Script Path: Jenkinsfile > Save

# Step 7 - Build Now (build #1 failed: python3 not found)
curl.exe -s -u admin:admin123 http://localhost:8080/job/Python-MultiStage-Pipeline/1/consoleText

# Step 8 - install python inside the jenkins container as root
docker ps -a
docker exec -u root jenkins bash -c "cat /etc/os-release | head -2"
docker exec -u root jenkins apt-get update
docker exec -u root jenkins apt install -y python3
docker exec -u root jenkins apt install -y pip
docker exec -u root jenkins apt install -y python3.11-venv     # not found on Debian 13
docker exec -u root jenkins apt install -y python3-venv
docker exec -u root jenkins apt install -y python3-flask
docker exec -u root jenkins bash -c "cd /var/jenkins_home/workspace/Python-MultiStage-Pipeline && python3 -m unittest discover -s ."

# Build Now again (build #2 SUCCESS)
curl.exe -s -u admin:admin123 http://localhost:8080/job/Python-MultiStage-Pipeline/2/consoleText

# check the deploy folder
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/Python-MultiStage-Pipeline && ls python-app-deploy && cat python-app-deploy/app.pid && cat python-app-deploy/app.log"

docker exec jenkins ps -eo pid,args
docker exec jenkins curl -s -m 3 http://127.0.0.1:5000/

# cleanup (after exercise 9)
docker rm -f jenkins
