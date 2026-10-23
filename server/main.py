"""
Habib Omri (حبيب عمري) - Python Backend Server
FastAPI + WebSockets + SQLite for private romantic messaging
"""

import os
import json
import time
import hashlib
from datetime import datetime
from typing import Dict, List, Optional
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, Depends, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import sqlite3

# -------------------------------------------------------------
# Configuration & Constants
# -------------------------------------------------------------
DB_FILE = "habib_omri.db"
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Default pre-configured partners (User can change these numbers anytime)
DEFAULT_USERS = {
    "01000000001": {
        "name": "حبيب قلبي",
        "role": "husband",
        "pin": "1234" # Default PIN on first login
    },
    "01000000002": {
        "name": "مروة عمري",
        "role": "fiancee",
        "pin": "1234" # Default PIN on first login
    }
}

app = FastAPI(title="Habib Omri Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# -------------------------------------------------------------
# Database Setup
# -------------------------------------------------------------
def get_db():
    conn = sqlite3.connect(DB_FILE, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    cursor = conn.cursor()
    # Users table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            phone TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            pin_hash TEXT NOT NULL,
            role TEXT NOT NULL,
            avatar_url TEXT DEFAULT '',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    # Messages table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender_phone TEXT NOT NULL,
            receiver_phone TEXT NOT NULL,
            content TEXT NOT NULL,
            msg_type TEXT DEFAULT 'text',
            media_url TEXT DEFAULT '',
            status TEXT DEFAULT 'sent', -- sent, delivered, read
            timestamp REAL NOT NULL,
            is_liked INTEGER DEFAULT 0
        )
    """)
    conn.commit()

    # Seed default users if empty
    cursor.execute("SELECT COUNT(*) as count FROM users")
    if cursor.fetchone()["count"] == 0:
        for phone, data in DEFAULT_USERS.items():
            pin_hash = hashlib.sha256(data["pin"].encode()).hexdigest()
            cursor.execute(
                "INSERT INTO users (phone, name, pin_hash, role) VALUES (?, ?, ?, ?)",
                (phone, data["name"], pin_hash, data["role"])
            )
        conn.commit()
    conn.close()

init_db()

# -------------------------------------------------------------
# Models
# -------------------------------------------------------------
class LoginRequest(BaseModel):
    phone: str
    pin: str

class UpdatePinRequest(BaseModel):
    phone: str
    old_pin: str
    new_pin: str

class MessageSend(BaseModel):
    sender_phone: str
    content: str
    msg_type: str = "text"
    media_url: str = ""

# -------------------------------------------------------------
# WebSocket Connection Manager
# -------------------------------------------------------------
class ConnectionManager:
    def __init__(self):
        # Maps phone -> WebSocket
        self.active_connections: Dict[str, WebSocket] = {}

    async def connect(self, phone: str, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[phone] = websocket
        # Notify the other partner that someone is online
        await self.broadcast_presence(phone, is_online=True)

    def disconnect(self, phone: str):
        if phone in self.active_connections:
            del self.active_connections[phone]

    async def broadcast_presence(self, phone: str, is_online: bool):
        # Find partner phone
        partner_phone = self.get_partner_phone(phone)
        if partner_phone and partner_phone in self.active_connections:
            try:
                await self.active_connections[partner_phone].send_json({
                    "event": "presence",
                    "phone": phone,
                    "is_online": is_online,
                    "last_seen": time.time()
                })
            except Exception:
                pass

    def get_partner_phone(self, phone: str) -> Optional[str]:
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT phone FROM users WHERE phone != ?", (phone,))
        row = cursor.fetchone()
        conn.close()
        return row["phone"] if row else None

    async def send_to_user(self, phone: str, message: dict):
        if phone in self.active_connections:
            try:
                await self.active_connections[phone].send_json(message)
                return True
            except Exception:
                self.disconnect(phone)
        return False

manager = ConnectionManager()

# -------------------------------------------------------------
# REST Endpoints
# -------------------------------------------------------------
@app.get("/")
def home():
    return {
        "app": "حبيب عمري (Habib Omri)",
        "status": "Online & Ready ❤️",
        "timestamp": datetime.now().isoformat()
    }

@app.post("/api/login")
def login(req: LoginRequest):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE phone = ?", (req.phone,))
    user = cursor.fetchone()

    if not user:
        conn.close()
        raise HTTPException(status_code=403, detail="هذا الرقم غير مسجل في تطبيق حبيب عمري")

    pin_hash = hashlib.sha256(req.pin.encode()).hexdigest()
    if user["pin_hash"] != pin_hash:
        conn.close()
        raise HTTPException(status_code=401, detail="الرقم السري غير صحيح")

    # Get partner info
    cursor.execute("SELECT phone, name, avatar_url FROM users WHERE phone != ?", (req.phone,))
    partner = cursor.fetchone()
    conn.close()

    return {
        "success": True,
        "user": {
            "phone": user["phone"],
            "name": user["name"],
            "role": user["role"],
            "avatar_url": user["avatar_url"]
        },
        "partner": {
            "phone": partner["phone"] if partner else "",
            "name": partner["name"] if partner else "حبيبتي",
            "avatar_url": partner["avatar_url"] if partner else ""
        }
    }

@app.get("/api/messages")
def get_messages(phone: str, limit: int = 100):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT * FROM messages
        WHERE sender_phone = ? OR receiver_phone = ?
        ORDER BY timestamp ASC
        LIMIT ?
    """, (phone, phone, limit))
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

@app.post("/api/upload")
async def upload_file(file: UploadFile = File(...)):
    ext = os.path.splitext(file.filename)[1].lower() if file.filename else ".jpg"
    filename = f"{int(time.time() * 1000)}{ext}"
    filepath = os.path.join(UPLOAD_DIR, filename)

    with open(filepath, "wb") as f:
        while chunk := await file.read(1024 * 1024): # 1MB chunk reading for photos/videos
            f.write(chunk)

    return {"url": f"/uploads/{filename}", "filename": filename}

# -------------------------------------------------------------
# WebSocket Chat Endpoint
# -------------------------------------------------------------
@app.websocket("/ws/{phone}")
async def websocket_chat(websocket: WebSocket, phone: str):
    await manager.connect(phone, websocket)
    partner_phone = manager.get_partner_phone(phone)

    # When connecting, mark pending messages as delivered
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE messages SET status = 'delivered'
        WHERE receiver_phone = ? AND status = 'sent'
    """, (phone,))
    conn.commit()
    conn.close()

    try:
        while True:
            data = await websocket.receive_text()
            event_data = json.loads(data)
            event_type = event_data.get("type", "message")

            if event_type == "message":
                content = event_data.get("content", "").strip()
                msg_type = event_data.get("msg_type", "text")
                media_url = event_data.get("media_url", "")

                if not content and not media_url:
                    continue

                ts = time.time()
                initial_status = "delivered" if (partner_phone and partner_phone in manager.active_connections) else "sent"

                # Save message in SQLite
                conn = get_db()
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO messages (sender_phone, receiver_phone, content, msg_type, media_url, status, timestamp)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                """, (phone, partner_phone or "", content, msg_type, media_url, initial_status, ts))
                msg_id = cursor.lastrowid
                conn.commit()
                conn.close()

                msg_payload = {
                    "event": "new_message",
                    "id": msg_id,
                    "sender_phone": phone,
                    "receiver_phone": partner_phone,
                    "content": content,
                    "msg_type": msg_type,
                    "media_url": media_url,
                    "status": initial_status,
                    "timestamp": ts,
                    "is_liked": 0
                }

                # Send back to sender for instant UI confirmation
                await websocket.send_json(msg_payload)

                # Send to partner if online
                if partner_phone:
                    await manager.send_to_user(partner_phone, msg_payload)

            elif event_type == "typing":
                # User is typing indicator
                is_typing = event_data.get("is_typing", False)
                if partner_phone:
                    await manager.send_to_user(partner_phone, {
                        "event": "typing",
                        "phone": phone,
                        "is_typing": is_typing
                    })

            elif event_type == "read_receipt":
                # Mark messages as read
                message_ids = event_data.get("message_ids", [])
                if message_ids:
                    conn = get_db()
                    cursor = conn.cursor()
                    placeholders = ",".join(["?"] * len(message_ids))
                    cursor.execute(f"UPDATE messages SET status = 'read' WHERE id IN ({placeholders})", message_ids)
                    conn.commit()
                    conn.close()

                    if partner_phone:
                        await manager.send_to_user(partner_phone, {
                            "event": "messages_read",
                            "message_ids": message_ids
                        })

            elif event_type == "toggle_like":
                # Double tap romantic heart reaction
                msg_id = event_data.get("message_id")
                is_liked = event_data.get("is_liked", 1)
                conn = get_db()
                cursor = conn.cursor()
                cursor.execute("UPDATE messages SET is_liked = ? WHERE id = ?", (is_liked, msg_id))
                conn.commit()
                conn.close()

                reaction_payload = {
                    "event": "message_liked",
                    "message_id": msg_id,
                    "is_liked": is_liked
                }
                await websocket.send_json(reaction_payload)
                if partner_phone:
                    await manager.send_to_user(partner_phone, reaction_payload)

    except WebSocketDisconnect:
        manager.disconnect(phone)
        await manager.broadcast_presence(phone, is_online=False)
    except Exception as e:
        manager.disconnect(phone)
        await manager.broadcast_presence(phone, is_online=False)

if __name__ == "__main__":
    import uvicorn
    print("🚀 تشغيل سيرفر تطبيق 'حبيب عمري'...")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
