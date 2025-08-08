# System Task Manager

A Dockerized Bash and Python-based system monitoring and task automation tool with both GUI (Zenity) and Console support for Linux.

---

## 🚀 Project Overview

**System Task Manager** is a Linux-focused tool for real-time system resource monitoring and task automation. It combines:

- Bash and Python scripting
- GUI support via Zenity
- CLI fallback for headless environments
- Docker containerization for portability

It enables system administrators and users to inspect and control CPU, memory, disk, network, GPU, and processes interactively.

---

## 📁 Project Structure

| File/Folder       | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `sys_mon.sh`      | GUI/Console script for system monitoring using Zenity                       |
| `project_os.sh`   | Console-based task automation and system info script                        |
| `code_python.py`  | Python script to log metrics and generate visual reports                    |
| `Dockerfile`      | Docker setup with all dependencies for deployment                          |

---

## 🛠️ Features

- Real-time monitoring of:
  - CPU, Memory, Disk, Network, GPU
  - SMART disk health
- Process listing and termination
- Uptime and system load metrics
- Full graphical or console-based user interface
- Automated data logging and graph generation
- Dockerized for easy deployment

---

## 📦 Setup & Installation

### Prerequisites

- Docker
- Bash
- Python 3
- Zenity (for GUI)

### Docker Installation

```bash
# Build the Docker image
docker build -t system-task-manager .

# Run the container (requires privileged mode for full hardware access)
docker run -it --privileged system-task-manager
```

---

## ▶️ Usage Instructions

Once inside the Docker container:

### Launch GUI/Console Interface

```bash
./sys_mon.sh
```

You’ll be prompted to choose **GUI** or **Console** mode.

### Console-Only Mode

```bash
./project_os.sh
```

### Generate Report via Python

```bash
python3 code_python.py
```

> Reports and logs are saved to your desktop path (you may change them in the scripts).

---

## 💡 Example Workflow

1. Start `sys_mon.sh` and login
2. Monitor system in GUI or Console mode
3. View SMART status or terminate processes
4. Generate full system report and graphs with Python

---

## 🔧 Customization

- Change hardcoded paths like `/home/abdelrahman2274/Desktop/` to `$HOME` or relative paths
- Update credentials in `sys_mon.sh` for login security
- Add more Zenity dialogs or CLI options as needed

---

## 🔒 License

**Custom License – MIT No Commercial Use (MIT-NC)**

This project is licensed for personal, educational, and non-commercial use only.  
**Commercial use (e.g., selling, sublicensing) is strictly prohibited without explicit permission** from the original author or designated contributors.

See the [`LICENSE`](./LICENSE) file for full terms.

---

## 🧑‍💻 Author

Developed by **Abdelrahmansoliman012004**  
Feel free to contribute or suggest improvements!
