#include libraries 
import csv
import os
import re
import tkinter as tk
from tkinter import messagebox, ttk

import bom_engine
import config
import views
from csv_product_manager import CSVProductManagerWindow


class WaterMeterTab(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent)
        self.customers_csv_path = config.WATER_METER_CUSTOMERS_CSV
        self.products_csv_path = config.WATER_METER_PRODUCTS_CSV
        self.customer_data = {}
        self.build_ui()
        self.refresh_customer_list()

    def build_ui(self):
        top_tab_bar = ttk.Frame(self)
        top_tab_bar.pack(fill="x", padx=10, pady=(10, 0))

        ttk.Label(
            top_tab_bar,
            text="Price List Search",
            font=("Helvetica", 10, "bold"),
            background="#e8e8e8"
        ).pack(side="left", padx=(0, 10))

        ttk.Label(
            top_tab_bar,
            text="Material & Labor Calculator",
            font=("Helvetica", 10)
        ).pack(side="left")

        ttk.Separator(self, orient="horizontal").pack(fill="x", pady=(8, 0), padx=10)

        title = ttk.Label(
            self,
            text="Water Meter Price Lookup",
            font=("Helvetica", 16, "bold")
        )
        title.pack(pady=(18, 10))

        form_frame = ttk.Frame(self, padding="10")
        form_frame.pack(fill="both", expand=True)

        row = 0

        ttk.Label(form_frame, text="Select Customer:", font=("Helvetica", 10, "bold")).grid(
            row=row, column=0, sticky="w", pady=4
        )

        cust_frame = ttk.Frame(form_frame)
        cust_frame.grid(row=row, column=1, sticky="e", pady=4)

        self.customer_combo = ttk.Combobox(cust_frame, width=17, state="readonly")
        self.customer_combo["values"] = ["Standard Customer", "Customer A", "Customer B", "Customer C"]
        self.customer_combo.current(0)
        self.customer_combo.pack(side="left", padx=(0, 5))

        add_cust_btn = ttk.Button(cust_frame, text="+ Add Customer", command=self.open_add_customer_window)
        add_cust_btn.pack(side="left", padx=(0, 5))

        open_csv_btn = ttk.Button(cust_frame, text="📊 Open Price List", command=self.open_csv_viewer)
        open_csv_btn.pack(side="left")

        edit_csv_btn = ttk.Button(cust_frame, text="Upload / Edit CSV", width=14, command=self.open_csv_manager)
        edit_csv_btn.pack(side="left", padx=(5, 0))

        row += 1
        ttk.Separator(form_frame, orient="horizontal").grid(row=row, column=0, columnspan=2, sticky="ew", pady=8)
        row += 1

        ttk.Label(form_frame, text="Device Name:").grid(row=row, column=0, sticky="w", pady=4)
        self.device_name_entry = ttk.Entry(form_frame, width=25)
        self.device_name_entry.grid(row=row, column=1, sticky="e", pady=4)
        row += 1

        ttk.Label(form_frame, text="Tank Height Position:").grid(row=row, column=0, sticky="w", pady=4)
        self.tank_position_combo = ttk.Combobox(
            form_frame,
            values=["Overhead Tank", "Underground Tank", "Ground Level Tank", "Sump Tank"],
            width=23,
            state="readonly"
        )
        self.tank_position_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.tank_position_combo.current(0)
        row += 1

        ttk.Label(form_frame, text="Solenoid Valve:").grid(row=row, column=0, sticky="w", pady=4)
        self.solenoid_combo = ttk.Combobox(
            form_frame,
            values=["Yes", "No"],
            width=23,
            state="readonly"
        )
        self.solenoid_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.solenoid_combo.current(0)
        row += 1

        ttk.Label(form_frame, text="Sensor Type:").grid(row=row, column=0, sticky="w", pady=4)
        self.sensor_type_combo = ttk.Combobox(
            form_frame,
            values=["Float Sensor", "Ultrasonic", "Pressure Sensor", "Level Sensor"],
            width=23,
            state="readonly"
        )
        self.sensor_type_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.sensor_type_combo.current(0)
        row += 1

        ttk.Label(form_frame, text="Communication Medium:").grid(row=row, column=0, sticky="w", pady=4)
        self.communication_medium_combo = ttk.Combobox(
            form_frame,
            values=["WiFi", "LoRa", "GSM"],
            width=23,
            state="readonly"
        )
        self.communication_medium_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.communication_medium_combo.current(0)
        self.communication_medium_combo.bind("<<ComboboxSelected>>", self._handle_communication_medium)
        row += 1

        self._handle_communication_medium()
        row += 1

        ttk.Label(form_frame, text="Meter Size:").grid(row=row, column=0, sticky="w", pady=4)
        self.meter_size_entry = ttk.Entry(form_frame, width=25)
        self.meter_size_entry.grid(row=row, column=1, sticky="e", pady=4)
        self.meter_size_entry.insert(0, "DN50")
        row += 1

        ttk.Label(form_frame, text="Remarks:").grid(row=row, column=0, sticky="w", pady=4)
        self.remarks_text = tk.Text(form_frame, height=4, width=24)
        self.remarks_text.grid(row=row, column=1, sticky="e", pady=4)
        row += 1

        btn_frame = ttk.Frame(self)
        btn_frame.pack(pady=10)

        search_btn = ttk.Button(btn_frame, text="Search Price", command=self.search_price)
        search_btn.pack(side="left", padx=5)

        calc_btn = ttk.Button(btn_frame, text="Open Material Calculator", command=self.open_material_calculator)
        calc_btn.pack(side="left", padx=5)

        save_btn = ttk.Button(btn_frame, text="Save Water Meter Data", command=self.save_data)
        save_btn.pack(side="left", padx=5)

        self.result_label = ttk.Label(self, text="Select water meter parameters and click 'Search Price'", font=("Helvetica", 12, "italic"))
        self.result_label.pack(pady=5)

        self.validation_error_label = ttk.Label(self, text="", foreground="red", font=("Helvetica", 9, "bold"))
        self.validation_error_label.pack(pady=2)

        self.config_status_var = tk.StringVar(value="Configuration not ready")
        self.config_status_label = ttk.Label(self, textvariable=self.config_status_var, foreground="orange", font=("Helvetica", 9, "bold"))
        self.config_status_label.pack(pady=(0, 8))

        self.breakdown_label = ttk.Label(self, text="", font=("Helvetica", 9), foreground="gray")
        self.breakdown_label.pack(pady=2)

    def _handle_communication_medium(self, event=None):
        value = self.communication_medium_combo.get().strip().lower()
        if value == "lora":
            self.communication_medium_combo["values"] = ["LoRa", "WiFi", "GSM"]
            self.communication_medium_combo.current(0)
        else:
            self.communication_medium_combo["values"] = ["WiFi", "LoRa", "GSM"]
            if value in {"wifi", "gsm"}:
                for index, item in enumerate(self.communication_medium_combo["values"]):
                    if item.lower() == value:
                        self.communication_medium_combo.current(index)
                        break
            else:
                self.communication_medium_combo.current(0)

    def refresh_customer_list(self):
        customers = bom_engine.read_csv_data(self.customers_csv_path)
        self.customer_data = {}
        names = []

        for c in customers:
            name = c.get("customer_name")
            if name:
                try:
                    pct = float(c.get("percentage", 0.0))
                except ValueError:
                    pct = 0.0
                self.customer_data[name] = pct
                names.append(name)

        if names:
            self.customer_combo["values"] = names
            self.customer_combo.current(0)

    def open_add_customer_window(self):
        views.AddCustomerWindow(self.winfo_toplevel(), self.refresh_customer_list, self.customers_csv_path)

    def open_csv_viewer(self):
        views.CSVViewerWindow(
            self.winfo_toplevel(),
            self.products_csv_path,
            title="Water Meter Price List"
        )

    def open_csv_manager(self):
        CSVProductManagerWindow(
            self.winfo_toplevel(),
            csv_path=self.products_csv_path,
            title="Water Meter Price List Editor"
        )

    def open_material_calculator(self):
        from tabs.material_tab import WaterMeterMaterialTab

        popup = tk.Toplevel(self.winfo_toplevel())
        popup.title("Water Meter Material & Labour Calculator")
        popup.geometry("900x620")
        popup.transient(self.winfo_toplevel())
        popup.grab_set()

        calc_frame = WaterMeterMaterialTab(popup, self)
        calc_frame.pack(fill="both", expand=True)

    def validate_form(self):
        issues = []

        if not self.device_name_entry.get().strip():
            issues.append("Device Name")
        if not self.tank_position_combo.get().strip():
            issues.append("Tank Height Position")
        if not self.solenoid_combo.get().strip():
            issues.append("Solenoid Valve")
        if not self.sensor_type_combo.get().strip():
            issues.append("Sensor Type")
        if not self.communication_medium_combo.get().strip():
            issues.append("Communication Medium")
        if not self.meter_size_entry.get().strip():
            issues.append("Meter Size")

        if issues:
            self.validation_error_label.config(text="Please check: " + ", ".join(issues), foreground="red")
            self.config_status_var.set("Configuration not ready")
            self.config_status_label.config(foreground="orange")
            self.result_label.config(text="Please complete required meter details", foreground="red", font=("Helvetica", 12, "bold"))
            return False

        self.validation_error_label.config(text="", foreground="red")
        self.config_status_var.set("Configuration Ready")
        self.config_status_label.config(foreground="green")
        self.result_label.config(text="Water meter configuration is ready", foreground="green", font=("Helvetica", 12, "bold"))
        return True

    def search_price(self):
        if not self.validate_form():
            messagebox.showwarning("Input Warning", "Please complete all required water meter fields before searching the price.")
            return

        def normalize(value):
            if value is None:
                return ""
            return re.sub(r"[^a-z0-9]", "", str(value).strip().lower())

        device_name = normalize(self.device_name_entry.get())
        tank_position = normalize(self.tank_position_combo.get())
        solenoid = normalize(self.solenoid_combo.get())
        sensor_type = normalize(self.sensor_type_combo.get())
        communication_medium = normalize(self.communication_medium_combo.get())
        meter_size = normalize(self.meter_size_entry.get())

        if not os.path.exists(self.products_csv_path):
            self.result_label.config(text="No water meter product data found", foreground="red", font=("Helvetica", 12, "bold"))
            self.breakdown_label.config(text="Please add entries into the water meter product CSV.")
            return

        matched_row = None
        try:
            with open(self.products_csv_path, mode="r", encoding="utf-8-sig") as file:
                reader = csv.DictReader(file)
                for row in reader:
                    if not row:
                        continue

                    row_device = normalize(row.get("device_name") or row.get("product_name") or row.get("name") or "")
                    row_tank = normalize(row.get("tank_height_position") or row.get("tank_position") or row.get("installation_position") or "")
                    row_solenoid = normalize(row.get("solenoid_valve") or row.get("solenoid") or row.get("valve") or "")
                    row_sensor = normalize(row.get("sensor_type") or row.get("sensor") or row.get("level_sensor") or "")
                    row_medium = normalize(row.get("communication_medium") or row.get("communication") or row.get("network") or "")
                    row_size = normalize(row.get("meter_size") or row.get("pipe_size") or row.get("size") or row.get("dn") or "")

                    matches = True
                    if device_name and row_device and device_name not in row_device and row_device not in device_name:
                        matches = False
                    if tank_position and row_tank and tank_position != row_tank:
                        matches = False
                    if solenoid and row_solenoid and solenoid != row_solenoid:
                        matches = False
                    if sensor_type and row_sensor and sensor_type != row_sensor:
                        matches = False
                    if communication_medium and row_medium and communication_medium != row_medium:
                        matches = False
                    if meter_size and row_size and meter_size != row_size:
                        matches = False

                    if matches:
                        matched_row = row
                        break
        except Exception as e:
            self.result_label.config(text="Water meter price search failed", foreground="red", font=("Helvetica", 12, "bold"))
            self.breakdown_label.config(text=str(e))
            return

        if not matched_row:
            self.result_label.config(text="No matching water meter model found", foreground="red", font=("Helvetica", 12, "bold"))
            self.breakdown_label.config(text="Try different device name, tank position, sensor type, or communication medium.")
            return

        try:
            unit_price = float(matched_row.get("price", 0) or 0)
        except ValueError:
            unit_price = 0.0

        selected_customer = self.customer_combo.get()
        customer_adjustment = self.customer_data.get(selected_customer, 0.0)
        final_price = unit_price * (1 + (customer_adjustment / 100.0))

        self.result_label.config(
            text=f"Water Meter Price: ₹{final_price:,.2f}",
            foreground="green",
            font=("Helvetica", 12, "bold")
        )
        self.breakdown_label.config(
            text=(
                f"Model: {matched_row.get('device_name') or matched_row.get('product_name') or 'Water Meter'} | "
                f"Tank: {matched_row.get('tank_height_position') or '-'} | "
                f"Sensor: {matched_row.get('sensor_type') or '-'} | "
                f"Comm: {matched_row.get('communication_medium') or '-'} | "
                f"Customer Adjustment: {customer_adjustment}%"
            )
        )

    def save_data(self):
        if not self.validate_form():
            messagebox.showwarning("Invalid Input", "Please complete all required water meter fields before saving.")
            return

        selected_customer = self.customer_combo.get()
        pct_adj = self.customer_data.get(selected_customer, 0.0)
        messagebox.showinfo(
            "Saved",
            f"Water meter configuration saved successfully.\nCustomer adjustment: {pct_adj}%"
        )
