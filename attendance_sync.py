import ipaddress
import os
import socket

try:
    from zk import ZK
except ImportError:
    ZK = None


DEFAULT_DEVICE_IP = os.getenv("BIOMETRIC_DEVICE_IP", "192.168.1.201")
DEFAULT_DEVICE_PORT = int(os.getenv("BIOMETRIC_DEVICE_PORT", "4370"))
DEFAULT_DEVICE_PASSWORD = int(os.getenv("BIOMETRIC_DEVICE_PASSWORD", "0"))


def discover_device_ips(network="192.168.1.0/24", port=4370, timeout=0.2):
    """Return local addresses accepting TCP connections on the device port."""
    candidates = []
    for address in ipaddress.ip_network(network, strict=False).hosts():
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(timeout)
            if sock.connect_ex((str(address), port)) == 0:
                candidates.append(str(address))
    return candidates


def test_device_connection(
    device_ip=DEFAULT_DEVICE_IP,
    port=DEFAULT_DEVICE_PORT,
    password=DEFAULT_DEVICE_PASSWORD,
):
    """Connect to the device and return the transport used."""
    if ZK is None:
        raise RuntimeError(
            "Biometric sync requires the 'pyzk' package. Install it with: pip install pyzk"
        )

    last_error = None
    for force_udp in (False, True):
        device = ZK(
            device_ip,
            port=port,
            timeout=5,
            password=password,
            force_udp=force_udp,
            ommit_ping=True,
        )
        connection = None
        try:
            connection = device.connect()
            return "UDP" if force_udp else "TCP"
        except Exception as error:
            last_error = error
        finally:
            if connection:
                connection.disconnect()

    raise RuntimeError(
        f"Could not connect to biometric device at {device_ip}:{port} using TCP or UDP. "
        "Check the device IP, network connection, port, and communication password."
    ) from last_error


def fetch_device_logs(
    device_ip=DEFAULT_DEVICE_IP,
    port=DEFAULT_DEVICE_PORT,
    password=DEFAULT_DEVICE_PASSWORD,
):
    if ZK is None:
        raise RuntimeError(
            "Biometric sync requires the 'pyzk' package. Install it with: pip install pyzk"
        )
    last_error = None
    for force_udp in (False, True):
        zk = ZK(
            device_ip,
            port=port,
            timeout=5,
            password=password,
            force_udp=force_udp,
            ommit_ping=True,
        )
        conn = None
        try:
            transport = "UDP" if force_udp else "TCP"
            print(f"Connecting to biometric device at {device_ip}:{port} using {transport}...")
            conn = zk.connect()
            print("Connected successfully!")
            attendances = conn.get_attendance()
            return [
                {
                    "user_id": att.user_id,
                    "timestamp": att.timestamp,
                    "status": att.status,
                }
                for att in attendances
            ]
        except Exception as error:
            last_error = error
        finally:
            if conn:
                conn.disconnect()

    raise RuntimeError(
        f"Could not connect to biometric device at {device_ip}:{port} using TCP or UDP. "
        "Check the device IP, network connection, port 4370, and communication password."
    ) from last_error