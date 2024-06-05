import asyncio
import aiohttp
from fastapi import FastAPI
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
import requests

app = FastAPI()


@app.get("/", response_class=HTMLResponse)
def front():
    with open("build/web/index.html", "r") as f:
        content = f.read()
    return HTMLResponse(content=content)


# @app.get("/etoro/stocks", response_class=JSONResponse)
# async def get_etoro_stocks(api_key: str):
#     response = requests.get(
#         url=f"https://financialmodelingprep.com/api/v3/stock/full/real-time-price?apikey={api_key}"
#     )
#     decoded = response.json()
#     from requests_html import AsyncHTMLSession

#     session = AsyncHTMLSession()
#     etoro_urls = []
#     for symbol in [d["symbol"] for d in decoded][0:10]:
#         etoro_urls.append( session.get(f"https://www.etoro.com/fr/markets/{symbol}"))


#     availiable_symbol = []
#     responses = await asyncio.gather(*etoro_urls)
#     for response in responses:
#         if response.status_code != 200:
#             continue
#         availiable_symbol.append(symbol)

#     return []


app.mount("/", StaticFiles(directory="build/web"), name="static")
