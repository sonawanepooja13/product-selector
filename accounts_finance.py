"""Accounts and finance workspace with invoice-based inward entries."""

import csv
import os
import re
import shutil
import tkinter as tk
from datetime import date, datetime
from tkinter import filedialog, messagebox, ttk

import config
from openpyxl import Workbook
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle
from xml.sax.saxutils import escape
from tkcalendar import DateEntry
from outward_window import OutwardWindow
from vendor_registration import VendorRegistrationWindow


DEPARTMENTS = ("Production", "R&D", "Panel Department", "Office", "Sales", "Marketing", "Other")
INWARD_HEADERS = ["date", "supplier", "invoice_no", "department", "item_description", "quantity", "rate", "amount", "payment_status", "payment_method", "cheque_date", "cheque_number", "cheque_photo", "notes"]
INWARD_CSV = os.path.join(config.CSV_DIR, "inward_entries.csv")
PAYMENTS_CSV = os.path.join(config.CSV_DIR, "invoice_payments.csv")
PAYMENT_HEADERS = ["payment_date", "supplier", "invoice_no", "amount", "payment_method"]
PRODUCT_CATALOG_CSV = os.path.join(config.SCRIPT_DIR, "price_list_clean.csv")
CHEQUE_PHOTOS_DIR = os.path.join(config.SCRIPT_DIR, "cheque_photos")
INWARD_OUTPUT_DIR = os.path.join(config.SCRIPT_DIR, "inward_invoices")


def ensure_inward_file():
    """Create the register or add the department column to old data."""
    if not os.path.exists(INWARD_CSV):
        with open(INWARD_CSV, "w", newline="", encoding="utf-8") as file:
            csv.DictWriter(file, fieldnames=INWARD_HEADERS).writeheader()
        return
    with open(INWARD_CSV, newline="", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        old_headers, rows = reader.fieldnames or [], list(reader)
    if any(header not in old_headers for header in INWARD_HEADERS):
        for row in rows:
            for header in INWARD_HEADERS:
                row.setdefault(header, "")
        with open(INWARD_CSV, "w", newline="", encoding="utf-8") as file:
            writer = csv.DictWriter(file, fieldnames=INWARD_HEADERS)
            writer.writeheader()
            writer.writerows(rows)


def ensure_payments_file():
    if not os.path.exists(PAYMENTS_CSV):
        with open(PAYMENTS_CSV, "w", newline="", encoding="utf-8") as file:
            csv.DictWriter(file, fieldnames=PAYMENT_HEADERS).writeheader()


def get_invoice_balances():
    """Return invoice totals, recorded payments, and current balances."""
    ensure_inward_file()
    ensure_payments_file()
    invoices = {}
    with open(INWARD_CSV, newline="", encoding="utf-8") as file:
        for row in csv.DictReader(file):
            key = (row.get("supplier", ""), row.get("invoice_no", ""))
            if not all(key):
                continue
            try:
                amount = float(row.get("amount", 0) or 0)
            except ValueError:
                amount = 0.0
            invoice = invoices.setdefault(key, {"supplier": key[0], "invoice_no": key[1], "department": row.get("department", ""), "total": 0.0, "paid": 0.0, "status": row.get("payment_status", "Pending")})
            invoice["total"] += amount
    with open(PAYMENTS_CSV, newline="", encoding="utf-8") as file:
        for row in csv.DictReader(file):
            invoice = invoices.get((row.get("supplier", ""), row.get("invoice_no", "")))
            if not invoice:
                continue
            try:
                invoice["paid"] += float(row.get("amount", 0) or 0)
            except ValueError:
                pass
    for invoice in invoices.values():
        if invoice["status"] == "Paid" and invoice["paid"] == 0:
            invoice["paid"] = invoice["total"]
        invoice["paid"] = min(invoice["paid"], invoice["total"])
        invoice["balance"] = max(invoice["total"] - invoice["paid"], 0.0)
    return list(invoices.values())


class InvoicePaymentDialog(tk.Toplevel):
    def __init__(self, parent, invoice, on_saved):
        super().__init__(parent)
        self.invoice, self.on_saved = invoice, on_saved
        self.title("Pay Pending Invoice")
        self.minsize(360, 300)
        self.resizable(True, True)
        self.transient(parent.winfo_toplevel())
        self.grab_set()
        self.amount_var = tk.StringVar(value=f"{invoice['balance']:.2f}")
        self.method_var = tk.StringVar(value="Account Pay")
        form = ttk.Frame(self, padding=16)
        form.pack(fill="both", expand=True)
        for label, value in (("Vendor", invoice["supplier"]), ("Invoice No.", invoice["invoice_no"]), ("Pending Balance", f"{invoice['balance']:,.2f}")):
            ttk.Label(form, text=f"{label}:").pack(anchor="w", pady=(0, 2))
            ttk.Label(form, text=value, font=("Helvetica", 10, "bold")).pack(anchor="w", pady=(0, 8))
        ttk.Label(form, text="Payment Amount:").pack(anchor="w")
        ttk.Entry(form, textvariable=self.amount_var, width=28).pack(anchor="w", pady=(2, 8))
        ttk.Label(form, text="Payment Method:").pack(anchor="w")
        ttk.Combobox(form, textvariable=self.method_var, values=("Hard Cash", "Account Pay", "Cheque"), state="readonly", width=25).pack(anchor="w", pady=(2, 12))
        actions = ttk.Frame(form)
        actions.pack(fill="x")
        ttk.Button(actions, text="Cancel", command=self.destroy).pack(side="right")
        ttk.Button(actions, text="Save Payment", command=self.save).pack(side="right", padx=(0, 8))

    def save(self):
        try:
            amount = float(self.amount_var.get())
            if amount <= 0 or amount > self.invoice["balance"] + 0.0001:
                raise ValueError
        except ValueError:
            messagebox.showwarning("Payment Amount", "Enter an amount greater than zero and not more than the pending balance.", parent=self)
            return
        ensure_payments_file()
        with open(PAYMENTS_CSV, "a", newline="", encoding="utf-8") as file:
            csv.DictWriter(file, fieldnames=PAYMENT_HEADERS).writerow({"payment_date": date.today().isoformat(), "supplier": self.invoice["supplier"], "invoice_no": self.invoice["invoice_no"], "amount": f"{amount:.2f}", "payment_method": self.method_var.get()})
        self.on_saved()
        self.destroy()
        messagebox.showinfo("Payment Saved", "Payment saved and pending balance updated.", parent=self.master)


def load_product_catalog():
    """Load selectable existing products from the maintained CSV price list."""
    if not os.path.exists(PRODUCT_CATALOG_CSV):
        return {}
    catalog = {}
    with open(PRODUCT_CATALOG_CSV, newline="", encoding="utf-8-sig") as file:
        for row in csv.DictReader(file):
            item = (row.get("Item Name") or "").strip()
            if not item:
                continue
            capacity = (row.get("CAPACITY") or "").strip()
            unit = (row.get("Unit") or "").strip()
            supplier = (row.get("Supplier") or "").strip()
            label = f"{item} | {capacity} {unit} | {supplier}".strip()
            catalog[label] = row
    return catalog


def safe_file_part(value):
    """Make a vendor or cheque number safe for a Windows file name."""
    return re.sub(r'[<>:"/\\|?*]+', "_", value).strip(" ._") or "unknown"


def load_vendor_names():
    """Vendor selection is deliberately limited to the registered vendor master."""
    from vendor_registration import VENDOR_CSV, ensure_vendor_file
    ensure_vendor_file()
    with open(VENDOR_CSV, newline="", encoding="utf-8-sig") as file:
        return sorted({(row.get("vendor_legal_name") or "").strip() for row in csv.DictReader(file) if (row.get("vendor_legal_name") or "").strip()}, key=str.casefold)


class ChequeDetailsWindow(ttk.Frame):
    """Search the saved cheque register by vendor, invoice, or cheque number."""

    def __init__(self, parent, on_complete=None):
        super().__init__(parent)
        self.on_complete = on_complete or (lambda: None)
        self.search_var = tk.StringVar()
        self.start_date_var = tk.StringVar()
        self.end_date_var = tk.StringVar()
        self.filtered_records = []
        self._build()
        self.load_cheques()

    def _build(self):
        top = ttk.Frame(self, padding=12)
        top.pack(fill="x")
        ttk.Label(top, text="Search Vendor / Invoice / Cheque No.:").pack(side="left")
        search = ttk.Entry(top, textvariable=self.search_var, width=40)
        search.pack(side="left", padx=8)
        search.bind("<KeyRelease>", lambda _event: self.load_cheques())
        ttk.Label(top, text="Cheque Date From:").pack(side="left", padx=(12, 5))
        DateEntry(top, textvariable=self.start_date_var, width=12, date_pattern="yyyy-mm-dd").pack(side="left")
        ttk.Label(top, text="To:").pack(side="left", padx=(8, 5))
        DateEntry(top, textvariable=self.end_date_var, width=12, date_pattern="yyyy-mm-dd").pack(side="left")
        ttk.Button(top, text="Apply Dates", command=self.apply_date_filter).pack(side="left", padx=8)
        ttk.Button(top, text="Export Excel", command=self.export_excel).pack(side="right")
        ttk.Button(top, text="Open Selected Photo", command=self.open_selected_photo).pack(side="right")
        ttk.Button(top, text="Back", command=self.on_complete).pack(side="right", padx=(0, 8))
        box = ttk.Frame(self, padding=(12, 0, 12, 12))
        box.pack(fill="both", expand=True)
        columns = ("supplier", "invoice", "date", "department", "cheque_date", "cheque_number", "photo")
        headings = ("Vendor", "Invoice", "Entry Date", "Department", "Cheque Date", "Cheque Number", "Photo File")
        self.tree = ttk.Treeview(box, columns=columns, show="headings", selectmode="browse")
        for column, heading in zip(columns, headings):
            self.tree.heading(column, text=heading)
            self.tree.column(column, width=160 if column in ("supplier", "photo") else 110, anchor="w")
        scroll = ttk.Scrollbar(box, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=scroll.set)
        self.tree.pack(side="left", fill="both", expand=True)
        scroll.pack(side="right", fill="y")

    def load_cheques(self):
        for item in self.tree.get_children():
            self.tree.delete(item)
        self.filtered_records = []
        query = self.search_var.get().strip().casefold()
        start_date = self.start_date_var.get().strip()
        end_date = self.end_date_var.get().strip()
        if not os.path.exists(INWARD_CSV):
            return
        with open(INWARD_CSV, newline="", encoding="utf-8") as file:
            for index, row in enumerate(csv.DictReader(file)):
                if row.get("payment_method") != "Cheque":
                    continue
                searchable = " ".join((row.get("supplier", ""), row.get("invoice_no", ""), row.get("cheque_number", ""))).casefold()
                if query and query not in searchable:
                    continue
                cheque_date = row.get("cheque_date", "")
                if start_date and cheque_date < start_date:
                    continue
                if end_date and cheque_date > end_date:
                    continue
                self.filtered_records.append(row)
                self.tree.insert("", "end", iid=str(index), values=(row.get("supplier", ""), row.get("invoice_no", ""), row.get("date", ""), row.get("department", ""), row.get("cheque_date", ""), row.get("cheque_number", ""), row.get("cheque_photo", "")))

    def apply_date_filter(self):
        start_date = self.start_date_var.get().strip()
        end_date = self.end_date_var.get().strip()
        try:
            if start_date:
                datetime.strptime(start_date, "%Y-%m-%d")
            if end_date:
                datetime.strptime(end_date, "%Y-%m-%d")
            if start_date and end_date and start_date > end_date:
                raise ValueError
        except ValueError:
            messagebox.showwarning("Date Range", "Use YYYY-MM-DD dates, with the start date before the end date.", parent=self)
            return False
        self.load_cheques()
        return True

    def export_excel(self):
        if not self.apply_date_filter():
            return
        if not self.filtered_records:
            messagebox.showwarning("No Cheques", "There are no cheque records in the selected date range.", parent=self)
            return
        start_date = self.start_date_var.get().strip() or "all"
        end_date = self.end_date_var.get().strip() or "all"
        path = filedialog.asksaveasfilename(
            parent=self, title="Save Cheque Details Excel",
            defaultextension=".xlsx", initialfile=f"cheque_details_{start_date}_to_{end_date}.xlsx",
            filetypes=(("Excel workbook", "*.xlsx"),),
        )
        if not path:
            return
        try:
            workbook = Workbook()
            sheet = workbook.active
            sheet.title = "Cheque Details"
            headings = ("Vendor", "Invoice No.", "Entry Date", "Department", "Cheque Date", "Cheque Number", "Payment Status", "Cheque Photo Path")
            sheet.append(headings)
            for cell in sheet[1]:
                cell.font = cell.font.copy(bold=True)
            for row in self.filtered_records:
                sheet.append((row.get("supplier", ""), row.get("invoice_no", ""), row.get("date", ""), row.get("department", ""), row.get("cheque_date", ""), row.get("cheque_number", ""), row.get("payment_status", ""), row.get("cheque_photo", "")))
            for column in sheet.columns:
                sheet.column_dimensions[column[0].column_letter].width = min(max(len(str(cell.value or "")) for cell in column) + 2, 45)
            workbook.save(path)
            messagebox.showinfo("Exported", f"Cheque details Excel file saved successfully.\n\n{path}", parent=self)
        except Exception as error:
            messagebox.showerror("Export Failed", f"Could not export the Excel file:\n{error}", parent=self)

    def open_selected_photo(self):
        selected = self.tree.selection()
        if not selected:
            messagebox.showwarning("Select Cheque", "Select a cheque record first.", parent=self)
            return
        photo_path = self.tree.item(selected[0], "values")[6]
        if not photo_path or not os.path.exists(photo_path):
            messagebox.showwarning("Photo Not Found", "The cheque photo file is not available.", parent=self)
            return
        os.startfile(photo_path)


class InwardEntryDialog(ttk.Frame):
    """Records an invoice header and multiple products under the invoice."""

    def __init__(self, parent, on_saved, on_cancel=None, on_register_vendor=None):
        super().__init__(parent)
        self.on_saved, self.items = on_saved, []
        self.on_cancel = on_cancel or on_saved
        self.on_register_vendor = on_register_vendor
        self.header = {"date": tk.StringVar(value=date.today().isoformat()), "supplier": tk.StringVar(), "invoice_no": tk.StringVar(), "department": tk.StringVar(), "payment_status": tk.StringVar(value="Pending"), "payment_method": tk.StringVar(value="Hard Cash"), "cheque_date": tk.StringVar(), "cheque_number": tk.StringVar(), "cheque_photo": tk.StringVar()}
        self.vendor_names = load_vendor_names()
        self.item = {"item_description": tk.StringVar(), "quantity": tk.StringVar(value="1"), "rate": tk.StringVar(value="0")}
        self.catalog = load_product_catalog()
        self.catalog_labels = list(self.catalog)
        self.catalog_var = tk.StringVar()
        self.total_var = tk.StringVar(value="0.00")
        self._build()

    def _build(self):
        form = ttk.Frame(self, padding=16)
        form.pack(fill="both", expand=True)
        form.columnconfigure(0, weight=1)
        form.rowconfigure(3, weight=1)

        details = ttk.LabelFrame(form, text=" Invoice Details ", padding=10)
        details.grid(row=0, column=0, sticky="ew")
        for column in (1, 3):
            details.columnconfigure(column, weight=1)
        for index, (label, key) in enumerate((("Date (YYYY-MM-DD)", "date"), ("Supplier", "supplier"), ("Invoice / Challan No.", "invoice_no"), ("Department", "department"))):
            row, group = divmod(index, 2)
            column = group * 2
            ttk.Label(details, text=f"{label}:").grid(row=row, column=column, sticky="w", padx=(0, 8), pady=5)
            if key == "department":
                widget = ttk.Combobox(details, textvariable=self.header[key], values=DEPARTMENTS, state="readonly")
            elif key == "supplier":
                supplier_frame = ttk.Frame(details)
                supplier_frame.grid(row=row, column=column + 1, sticky="ew", padx=(0, 16), pady=5)
                supplier_frame.columnconfigure(0, weight=1)
                self.supplier_combo = ttk.Combobox(supplier_frame, textvariable=self.header[key], values=self.vendor_names, state="readonly")
                self.supplier_combo.grid(row=0, column=0, sticky="ew")
                ttk.Button(supplier_frame, text="+ Add Vendor", command=self.add_vendor).grid(row=0, column=1, padx=(6, 0))
                continue
            elif key == "date":
                widget = DateEntry(details, textvariable=self.header[key], date_pattern="yyyy-mm-dd")
            else:
                widget = ttk.Entry(details, textvariable=self.header[key])
            widget.grid(row=row, column=column + 1, sticky="ew", padx=(0, 16), pady=5)

        product = ttk.LabelFrame(form, text=" Add Product to This Invoice ", padding=10)
        product.grid(row=1, column=0, sticky="ew", pady=(12, 0))
        product.columnconfigure(1, weight=1)
        ttk.Label(product, text="Product / Material:").grid(row=0, column=0, sticky="w", padx=(0, 8))
        ttk.Entry(product, textvariable=self.item["item_description"]).grid(row=0, column=1, sticky="ew")
        ttk.Label(product, text="Qty:").grid(row=0, column=2, padx=(12, 5))
        ttk.Entry(product, textvariable=self.item["quantity"], width=9).grid(row=0, column=3)
        ttk.Label(product, text="Rate:").grid(row=0, column=4, padx=(12, 5))
        ttk.Entry(product, textvariable=self.item["rate"], width=12).grid(row=0, column=5)
        ttk.Button(product, text="Add Product", command=self.add_product).grid(row=0, column=6, padx=(12, 0))
        ttk.Label(product, text="Existing Product:").grid(row=1, column=0, sticky="w", pady=(10, 0))
        self.catalog_combo = ttk.Combobox(product, textvariable=self.catalog_var, values=self.catalog_labels[:5], width=70, height=5)
        self.catalog_combo.grid(row=1, column=1, columnspan=4, sticky="ew", pady=(10, 0))
        self.catalog_combo.bind("<<ComboboxSelected>>", self.use_existing_product)
        self.catalog_combo.bind("<KeyRelease>", self.filter_existing_products)
        ttk.Button(product, text="Use Selected Product", command=self.use_existing_product).grid(row=1, column=5, columnspan=2, padx=(12, 0), pady=(10, 0))
        self.matches_list = tk.Listbox(product, height=5, exportselection=False)
        self.matches_list.grid(row=2, column=1, columnspan=4, sticky="ew", pady=(4, 0))
        self.matches_list.grid_remove()
        self.matches_list.bind("<<ListboxSelect>>", self.select_product_match)

        ttk.Label(form, text="Products in this invoice:", font=("Helvetica", 10, "bold")).grid(row=2, column=0, sticky="w", pady=(12, 4))
        box = ttk.Frame(form)
        box.grid(row=3, column=0, sticky="nsew")
        columns = ("item", "quantity", "rate", "amount")
        self.items_tree = ttk.Treeview(box, columns=columns, show="headings", height=8)
        for col, heading, width in (("item", "Product / Material", 430), ("quantity", "Qty", 90), ("rate", "Rate", 110), ("amount", "Amount", 120)):
            self.items_tree.heading(col, text=heading)
            self.items_tree.column(col, width=width, anchor="w" if col == "item" else "e")
        scroll = ttk.Scrollbar(box, orient="vertical", command=self.items_tree.yview)
        self.items_tree.configure(yscrollcommand=scroll.set)
        self.items_tree.pack(side="left", fill="both", expand=True)
        scroll.pack(side="right", fill="y")

        actions = ttk.Frame(form)
        actions.grid(row=4, column=0, sticky="ew", pady=(7, 10))
        ttk.Button(actions, text="Remove Selected Product", command=self.remove_selected_product).pack(side="left")
        ttk.Label(actions, textvariable=self.total_var, font=("Helvetica", 11, "bold")).pack(side="right")
        ttk.Label(actions, text="Invoice Total:", font=("Helvetica", 10, "bold")).pack(side="right", padx=(0, 6))

        footer = ttk.LabelFrame(form, text=" Payment and Notes ", padding=10)
        footer.grid(row=5, column=0, sticky="ew")
        footer.columnconfigure(3, weight=1)
        ttk.Label(footer, text="Payment Status:").grid(row=0, column=0, sticky="w", padx=(0, 8))
        ttk.Combobox(footer, textvariable=self.header["payment_status"], values=("Pending", "Paid", "Partial"), state="readonly", width=14).grid(row=0, column=1, sticky="w")
        ttk.Label(footer, text="Payment Method:").grid(row=0, column=2, sticky="w", padx=(18, 8))
        payment_combo = ttk.Combobox(footer, textvariable=self.header["payment_method"], values=("Hard Cash", "Account Pay", "Cheque"), state="readonly", width=16)
        payment_combo.grid(row=0, column=3, sticky="w")
        payment_combo.bind("<<ComboboxSelected>>", self.toggle_cheque_fields)
        self.cheque_frame = ttk.Frame(footer)
        self.cheque_frame.grid(row=1, column=0, columnspan=4, sticky="ew", pady=(10, 0))
        self.cheque_frame.columnconfigure(5, weight=1)
        ttk.Label(self.cheque_frame, text="Cheque Date:").grid(row=0, column=0, sticky="w", padx=(0, 6))
        DateEntry(self.cheque_frame, textvariable=self.header["cheque_date"], width=14, date_pattern="yyyy-mm-dd").grid(row=0, column=1, sticky="w")
        ttk.Label(self.cheque_frame, text="Cheque Number:").grid(row=0, column=2, sticky="w", padx=(16, 6))
        ttk.Entry(self.cheque_frame, textvariable=self.header["cheque_number"], width=18).grid(row=0, column=3, sticky="w")
        ttk.Label(self.cheque_frame, text="Cheque Photo:").grid(row=1, column=0, sticky="w", pady=(8, 0))
        ttk.Entry(self.cheque_frame, textvariable=self.header["cheque_photo"], state="readonly").grid(row=1, column=1, columnspan=4, sticky="ew", pady=(8, 0))
        ttk.Button(self.cheque_frame, text="Attach Photo", command=self.choose_cheque_photo).grid(row=1, column=5, padx=(8, 0), pady=(8, 0))
        ttk.Button(self.cheque_frame, text="Capture from Camera", command=self.capture_cheque_photo).grid(row=1, column=6, padx=(8, 0), pady=(8, 0))
        ttk.Label(footer, text="Notes:").grid(row=2, column=0, sticky="nw", pady=(10, 0))
        self.notes = tk.Text(footer, height=3)
        self.notes.grid(row=2, column=1, columnspan=3, sticky="ew", pady=(10, 0))
        buttons = ttk.Frame(footer)
        buttons.grid(row=3, column=0, columnspan=4, sticky="e", pady=(10, 0))
        ttk.Button(buttons, text="Cancel", command=self.on_cancel).pack(side="right")
        ttk.Button(buttons, text="Save Invoice", command=self.save).pack(side="right", padx=(0, 8))
        self.toggle_cheque_fields()

    def add_vendor(self):
        if self.on_register_vendor:
            self.on_register_vendor()

    def vendor_added(self, vendor_name):
        self.vendor_names = load_vendor_names()
        self.supplier_combo["values"] = self.vendor_names
        self.header["supplier"].set(vendor_name)

    def add_product(self):
        product = self.item["item_description"].get().strip()
        try:
            quantity, rate = float(self.item["quantity"].get()), float(self.item["rate"].get())
            if quantity <= 0 or rate < 0:
                raise ValueError
        except ValueError:
            messagebox.showwarning("Invalid Product", "Enter a product, a quantity greater than zero, and a valid rate.", parent=self)
            return
        if not product:
            messagebox.showwarning("Missing Product", "Enter a product or material description.", parent=self)
            return
        self.items.append({"item_description": product, "quantity": quantity, "rate": rate, "amount": quantity * rate})
        self.item["item_description"].set("")
        self.item["quantity"].set("1")
        self.item["rate"].set("0")
        self.refresh_items()

    def use_existing_product(self, _event=None):
        product = self.catalog.get(self.catalog_var.get())
        if not product:
            messagebox.showwarning("Select Product", "Select an existing product from the list first.", parent=self)
            return
        capacity = " ".join(part for part in (product.get("CAPACITY", "").strip(), product.get("Unit", "").strip()) if part)
        self.item["item_description"].set(f"{product.get('Item Name', '').strip()} {capacity}".strip())
        price = (product.get("DP") or product.get("List Price") or "").replace(",", "").strip()
        if price:
            self.item["rate"].set(price)

    def filter_existing_products(self, event=None):
        """Show up to five matching products while the user types."""
        if event and event.keysym in ("Up", "Down", "Return", "Escape", "Tab"):
            return
        search = self.catalog_var.get().strip().casefold()
        matches = [label for label in self.catalog_labels if search in label.casefold()][:5]
        self.catalog_combo["values"] = matches
        if matches and search:
            self.matches_list.delete(0, tk.END)
            for label in matches:
                self.matches_list.insert(tk.END, label)
            self.matches_list.grid()
        else:
            self.matches_list.grid_remove()

    def select_product_match(self, _event=None):
        selected = self.matches_list.curselection()
        if not selected:
            return
        self.catalog_var.set(self.matches_list.get(selected[0]))
        self.matches_list.grid_remove()
        self.use_existing_product()

    def toggle_cheque_fields(self, _event=None):
        if self.header["payment_method"].get() == "Cheque":
            self.cheque_frame.grid()
        else:
            self.cheque_frame.grid_remove()

    def choose_cheque_photo(self):
        path = filedialog.askopenfilename(
            parent=self, title="Attach Cheque Photo",
            filetypes=(("Image files", "*.png *.jpg *.jpeg *.bmp"), ("All files", "*.*")),
        )
        if path:
            self.header["cheque_photo"].set(path)

    def capture_cheque_photo(self):
        """Capture a cheque image from the default PC camera using OpenCV."""
        try:
            import cv2
        except ImportError:
            messagebox.showerror("Camera Unavailable", "Camera support is not installed. Please install OpenCV first.", parent=self)
            return
        camera = cv2.VideoCapture(0)
        if not camera.isOpened():
            camera.release()
            messagebox.showerror("Camera Unavailable", "Could not open the PC camera. Check that the camera is connected and Windows camera permission is enabled.", parent=self)
            return
        captured_path = ""
        try:
            while True:
                success, frame = camera.read()
                if not success:
                    messagebox.showerror("Camera Error", "Could not receive an image from the camera.", parent=self)
                    break
                cv2.putText(frame, "Press SPACE to capture cheque | ESC to cancel", (12, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (0, 255, 0), 2)
                cv2.imshow("Capture Cheque Photo", frame)
                key = cv2.waitKey(1) & 0xFF
                if key == 32:
                    capture_dir = os.path.join(CHEQUE_PHOTOS_DIR, "camera_captures")
                    os.makedirs(capture_dir, exist_ok=True)
                    captured_path = os.path.join(capture_dir, f"captured_cheque_{datetime.now():%Y%m%d_%H%M%S_%f}.png")
                    cv2.imwrite(captured_path, frame)
                    break
                if key == 27:
                    break
        finally:
            camera.release()
            cv2.destroyAllWindows()
        if captured_path:
            self.header["cheque_photo"].set(captured_path)
            messagebox.showinfo("Cheque Captured", "Cheque photo captured and attached to this invoice.", parent=self)

    def remove_selected_product(self):
        selected = self.items_tree.selection()
        if not selected:
            messagebox.showwarning("Select Product", "Select a product line to remove.", parent=self)
            return
        del self.items[int(selected[0])]
        self.refresh_items()

    def refresh_items(self):
        for row_id in self.items_tree.get_children():
            self.items_tree.delete(row_id)
        total = 0.0
        for index, item in enumerate(self.items):
            total += item["amount"]
            self.items_tree.insert("", "end", iid=str(index), values=(item["item_description"], f"{item['quantity']:g}", f"{item['rate']:.2f}", f"{item['amount']:.2f}"))
        self.total_var.set(f"{total:,.2f}")

    def save(self):
        if any(not self.header[key].get().strip() for key in ("supplier", "invoice_no", "department")):
            messagebox.showwarning("Missing Details", "Supplier, invoice/challan number, and department are required.", parent=self)
            return
        if not self.items:
            messagebox.showwarning("No Products", "Add at least one product to this invoice.", parent=self)
            return
        cheque_photo = ""
        if self.header["payment_method"].get() == "Cheque":
            cheque_date = self.header["cheque_date"].get().strip()
            cheque_number = self.header["cheque_number"].get().strip()
            photo_path = self.header["cheque_photo"].get().strip()
            if not cheque_date or not cheque_number or not photo_path:
                messagebox.showwarning("Cheque Details", "Cheque date, cheque number, and cheque photo are required.", parent=self)
                return
            if not os.path.exists(photo_path):
                messagebox.showwarning("Cheque Photo", "The selected cheque photo could not be found.", parent=self)
                return
            try:
                vendor_folder = os.path.join(CHEQUE_PHOTOS_DIR, safe_file_part(self.header["supplier"].get()))
                os.makedirs(vendor_folder, exist_ok=True)
                extension = os.path.splitext(photo_path)[1]
                cheque_photo = os.path.join(vendor_folder, f"{safe_file_part(self.header['supplier'].get())}_{safe_file_part(cheque_number)}_{cheque_date}_{datetime.now():%Y%m%d_%H%M%S}{extension}")
                shutil.copy2(photo_path, cheque_photo)
            except OSError as error:
                messagebox.showerror("Cheque Photo", f"Could not save the cheque photo:\n{error}", parent=self)
                return
        ensure_inward_file()
        notes = self.notes.get("1.0", "end-1c").strip()
        with open(INWARD_CSV, "a", newline="", encoding="utf-8") as file:
            writer = csv.DictWriter(file, fieldnames=INWARD_HEADERS)
            for item in self.items:
                writer.writerow({"date": self.header["date"].get().strip(), "supplier": self.header["supplier"].get().strip(), "invoice_no": self.header["invoice_no"].get().strip(), "department": self.header["department"].get().strip(), "item_description": item["item_description"], "quantity": f"{item['quantity']:g}", "rate": f"{item['rate']:.2f}", "amount": f"{item['amount']:.2f}", "payment_status": self.header["payment_status"].get(), "payment_method": self.header["payment_method"].get(), "cheque_date": self.header["cheque_date"].get().strip() if cheque_photo else "", "cheque_number": self.header["cheque_number"].get().strip() if cheque_photo else "", "cheque_photo": cheque_photo, "notes": notes})
        try:
            output_dir = self.generate_invoice_files(notes)
        except Exception as error:
            messagebox.showerror("Invoice Saved", f"The inward invoice was saved, but its PDF and Excel files could not be generated:\n{error}", parent=self)
            self.on_saved()
            return
        messagebox.showinfo("Saved", f"Invoice saved with {len(self.items)} product line(s).\n\nPDF and Excel files created in:\n{output_dir}", parent=self)
        self.on_saved()

    def generate_invoice_files(self, notes):
        """Create one Excel workbook and one printable PDF for this new invoice."""
        invoice_no = self.header["invoice_no"].get().strip()
        base_name = safe_file_part(f"Inward_Invoice_{invoice_no}_{datetime.now():%Y%m%d_%H%M%S}")
        output_dir = os.path.join(INWARD_OUTPUT_DIR, base_name)
        os.makedirs(output_dir, exist_ok=True)
        workbook = Workbook()
        sheet = workbook.active
        sheet.title = "Inward Invoice"
        sheet.append(("Date", self.header["date"].get().strip()))
        sheet.append(("Vendor", self.header["supplier"].get().strip()))
        sheet.append(("Invoice / Challan No.", invoice_no))
        sheet.append(("Department", self.header["department"].get().strip()))
        sheet.append(())
        sheet.append(("No.", "Product / Material", "Qty", "Rate", "Amount"))
        for index, item in enumerate(self.items, 1):
            sheet.append((index, item["item_description"], item["quantity"], item["rate"], item["amount"]))
        sheet.append(("", "", "", "Total", sum(item["amount"] for item in self.items)))
        sheet.append(())
        sheet.append(("Notes", notes))
        for cell in sheet[6]:
            cell.font = cell.font.copy(bold=True)
        for column in sheet.columns:
            sheet.column_dimensions[column[0].column_letter].width = min(max(len(str(cell.value or "")) for cell in column) + 2, 48)
        workbook.save(os.path.join(output_dir, f"{base_name}.xlsx"))
        styles = getSampleStyleSheet()
        pdf = SimpleDocTemplate(os.path.join(output_dir, f"{base_name}.pdf"), pagesize=A4, rightMargin=14 * mm, leftMargin=14 * mm, topMargin=14 * mm)
        story = [Paragraph("Inward Invoice", styles["Title"]), Spacer(1, 5 * mm), Paragraph(
            f"<b>Date:</b> {escape(self.header['date'].get())}<br/><b>Vendor:</b> {escape(self.header['supplier'].get())}<br/><b>Invoice / Challan No.:</b> {escape(invoice_no)}<br/><b>Department:</b> {escape(self.header['department'].get())}", styles["Normal"]), Spacer(1, 5 * mm)]
        table_data = [["No.", "Product / Material", "Qty", "Rate", "Amount"]]
        for index, item in enumerate(self.items, 1):
            table_data.append((str(index), item["item_description"], f"{item['quantity']:g}", f"{item['rate']:.2f}", f"{item['amount']:.2f}"))
        table_data.append(("", "", "", "Total", f"{sum(item['amount'] for item in self.items):.2f}"))
        table = Table(table_data, colWidths=(12 * mm, 88 * mm, 18 * mm, 28 * mm, 28 * mm))
        table.setStyle(TableStyle([("GRID", (0, 0), (-1, -1), 0.5, colors.black), ("BACKGROUND", (0, 0), (-1, 0), colors.lightgrey), ("ALIGN", (2, 1), (-1, -1), "RIGHT"), ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"), ("FONTNAME", (3, -1), (-1, -1), "Helvetica-Bold")]))
        story.extend((table, Spacer(1, 5 * mm), Paragraph(f"<b>Notes:</b> {escape(notes or '-')}", styles["Normal"])))
        pdf.build(story)
        return output_dir


class AccountsFinanceView(ttk.Frame):
    def __init__(self, parent, user_data=None, navigator=None):
        super().__init__(parent, padding=14)
        self.user_data = user_data or {}
        self.navigator = navigator
        ensure_inward_file()
        self._build()
        self.load_entries()

    def _build(self):
        header = ttk.Frame(self)
        header.pack(fill="x", pady=(0, 12))
        ttk.Label(header, text="Accounts & Finance", font=("Helvetica", 16, "bold")).pack(side="left")
        ttk.Button(header, text="+ Inward Entry", command=self.open_inward_entry).pack(side="right")
        ttk.Button(header, text="+ Outward Document", command=self.open_outward_window).pack(side="right", padx=(0, 8))
        ttk.Button(header, text="+ Vendor Registration", command=self.open_vendor_registration).pack(side="right", padx=(0, 8))
        ttk.Button(header, text="Cheque Details", command=self.open_cheque_details).pack(side="right", padx=(0, 8))
        summary = ttk.LabelFrame(self, text=" Inward Purchase Summary ", padding=12)
        summary.pack(fill="x", pady=(0, 12))
        self.total_entries_var, self.total_amount_var, self.pending_amount_var = tk.StringVar(value="0"), tk.StringVar(value="0.00"), tk.StringVar(value="0.00")
        for index, (label, variable) in enumerate((("Product Lines", self.total_entries_var), ("Total Inward Amount", self.total_amount_var), ("Pending Amount", self.pending_amount_var))):
            card = ttk.Frame(summary, padding=(12, 3))
            card.grid(row=0, column=index, sticky="ew", padx=8)
            ttk.Label(card, text=label).pack(anchor="w")
            ttk.Label(card, textvariable=variable, font=("Helvetica", 14, "bold")).pack(anchor="w")
            summary.columnconfigure(index, weight=1)
        pending_box = ttk.LabelFrame(self, text=" Pending Invoices ", padding=8)
        pending_box.pack(fill="x", pady=(0, 12))
        pending_columns = ("supplier", "invoice", "department", "total", "paid", "balance")
        self.pending_tree = ttk.Treeview(pending_box, columns=pending_columns, show="headings", height=4, selectmode="browse")
        for column, heading in zip(pending_columns, ("Vendor", "Invoice No.", "Department", "Invoice Total", "Paid", "Pending Balance")):
            self.pending_tree.heading(column, text=heading)
            self.pending_tree.column(column, width=175 if column == "supplier" else 120, anchor="e" if column in ("total", "paid", "balance") else "w")
        self.pending_tree.pack(side="left", fill="x", expand=True)
        pending_actions = ttk.Frame(pending_box)
        pending_actions.pack(side="right", fill="y", padx=(8, 0))
        ttk.Button(pending_actions, text="Pay Selected\nInvoice", command=self.pay_selected_invoice).pack(fill="x")
        table_box = ttk.LabelFrame(self, text=" Inward Entry Register ", padding=8)
        table_box.pack(fill="both", expand=True)
        columns = ("date", "supplier", "invoice_no", "department", "item_description", "quantity", "rate", "amount", "payment_status")
        headings = ("Date", "Supplier", "Invoice No.", "Department", "Product / Material", "Qty", "Rate", "Amount", "Status")
        self.tree = ttk.Treeview(table_box, columns=columns, show="headings", selectmode="browse")
        for column, heading in zip(columns, headings):
            self.tree.heading(column, text=heading)
            self.tree.column(column, width=180 if column in ("supplier", "item_description") else 115, anchor="e" if column in ("quantity", "rate", "amount") else "w")
        scrollbar = ttk.Scrollbar(table_box, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=scrollbar.set)
        self.tree.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        footer = ttk.Frame(self)
        footer.pack(fill="x", pady=(10, 0))
        ttk.Button(footer, text="Refresh", command=self.load_entries).pack(side="right")

    def open_inward_entry(self):
        self.navigator.show_inward_entry_page()

    def open_outward_window(self):
        self.navigator.show_outward_document_page()

    def open_vendor_registration(self):
        self.navigator.show_vendor_registration_page()

    def open_cheque_details(self):
        self.navigator.show_cheque_details_page()

    def pay_selected_invoice(self):
        selected = self.pending_tree.selection()
        if not selected:
            messagebox.showwarning("Select Invoice", "Select a pending invoice first.", parent=self)
            return
        invoice = next((item for item in get_invoice_balances() if f"{item['supplier']}|{item['invoice_no']}" == selected[0]), None)
        if invoice:
            InvoicePaymentDialog(self, invoice, self.load_entries)

    def load_entries(self):
        for row_id in self.tree.get_children():
            self.tree.delete(row_id)
        total = 0.0
        count = 0
        with open(INWARD_CSV, newline="", encoding="utf-8") as file:
            for row in csv.DictReader(file):
                count += 1
                try:
                    amount = float(row.get("amount", 0) or 0)
                except ValueError:
                    amount = 0.0
                total += amount
                self.tree.insert("", "end", values=(row.get("date", ""), row.get("supplier", ""), row.get("invoice_no", ""), row.get("department", ""), row.get("item_description", ""), row.get("quantity", ""), row.get("rate", ""), f"{amount:.2f}", row.get("payment_status", "")))
        self.total_entries_var.set(str(count))
        self.total_amount_var.set(f"{total:,.2f}")
        for row_id in self.pending_tree.get_children():
            self.pending_tree.delete(row_id)
        pending_total = 0.0
        for invoice in get_invoice_balances():
            if invoice["balance"] <= 0:
                continue
            pending_total += invoice["balance"]
            item_id = f"{invoice['supplier']}|{invoice['invoice_no']}"
            self.pending_tree.insert("", "end", iid=item_id, values=(invoice["supplier"], invoice["invoice_no"], invoice["department"], f"{invoice['total']:,.2f}", f"{invoice['paid']:,.2f}", f"{invoice['balance']:,.2f}"))
        self.pending_amount_var.set(f"{pending_total:,.2f}")
