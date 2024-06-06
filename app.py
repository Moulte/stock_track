import json
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
async def get_etoro_stocks():
    with open("etoro_symbols.json") as f:
        _datas = json.load(f)
    datas = []
    invalid_char=["."," ","_","1","2","3","4","5","6","7","8","9"]
    for d in _datas:
        if not str(d).isupper():
            continue
        for char in invalid_char:
            if char in d:
                break
        else:
            datas.append(d)
    return datas


app.mount("/", StaticFiles(directory="build/web"), name="static")
