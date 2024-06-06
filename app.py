from fastapi import FastAPI
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles

app = FastAPI()


@app.get("/", response_class=HTMLResponse)
def front():
    with open("build/web/index.html", "r") as f:
        content = f.read()
    return HTMLResponse(content=content)


@app.get("/etoro/stocks", response_class=JSONResponse)
async def get_etoro_stocks(api_key: str):
    with open("etoro_symbols.json") as f:
        data = json.load(f)
    return data


app.mount("/", StaticFiles(directory="build/web"), name="static")
