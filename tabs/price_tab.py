import csv
import math
import os
import re
import tkinter as tk
from tkinter import messagebox, simpledialog, ttk

import bom_engine
import config
import views
from csv_product_manager import CSVProductManagerWindow


class PriceTab(ttk.Frame):
    def __init__(self, parent, main_app, product_category="Booster Pump Control Panel"):
        super().__init__(parent)
        self.main_app = main_app
        self.product_category = product_category
        self.products_csv_path = config.BOOSTER_PRODUCTS_CSV
        self.customers_csv_path = config.BOOSTER_CUSTOMERS_CSV
        self.customer_data = {}
        
        # MCB/MCCB state tracking
        self.mcb_mccb_enabled = False

        self.build_ui()
        self.refresh_customer_list()
        self._bind_configuration_events()

    def build_ui(self):
        if self.product_category == "STP Panel":
            title_text = "STP Panel Price Lookup"
            current_label = "Motor Current (A)"
            pump_label = "Number of Pumps / Stages"
            vfd_label = "Number of Motors"
            bypass_label = "Bypass Required"
        else:
            title_text = "Product Price Lookup"
            current_label = "Pump Current (A)"
            pump_label = "Number of Pumps"
            vfd_label = "Number of VFD"
            bypass_label = "Bypass"

        title = ttk.Label(self, text=title_text, font=("Helvetica", 15, "bold"))
        title.pack(pady=10)

        form_frame = ttk.Frame(self, padding="10")
        form_frame.pack(fill="both", expand=True)

        row = 0

        ttk.Label(form_frame, text="Select Customer: ", font=("Helvetica", 10, "bold")).grid(row=row, column=0, sticky="w", pady=4)
        cust_frame = ttk.Frame(form_frame)
        cust_frame.grid(row=row, column=1, sticky="e", pady=4)

        self.customer_combo = ttk.Combobox(cust_frame, width=17, state="readonly")
        self.customer_combo.pack(side="left", padx=(0, 5))

        add_cust_btn = ttk.Button(cust_frame, text="+ Add Customer", command=self.open_add_customer_window)
        add_cust_btn.pack(side="left", padx=(0, 5))

        open_csv_btn = ttk.Button(cust_frame, text="📊 Open Price List", command=self.open_csv_viewer)
        open_csv_btn.pack(side="left")

        edit_csv_btn = ttk.Button(cust_frame, text="Upload / Edit CSV", command=self.open_csv_manager)
        edit_csv_btn.pack(side="left", padx=(5, 0))

        row += 1
        ttk.Separator(form_frame, orient="horizontal").grid(row=row, column=0, columnspan=2, sticky="ew", pady=8)
        row += 1

        ttk.Label(form_frame, text=f"{current_label}: ").grid(row=row, column=0, sticky="w", pady=4)
        self.current_entry = ttk.Entry(form_frame, width=25)
        self.current_entry.grid(row=row, column=1, sticky="e", pady=4)
        self.current_entry.insert(0, "")
        row += 1

        ttk.Label(form_frame, text=f"{pump_label}: ").grid(row=row, column=0, sticky="w", pady=4)
        self.pumps_combo = ttk.Combobox(form_frame, values=["1", "2", "3", "4", "5"], width=23, state="readonly")
        self.pumps_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.pumps_combo.current(0)
        row += 1

        ttk.Label(form_frame, text=f"{vfd_label}: ").grid(row=row, column=0, sticky="w", pady=4)
        self.vfd_combo = ttk.Combobox(form_frame, values=["0", "1", "2", "3", "4"], width=23, state="readonly")
        self.vfd_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.vfd_combo.current(0)
        row += 1

        ttk.Label(form_frame, text=f"{bypass_label}: ").grid(row=row, column=0, sticky="w", pady=4)
        self.bypass_combo = ttk.Combobox(form_frame, values=["With Bypass", "Without Bypass"], width=23, state="readonly")
        self.bypass_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.bypass_combo.current(0)
        row += 1

        # MCB/MCCB Type Selection
        ttk.Label(form_frame, text="MCB/MCCB Type: ").grid(row=row, column=0, sticky="w", pady=4)
        self.mcb_mccb_type_combo = ttk.Combobox(form_frame, values=["MCB", "MCCB"], width=23, state="disabled")
        self.mcb_mccb_type_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.mcb_mccb_type_combo.current(0)
        row += 1

        # MCB/MCCB Company Selection
        ttk.Label(form_frame, text="MCB/MCCB Company: ").grid(row=row, column=0, sticky="w", pady=4)
        self.mcb_mccb_company_combo = ttk.Combobox(form_frame, 
                                                   values=["Schneider", "Siemens", "ABB", "Legrand", "Havells", "L&T"], 
                                                   width=23, state="disabled")
        self.mcb_mccb_company_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.mcb_mccb_company_combo.set("Schneider")
        row += 1

        ttk.Label(form_frame, text="Panel Type: ").grid(row=row, column=0, sticky="w", pady=4)
        self.panel_type_combo = ttk.Combobox(form_frame, values=["Indoor", "Outdoor"], width=23, state="readonly")
        self.panel_type_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.panel_type_combo.current(0)
        row += 1

        ttk.Label(form_frame, text="Panel Size: ").grid(row=row, column=0, sticky="w", pady=4)
        self.size_combo = ttk.Combobox(form_frame, values=["400x300", "600x400", "800x600", "1000x800", "1200x800"], width=23, state="normal")
        self.size_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.size_combo.current(0)
        row += 1

        ttk.Label(form_frame, text="Panel Class:").grid(row=row, column=0, sticky="w", pady=4)
        self.panel_class_combo = ttk.Combobox(form_frame, values=["Industrial", "Domestic"], width=23, state="readonly")
        self.panel_class_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.panel_class_combo.current(0)
        row += 1

        ttk.Label(form_frame, text="Main Incomer: ").grid(row=row, column=0, sticky="w", pady=4)
        self.main_incomer_combo = ttk.Combobox(form_frame, values=["Yes", "No"], width=23, state="readonly")
        self.main_incomer_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.main_incomer_combo.current(0)
        row += 1

        ttk.Label(form_frame, text="OLR Requirement: ").grid(row=row, column=0, sticky="w", pady=4)
        self.olr_combo = ttk.Combobox(form_frame, values=["Yes", "No"], width=23, state="readonly")
        self.olr_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.olr_combo.current(0)
        row += 1

        ttk.Label(form_frame, text="Indicator Light Required:").grid(row=row, column=0, sticky="w", pady=4)
        self.light_combo = ttk.Combobox(form_frame, values=["Yes", "No"], width=23, state="readonly")
        self.light_combo.grid(row=row, column=1, sticky="e", pady=4)
        self.light_combo.current(0)
        row += 1

        btn_frame = ttk.Frame(self)
        btn_frame.pack(pady=10)

        search_btn = ttk.Button(btn_frame, text="Search Price", command=self.search_price)
        search_btn.pack(side="left", padx=5)

        reload_btn = ttk.Button(btn_frame, text="📁 Reload File Path", command=self.show_file_info)
        reload_btn.pack(side="left", padx=5)

        calc_switch_btn = ttk.Button(btn_frame, text="Open Material Calculator ->", command=lambda: self.main_app.switch_tab(1))
        calc_switch_btn.pack(side="left", padx=5)

        self.result_label = ttk.Label(self, text="Select parameters and click 'Search Price'", font=("Helvetica", 12, "italic"))
        self.result_label.pack(pady=5)

        self.validation_error_label = ttk.Label(self, text="", foreground="red", font=("Helvetica", 9, "bold"))
        self.validation_error_label.pack(pady=2)

        self.config_status_var = tk.StringVar(value="Configuration not ready")
        self.config_status_label = ttk.Label(self, textvariable=self.config_status_var, foreground="orange", font=("Helvetica", 9, "bold"))
        self.config_status_label.pack(pady=(0, 8))

        self.breakdown_label = ttk.Label(self, text="", font=("Helvetica", 9), foreground="gray")
        self.breakdown_label.pack(pady=2)

        self._update_validation_status()

    def _bind_configuration_events(self):
        """Bind events to validate MCB/MCCB configuration based on pump/VFD settings."""
        self.pumps_combo.bind("<<ComboboxSelected>>", lambda e: (self._validate_mcb_mccb_config(), self._update_validation_status()))
        self.vfd_combo.bind("<<ComboboxSelected>>", lambda e: (self._validate_mcb_mccb_config(), self._update_validation_status()))
        self.bypass_combo.bind("<<ComboboxSelected>>", lambda e: (self._validate_mcb_mccb_config(), self._update_validation_status()))
        self.current_entry.bind("<KeyRelease>", lambda e: self._update_validation_status())
        self.size_combo.bind("<<ComboboxSelected>>", lambda e: self._update_validation_status())
        self.size_combo.bind("<KeyRelease>", lambda e: self._update_validation_status())

    def _update_validation_status(self):
        """Show friendly validation feedback for required configuration fields."""
        issues = []

        raw_current = self.current_entry.get().strip()
        if not raw_current:
            issues.append("Pump Current")
        else:
            try:
                current_value = float(raw_current)
                if current_value <= 0:
                    issues.append("Pump Current > 0")
            except ValueError:
                issues.append("Pump Current format")

        if not self.pumps_combo.get().strip():
            issues.append("Number of Pumps")

        if not self.vfd_combo.get().strip():
            issues.append("Number of VFD")

        if not self.bypass_combo.get().strip():
            issues.append("Bypass")

        if not self.panel_type_combo.get().strip():
            issues.append("Panel Type")

        size_value = self.size_combo.get().strip()
        if not size_value:
            issues.append("Panel Size")
        elif not re.fullmatch(r"\d+\s*[xX]\s*\d+", size_value):
            issues.append("Panel Size format")

        if not self.panel_class_combo.get().strip():
            issues.append("Panel Class")

        if not self.main_incomer_combo.get().strip():
            issues.append("Main Incomer")

        if not self.olr_combo.get().strip():
            issues.append("OLR Requirement")

        if not self.light_combo.get().strip():
            issues.append("Indicator Light")

        if issues:
            self.validation_error_label.config(text="Please check: " + ", ".join(issues), foreground="red")
            self.config_status_var.set("Configuration not ready")
            self.config_status_label.config(foreground="orange")
            return False

        self.validation_error_label.config(text="", foreground="red")
        self.config_status_var.set("Configuration Ready")
        self.config_status_label.config(foreground="green")
        return True

    def _validate_mcb_mccb_config(self):
        """
        Validate and update MCB/MCCB configuration based on pump and VFD settings.
        
        Logic:
        1. Enable MCB/MCCB selection after both Pumps and VFD are selected
        2. If Pumps == VFDs, automatically route to "Bypass" mode
        3. If "Without Bypass" is selected, disable contactor (no contactor field needed)
        4. Set MCB/MCCB Company default to Schneider
        """
        try:
            num_pumps = int(self.pumps_combo.get())
            num_vfds = int(self.vfd_combo.get())
            bypass_mode = self.bypass_combo.get()
        except (ValueError, tk.TclError):
            return

        # Enable MCB/MCCB selection after VFD is selected
        if num_pumps > 0 and num_vfds >= 0:
            self.mcb_mccb_type_combo.config(state="readonly")
            self.mcb_mccb_company_combo.config(state="readonly")
            self.mcb_mccb_enabled = True
        else:
            self.mcb_mccb_type_combo.config(state="disabled")
            self.mcb_mccb_company_combo.config(state="disabled")
            self.mcb_mccb_enabled = False

        # Auto-route to Bypass if Pumps == VFDs
        if num_pumps == num_vfds and num_vfds > 0:
            self.bypass_combo.set("With Bypass")
            bypass_mode = "With Bypass"

        # Disable MCB/MCCB if "Without Bypass" is selected
        if bypass_mode == "Without Bypass":
            self.mcb_mccb_type_combo.config(state="disabled")
            self.mcb_mccb_company_combo.config(state="disabled")
            self.mcb_mccb_enabled = False
        elif num_pumps > 0 and num_vfds >= 0:
            # Re-enable if conditions are met
            self.mcb_mccb_type_combo.config(state="readonly")
            self.mcb_mccb_company_combo.config(state="readonly")
            self.mcb_mccb_enabled = True

    def show_file_info(self):
        messagebox.showinfo(
            "Active CSV Storage Folder",
            f"All CSV files are stored in:\n\n{config.CSV_DIR}\n\n"
            f"Active Products CSV:\n{self.products_csv_path}"
        )

    def open_csv_viewer(self):
        views.CSVViewerWindow(self.winfo_toplevel())

    def open_csv_manager(self):
        CSVProductManagerWindow(self.winfo_toplevel())

    def refresh_customer_list(self):
        customers = bom_engine.read_csv_data(self.customers_csv_path)
        self.customer_data = {}
        names = []

        for c in customers:
            name = c.get("customer_name")
            try:
                pct = float(c.get("percentage", 0.0))
            except ValueError:
                pct = 0.0
            if name:
                self.customer_data[name] = pct
                names.append(name)

        if names:
            self.customer_combo["values"] = names
            self.customer_combo.current(0)

    def open_add_customer_window(self):
        views.AddCustomerWindow(self.winfo_toplevel(), self.refresh_customer_list, self.customers_csv_path)

    def search_price(self):
        if not self._update_validation_status():
            messagebox.showwarning("Input Warning", "Please complete all required fields before searching the price.")
            return

        raw_current = self.current_entry.get().strip()
        if not raw_current:
            messagebox.showwarning("Input Warning", "Please enter the Pump Current value.")
            return

        try:
            pump_current = float(raw_current)
            if pump_current <= 0:
                messagebox.showwarning("Input Warning", "Pump Current must be greater than 0.")
                self.validation_error_label.config(text="Pump Current must be greater than 0.", foreground="red")
                return
        except ValueError:
            messagebox.showwarning("Input Warning", "Pump Current must be a valid number in format like 12.5 or 25.")
            self.validation_error_label.config(text="Pump Current must be a valid number in format like 12.5 or 25.", foreground="red")
            return

        def flexible_normalize(val):
            if val is None:
                return ""
            s = str(val).strip().lower()
            if s.endswith(".0"):
                s = s[:-2]
            
            if s in ["1", "true", "yes", "with bypass", "with_bypass", "withbypass"]:
                return "yes_or_with"
            if s in ["0", "false", "no", "without bypass", "without_bypass", "withoutbypass"]:
                return "no_or_without"
            
            return re.sub(r"[^a-z0-9]", "", s)

        num_pumps = flexible_normalize(self.pumps_combo.get())
        num_vfd = flexible_normalize(self.vfd_combo.get())
        bypass = flexible_normalize(self.bypass_combo.get())
        panel_type = flexible_normalize(self.panel_type_combo.get())
        panel_size = flexible_normalize(self.size_combo.get())
        panel_class = flexible_normalize(self.panel_class_combo.get())
        main_incomer = flexible_normalize(self.main_incomer_combo.get())
        olr_required = flexible_normalize(self.olr_combo.get())
        indicator_light = flexible_normalize(self.light_combo.get())

        found_base_price = None

        if os.path.exists(self.products_csv_path):
            try:
                with open(self.products_csv_path, mode="r", encoding="utf-8-sig") as f:
                    reader = list(csv.reader(f))
                    if reader:
                        header_map = {}
                        first_row_norm = [re.sub(r"[^a-z0-9]", "", str(c).lower()) for c in reader[0]]

                        has_header = any(
                            k in first_row_norm
                            for k in ["pumpcurrent", "current", "price", "numpumps", "pumps"]
                        )

                        if has_header:
                            for idx, col_norm in enumerate(first_row_norm):
                                header_map[col_norm] = idx
                            data_rows = reader[1:]
                        else:
                            data_rows = reader

                        def get_val(row, aliases, default_idx):
                            for alias in aliases:
                                norm_alias = re.sub(r"[^a-z0-9]", "", alias.lower())
                                if norm_alias in header_map:
                                    idx = header_map[norm_alias]
                                    if idx < len(row):
                                        return row[idx].strip()
                            if 0 <= default_idx < len(row):
                                return row[default_idx].strip()
                            return ""

                        for r in data_rows:
                            if not r or not any(r):
                                continue

                            try:
                                csv_current_val = get_val(r, ["pump_current", "current", "pump current", "amp"], 0)
                                csv_current = float(csv_current_val)
                            except (ValueError, TypeError):
                                continue

                            csv_pumps = flexible_normalize(get_val(r, ["num_pumps", "pumps", "num pumps"], 1))
                            csv_vfd = flexible_normalize(get_val(r, ["num_vfd", "vfd", "num vfd"], 2))
                            csv_bypass = flexible_normalize(get_val(r, ["bypass"], 3))
                            csv_type = flexible_normalize(get_val(r, ["panel_type", "type", "panel type"], 4))
                            csv_size = flexible_normalize(get_val(r, ["panel_size", "size", "panel size"], 5))
                            csv_class = flexible_normalize(get_val(r, ["panel_class", "class", "panel class"], 6) or "industrial")
                            csv_incomer = flexible_normalize(get_val(r, ["main_incomer", "incomer", "main incomer"], 7) or "yes")
                            csv_olr = flexible_normalize(get_val(r, ["olr_required", "olr", "olr required"], 8) or "no")
                            csv_light = flexible_normalize(get_val(r, ["indicator_light", "indicator", "light"], 9) or "no")

                            price_str = get_val(r, ["price", "base_price", "cost"], len(r) - 1)

                            if (
                                math.isclose(csv_current, pump_current, rel_tol=1e-5)
                                and csv_pumps == num_pumps
                                and csv_vfd == num_vfd
                                and csv_bypass == bypass
                                and csv_type == panel_type
                                and csv_size == panel_size
                                and csv_class == panel_class
                                and csv_incomer == main_incomer
                                and csv_olr == olr_required
                                and csv_light == indicator_light
                            ):
                                try:
                                    found_base_price = float(price_str)
                                except (ValueError, TypeError):
                                    found_base_price = None
                                break
            except PermissionError:
                messagebox.showerror("File Reading Error", "Cannot read 'products.csv'. Please close Excel if it is open.")
                return

        if found_base_price is not None:
            selected_customer = self.customer_combo.get()
            pct_adj = self.customer_data.get(selected_customer, 0.0)
            final_price = found_base_price + (found_base_price * (pct_adj / 100.0))

            # Build MCB/MCCB info string
            mcb_mccb_info = ""
            if self.mcb_mccb_enabled:
                mcb_type = self.mcb_mccb_type_combo.get()
                mcb_company = self.mcb_mccb_company_combo.get()
                mcb_mccb_info = f" | {mcb_type} ({mcb_company})"

            self.result_label.config(
                text=f"Final Price: Rs.{final_price:,.2f}{mcb_mccb_info}",
                foreground="green",
                font=("Helvetica", 14, "bold"),
            )
            sign_str = f"+{pct_adj}%" if pct_adj >= 0 else f"{pct_adj}%"
            self.breakdown_label.config(
                text=f"(Base Price: Rs.{found_base_price:,.2f} | Customer Adj: {sign_str})"
            )
        else:
            self.result_label.config(
                text="Product does not exist",
                foreground="red",
                font=("Helvetica", 13, "bold"),
            )
            self.breakdown_label.config(text="")

            add_new = messagebox.askyesno(
                "Product Not Found",
                "Product does not exist in database.\nWould you like to add a base price for this configuration?",
            )

            if add_new:
                new_price_str = simpledialog.askstring(
                    "Enter Price",
                    "Enter base price for this new configuration:",
                )

                if new_price_str:
                    try:
                        new_price = float(new_price_str.strip())

                        row_to_add = [
                            f"{pump_current:g}",
                            self.pumps_combo.get().strip(),
                            self.vfd_combo.get().strip(),
                            self.bypass_combo.get().strip(),
                            self.panel_type_combo.get().strip(),
                            self.size_combo.get().strip(),
                            self.panel_class_combo.get().strip(),
                            self.main_incomer_combo.get().strip(),
                            self.olr_combo.get().strip(),
                            self.light_combo.get().strip(),
                            f"{new_price:.2f}"
                        ]

                        file_exists = os.path.exists(self.products_csv_path)
                        file_is_empty = not file_exists or os.path.getsize(self.products_csv_path) == 0

                        last_char = b"\n"
                        if file_exists and not file_is_empty:
                            with open(self.products_csv_path, mode="rb") as check_f:
                                check_f.seek(-1, os.SEEK_END)
                                last_char = check_f.read(1)

                        with open(self.products_csv_path, mode="a", newline="", encoding="utf-8-sig") as file:
                            if last_char not in (b"\n", b"\r"):
                                file.write("\n")

                            writer = csv.writer(file)
                            if file_is_empty:
                                writer.writerow(config.PRODUCTS_HEADERS)

                            writer.writerow(row_to_add)

                        selected_customer = self.customer_combo.get()
                        pct_adj = self.customer_data.get(selected_customer, 0.0)
                        final_price = new_price + (new_price * (pct_adj / 100.0))
                        sign_str = f"+{pct_adj}%" if pct_adj >= 0 else f"{pct_adj}%"

                        self.result_label.config(
                            text=f"Final Price: Rs.{final_price:,.2f}",
                            foreground="green",
                            font=("Helvetica", 14, "bold"),
                        )
                        self.breakdown_label.config(
                            text=f"(Base Price: Rs.{new_price:,.2f} | Customer Adj: {sign_str})"
                        )
                        messagebox.showinfo("Success", "New product saved successfully!")

                    except PermissionError:
                        messagebox.showerror(
                            "Permission Error",
                            "Cannot write to 'products.csv'.\nPlease close Excel before saving."
                        )
                    except ValueError:
                        messagebox.showerror("Invalid Input", "Please enter a valid numeric price.")
