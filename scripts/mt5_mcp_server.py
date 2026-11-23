from mcp.server.mcpserver import MCPServer
import os

mcp = MCPServer("mt5-dev-tools")

@mcp.tool()
def list_mt5_modules(folder: str = "Include") -> list[str]:
    """Liệt kê các file thư viện MQL5 trong dự án MT5-Dev."""
    target = os.path.join(r"D:\MT5-Dev", folder)
    if not os.path.exists(target):
        return [f"Không tìm thấy thư mục: {target}"]
    return os.listdir(target)

if __name__ == "__main__":
    mcp.run()