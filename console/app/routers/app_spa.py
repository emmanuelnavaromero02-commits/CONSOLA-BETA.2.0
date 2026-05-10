from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import FileResponse
from pathlib import Path
import os

STATIC = Path(__file__).resolve().parents[2] / "frontend" / "dist"

router = APIRouter(tags=["SPA"])

@router.get("/app", include_in_schema=False)
@router.get("/app/{path:path}", include_in_schema=False)
async def serve_spa(request: Request, path: str = ""):
    if path.startswith("api/") or path.startswith("auth/") or path.startswith("mcp/") or path.startswith("security/"):
        raise HTTPException(status_code=404, detail="Not Found")

    index_file = STATIC / "index.html"
    if not index_file.exists():
        # Fallback for dev environment or if build is missing
        return {"error": "Frontend build not found. Run npm run build in console/frontend"}

    return FileResponse(index_file)
