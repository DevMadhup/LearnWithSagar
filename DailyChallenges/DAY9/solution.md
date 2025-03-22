## Build a Distributed Logging System (Part 2)

- **Pre-requisite:** Complete Day8 (Build a Distributed Logging System (Part 1)) challenge. 

### Steps to implement

- Install pip3 in your machine (If not installed)
```bash
sudo apt install python3-pip -y
```
---

- Install a virtual environment
```bash
sudo apt install python3-venv
```
---

- Create virtual environment
```bash
python3 -m venv venv
source venv/bin/activate
```
---

- Now, install pika client library for RabbitMQ
```bash
pip install pika
```
---

- Run the producer script to send a log message
```bash
python log_producer.py "Log Entry 1: This is a sample log."
```
![image](https://github.com/user-attachments/assets/42db477b-c8c2-45b7-b975-fbb59e08ff97)

![image](https://github.com/user-attachments/assets/cc2db6a5-7f69-4553-93fe-866afafbeb92)

---
- Run the consumer script
```bash
python log_aggregator.py
```
![image](https://github.com/user-attachments/assets/82376b51-717c-451e-ae81-f545b11c084a)

![image](https://github.com/user-attachments/assets/cf5d4c4f-98a7-47cd-81b9-4e2f27755a5f)

---

- Verfiy the aggregated_logs.txt file to ensure all logs are captured.
  
![image](https://github.com/user-attachments/assets/62f73c6c-de4c-404a-8fd3-2332aaf06ae1)
