import subprocess

def check_kubernetes():
    try:
        nodes = subprocess.check_output(
            ["kubectl", "get", "nodes"],
            text=True
        )

        pods = subprocess.check_output(
            ["kubectl", "get", "pods", "-A"],
            text=True
        )

        return {
            "status": "healthy",
            "nodes": nodes,
            "pods": pods
        }

    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }