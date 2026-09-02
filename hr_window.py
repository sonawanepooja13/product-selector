"""Full-screen Human Resources workspace with local CSV registers."""

import csv
import os
import tkinter as tk
from datetime import date, datetime
from tkinter import filedialog, messagebox, ttk

import config
from tkcalendar import DateEntry


DEPARTMENTS = ("Production", "R&D", "Panel Department", "Office", "Sales", "Marketing", "HR", "Accounts", "Other")
EMPLOYMENT_TYPES = ("Full-time", "Part-time", "Contractor", "Intern")

HR_TABS = (
    ("Employee Profile", "employees", (
        ("Employee ID", "employee_id"), ("First Name", "first_name"), ("Last Name", "last_name"), ("Full Name", "full_name"), ("Work Email", "work_email"), ("Date of Birth", "date_of_birth"),
        ("Gender", "gender"), ("Marital Status", "marital_status"), ("Nationality", "nationality"),
        ("Blood Group", "blood_group"), ("Emergency Contact", "emergency_contact"),
        ("Personal Email", "personal_email"), ("Phone Number", "phone_number"), ("Current Address", "current_address"),
        ("Permanent Address", "permanent_address"), ("Department", "department"), ("Designation / Title", "designation"),
        ("Reporting Manager ID", "reporting_manager"), ("Date of Joining", "date_of_joining"), ("Employment Type", "employment_type"), ("Employment Status", "employment_status"), ("Created At", "created_at"),
        ("Work Location / Branch", "work_location"), ("Resume / CV", "resume_cv"), ("Signed Offer Letter", "offer_letter"),
        ("Employment Contract", "employment_contract"), ("NDA", "nda"), ("Government ID Proofs", "government_id"), ("Photograph", "photograph"),
    )),
    ("Employee Documents", "employee_documents", (
        ("Document ID", "document_id"), ("Employee ID", "employee_id"), ("Document Type", "document_type"),
        ("Document File", "file_path"), ("Uploaded At", "uploaded_at"),
    )),
    ("Recruitment (ATS)", "recruitment", (
        ("Job ID", "job_id"), ("Job Title", "job_title"), ("Department", "department"), ("Open Positions", "open_positions"),
        ("Minimum Salary", "min_salary"), ("Maximum Salary", "max_salary"), ("Job Status", "job_status"), ("Job Description", "job_description"), ("Required Skills", "required_skills"),
        ("Hiring Manager", "hiring_manager"), ("Candidate ID", "candidate_id"), ("Candidate First Name", "candidate_first_name"), ("Candidate Last Name", "candidate_last_name"), ("Candidate Name", "candidate_name"), ("Candidate Email", "candidate_email"),
        ("Candidate Phone", "candidate_phone"), ("Resume File", "resume_file"), ("Cover Letter", "cover_letter"),
        ("Source", "source"), ("Current Stage", "current_stage"), ("Interview Rounds", "interview_rounds"), ("Interviewer Feedback / Score", "feedback_score"),
        ("Interview Date", "interview_date"), ("Offer Status", "offer_status"),
    )),
    ("Interviews", "interviews", (
        ("Interview ID", "interview_id"), ("Candidate ID", "candidate_id"), ("Interviewer Employee ID", "interviewer_id"),
        ("Scheduled Date / Time", "scheduled_time"), ("Score", "score"), ("Feedback", "feedback"), ("Interview Status", "interview_status"),
    )),
    ("Shift Setup", "shifts", (
        ("Shift ID", "shift_id"), ("Shift Name", "shift_name"), ("Start Time", "start_time"),
        ("End Time", "end_time"), ("Grace Period (Minutes)", "grace_period_minutes"),
    )),
    ("Attendance & Leave", "attendance_leave", (
        ("Employee ID", "employee_id"), ("Employee Name", "employee_name"), ("Attendance Date", "attendance_date"),
        ("Clock In", "clock_in"), ("Clock Out", "clock_out"), ("Total Work Hours", "total_work_hours"),
        ("IP / Geo-location", "location"), ("Attendance Status", "attendance_status"), ("Attendance Source", "attendance_source"),
        ("Over / Under Logged Hours", "logged_hours"), ("Shift ID / Schedule", "shift_schedule"),
    )),
    ("Leave Types", "leave_types", (
        ("Leave Type ID", "leave_type_id"), ("Leave Name", "leave_name"), ("Default Quota (Days)", "default_quota"), ("Carry Forward", "carry_forward"),
    )),
    ("Leave Balances", "leave_balances", (
        ("Balance ID", "balance_id"), ("Employee ID", "employee_id"), ("Leave Type ID", "leave_type_id"),
        ("Year", "year"), ("Allocated Days", "allocated_days"), ("Used Days", "used_days"), ("Remaining Days", "remaining_days"),
    )),
    ("Leave Requests", "leave_requests", (
        ("Request ID", "request_id"), ("Employee ID", "employee_id"), ("Leave Type ID", "leave_type_id"),
        ("Start Date", "start_date"), ("End Date", "end_date"), ("Total Days", "total_days"), ("Reason", "reason"),
        ("Status", "approval_status"), ("Approved By (Employee ID)", "approved_by"), ("Created At", "created_at"),
        ("Medical Certificate", "medical_certificate"), ("Approved Leave Form", "leave_form"),
    )),
    ("Payroll & Compensation", "payroll", (
        ("Employee ID", "employee_id"), ("Employee Name", "employee_name"), ("Effective Month", "effective_month"),
        ("Base Salary", "base_salary"), ("HRA", "hra"), ("Allowances", "allowances"), ("Bonus", "bonus"), ("Incentive", "incentive"), ("Effective From", "effective_from"),
        ("Overpay / Deductions", "deductions"), ("Bank Account Number", "bank_account"), ("Bank Name", "bank_name"),
        ("SWIFT / IFSC Code", "ifsc_code"), ("Tax / PF / Social Security ID", "tax_pf_id"), ("Tax Declaration", "tax_declaration"),
        ("Monthly Payslip", "payslip"), ("Tax Statement", "tax_statement"), ("Salary Revision Letter", "revision_letter"),
        ("Loan / Advance Request", "loan_advance"), ("Repayment Log", "repayment_log"),
    )),
    ("Payroll Runs", "payroll_runs", (
        ("Payroll ID", "payroll_id"), ("Employee ID", "employee_id"), ("Pay Period Month", "pay_period_month"),
        ("Pay Period Year", "pay_period_year"), ("Gross Salary", "gross_salary"), ("Total Deductions", "total_deductions"),
        ("Net Salary", "net_salary"), ("Payment Status", "payment_status"), ("Payment Date", "payment_date"),
    )),
    ("Performance & Goals", "performance", (
        ("Goal ID", "goal_id"), ("Employee ID", "employee_id"), ("Employee Name", "employee_name"), ("Goal Title / Objective", "objective"),
        ("Goal Description", "goal_description"), ("Key Result", "key_result"), ("Target Completion Date", "target_date"), ("Progress %", "progress_percentage"), ("Weightage", "weightage"),
        ("Goal Status", "goal_status"), ("Self Evaluation", "self_evaluation"), ("Manager Review", "manager_review"),
        ("Peer / 360 Feedback", "peer_feedback"), ("Feedback Score", "feedback_score"), ("PIP Document", "pip_document"),
        ("Appraisal Letter", "appraisal_letter"), ("Promotion / Demotion Letter", "promotion_letter"), ("Training Certificate", "training_certificate"),
    )),
    ("Appraisals", "appraisals", (
        ("Appraisal ID", "appraisal_id"), ("Employee ID", "employee_id"), ("Reviewer Employee ID", "reviewer_id"),
        ("Review Cycle", "review_cycle"), ("Self Rating", "self_rating"), ("Manager Rating", "manager_rating"),
        ("Final Comments", "final_comments"), ("Appraisal Status", "appraisal_status"),
    )),
    ("Learning & Development", "learning", (
        ("Course Title", "course_title"), ("Description", "description"), ("Assigned Participants", "participants"),
        ("Completion Status", "completion_status"), ("Due Date", "due_date"), ("Completion Certificate", "certificate"),
        ("Training Feedback Form", "feedback_form"), ("External Certification Receipt", "certification_receipt"),
    )),
    ("Offboarding & Separation", "offboarding", (
        ("Employee ID", "employee_id"), ("Employee Name", "employee_name"), ("Resignation Date", "resignation_date"),
        ("Last Working Day", "last_working_day"), ("Reason for Leaving", "leaving_reason"), ("IT Clearance", "it_clearance"),
        ("Finance Clearance", "finance_clearance"), ("HR Clearance / Exit Notes", "hr_clearance"), ("Resignation Letter", "resignation_letter"),
        ("Resignation Acceptance", "acceptance_letter"), ("Exit Interview Form", "exit_interview"),
        ("F&F Settlement Statement", "final_settlement"), ("Experience / Relieving Letter", "relieving_letter"),
    )),
)


def csv_path(register):
    return os.path.join(config.CSV_DIR, f"hr_{register}.csv")


class HRRegisterTab(ttk.Frame):
    def __init__(self, parent, title, register, fields):
        super().__init__(parent, padding=12)
        self.title, self.register, self.fields = title, register, fields
        self.headers = [key for _label, key in fields]
        self.vars = {key: tk.StringVar() for key in self.headers}
        self._build()
        self.load_records()

    def _build(self):
        self.columnconfigure(0, weight=1)
        self.rowconfigure(1, weight=1)
        ttk.Label(self, text=self.title, font=("Helvetica", 14, "bold")).grid(row=0, column=0, sticky="w", pady=(0, 8))
        outer = ttk.PanedWindow(self, orient="vertical")
        outer.grid(row=1, column=0, sticky="nsew")
        form_box = ttk.LabelFrame(outer, text=" Add / Update Record ", padding=10)
        list_box = ttk.LabelFrame(outer, text=" Saved Records ", padding=8)
        outer.add(form_box, weight=3)
        outer.add(list_box, weight=2)
        for column in (1, 3):
            form_box.columnconfigure(column, weight=1)
        for index, (label, key) in enumerate(self.fields):
            row, group = divmod(index, 2)
            column = group * 2
            ttk.Label(form_box, text=f"{label}:").grid(row=row, column=column, sticky="w", padx=(0, 7), pady=4)
            widget = self.make_widget(form_box, key)
            widget.grid(row=row, column=column + 1, sticky="ew", padx=(0, 12) if group == 0 else (0, 0), pady=4)
        actions = ttk.Frame(form_box)
        actions.grid(row=(len(self.fields) + 1) // 2, column=0, columnspan=4, sticky="e", pady=(10, 0))
        ttk.Button(actions, text="Clear", command=self.clear_form).pack(side="right")
        ttk.Button(actions, text="Save Record", command=self.save).pack(side="right", padx=(0, 8))

        visible = self.headers[:6]
        self.tree = ttk.Treeview(list_box, columns=visible, show="headings", height=7)
        for key in visible:
            label = next(label for label, field_key in self.fields if field_key == key)
            self.tree.heading(key, text=label)
            self.tree.column(key, width=180, anchor="w")
        scroll = ttk.Scrollbar(list_box, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=scroll.set)
        self.tree.pack(side="left", fill="both", expand=True)
        scroll.pack(side="right", fill="y")

    def make_widget(self, parent, key):
        if key in {"department"}:
            return ttk.Combobox(parent, textvariable=self.vars[key], values=DEPARTMENTS)
        if key == "employment_type":
            return ttk.Combobox(parent, textvariable=self.vars[key], values=EMPLOYMENT_TYPES, state="readonly")
        if key == "employment_status":
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Active", "On-Leave", "Terminated", "Resigned"), state="readonly")
        if key in {"gender"}:
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Female", "Male", "Non-binary", "Prefer not to say"), state="readonly")
        if key in {"offer_status"}:
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Pending", "Accepted", "Rejected"), state="readonly")
        if key == "job_status":
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Draft", "Open", "On-Hold", "Closed"), state="readonly")
        if key == "current_stage":
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Applied", "Screening", "Interview", "Offered", "Hired", "Rejected"), state="readonly")
        if key == "interview_status":
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Scheduled", "Completed", "Cancelled"), state="readonly")
        if key in {"approval_status"}:
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Pending", "Approved", "Rejected"), state="readonly")
        if key in {"goal_status"}:
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Not Started", "In Progress", "On Track", "Completed", "Delayed"), state="readonly")
        if key == "attendance_status":
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Present", "Absent", "Half-Day", "Late", "On-Leave"), state="readonly")
        if key == "attendance_source":
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Web", "Mobile", "Biometric Device", "Manual Override"), state="readonly")
        if key == "payment_status":
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Pending", "Processed", "Failed"), state="readonly")
        if key == "appraisal_status":
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Draft", "Submitted", "Approved", "Locked"), state="readonly")
        if key in {"completion_status"}:
            return ttk.Combobox(parent, textvariable=self.vars[key], values=("Assigned", "In Progress", "Completed", "Overdue"), state="readonly")
        if "date" in key or key in {"target_date", "due_date", "last_working_day"}:
            self.vars[key].set(date.today().isoformat())
            return DateEntry(parent, textvariable=self.vars[key], date_pattern="yyyy-mm-dd")
        if key in {"created_at", "uploaded_at"}:
            self.vars[key].set(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
            return ttk.Entry(parent, textvariable=self.vars[key], state="readonly")
        if any(word in key for word in ("file", "document", "letter", "certificate", "form", "photograph", "resume", "contract", "nda", "government_id", "payslip", "statement", "receipt")):
            box = ttk.Frame(parent)
            box.columnconfigure(0, weight=1)
            ttk.Entry(box, textvariable=self.vars[key]).grid(row=0, column=0, sticky="ew")
            ttk.Button(box, text="Attach", command=lambda field=key: self.attach(field)).grid(row=0, column=1, padx=(5, 0))
            return box
        return ttk.Entry(parent, textvariable=self.vars[key])

    def attach(self, key):
        path = filedialog.askopenfilename(parent=self, title="Select document", filetypes=(("All files", "*.*"),))
        if path:
            self.vars[key].set(path)

    def ensure_file(self):
        path = csv_path(self.register)
        if not os.path.exists(path):
            with open(path, "w", newline="", encoding="utf-8") as file:
                csv.DictWriter(file, fieldnames=self.headers).writeheader()
        return path

    def save(self):
        identity_keys = ("employee_id", "candidate_id", "job_id", "document_id", "interview_id", "shift_id", "leave_type_id", "balance_id", "request_id", "payroll_id", "goal_id", "appraisal_id", "course_title")
        identity = next((self.vars[key] for key in identity_keys if key in self.vars), None)
        if not identity or not identity.get().strip():
            messagebox.showwarning("Required Details", "Enter the primary record name or employee ID before saving.", parent=self)
            return
        for key in ("created_at", "uploaded_at"):
            if key in self.vars:
                self.vars[key].set(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        with open(self.ensure_file(), "a", newline="", encoding="utf-8") as file:
            csv.DictWriter(file, fieldnames=self.headers).writerow({key: value.get().strip() for key, value in self.vars.items()})
        self.load_records()
        self.clear_form()
        messagebox.showinfo("Saved", f"{self.title} record saved successfully.", parent=self)

    def load_records(self):
        for item in self.tree.get_children():
            self.tree.delete(item)
        with open(self.ensure_file(), newline="", encoding="utf-8") as file:
            for row in csv.DictReader(file):
                self.tree.insert("", "end", values=[row.get(key, "") for key in self.headers[:6]])

    def clear_form(self):
        for key, value in self.vars.items():
            if "date" not in key and key not in {"target_date", "due_date", "last_working_day"}:
                value.set("")
        for key in ("created_at", "uploaded_at"):
            if key in self.vars:
                self.vars[key].set(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))


class HRView(ttk.Frame):
    def __init__(self, parent, user_data=None):
        super().__init__(parent, padding=14)
        ttk.Label(self, text="Human Resources", font=("Helvetica", 16, "bold")).pack(anchor="w")
        ttk.Label(self, text="Employee records, recruitment, attendance, payroll, performance, training, and separation.").pack(anchor="w", pady=(2, 10))
        notebook = ttk.Notebook(self)
        notebook.pack(fill="both", expand=True)
        for title, register, fields in HR_TABS:
            tab = HRRegisterTab(notebook, title, register, fields)
            notebook.add(tab, text=f" {title} ")
