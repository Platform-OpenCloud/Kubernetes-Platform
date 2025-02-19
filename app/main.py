import logging
import sys

import uvicorn
from fastapi import FastAPI

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", reload=True, port=8000)
