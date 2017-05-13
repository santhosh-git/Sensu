# Docker Sensu Server
   Ubuntu with Sensu, It runs Redis, Rabbitmq server, Uchiwa, Sensu server, Sensu API
   
  # Installation
    docker pull santhoz/sensu
    
   or
   
    git clone https://github.com/santhosh-git/Sensu.git
    cd Sensu
    docker build -t sensu .
    
  # To Run
    docker run -d -p 3000:3000 -p 5671:5671 -p 15672:15672  -it --name sensu  santhoz/sensu
    
  # Create a RabbitMQ virtual host and user for Sensu
    rabbitmqctl add_vhost /sensu
    rabbitmqctl add_user sensu secret
    rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"  
  
  # Access dashboards via browser
    Uchiwa   - http://your-IP:3000
    RabbitMQ - http://your-IP:15672
    
  Note : RabbitMQ SSL file location for sensu clients (/opt/sensu_ssl_tool/client/)

  
    
   
 
