import asyncio
from fastapi import FastAPI
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
import requests
app= FastAPI()

@app.get("/", response_class=HTMLResponse)
def front():
    with open("build/web/index.html", "r") as f:
        content = f.read()
    return HTMLResponse(content=content)
@app.get("/etoro/stocks", response_class=JSONResponse)
async def get_etoro_stocks(api_key:str):
    response = requests.get(url=f"https://financialmodelingprep.com/api/v3/stock/full/real-time-price?apikey={api_key}")
    decoded = response.json()

    etoro_urls = []
    for symbol in  [d["symbol"] for d in decoded]:
        etoro_urls.append(requests.get(f"https://www.etoro.com/fr/markets/{symbol}"))
    
    availiable_symbol = []
    responses = await asyncio.gather(etoro_urls)
    for response in responses:
        if response.status_code == 404:
            continue
        availiable_symbol.append(symbol)

    return availiable_symbol

app.mount("/", StaticFiles(directory="build/web"), name="static")

