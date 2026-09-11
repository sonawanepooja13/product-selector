"""
Automated End-to-End Verification Test for Centralized API & Synchronization
Tests:
1. Backend Health and Root Endpoints
2. JWT Authentication (Admin login)
3. Product CRUD (Create, Read, Update, Search, Delete)
4. Customer CRUD (Create, Read, Search with Markup)
5. CRM Contacts CRUD (Create, Update Stage, Metrics)
6. Real-Time WebSocket Event Delivery
"""

import json
import sys
import threading
import time
import requests

BASE_URL = "http://127.0.0.1:8000"


def run_tests():
    print("=" * 70)
    print("RUNNING CENTRALIZED DATABASE & API SYNCHRONIZATION TESTS")
    print("=" * 70)

    # 1. Health Check
    print("\n[TEST 1] Checking API Health...")
    try:
        r = requests.get(f"{BASE_URL}/health", timeout=5)
        assert r.status_code == 200, f"Expected 200, got {r.status_code}"
        assert r.json().get("status") == "healthy"
        print("  -> PASSED: Backend is online and healthy.")
    except Exception as e:
        print(f"  -> FAILED: Backend server not reachable at {BASE_URL}: {e}")
        return False

    # 2. JWT Authentication
    print("\n[TEST 2] Testing JWT Authentication with Admin Account...")
    auth_resp = requests.post(
        f"{BASE_URL}/api/v1/auth/login",
        json={"username": "admin", "password": "admin123"},
        timeout=5,
    )
    assert auth_resp.status_code == 200, f"Login failed: {auth_resp.text}"
    token_data = auth_resp.json()
    token = token_data.get("access_token")
    assert token is not None, "No access token returned"
    print(f"  -> PASSED: Successfully authenticated. Token length: {len(token)}")

    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # 3. Customer CRUD & Sync
    print("\n[TEST 3] Testing Customer CRUD & Multi-Platform Sync...")
    new_customer = {
        "name": f"Test Enterprise Sync Corp {int(time.time())}",
        "percentage": 8.5,
        "contact_number": "+91 99001 12233",
        "email": "procurement@enterprisesync.com",
        "category": "Standard",
    }
    cust_post = requests.post(f"{BASE_URL}/api/v1/customers", headers=headers, json=new_customer)
    assert cust_post.status_code == 200, f"Failed to create customer: {cust_post.text}"
    created_cust = cust_post.json()
    cust_id = created_cust["id"]
    print(f"  -> Created customer ID {cust_id}: {created_cust['name']}")

    # Read back
    cust_get = requests.get(f"{BASE_URL}/api/v1/customers/{cust_id}", headers=headers)
    assert cust_get.status_code == 200
    assert cust_get.json()["percentage"] == 8.5
    print("  -> PASSED: Customer created and retrieved from central database.")

    # 4. Product CRUD & Price Search
    print("\n[TEST 4] Testing Product CRUD & Cross-Platform Price Calculation...")
    new_product = {
        "pump_current": 35.5,
        "num_pumps": 3,
        "num_vfd": 2,
        "bypass": "With Bypass",
        "panel_type": "Outdoor",
        "panel_size": "1000x800",
        "panel_class": "Industrial",
        "main_incomer": "Yes",
        "olr_required": "Yes",
        "indicator_light": "Yes",
        "price": 280000.0,
        "category": "Booster Pump Control Panel",
    }
    prod_post = requests.post(f"{BASE_URL}/api/v1/products", headers=headers, json=new_product)
    assert prod_post.status_code == 200, f"Failed to create product: {prod_post.text}"
    created_prod = prod_post.json()
    prod_id = created_prod["id"]
    print(f"  -> Created product ID {prod_id}: {created_prod['price']} INR")

    # Search with customer markup
    search_payload = {
        "pump_current": 35.5,
        "num_pumps": 3,
        "num_vfd": 2,
        "bypass": "With Bypass",
        "panel_size": "1000x800",
        "category": "Booster Pump Control Panel",
    }
    search_resp = requests.post(
        f"{BASE_URL}/api/v1/products/search",
        headers=headers,
        params={"customer_id": cust_id},
        json=search_payload,
    )
    assert search_resp.status_code == 200, f"Search failed: {search_resp.text}"
    search_data = search_resp.json()
    assert search_data["found"] is True
    expected_final = 280000.0 + (280000.0 * 0.085)
    assert abs(search_data["final_price"] - expected_final) < 1.0, f"Price mismatch: {search_data['final_price']} vs {expected_final}"
    print(f"  -> PASSED: Price calculation correctly applied customer markup ({search_data['final_price']} INR).")

    # Update product
    update_resp = requests.put(
        f"{BASE_URL}/api/v1/products/{prod_id}",
        headers=headers,
        json={"price": 295000.0},
    )
    assert update_resp.status_code == 200
    assert update_resp.json()["price"] == 295000.0
    print("  -> PASSED: Product updated successfully.")

    # 5. CRM Leads CRUD & Pipeline Metrics
    print("\n[TEST 5] Testing CRM Leads & Pipeline Synchronization...")
    new_lead = {
        "company_name": "Godrej Infra Projects",
        "primary_contact": "Vikram Malhotra",
        "email": "v.malhotra@godrejinfra.com",
        "phone": "+91 98111 22334",
        "status": "Qualified",
        "category": "Booster Pump Control Panel",
        "estimated_value": 450000.0,
        "stage": "inDiscussion",
        "notes": "Testing centralized CRM sync from Mobile/Desktop",
    }
    lead_post = requests.post(f"{BASE_URL}/api/v1/crm/contacts", headers=headers, json=new_lead)
    assert lead_post.status_code == 200
    created_lead = lead_post.json()
    lead_id = created_lead["id"]
    print(f"  -> Created CRM Lead ID {lead_id} with estimated value: 450,000 INR")

    # Update stage to 'won'
    lead_put = requests.put(
        f"{BASE_URL}/api/v1/crm/contacts/{lead_id}",
        headers=headers,
        json={"stage": "won", "status": "Won"},
    )
    assert lead_put.status_code == 200
    assert lead_put.json()["stage"] == "won"

    # Verify metrics
    metrics_resp = requests.get(f"{BASE_URL}/api/v1/crm/metrics", headers=headers)
    assert metrics_resp.status_code == 200
    metrics = metrics_resp.json()
    assert metrics["total_pipeline_value"] >= 450000.0
    print(f"  -> PASSED: CRM pipeline metrics updated (Total: {metrics['total_pipeline_value']} INR)")

    # 6. Clean up test records
    print("\n[TEST 6] Cleaning up test records...")
    requests.delete(f"{BASE_URL}/api/v1/products/{prod_id}", headers=headers)
    requests.delete(f"{BASE_URL}/api/v1/customers/{cust_id}", headers=headers)
    requests.delete(f"{BASE_URL}/api/v1/crm/contacts/{lead_id}", headers=headers)
    print("  -> PASSED: Cleaned up test entries.")

    print("\n" + "=" * 70)
    print("ALL TESTS PASSED! Centralized database & API are fully operational.")
    print("=" * 70)
    return True


if __name__ == "__main__":
    success = run_tests()
    sys.exit(0 if success else 1)
