import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import subprocess
import datetime

# Initialize data storage for all metrics
timestamps = []
cpu_usages = []
memory_usages = []
network_rx = []
network_tx = []
disk_usages = []
gpu_utilizations = []

# Function to fetch system metrics without psutil
def fetch_metrics():
    # Get CPU usage
    cpu_command = "top -bn1 | grep '%Cpu' | awk '{print 100-$8}' | tee -a  /home/abdelrahman2274/Desktop/report_python.txt"
    cpu_usage = float(subprocess.getoutput(cpu_command).strip())

    # Get memory usage
    memory_command = "free | awk '/Mem/ {printf \"%.2f\", $3/$2 * 100}'"
    memory_usage = float(subprocess.getoutput(memory_command).strip())

    # Get network usage
    interface = subprocess.getoutput("ip route show default | awk '/default/ {print $5}'").strip()
    rx_bytes = int(subprocess.getoutput(f"cat /sys/class/net/{interface}/statistics/rx_bytes").strip())
    tx_bytes = int(subprocess.getoutput(f"cat /sys/class/net/{interface}/statistics/tx_bytes").strip())

    # Get disk usage
    disk_command = "df -h / | awk 'NR==2 {print $5}' | sed 's/%//'"
    disk_usage = float(subprocess.getoutput(disk_command).strip())

    # Get GPU utilization (replace with actual GPU metric if available)
    gpu_command = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits"
    try:
        gpu_utilization = float(subprocess.getoutput(gpu_command).strip())
    except ValueError:
        gpu_utilization = 0.0  # Default if no GPU or command fails

    # Get current timestamp
    timestamp = datetime.datetime.now().strftime("%H:%M:%S")

    return timestamp, cpu_usage, memory_usage, rx_bytes, tx_bytes, disk_usage, gpu_utilization

# Function to update the graph
def update(frame):
    global previous_rx, previous_tx

    timestamp, cpu, memory, rx, tx, disk, gpu = fetch_metrics()

    # Calculate network usage (difference since last fetch)
    if len(network_rx) > 0:
        rx_rate = (rx - network_rx[-1]) / 1024  # Convert bytes to KB
        tx_rate = (tx - network_tx[-1]) / 1024
    else:
        rx_rate = 0
        tx_rate = 0

    # Append data to the lists
    timestamps.append(timestamp)
    cpu_usages.append(cpu)
    memory_usages.append(memory)
    network_rx.append(rx_rate)
    network_tx.append(tx_rate)
    disk_usages.append(disk)
    gpu_utilizations.append(gpu)

    # Limit data to the last 20 points to avoid overcrowding
    if len(timestamps) > 20:
        timestamps.pop(0)
        cpu_usages.pop(0)
        memory_usages.pop(0)
        network_rx.pop(0)
        network_tx.pop(0)
        disk_usages.pop(0)
        gpu_utilizations.pop(0)

    # Clear and update the graph
    ax1.clear()
    ax2.clear()
    ax3.clear()
    ax4.clear()
    ax5.clear()

    ax1.plot(timestamps, cpu_usages, label="CPU Usage (%)", color="blue", marker="o")
    ax2.plot(timestamps, memory_usages, label="Memory Usage (%)", color="green", marker="o")
    ax3.plot(timestamps, network_rx, label="Network RX (KB/s)", color="orange", marker="o")
    ax3.plot(timestamps, network_tx, label="Network TX (KB/s)", color="red", marker="o")
    ax4.plot(timestamps, disk_usages, label="Disk Usage (%)", color="purple", marker="o")
    ax5.plot(timestamps, gpu_utilizations, label="GPU Utilization (%)", color="brown", marker="o")

    # Set titles and labels
    ax1.set_title("Live CPU Usage")
    ax2.set_title("Live Memory Usage")
    ax3.set_title("Live Network Usage")
    ax4.set_title("Live Disk Usage")
    ax5.set_title("Live GPU Utilization")

    # Set y-axis limits
    ax1.set_ylim(0, 100)
    ax2.set_ylim(0, 100)
    ax3.set_ylim(0, max(max(network_rx, default=1), max(network_tx, default=1)) * 1.2)
    ax4.set_ylim(0, 100)
    ax5.set_ylim(0, 100)

    # Format x-axis
    for ax in [ax1, ax2, ax3, ax4, ax5]:
        ax.set_xticks(timestamps)
        ax.set_xticklabels(timestamps, rotation=45, ha="right", fontsize=8)
        ax.legend()

    fig.tight_layout()

# Set up the figure and axes
fig, ((ax1, ax2), (ax3, ax4), (ax5, _)) = plt.subplots(3, 2, figsize=(12, 10), gridspec_kw={'width_ratios': [3, 1]})
fig.delaxes(_)  # Remove unused subplot

# Set up the animation
ani = FuncAnimation(fig, update, interval=1000)  # Update every second

# Run the graph
plt.show()
