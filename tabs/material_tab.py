import csv
import os
import re

import tkinter as tk
from tkinter import messagebox, ttk

import bom_engine
import config


class MaterialTab(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent)
        self.current_bom = []
        self.current_labor_cost = 0.0
        self.current_grand_total = 0.0

        self.build_ui()

    def build_ui(self):
        title = ttk.Label(self, text="Material & Labor Calculator", font=("Helvetica", 14, "bold"))
        title.pack(pady=10)

        form_frame = ttk.LabelFrame(self, text=" Inputs (Yellow Section) ", padding="10")
        form_frame.pack(fill="x", padx=15, pady=5)

        row = 0

        ttk.Label(form_frame, text="Pump Current (A):").grid(row=row, column=0, sticky="w", pady=4)
        self.m_current_entry = ttk.Entry(form_frame, width=20)
        self.m_current_entry.grid(row=row, column=1, sticky="e", pady=4)
        self.m_current_entry.insert(0, "15")
        row += 1

        ttk.Label(form_frame, text="Number of Pumps:").grid(row=row, column=0, sticky="w", pady=4)
        self.m_pumps_combo = ttk.Combobox(form_frame, values=["1", "2", "3", "4", "5"], width=18, state="readonly")
        self.m_pumps_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.m_pumps_combo.set("3")
        row += 1

        ttk.Label(form_frame, text="Number of VFD:").grid(row=row, column=0, sticky="w", pady=4)
        self.m_vfd_combo = ttk.Combobox(form_frame, values=["0", "1", "2", "3", "4"], width=18, state="readonly")
        self.m_vfd_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.m_vfd_combo.set("1")
        row += 1

        ttk.Label(form_frame, text="Main Incomer Required:").grid(row=row, column=0, sticky="w", pady=4)
        self.m_incomer_combo = ttk.Combobox(form_frame, values=["1 - Yes", "0 - No"], width=18, state="readonly")
        self.m_incomer_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.m_incomer_combo.set("1 - Yes")
        row += 1

        ttk.Label(form_frame, text="3-Pole Door Mount Switch:").grid(row=row, column=0, sticky="w", pady=4)
        self.m_door_mount_combo = ttk.Combobox(form_frame, values=["1 - Yes", "0 - No"], width=18, state="readonly")
        self.m_door_mount_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.m_door_mount_combo.set("1 - Yes")
        row += 1

        ttk.Label(form_frame, text="Panel Size Level (1-5):").grid(row=row, column=0, sticky="w", pady=4)
        self.m_panel_size_combo = ttk.Combobox(form_frame, values=["1", "2", "3", "4", "5"], width=18, state="readonly")
        self.m_panel_size_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.m_panel_size_combo.set("4")
        row += 1

        ttk.Label(form_frame, text="OLR Requirement:").grid(row=row, column=0, sticky="w", pady=4)
        self.m_olr_combo = ttk.Combobox(form_frame, values=["0 - No", "1 - Yes"], width=18, state="readonly")
        self.m_olr_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.m_olr_combo.set("0 - No")
        row += 1

        ttk.Label(form_frame, text="Indicator Light Required:").grid(row=row, column=0, sticky="w", pady=4)
        self.m_light_combo = ttk.Combobox(form_frame, values=["0 - No", "1 - Yes"], width=18, state="readonly")
        self.m_light_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.m_light_combo.set("0 - No")
        row += 1

        action_frame = ttk.Frame(self)
        action_frame.pack(pady=5)

        calc_btn = ttk.Button(action_frame, text="Calculate Material List & BOM", command=self.calculate_materials)
        calc_btn.pack(side="left", padx=5)

        export_btn = ttk.Button(action_frame, text="💾 Export BOM to CSV", command=self.export_bom_to_csv)
        export_btn.pack(side="left", padx=5)

        output_frame = ttk.LabelFrame(self, text=" Material Breakdown & BOM ", padding="10")
        output_frame.pack(fill="both", expand=True, padx=15, pady=5)

        self.output_text = tk.Text(output_frame, wrap="none", width=85, height=16, font=("Consolas", 9))

        vsb = ttk.Scrollbar(output_frame, orient="vertical", command=self.output_text.yview)
        hsb = ttk.Scrollbar(output_frame, orient="horizontal", command=self.output_text.xview)
        self.output_text.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)

        self.output_text.grid(row=0, column=0, sticky="nsew")
        vsb.grid(row=0, column=1, sticky="ns")
        hsb.grid(row=1, column=0, sticky="ew")

        output_frame.grid_rowconfigure(0, weight=1)
        output_frame.grid_columnconfigure(0, weight=1)

    def calculate_materials(self):
        try:
            pump_current = float(self.m_current_entry.get().strip())
            num_pumps = int(self.m_pumps_combo.get().strip())
            num_vfd = int(self.m_vfd_combo.get().strip())
            incomer_req = 1 if "1" in self.m_incomer_combo.get() else 0
            door_mount_req = 1 if "1" in self.m_door_mount_combo.get() else 0
            panel_size_lvl = int(self.m_panel_size_combo.get().strip())
            olr_req = 1 if "1" in self.m_olr_combo.get() else 0
            light_req = 1 if "1" in self.m_light_combo.get() else 0
        except ValueError:
            messagebox.showerror("Input Error", "Please ensure all numerical input fields contain valid values.")
            return

        pump_hp = (pump_current * 1.732 * 415 * 0.85) / 746
        total_panel_current = pump_current * num_pumps
        controller_type = "AIPCU OR HMI" if num_vfd > 0 else "DOL/STAR-DELTA"
        mcb_mccb_type = "MCCB" if total_panel_current > 63 else "MCB"
        breaker_qty = 1
        raw_breaker_rating = total_panel_current * 1.25

        fan_qty = 2 if num_vfd > 1 else (1 if num_vfd == 1 else 0)
        filter_qty = fan_qty
        endlock_qty = 4

        self.current_bom = bom_engine.generate_bom(
            controller_type, num_pumps, num_vfd, pump_hp, olr_req, light_req,
            fan_qty, filter_qty, endlock_qty, mcb_mccb_type, breaker_qty,
            raw_breaker_rating, incomer_req, door_mount_req, total_panel_current
        )

        total_material_dp = sum(item["Qty"] * item["DP"] for item in self.current_bom)
        self.current_labor_cost = 500.0 + (num_pumps * 250.0) + (panel_size_lvl * 150.0)
        self.current_grand_total = total_material_dp + self.current_labor_cost

        self.output_text.delete("1.0", tk.END)
        out = []
        out.append(f"{'ITEM NAME':<42} | {'QTY':<4} | {'UNIT DP (Rs.)':<13} | {'TOTAL DP (Rs.)':<13}")
        out.append("-" * 80)

        for item in self.current_bom:
            tot_dp = item["Qty"] * item["DP"]
            out.append(f"{item['Item_Name'][:40]:<42} | {item['Qty']:<4} | {item['DP']:<13,.2f} | {tot_dp:<13,.2f}")

        out.append("-" * 80)
        out.append(f"{'TOTAL MATERIAL COST (DP):':<62} Rs.{total_material_dp:,.2f}")
        out.append(f"{'LABOR & ASSEMBLY COST:':<62} Rs.{self.current_labor_cost:,.2f}")
        out.append(f"{'GRAND TOTAL ESTIMATED COST:':<62} Rs.{self.current_grand_total:,.2f}")

        self.output_text.insert(tk.END, "\n".join(out))

    def export_bom_to_csv(self):
        if not self.current_bom:
            messagebox.showwarning("Export Warning", "No BOM generated to export. Please calculate first.")
            return

        export_file = config.BOM_EXPORT_CSV
        try:
            with open(export_file, mode="w", newline="", encoding="utf-8") as f:
                writer = csv.DictWriter(f, fieldnames=["Item_Name", "Category", "SUB Category", "Capacity", "Qty", "DP"])
                writer.writeheader()
                for item in self.current_bom:
                    writer.writerow(item)
            messagebox.showinfo("Export Success", f"BOM export saved successfully to:\n{export_file}")
        except Exception as e:
            messagebox.showerror("Export Error", f"Could not export BOM CSV: {e}")


class WaterMeterMaterialTab(ttk.Frame):
    """Material and labour calculator for Water Meter configurations."""

    def __init__(self, parent, water_meter_tab=None):
        super().__init__(parent)
        self.water_meter_tab = water_meter_tab
        self.current_bom = []
        self.current_labor_cost = 0.0
        self.current_grand_total = 0.0
        self.build_ui()
        self.load_water_meter_configuration()

    def build_ui(self):
        ttk.Label(self, text="Water Meter Material & Labor Calculator", font=("Helvetica", 14, "bold")).pack(pady=10)

        form_frame = ttk.LabelFrame(self, text=" Water Meter Configuration ", padding="10")
        form_frame.pack(fill="x", padx=15, pady=5)

        self.fields = {}
        field_definitions = [
            ("Device Name", "device_name", "entry"),
            ("Tank Height Position", "tank_position", "combo"),
            ("Solenoid Valve", "solenoid", "combo"),
            ("Sensor Type", "sensor_type", "combo"),
            ("Communication Medium", "communication_medium", "combo"),
            ("Meter Size", "meter_size", "entry"),
        ]
        values = {
            "tank_position": ["Overhead Tank", "Underground Tank", "Ground Level Tank", "Sump Tank"],
            "solenoid": ["Yes", "No"],
            "sensor_type": ["Float Sensor", "Ultrasonic", "Pressure Sensor", "Level Sensor"],
            "communication_medium": ["LoRa", "WiFi", "GSM"],
        }

        for row, (label, key, field_type) in enumerate(field_definitions):
            ttk.Label(form_frame, text=f"{label}:").grid(row=row, column=0, sticky="w", pady=4)
            if field_type == "combo":
                widget = ttk.Combobox(form_frame, values=values[key], width=28, state="readonly")
                widget.current(0)
            else:
                widget = ttk.Entry(form_frame, width=30)
            widget.grid(row=row, column=1, sticky="e", pady=4)
            self.fields[key] = widget

        action_frame = ttk.Frame(self)
        action_frame.pack(pady=5)
        ttk.Button(action_frame, text="Search Price", command=self.search_price).pack(side="left", padx=5)
        ttk.Button(action_frame, text="Calculate Material & Labor", command=self.calculate_materials).pack(side="left", padx=5)
        ttk.Button(action_frame, text="Export BOM to CSV", command=self.export_bom_to_csv).pack(side="left", padx=5)

        self.price_result_label = ttk.Label(self, text="Enter Water Meter details and search for price.", foreground="gray")
        self.price_result_label.pack(pady=(0, 5))

        output_frame = ttk.LabelFrame(self, text=" Water Meter Material Breakdown ", padding="10")
        output_frame.pack(fill="both", expand=True, padx=15, pady=5)
        self.output_text = tk.Text(output_frame, wrap="none", width=90, height=14, font=("Consolas", 9))
        scroll = ttk.Scrollbar(output_frame, orient="vertical", command=self.output_text.yview)
        self.output_text.configure(yscrollcommand=scroll.set)
        self.output_text.pack(side="left", fill="both", expand=True)
        scroll.pack(side="right", fill="y")

    def load_water_meter_configuration(self):
        if not self.water_meter_tab:
            return
        source_widgets = {
            "device_name": self.water_meter_tab.device_name_entry,
            "tank_position": self.water_meter_tab.tank_position_combo,
            "solenoid": self.water_meter_tab.solenoid_combo,
            "sensor_type": self.water_meter_tab.sensor_type_combo,
            "communication_medium": self.water_meter_tab.communication_medium_combo,
            "meter_size": self.water_meter_tab.meter_size_entry,
        }
        for key, source_widget in source_widgets.items():
            target_widget = self.fields[key]
            value = source_widget.get()
            if isinstance(target_widget, ttk.Combobox):
                target_widget.set(value)
            else:
                target_widget.insert(0, value)

    @staticmethod
    def normalize(value):
        return re.sub(r"[^a-z0-9]", "", str(value or "").strip().lower())

    def find_matching_product(self):
        configuration = {key: widget.get().strip() for key, widget in self.fields.items()}
        if not configuration["device_name"] or not configuration["meter_size"]:
            return configuration, None

        product_path = config.WATER_METER_PRODUCTS_CSV
        matched_row = None
        try:
            with open(product_path, newline="", encoding="utf-8-sig") as file:
                for row in csv.DictReader(file):
                    matches = {
                        "device_name": ("device_name", "product_name", "name"),
                        "tank_position": ("tank_height_position", "tank_position", "installation_position"),
                        "solenoid": ("solenoid_valve", "solenoid", "valve"),
                        "sensor_type": ("sensor_type", "sensor", "level_sensor"),
                        "communication_medium": ("communication_medium", "communication", "network"),
                        "meter_size": ("meter_size", "pipe_size", "size", "dn"),
                    }
                    valid = True
                    for key, column_names in matches.items():
                        row_value = next((row.get(name, "") for name in column_names if row.get(name, "") != ""), "")
                        if self.normalize(configuration[key]) != self.normalize(row_value):
                            valid = False
                            break
                    if valid:
                        matched_row = row
                        break
        except (OSError, csv.Error) as error:
            messagebox.showerror("Price Search Error", f"Could not read Water Meter price data:\n{error}", parent=self)
            return configuration, None

        return configuration, matched_row

    def search_price(self):
        configuration, matched_row = self.find_matching_product()
        if not configuration["device_name"] or not configuration["meter_size"]:
            self.price_result_label.config(text="Enter Device Name and Meter Size before searching.", foreground="red")
            return

        if not matched_row:
            self.price_result_label.config(text="No matching Water Meter price found.", foreground="red")
            return

        try:
            material_cost = float(matched_row.get("price", 0) or 0)
        except ValueError:
            material_cost = 0.0

        self.price_result_label.config(text=f"Water Meter Price: Rs.{material_cost:,.2f}", foreground="green")

    def calculate_materials(self):
        configuration, matched_row = self.find_matching_product()
        if not configuration["device_name"] or not configuration["meter_size"]:
            messagebox.showwarning("Input Warning", "Enter Device Name and Meter Size before calculating.", parent=self)
            return

        if not matched_row:
            messagebox.showwarning("No Matching Product", "No Water Meter product matches the selected configuration.", parent=self)
            return

        try:
            material_cost = float(matched_row.get("price", 0) or 0)
        except ValueError:
            material_cost = 0.0

        solenoid_cost = 250.0 if configuration["solenoid"].lower() == "yes" else 0.0
        communication_costs = {"lora": 900.0, "wifi": 500.0, "gsm": 700.0}
        communication_cost = communication_costs.get(self.normalize(configuration["communication_medium"]), 0.0)
        sensor_costs = {"floatsensor": 350.0, "ultrasonic": 1200.0, "pressuresensor": 850.0, "levelsensor": 650.0}
        sensor_cost = sensor_costs.get(self.normalize(configuration["sensor_type"]), 0.0)
        self.current_labor_cost = 750.0 + (250.0 if configuration["solenoid"].lower() == "yes" else 0.0)
        self.current_bom = [
            {"Item_Name": configuration["device_name"], "Category": "Water Meter", "SUB Category": "Meter", "Capacity": configuration["meter_size"], "Qty": 1, "DP": material_cost},
            {"Item_Name": configuration["sensor_type"], "Category": "Water Meter", "SUB Category": "Sensor", "Capacity": "-", "Qty": 1, "DP": sensor_cost},
            {"Item_Name": configuration["communication_medium"], "Category": "Water Meter", "SUB Category": "Communication", "Capacity": "-", "Qty": 1, "DP": communication_cost},
        ]
        if solenoid_cost:
            self.current_bom.append({"Item_Name": "Solenoid Valve", "Category": "Water Meter", "SUB Category": "Valve", "Capacity": "-", "Qty": 1, "DP": solenoid_cost})
        total_material = sum(item["Qty"] * item["DP"] for item in self.current_bom)
        self.current_grand_total = total_material + self.current_labor_cost

        lines = [f"{'ITEM NAME':<32} | {'QTY':<4} | {'UNIT DP (Rs.)':<13} | {'TOTAL DP (Rs.)':<13}", "-" * 70]
        for item in self.current_bom:
            total = item["Qty"] * item["DP"]
            lines.append(f"{item['Item_Name'][:30]:<32} | {item['Qty']:<4} | {item['DP']:<13,.2f} | {total:<13,.2f}")
        lines.extend(["-" * 70, f"{'TOTAL MATERIAL COST:':<50} Rs.{total_material:,.2f}", f"{'LABOR & ASSEMBLY COST:':<50} Rs.{self.current_labor_cost:,.2f}", f"{'GRAND TOTAL ESTIMATED COST:':<50} Rs.{self.current_grand_total:,.2f}"])
        self.output_text.delete("1.0", tk.END)
        self.output_text.insert(tk.END, "\n".join(lines))

    def export_bom_to_csv(self):
        if not self.current_bom:
            messagebox.showwarning("Export Warning", "Calculate the Water Meter BOM first.", parent=self)
            return
        try:
            with open(config.BOM_EXPORT_CSV, "w", newline="", encoding="utf-8") as file:
                writer = csv.DictWriter(file, fieldnames=["Item_Name", "Category", "SUB Category", "Capacity", "Qty", "DP"])
                writer.writeheader()
                writer.writerows(self.current_bom)
            messagebox.showinfo("Export Success", f"BOM export saved successfully to:\n{config.BOM_EXPORT_CSV}", parent=self)
        except OSError as error:
            messagebox.showerror("Export Error", f"Could not export BOM CSV:\n{error}", parent=self)