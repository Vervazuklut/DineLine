from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
from typing import List, Dict, Optional
from fastapi.responses import JSONResponse

app = FastAPI(title="DineLine Backend")

# In-memory storage for orders
# Each order: { 'uuid': str, 'order': List[str], 'queue_number': int }
orders: List[Dict] = []

class PlaceOrderRequest(BaseModel):
    uuid: str
    order: List[str]

class CancelOrderRequest(BaseModel):
    uuid: str

@app.get("/getOrder")
def get_order_count():
    """
    Returns the current number of active orders in the system.
    Example response: { "order_count": 3 }
    """
    return {"order_count": len(orders)}

@app.post("/placeOrder")
def place_order(req: PlaceOrderRequest):
    """
    Handles placing a new order. Assigns a queue number based on order of arrival.
    Example request: { "uuid": "abc123", "order": ["Nasi Lemak", "Teh Tarik"] }
    Example response: { "message": "Order placed", "queue_number": 1 }
    """
    # Check if user already has an order
    for o in orders:
        if o['uuid'] == req.uuid:
            return JSONResponse(status_code=400, content={"error": "Order already exists for this user."})
    queue_number = len(orders) + 1
    orders.append({
        'uuid': req.uuid,
        'order': req.order,
        'queue_number': queue_number
    })
    return {"message": "Order placed", "queue_number": queue_number}

@app.get("/getQueueNumber")
def get_queue_number(uuid: str = Query(..., description="User/device UUID")):
    """
    Returns the queue number for a given user/device.
    Example: /getQueueNumber?uuid=abc123
    Example response: { "queue_number": 2 }
    """
    for o in orders:
        if o['uuid'] == uuid:
            return {"queue_number": o['queue_number']}
    return JSONResponse(status_code=404, content={"error": "Order not found for this user."})

@app.post("/cancelOrder")
def cancel_order(req: CancelOrderRequest):
    """
    Cancels an order for a given user/device. Decrements queue numbers for users behind.
    Example request: { "uuid": "abc123" }
    Example response: { "message": "Order cancelled" }
    """
    global orders
    idx = None
    for i, o in enumerate(orders):
        if o['uuid'] == req.uuid:
            idx = i
            break
    if idx is None:
        return JSONResponse(status_code=404, content={"error": "Order not found for this user."})
    # Remove the order
    removed_order = orders.pop(idx)
    # Decrement queue numbers for all orders behind
    for j in range(idx, len(orders)):
        orders[j]['queue_number'] -= 1
    return {"message": "Order cancelled"}

# Example curl requests (for documentation):
# 1. Get order count:
#    curl http://localhost:8000/getOrder
# 2. Place order:
#    curl -X POST http://localhost:8000/placeOrder -H "Content-Type: application/json" -d '{"uuid": "abc123", "order": ["Nasi Lemak", "Teh Tarik"]}'
# 3. Get queue number:
#    curl "http://localhost:8000/getQueueNumber?uuid=abc123"
# 4. Cancel order:
#    curl -X POST http://localhost:8000/cancelOrder -H "Content-Type: application/json" -d '{"uuid": "abc123"}' 