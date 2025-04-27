FROM ubuntu
WORKDIR /app


# Set environment variables
ENV DEBIAN_FRONTEND="noninteractive" TZ="America/Chicago"

# Install system dependencies, including python3-venv for creating virtual environments and Redis
RUN apt-get -y update && \
    apt-get -y install make sudo mysql-server libmysqlclient-dev python3 python3-pip python3-venv redis-server && \
    apt-get clean

COPY . .

    # Start MySQL and set root user authentication method
RUN service mysql start && \
mysql mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY ''; FLUSH PRIVILEGES;"  && \
mysql mysql -e "CREATE USER 'automoss'@'localhost' IDENTIFIED BY 'password';" && \
mysql mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'automoss'@'localhost' WITH GRANT OPTION;" && \
mysql mysql -e "FLUSH PRIVILEGES;"


# Create and activate a virtual environment, install dependencies
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip
RUN pip install -r requirements_dev.txt --upgrade

# Make start script executable
RUN chmod +x start.sh

# Start MySQL, Redis, and run server
CMD service redis-server start && service mysql start && python ./automoss/db.py && make install && /bin/bash /app/start.sh