# Exercise 6 - Real-Time Operations Monitoring and Alerting
# Run in PowerShell from this folder with Docker Desktop running.

# Step 2a - install prometheus-client (in a python virtual environment)
python -m venv venv
.\venv\Scripts\python.exe -m pip install prometheus-client

# Step 1 - run the python app (keep this terminal open) and check the metrics in another terminal
.\venv\Scripts\python.exe -u delivery_metrics.py
curl.exe -s http://localhost:8000/metrics

# Step 2 - run Prometheus (on Windows -p 9090:9090 is used instead of --network=host)
docker run -d --name prometheus -p 9090:9090 -v "${PWD}\prometheus.yml:/etc/prometheus/prometheus.yml" -v "${PWD}\alert_rules.yml:/etc/prometheus/alert_rules.yml" prom/prometheus
docker ps -a --filter name=prometheus
(curl.exe -s http://localhost:9090/api/v1/targets | ConvertFrom-Json).data.activeTargets | ForEach-Object { "{0}  {1}  health={2}" -f $_.labels.job, $_.scrapeUrl, $_.health }
(curl.exe -s http://localhost:9090/api/v1/rules | ConvertFrom-Json).data.groups.rules | ForEach-Object { "{0}  state={1}" -f $_.name, $_.state }

# Step 3 - run Grafana (anonymous viewer added so the dashboard can be opened without login)
docker pull grafana/grafana
docker run -d --name grafana -p 3000:3000 -e GF_AUTH_ANONYMOUS_ENABLED=true -e GF_AUTH_ANONYMOUS_ORG_ROLE=Viewer grafana/grafana
curl.exe -s http://localhost:3000/api/health

# Step 3c - add Prometheus data source (login admin/admin), then Save & Test
curl.exe -s -u admin:admin -H "Content-Type: application/json" -X POST http://localhost:3000/api/datasources -d '{\"name\":\"Prometheus\",\"type\":\"prometheus\",\"uid\":\"prometheus\",\"url\":\"http://host.docker.internal:9090\",\"access\":\"proxy\",\"isDefault\":true}'
curl.exe -s -u admin:admin http://localhost:3000/api/datasources/uid/prometheus/health

# Step 3d - create the dashboard with 4 panels
curl.exe -s -u admin:admin -H "Content-Type: application/json" -X POST http://localhost:3000/api/dashboards/db -d "@grafana-dashboard.json"
# open http://localhost:3000/d/delivery-monitoring/delivery-monitoring-dashboard

# Step 6 - simulate alerts: change pending = random.randint(50, 100) in delivery_metrics.py,
# restart the python script and Prometheus, then check the alerts
docker restart prometheus
(curl.exe -s http://localhost:9090/api/v1/alerts | ConvertFrom-Json).data.alerts | ForEach-Object { "{0}  state={1}  value={2}" -f $_.labels.alertname, $_.state, $_.value }
# (then change it back to random.randint(10, 20))

# Step 5a and 5b - plain Jenkins as in the exercise
docker ps -a --filter name=jenkins
docker run -d -p 8080:8080 -p 50000:50000 --name jenkins -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
docker exec jenkins docker --version       # fails, no docker inside plain jenkins

# Step 5 - Jenkins with docker CLI to run the Jenkinsfile
docker rm -f prometheus grafana jenkins
docker build -f jenkins.Dockerfile -t jenkins-docker .
docker run -d --name jenkins -u root -p 8080:8080 -p 50000:50000 -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" -v jenkins_home_ex6:/var/jenkins_home -v //var/run/docker.sock:/var/run/docker.sock -v "${PWD}:/delivery_monitoring:ro" jenkins-docker
# In Jenkins: New Item > Pipeline > Pipeline script > paste the Jenkinsfile > Save > Build Now
# (I created the job "delivery-monitoring-pipeline" with the Jenkins REST API using the same Jenkinsfile)
docker ps --format "table {{.Image}}\t{{.Status}}\t{{.Names}}"
docker logs delivery_metrics

# Cleanup
docker rm -f delivery_metrics prometheus grafana jenkins
docker volume rm jenkins_home jenkins_home_ex6
