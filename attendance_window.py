import csv
import os
import tkinter as tk
from datetime import datetime
from tkinter import messagebox, ttk

import attendance_sync


class AttendanceView(ttk.Frame):
    """Front-screen attendance view for reviewing and importing biometric logs."""

    CSV_PATH = os.path.join("csv_data", "hr_attendance_leave.csv")
    COLUMNS = (
        ("employee_id", "Employee ID"),
        ("employee_name", "Employee Name"),
        ("attendance_date", "Date"),
        ("clock_in", "Clock In"),
        ("clock_out", "Clock Out"),
        ("attendance_status", "Status"),
        ("attendance_source", "Source"),
    )

    def __init__(self, parent, user_data=None):
        super().__init__(parent, padding=15)
        self.user_data = user_data or {}
        self.status_var = tk.StringVar(value="Ready")
        self._build_ui()
        self._load_records()

    def _build_ui(self):
        header = ttk.Frame(self)
        header.pack(fill="x", pady=(0, 12))
        ttk.Label(
            header, text="Attendance", font=("Helvetica", 16, "bold")
        ).pack(side="left")
        ttk.Button(
            header, text="Sync Biometric Device", command=self.sync_device
        ).pack(side="right")

        device_bar = ttk.Frame(self)
        device_bar.pack(fill="x", pady=(0, 8))
        ttk.Label(device_bar, text="Biometric Device IP:").pack(side="left")
        self.device_ip_var = tk.StringVar(value=attendance_sync.DEFAULT_DEVICE_IP)
        ttk.Entry(device_bar, textvariable=self.device_ip_var, width=20).pack(
            side="left", padx=(6, 12)
        )
        ttk.Label(device_bar, text="Port:").pack(side="left")
        self.device_port_var = tk.StringVar(value=str(attendance_sync.DEFAULT_DEVICE_PORT))
        ttk.Entry(device_bar, textvariable=self.device_port_var, width=7).pack(
            side="left", padx=(6, 12)
        )
        ttk.Label(device_bar, text="Password:").pack(side="left")
        self.device_password_var = tk.StringVar(
            value=str(attendance_sync.DEFAULT_DEVICE_PASSWORD)
        )
        ttk.Entry(
            device_bar, textvariable=self.device_password_var, width=8, show="*"
        ).pack(side="left", padx=(6, 12))
        ttk.Button(
            device_bar, text="Test Connection", command=self.test_connection
        ).pack(side="left")

        toolbar = ttk.Frame(self)
        toolbar.pack(fill="x", pady=(0, 8))
        ttk.Button(toolbar, text="Refresh", command=self._load_records).pack(side="left")
        ttk.Label(toolbar, textvariable=self.status_var).pack(side="left", padx=12)

        table_frame = ttk.Frame(self)
        table_frame.pack(fill="both", expand=True)
        table_frame.rowconfigure(0, weight=1)
        table_frame.columnconfigure(0, weight=1)

        self.tree = ttk.Treeview(
            table_frame,
            columns=[key for key, _ in self.COLUMNS],
            show="headings",
        )
        for key, label in self.COLUMNS:
            self.tree.heading(key, text=label)
            self.tree.column(key, width=130, anchor="w")
        self.tree.grid(row=0, column=0, sticky="nsew")

        scrollbar = ttk.Scrollbar(
            table_frame, orient="vertical", command=self.tree.yview
        )
        scrollbar.grid(row=0, column=1, sticky="ns")
        self.tree.configure(yscrollcommand=scrollbar.set)

    def _load_records(self):
        for item in self.tree.get_children():
            self.tree.delete(item)

        if not os.path.exists(self.CSV_PATH):
            self.status_var.set("No attendance file found")
            return

        try:
            with open(self.CSV_PATH, newline="", encoding="utf-8") as file:
                for record in csv.DictReader(file):
                    self.tree.insert(
                        "", "end", values=[record.get(key, "") for key, _ in self.COLUMNS]
                    )
            self.status_var.set("Attendance records loaded")
        except OSError as error:
            self.status_var.set("Unable to load attendance records")
            messagebox.showerror("Attendance", str(error), parent=self)

    def sync_device(self):
        try:
            device_ip, port, password = self._device_settings()
            logs = attendance_sync.fetch_device_logs(
                device_ip=device_ip, port=port, password=password
            )
        except Exception as error:
            messagebox.showerror("Biometric Sync", str(error), parent=self)
            return

        if not logs:
            self.status_var.set("No biometric records received")
            messagebox.showinfo(
                "Biometric Sync",
                "No attendance records were received from the device.",
                parent=self,
            )
            return

        self._display_device_logs(logs)
        self.status_var.set(f"Received {len(logs)} biometric records")
        messagebox.showinfo(
            "Biometric Sync",
            f"Received {len(logs)} records. Review the data before importing it into HR.",
            parent=self,
        )

    def _device_settings(self):
        device_ip = self.device_ip_var.get().strip()
        if not device_ip:
            raise ValueError("Enter the biometric device IP address.")
        try:
            port = int(self.device_port_var.get().strip())
            password = int(self.device_password_var.get().strip() or "0")
        except ValueError as error:
            raise ValueError("Port and password must be numeric values.") from error
        if not 1 <= port <= 65535:
            raise ValueError("Port must be between 1 and 65535.")
        return device_ip, port, password

    def test_connection(self):
        try:
            device_ip, port, password = self._device_settings()
            transport = attendance_sync.test_device_connection(
                device_ip=device_ip, port=port, password=password
            )
        except Exception as error:
            messagebox.showerror("Biometric Connection", str(error), parent=self)
            return
        self.status_var.set(f"Device connected using {transport}")
        messagebox.showinfo(
            "Biometric Connection",
            f"Connected to {device_ip}:{port} using {transport}.",
            parent=self,
        )

    def _display_device_logs(self, logs):
        for item in self.tree.get_children():
            self.tree.delete(item)

        for log in logs:
            timestamp = log.get("timestamp")
            timestamp_text = timestamp.strftime("%Y-%m-%d %H:%M:%S") if timestamp else ""
            self.tree.insert(
                "",
                "end",
                values=[
                    log.get("user_id", ""),
                    "",
                    timestamp_text[:10],
                    timestamp_text[11:],
                    "",
                    log.get("status", ""),
                    "Biometric device",
                ],
            )
