# Exercise 7 - Jenkins Installation using Docker
# Run in PowerShell with Docker Desktop running.

# Step 1 - install (run) Jenkins using Docker
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts
docker images jenkins/jenkins

# Step 2 - get the initial admin password
docker ps -a
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
docker logs jenkins

# Step 3 - open Jenkins in the browser
# http://localhost:8080/
# Unlock Jenkins (paste the password) > Install suggested plugins >
# Create First Admin User > Instance Configuration (Save and Finish) > Start using Jenkins

# Step 4 - check Jenkins after setup
curl.exe -s -I -u admin:admin123 http://localhost:8080/ | Select-String "X-Jenkins:"
(curl.exe -s -u admin:admin123 "http://localhost:8080/pluginManager/api/json?depth=1" | ConvertFrom-Json).plugins.Count

# Cleanup (after exercise 8, which uses the same Jenkins)
docker rm -f jenkins
