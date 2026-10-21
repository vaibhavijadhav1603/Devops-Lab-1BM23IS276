# Exercise 8 - Hello World Jenkins job
# git commands run in Git Bash, inside a new folder C:\Users\vaibh\exercise-8

# make the github repo (public)
gh repo create exercise-8 --public --description "A demo repository for Jenkins scripting."

# create the script
touch hello-world.sh
# hello-world.sh:
#   #!/bin/bash
#   echo "Hello, Jenkins!"
chmod +x hello-world.sh

# local git repo
git init
git config user.name "Vaibhavi"
git config user.email "vaibhavijadhav1603@gmail.com"
git add hello-world.sh
git status
git commit -m "Add hello-world.sh"

# link to github and push
git remote add origin https://github.com/vaibhavijadhav1603/exercise-8.git
git push -u origin main

# Jenkins (same container as exercise 7) - http://localhost:8080
# New Item > HelloWorld > Freestyle project > OK
# Description: Hello World! Jenkins job.
# Source Code Management: Git, https://github.com/vaibhavijadhav1603/exercise-8.git, branch */main
# Build Steps: Execute shell > sh hello-world.sh
# Save > Build Now > #1 > Console Output

# console output from terminal
curl.exe -s -u admin:admin123 http://localhost:8080/job/HelloWorld/1/consoleText

# cleanup
docker rm -f jenkins
