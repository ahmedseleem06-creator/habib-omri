"""
Habib Omri - Server Unit & Integration Test
"""
import unittest
import hashlib
from fastapi.testclient import TestClient
from main import app, init_db, get_db

class TestHabibOmriServer(unittest.TestCase):
    def setUp(self):
        init_db()
        self.client = TestClient(app)

    def test_home(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertIn("حبيب عمري", response.json()["app"])

    def test_login_success(self):
        response = self.client.post("/api/login", json={
            "phone": "01000000001",
            "pin": "1234"
        })
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(data["success"])
        self.assertEqual(data["user"]["phone"], "01000000001")

    def test_login_wrong_pin(self):
        response = self.client.post("/api/login", json={
            "phone": "01000000001",
            "pin": "0000"
        })
        self.assertEqual(response.status_code, 401)

    def test_login_unregistered_phone(self):
        response = self.client.post("/api/login", json={
            "phone": "01234567890",
            "pin": "1234"
        })
        self.assertEqual(response.status_code, 403)

if __name__ == "__main__":
    unittest.main()
