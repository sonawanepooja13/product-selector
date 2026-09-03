import os
import tkinter as tk
from tkinter import messagebox, ttk

import auth_manager
import accounts_finance
import bom_engine
import panel_manufacturing
import production_window
import hr_window
from outward_window import OutwardWindow
from vendor_registration import VendorRegistrationWindow
import supply_chain_logistics
import legal_compliance
import maintenance
import it_workspace
import rnd_engineering
import customer_service
import warehouse_management
import qc_qa
import help as app_help
import subprocess
import datetime


# ---------------------------------------------------------------------------
# UI THEME
# ---------------------------------------------------------------------------

BG = "#F4F6F9"
PRIMARY = "#2F5D9F"
PRIMARY_DARK = "#1F3B66"
CARD_BG = "#FFFFFF"
CARD_HOVER = "#EAF1FB"
BORDER = "#D8DEE9"
TEXT = "#1F2937"
MUTED = "#6B7280"

BASE_FONT = ("Segoe UI", 10)
TITLE_FONT = ("Segoe UI", 16, "bold")
SUBTITLE_FONT = ("Segoe UI", 10)
CARD_FONT = ("Segoe UI", 10, "bold")
HEADER_FONT = ("Segoe UI", 12, "bold")


# ---------------------------------------------------------------------------
# WINDOWS TTS
# ---------------------------------------------------------------------------

def speak_greeting(username):
    """Speak a time-appropriate greeting using Windows TTS."""
    try:
        hour = datetime.datetime.now().hour

        if hour < 12:
            greeting = "Good morning"
        elif hour < 18:
            greeting = "Good afternoon"
        else:
            greeting = "Good evening"

        safe_name = str(username).replace("'", "''")

        message = (
            f"{greeting}, {safe_name}. "
            f"Welcome to Saark Operating System"
        )

        ps_cmd = (
            "Add-Type -AssemblyName System.Speech; "
            "(New-Object System.Speech.Synthesis.SpeechSynthesizer)"
            f".Speak('{message}')"
        )

        subprocess.Popen(
            [
                "powershell",
                "-NoProfile",
                "-Command",
                ps_cmd,
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    except Exception:
        return


# ---------------------------------------------------------------------------
# R&D PERMISSIONS WINDOW
# ---------------------------------------------------------------------------

class RnDPermissionsWindow(tk.Toplevel):
    """Separate window for R&D granular permissions configuration."""

    def __init__(self, parent, module_vars):
        super().__init__(parent)

        self.parent = parent
        self.module_vars = module_vars

        self.title("🔬 R&D Granular Permissions Configuration")
        self.geometry("500x450")
        self.minsize(400, 350)
        self.resizable(True, True)

        try:
            self.state("zoomed")
        except Exception:
            pass

        self.transient(parent)
        self.grab_set()

        self.create_widgets()

    def create_widgets(self):

        ttk.Label(
            self,
            text="R&D Engineering Granular Access Control",
            font=("Helvetica", 12, "bold"),
        ).pack(pady=10)

        action_frame = ttk.Frame(
            self,
            padding=(15, 0, 15, 15)
        )
        action_frame.pack(fill="x")

        ttk.Button(
            action_frame,
            text="💾 Apply Changes",
            command=self.apply_changes,
        ).pack(
            side="left",
            fill="x",
            expand=True,
            padx=(0, 5),
        )

        ttk.Button(
            action_frame,
            text="❌ Close",
            command=self.destroy,
        ).pack(
            side="left",
            fill="x",
            expand=True,
            padx=(5, 0),
        )

        canvas = tk.Canvas(self)
        scrollbar = ttk.Scrollbar(
            self,
            orient="vertical",
            command=canvas.yview,
        )

        scrollable_frame = ttk.Frame(
            canvas,
            padding=15
        )

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(
                scrollregion=canvas.bbox("all")
            )
        )

        canvas.create_window(
            (0, 0),
            window=scrollable_frame,
            anchor="nw",
        )

        canvas.configure(
            yscrollcommand=scrollbar.set
        )

        canvas.pack(
            side="left",
            fill="both",
            expand=True,
        )

        scrollbar.pack(
            side="right",
            fill="y",
        )

        ttk.Label(
            scrollable_frame,
            text="R&D Module - Tab Access Control",
            font=("Helvetica", 10, "bold"),
        ).pack(
            anchor="w",
            pady=(10, 5),
        )

        rnd_permissions = [
            ("allow_rnd_pdlc", "📊 Product Development (PDLC)"),
            ("allow_rnd_projects", "📋 Projects & Tasks"),
            ("allow_rnd_sprints", "🔄 Sprint Management"),
            ("allow_rnd_hardware", "🔧 Hardware & Prototypes"),
            ("allow_rnd_components", "⚙️ Components & Supply"),
            ("allow_rnd_risk", "⚠️ Risk Management"),
            ("allow_rnd_team", "👥 Team & Resource Allocation"),
            ("allow_rnd_compliance", "📋 Compliance & Certification"),
        ]

        rnd_sub_permissions = [
            ("allow_rnd_design_cad", "Design & CAD"),
            ("allow_rnd_prototyping_testing", "Prototyping & Testing"),
            ("allow_rnd_bom", "Bill of Materials (BOM)"),
            ("allow_rnd_eco", "Engineering Change Orders (ECO)"),
        ]

        for key, label_text in rnd_permissions:

            var = self.module_vars.get(
                key,
                tk.BooleanVar(value=False)
            )

            ttk.Checkbutton(
                scrollable_frame,
                text=label_text,
                variable=var,
            ).pack(
                anchor="w",
                pady=4,
                padx=5,
            )

        ttk.Label(
            scrollable_frame,
            text="R&D Module - Sub-parts / Windows",
            font=("Helvetica", 10, "bold"),
        ).pack(
            anchor="w",
            pady=(12, 5),
            padx=5,
        )

        for key, label_text in rnd_sub_permissions:

            var = self.module_vars.get(
                key,
                tk.BooleanVar(value=False)
            )

            ttk.Checkbutton(
                scrollable_frame,
                text=label_text,
                variable=var,
            ).pack(
                anchor="w",
                pady=3,
                padx=20,
            )

        utility_frame = ttk.Frame(scrollable_frame)
        utility_frame.pack(
            fill="x",
            pady=(15, 0)
        )

        ttk.Button(
            utility_frame,
            text="📂 Open All R&D",
            command=self.open_all_rnd,
        ).pack(
            side="left",
            padx=5,
        )

        ttk.Button(
            utility_frame,
            text="📁 Close All R&D",
            command=self.close_all_rnd,
        ).pack(
            side="left",
            padx=5,
        )

        ttk.Button(
            utility_frame,
            text="⚙️ Default R&D",
            command=self.set_default_rnd,
        ).pack(
            side="left",
            padx=5,
        )

    def open_all_rnd(self):

        rnd_keys = [
            "allow_rnd_pdlc",
            "allow_rnd_projects",
            "allow_rnd_sprints",
            "allow_rnd_hardware",
            "allow_rnd_components",
            "allow_rnd_risk",
            "allow_rnd_team",
            "allow_rnd_compliance",
        ]

        for key in rnd_keys:
            if key in self.module_vars:
                self.module_vars[key].set(True)

    def close_all_rnd(self):

        rnd_keys = [
            "allow_rnd_pdlc",
            "allow_rnd_projects",
            "allow_rnd_sprints",
            "allow_rnd_hardware",
            "allow_rnd_components",
            "allow_rnd_risk",
            "allow_rnd_team",
            "allow_rnd_compliance",
        ]

        for key in rnd_keys:
            if key in self.module_vars:
                self.module_vars[key].set(False)

    def set_default_rnd(self):

        rnd_keys = [
            "allow_rnd_pdlc",
            "allow_rnd_projects",
            "allow_rnd_sprints",
            "allow_rnd_hardware",
            "allow_rnd_components",
            "allow_rnd_risk",
            "allow_rnd_team",
            "allow_rnd_compliance",
        ]

        for key in rnd_keys:
            if key in self.module_vars:
                self.module_vars[key].set(False)

    def apply_changes(self):

        messagebox.showinfo(
            "Success",
            "R&D permissions updated successfully!",
            parent=self,
        )

        self.destroy()


# ---------------------------------------------------------------------------
# USER ACCESS CONTROL
# ---------------------------------------------------------------------------

class UserAccessControlFrame(ttk.Frame):
    """Integrated User Access & Permission Control."""

    def __init__(self, parent, main_app):

        super().__init__(
            parent,
            padding=15
        )

        self.main_app = main_app

        self.users_cache = []
        self.selected_user = None
        self.module_vars = {}
        self.subwindow_vars = {}

        self.setup_ui()
        self.load_accounts_dropdown()

    def setup_ui(self):

        self.columnconfigure(0, weight=1)
        self.columnconfigure(1, weight=1)
        self.rowconfigure(1, weight=1)

        title_lbl = ttk.Label(
            self,
            text="User Account & Module Access Control Panel",
            font=("Helvetica", 14, "bold"),
        )

        title_lbl.grid(
            row=0,
            column=0,
            columnspan=2,
            sticky="w",
            pady=(0, 15),
        )

        # ---------------------------------------------------------------
        # LEFT PANEL
        # ---------------------------------------------------------------

        left_panel = ttk.Frame(self)

        left_panel.grid(
            row=1,
            column=0,
            sticky="nsew",
            padx=(0, 10),
        )

        left_panel.rowconfigure(2, weight=1)
        left_panel.columnconfigure(0, weight=1)

        select_frame = ttk.Frame(left_panel)

        select_frame.pack(
            fill="x",
            pady=(0, 10)
        )

        ttk.Label(
            select_frame,
            text="Select Account to Modify:",
            font=("Helvetica", 9, "bold"),
        ).pack(
            anchor="w",
            pady=(0, 2),
        )

        self.combo_accounts = ttk.Combobox(
            select_frame,
            state="readonly",
            font=("Helvetica", 10),
        )

        self.combo_accounts.pack(
            fill="x"
        )

        self.combo_accounts.bind(
            "<<ComboboxSelected>>",
            self.on_account_selected,
        )

        cred_frame = ttk.LabelFrame(
            left_panel,
            text=" Account Credentials ",
            padding=12,
        )

        cred_frame.pack(
            fill="x",
            pady=(0, 10),
        )

        fields = [
            ("Username:", "ent_username", False),
            ("Full Name:", "ent_full_name", False),
            ("Mobile Number:", "ent_mobile", False),
            ("New Password:", "ent_password", True),
        ]

        for idx, (label_text, attr_name, is_password) in enumerate(fields):

            ttk.Label(
                cred_frame,
                text=label_text,
            ).grid(
                row=idx,
                column=0,
                sticky="w",
                pady=6,
                padx=5,
            )

            entry = ttk.Entry(
                cred_frame,
                show="*" if is_password else "",
                width=30,
            )

            entry.grid(
                row=idx,
                column=1,
                sticky="ew",
                pady=6,
                padx=5,
            )

            setattr(
                self,
                attr_name,
                entry,
            )

        ttk.Label(
            cred_frame,
            text="Role Designation:",
        ).grid(
            row=4,
            column=0,
            sticky="w",
            pady=6,
            padx=5,
        )

        self.combo_role = ttk.Combobox(
            cred_frame,
            state="readonly",
            values=["User", "Admin"],
            width=28,
        )

        self.combo_role.set("User")

        self.combo_role.grid(
            row=4,
            column=1,
            sticky="ew",
            pady=6,
            padx=5,
        )

        cred_frame.columnconfigure(
            1,
            weight=1
        )

        btn_frame = ttk.Frame(left_panel)

        btn_frame.pack(
            fill="x",
            pady=(10, 0)
        )

        ttk.Button(
            btn_frame,
            text="💾 Save / Apply",
            command=self.save_user_details,
        ).pack(
            side="left",
            fill="x",
            expand=True,
            padx=(0, 5),
            ipady=4,
        )

        ttk.Button(
            btn_frame,
            text="🗑️ Delete User",
            command=self.delete_user_account,
        ).pack(
            side="right",
            fill="x",
            expand=True,
            padx=(5, 0),
            ipady=4,
        )

        # ---------------------------------------------------------------
        # RIGHT PANEL
        # ---------------------------------------------------------------

        right_panel = ttk.LabelFrame(
            self,
            text=" Module & Tab Access Permissions ",
            padding=10,
        )

        right_panel.grid(
            row=1,
            column=1,
            sticky="nsew",
            padx=(10, 0),
        )

        perm_canvas = tk.Canvas(
            right_panel,
            borderwidth=0,
            highlightthickness=0,
        )

        perm_scrollbar = ttk.Scrollbar(
            right_panel,
            orient="vertical",
            command=perm_canvas.yview,
        )

        self.perm_scrollable_inner = ttk.Frame(
            perm_canvas,
            padding=5,
        )

        self.perm_scrollable_inner.bind(
            "<Configure>",
            lambda e: perm_canvas.configure(
                scrollregion=perm_canvas.bbox("all")
            )
        )

        self.perm_window_id = perm_canvas.create_window(
            (0, 0),
            window=self.perm_scrollable_inner,
            anchor="nw",
        )

        perm_canvas.configure(
            yscrollcommand=perm_scrollbar.set
        )

        perm_canvas.pack(
            side="left",
            fill="both",
            expand=True,
        )

        perm_scrollbar.pack(
            side="right",
            fill="y",
        )

        def resize_inner(event):
            perm_canvas.itemconfigure(
                self.perm_window_id,
                width=event.width
            )

        perm_canvas.bind(
            "<Configure>",
            resize_inner
        )

        # ---------------------------------------------------------------
        # MODULE DEFINITIONS
        # ---------------------------------------------------------------

        self.defined_modules = [
            ("allow_price", "Price List Search Tab"),
            ("allow_material", "Material & Labor Calculator Tab"),
            ("allow_crm", "Customer CRM & Leads Tab"),
            ("allow_sales", "📈 Sales & Marketing Module"),
            ("allow_production", "🏭 Production Process Module"),
            ("allow_project_management", "📁 Project Management / Professional Services"),
            ("allow_qc_qa", "✅ Quality Control (QC) / Quality Assurance (QA)"),
            ("allow_panel_mfg", "🔧 Panel Manufacturing Module"),
            ("allow_accounts", "💰 Accounts & Finance Module"),
            ("allow_hr", "👥 HR (Human Resources) Module"),
            ("allow_purchase", "🛒 Purchase / Procurement Module"),
            ("allow_stores", "📦 Stores / Warehouse Module"),
            ("allow_maintenance", "🛠️ Maintenance Module"),
            ("allow_rnd", "🔬 R&D / Engineering Module"),
            ("allow_asset_management", "🏢 Asset Management / Fixed Assets"),
            ("allow_ehs", "🛡️ EHS / Risk Management"),
            ("allow_pos_ecommerce", "🛍️ Point of Sale (POS) / E-Commerce"),
            ("allow_it", "💻 IT Module"),
            ("allow_customer_service", "🎧 Customer Service Module"),
            ("allow_legal", "⚖️ Legal & Compliance Module"),
            ("allow_admin_dept", "📋 Administration Module"),
            ("allow_supply_chain", "🚚 Supply Chain / Logistics Module"),
            ("allow_admin", "⚙️ Admin Settings"),
        ]

        self.rnd_permissions = [
            ("allow_rnd_pdlc", "📊 Product Development (PDLC)"),
            ("allow_rnd_projects", "📋 Projects & Tasks"),
            ("allow_rnd_sprints", "🔄 Sprint Management"),
            ("allow_rnd_hardware", "🔧 Hardware & Prototypes"),
            ("allow_rnd_components", "⚙️ Components & Supply"),
            ("allow_rnd_risk", "⚠️ Risk Management"),
            ("allow_rnd_team", "👥 Team & Resource Allocation"),
            ("allow_rnd_compliance", "📋 Compliance & Certification"),
        ]

        self.rnd_sub_permissions = [
            ("allow_rnd_design_cad", "Design & CAD"),
            ("allow_rnd_prototyping_testing", "Prototyping & Testing"),
            ("allow_rnd_bom", "Bill of Materials (BOM)"),
            ("allow_rnd_eco", "Engineering Change Orders (ECO)"),
        ]

        for key, label_text in self.defined_modules:

            var = tk.BooleanVar(value=False)

            self.module_vars[key] = var

            ttk.Checkbutton(
                self.perm_scrollable_inner,
                text=label_text,
                variable=var,
            ).pack(
                anchor="w",
                pady=4,
                padx=5,
            )

        # ---------------------------------------------------------------
        # R&D SUB PERMISSIONS
        # ---------------------------------------------------------------

        self.rnd_sub_frame = ttk.Frame(
            self.perm_scrollable_inner
        )

        for key, label_text in self.rnd_sub_permissions:

            var = tk.BooleanVar(value=False)

            self.module_vars[key] = var

            ttk.Checkbutton(
                self.rnd_sub_frame,
                text=label_text,
                variable=var,
            ).pack(
                anchor="w",
                pady=2,
                padx=10,
            )

        # R&D granular variables
        for key, _ in self.rnd_permissions:

            var = tk.BooleanVar(value=False)

            self.module_vars[key] = var

        if "allow_rnd" in self.module_vars:

            self.module_vars["allow_rnd"].trace_add(
                "write",
                self.on_rnd_toggle,
            )

        self.update_rnd_sub_visibility()

        # ---------------------------------------------------------------
        # PERMISSION BUTTONS
        # ---------------------------------------------------------------

        perm_btn_frame = ttk.Frame(
            self.perm_scrollable_inner
        )

        perm_btn_frame.pack(
            fill="x",
            pady=(15, 0),
        )

        ttk.Button(
            perm_btn_frame,
            text="💾 Save Permissions",
            command=self.save_user_details,
        ).pack(
            side="left",
            fill="x",
            expand=True,
            padx=(0, 5),
            ipady=4,
        )

        ttk.Button(
            perm_btn_frame,
            text="🗑️ Delete User",
            command=self.delete_user_account,
        ).pack(
            side="right",
            fill="x",
            expand=True,
            padx=(5, 0),
            ipady=4,
        )

        utility_frame = ttk.Frame(
            self.perm_scrollable_inner
        )

        utility_frame.pack(
            fill="x",
            pady=(8, 0),
        )

        ttk.Button(
            utility_frame,
            text="📂 Open All",
            command=self.open_all_permissions,
        ).pack(
            side="left",
            padx=5,
        )

        ttk.Button(
            utility_frame,
            text="📁 Close All",
            command=self.close_all_permissions,
        ).pack(
            side="left",
            padx=5,
        )

        ttk.Button(
            utility_frame,
            text="⚙️ Default",
            command=self.set_default_permissions,
        ).pack(
            side="left",
            padx=5,
        )

        rnd_frame = ttk.Frame(
            self.perm_scrollable_inner
        )

        rnd_frame.pack(
            fill="x",
            pady=(10, 0),
        )

        ttk.Label(
            rnd_frame,
            text="🔬 R&D Granular Permissions:",
            font=("Helvetica", 10, "bold"),
        ).pack(
            side="left",
            padx=5,
        )

        ttk.Button(
            rnd_frame,
            text="⚙️ Configure R&D Access",
            command=self.open_rnd_permissions_window,
        ).pack(
            side="left",
            padx=5,
        )

    def load_accounts_dropdown(self):

        self.users_cache = auth_manager.load_users()

        dropdown_list = [
            "-- Create New User --"
        ]

        for u in self.users_cache:

            username = u.get("username", "")
            full_name = u.get("full_name", "")
            mobile = u.get("mobile_number", "")

            details = [
                d
                for d in (full_name, mobile)
                if d
            ]

            detail_str = (
                f" ({' - '.join(details)})"
                if details
                else ""
            )

            dropdown_list.append(
                f"{username}{detail_str}"
            )

        self.combo_accounts["values"] = dropdown_list

        self.combo_accounts.set(
            dropdown_list[0]
        )

        self.clear_fields()

    def on_account_selected(self, event):

        selected_text = self.combo_accounts.get()

        if selected_text == "-- Create New User --":

            self.selected_user = None
            self.clear_fields()

            self.ent_username.config(
                state="normal"
            )

            return

        username = selected_text.split(
            " ("
        )[0].strip()

        user_data = next(
            (
                u
                for u in self.users_cache
                if u["username"] == username
            ),
            None,
        )

        if user_data:

            self.selected_user = user_data

            self.ent_username.config(
                state="normal"
            )

            self.ent_username.delete(
                0,
                tk.END
            )

            self.ent_username.insert(
                0,
                user_data.get(
                    "username",
                    ""
                )
            )

            self.ent_username.config(
                state="disabled"
            )

            self.ent_full_name.delete(
                0,
                tk.END
            )

            self.ent_full_name.insert(
                0,
                user_data.get(
                    "full_name",
                    ""
                )
            )

            self.ent_mobile.delete(
                0,
                tk.END
            )

            self.ent_mobile.insert(
                0,
                user_data.get(
                    "mobile_number",
                    ""
                )
            )

            self.ent_password.delete(
                0,
                tk.END
            )

            self.combo_role.set(
                user_data.get(
                    "role",
                    "User"
                )
            )

            for key, _ in self.defined_modules:

                default_val = (
                    True
                    if key in [
                        "allow_price",
                        "allow_material",
                    ]
                    else False
                )

                self.module_vars[key].set(
                    user_data.get(
                        key,
                        default_val
                    )
                )

            for key, _ in self.rnd_permissions:

                self.module_vars[key].set(
                    user_data.get(
                        key,
                        False
                    )
                )

            for key, _ in self.rnd_sub_permissions:

                self.module_vars[key].set(
                    user_data.get(
                        key,
                        False
                    )
                )

            self.update_rnd_sub_visibility()

    def clear_fields(self):

        self.ent_username.config(
            state="normal"
        )

        self.ent_username.delete(
            0,
            tk.END
        )

        self.ent_full_name.delete(
            0,
            tk.END
        )

        self.ent_mobile.delete(
            0,
            tk.END
        )

        self.ent_password.delete(
            0,
            tk.END
        )

        self.combo_role.set(
            "User"
        )

        for key, _ in self.defined_modules:

            default_val = (
                True
                if key in [
                    "allow_price",
                    "allow_material",
                ]
                else False
            )

            self.module_vars[key].set(
                default_val
            )

        for key, _ in self.rnd_permissions:
            self.module_vars[key].set(False)

        for key, _ in self.rnd_sub_permissions:
            self.module_vars[key].set(False)

        self.update_rnd_sub_visibility()

    def update_rnd_sub_visibility(self):

        if "allow_rnd" not in self.module_vars:
            return

        if self.module_vars["allow_rnd"].get():

            self.rnd_sub_frame.pack(
                fill="x",
                padx=(20, 5),
                pady=(0, 4),
            )

        else:

            self.rnd_sub_frame.pack_forget()

    def on_rnd_toggle(self, *args):

        if "allow_rnd" not in self.module_vars:
            return

        parent_checked = (
            self.module_vars["allow_rnd"].get()
        )

        if parent_checked:

            for key, _ in self.rnd_sub_permissions:

                if (
                    key in self.module_vars
                    and not self.module_vars[key].get()
                ):
                    self.module_vars[key].set(True)

        else:

            for key, _ in self.rnd_sub_permissions:

                if key in self.module_vars:
                    self.module_vars[key].set(False)

        self.update_rnd_sub_visibility()

    def open_all_permissions(self):

        for var in self.module_vars.values():
            var.set(True)

        self.update_rnd_sub_visibility()

    def close_all_permissions(self):

        for var in self.module_vars.values():
            var.set(False)

        self.update_rnd_sub_visibility()

    def set_default_permissions(self):

        for key, var in self.module_vars.items():

            default_val = (
                True
                if key in [
                    "allow_price",
                    "allow_material",
                ]
                else False
            )

            var.set(default_val)

        self.update_rnd_sub_visibility()

    def open_rnd_permissions_window(self):

        RnDPermissionsWindow(
            self,
            self.module_vars
        )

    def save_user_details(self):

        username = self.ent_username.get().strip()
        full_name = self.ent_full_name.get().strip()
        mobile_number = self.ent_mobile.get().strip()
        password = self.ent_password.get().strip()
        role = self.combo_role.get()

        if not username:

            messagebox.showwarning(
                "Input Error",
                "Username is required.",
                parent=self,
            )

            return

        if not self.selected_user and not password:

            messagebox.showwarning(
                "Input Error",
                "Password is required for new accounts.",
                parent=self,
            )

            return

        perm_data = {
            key: var.get()
            for key, var in self.module_vars.items()
        }

        auth_manager.add_or_update_user(
            username=username,
            password=password if password else None,
            full_name=full_name,
            mobile_number=mobile_number,
            designation="",
            role=role,
            **perm_data
        )

        messagebox.showinfo(
            "Success",
            f"User account '{username}' saved successfully!",
            parent=self,
        )

        self.load_accounts_dropdown()

    def delete_user_account(self):

        if not self.selected_user:

            messagebox.showwarning(
                "Selection Error",
                "Please select an account to delete.",
                parent=self,
            )

            return

        username = self.selected_user["username"]

        if username == "admin":

            messagebox.showerror(
                "Action Denied",
                "Default 'admin' account cannot be deleted.",
                parent=self,
            )

            return

        if messagebox.askyesno(
            "Confirm Delete",
            f"Are you sure you want to delete user '{username}'?",
            parent=self,
        ):

            auth_manager.delete_user(
                username
            )

            messagebox.showinfo(
                "Deleted",
                f"User '{username}' deleted.",
                parent=self,
            )

            self.load_accounts_dropdown()


# ---------------------------------------------------------------------------
# MAIN APPLICATION
# ---------------------------------------------------------------------------

class MainApp:
    """Master Application Window."""

    def __init__(self, root):

        self.root = root

        self.root.title(
            "Company Manegement Software"
        )

        bom_engine.ensure_files_exist()
        auth_manager.ensure_user_file_exists()

        self.user_data = None
        self.content_frame = None

        # ---------------------------------------------------------------
        # CENTRALIZED NAVIGATION
        # ---------------------------------------------------------------

        self.navigation_stack = []

        self.current_view = None
        self.current_view_name = None

        # Prevent Back from creating another history entry.
        self._going_back = False

        self._setup_styles()

        self.show_login_screen()

    # ===================================================================
    # NAVIGATION SYSTEM
    # ===================================================================

    def _set_current_view(
        self,
        view_callable,
        *args,
        view_name=None,
        **kwargs
    ):
        """
        Register the current screen.

        Every screen is represented by:
            callable + args + kwargs

        This allows the Back button to reconstruct the previous screen.
        """

        self.current_view = (
            view_callable,
            args,
            kwargs,
        )

        self.current_view_name = (
            view_name
            or getattr(
                view_callable,
                "__name__",
                "View",
            )
        )

    def navigate_to(
        self,
        view_callable,
        *args,
        view_name=None,
        **kwargs
    ):
        """
        Central navigation function.

        Pushes the current screen onto the history stack and opens
        the requested screen.
        """

        if self._going_back:
            return

        if self.current_view is not None:

            self.navigation_stack.append(
                self.current_view
            )

        self._set_current_view(
            view_callable,
            *args,
            view_name=view_name,
            **kwargs,
        )

        view_callable(
            *args,
            **kwargs
        )

    def go_back(self):
        """
        Return to the immediately previous screen.
        """

        if not self.navigation_stack:

            self.build_main_dashboard()
            return

        previous_view = self.navigation_stack.pop()

        self._going_back = True

        try:

            view_callable, args, kwargs = previous_view

            self._set_current_view(
                view_callable,
                *args,
                **kwargs,
            )

            view_callable(
                *args,
                **kwargs
            )

        except Exception as e:

            messagebox.showerror(
                "Navigation Error",
                f"Could not return to previous page:\n{e}",
                parent=self.root,
            )

        finally:

            self._going_back = False

    def go_home(self):

        self.navigation_stack.clear()

        self._going_back = True

        try:
            self.build_main_dashboard()
        finally:
            self._going_back = False

    def reset_navigation(self):

        self.navigation_stack.clear()

    def logout(self):

        if self.content_frame:
            self.content_frame.destroy()
            self.content_frame = None

        self.user_data = None
        self.reset_navigation()
        self.current_view = None
        self.current_view_name = None
        self.show_login_screen()

    # ===================================================================
    # STYLES
    # ===================================================================

    def _setup_styles(self):

        style = ttk.Style()

        try:
            style.theme_use("clam")
        except Exception:
            pass

        self.root.configure(
            bg=BG
        )

        style.configure(
            ".",
            font=BASE_FONT,
            background=BG,
            foreground=TEXT,
        )

        style.configure(
            "TFrame",
            background=BG,
        )

        style.configure(
            "TLabel",
            background=BG,
            foreground=TEXT,
        )

        style.configure(
            "TLabelframe",
            background=BG,
            foreground=TEXT,
        )

        style.configure(
            "TLabelframe.Label",
            background=BG,
            foreground=TEXT,
            font=("Segoe UI", 10, "bold"),
        )

        style.configure(
            "TCheckbutton",
            background=BG,
            foreground=TEXT,
        )

        style.configure(
            "Card.TFrame",
            background=CARD_BG,
        )

        style.configure(
            "Card.TLabel",
            background=CARD_BG,
            foreground=TEXT,
        )

        style.configure(
            "CardTitle.TLabel",
            background=CARD_BG,
            foreground=TEXT,
            font=("Segoe UI", 12, "bold"),
        )

        style.configure(
            "TButton",
            font=BASE_FONT,
            padding=6,
        )

        style.configure(
            "Accent.TButton",
            font=("Segoe UI", 10, "bold"),
            padding=8,
            background=PRIMARY,
            foreground="white",
            borderwidth=0,
        )

        style.map(
            "Accent.TButton",
            background=[
                ("active", PRIMARY_DARK),
                ("pressed", PRIMARY_DARK),
            ],
        )

        style.configure(
            "Ghost.TButton",
            font=("Segoe UI", 9, "bold"),
            padding=6,
            background=PRIMARY_DARK,
            foreground="white",
            borderwidth=0,
        )

        style.map(
            "Ghost.TButton",
            background=[
                ("active", PRIMARY),
                ("pressed", PRIMARY),
            ],
        )

        style.configure(
            "TEntry",
            padding=4,
        )

        style.configure(
            "TCombobox",
            padding=4,
        )

    # ===================================================================
    # ANIMATIONS
    # ===================================================================

    def _animate_widget(
        self,
        widget,
        start,
        end,
        duration=280,
        steps=18,
        done=None
    ):

        try:
            start = float(start)
            end = float(end)

        except (
            TypeError,
            ValueError,
        ):

            if done:
                done()

            return

        def tick(i=0):

            try:

                if not widget.winfo_exists():
                    return

                progress = min(
                    1.0,
                    i / float(steps)
                )

                eased = (
                    1 -
                    (1 - progress) ** 3
                )

                value = (
                    start +
                    (end - start) *
                    eased
                )

                widget.place_configure(
                    relx=0.5,
                    rely=value,
                    anchor="center",
                )

                if i < steps:

                    widget.after(
                        max(
                            1,
                            duration // steps
                        ),
                        lambda: tick(i + 1)
                    )

                elif done:

                    done()

            except tk.TclError:
                return

        tick()

    def _fade_text(
        self,
        label,
        text,
        steps=10,
        interval=35
    ):

        if not label.winfo_exists():
            return

        label.configure(
            text=""
        )

        chars = list(
            str(text)
        )

        def reveal(i=0):

            if not label.winfo_exists():
                return

            label.configure(
                text="".join(
                    chars[:i]
                )
            )

            if i < len(chars):

                label.after(
                    interval,
                    lambda: reveal(i + 1)
                )

        reveal()

    def _animate_card_grid(
        self,
        cards,
        delay=45
    ):

        for index, card in enumerate(cards):

            try:
                card.grid_remove()

            except tk.TclError:
                continue

            def show(c=card):

                try:

                    c.grid()

                    c.update_idletasks()

                    c.grid_configure(
                        padx=8,
                        pady=8,
                    )

                    c.after(
                        120,
                        lambda: c.grid_configure(
                            padx=10,
                            pady=10
                        )
                    )

                except tk.TclError:
                    pass

            self.root.after(
                index * delay,
                show
            )

    def _animate_hover(
        self,
        widgets,
        entering
    ):

        try:

            card = widgets[0]

            bg = (
                CARD_HOVER
                if entering
                else CARD_BG
            )

            border = (
                PRIMARY
                if entering
                else BORDER
            )

            for w in widgets:
                w.configure(
                    bg=bg
                )

            card.configure(
                highlightbackground=border,
                highlightthickness=(
                    2 if entering else 1
                ),
            )

        except tk.TclError:
            pass

    def _button_click_animation(
        self,
        button,
        command,
        delay=110
    ):

        try:
            button.state(["pressed"])

        except tk.TclError:
            pass

        def release_and_run():

            try:
                button.state(["!pressed"])

            except tk.TclError:
                pass

            command()

        self.root.after(
            delay,
            release_and_run
        )

    # ===================================================================
    # WINDOW HELPERS
    # ===================================================================

    def center_window(
        self,
        width,
        height
    ):

        self.root.update_idletasks()

        screen_width = (
            self.root.winfo_screenwidth()
        )

        screen_height = (
            self.root.winfo_screenheight()
        )

        x = (
            screen_width // 2
            - width // 2
        )

        y = (
            screen_height // 2
            - height // 2
        )

        self.root.geometry(
            f"{width}x{height}+{x}+{y}"
        )

    def toggle_main_window_size(self):

        try:

            if self.root.state() == "normal":
                self.root.state("zoomed")

            else:
                self.root.state("normal")

        except Exception:

            self.root.geometry(
                "420x280"
            )

    # ===================================================================
    # LOGIN
    # ===================================================================

    def show_login_screen(self):

        self.root.title(
            "Company Manegement Software"
        )

        self.root.configure(
            bg=BG
        )

        self.root.geometry(
            "480x460"
        )

        self.root.minsize(
            420,
            420
        )

        self.root.resizable(
            True,
            True
        )

        self.content_container = tk.Frame(
            self.root,
            bg=BG
        )

        self.content_container.pack(
            fill="both",
            expand=True
        )

        header = tk.Frame(
            self.content_container,
            bg=PRIMARY_DARK,
            height=110,
        )

        header.pack(
            fill="x"
        )

        header.pack_propagate(False)

        tk.Label(
            header,
            text="🏭 Saark Operating System",
            bg=PRIMARY_DARK,
            fg="white",
            font=("Segoe UI", 16, "bold"),
        ).pack(
            pady=(26, 2)
        )

        tk.Label(
            header,
            text="Company Management Software",
            bg=PRIMARY_DARK,
            fg="#CBD9EF",
            font=("Segoe UI", 9),
        ).pack()

        center_area = tk.Frame(
            self.content_container,
            bg=BG
        )

        center_area.pack(
            fill="both",
            expand=True
        )

        self.login_frame = ttk.Frame(
            center_area,
            padding=28,
            style="Card.TFrame"
        )

        self.login_frame.place(
            relx=0.5,
            rely=0.5,
            anchor="center",
            width=340
        )

        ttk.Label(
            self.login_frame,
            text="Sign in to continue",
            style="CardTitle.TLabel",
        ).pack(
            pady=(0, 18)
        )

        ttk.Label(
            self.login_frame,
            text="Username",
            style="Card.TLabel",
        ).pack(
            anchor="w"
        )

        self.entry_user = ttk.Entry(
            self.login_frame
        )

        self.entry_user.pack(
            fill="x",
            pady=(2, 14),
            ipady=4
        )

        self.entry_user.focus_set()

        ttk.Label(
            self.login_frame,
            text="Password",
            style="Card.TLabel",
        ).pack(
            anchor="w"
        )

        self.entry_pwd = ttk.Entry(
            self.login_frame,
            show="*"
        )

        self.entry_pwd.pack(
            fill="x",
            pady=(2, 20),
            ipady=4
        )

        self.entry_pwd.bind(
            "<Return>",
            lambda event: self.handle_login()
        )

        btn_login = ttk.Button(
            self.login_frame,
            text="Login",
            style="Accent.TButton",
            command=lambda: self._button_click_animation(
                btn_login,
                self.handle_login,
            ),
        )

        btn_login.pack(
            fill="x",
            ipady=3
        )

    def handle_login(self):

        username = (
            self.entry_user.get().strip()
        )

        password = (
            self.entry_pwd.get().strip()
        )

        if not username or not password:

            messagebox.showwarning(
                "Login Error",
                "Please enter both username and password.",
            )

            return

        success, user_data = (
            auth_manager.verify_login(
                username,
                password
            )
        )

        if success:

            self.user_data = user_data

            try:
                speak_greeting(
                    self.user_data.get(
                        "username",
                        "User"
                    )
                )
            except Exception:
                pass

            if hasattr(
                self,
                "title_bar"
            ):
                self.title_bar.destroy()

            if hasattr(
                self,
                "content_container"
            ):
                self.content_container.destroy()

            if hasattr(
                self,
                "login_frame"
            ):
                self.login_frame.destroy()

            self.reset_navigation()

            self.build_main_dashboard()

        else:

            messagebox.showerror(
                "Access Denied",
                "Invalid username or password.\n\n"
                "Please check your credentials.",
            )

            self.entry_pwd.delete(
                0,
                tk.END
            )

            self.entry_pwd.focus_set()

    # ===================================================================
    # WORKSPACE
    # ===================================================================

    def clear_workspace(self):

        if (
            hasattr(
                self,
                "content_frame"
            )
            and self.content_frame
        ):

            try:
                self.content_frame.destroy()
            except Exception:
                pass

        self.content_frame = ttk.Frame(
            self.root
        )

        self.content_frame.pack(
            fill="both",
            expand=True
        )

    # ===================================================================
    # MAIN DASHBOARD
    # ===================================================================

    def build_main_dashboard(self):

        self.center_window(
            1100,
            800
        )

        self.root.resizable(
            True,
            True
        )

        try:
            self.root.state("zoomed")
        except Exception:
            pass

        username = self.user_data.get(
            "username",
            "User"
        )

        role = self.user_data.get(
            "role",
            "User"
        )

        self.root.title(
            "Company Manegement Software "
            f"— Logged in: {username} ({role})"
        )

        self.clear_workspace()

        # Dashboard is the root page.
        self._set_current_view(
            self.build_main_dashboard,
            view_name="Dashboard"
        )

        banner = tk.Frame(
            self.content_frame,
            bg=PRIMARY_DARK
        )

        banner.pack(
            fill="x"
        )

        ttk.Button(
            banner,
            text="Logout",
            style="Ghost.TButton",
            command=self.logout,
        ).pack(
            side="right",
            padx=26,
            pady=16,
        )

        tk.Label(
            banner,
            text=f"Welcome, {username}!",
            bg=PRIMARY_DARK,
            fg="white",
            font=TITLE_FONT,
        ).pack(
            anchor="w",
            padx=26,
            pady=(18, 2)
        )

        tk.Label(
            banner,
            text="Select a workspace module to proceed",
            bg=PRIMARY_DARK,
            fg="#CBD9EF",
            font=SUBTITLE_FONT,
        ).pack(
            anchor="w",
            padx=26,
            pady=(0, 16)
        )

        body_wrap = tk.Frame(
            self.content_frame,
            bg=BG
        )

        body_wrap.pack(
            fill="both",
            expand=True
        )

        canvas = tk.Canvas(
            body_wrap,
            bg=BG,
            highlightthickness=0
        )

        scrollbar = ttk.Scrollbar(
            body_wrap,
            orient="vertical",
            command=canvas.yview
        )

        scrollable_frame = tk.Frame(
            canvas,
            bg=BG,
            padx=24,
            pady=22
        )

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(
                scrollregion=canvas.bbox("all")
            )
        )

        canvas_window = canvas.create_window(
            (0, 0),
            window=scrollable_frame,
            anchor="nw"
        )

        canvas.configure(
            yscrollcommand=scrollbar.set
        )

        canvas.pack(
            side="left",
            fill="both",
            expand=True
        )

        scrollbar.pack(
            side="right",
            fill="y"
        )

        # ---------------------------------------------------------------
        # MODULES
        # ---------------------------------------------------------------

        all_modules = [

            (
                "allow_sales",
                "📈 Sales & Marketing",
                lambda: self.navigate_to(
                    self.show_sales_marketing_view,
                    view_name="Sales & Marketing"
                ),
            ),

            (
                "allow_production",
                "🏭 Production Process",
                lambda: self.navigate_to(
                    self.show_production_view,
                    view_name="Production"
                ),
            ),

            (
                "allow_project_management",
                "📁 Project Management / Professional Services",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "Project Management / Professional Services",
                    view_name="Project Management"
                ),
            ),

            (
                "allow_qc_qa",
                "✅ Quality Control (QC) / Quality Assurance (QA)",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "Quality Control (QC) / Quality Assurance (QA)",
                    view_name="Quality Control"
                ),
            ),

            (
                "allow_panel_mfg",
                "🔧 Panel Manufacturing",
                lambda: self.navigate_to(
                    self.show_panel_manufacturing_view,
                    view_name="Panel Manufacturing"
                ),
            ),

            (
                "allow_accounts",
                "💰 Accounts & Finance",
                lambda: self.navigate_to(
                    self.show_accounts_finance_view,
                    view_name="Accounts & Finance"
                ),
            ),

            (
                "allow_hr",
                "👥 HR (Human Resources)",
                lambda: self.navigate_to(
                    self.show_hr_view,
                    view_name="Human Resources"
                ),
            ),

            (
                "allow_purchase",
                "🛒 Purchase / Procurement",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "Purchase / Procurement",
                    view_name="Purchase / Procurement"
                ),
            ),

            (
                "allow_stores",
                "📦 Stores / Warehouse",
                lambda: self.navigate_to(
                    self.show_warehouse_view,
                    view_name="Stores / Warehouse"
                ),
            ),

            (
                "allow_maintenance",
                "🛠️ Maintenance",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "Maintenance",
                    view_name="Maintenance"
                ),
            ),

            (
                "allow_rnd",
                "🔬 R&D / Engineering",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "R&D / Engineering",
                    view_name="R&D / Engineering"
                ),
            ),

            (
                "allow_asset_management",
                "🏢 Asset Management / Fixed Assets",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "Asset Management / Fixed Assets",
                    view_name="Asset Management"
                ),
            ),

            (
                "allow_ehs",
                "🛡️ EHS / Risk Management",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "Environment, Health, and Safety (EHS) / Risk Management",
                    view_name="EHS / Risk Management"
                ),
            ),

            (
                "allow_pos_ecommerce",
                "🛍️ Point of Sale (POS) / E-Commerce",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "Point of Sale (POS) / E-Commerce",
                    view_name="POS / E-Commerce"
                ),
            ),

            (
                "allow_it",
                "💻 IT",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "IT",
                    view_name="IT"
                ),
            ),

            (
                "allow_customer_service",
                "🎧 Customer Service",
                lambda: self.navigate_to(
                    self.show_customer_service_view,
                    view_name="Customer Service"
                ),
            ),

            (
                "allow_legal",
                "⚖️ Legal & Compliance",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "Legal & Compliance",
                    view_name="Legal & Compliance"
                ),
            ),

            (
                "allow_admin_dept",
                "📋 Administration",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "Administration",
                    view_name="Administration"
                ),
            ),

            (
                "allow_supply_chain",
                "🚚 Supply Chain / Logistics",
                lambda: self.navigate_to(
                    self.show_generic_department_view,
                    "Supply Chain / Logistics",
                    view_name="Supply Chain / Logistics"
                ),
            ),
        ]

        is_admin = (
            self.user_data.get(
                "role"
            ) == "Admin"
        )

        visible_modules = [
            (
                perm_key,
                label,
                cmd
            )
            for perm_key, label, cmd
            in all_modules
            if (
                is_admin
                or self.user_data.get(
                    perm_key,
                    False
                )
            )
        ]

        if (
            is_admin
            or self.user_data.get(
                "allow_admin",
                False
            )
        ):

            visible_modules.append(
                (
                    "allow_admin",
                    "⚙️ Admin Settings",
                    lambda: self.navigate_to(
                        self.show_admin_settings_view,
                        view_name="Admin Settings"
                    ),
                )
            )

        self._render_module_cards(
            scrollable_frame,
            visible_modules
        )

        def _on_canvas_resize(event):

            canvas.itemconfig(
                canvas_window,
                width=event.width
            )

            self._reflow_module_cards(
                event.width
            )

        canvas.bind(
            "<Configure>",
            _on_canvas_resize
        )

    # ===================================================================
    # MODULE CARDS
    # ===================================================================

    def _render_module_cards(
        self,
        parent,
        modules
    ):

        self._module_card_widgets = []

        for (
            perm_key,
            label,
            cmd
        ) in modules:

            card = self._make_module_card(
                parent,
                label,
                cmd
            )

            self._module_card_widgets.append(
                card
            )

        self._reflow_module_cards(
            parent.winfo_width() or 1000
        )

    def _make_module_card(
        self,
        parent,
        label,
        cmd
    ):

        icon, _, text = label.partition(
            " "
        )

        if not text:

            icon = ""
            text = label

        card = tk.Frame(
            parent,
            bg=CARD_BG,
            highlightbackground=BORDER,
            highlightthickness=1,
            cursor="hand2",
        )

        inner = tk.Frame(
            card,
            bg=CARD_BG
        )

        inner.pack(
            fill="both",
            expand=True,
            padx=16,
            pady=20
        )

        icon_lbl = tk.Label(
            inner,
            text=icon,
            bg=CARD_BG,
            font=("Segoe UI", 22)
        )

        icon_lbl.pack()

        text_lbl = tk.Label(
            inner,
            text=text,
            bg=CARD_BG,
            fg=TEXT,
            font=CARD_FONT,
            wraplength=180,
            justify="center",
        )

        text_lbl.pack(
            pady=(8, 0)
        )

        hoverable = [
            card,
            inner,
            icon_lbl,
            text_lbl
        ]

        def on_enter(event):
            self._animate_hover(
                hoverable,
                True
            )

        def on_leave(event):
            self._animate_hover(
                hoverable,
                False
            )

        def on_press(event):

            try:

                for w in hoverable:
                    w.configure(
                        bg=CARD_HOVER
                    )

                card.configure(
                    highlightbackground=PRIMARY,
                    highlightthickness=2
                )

                card.grid_configure(
                    padx=12,
                    pady=12
                )

            except tk.TclError:
                pass

        def on_release(event):

            try:

                card.grid_configure(
                    padx=10,
                    pady=10
                )

            except tk.TclError:
                pass

            self.root.after(
                110,
                cmd
            )

        for widget in hoverable:

            widget.bind(
                "<Enter>",
                on_enter
            )

            widget.bind(
                "<Leave>",
                on_leave
            )

            widget.bind(
                "<ButtonPress-1>",
                on_press
            )

            widget.bind(
                "<ButtonRelease-1>",
                on_release
            )

        return card

    def _reflow_module_cards(
        self,
        available_width
    ):

        cards = getattr(
            self,
            "_module_card_widgets",
            None
        )

        if not cards:
            return

        card_min_width = 210

        columns = max(
            1,
            min(
                len(cards),
                max(
                    1,
                    available_width //
                    card_min_width
                )
            )
        )

        parent = cards[0].master

        for idx, card in enumerate(cards):

            row, col = divmod(
                idx,
                columns
            )

            card.grid(
                row=row,
                column=col,
                padx=10,
                pady=10,
                sticky="nsew"
            )

        for col in range(columns):

            parent.grid_columnconfigure(
                col,
                weight=1
            )

    # ===================================================================
    # BACK HEADER
    # ===================================================================

    def create_back_header(
        self,
        title_text,
        back_command=None,
        back_text="⬅ Back"
    ):

        header_frame = tk.Frame(
            self.content_frame,
            bg=PRIMARY_DARK
        )

        header_frame.pack(
            fill="x",
            side="top"
        )

        inner = tk.Frame(
            header_frame,
            bg=PRIMARY_DARK
        )

        inner.pack(
            fill="x",
            padx=16,
            pady=10
        )

        # ---------------------------------------------------------------
        # CENTRALIZED BACK BUTTON
        # ---------------------------------------------------------------

        if back_command is None:
            back_command = self.go_back

        back_btn = ttk.Button(
            inner,
            text=back_text,
            style="Ghost.TButton",
        )

        back_btn.configure(
            command=lambda b=back_btn, c=back_command:
            self._button_click_animation(
                b,
                c
            )
        )

        back_btn.pack(
            side="left",
            padx=(0, 8)
        )

        # ---------------------------------------------------------------
        # HOME BUTTON
        # ---------------------------------------------------------------

        home_btn = ttk.Button(
            inner,
            text="🏠 Dashboard",
            style="Ghost.TButton",
        )

        home_btn.configure(
            command=lambda b=home_btn:
            self._button_click_animation(
                b,
                self.go_home
            )
        )

        home_btn.pack(
            side="left",
            padx=(0, 8)
        )

        # ---------------------------------------------------------------
        # HELP
        # ---------------------------------------------------------------

        help_btn = ttk.Button(
            inner,
            text="❓ Help",
            style="Ghost.TButton",
        )

        help_btn.configure(
            command=lambda b=help_btn, c=lambda:
            app_help.open_help_window(
                self.root,
                title_text
            ):
            self._button_click_animation(
                b,
                c
            )
        )

        help_btn.pack(
            side="left",
            padx=(0, 16)
        )

        # ---------------------------------------------------------------
        # BREADCRUMB
        # ---------------------------------------------------------------

        tk.Label(
            inner,
            text="Dashboard",
            bg=PRIMARY_DARK,
            fg="#9FB6DD",
            font=SUBTITLE_FONT
        ).pack(
            side="left"
        )

        tk.Label(
            inner,
            text="  ›  ",
            bg=PRIMARY_DARK,
            fg="#9FB6DD",
            font=SUBTITLE_FONT
        ).pack(
            side="left"
        )

        tk.Label(
            inner,
            text=title_text,
            bg=PRIMARY_DARK,
            fg="white",
            font=HEADER_FONT
        ).pack(
            side="left"
        )

        ttk.Separator(
            self.content_frame,
            orient="horizontal"
        ).pack(
            fill="x",
            pady=(0, 5)
        )

    # ===================================================================
    # PERMISSIONS
    # ===================================================================

    def user_has_permission(
        self,
        permission_key,
        default_value=False
    ):

        if not self.user_data:
            return False

        if (
            self.user_data.get("role")
            == "Admin"
        ):
            return True

        return bool(
            self.user_data.get(
                permission_key,
                default_value
            )
        )

    # ===================================================================
    # SALES
    # ===================================================================

    def show_sales_marketing_view(self):

        if not self.user_has_permission(
            "allow_sales",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open Sales & Marketing.",
                parent=self.root,
            )

            return

        try:

            self.clear_workspace()

            self._set_current_view(
                self.show_sales_marketing_view,
                view_name="Sales & Marketing"
            )

            self.create_back_header(
                "Sales & Marketing Module",
                self.go_back,
                "⬅ Back to Dashboard"
            )

            self.show_product_category_selector(
                register_history=False
            )

        except Exception as e:

            messagebox.showerror(
                "Error Loading View",
                f"Could not load Sales module:\n{e}",
                parent=self.root,
            )

    def show_product_category_selector(
        self,
        register_history=True
    ):

        if register_history:

            if self.current_view is not None:

                self.navigation_stack.append(
                    self.current_view
                )

            self._set_current_view(
                self.show_product_category_selector,
                view_name="Product Categories"
            )

        # ---------------------------------------------------------------
        # IMPORTANT:
        # Do NOT destroy the entire content_frame here.
        # The old implementation removed the Back header.
        # ---------------------------------------------------------------

        for widget in self.content_frame.winfo_children():

            widget.destroy()

        # Recreate navigation header.
        self.create_back_header(
            "Sales & Marketing - Categories",
            self.go_back,
            "⬅ Back to Sales"
        )

        container = ttk.Frame(
            self.content_frame,
            padding=40
        )

        container.pack(
            expand=True
        )

        ttk.Label(
            container,
            text="Select Product Category",
            font=("Helvetica", 16, "bold")
        ).pack(
            pady=(0, 20)
        )

        category_frame = ttk.Frame(
            container
        )

        category_frame.pack()

        categories = [
            "Customer CRM & Leads",
            "Booster Pump Control Panel",
            "STP Panel",
            "Water Meter",
            "BMS"
        ]

        for category in categories:

            btn = ttk.Button(
                category_frame,
                text=category,
                width=30,
                command=lambda cat=category:
                self.navigate_to(
                    self.show_category_content,
                    cat,
                    view_name=f"Sales - {cat}"
                )
            )

            btn.pack(
                pady=10
            )

    def show_category_content(
        self,
        category
    ):

        try:

            from tabs import (
                CrmTab,
                MaterialTab,
                PriceTab
            )

            self.clear_workspace()

            self._set_current_view(
                self.show_category_content,
                category,
                view_name=f"Sales - {category}"
            )

            self.create_back_header(
                f"Sales & Marketing - {category}",
                self.go_back,
                "⬅ Back"
            )

            if category == "Customer CRM & Leads":

                if self.user_has_permission(
                    "allow_crm",
                    False
                ):

                    tab_crm = CrmTab(
                        self.content_frame
                    )

                    tab_crm.pack(
                        fill="both",
                        expand=True
                    )

                else:

                    messagebox.showwarning(
                        "Access Denied",
                        "You do not have permission "
                        "to access Customer CRM & Leads.",
                        parent=self.root,
                    )

                    self.go_back()

            elif category in [
                "Booster Pump Control Panel",
                "STP Panel"
            ]:

                notebook = ttk.Notebook(
                    self.content_frame
                )

                notebook.pack(
                    fill="both",
                    expand=True,
                    padx=5,
                    pady=5
                )

                if self.user_has_permission(
                    "allow_price",
                    True
                ):

                    tab_price = PriceTab(
                        notebook,
                        self,
                        product_category=category
                    )

                    notebook.add(
                        tab_price,
                        text=" Price List Search "
                    )

                if self.user_has_permission(
                    "allow_material",
                    True
                ):

                    tab_material = MaterialTab(
                        notebook
                    )

                    notebook.add(
                        tab_material,
                        text=" Material & Labor Calculator "
                    )

            elif category == "Water Meter":

                from tabs import WaterMeterTab

                tab_water_meter = WaterMeterTab(
                    self.content_frame
                )

                tab_water_meter.pack(
                    fill="both",
                    expand=True
                )

            elif category == "BMS":

                placeholder_frame = ttk.Frame(
                    self.content_frame,
                    padding=40
                )

                placeholder_frame.pack(
                    expand=True
                )

                ttk.Label(
                    placeholder_frame,
                    text=category,
                    font=("Helvetica", 16, "bold")
                ).pack(
                    pady=(0, 20)
                )

                ttk.Label(
                    placeholder_frame,
                    text="This module is under development.",
                    font=("Helvetica", 12)
                ).pack(
                    pady=10
                )

        except Exception as e:

            messagebox.showerror(
                "Error Loading Category",
                f"Could not load {category}:\n{e}",
                parent=self.root,
            )

    # ===================================================================
    # PRODUCTION
    # ===================================================================

    def show_production_view(self):

        if not self.user_has_permission(
            "allow_production",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open Production.",
                parent=self.root,
            )

            return

        try:

            self.clear_workspace()

            self._set_current_view(
                self.show_production_view,
                view_name="Production"
            )

            self.create_back_header(
                "Production Module",
                self.go_back
            )

            production_panel = (
                production_window.ProductionView(
                    self.content_frame,
                    user_data=self.user_data,
                )
            )

            production_panel.pack(
                fill="both",
                expand=True
            )

        except Exception as e:

            messagebox.showerror(
                "Error Loading View",
                f"Could not load Production module:\n{e}",
                parent=self.root,
            )

    # ===================================================================
    # PANEL MANUFACTURING
    # ===================================================================

    def show_panel_manufacturing_view(self):

        if not self.user_has_permission(
            "allow_panel_mfg",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open Panel Manufacturing.",
                parent=self.root,
            )

            return

        try:

            self.clear_workspace()

            self._set_current_view(
                self.show_panel_manufacturing_view,
                view_name="Panel Manufacturing"
            )

            self.create_back_header(
                "Panel Manufacturing Module",
                self.go_back
            )

            mfg_panel = (
                panel_manufacturing.PanelManufacturingView(
                    self.content_frame,
                    user_data=self.user_data
                )
            )

            mfg_panel.pack(
                fill="both",
                expand=True
            )

        except Exception as e:

            messagebox.showerror(
                "Error Loading View",
                f"Could not load Panel Manufacturing module:\n{e}",
                parent=self.root,
            )

    # ===================================================================
    # ACCOUNTS & FINANCE
    # ===================================================================

    def show_accounts_finance_view(self):

        if not self.user_has_permission(
            "allow_accounts",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open Accounts & Finance.",
                parent=self.root,
            )

            return

        try:

            self.clear_workspace()

            self._set_current_view(
                self.show_accounts_finance_view,
                view_name="Accounts & Finance"
            )

            self.create_back_header(
                "Accounts & Finance Module",
                self.go_back
            )

            accounts_panel = (
                accounts_finance.AccountsFinanceView(
                    self.content_frame,
                    user_data=self.user_data,
                    navigator=self
                )
            )

            accounts_panel.pack(
                fill="both",
                expand=True
            )

        except Exception as e:

            messagebox.showerror(
                "Error Loading View",
                f"Could not load Accounts & Finance module:\n{e}",
                parent=self.root,
            )

    # ===================================================================
    # INWARD ENTRY
    # ===================================================================

    def show_inward_entry_page(self):

        if not self.user_has_permission(
            "allow_inward_entry",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open the New Inward Invoice window.",
                parent=self.root,
            )

            return

        self.navigate_to(
            self._show_inward_entry_page_internal,
            view_name="New Inward Invoice"
        )

    def _show_inward_entry_page_internal(self):

        self.clear_workspace()

        self._set_current_view(
            self._show_inward_entry_page_internal,
            view_name="New Inward Invoice"
        )

        self.create_back_header(
            "New Inward Invoice",
            self.go_back,
            "⬅ Back"
        )

        accounts_finance.InwardEntryDialog(
            self.content_frame,
            self.show_accounts_finance_view,
            self.show_accounts_finance_view,
            lambda:
            self.show_vendor_registration_page(
                self.show_inward_entry_page
            )
        ).pack(
            fill="both",
            expand=True,
            padx=12,
            pady=12
        )

    # ===================================================================
    # OUTWARD DOCUMENT
    # ===================================================================

    def show_outward_document_page(self):

        if not self.user_has_permission(
            "allow_outward_document",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open the New Outward Document window.",
                parent=self.root,
            )

            return

        self.navigate_to(
            self._show_outward_document_page_internal,
            view_name="New Outward Document"
        )

    def _show_outward_document_page_internal(self):

        self.clear_workspace()

        self._set_current_view(
            self._show_outward_document_page_internal,
            view_name="New Outward Document"
        )

        self.create_back_header(
            "New Outward Document",
            self.go_back,
            "⬅ Back"
        )

        OutwardWindow(
            self.content_frame,
            on_complete=self.show_accounts_finance_view
        ).pack(
            fill="both",
            expand=True,
            padx=12,
            pady=12
        )

    # ===================================================================
    # VENDOR REGISTRATION
    # ===================================================================

    def show_vendor_registration_page(
        self,
        return_to=None
    ):

        if not self.user_has_permission(
            "allow_vendor_registration",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open Vendor Registration.",
                parent=self.root,
            )

            return

        return_to = (
            return_to
            or self.show_accounts_finance_view
        )

        self.navigate_to(
            self._show_vendor_registration_page_internal,
            return_to,
            view_name="Vendor Registration"
        )

    def _show_vendor_registration_page_internal(
        self,
        return_to
    ):

        self.clear_workspace()

        self._set_current_view(
            self._show_vendor_registration_page_internal,
            return_to,
            view_name="Vendor Registration"
        )

        self.create_back_header(
            "Vendor Registration",
            self.go_back,
            "⬅ Back"
        )

        VendorRegistrationWindow(
            self.content_frame,
            on_complete=return_to
        ).pack(
            fill="both",
            expand=True,
            padx=12,
            pady=12
        )

    # ===================================================================
    # CHEQUE DETAILS
    # ===================================================================

    def show_cheque_details_page(self):

        if not self.user_has_permission(
            "allow_cheque_details",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open Cheque Details.",
                parent=self.root,
            )

            return

        self.navigate_to(
            self._show_cheque_details_page_internal,
            view_name="Cheque Details"
        )

    def _show_cheque_details_page_internal(self):

        self.clear_workspace()

        self._set_current_view(
            self._show_cheque_details_page_internal,
            view_name="Cheque Details"
        )

        self.create_back_header(
            "Cheque Details",
            self.go_back,
            "⬅ Back"
        )

        accounts_finance.ChequeDetailsWindow(
            self.content_frame,
            on_complete=self.show_accounts_finance_view
        ).pack(
            fill="both",
            expand=True,
            padx=12,
            pady=12
        )

    # ===================================================================
    # WAREHOUSE
    # ===================================================================

    def show_warehouse_view(self):

        if not self.user_has_permission(
            "allow_stores",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open Stores / Warehouse.",
                parent=self.root,
            )

            return

        try:

            self.clear_workspace()

            self._set_current_view(
                self.show_warehouse_view,
                view_name="Stores / Warehouse"
            )

            self.create_back_header(
                "Stores / Warehouse Management",
                self.go_back
            )

            warehouse_panel = (
                warehouse_management.WarehouseManagementView(
                    self.content_frame,
                    user_data=self.user_data
                )
            )

            warehouse_panel.pack(
                fill="both",
                expand=True
            )

        except Exception as e:

            messagebox.showerror(
                "Error Loading View",
                f"Could not load Warehouse module:\n{e}",
                parent=self.root,
            )

    # ===================================================================
    # GENERIC DEPARTMENTS
    # ===================================================================

    def show_generic_department_view(
        self,
        dept_name
    ):

        permission_map = {

            "Purchase / Procurement":
                "allow_purchase",

            "Maintenance":
                "allow_maintenance",

            "R&D / Engineering":
                "allow_rnd",

            "IT":
                "allow_it",

            "Information Technology":
                "allow_it",

            "Legal & Compliance":
                "allow_legal",

            "Administration":
                "allow_admin_dept",

            "Supply Chain / Logistics":
                "allow_supply_chain",

            "Customer Service":
                "allow_customer_service",

            "Project Management / Professional Services":
                "allow_project_management",

            "Quality Control (QC) / Quality Assurance (QA)":
                "allow_qc_qa",

            "Asset Management / Fixed Assets":
                "allow_asset_management",

            "Environment, Health, and Safety (EHS) / Risk Management":
                "allow_ehs",

            "EHS / Risk Management":
                "allow_ehs",

            "Point of Sale (POS) / E-Commerce":
                "allow_pos_ecommerce",

            "POS / E-Commerce":
                "allow_pos_ecommerce",
        }

        required_permission = (
            permission_map.get(
                dept_name
            )
        )

        if (
            required_permission
            and not self.user_has_permission(
                required_permission,
                False
            )
        ):

            messagebox.showwarning(
                "Access Denied",
                f"You do not have permission "
                f"to open the {dept_name} module.",
                parent=self.root,
            )

            return

        try:

            self.clear_workspace()

            self._set_current_view(
                self.show_generic_department_view,
                dept_name,
                view_name=dept_name
            )

            self.create_back_header(
                f"{dept_name} Module",
                self.go_back
            )

            # -----------------------------------------------------------
            # PROJECT MANAGEMENT
            # -----------------------------------------------------------

            if (
                "Project Management"
                in dept_name
                or "Professional Services"
                in dept_name
            ):

                try:

                    import project_management

                    pm_panel = (
                        project_management.ProjectManagementView(
                            self.content_frame,
                            user_data=self.user_data
                        )
                    )

                    pm_panel.pack(
                        fill="both",
                        expand=True
                    )

                except Exception as pm_e:

                    messagebox.showerror(
                        "Error Loading Module",
                        f"Could not load Project Management:\n{pm_e}",
                        parent=self.root,
                    )

                return

            # -----------------------------------------------------------
            # R&D
            # -----------------------------------------------------------

            if (
                "R&D"
                in dept_name
                or "Engineering"
                in dept_name
            ):

                rnd_panel = (
                    rnd_engineering.RnDEngineeringView(
                        self.content_frame,
                        user_data=self.user_data
                    )
                )

                rnd_panel.pack(
                    fill="both",
                    expand=True
                )

                return

            # -----------------------------------------------------------
            # SUPPLY CHAIN
            # -----------------------------------------------------------

            if "Supply Chain" in dept_name:

                supply_chain_panel = (
                    supply_chain_logistics.SupplyChainLogisticsView(
                        self.content_frame,
                        user_data=self.user_data
                    )
                )

                supply_chain_panel.pack(
                    fill="both",
                    expand=True
                )

                return

            # -----------------------------------------------------------
            # QUALITY
            # -----------------------------------------------------------

            if (
                "Quality Control"
                in dept_name
                or "Quality Assurance"
                in dept_name
            ):

                quality_panel = (
                    qc_qa.QCQAView(
                        self.content_frame,
                        user_data=self.user_data
                    )
                )

                quality_panel.pack(
                    fill="both",
                    expand=True
                )

                return

            # -----------------------------------------------------------
            # LEGAL
            # -----------------------------------------------------------

            if "Legal" in dept_name:

                legal_panel = (
                    legal_compliance.LegalComplianceView(
                        self.content_frame,
                        user_data=self.user_data
                    )
                )

                legal_panel.pack(
                    fill="both",
                    expand=True
                )

                return

            # -----------------------------------------------------------
            # MAINTENANCE
            # -----------------------------------------------------------

            if "Maintenance" in dept_name:

                maintenance_panel = (
                    maintenance.MaintenanceView(
                        self.content_frame,
                        user_data=self.user_data
                    )
                )

                maintenance_panel.pack(
                    fill="both",
                    expand=True
                )

                return

            # -----------------------------------------------------------
            # IT
            # -----------------------------------------------------------

            if (
                "IT" in dept_name
                or "Information Technology"
                in dept_name
            ):

                it_panel = (
                    it_workspace.ITWorkspaceView(
                        self.content_frame,
                        user_data=self.user_data
                    )
                )

                it_panel.pack(
                    fill="both",
                    expand=True
                )

                return

            # -----------------------------------------------------------
            # WAREHOUSE
            # -----------------------------------------------------------

            if (
                "Stores" in dept_name
                or "Warehouse" in dept_name
            ):

                warehouse_panel = (
                    warehouse_management.WarehouseManagementView(
                        self.content_frame,
                        user_data=self.user_data
                    )
                )

                warehouse_panel.pack(
                    fill="both",
                    expand=True
                )

                return

            # -----------------------------------------------------------
            # GENERIC PLACEHOLDER
            # -----------------------------------------------------------

            dept_frame = ttk.Frame(
                self.content_frame,
                padding=30
            )

            dept_frame.pack(
                fill="both",
                expand=True
            )

            ttk.Label(
                dept_frame,
                text=f"{dept_name} Workspace",
                font=("Helvetica", 14, "bold"),
            ).pack(
                pady=(0, 15)
            )

            ttk.Label(
                dept_frame,
                text=(
                    f"Welcome to the {dept_name} "
                    "dashboard management system."
                ),
                font=("Helvetica", 11),
            ).pack(
                pady=(0, 20)
            )

            info_box = ttk.LabelFrame(
                dept_frame,
                text=" Department Status ",
                padding=15
            )

            info_box.pack(
                fill="x",
                padx=10,
                pady=10
            )

            ttk.Label(
                info_box,
                text="• Module Active: Yes"
            ).pack(
                anchor="w",
                pady=2
            )

            ttk.Label(
                info_box,
                text=(
                    "• User Role Access: "
                    f"{self.user_data.get('role', 'User')}"
                )
            ).pack(
                anchor="w",
                pady=2
            )

            ttk.Label(
                info_box,
                text=(
                    "• Current Active User: "
                    f"{self.user_data.get('full_name', self.user_data.get('username'))}"
                )
            ).pack(
                anchor="w",
                pady=2
            )

        except Exception as e:

            messagebox.showerror(
                "Error Loading View",
                f"Could not load {dept_name} module:\n{e}",
                parent=self.root,
            )

    # ===================================================================
    # CUSTOMER SERVICE
    # ===================================================================

    def show_customer_service_view(self):

        if not self.user_has_permission(
            "allow_customer_service",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open Customer Service.",
                parent=self.root,
            )

            return

        try:

            self.clear_workspace()

            self._set_current_view(
                self.show_customer_service_view,
                view_name="Customer Service"
            )

            self.create_back_header(
                "Customer Service Module",
                self.go_back
            )

            panel = (
                customer_service.CustomerServiceView(
                    self.content_frame,
                    user_data=self.user_data
                )
            )

            panel.pack(
                fill="both",
                expand=True
            )

        except Exception as e:

            messagebox.showerror(
                "Error Loading View",
                f"Could not load Customer Service module:\n{e}",
                parent=self.root,
            )

    # ===================================================================
    # HR
    # ===================================================================

    def show_hr_view(self):

        if not self.user_has_permission(
            "allow_hr",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open HR.",
                parent=self.root,
            )

            return

        try:

            self.clear_workspace()

            self._set_current_view(
                self.show_hr_view,
                view_name="Human Resources"
            )

            self.create_back_header(
                "Human Resources",
                self.go_back
            )

            hr_window.HRView(
                self.content_frame,
                user_data=self.user_data
            ).pack(
                fill="both",
                expand=True
            )

        except Exception as e:

            messagebox.showerror(
                "Error Loading View",
                f"Could not load HR module:\n{e}",
                parent=self.root,
            )

    # ===================================================================
    # ADMIN SETTINGS
    # ===================================================================

    def show_admin_settings_view(self):

        if not self.user_has_permission(
            "allow_admin",
            False
        ):

            messagebox.showwarning(
                "Access Denied",
                "You do not have permission "
                "to open Admin Settings.",
                parent=self.root,
            )

            return

        try:

            from tabs.admin_tab import AdminTab

            self.clear_workspace()

            self._set_current_view(
                self.show_admin_settings_view,
                view_name="Administration Settings"
            )

            self.create_back_header(
                "Administration Settings & Access Controls",
                self.go_back
            )

            admin_view = AdminTab(
                self.content_frame
            )

            admin_view.pack(
                fill="both",
                expand=True,
                padx=10,
                pady=10
            )

        except Exception as e:

            messagebox.showerror(
                "Error Loading View",
                f"Could not load Admin module:\n{e}",
                parent=self.root,
            )


# ---------------------------------------------------------------------------
# APPLICATION ENTRY POINT
# ---------------------------------------------------------------------------

if __name__ == "__main__":

    root = tk.Tk()

    app = MainApp(
        root
    )

    root.mainloop()